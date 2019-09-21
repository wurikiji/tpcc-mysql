name=$1

if [ -z "$name" ]
then
	echo "Usage: $0 [file name]";
	exit 1;
fi

mysqladmin -P3306 -S/tmp/my1.sock -uroot -prlghks12 create tpcc1000
`which mysql` -P3306 -S/tmp/my1.sock -uroot -prlghks12 tpcc1000 < create_table.sql
./load.sh 3306
`which mysql` -P3306 -S/tmp/my1.sock -uroot -prlghks12 tpcc1000 < add_fkey_idx.sql 
# iostat -xm 5 > $name.iostat &
# ./run.sh | tee $name.tpcc

killall -9 iostat
