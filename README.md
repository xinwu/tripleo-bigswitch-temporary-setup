Contains 2 scripts, one for patching the tripleo-heat-templates to carry the
configuration required by the bigswitch neutron plugin and another for patching
the overcloud-full image to install the biswitch rpms and also patch
puppet-neutron with the bigswitch specific manifests.

For reference, the three upstream reviews that are being patched
(2 in t-h-t and one in puppet-neutron) are:

puppet-neutron: https://review.openstack.org/#/c/214686 Configure Big Switch ML2 plugin

t-h-t: https://review.openstack.org/#/c/213142/ Big Switch Neutron ML2 plugin integration

t-h-t: https://review.openstack.org/#/c/214649 Consume the NeutronMechanismDrivers from the hiera data


Patch the tripleo heat templates:
---------------------------------

It is a good idea to backup your existing tripleo heat templates before
starting this:

    sudo su
    cd /usr/share/openstack-tripleo-heat-templates
    mkdir BACKUP
    cp -r ./* ./BACKUP/
    exit  # drop out of root shell before continuing.

Now you can clone this repo, and run the bigswitch-patch-tht.sh script:

    cd /home/stack
    git clone https://github.com/jistr/tripleo-bigswitch-temporary-setup.git
    cd tripleo-bigswitch-temporary-setup
    sudo chmod 766  bigswitch-patch-tht.sh
    sudo ./bigswitch-patch-tht.sh

You will finally be prompted to review the patches before they are applied.
They are placed in ./tripleo-bigswitch-temporary-setup/bigswitch-patch for
review.

Patch the overcloud-full image:
-------------------------------

It is a good idea to backup the existing overcloud-full.qcow2 image before
starting this:

    cp overcloud-full.qcow2 overcloud-full.qcow2BACKUP

Now you can run the bigswitch-patch-image.sh script:

    chmod 766  bigswitch-patch-image.sh
    sudo ./bigswitch-patch-image.sh

You can specify the location to the overcloud-full.qcow2 image if it is not
at /home/stack/overcloud-full.qcow2:

    sudo ./bigswitch-patch-image.sh /home/path/overcloud-full.qcow2

The puppet-neutron changes are checked out in
./tripleo-bigswitch-temporary-setup/bigswitch-patch for your review before
irt-customize is invoked.

The bigswitch rpms are downloaded to the bigswitch-patch directory and
userd to patch the image. You will see the output from virt-customize like


    [   0.0] Examining the guest ...
    [   3.0] Setting a random seed
    [   3.0] Uploading: python-networking-bigswitch-2015.1.37-1.el7.centos.noarch.rpm to /root/python-networking-bigswitch-2015.1.37-1.el7.centos.noarch.rpm
    [   3.0] Uploading: openstack-neutron-bigswitch-lldp-2015.1.37-1.el7.centos.noarch.rpm to /root/openstack-neutron-bigswitch-lldp-2015.1.37-1.el7.centos.noarch.rpm

