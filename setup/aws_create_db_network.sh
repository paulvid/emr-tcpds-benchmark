#!/bin/bash 


 display_usage() { 
	echo "
Usage:
    $(basename "$0") <prefix> <region> [--help or -h]

Description:
    Creates a DB subnet and a DB security group for RDS
    Requires jq

Arguments:
    prefix:          prefix to use for objects created in AWS
    region:         AWS region to create RDS db e.g. us-east-2
    --help or -h:   displays this help"

}

# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $1 == "--help") ||  $1 == "-h" ]] 
then 
    display_usage
    exit 0
fi 


# Check the numbers of arguments
if [  $# -lt 2 ] 
then 
    echo "Not enough arguments!"
    display_usage
    exit 1
fi 

if [  $# -gt 2 ] 
then 
    echo "Too many arguments!"
    display_usage
    exit 1
fi 

export prefix=$1
export region=$2

igw_id=$(aws ec2 create-internet-gateway | jq -r .InternetGateway.InternetGatewayId)

vpc_id=$(aws ec2 create-vpc --cidr 10.0.0.0/16 | jq -r .Vpc.VpcId)

aws ec2 attach-internet-gateway --internet-gateway-id $igw_id --vpc-id $vpc_id
aws ec2 modify-vpc-attribute --enable-dns-support "{\"Value\":true}" --vpc-id $vpc_id
aws ec2 modify-vpc-attribute --enable-dns-hostnames "{\"Value\":true}" --vpc-id $vpc_id

route_id=$(aws ec2 create-route-table --vpc-id $vpc_id | jq -r .RouteTable.RouteTableId)

aws ec2 create-route --route-table-id $route_id --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id > /dev/null 2>&1

subnet_id1a=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.0.0/19 --availability-zone ${region}a | jq -r .Subnet.SubnetId)
subnet_id1b=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.160.0/19 --availability-zone ${region}b | jq -r .Subnet.SubnetId)
subnet_id1c=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.64.0/19 --availability-zone ${region}c | jq -r .Subnet.SubnetId)


aws ec2 associate-route-table  --subnet-id $subnet_id1a --route-table-id $route_id > /dev/null 2>&1
aws ec2 associate-route-table  --subnet-id $subnet_id1b --route-table-id $route_id > /dev/null 2>&1
aws ec2 associate-route-table  --subnet-id $subnet_id1c --route-table-id $route_id > /dev/null 2>&1

db_subnet_group=$(aws rds create-db-subnet-group --db-subnet-group-name "${prefix}-cdp-workshop-db-subnet-gp" --db-subnet-group-description "CDP workshop DB subnet group" --subnet-ids $subnet_id1a $subnet_id1b $subnet_id1c | jq -r .DBSubnetGroup.DBSubnetGroupName)



#db_sg=$(aws rds create-db-security-group --db-security-group-name "pvidal-cdp-workshop-db-sg" --db-security-group-description "CDP workshop DB security group" | jq -r .DBSecurityGroup.DBSecurityGroupName)

sg_id=$(aws ec2 create-security-group --description "CDP workshop RDS security group" --group-name "${prefix}-sg-cdp-workshop" --vpc-id $vpc_id | jq -r .GroupId)

#my_ip=$(curl -s ifconfig.me)

#aws2 ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 0-65535 --cidr $my_ip/32 >> /dev/null 2>&1
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 3306 --cidr 0.0.0.0/0 

echo "{\"InternetGatewayId\": \"$igw_id\", \"VpcId\": \"$vpc_id\", \"Subnets\": [\"$subnet_id1a\", \"$subnet_id1b\", \"$subnet_id1c\"], \"DBSubnetGroupName\": \"$db_subnet_group\", \"GroupId\": \"$sg_id\", \"RouteTableId\": \"$route_id\" }"

# HOW TO DELETE

#aws rds delete-db-security-group --db-security-group-name $db_sg

# echo "
# aws ec2 delete-security-group --group-id $sg_id
# aws rds delete-db-subnet-group --db-subnet-group-name $db_subnet_group
# aws ec2 delete-subnet --subnet-id $subnet_id1a
# aws ec2 delete-subnet --subnet-id $subnet_id1b
# aws ec2 delete-subnet --subnet-id $subnet_id1c
# aws ec2 detach-internet-gateway --internet-gateway-id $igw_id --vpc-id $vpc_id
# aws ec2 delete-route-table --route-table-id $route_id
# aws ec2 delete-vpc --vpc-id $vpc_id
# aws ec2 delete-internet-gateway --internet-gateway-id $igw_id
# "