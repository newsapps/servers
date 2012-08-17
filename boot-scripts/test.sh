#!/bin/bash -x
export USERNAME=newsapps
export PASS=PYThing625
usermod -l $USERNAME -d /home/$USERNAME -m ubuntu
groupmod -n $USERNAME ubuntu
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/90-cloudimg-$USERNAME
chmod 0440 /etc/sudoers.d/90-cloudimg-$USERNAME

rm /etc/sudoers.d/90-cloudimg-ubuntu
