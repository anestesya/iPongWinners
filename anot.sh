#!/bin/bash
echo $1
echo $2
curl -u worldcupsoutha:c0p42010sa -d status="$1" -d source='mybashscript' $2  http://twitter.com/statuses/update.xml
