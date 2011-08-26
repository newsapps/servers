# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        libpcre3-dev libxml2-dev libxslt1-dev libgd2-xpm-dev libgeoip-dev \
        nginx-common

cd /home/$USERNAME

# Grab latest nginx code
curl http://nginx.org/download/nginx-1.0.5.tar.gz | tar zxf -

# Patch nginx for syslog support
git clone https://github.com/yaoweibin/nginx_syslog_patch.git

cd nginx-1.0.5
patch -p1 < /home/$USERNAME/nginx_syslog_patch/new_syslog_0.8.54.patch

# Configure for ubuntu and needed plugins
./configure \
    --prefix=/usr \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-log-path=/var/log/nginx/access.log \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/var/run/nginx.pid \
    --with-debug \
    --with-http_addition_module \
    --with-http_dav_module \
    --with-http_geoip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_sub_module \
    --with-http_xslt_module \
    --with-ipv6 \
    --with-sha1=/usr/include/openssl \
    --with-md5=/usr/include/openssl \
    --add-module=/home/$USERNAME/nginx_syslog_patch

make
make install

# start it at boot
update-rc.d nginx enable 2 3 4 5

# install custom config
install_file newsapps /etc/nginx/nginx.conf

# start it!
service nginx start

cd ~
