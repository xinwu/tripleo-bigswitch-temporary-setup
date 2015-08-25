#!/bin/bash

set -euxo pipefail

if [ $(id -un) != 'root' ]; then
    echo "This needs to be run as root."
    exit 1
fi

mkdir bigswitch-patch || true
cd bigswitch-patch

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd )

if [ ! -e tht-bigswitch.patch ]; then
    # OpenStack gerrit won't allow direct patch download it seems
    git clone https://github.com/openstack/tripleo-heat-templates || true
    pushd tripleo-heat-templates
    git fetch https://review.openstack.org/openstack/tripleo-heat-templates refs/changes/42/213142/2 && git format-patch -1 --stdout FETCH_HEAD > ../tht-bigswitch.patch
    popd
fi

if [ ! -e tht-mechanism-drivers.patch ]; then
    # OpenStack gerrit won't allow direct patch download it seems
    git clone https://github.com/openstack/tripleo-heat-templates || true
    pushd tripleo-heat-templates
    git fetch https://review.openstack.org/openstack/tripleo-heat-templates refs/changes/49/214649/2 && git format-patch -1 --stdout FETCH_HEAD > ../tht-mechanism-drivers.patch
    popd
fi

echo "Patches downloaded, inspect them if you wish, then press enter to continue"
read

pushd /usr/share/openstack-tripleo-heat-templates
patch -p1 < "$DIR/tht-bigswitch.patch"
patch -p1 < "$DIR/tht-mechanism-drivers.patch"
popd
