dev=$1
name=$2
if [ -z "$dev" ] || [ -z "$name" ]
then
	echo "Usage: $0 [device] [test name]"
	exit 1
fi

while true; do sudo smartctl -A $dev >> $name.smartctl; sleep 10; done &

LD_LIBRARY_PATH=/home/ogh/work/git/mysql-server/build-install/installs/lib ./tpcc_start -h127.0.0.1 -P3306 -dtpcc1000 -uroot -w20 -c16 -r0 -l18000 -prlghks12 -i5 > $name.tpcc

sudo killall -9 smartctl
