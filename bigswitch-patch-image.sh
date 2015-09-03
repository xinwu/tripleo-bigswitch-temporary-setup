#!/bin/bash

set -euxo pipefail

IMAGE_PATH=${1:-"/home/stack/images/overcloud-full.qcow2"}

if [ $(id -un) != 'root' ]; then
    echo "This needs to be run as root."
    exit 1
fi

mkdir bigswitch-patch || true
cd bigswitch-patch

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd )

if [ ! -e puppet-neutron ]; then
    git clone https://github.com/openstack/puppet-neutron || true
    pushd puppet-neutron
    git fetch https://review.openstack.org/openstack/puppet-neutron refs/changes/86/214686/4 && git checkout FETCH_HEAD
    popd
fi

echo "puppet-neutron checked out, inspect it if you wish, then press enter to continue"
read

rpm -q libguestfs-tools || yum -y install libguestfs-tools

sudo -u stack virt-customize -a $IMAGE_PATH \
    --mkdir /usr/share/openstack-puppet/modules/neutron/manifests/plugins/ml2/bigswitch \
    --upload puppet-neutron/manifests/plugins/ml2/bigswitch.pp:/usr/share/openstack-puppet/modules/neutron/manifests/plugins/ml2/bigswitch.pp \
    --upload puppet-neutron/manifests/plugins/ml2/bigswitch/restproxy.pp:/usr/share/openstack-puppet/modules/neutron/manifests/plugins/ml2/bigswitch/restproxy.pp

# lets also add the package installs here
# get the rpms:
if [ ! -e python-networking-bigswitch-2015.1.37-1.fc24.noarch.rpm ]; then
    wget --no-check-certificate https://kojipkgs.fedoraproject.org//packages/python-networking-bigswitch/2015.1.37/1.fc24/noarch/python-networking-bigswitch-2015.1.37-1.fc24.noarch.rpm -O python-networking-bigswitch-2015.1.37-1.fc24.noarch.rpm
fi

if [ ! -e openstack-neutron-bigswitch-lldp-2015.1.37-1.fc24.noarch.rpm ]; then
    wget https://kojipkgs.fedoraproject.org//packages/python-networking-bigswitch/2015.1.37/1.fc24/noarch/openstack-neutron-bigswitch-lldp-2015.1.37-1.fc24.noarch.rpm -O openstack-neutron-bigswitch-lldp-2015.1.37-1.fc24.noarch.rpm
fi

# virt-customize for package install:
sudo -u stack virt-customize -a $IMAGE_PATH \
    --upload python-networking-bigswitch-2015.1.37-1.fc24.noarch.rpm:/root/python-networking-bigswitch-2015.1.37-1.fc24.noarch.rpm  \
    --upload openstack-neutron-bigswitch-lldp-2015.1.37-1.fc24.noarch.rpm:/root/openstack-neutron-bigswitch-lldp-2015.1.37-1.fc24.noarch.rpm  \
    --firstboot-command "rpm -ivh /root/python-networking-bigswitch-2015.1.37-1.fc24.noarch.rpm" \
    --firstboot-command "rpm -ivh /root/openstack-neutron-bigswitch-lldp-2015.1.37-1.fc24.noarch.rpm" \
    --firstboot-command "systemctl enable neutron-bsn-lldp.service" \
    --firstboot-command "service neutron-bsn-lldp start"
