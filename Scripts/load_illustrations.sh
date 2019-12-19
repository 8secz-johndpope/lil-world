line_number=0
current_folder=""
for i in $(cat images.txt); do
	if ! ((line_number % 4)); then
		mkdir $i
		current_folder=$i"/"
	else
		no_dv=${i//:/_}
		echo "1"
		echo $no_dv
		no_sl=${no_dv//\//_}
		echo $no_sl
	    curl $i >> $current_folder$no_sl
	fi
	line_number=$line_number+1
done