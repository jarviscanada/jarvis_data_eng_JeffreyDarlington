#!/bin/sh

cmd=$1
db_username=$2
db_password=$3

sudo systemctl status docker || systemctl start docker

docker container inspect jrvs-psql
container_status=$?

case $cmd in 
	create)
	
	if [ $container_status -eq 0 ]; then
		echo 'Container already exists'
		exit 1
	fi

	# Check # of CLI arguments
	if [ $# -ne 3 ]; then
		echo 'Create requires username and password'
		exit 1
	fi

# Create container
docker volume create pgdata

# Starting the container
docker run --name jrvs-psql \
	-e POSTGRES_USER=$local \
	-e POSTGRES_PASSWORD=$password \
	-v pgdata:/var/lib/postresql/data \
	-p 5432:5432\
	-d postgres

# this is a exit status
exit $?
;;

start|stop)

# Check instance status; exit 1 if the container has not been created
	if [ $container_status -ne 0 ]; then
		echo 'Container does not exist'
		exit 1
	fi

docker container $cmd jrvs-psql
exit $?
;;

*)
	echo 'Illegal command'
	echo 'Commands: start|stop|create'
	exit 1
	;;
esac
