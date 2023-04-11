# gcp-extension-generator
### about
The script automates building custom GCP extensions for https://github.com/dynatrace-oss/dynatrace-gcp-monitor.

It auto-discovers all available metrics and resource descriptors using `gcloud SDK` and generates signed extensions files, that can be uploaded into Dynatrace Hub.

### Prerequisites
Bash terminal (ideally Ubuntu 18.X) with following dependencies:
* Google Cloud SDK 
https://cloud.google.com/sdk/docs#install_the_latest_cloud_tools_version_cloudsdk_current_version
* the terminal should be authenticated to Google 
``` 
gcloud auth login
```
* jq (version 1.6)
```
sudo wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O /usr/bin/jq && sudo chmod +x /usr/bin/jq'
```

* yq (4.9.x+) 
```
sudo wget https://github.com/mikefarah/yq/releases/download/v4.9.8/yq_linux_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq'
```
* curl
* unzip
* OpenSSL
* `Root Key& Certificate` & `Developer certificate` created and added to `Dynatrace credential vault` 
https://www.dynatrace.com/support/help/extend-dynatrace/extensions20/sign-extension


### Reference
* https://github.com/dynatrace-oss/dynatrace-gcp-monitor/blob/master/HACKING.md
* https://www.dynatrace.com/support/help/extend-dynatrace/extensions20/sign-extension

### Usage
```
export DEVELOPER_KEY=..PATH-TO-DEVELOPER-KEY..key
export DEVELOPER_PEM=..PATH-TO-DEVELOPER-PEM..pem
gcp-extension-generator.sh
```

Source:

[gcp-extension-generator.sh](./gcp-extension-generator.sh)
