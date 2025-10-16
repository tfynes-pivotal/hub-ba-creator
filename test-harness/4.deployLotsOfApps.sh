#!/bin/bash

apm_format() {
	printf "ad%08d" "$1"
}

ORG_NAME=lotsofspacestest

# cf target -o $ORG_NAME
# sleep 1
# for i in {1..1000} 
# do
# 	formatted_i=$(apm_format $i)
# 	cf target -o $ORG_NAME  -s "dev-$formatted_i"
# 	cf push $"tinyapp1-$i" --droplet ./tmp/tinyapp-droplet.tgz -m 4M -k 1M -c "/home/vcap/app/tinyapp.sh" &
# done

ORG_NAME+="2"
echo ORGNAME=$ORG_NAME

cf target -o $ORG_NAME
sleep 1
for i in {2..1000} 
do
	formatted_i=$(apm_format $i)
  	cf target -o $ORG_NAME  -s "dev2-$formatted_i"
 	cf push $"tinyapp2-$i" --droplet ./tmp/tinyapp-droplet.tgz -m 4M -k 1M -c "/home/vcap/app/tinyapp.sh" &
done

