#!/bin/bash
curl --header "Access-Token: $1" \
     --header "Content-Type: application/json" \
     --data-binary "{\"body\":\"$2\",\"title\":\"$3\",\"type\":\"note\"}" \
     --request POST \
     https://api.pushbullet.com/v2/pushes
