{% extends 'newsapps/base.sh' %}

{% block install %}
install_pkg libgraphicsmagick++1-dev libboost-python-dev imagemagick enchant \
  graphicsmagick python-pgmagick libtiff-dev liblcms2-dev libwebp-dev \
  python-imaging libboost-python-dev

mkdir /mnt/tmp
chmod ugo+rw /mnt/tmp
{% endblock %}
