# Use PPA for nginx
add-apt-repository ppa:nginx/stable

apt-get update

# install some basic stuff
install_pkg libpcre3-dev libxml2-dev libxslt1-dev libgd2-xpm-dev libgeoip-dev \
        nginx

# install custom config
install_file wordpress /etc/nginx/nginx.conf

# reload it!
service nginx reload
