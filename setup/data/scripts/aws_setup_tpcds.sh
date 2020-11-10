function display_usage() {
  echo "Usage: $(basename "$0") <public_host> <base_dir> [--help or -h]"
}

if [[ ( $1 == "--help") ||  $1 == "-h" || $# != 2 ]]; then
  display_usage
  exit 0
fi

MASTER_HOST=$1
BASE_DIR=$2

scp -r ${BASE_DIR}/data/tcpds hadoop@${MASTER_HOST}:/home/hadoop/tcpds
ssh hadoop@${MASTER_HOST} chmod a+x /home/hadoop/tcpds/run_ddl.sh
ssh hadoop@${MASTER_HOST} /home/hadoop/tcpds/run_ddl.sh
