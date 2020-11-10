#!/bin/bash 
set -o nounset
BASE_DIR=$(cd $(dirname $0); pwd -L)

display_usage() { 
    echo "
Usage:
    $(basename "$0") [--help or -h] <prefix> <sleep_duration>

Description:
    Creates minimal set of roles for EMR setup

Arguments:
    prefix:         prefix for your roles
    sleep_duration: duration of pause between role creation
    --help or -h:   displays this help"

}

# check whether user had supplied -h or --help . If yes display usage 
if [[ ( ${1:-x} == "--help") ||  ${1:-x} == "-h" ]] 
then 
    display_usage
    exit 0
fi 


# Check the numbers of arguments
if [  $# -lt 2 ] 
then 
    echo "Not enough arguments!"  >&2
    display_usage
    exit 1
fi 

if [  $# -gt 2 ] 
then 
    echo "Too many arguments!"  >&2
    display_usage
    exit 1
fi 


prefix=$1
sleep_duration=$2

AWS_ACCOUNT_ID=$(aws sts get-caller-identity  | jq .Account -r)

aws iam create-role  --role-name ${prefix}-emr-ec2-default-role   --assume-role-policy-document file://${BASE_DIR}/emr_ec2_assume_role_policy.json
sleep $sleep_duration 

aws iam create-instance-profile  --instance-profile-name  ${prefix}-emr-ec2-default-role
sleep $sleep_duration 

aws iam add-role-to-instance-profile  --instance-profile-name  ${prefix}-emr-ec2-default-role --role-name  ${prefix}-emr-ec2-default-role
sleep $sleep_duration 

aws iam attach-role-policy  --role-name ${prefix}-emr-ec2-default-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role
sleep $sleep_duration 

aws iam create-role  --role-name ${prefix}-emr-default-role   --assume-role-policy-document file://${BASE_DIR}/emr_default_assume_role_policy.json
sleep $sleep_duration 

aws iam attach-role-policy  --role-name ${prefix}-emr-default-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole
sleep $sleep_duration 


echo "Roles Created!"
