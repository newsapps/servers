{% extends 'wordpress/base.sh' %}

{% block install %}

{% include "_nfs-client.sh" %}

{% include "_varnish.sh" %}

{% endblock %}
