#!/bin/bash 


 display_usage() { 
	echo "
Usage:
    $(basename "$0") <prefix> <sg_id> <subnet_gp> [--help or -h]

Description:
    Creates an Oracle RDS instance based on previously created security groups and subnets

Arguments:
    prefix:         prefix to use for objects created in AWS
    sg_id:          IF of your previously created vpc security group
    subnet_gp:      Name of your previously created db subnet
    --help or -h:   displays this help"

}

# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $1 == "--help") ||  $1 == "-h" ]] 
then 
    display_usage
    exit 0
fi 


# Check the numbers of arguments
if [  $# -lt 3 ] 
then 
    echo "Not enough arguments!"
    display_usage
    exit 1
fi 

if [  $# -gt 3 ] 
then 
    echo "Too many arguments!"
    display_usage
    exit 1
fi 

prefix=$1
sg_id=$2
subnet_gp=$3

aws rds create-db-instance --engine mariadb \
        --db-instance-identifier ${prefix}-emr-tpcds \
        --allocated-storage 100 \
        --db-instance-class db.t3.large  \
        --vpc-security-group-ids ${sg_id} \
        --db-subnet-group ${subnet_gp} \
        --publicly-accessible \
        --master-username admin \
        --master-user-password emrtpcds \
        --backup-retention-period 3

# HOW TO DELETE
# aws rds delete-db-instance --db-instance-identifier pvidal-cdp-workshop-orcl-rds --skip-final-snapshot



