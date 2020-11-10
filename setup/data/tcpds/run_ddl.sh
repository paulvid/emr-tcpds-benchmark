BEELINE="hive"
DT=$(date +%Y-%m-%d.%s)

mkdir -p ./tcpds/ddl_results/$DT

$BEELINE -f ./tcpds/ddl/dims.sql 2>&1 | tee ./tcpds/ddl_results/$DT/dims.txt
$BEELINE -f ./tcpds/ddl/facts.sql 2>&1 | tee ./tcpds/ddl_results/$DT/facts.txt
# $BEELINE -f ./tcpds/ddl/add_constraints.sql 2>&1 | tee ./tcpds/ddl_results/$DT/constraints.txt