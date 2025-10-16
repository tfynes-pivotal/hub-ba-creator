#!/bin/bash

HUB_URL='https://hub.homelab1.fynesy.com'
curl -s "$HUB_URL/hub/graphql"                      -H "Authorization: Bearer $htoken" -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'Origin: altair://-'  --data-binary '{"query":"query {\n  entityQuery {\n    queryEntities(entityType: \"Tanzu.TAS.Space\", first: 10000) {\n      totalCount\n    }\n  }\n}","variables":{}}'  --compressed | jq -r '.data.entityQuery.queryEntities.totalCount'