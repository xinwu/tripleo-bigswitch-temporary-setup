#!/bin/bash

set -euxo pipefail

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

sudo -u stack virt-customize -a ../overcloud-full.qcow2 \
    --mkdir /usr/share/openstack-puppet/modules/neutron/manifests/plugins/ml2/bigswitch \
    --upload puppet-neutron/manifests/plugins/ml2/bigswitch.pp:/usr/share/openstack-puppet/modules/neutron/manifests/plugins/ml2/bigswitch.pp \
    --upload puppet-neutron/manifests/plugins/ml2/bigswitch/restproxy.pp:/usr/share/openstack-puppet/modules/neutron/manifests/plugins/ml2/bigswitch/restproxy.pp
