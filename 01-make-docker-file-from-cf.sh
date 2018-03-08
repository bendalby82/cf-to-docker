#!/usr/bin/env bash
# Name: 		01-make-docker-file-from-cf.sh
# Description:	Given a CF CLI that is logged into Cloud Foundry, will extract a running Java apps
#				droplet and configuration, and construct a Docker file to run the same application.
# Usage: 		./01-make-docker-file-from-cf.sh spring-music
# Dependencies:	Your Cloud Foundry user must have access to cf API, and to cf ssh command.
# Location:		https://github.com/bendalby82/cf-to-docker

if [ "$#" -ne 1 ]; then
    echo -e "You must provide a Cloud Foundry app name to run this script - e.g.: \n$0 myapp \nAlso you must be logged into Cloud Foundry in the right org and space for the app you wish to migrate."
    exit 1
fi

CFAPP=$1
CFBLOBNAME=droplet-$CFAPP

#Retreive GUID for CFAPP
CFAPPGUID=$(cf app $1 --guid)
if [[ $CFAPPGUID =~ FAILED ]]
then
	echo "Failed to retreive GUID - please check your app name"
	exit 1
fi

#Retrieve port and memory environment settings
CFENV=$(cf ssh spring-music -c env)
CFPORT=$(echo $CFENV | sed 's/.*PORT=\([0-9]*\).*/\1/')
CFMEM=$(echo $CFENV | sed 's/.*MEMORY_LIMIT=\([^\s]*m\).*/\1/')

#Retrieve and unpack droplet
cf curl /v2/apps/$CFAPPGUID/droplet/download > $CFBLOBNAME.tar.gz
mkdir ./$CFBLOBNAME
tar -xvzf $CFBLOBNAME.tar.gz -C ./$CFBLOBNAME

#Extract and process the handy start command from the staging_info.yml file.
CFSTARTCMD=$(cat ./$CFBLOBNAME/staging_info.yml | sed 's/.*"start_command":"\(.*\)"}/\1/' | sed 's/\\u0026/\&/g' | sed 's/\\"/"/g' | sed 's/CALCULATED_MEMORY=/CALCULATED_MEMORY="/' | sed 's/MEMORY_LIMIT)/MEMORY_LIMIT)"/')

#Create the Dockerfile
cat << EOF > ./Dockerfile
FROM ubuntu:16.04
COPY $CFBLOBNAME /home/vcap/
EXPOSE $CFPORT
ENV TMPDIR /tmp
ENV PORT $CFPORT
ENV MEMORY_LIMIT $CFMEM
WORKDIR /home/vcap/app
CMD $CFSTARTCMD
EOF

echo "$0 successfully executed in $SECONDS seconds."

exit 0
