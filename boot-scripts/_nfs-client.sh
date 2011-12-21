# NFS client setup
# Include this in your boot script to have your instance configured to connect to 
# and nfs server for it's application data

# Install the packages we need
install_pkg portmap nfs-common

# setup a log, temp and site directory in ephemeral storage
mkdir /mnt/localapps
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

# Configure NFS and setup a mount point for media
mkdir /mnt/apps
echo 'nfs:/mnt/apps	/mnt/apps	nfs	defaults,nobootwait,nfsvers=3' >> /etc/fstab
sed s/^NEED_IDMAPD=$/NEED_IDMAPD=yes/g /etc/default/nfs-common >/etc/default/nfs-common.new
mv /etc/default/nfs-common.new /etc/default/nfs-common
service idmapd start
mount /mnt/apps
