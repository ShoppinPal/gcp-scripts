##
### Echo key env variables for sanity testing
##
echo NODE_ENV ${NODE_ENV}
echo GCE_PROJECT_ID ${GCE_PROJECT_ID}
echo GCE_VM_NAME ${GCE_VM_NAME}
echo GCE_CONTAINER_NAME ${GCE_CONTAINER_NAME}
echo GCE_ZONE ${GCE_ZONE}
echo GCE_MACHINE_TYPE ${GCE_MACHINE_TYPE}
echo GCE_PROJECT_DOCKER_IMAGE_NAME ${GCE_PROJECT_DOCKER_IMAGE_NAME}
echo MANIFEST_YAML_ONE_LINER ${MANIFEST_YAML_ONE_LINER}
##
### Build the application as a docker image
##
#docker build -t gcr.io/${GCE_PROJECT_ID}/${GCE_PROJECT_DOCKER_IMAGE_NAME} .
##
### Push the application to the Google Container Registry
##
#gcloud preview docker push gcr.io/${GCE_PROJECT_ID}/${GCE_PROJECT_DOCKER_IMAGE_NAME}
##
### Set project id globally
##
gcloud config set project ${GCE_PROJECT_ID}
##
### Setup manifest.yaml
##
## a) echo takes care of substitutions
#echo -e 'version: 1.0.0\nid: container-vm-loopback\ncontainers:\n  - name: '"${GCE_CONTAINER_NAME}"'\n    image: gcr.io/'"${GCE_PROJECT_ID}"'/'"${GCE_PROJECT_DOCKER_IMAGE_NAME}"'\n    ports:\n      - name: www\n        hostPort: 3000\n        containerPort: 3000' > manifest.yaml
#
## b) what the value for MANIFEST_YAML_ONE_LINER looks like when substitutions are handled by codeship itself for an env value with env variables inside it
#version: 1.0.0\nid: container-vm-loopback\ncontainers:\n  - name: $GCE_CONTAINER_NAME\n    image: gcr.io/$GCE_PROJECT_ID/$GCE_PROJECT_DOCKER_IMAGE_NAME\n    ports:\n      - name: www\n        hostPort: 3000\n        containerPort: 3000
echo -e ${MANIFEST_YAML_ONE_LINER} > manifest.yaml
cat manifest.yaml
##
### Setup Dockerfile
##
echo -e 'FROM google/nodejs\nMAINTAINER ShoppinPal <founders@shoppinpal.com>\n\n# set the working directory\nWORKDIR /app\n\n# add relevant sources into the docker container\nADD package.json /app/\nADD client /app/client\nADD server /app/server\n\nRUN npm install\nRUN export NODE_ENV='"${NODE_ENV}"'\n#ONBUILD ADD . /app\n#ONBUILD ADD node_modules /app/node_modules\n\nRUN set :bind, '0.0.0.0'\nEXPOSE 3000\n#CMD []\nRUN pwd\nRUN ls -alrt\nENTRYPOINT ["/nodejs/bin/npm", "start"]' > Dockerfile
cat Dockerfile
##
### Setup a VM + Docker Container
##
echo "Creating VM: ${GCE_VM_NAME}"
gcloud compute instances create ${GCE_VM_NAME} --tags ${GCE_VM_NAME} --zone ${GCE_ZONE} --machine-type ${GCE_MACHINE_TYPE} --image https://www.googleapis.com/compute/v1/projects/google-containers/global/images/container-vm --metadata-from-file google-container-manifest=manifest.yaml || echo "Probably the VM instance already exists? Let's move on..."
##
### Setup a firewall rule
##
echo "Opening firewall for tcp:3000 to ${GCE_VM_NAME}"
gcloud compute firewall-rules create ${GCE_VM_NAME}-www --allow tcp:3000 --target-tags ${GCE_VM_NAME} || echo "Probably the firewall/rule already exists? Let's move on..."
