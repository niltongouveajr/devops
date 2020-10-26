#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

CMD=$(/usr/bin/curl --silent -X GET "https://<user>:<pass>@jenkins.local/api/json?pretty=true")

echo -e "All       : `echo "$CMD" | grep name | grep -v [A-Z] | wc -l`"
echo -e "Success   : `echo "$CMD" | grep color | grep blue | wc -l`"
echo -e "Failed    : `echo "$CMD" | grep color | grep red | wc -l`"
echo -e "Disabled  : `echo "$CMD" | grep color | grep disabled | wc -l`"
echo -e "Not Built : `echo "$CMD" | grep color | grep notbuilt | wc -l`"
