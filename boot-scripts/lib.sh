# Some useful bash functions

# install_file $from_bundle $file_path
# ex:
#   install_file newsapps /etc/memcached.conf
#
function install_file {
    echo "Installing '$2' from assets"
    cp /home/$USERNAME/cloud-commander/$1$2 $2
    chown root:root $2
    chmod 644 $2
}

# install_pkgs $pkg_name
function install_pkg {
    echo "Installing packages $*"
    DEBIAN_FRONTEND='noninteractive' \
    apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
            $*
}
