#!/bin/bash

source /home/ogh/.bashrc
dev=/dev/sdc
pw='rlghks!1'
db_folder=/home/ogh/jasmine/32kb-10g
log_folder=/home/ogh/temp
#cp="rsync -avh --progress"
cp="gcp -f"
mysql_home=/home/ogh/original/mysql-5.7.15-install
mysqld=${mysql_home}/bin/mysqld
backup_db=/home/ogh/backup/h2o/32kb-tpcc-100wh-5.7
drop_cache="sysctl -w vm.drop_caches=3"

init() {
	echo $pw | sudo -S killall -9 mysqld
	while true
	do
		old_mysqld=`ps -ef |grep mysqld|grep -v grep`
		if [ -z "${old_mysqld}" ]
		then
			break;
		fi
	done
	sudo umount ${dev}1
	#sudo dd if=/dev/zero | pv | sudo dd of=${dev} bs=1M oflag=direct
	#sudo dd if=/dev/zero | pv | sudo dd of=${dev} bs=1M oflag=direct
	sudo dd if=/dev/zero of=${dev} bs=1M oflag=direct status=progress
	sudo dd if=/dev/zero of=${dev} bs=1M oflag=direct status=progress
	echo -e "${pw}\n d\n n\n \n \n \n \n w\n" | sudo -S fdisk ${dev}
	sudo mkfs.ext4 -Elazy_itable_init=0,nodiscard ${dev}1
	sudo mount -onobarrier ${dev}1  /home/ogh/jasmine
	sudo umount /dev/sdb1
	sudo mount /dev/sdb1 -onobarrier ${log_folder}
	sudo chown -R ogh:ogh /home/ogh/jasmine ${log_folder}
}

copy_data(){ 
	$cp -r ${backup_db}/ib_logfile* ${log_folder} 
	$cp -r ${backup_db} ${db_folder}
}

start_mysql(){
	sync; sudo ${drop_cache};
	rm -f /home/ogh/nvme/mysql-error.log
	${mysqld} --defaults-file=${mysql_home}/jasmine.cnf &
	sudo hdparm -A$1 ${dev}
}

if [ $# -lt 1 ]
then
	echo "Usage: $0 [0:Normal, 1:CBM]";
	exit 1;
fi

init
copy_data
start_mysql $1
