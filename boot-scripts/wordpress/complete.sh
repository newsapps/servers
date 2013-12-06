{% extends 'wordpress/base.sh' %}

{% block install %}

# Install php-fpm config
install_file wordpress /etc/php5/fpm/pool.d/www.conf

# install nginx config
install_file wordpress /etc/nginx/nginx.conf

# install stuff
install_pkg php5 php5-mysql php5-gd php5-fpm php-pear php-apc php5-curl php5-memcache nginx-full

# reload it!
service php5-fpm restart
service nginx restart

# setup a log, temp and site directory in ephemeral storage
mkdir /mnt/localapps
ln -s /mnt/localapps /mnt/apps
mkdir /mnt/localapps/logs
mkdir /mnt/localapps/sites
mkdir /mnt/localapps/nginx
mkdir /mnt/localapps/apache
mkdir /mnt/localapps/varnish
mkdir /mnt/localapps/media
mkdir /mnt/tmp
chmod -R ugo+rwx /mnt/tmp /mnt/localapps

# shortcuts in the home directory
ln -s /mnt/localapps/logs /home/$USERNAME/logs
ln -s /mnt/localapps/sites /home/$USERNAME/sites
ln -s /mnt/localapps/apache /home/$USERNAME/apache
ln -s /mnt/localapps/varnish /home/$USERNAME/varnish
ln -s /mnt/localapps/nginx /home/$USERNAME/nginx
ln -s /mnt/localapps/media /home/$USERNAME/media

{% endblock %}
