#!/usr/bin/env bash
STACKNAME='Baukis-devops-production-VPC'
TEMPLATE='vpc/vpc-2az-2subnet-pub.template'
TAGKEY='Name'
TAGVALUE='production'

aws cloudformation create-stack --stack-name ${STACKNAME} \
                                --template-body file://${TEMPLATE} \
                                --tags Key=${TAGKEY},Value=${TAGVALUE}