#!/bin/bash 
source $(cd $(dirname $0); pwd -L)/common.sh

 display_usage() { 
	echo "
Usage:
    $(basename "$0") <parameter_file> [--help or -h]

Description:
    Creates AWS pre-requisites

Arguments:
    parameter_file: location of your emr parameter json file"

}




# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $1 == "--help") ||  $1 == "-h" ]] 
then 
    display_usage
    exit 0
fi 


# Check the numbers of arguments
if [  $# -lt 1 ] 
then 
    echo "Not enough arguments!"  >&2
    display_usage
    exit 1
fi 

if [  $# -gt 1 ] 
then 
    echo "Too many arguments!"  >&2
    display_usage
    exit 1
fi 

# Parsing arguments
parse_parameters ${1}


# AWS pre-requisites (per env)
echo "⏱  $(date +%H%Mhrs)"
echo ""
echo "Deleting AWS pre-requisites for $prefix:"
underline="▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
for ((i=1;i<=$prefix_length;i++))
do
    underline=${underline}"▔"
done
echo ${underline}

# 1. Network

# 2. Deleting Roles
result=$($base_dir/aws_delete_roles.sh $prefix $sleep_duration 2>&1 > /dev/null)
handle_exception $? $prefix "roles creation" "$result"
echo "${CHECK_MARK}  $prefix: roles deleted"

# 3. Bucket
result=$($base_dir/aws_delete_bucket.sh $prefix 2>&1 > /dev/null)
handle_exception $? $prefix "bucket deletion" "$result"

bucket=${prefix}-emr-bucket
echo "${CHECK_MARK}  $prefix: bucket $bucket deleted"





echo ""
echo "AWS pre-requisites deleted for $prefix!"
echo ""