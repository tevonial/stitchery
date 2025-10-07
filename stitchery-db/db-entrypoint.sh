#!/usr/bin/env bash

echo "Beginning db-entrypoint.sh"
entrypoint_dir="/entrypoint.d"

# Process entrypoint scripts and environment files
function process_entrypoints {
    for dir in "$@"; do
        echo "Processing entrypoint directory: '$dir'"
        if [ -d "$dir" ]; then
            for ep in "$dir"/*; do
                ext="${ep##*.}"
                if [ "${ext}" = "env" ] && [ -f "${ep}" ]; then
                    # source files ending in ".env"
                    echo "Sourcing: ${ep}"
                    set -a && . "${ep}" && set +a
                elif [ "${ext}" = "sh" ] && [ -x "${ep}" ]; then
                    # run scripts ending in ".sh"
                    echo "Running: ${ep}"
                    "${ep}"
                fi
            done
        else
            echo "Entrypoint directory '$dir' does not exist, skipping."
        fi
    done
}

db_credentials="/run/secrets/db-credentials"
if [ -f "$db_credentials" ]; then
    # Symlink the database credentials to etc/entrypoint.d for processing
    ln -s $db_credentials "${entrypoint_dir}/db-credentials.env"
else
    echo "Error: No database credentials secret found at '$db_credentials'."
    exit 1
fi

process_entrypoints $entrypoint_dir

# Ensure the main entrypoint script exists and is executable
main_entrypoint="docker-entrypoint.sh"
if type -P $main_entrypoint >/dev/null 2>&1; then
    echo "Returning to main entrypoint"
    echo "Running: $main_entrypoint $@"
    echo "$(which $main_entrypoint)"
    echo "POSTGRES_USER: $POSTGRES_USER"
    echo "POSTGRES_DB: $POSTGRES_DB"
    echo "POSTGRES_PORT: $POSTGRES_PORT"
    exec $main_entrypoint $@
else
    echo "Error: Main entrypoint script '$main_entrypoint' not found or not executable."
    exit 1
fi
