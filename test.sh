send_gather() {
    lba=$1
    num=$2
    while((num > 0))
    do
        next_num=128;
        if [ $num -lt 128 ]
        then
            next_num=$num;
        fi
        # sudo /home/ogh/work/git/libgather/libgather/test $dev lba next_num
        
        echo $lba $next_num
        
        
        num=$((num - next_num))
        lba=$((lba + next_num))
    done
}
send_gather 0 192939