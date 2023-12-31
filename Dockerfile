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
    && echo 'Hello LAMP from hostname $(curl -s http://13.58.82.133/latest/meta-data/public-hostname) with public IP $(curl -s http://13.58.82.133/latest/meta-data/public-ipv4)' > /var/www/projectlamp/index.html \
    && echo '<?php phpinfo(); ?>' > /var/www/projectlamp/index.php \
    && chown -R www-data:www-data /var/www/projectlamp

# Create the projectlamp site configuration for Apache
RUN echo '<VirtualHost *:80>\n\
    ServerName projectlamp\n\
    ServerAlias www.projectlamp\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/projectlamp\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/projectlamp.conf

# Enable the projectlamp site configuration and disable default site
RUN a2ensite projectlamp && a2dissite 000-default

# Adjust Apache configuration
RUN sed -i 's/index.html index.cgi index.pl index.php index.xhtml index.htm/index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

# Reload Apache
CMD service apache2 reload

# Expose port 80
EXPOSE 80

# Start Apache in foreground (for Docker)
CMD ["apachectl", "-D", "FOREGROUND"]
