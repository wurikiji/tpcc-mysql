#!/bin/bash
name=$1

if [ -z "$name" ]
then
	echo "Usage: $0 [file name]";
	exit 1;
fi

preconditioning() {
 dd if=/dev/zero of=/home/ogh/nvme/dummy bs=16k # count=2921440
 fio --name=job-dummy \
 	--bs=16KB --rw=randwrite --ioengine=libaio -iodepth=32 \
	--direct=1 --filename=/home/ogh/nvme/dummy
 rm -rf /home/ogh/nvme/dummy
}

loader() {
	i=$1
	PORT=$((3305 + i))
	echo PORT: $PORT
	mysqladmin -P$PORT -S/tmp/my$i.sock -uroot -prlghks12 create tpcc1000
	`which mysql` -P$PORT -S/tmp/my$i.sock -uroot -prlghks12 tpcc1000 < create_table.sql
	./load.sh $PORT
	`which mysql` -P$PORT -S/tmp/my$i.sock -uroot -prlghks12 tpcc1000 < add_fkey_idx.sql 
}

runner() {
	i=$1
	PORT=$((i  + 3305))
	RUNTIME=$(((i * 5 + 10) * 60))
	SLEEPTIME=$(((i-1) * 5 * 60))
	isfirst=1

	while true
	do
		sleep $SLEEPTIME

		./run2.sh $PORT $RUNTIME >>  ${name}-$i.tpcc
	done
}

if [ ! -z "$2" ]
then
	echo "DO PRECONDITIONING";
	preconditioning
fi

echo "DONE PRECONDITIONING, waiting for users entering... >> "
read enter

for i in 1 2 3 4 
do
	loader $i &
done

for job in `jobs -p`
do
	echo "Wait for loader $job";
	wait $job
done

echo "DONE LOADING, waiting for users entering... >> "
read enter

iostat -xm 5 > $name.iostat &

for i in 1 2 3 4
do
	runner $i &
done

for job in `jobs -p`
do
	echo "Wait for runner $job";
	wait $job;
done
