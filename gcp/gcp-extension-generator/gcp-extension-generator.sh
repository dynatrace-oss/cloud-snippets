# Copyright 2022 Dynatrace LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#!/usr/bin/env bash
TOKEN=$(gcloud auth print-access-token)
PROJECT=$(gcloud config get project) 

# # Cleanup tmp
mkdir ./tmp
mkdir ./extensions

# # # Get metricDescriptors
curl "https://monitoring.googleapis.com/v3/projects/$PROJECT/metricDescriptors" --header "Authorization: Bearer $TOKEN" --header "Accept: application/json" --compressed   > ./tmp/metricDescriptors.json  

# # # Get monitoredResourceDescriptors
curl "https://monitoring.googleapis.com/v3/projects/$PROJECT/monitoredResourceDescriptors" --header "Authorization: Bearer $TOKEN" --header "Accept: application/json" --compressed   > ./tmp/monitoredResourceDescriptors.json

# Structure output of metricDescriptors into extension format
cat ./tmp/metricDescriptors.json  | jq '  .metricDescriptors[] |  select(has("metadata")) | select(.type |startswith("aws") | not) |
    {   
        service: .monitoredResourceTypes[],         
        metricsMetadata:
        {
            key: ("cloud.gcp." + (.type | gsub("\\.";"_") | gsub("\\/";"."))) , 
            metadata:
            {    
              displayName: .displayName,               
              unit:  (if   .unit == "1" then "Count"
                    elif .unit == "count" then "Count"
                    elif .unit == "{operation}" then "Count"
                    elif .unit == "{packet}" then "Count"
                    elif .unit == "{packets}" then "Count"
                    elif .unit == "{request}" then "Count"
                    elif .unit == "{port}" then "Count"
                    elif .unit == "{connection}" then "Count"
                    elif .unit == "{devices}" then "Count"
                    elif .unit == "{errors}" then "Count"
                    elif .unit == "{cpu}" then "Count"
                    elif .unit == "s" then "Second"
                    elif .unit == "s{idle}" then "Second"
                    elif .unit == "By" then "Byte"
                    elif .unit == "Byte" then "Byte"
                    elif .unit == "bytes" then "Byte"
                    elif .unit == "By/s" then "BytePerSecond"
                    elif .unit == "GiBy" then "GigaByte"
                    elif .unit == "GBy" then  "GigaByte"
                    elif .unit == "MiBy" then "MegaByte"
                    elif .unit == "ns" then "NanoSecond"
                    elif .unit == "us" then "MicroSecond"
                    elif .unit == "ms" then "MilliSecond"
                    elif .unit == "us{CPU}" then "MicroSecond"
                    elif .unit == "10^2.%" then "Percent"
                    elif .unit == "%" then "Percent"
                    elif .unit == "percent" then "Percent"
                    elif .unit == "1/s" then "PerSecond"
                    elif .unit == "frames/seconds" then "PerSecond"
                    elif .unit == "s{CPU}" then "Second"
                    elif .unit == "s{uptime}" then "Second"
                    elif .unit == null then "Unspecified"
                    elif .unit == "{dBm}" then "DecibelMilliWatt"
                    else "Unspecified"
                    end),
            }
        },
        metrics: 
            { 
              value: .type, 
              key: ("cloud.gcp." + (.type | gsub("\\.";"_") | gsub("\\/";"."))) , 
              type: (if   .metricKind == "GAUGE" then "gauge"
                    elif .metricKind == "DELTA" and .valueType =="DISTRIBUTION" then "gauge"
                    elif .metricKind == "DELTA" and .valueType !="DISTRIBUTION" then "count,delta"
                    elif .metricKind == "CUMULATIVE" then "count,delta"
                    else ""
                    end),
              gcpOptions: {         
                    ingestDelay: (.metadata.ingestDelay | gsub("s";"")? | tonumber? )  , 
                    samplePeriod: (.metadata.samplePeriod | gsub("s";"")? | tonumber? ),        
                    valueType: .valueType, 
                    metricKind: .metricKind, 
                    unit: (.unit // "Unspecified")
                },          
              dimensions:  (  try  [.labels?[]? | { key:.key, value:.key}] catch "")
              }
        
    }' | jq -s 'group_by(.service) | map(
        {   
            name: ("custom:dynatrace.extension.google-" + (.[0].service | gsub("_";"-") | gsub("\\.";"_") | gsub("\\/";"_") | ascii_downcase)),
            version: "1.0.0",
            minDynatraceVersion: "1.250",
            author: {
                name:"Dynatrace"
            },
            metrics: map(.metricsMetadata),
            service: .[0].service,
            gcp : [{
                service: .[0].service, 
                metrics: map(.metrics)
            }]
        })'  > ./tmp/parsedMetricDescriptors.json


# Combine together metricDescriptors with monitoredResourceDescriptors
jq -s '[
  .[0].resourceDescriptors[] as $d |
  .[1][] |
  select(.service == $d.type) |
  {
    "name": .name,
    "version" : .version,
    "minDynatraceVersion" : .minDynatraceVersion,
    "author": .author,
    "metrics": .metrics,
    "gcp": [
                {
                    "service": .gcp[0].service,
                    "dimensions": $d.labels | [( .[] | {key: .key, value: .key} )],
                    "metrics": .gcp[0].metrics
                }
            ]
  }
]' ./tmp/monitoredResourceDescriptors.json ./tmp/parsedMetricDescriptors.json > ./tmp/extensions.json

# Prepare JSON output to build a file for each extension 
cat ./tmp/extensions.json |  jq -c ".[]" |

# Iterate through all services
while IFS=$"\n" read -r c; do    
    # build the name from GCP Service
    name=$(echo "$c" | jq -r '.gcp[0].service | gsub("\\.";"_") | gsub("\\/";"_") | ascii_downcase')
    echo $c | jq . >./tmp/$name.json
    mkdir -p ./tmp/$name/extension/dashboards
    # save YAML defintion of extension
    yq eval -P ./tmp/$name.json > ./tmp/$name/extension/extension.yaml
    # build extension content
    cd ./tmp/$name/extension
    zip -r ../extension.zip *
    cd ..
    # sign extensions
    openssl cms -sign -signer $DEVELOPER_PEM -inkey $DEVELOPER_KEY -binary -in extension.zip -outform PEM -out extension.zip.sig
    # build extension bundle
    zip -r ../../extensions/$name.zip  extension.zip*
    cd ../..
done

#Cleanup 
rm -rf ./tmp