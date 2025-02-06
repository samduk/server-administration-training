#!/usr/bin/bash
# written by BCA gang

# Update and Upgrade System Packages
sudo apt update -y && sudo apt upgrade -y

# Set System Timezone to Asia/Kolkata
sudo timedatectl set-timezone Asia/Kolkata

# Install Apache2, OpenSSL, and other required dependencies
sudo apt install -y apache2 openssl software-properties-common wget

# Install MySQL Server
sudo apt install -y mysql-server

# Install PHP 8.3 and required PHP extensions
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update -y
sudo apt install -y php8.3 php8.3-common php8.3-mysql php8.3-xml php8.3-xmlrpc \
    php8.3-curl php8.3-gd php8.3-imagick php8.3-cli php8.3-dev php8.3-imap \
    php8.3-mbstring php8.3-opcache php8.3-soap php8.3-zip php8.3-redis php8.3-intl

# Download latest WordPress and extract
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz

# Move WordPress to /var/www/html and set proper ownership
sudo mv wordpress /var/www/html/
sudo chown -R www-data:www-data /var/www/html/wordpress

# Create MySQL Database and User with proper privileges
sudo mysql -u root -e "CREATE DATABASE bca CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -u root -e "CREATE USER 'researcher'@'localhost' IDENTIFIED BY 'root123';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON bca.* TO 'researcher'@'localhost' WITH GRANT OPTION;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# Configure WordPress Database Settings
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i "s/database_name_here/bca/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/researcher/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/root123/" /var/www/html/wordpress/wp-config.php

# Generate a self-signed SSL certificate
sudo mkdir -p /etc/ssl/private /etc/ssl/certs
sudo openssl req -nodes -newkey rsa:2048 -keyout /etc/ssl/private/bca.key -out /etc/ssl/private/bca.csr -subj "/C=IN/ST=State/L=City/O=Organization/OU=IT Department/CN=bca.local"
sudo openssl x509 -in /etc/ssl/private/bca.csr -out /etc/ssl/certs/bca.crt -req -signkey /etc/ssl/private/bca.key -days 2000

# Create Apache VirtualHost Configuration for HTTPS
sudo bash -c 'cat > /etc/apache2/sites-available/bca-ssl.conf <<EOF
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    ServerName bca.local
    DocumentRoot /var/www/html/wordpress

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/bca.crt
    SSLCertificateKeyFile /etc/ssl/private/bca.key

    <Directory /var/www/html/wordpress>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF'

# Create Apache VirtualHost Configuration for HTTP to HTTPS Redirection
sudo bash -c 'cat > /etc/apache2/sites-available/bca.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName bca.local
    Redirect permanent / https://bca.local/
</VirtualHost>
EOF'

# Enable SSL module and VirtualHost configurations
sudo a2enmod ssl rewrite
sudo a2ensite bca-ssl.conf bca.conf

# Restart Apache to apply changes
sudo systemctl restart apache2

# Notify the user
echo "WordPress installation completed. Visit https://bca.local in your browser."

# Reboot the system to apply all changes
echo "Rebooting the system in 10 seconds..."
sleep 10
sudo reboot

