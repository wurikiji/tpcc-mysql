export LD_LIBRARY_PATH=/home/ogh/work/git/mysql-server/build-install/installs/lib
DBNAME=tpcc1000
WH=25
HOST=127.0.0.1
STEP=25

./tpcc_load -h $HOST -P 3307 -d $DBNAME -u root -p "rlghks12" -w $WH -l 1 -m 1 -n $WH >> 1.out &

x=1

while [ $x -le $WH ]
do
 echo $x $(( $x + $STEP - 1 ))
./tpcc_load -h $HOST -P 3307 -d $DBNAME -u root -p "rlghks12" -w $WH -l 2 -m $x -n $(( $x + $STEP - 1 ))  >> 2_$x.out &
./tpcc_load -h $HOST -P 3307 -d $DBNAME -u root -p "rlghks12" -w $WH -l 3 -m $x -n $(( $x + $STEP - 1 ))  >> 3_$x.out &
./tpcc_load -h $HOST -P 3307 -d $DBNAME -u root -p "rlghks12" -w $WH -l 4 -m $x -n $(( $x + $STEP - 1 ))  >> 4_$x.out &
 x=$(( $x + $STEP ))
done
for job in `jobs -p`
do
	echo $job
	wait $job
done
