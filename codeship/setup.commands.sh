###
## install gcloud
###
export CLOUDSDK_PYTHON_SITEPACKAGES=1; export CLOUDSDK_CORE_DISABLE_PROMPTS=1; curl -s https://sdk.cloud.google.com | bash
source ~/.bashrc
which gcloud
###
## setup gcloud credentials
###
echo '{  "data": [...],  "file_version": 1}' > ~/.config/gcloud/credentials
cat ~/.config/gcloud/credentials
#echo '' > ~/.config/gcloud/properties
printf '[core]\naccount = ...' > ~/.config/gcloud/properties
cat ~/.config/gcloud/properties
#echo '' > ~/.config/gcloud/application_default_credentials.json
###
## verify gcloud creds setup
###
gcloud compute instances list --project ...
###
## setup node
###
nvm install 0.10.36
nvm use 0.10.36
###
## project specific setup
###
npm install
npm install grunt-cli
npm install bower
bower install
###
## environment specific setup
###
echo '...' > server/config.staging.json
cat server/config.staging.json
##
### run the build
##
grunt deploy:staging
