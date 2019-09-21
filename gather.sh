dev=$1
if [ -z "$dev" ]
then
	echo "Usage: $0 [dev name]"
	exit 1
fi

sudo hdparm --fibmap /home/ogh/ssd/database/tpcc1000/order_line*.ibd > order_line.fibmap

grep -v 's\|^\s\+$' order_line.fibmap | sed 's/^\s\+//g' |sed 's/\s\+/ /g' |cut -d ' ' -f 2,4 > order_line.gather_pair

# rm -f tmp.db
# sqlite3 tmp.db "create table pair (a int);"


send_gather() {
    lba=$1
    num=$2
	sudo /home/ogh/work/git/libgather/libgather/test $dev $lba $num
: '
    while((num > 0))
    do
        next_num=1024;
        if [ $num -lt $next_num ]
        then
            next_num=$num;
        fi

        sudo /home/ogh/work/git/libgather/libgather/test $dev $lba $next_num
        
        num=$((num - next_num))
        lba=$((lba + next_num))
		sleep 0.1
    done
	';
}

while read line
do
	IFS=' ' read -a params <<< $line
	if [ -z $params ]
	then
		continue
	fi
	count=`sqlite3 tmp.db "select count(*) from gather where key = ${params[0]};"`
	if [ -z $count ]
	then
		count=0
	fi
	if [ $count -eq 0 ]
	then
		# do gather and insert it to table
		sqlite3 tmp.db "insert into gather values (${params[0]}, ${params[1]});"
		send_gather ${params[0]} ${params[1]}
	else
		# check length 
		length=`sqlite3 tmp.db "select length from gather where key = ${params[0]};"`
		if [ $length -ne ${params[1]} ]
		then
			# do gather and update
			sqlite3 tmp.db "update gather set length=${params[1]} where key = ${params[0]};"
			send_gather ${params[0]} ${params[1]}
		fi
	fi
done < order_line.gather_pair
