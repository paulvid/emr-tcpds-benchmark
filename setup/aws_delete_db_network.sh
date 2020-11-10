
#!/bin/bash 


 display_usage() { 
	echo "
Usage:
    $(basename "$0") <network_file> [--help or -h]

Description:
    Deletes the db network created for RDS

Arguments:
    network_file:   prefix to use for objects created in AWS
    --help or -h:   displays this help"

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
    echo "Not enough arguments!"
    display_usage
    exit 1
fi 

if [  $# -gt 1 ] 
then 
    echo "Too many arguments!"
    display_usage
    exit 1
fi 

network_file=$1

igw_id=$(cat $network_file | jq -r .InternetGatewayId)
vpc_id=$(cat $network_file | jq -r .VpcId)
subnet_id1a=$(cat $network_file | jq -r .Subnets[0])
subnet_id1b=$(cat $network_file | jq -r .Subnets[1])
subnet_id1c=$(cat $network_file | jq -r .Subnets[2])
db_subnet_group=$(cat $network_file | jq -r .DBSubnetGroupName)
sg_id=$(cat $network_file | jq -r .GroupId)
route_id=$(cat $network_file | jq -r .RouteTableId)



aws ec2 delete-security-group --group-id $sg_id
aws rds delete-db-subnet-group --db-subnet-group-name $db_subnet_group
aws ec2 delete-subnet --subnet-id $subnet_id1a
aws ec2 delete-subnet --subnet-id $subnet_id1b
aws ec2 delete-subnet --subnet-id $subnet_id1c
aws ec2 detach-internet-gateway --internet-gateway-id $igw_id --vpc-id $vpc_id
aws ec2 delete-route-table --route-table-id $route_id
aws ec2 delete-vpc --vpc-id $vpc_id
aws ec2 delete-internet-gateway --internet-gateway-id $igw_id


