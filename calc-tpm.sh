files=$@

for file in $files
do
	echo "=====FILE: $file"
	output=nonzero-$file
	withzero=withzero-$file

	grep trx $file | grep -v "trx: 0" > $output
	grep trx $file > $withzero

	sed -i 's/^\s\+//g' $output
	sed -i 's/,//g' $output

	sed -i 's/^\s\+//g' $withzero
	sed -i 's/,//g' $withzero

	sum=`cut -d' ' -f3 $output | paste -sd+ | bc`
	lines=`wc -l $output | cut -d ' ' -f 1` 

	echo "Total tx: $sum, Total times: $((lines * 5)) seconds"
	echo -n " TPM >> " 
	echo "$sum / $lines * 12" | bc

	sum=`cut -d' ' -f3 $withzero| paste -sd+ | bc`
	lines=`wc -l $withzero| cut -d ' ' -f 1` 
	tpm=`echo "$sum / $lines * 12" | bc`

	echo "Total tx: $sum, Total times: $((lines * 5)) seconds with zero"
	echo " TPM >> $tpm  with zero " 
done
