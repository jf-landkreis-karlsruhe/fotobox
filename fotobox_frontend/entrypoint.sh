#!/bin/sh

# Create directory if it doesn't exist
mkdir -p /usr/share/nginx/html/assets/assets/textfiles

# Write token to file
echo "$CRYPTION_KEY" > /usr/share/nginx/html/assets/assets/textfiles/token.txt
echo $BACKEND_URL > /usr/share/nginx/html/assets/assets/textfiles/backend-url.txt
echo $BUTTON_BOX_URL > /usr/share/nginx/html/assets/assets/textfiles/button-box-url.txt

# Start nginx in foreground
nginx -g 'daemon off;'
