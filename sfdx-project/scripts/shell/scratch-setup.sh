sf org create scratch -d -f config/project-scratch-def.json -a apex-mdapi
sf project deploy start -o apex-mdapi -d force-app
sf org assign permset --name Apex_Metadata_API --target-org apex-mdapi
sf org open -p /lightning/n/Metadata_Browser_LWC