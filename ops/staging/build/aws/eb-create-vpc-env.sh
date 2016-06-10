#!/bin/sh
ENVNAME='staging-env'
CNAME='staging-baukis'
VPCID='vpc-70705915'
ELBSUBNET='subnet-ebb8ab9c'
EC2SUBNET='subnet-ebb8ab9c'
INSTANCE='t2.small'
eb create ${ENVNAME} \
                     --cname ${CNAME} \
                     --vpc.id ${VPCID} \
                     --vpc.elbsubnets ${ELBSUBNET} \
                     --vpc.ec2subnets ${EC2SUBNET} \
                     --vpc.publicip \
                     --vpc.elbpublic \
                     --instance_type ${INSTANCE} \
