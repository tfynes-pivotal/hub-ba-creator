#!/bin/bash

CURSOR=''
if [ "$#" -eq 1 ]; then
    CURSOR="$1"
    #echo setting cursor to $CURSOR
fi


HUB_URL='https://hub.homelab1.fynesy.com'

first_count='1000'


hasNextPage() {
    #echo "inside hasNextPage: cursor=$CURSOR"
    if [[ "$CURSOR" == "" ]]; then
        curl -s  "$HUB_URL/hub/graphql"  -H "Authorization: Bearer $htoken"  -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'Origin: altair://-' --data-binary "{\"query\":\"{\n  entityQuery {\n    queryEntities(\n      entityType: \\\"Tanzu.TAS.Space\\\"\n      sort: { field: \\\"lastUpdateTime\\\", order: DESC }\n       first: $first_count\n         ) {\n      totalCount\n      pageInfo {\n        endCursor\n        hasNextPage\n      }\n      entities {\n        entityId\n        entityName\n        entitiesIn (entityType:\\\"Tanzu.Hub.PotentialBusinessApplication\\\") {\n      entities {\n            entityId\n            entityName\n          }\n        }\n      }\n    }\n  }\n}\",\"variables\":{}}" --compressed | jq -r '.data.entityQuery.queryEntities.pageInfo.endCursor'
    else
        curl -s  "$HUB_URL/hub/graphql"  -H "Authorization: Bearer $htoken"  -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'Origin: altair://-' --data-binary "{\"query\":\"{\n  entityQuery {\n    queryEntities(\n      entityType: \\\"Tanzu.TAS.Space\\\"\n      sort: { field: \\\"lastUpdateTime\\\", order: DESC }\n       first: $first_count\n   after: \\\"$CURSOR\\\"\n         ) {\n      totalCount\n      pageInfo {\n        endCursor\n        hasNextPage\n      }\n      entities {\n        entityId\n        entityName\n        entitiesIn (entityType:\\\"Tanzu.Hub.PotentialBusinessApplication\\\") {\n      entities {\n            entityId\n            entityName\n          }\n        }\n      }\n    }\n  }\n}\",\"variables\":{}}" --compressed | jq -r '.data.entityQuery.queryEntities.pageInfo.endCursor'
    fi
}

#result=$(hasNextPage)
#echo "result = $result"

getSpacesAndPBAsPage() {
    local myCursor=$1
    if [[ "$myCursor" == "" ]]; then
        curl -s  "$HUB_URL/hub/graphql"  -H "Authorization: Bearer $htoken"  -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'Origin: altair://-' --data-binary "{\"query\":\"{\n  entityQuery {\n    queryEntities(\n      entityType: \\\"Tanzu.TAS.Space\\\"\n      sort: { field: \\\"lastUpdateTime\\\", order: DESC }\n       first: $first_count\n         ) {\n      totalCount\n      pageInfo {\n        endCursor\n        hasNextPage\n      }\n      entities {\n        entityId\n        entityName\n        entitiesIn (entityType:\\\"Tanzu.Hub.PotentialBusinessApplication\\\") {\n      entities {\n            entityId\n            entityName\n          }\n        }\n      }\n    }\n  }\n}\",\"variables\":{}}" --compressed
    else
        curl -s  "$HUB_URL/hub/graphql"  -H "Authorization: Bearer $htoken"  -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'Origin: altair://-' --data-binary "{\"query\":\"{\n  entityQuery {\n    queryEntities(\n      entityType: \\\"Tanzu.TAS.Space\\\"\n      sort: { field: \\\"lastUpdateTime\\\", order: DESC }\n       first: $first_count\n   after: \\\"$myCursor\\\"\n         ) {\n      totalCount\n      pageInfo {\n        endCursor\n        hasNextPage\n      }\n      entities {\n        entityId\n        entityName\n        entitiesIn (entityType:\\\"Tanzu.Hub.PotentialBusinessApplication\\\") {\n      entities {\n            entityId\n            entityName\n          }\n        }\n      }\n    }\n  }\n}\",\"variables\":{}}" --compressed
    fi
}


# if [[ "$CURSOR" == "" ]]; then
#     curl -s  "$HUB_URL/hub/graphql"  -H "Authorization: Bearer $htoken"  -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'Origin: altair://-' --data-binary "{\"query\":\"{\n  entityQuery {\n    queryEntities(\n      entityType: \\\"Tanzu.TAS.Space\\\"\n      sort: { field: \\\"lastUpdateTime\\\", order: DESC }\n       first: $first_count\n         ) {\n      totalCount\n      pageInfo {\n        endCursor\n        hasNextPage\n      }\n      entities {\n        entityId\n        entityName\n        entitiesIn (entityType:\\\"Tanzu.Hub.PotentialBusinessApplication\\\") {\n      entities {\n            entityId\n            entityName\n          }\n        }\n      }\n    }\n  }\n}\",\"variables\":{}}" --compressed
# else
#     curl -s  "$HUB_URL/hub/graphql"  -H "Authorization: Bearer $htoken"  -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'Origin: altair://-' --data-binary "{\"query\":\"{\n  entityQuery {\n    queryEntities(\n      entityType: \\\"Tanzu.TAS.Space\\\"\n      sort: { field: \\\"lastUpdateTime\\\", order: DESC }\n       first: $first_count\n   after: \\\"$CURSOR\\\"\n         ) {\n      totalCount\n      pageInfo {\n        endCursor\n        hasNextPage\n      }\n      entities {\n        entityId\n        entityName\n        entitiesIn (entityType:\\\"Tanzu.Hub.PotentialBusinessApplication\\\") {\n      entities {\n            entityId\n            entityName\n          }\n        }\n      }\n    }\n  }\n}\",\"variables\":{}}" --compressed
# fi

getAllSpacesAndPBAs() {
    # First page
    local page_content=$(getSpacesAndPBAsPage)
    echo $page_content
    local myCursor=$(hasNextPage)
    while [[ -n "$myCursor" ]]; do
        # 2 or more pages
        next_page=$(getSpacesAndPBAsPage $myCursor)
        echo $next_page
        page_content+=next_page
        newCursor=$(echo $next_page | jq -r '.data.entityQuery.queryEntities.pageInfo.endCursor')
        if [[ "$newCursor" == "null" ]]; then
            myCursor="" # Set to truly empty string to break the loop
        else
            myCursor=$newCursor
        fi
    done
}


getAllSpacesAndPBAs
