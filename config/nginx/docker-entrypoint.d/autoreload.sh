# 99-autoreload.sh

#!/bin/sh

# Attempt to delete default nginx config
default_config="/etc/nginx/conf.d/default.conf"
if [ -e "$default_config" ]; then    
    if rm "$default_config"; then
        echo "Successfully removed $default_config"
    else
        echo "Failed to remove $default_config. Check permissions."
        exit 1
    fi
fi

while :; do
    # Optional: Instead of sleep, detect config changes and only reload if necessary.
    sleep 6h
    nginx -t && nginx -s reload
done &
