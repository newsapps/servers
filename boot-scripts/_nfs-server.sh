# NFS server setup
# Setup apps directories, export them through NFS

# Install packages
install_pkg portmap nfs-common nfs-kernel-server \
            linux-image-virtual

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

# setup our media share. You probably want to create, attach and mount an ebs here.
mkdir /mnt/media

# Add our share to NFS exports
echo '/mnt/media 10.0.0.0/8(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports

# Fix for NFSv4 that's sometimes needed for proper permissions
sed s/^NEED_IDMAPD=$/NEED_IDMAPD=yes/g /etc/default/nfs-common >/etc/default/nfs-common.new
mv /etc/default/nfs-common.new /etc/default/nfs-common
service nfs-kernel-server reload

# make sure idmapd starts
service idmapd start

