PORT=$1
RUNTIME=$2

if [ -z "$PORT" ]
then
	echo "USAGE: $0 [PORT_NUM]"
	exit 1
fi

if [ -z "$RUNTIME" ]
then
	echo "SET runtime to 30";
	RUNTIME=30
fi

LD_LIBRARY_PATH=/home/ogh/work/git/mysql-server/build-install/installs/lib ./tpcc_start -h127.0.0.1 -P$PORT -dtpcc1000 -uroot -w10 -c32 -r0 -l$RUNTIME -prlghks12 -i5
