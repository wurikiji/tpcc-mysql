
mysqladmin -P3306 -S/tmp/my1.sock -uroot -prlghks12 create tpcc1000
`which mysql` -P3306 -S/tmp/my1.sock -uroot -prlghks12 tpcc1000 < create_table.sql
./load.sh 3306
`which mysql` -P3306 -S/tmp/my1.sock -uroot -prlghks12 tpcc1000 < add_fkey_idx.sql 

killall -9 iostat
