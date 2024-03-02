#!/usr/bin/env bash
# check if ENVIRONMENT is set
usage() {
    echo "Usage: run.sh <up|stop|down|rm>"
    exit 1
}
if [ -z "$ENVIRONMENT" ]; then
    echo "ENVIRONMENT is not set - defaulting to dev"
    export ENVIRONMENT=dev
fi
# check if $1 is set
if [ -z "$1" ]; then
    echo "No argument supplied"
    usage
fi
echo "ENVIRONMENT is set to $ENVIRONMENT"
docker_compose_args="--project-directory ."
if [ "$ENVIRONMENT" = "dev" ]; then
    # docker_compose_args="--env-file dev/.env -f docker-compose.yml -f dev/docker-compose.yml"
    docker_compose_args="$docker_compose_args -f dev/docker-compose.yml"
fi

if [ "$1" = "up" ]; then
    echo "Starting the application"
    command="docker compose $docker_compose_args up -d --pull always"
    echo $command
    exec $command
    exit 0
fi
if [ "$1" = "stop" ]; then
    echo "Stopping the application"
    command="docker compose $docker_compose_args stop"
    echo $command
    exec $command
    exit 0
fi
if [ "$1" = "down" ]; then
    echo "Stopping and removing the application"
    command="docker compose $docker_compose_args down"
    echo $command
    exec $command
    exit 0
fi
if [ "$1" = "rm" ]; then
    echo "Removing the application"
    command="docker compose $docker_compose_args rm --force --stop --volumes"
    echo $command
    exec $command
    exit 0
fi
echo "Invalid argument"
usage
