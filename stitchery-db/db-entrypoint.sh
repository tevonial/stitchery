#!/usr/bin/env bash

echo "===> Beginning db-entrypoint.sh"

ENTRYPOINT_DIR="/entrypoint.d"
DOCKER_ENTRYPOINT="$(command -v docker-entrypoint.sh)"

# Ensure credentials file exists
if [[ ! -f "$DB_CREDENTIALS_FILE" ]]; then
    echo "Error: No database credentials secret found at '$DB_CREDENTIALS_FILE'."
    exit 1
fi

if ! type -P $main_entrypoint >/dev/null 2>&1; then
    echo "Error: Main entrypoint script '$DOCKER_ENTRYPOINT' not found or not executable."
    exit 1
fi


# Process entrypoint scripts and environment files
function process_entrypoints {
    for dir in "$@"; do
        if [[ -d "$dir" ]]; then
            echo "Processing entrypoint directory: '$dir'"
            for ep in "$dir"/*; do
                ext="${ep##*.}"
                if [[ "${ext}" = "env" ]] && [[ -f "${ep}" ]]; then
                    # source files ending in ".env"
                    echo "Sourcing: ${ep}"
                    set -a && . "${ep}" && set +a
                elif [[ "${ext}" = "sh" ]] && [[ -x "${ep}" ]]; then
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

# Add database credentials to etc/entrypoint.d with symlink
# Then, begin processing the contents of entrypoint directory

ln -s $DB_CREDENTIALS_FILE "${ENTRYPOINT_DIR}/db-credentials.env"
process_entrypoints $ENTRYPOINT_DIR

echo "<=== Returning control to main entrypoint script ($(which $DOCKER_ENTRYPOINT))"
exec $DOCKER_ENTRYPOINT "$@"
