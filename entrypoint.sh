#!/usr/bin/env sh
set -e

## ------ EXTRA STEPS, For example purpose ---------
echo 'Composer Install...'
/usr/local/bin/composer install

sleep 10

echo 'Update database..'
vendor/bin/drush updatedb -y

sleep 10

## Import configuration
echo 'Import configuration..'
vendor/bin/drush cim --partial --source=../config/sync -y

sleep 5

## Clear caches again
echo 'Drush cr..'
vendor/bin/drush cr

sleep 5

## ------ EXTRA STEPS, For example purpose ---------

# Start PHP-FPM and Nginx in the background
echo 'nginx and php-fpm...'
php-fpm -D --allow-to-run-as-root
nginx -g 'daemon off;'
