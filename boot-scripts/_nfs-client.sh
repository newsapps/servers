# NFS client setup
# Include this in your boot script to have your instance configured to connect to 
# and nfs server for it's application data

# Install the packages we need
install_pkg portmap nfs-common

# setup a log, temp and site directory in ephemeral storage
mkdir /mnt/apps
mkdir /mnt/apps/logs
mkdir /mnt/apps/sites
mkdir /mnt/apps/nginx
mkdir /mnt/apps/apache
mkdir /mnt/apps/varnish
mkdir /mnt/tmp
chmod ugo+rwx -r /mnt/logs /mnt/tmp /mnt/apps

# shortcuts in the home directory
ln -s /mnt/apps/logs /home/$USERNAME/logs
ln -s /mnt/apps/sites /home/$USERNAME/sites
ln -s /mnt/apps/apache /home/$USERNAME/apache
ln -s /mnt/apps/varnish /home/$USERNAME/varnish
ln -s /mnt/apps/nginx /home/$USERNAME/nginx

# Configure NFS and setup a mount point for media
mkdir /mnt/media
echo 'nfs:/mnt/media	/mnt/media	nfs	defaults' >> /etc/fstab
sed s/^NEED_IDMAPD=$/NEED_IDMAPD=yes/g /etc/default/nfs-common >/etc/default/nfs-common.new
mv /etc/default/nfs-common.new /etc/default/nfs-common
service idmapd start
mount /mnt/media
