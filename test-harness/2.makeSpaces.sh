#!/bin/bash

apm_format() {
	printf "ad%08d" "$1"
}

cf create-org -o spacestest
for i in {1..25} 
do
	formatted_i=$(apm_format $i)
	echo "Test: input $i output $formatted_i"
	echo cf create-space "prod-$formatted_i" -o spacestest 
	cf create-space "prod-$formatted_i" -o spacestest 
	cf target -o spacestest -s "prod-$formatted_i"
	pushd ./testapp
	cf push "app1-$i" -b binary_buildpack -c "python3 -m http.server 8080" -m 32M -k 1M &
	sleep 10
	popd
done
 cf create-org spacestest2
 for i in {1..25} 
 do
	formatted_i=$(apm_format $i)
 	echo cf create-space "prod2-$formatted_i" -o spacestest2 
 	cf create-space "prod2-$formatted_i" -o spacestest2 
 	cf target -o spacestest2 -s "prod2-$formatted_i"
	echo "TARGETTING SPACE prod2-$formatted_i"
 	pushd ./testapp
 	cf push "app2-$i" -b binary_buildpack -c "python3 -m http.server 8080" -m 32M -k 1M &
 	sleep 10
	popd
 done

