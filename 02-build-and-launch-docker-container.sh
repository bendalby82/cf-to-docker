#!/usr/bin/env bash
# Name: 		02-build-and-launch-docker-container.sh
# Description:	Given a docker daemon that is connected to a running docker machine, will build
#				a local image and then launch it as a container. 
#				Currently needs the app name to label things nicely - but any string will do.
# Usage: 		./02-build-and-launch-docker-container.sh myapp
# Dependencies:	A docker daemon that is connected to a running docker machine. 
#				A Dockerfile created by 01-make-docker-file-from-cf.sh exists in the current directory
# Location:		https://github.com/bendalby82/cfripper

timestamp(){
  date +"%Y%m%d%H%M%S"
}



if [ "$#" -ne 1 ]; then
    echo -e "You must provide a Cloud Foundry app name to run this script - e.g.: \n$0 myapp"
    exit 1
fi

CFAPP=$1
CONTAINERTAG="cfripper/$CFAPP:$(timestamp)"

#Local build of Docker image. Currently we will always get a new one due to use of timestamp in tag.
docker build -t $CONTAINERTAG .

#Run the container
RUNNING=$(docker ps -a | grep -c $CFAPP)
if [ $RUNNING -gt 0 ]; then
    docker rm -f $CFAPP
    echo "$CFAPP already exists and was removed."
fi
docker run -d -P --name $CFAPP $CONTAINERTAG

#Help the user find it ...
DOCKERIP=$(docker-machine ip $(docker info | grep Name | awk '{print $2}'))
DOCKERPORT=$(docker inspect $CFAPP | grep HostPort | sed 's/[^0-9]//g')

echo "$0: All done! Image build and container started in $SECONDS seconds."
echo -e "\nAccess your containerized application at:\n http://$DOCKERIP:$DOCKERPORT\n"

exit 0
