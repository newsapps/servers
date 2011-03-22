# NFS server setup
# Setup apps directories, export them through NFS
# This stuff needs a new kernel, be sure to reboot!

# Install packages
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        portmap nfs-common nfs-kernel-server \
        linux-image-virtual

# setup the directories for sharing, set permissions to the
# wordpress user and apache group, make the permissions sticky
mkdir /mnt/apps /mnt/apps/sites /mnt/apps/apache /mnt/apps/varnish
chown $USERNAME:www-data /mnt/apps/sites /mnt/apps/apache /mnt/apps/varnish
chmod ug+sw /mnt/apps/sites /mnt/apps/apache /mnt/apps/varnish

# Add our share to NFS exports
echo '/mnt/apps 10.0.0.0/8(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports

# Fix for NFSv4 that's sometimes needed for proper permissions
sed s/^NEED_IDMAPD=$/NEED_IDMAPD=yes/g /etc/default/nfs-common >/etc/default/nfs-common.new
mv /etc/default/nfs-common.new /etc/default/nfs-common
#service nfs-kernel-server reload

ln -s /mnt/apps/sites /home/$USERNAME/sites
ln -s /mnt/apps/apache /home/$USERNAME/apache
ln -s /mnt/apps/varnish /home/$USERNAME/varnish

