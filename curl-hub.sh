#!/bin/bash
echo curl hub $@

entityName="$1"
echo entityName=$entityName
pbas=("${@:2}")
echo "pbas = ${pbas[@]}"

pbas_formatted=$(printf '"%s",' "${pbas[@]}" | sed 's/,$//')
pbas_formatted="[$pbas_formatted]"

entityName_formatted="\\\"$entityName\\\""

# "query": "mutation {
#             businessAppMutation {
#                 upsertBusinessApplications(
#                     input: [
#                         {
#                             entityName: \$entityNameVar
#                             potentialBusinessApps: \$pbasVar
#                         }
#                     ]
#                 ) {
#                     entities {
#                         entityId
#                     }
#                     errors {
#                         entityId
#                         entityName
#                         errorMsg
#                         errorType
#                     }
#                   }
#             }
#         }",
# query=$(cat << EOF
# {
# "query": "mutation UpsertBusinessApps(\$entityName: String!, \$potentialBusinessApps: [String!]!) { businessAppMutation { upsertBusinessApplications( input: [ { entityName: \$entityName, potentialBusinessApps: \$potentialBusinessApps } ] ) { entities { entityId } errors { entityId entityName errorMsg errorType } } } }",
#   "variables": {
#     "entityName": "$entityName",
#     "potentialBusinessApps": $pbas_formatted
#   }
# }
# EOF
# )

query=$(cat << EOF
{
"query": "mutation UpsertBusinessApps(\$entityName: String!, \$potentialBusinessApps: [EntityId!]!) { businessAppMutation { upsertBusinessApplications( input: [ { entityName: \$entityName, potentialBusinessApps: \$potentialBusinessApps } ] ) { entities { entityId } errors { entityId entityName errorMsg errorType } } } }",
"variables": {
    "entityName": "$entityName",
    "potentialBusinessApps": $pbas_formatted
}
}
EOF
)

echo "entityName=$entityName"
echo "pbas=$pbas_formatted"
echo "query=$query"
# tmp="${query/\"/\'}"
# query="${tmp%\"/\'}"
# echo
# echo "updated query: $query"
# echo

#query_formatted=$(echo $query | tr -d '\n\t' | tr -s ' ' | sed 's/ $//')


#echo 
#echo "query_formatted=$query_formatted"
#echo

curl 'https://hub.homelab1.fynesy.com/hub/graphql' -H "Authorization: Bearer $htoken" -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'Origin: altair://-'  --data-binary "$query"  --compressed


echo
echo done
echo
