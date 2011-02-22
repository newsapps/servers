{% extends "newsapps/base.sh" %}

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential libxml2-dev libxslt-dev \
        apache2 apache2-mpm-worker apache2-utils apache2.2-common \
        memcached postfix varnish \
        proj libgeoip1 geoip-database python-gdal \
        python-setuptools python-virtualenv python-pip ruby libruby-extras python-dev \
        libapache2-mod-wsgi virtualenvwrapper\
        postgresql-8.4-postgis pgpool libpq-dev

# create postgres user
sudo -u postgres createuser -s $USERNAME

# POSTGIS setup
# Where the postgis templates should be
POSTGIS_SQL_PATH=/usr/share/postgresql/8.4/contrib/postgis-1.5

# Creating the template spatial database.
sudo -u postgres createdb -E UTF8 template_postgis 

# Adding PLPGSQL language support.
sudo -u postgres createlang -d template_postgis plpgsql 

# Allows non-superusers the ability to create from this template
sudo -u postgres psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis';" 

# Loading the PostGIS SQL routines
sudo -u postgres psql -d template_postgis -f $POSTGIS_SQL_PATH/postgis.sql 

# Enabling users to alter spatial tables.
sudo -u postgres psql -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;" 
sudo -u postgres psql -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

# some apache config
a2dismod autoindex authn_file cgid negotiation
a2enmod rewrite

# apps dirs
sudo -u $USERNAME \
    mkdir /home/$USERNAME/sites \
          /home/$USERNAME/sites/default \
          /home/$USERNAME/sites/virtualenvs \
          /home/$USERNAME/sites/default/defaultproject \
          /home/$USERNAME/sites/conf \
          /home/$USERNAME/sites/apache \
          /home/$USERNAME/logs

# setup virtualenvwrapper
echo "export WORKON_HOME=/home/$USERNAME/sites/virtualenvs" >> /home/$USERNAME/.bashrc

chgrp www-data /home/$USERNAME/logs
chmod g+w /home/$USERNAME/logs

# install custom configs and scripts
cp -Rf $ASSET_DIR/newsapps/app/* /
cp -Rf $ASSET_DIR/newsapps/cron/* /
cp -Rf $ASSET_DIR/newsapps/db/* /
cp -Rf $ASSET_DIR/newsapps/lb/* /

{% endblock %}
