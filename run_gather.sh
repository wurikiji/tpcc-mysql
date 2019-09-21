dev=$1
name=$2
wh=$3
gather=$4
sg_dev=$5
mysql_dir=/home/ogh/work/git/mysql-server/build-install/installs/

if [ -z "$dev" ] || [ -z "$name" ] || [ -z "$gather" ] || [ -z "$sg_dev" ]
then
    echo "Usage: $0 [device] [test name] [wh] [do gather] [sg0]"
    exit 1
fi

rm -rf tmp.db
sqlite3 tmp.db "create table gather (key int, length int);"

while true; do sudo smartctl -A $dev >> outputs/$name.smartctl; sleep 10; done &
tty_on
tty_print > outputs/$name.uart &


while true
do
    LD_LIBRARY_PATH=/home/ogh/work/git/mysql-server/build-install/installs/lib ./tpcc_start -h127.0.0.1 -P3306 -dtpcc1000 -uroot -w${wh} -c16 -r0 -l1800 -prlghks12 -i5 >> outputs/$name.tpcc
    
    available_space=`df $dev --output=avail |tail -n 1`
    if [ 0 -eq ${available_space} ]
    then
        break;
    fi
    
    if $gather
    then
        # kill smartctl
        # JOBS=`jobs -p`
        # sudo kill -9 $JOBS
        
        
        #kill mysqld
        mysqladmin -S /tmp/my1.sock -uroot -prlghks12 shutdown
        sudo killall -9 mysqld
        sleep 10
        umount $dev
        
        #do gather
        ./gather.sh $sg_dev >> outputs/$name.gather_log
        
        sleep 10
        mount $dev /home/ogh/ssd
        # restart mysqld
        $mysql_dir/bin/mysqld --defaults-file=$mysql_dir/my.conf &
        
        # restart smartctl log
        # while true; do sudo smartctl -A $dev >> $name.smartctl; sleep 10; done &
    fi
done

jobs=`jobs -p`
sudo kill -9 $jobs
