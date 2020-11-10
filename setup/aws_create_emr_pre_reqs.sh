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
echo "Creating AWS pre-requisites for $prefix:"
underline="▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
for ((i=1;i<=$prefix_length;i++))
do
    underline=${underline}"▔"
done
echo ${underline}


# 1. Bucket
result=$($base_dir/aws_create_bucket.sh  $prefix $region 2>&1 > /dev/null)
handle_exception $? $prefix "bucket creation" "$result"

bucket=${prefix}-emr-bucket
echo "${CHECK_MARK}  $prefix: bucket $bucket created"

# 2. Creating Roles
result=$($base_dir/aws_create_roles.sh $prefix $sleep_duration 2>&1 > /dev/null)
handle_exception $? $prefix "roles creation" "$result"

echo "${CHECK_MARK}  $prefix: new roles created"

# 3. Creating Network
# result=$(
#     { stdout=$($base_dir/aws-pre-req/aws_create_network.sh $prefix $region ) ; } 2>&1
#     printf "this is the separator"
#     printf "%s\n" "$stdout"
# )
# var_out=${result#*this is the separator}
# var_err=${result%this is the separator*}

# if [ "$var_err" ]
# then
#     handle_exception 1 $prefix "role creation" "$var_err"
# fi

# create_network=$var_out

# echo $var_out > $base_dir/aws-pre-req/${prefix}_aws_network.json

# igw_id=$(echo $create_network | jq -r .InternetGatewayId)
# vpc_id=$(echo $create_network | jq -r .VpcId)
# subnet_id1a=$(echo $create_network | jq -r .Subnets[0])
# subnet_id1b=$(echo $create_network | jq -r .Subnets[1])
# subnet_id1c=$(echo $create_network | jq -r .Subnets[2])
# route_id=$(echo $create_network | jq -r .RouteTableId)
# knox_sg_id=$(echo $create_network | jq -r .KnoxGroupId)
# default_sg_id=$(echo $create_network | jq -r .DefaultGroupId)


# echo "
# aws ec2 delete-security-group  --group-id $knox_sg_id
# aws ec2 delete-security-group  --group-id $default_sg_id
# aws ec2 delete-subnet  --subnet-id $subnet_id1a
# aws ec2 delete-subnet  --subnet-id $subnet_id1b
# aws ec2 delete-subnet  --subnet-id $subnet_id1c
# aws ec2 detach-internet-gateway  --internet-gateway-id $igw_id --vpc-id $vpc_id
# aws ec2 delete-route-table  --route-table-id $route_id
# aws ec2 delete-vpc  --vpc-id $vpc_id
# aws ec2 delete-internet-gateway  --internet-gateway-id $igw_id

# " > $base_dir/aws-pre-req/${prefix}_aws_delete_network.sh
# chmod a+x $base_dir/aws-pre-req/${prefix}_aws_delete_network.sh


# echo "${CHECK_MARK}  $prefix: new network created"


echo ""
echo "AWS pre-requisites created for $prefix!"
echo ""