{%extends 'wordpress/base.sh' %}

{% block install %}

# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential

{% include "_syslog-client.sh" %}

{% include "_nfs-client.sh" %}

{% include "_varnish.sh" %}

{% endblock %}
