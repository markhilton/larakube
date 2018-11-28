cd /app
echo "Laravel provisioning..."

dirs=( "/app/storage/app/public" "/app/storage/framework/cache" "/app/storage/framework/sessions" "/app/storage/framework/testing" "/app/storage/framework/views" "/app/storage/logs" )

for i in "${dirs[@]}"; do
    [ -d "$i" ] || mkdir -p $i
done

chmod -R 777 /app/storage
chmod -R 777 /app/public/storage
chown -R 9000:9000 /app/storage
chown -R 9000:9000 /app/public/storage

php artisan migrate --force
php artisan clear-compiled
php artisan cache:clear
php artisan view:clear
php artisan route:clear
php artisan config:clear
