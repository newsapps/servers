
# install postgres
install_pkg postgresql-8.4-postgis pgpool libpq-dev

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

# install configs
install_file newsapps /etc/pgpool.conf
install_file newsapps /etc/postgresql/8.4/main/pg_hba.conf
install_file newsapps /etc/postgresql/8.4/main/postgresql.conf

# reload everything
service postgresql restart
service pgpool restart
