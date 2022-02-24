#!/bin/bash
db_username=${db_username}
db_user_password=${db_user_password}
db_name=${db_name}
db_rds=${db_rds}
efs=${efs}
ip=$(curl http://checkip.amazonaws.com)
url=${url}
#install LAMP Server
yum update -y
yum install -y httpd
yum install -y mysql
yum install -y amazon-efs-utils
pip3 install botocore
#mount efs-disk
mount -t efs $efs:/ /var/www/html
#edit fstab
cat <<EOF >>/etc/fstab
$efs:/   /var/www/html   efs   defaults,_netdev  0  0
EOF
#php install
amazon-linux-extras enable php7.4
yum clean metadata
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel}
#install imagick extension
yum -y install gcc ImageMagick ImageMagick-devel ImageMagick-perl
pecl install imagick
chmod 755 /usr/lib64/php/modules/imagick.so
cat <<EOF >>/etc/php.d/20-imagick.ini

extension=imagick

EOF

systemctl restart php-fpm.service

systemctl start  httpd
# Change OWNER and permission of directory /var/www
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Download wordpress package and extract
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/

# Create wordpress configuration file and update database value
cd /var/www/html
cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/$db_name/g" wp-config.php
sed -i "s/username_here/$db_username/g" wp-config.php
sed -i "s/password_here/$db_user_password/g" wp-config.php
sed -i "s/localhost/$db_rds/g" wp-config.php

cat <<EOF >>/var/www/html/wp-config.php

define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '128M');

EOF

# Change permission of /var/www/html/
chown -R ec2-user:apache /var/www/html
chmod -R 774 /var/www/html

#  enable .htaccess files in Apache config using sed command
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

#Install wp-cli and autoinstall wordpress
cd /var/www/html
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/bin/wp
sudo -u ec2-user wp core install --url=http://"$url" --title='Nikolai Voloshin AWS Homework' --admin_user='admin' --admin_password='$db_user_password' --admin_email='voloshin07@gmail.com'
sudo -u ec2-user wp post create --post_type=post --post_status=publish --post_title="A new test post from ip $ip"

#Make apache and mysql to autostart and restart apache
systemctl enable  httpd.service
systemctl restart httpd.service
