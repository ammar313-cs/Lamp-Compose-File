# Use Ubuntu as the base image
FROM ubuntu:latest

# Install necessary packages and set up LAMP stack
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    mysql-server \
    php libapache2-mod-php php-mysql \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/www/projectlamp \
    && echo 'Hello LAMP from hostname $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) with public IP $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)' > /var/www/projectlamp/index.html \
    && echo '<?php phpinfo(); ?>' > /var/www/projectlamp/index.php \
    && chown -R www-data:www-data /var/www/projectlamp \
    && a2ensite projectlamp \
    && a2dissite 000-default \
    && sed -i 's/index.html index.cgi index.pl index.php index.xhtml index.htm/index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf \
    && service apache2 reload

# Expose port 80
EXPOSE 80

# Start Apache in foreground (for Docker)
CMD ["apachectl", "-D", "FOREGROUND"]
