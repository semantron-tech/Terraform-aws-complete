#!/bin/bash -e
#clear
#echo "============================================"
#echo "WordPress Install Script"
#echo "============================================"
#echo "Database Name: "


# Install Apache
yum -y install httpd

# Start Apache
service httpd start

# Install PHP
yum -y install php php-mysql

# Restart Apache
service httpd restart


# Change directory to web root
cd /var/www/html

dbname = "wordpress"
#echo "Database User: "
dbuser = "wpuser"
#echo "Database Password: "
dbpass = "amroot"

dbhost = "3.81.228.182"



#download wordpress
curl -O https://wordpress.org/wordpress-4.9.6.tar.gz
#unzip wordpress
tar -zxvf wordpress-4.9.6.tar.gz
#change dir to wordpress
cd wordpress
#copy file to parent dir
cp -rf . ..
#move back to parent dir
cd ..
#remove files from wordpress folder
rm -R wordpress
#create wp config
cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php
perl -pi -e "s/localhost/$dbhost/g" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 775 wp-content/uploads
echo "Cleaning..."
#remove zip file
rm wordpress-4.9.6.tar.gz
echo "========================="
echo "Installation is complete."
echo "========================="

