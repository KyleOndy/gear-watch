#!/bin/bash
curl --header "Access-Token: $1" \
     --header "Content-Type: application/json" \
     --data-binary "{\"body\":\"$3\",\"title\":\"$2\",\"url\":\"$4\",\"type\":\"link\"}" \
     --request POST \
     https://api.pushbullet.com/v2/pushes
