#!/bin/sh

handler () {
    EVENT_DATA=$1
    echo "$EVENT_DATA" 1>&2

    repo=$(echo $EVENT_DATA | jq .repo)
    image_name=$(echo $EVENT_DATA | jq .repo_name)

    git clone --single-branch git@github.com:mgtrrz/bookfeed.git "/tmp/${repo}"


    RESPONSE="Echoing json_data: '$json_data'"
    echo $RESPONSE
}

prepare_key () {
    
}
