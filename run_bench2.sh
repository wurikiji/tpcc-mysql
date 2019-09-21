name=$1

if [ -z "$name" ]
then
	echo "Usage: $0 [file name]";
	exit 1;
fi

mysqladmin -P3307 -S/tmp/my2.sock -uroot -prlghks12 create tpcc1000
`which mysql` -P3307 -S/tmp/my2.sock -uroot -prlghks12 tpcc1000 < create_table.sql
./load2.sh
`which mysql` -P3307 -S/tmp/my2.sock -uroot -prlghks12 tpcc1000 < add_fkey_idx.sql 
./run2.sh | tee ${name}.tpcc

