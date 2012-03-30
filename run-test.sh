#!/bin/bash
REQS=$2
FILENAME=`basename $1`
TMP=/tmp/.ab-suite-$FILENAME
REPS=5

URLS=`grep url $1 | sed -e "s/url=\(.*\)$/\1/g"`
CONCURRENCY=`grep concurrency $1 | sed -e "s/concurrency=\(.*\)$/\1/g"`

countdown()
(
	secs=$1
	while [ $secs -gt 0 ]
	do
		sleep 1 &
		printf "\rSleep for %02d" $secs
		secs=$(( $secs - 1 ))
		wait
	done
	printf "\r                   \r"
)

for URL in  $URLS
do
	echo "Testing url: $URL"
	echo -en "Conc\t\tRequest/sec\tTime/req\t95%\n"
	for CON in $CONCURRENCY
	do
		num=$REPS
		while [ $num -gt 0 ]
		do
			ab -n $REQS -c $CON $URL > $TMP 2> /dev/null
			RPS=`grep "Requests per second" $TMP | grep -oE "[0-9\.]*"`
			TPR=`grep "Time per request" $TMP | grep "all concurrent requests" | grep -oE "[0-9\.]*"`
			T95=`grep "95%" $TMP | grep -oE "[0-9\.]*$"`
			echo -en "$CON \t\t$RPS\t\t$TPR\t\t$T95\n"

			num=$(( $num -1 ))
			countdown 5
		done
		echo "----------------------------------------------"
		countdown 5
	done

	countdown 5
done


