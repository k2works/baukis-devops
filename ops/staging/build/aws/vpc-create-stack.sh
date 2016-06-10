#!/usr/bin/env bash
STACKNAME='Baukis-devops-VPC'
TEMPLATE='vpc/vpc-1az-2subnet-pub.template'
TAGKEY='Name'
TAGVALUE='staging'

aws cloudformation create-stack --stack-name ${STACKNAME} \
                                --template-body file://${TEMPLATE} \
                                --tags Key=${TAGKEY},Value=${TAGVALUE}