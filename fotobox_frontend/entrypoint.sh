#!/bin/sh

# Create directory if it doesn't exist
mkdir -p /usr/share/nginx/html/assets/assets/textfiles

# Write token to file
echo "$CRYPTION_KEY" > /usr/share/nginx/html/assets/assets/textfiles/Token.txt

# Start nginx in foreground
nginx -g 'daemon off;'