#!/bin/bash

apm_format() {
	printf "ad%08d" "$1"
}

ORG_NAME=lotsofspacestest

cf create-org $ORG_NAME
sleep 1
cf target -o $ORG_NAME
sleep 1
for i in {1..1000} 
do
	formatted_i=$(apm_format $i)
	echo cf create-space "dev-$formatted_i" -o  $ORG_NAME
	cf create-space "dev-$formatted_i" -o  $ORG_NAME
	#cf target -o spacestest -s "prod-$formatted_i"
	#pushd ./testapp
	#cf push "app1-$i" -b binary_buildpack -c "python3 -m http.server 8080" -m 32M -k 1M &
	#sleep 10
	#popd
done

ORG_NAME+="2"
echo ORGNAME=$ORG_NAME

 cf create-org $ORG_NAME
 sleep 1
 cf target -o $ORG_NAME
 sleep 1
 for i in {1..1000} 
 do
	formatted_i=$(apm_format $i)
 	echo cf create-space "dev2-$formatted_i" -o $ORG_NAME
 	cf create-space "dev2-$formatted_i" -o $ORG_NAME
 	#cf target -o spacestest2 -s "prod2-$formatted_i"
	#echo "TARGETTING SPACE prod2-$formatted_i"
 	#pushd ./testapp
 	#cf push "app2-$i" -b binary_buildpack -c "python3 -m http.server 8080" -m 32M -k 1M &
 	#sleep 10
	#popd
 done

