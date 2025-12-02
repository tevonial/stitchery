#!/bin/bash

set -e

env_path=".env"
env_var="NPM_DEPENDANT_DIRS"

if [ -f "$env_path" ]; then
    echo "Looking for $env_var in $env_path..."

    eval "$(grep "^$env_var=" $env_path)"
    IFS=: read -r -a dirs <<< ${!env_var}

    if [ ${#dirs[@]} -gt 0 ]; then
        for dir in ${dirs[@]}; do
            echo "Installing dependencies: $dir"
            sudo chown -R node:node "./$dir/node_modules"
            npm i --prefix "./$dir"
        done
    else
        echo "No NPM dependant directories specified"
    fi
else
    echo "Environment file not found: $env_path"
fi

exec "$@"