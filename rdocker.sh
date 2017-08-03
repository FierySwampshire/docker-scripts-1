#!/bin/bash


# default list of env variables, which can be overriden in ~/.rdocker
declare -a env_vars=( "AWS_REGION" "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" )

if [ -f ~/.rdocker ]; then
    source ~/.rdocker
fi

export docker_run_cmd="docker container run "

for env_var_name in "${env_vars[@]}"
do
    if [ ! "${!env_var_name}" == "" ]; then
        export docker_run_cmd="$docker_run_cmd -e ${env_var_name}=${!env_var_name}"
    fi
done

export docker_run_cmd="$docker_run_cmd $*"

echo "Starting docker command : $docker_run_cmd"
eval "$docker_run_cmd"