#!/bin/sh

#!set -x
#!read trap debug

if [ $# -eq 0 ]
then
        echo " Usage: `basename $0` Project#"
        exit 2
fi

#variables

id=$1
tenant=Tenant
project=Project
user=user
ks_dir=/root/keystonerc

network_router(){
#neutron floatingip-delete <floatingip-id>
ns=`neutron router-list| grep $id | awk '{print $2}'`
ns=qrouter-$ns
neutron router-gateway-clear router$id
neutron router-interface-delete router$id PrivateSubnet_$id
neutron router-delete router$id
ip netns delete $ns
}

network_net(){
neutron net-delete PrivateNet_$id
}

network_subnet(){
neutron subnet-delete PrivateSubnet_$id
}

user(){
keystone user-delete $user$id 
}

tenant(){
keystone tenant-delete $project$id
}

role(){
keystone role-delete admin$id
}

secgroup(){
nova secgroup-delete SecGrp$id
}

keystonerc(){
echo " INFO: Deleting $ks_dir/keystonerc_$user$id"
rm -rf $ks_dir/keystonerc_$user$id
}

pem_file(){
echo " INFO: Deleting $ks_dir/$user$id.pem "
rm -rf $ks_dir/key$id.pem
}

keypair(){
echo " INFO: Deleting keypair key$id"
nova keypair-delete key$id
}

network_router
network_net
network_subnet
secgroup
keypair
user
role
tenant
keystonerc
pem_file
