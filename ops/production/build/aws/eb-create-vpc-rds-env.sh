#!/bin/sh
ENVNAME='production-env'
CNAME='production-baukis'
VPCID='vpc-1f133a7a '
ELBSUBNET='subnet-ed20329a'
EC2SUBNET='subnet-ed20329a'
INSTANCE='t2.small'
DBENGINE='mysql'
DBSIZE='5'
DBINSTANCE='db.t2.micro'
DBPASSWORD='password'
DBUSERNAME='app'
DBVERSION='5.6.27'
DBSUBNET1='subnet-ed20329a'
DBSUBNET2='subnet-57ffd70e'
eb create ${ENVNAME} \
                     --cname ${CNAME} \
                     --vpc.id ${VPCID} \
                     --vpc.elbsubnets ${ELBSUBNET} \
                     --vpc.ec2subnets ${EC2SUBNET} \
                     --vpc.publicip \
                     --vpc.elbpublic \
                     --instance_type ${INSTANCE} \
                     --database \
                     --database.engine ${DBENGINE} \
                     --database.size ${DBSIZE} \
                     --database.instance ${DBINSTANCE} \
                     --database.password ${DBPASSWORD} \
                     --database.username ${DBUSERNAME} \
                     --database.version ${DBVERSION} \
                     --vpc.dbsubnets ${DBSUBNET1},${DBSUBNET2} \
