#####################
# Arguments:        #
#   $1 -> retcode   #
#   $2 -> prefix    #
#   $2 -> operation #
#   $3 -> error     #
#####################
handle_exception()
{
    if [ "$1" -ne "0" ]; then
        prefix=$2
        operation=$3
        error=$4
        echo ""
        echo "🚫  $prefix: error during operation: $operation"
        echo ""
        echo "Error details:"
        echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
        echo "$error"
        echo ""
        
        exit $1
    fi
}

#########################
# Arguments:            #
#   $1 -> file to parse #
#########################
parse_parameters() 
{
    # Parsing arguments

    param_file=${1}

    base_dir=$(cd $(dirname $0); pwd -L)
    prefix=$(cat ${param_file} | jq -r .prefix)
    region=$(cat ${param_file} | jq -r .region)
    key=$(cat ${param_file} | jq -r .key)
    emr_version=$(cat ${param_file} | jq -r .emr_version)
    worker_type=$(cat ${param_file} | jq -r .worker_type)
    worker_count=$(cat ${param_file} | jq -r .worker_count)
    aws_profile=$(cat ${param_file} | jq -r .aws_profile)
    use_external_db=$(cat ${param_file} | jq -r .use_external_db)
    delete_external_db=$(cat ${param_file} | jq -r .delete_external_db)

    if [[ $aws_profile == "null" ]]
    then
        aws_profile="default"
    fi
    
    export AWS_PROFILE=${aws_profile}
    prefix_length=$(echo ${prefix} | awk '{print length}')

    sleep_duration=5
    CHECK_MARK="✅"
    ALREADY_DONE="❎"
}


run_pre_checks() 
{
    result=$(aws iam get-user  2>&1 > /dev/null)
    handle_exception $? $prefix "aws cli verification" "$result"

}