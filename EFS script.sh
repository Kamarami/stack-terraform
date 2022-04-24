#!/bin/bash
sudo exec > >(tee /var/log/user-data.log|logger -t user-date -s 2>/dev/console) 2>&1

#Configure mount point and install MariaDB
sudo su -
yum update -y
yum install -y nfs-utils
FILE_SYSTEM_ID=fs-86973c32
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AVAILABILITY_ZONE:0:-1}
MOUNT_POINT=/var/www/html
mkdir -p ${MOUNT_POINT}
chown ec2-user:ec2-user ${MOUNT_POINT}
echo ${FILE_SYSTEM_ID}.efs.${REGION}.amazonaws.com:/ ${MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0 >> /etc/fstab
mount -a -t nfs4

chmod -R 755 /var/www/html
sudo su - ec2-user
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chown 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl start mariadb

###INSTALL AND START LINUX, APACHE, MYSQL, AND PHP DRIVERS###
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cat /etc/system-release 
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl start mariadb
sudo mysql_secure_installation
sudo systemctl enable mariadb
sudo yum install php-mbstring -y
sudo yum install php-xml
sudo systemctl restart httpd
sudo systemctl restart php-fpm

###INSTALL PHPMYADMIN###
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
sudo systemctl start mariadb
sudo chkconfig httpd on
sudo chkconfig mariadb on
sudo systemctl status httpd
sudo systemctl status mariadb

###INSTALL WORDPRESS###
wget https://wordpress.org/latest.tar.gz #These lines need to go away
tar -xzf latest.tar.gz                  ##bootstrap will now copy this from s3 bucket
cp wordpress/wp-config-sample.php wordpress/wp-config.php
mkdir /var/www/html/
cp -r wordpress/* /var/www/html/

###CREATE WORDPRESS DATABASE AND USER###
export DEBIAN_FRONTEND="noninteractive"
sudo mysql -u root <<EOF
FLUSH PRIVILEGES;
drop user 'wordpress-user'@'localhost';
CREATE USER 'wordpress-user'@'localhost' IDENTIFIED BY 'stackinc';
CREATE DATABASE \`wordpress-db\`;
USE \'wordpress-db\';
GRANT ALL PRIVILEGES ON \'wordpress-db\`.* TO 'wordpress-user'@'localhost';
FLUSH PRIVILEGES;
EOF
sudo sed -i 's/database_name_here/wordpress-db/' /var/www/html/wp-config.php
sudo sed -i 's/username_here/wordpress-user/' /var/www/html/wp-config.php
sudo sed -i 's/password_here/password/' /var/www/html/wp-config.php
sudo sed -i 's/localhost/(RDS endpoint)/' /var/www/html/wp-config.php

###ALLOW WORDPRESS TO USE PERMALINKS###
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf

###CHANGE OWNERSHIPS FOR APACHE & RESTART SERVICES###
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl restart httpd
sudo systemctl enable httpd && sudo systemctl enable mariadb
sudo systemctl status mariadb
sudo systemctl start mariadb
sudo systemctl status httpd
sudo systemctl start httpd
curl http://169.254.169.254/latest/meta-data/public-ipv4

aws s3 cp s3://mystacks3website/index.html /var/www/html
aws s3 cp s3://mystacks3website/Stack_IT_Logo.png /var/www/html
