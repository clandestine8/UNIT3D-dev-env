FROM fedora:41

RUN dnf -y install https://fr2.rpmfind.net/linux/remi/fedora/remi-release-41.rpm https://dev.mysql.com/get/mysql84-community-release-fc41-1.noarch.rpm
RUN dnf config-manager setopt remi.enabled=1
RUN dnf update -y
RUN dnf module reset php
RUN dnf module -y enable php:remi-8.3
RUN dnf install -y \
    php php-fpm php-common \
    php-gd \
    php-zip \
    php-sodium \
    php-pdo \
    php-mysqlnd \
    php-intl \
    php-bcmath \
    php-sockets \
    php-soap \
    git \
    sed \
    nodejs \
    npm \
    openssh-clients \
    libzip-devel \
    libsodium-devel \
    icu \
    freetype-devel \
    libjpeg-turbo-devel \
    libpng-devel \
    supervisor \
    php-pecl-imagick \
    php-pecl-redis \
    mysql-community-client \
    mysql-community-libs \
    && dnf clean all

# Set working directory
WORKDIR /var/www

#Laravel Echo Server Install
RUN npm install -g laravel-echo-server
RUN npm install -g bun

# Configure PHP-FPM
RUN mkdir -p /etc/php-fpm.d/ && \
    echo "[global]" > /etc/php-fpm.d/www.conf && \
    echo "error_log = /proc/self/fd/2" >> /etc/php-fpm.d/www.conf && \
    echo "log_limit = 8192" >> /etc/php-fpm.d/www.conf && \
    echo "daemonize = no" >> /etc/php-fpm.d/www.conf && \
    echo "" >> /etc/php-fpm.d/www.conf && \
    echo "[www]" >> /etc/php-fpm.d/www.conf && \
    echo "listen = /var/run/unit3d/www.sock" >> /etc/php-fpm.d/www.conf && \
    echo "pm = dynamic" >> /etc/php-fpm.d/www.conf && \
    echo "pm.max_children = 3" >> /etc/php-fpm.d/www.conf && \
    echo "pm.start_servers = 1" >> /etc/php-fpm.d/www.conf && \
    echo "pm.min_spare_servers = 1" >> /etc/php-fpm.d/www.conf && \
    echo "pm.max_spare_servers = 2" >> /etc/php-fpm.d/www.conf && \
    echo "user = 1000" >> /etc/php-fpm.d/www.conf && \
    echo "group = 1000" >> /etc/php-fpm.d/www.conf && \
    echo "access.log = /proc/self/fd/2" >> /etc/php-fpm.d/www.conf && \
    echo "catch_workers_output = yes" >> /etc/php-fpm.d/www.conf && \
    echo "decorate_workers_output = no" >> /etc/php-fpm.d/www.conf && \
    echo "clear_env = no" >> /etc/php-fpm.d/www.conf

# Ensure the directory for PID exists
RUN mkdir -p /run/php-fpm && \
    chmod 755 /run/php-fpm && \
    chown 1000:1000 /run/php-fpm

# Configure PHP.ini
RUN sed -i 's/memory_limit = 128M/memory_limit = -1/' /etc/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10G/' /etc/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 10G/' /etc/php.ini && \
    sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php.ini

# Create entry scripts
RUN echo '#!/bin/sh' > /usr/bin/entry && \
    echo 'umask 0002' >> /usr/bin/entry && \
    echo '/usr/bin/start' >> /usr/bin/entry && \
    \
    echo '#!/bin/sh' > /usr/bin/start && \
    echo "[ -f laravel-echo-server.lock ] && rm laravel-echo-server.lock" >> /usr/bin/start && \
    echo "php-fpm & \\" >> /usr/bin/start && \
    echo "laravel-echo-server start --dir=/var/www & \\" >> /usr/bin/start && \
    echo "/usr/bin/schedule & \\" >> /usr/bin/start && \
    echo "php /var/www/artisan queue:work redis -v --sleep=3 --tries=3 --max-time=3600" >> /usr/bin/start && \
    \
    echo '#!/bin/sh' > /usr/bin/first && \
    echo 'cd /var/www/' >> /usr/bin/first && \
    echo 'php artisan storage:link' >> /usr/bin/first && \
    echo 'php artisan key:generate' >> /usr/bin/first && \
    echo 'php artisan migrate:fresh --seed' >> /usr/bin/first && \
    \
    echo '#!/bin/bash' >> /usr/bin/schedule && \
    echo 'while true; do' >> /usr/bin/schedule && \
    echo '  sleep 30' >> /usr/bin/schedule && \
    echo '  php /var/www/artisan schedule:run' >> /usr/bin/schedule && \
    echo '  sleep 30' >> /usr/bin/schedule && \
    echo 'done' >> /usr/bin/schedule && \
    \
    chmod +x /usr/bin/entry /usr/bin/start /usr/bin/first /usr/bin/schedule



# Clean up
RUN rm -rf /var/www/*

# Expose PHP-FPM port
EXPOSE 9000

# Set entrypoint and default command
ENTRYPOINT ["/usr/bin/entry"]
CMD ["/usr/bin/entry"]
