install_pkg libxml2-dev libxslt-dev \
        apache2 apache2-mpm-worker apache2-utils apache2.2-common \
        proj libgeoip1 geoip-database python-gdal \
        python-virtualenv python-pip ruby libruby-extras python-dev \
        libapache2-mod-wsgi virtualenvwrapper

# enable mod_rewrite
a2enmod rewrite

# disable deflate
a2dismod deflate

# Install apache config
install_file /etc/apache2/apache2.conf

# setup virtualenvwrapper
echo "export WORKON_HOME=/home/$USERNAME/sites/virtualenvs" >> /home/$USERNAME/.bashrc

reload apache2
