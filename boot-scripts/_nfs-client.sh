# NFS client setup
# Include this in your boot script to have your instance configured to connect to 
# and nfs server for it's application data

# Install the packages we need
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        portmap nfs-common

# Configure NFS and setup a mount point for application configuration, code and data
mkdir /mnt/apps
echo 'nfs:/mnt/apps	/mnt/apps	nfs	defaults' >> /etc/fstab
sed s/^NEED_IDMAPD=$/NEED_IDMAPD=yes/g /etc/default/nfs-common >/etc/default/nfs-common.new
mv /etc/default/nfs-common.new /etc/default/nfs-common
service idmapd start
mount /mnt/apps

ln -s /mnt/apps/sites /home/$USERNAME/sites
ln -s /mnt/apps/apache /home/$USERNAME/apache
ln -s /mnt/apps/varnish /home/$USERNAME/varnish
