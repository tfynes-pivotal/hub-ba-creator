# hub-ba-creator<img width="973" height="768" alt="image" src="https://github.com/user-attachments/assets/b8dd3004-2450-4b31-b581-90713f87582b" />


#Hub business application auto-generator

Uses direct hub graphql interface to probe for all spaces that contain a substring ad-xxxxxxxx (where x is a numeric)

The objective is to craete a set of 'business applications' based on these 'ad-xxxxxxxx' detected substrings in space-names.

One of these identifiers could be shared across multiple spaces - the goal is to add every space containing this specific ad-xxxxxxxx identifier into the same 'business application'

Lastly the 'ad-xxxxxxxx' string is a 'business appliaction id' - so script will look for and leverage a mapping CSV that will expect every detected business application id in column 1 and corresponding business applciation name

In Hub the business applications with be labeled with "business application name" values per this enrichment


## PreReqs'

Runs on an ops-managerVM, which has python3 but needs pip and pandas python librarires (both included here)
### Install PIP
cd python3-dependencies/
tar zxvf ./pip.tgz
dpkg -i ./*.deb
### Install pandas python library
cd python3-dependencies/
tar zxvf ./pandas.tgz 
cd pandas
pip install ./*.whl

## Getting started

### update 1.getSpacesAndPbas.py (line 104) and curl-hub.sh (line 74) with URL for your Hub

### Grab hub-api oauth token 
<img width="442" height="386" alt="image" src="https://github.com/user-attachments/assets/f11f6e87-23e6-4dad-b0f0-a686dd883c40" />
'copy raw token'
set to env-var 'htoken'
export htoken='<token from clipboard>'

### Walk hub to generate list of candidate spaces (containing 'ad-xxxxxxxx') and the associated unique identifier needed for adding space to a business application (called 'potential business application')
Script1
python3 1.getSpacesAndPbas.py

generates "spaces_with_pbas.csv"

### Ensure a CSV file existing in current directory with all "ad-xxxxxxxx" business application ids listed in column 1 with corresponding business application name in column 2 (header row values; ad_Id,ad_Name)

### Create Business Applications
python3 ./2.createBaList.py ./spaces_with_pbas.csv

