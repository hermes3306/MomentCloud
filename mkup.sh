#!/bin/bash

# Path to the upload directory
UPLOAD_DIR="/home/pi/MomentCloud/upload"

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Create the directory if it doesn't exist
mkdir -p "$UPLOAD_DIR"

# Change ownership of the directory to www-data
chown -R www-data:www-data "$UPLOAD_DIR"

# Set directory permissions
chmod -R 775 "$UPLOAD_DIR"

# Add pi user to www-data group
usermod -a -G www-data pi

# Restart Apache and PHP-FPM (if used)
systemctl restart apache2
# Uncomment the next line if you're using PHP-FPM
# systemctl restart php7.4-fpm  # Replace 7.4 with your PHP version if different

echo "Permissions have been set for $UPLOAD_DIR"
echo "The 'pi' user has been added to the www-data group"
echo "Apache has been restarted"

# Verify the changes
echo "Directory permissions:"
ls -ld "$UPLOAD_DIR"
echo "Group membership for pi user:"
groups pi
