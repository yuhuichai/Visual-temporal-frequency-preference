#!/bin/sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}

[ -f ${batchDir}/run.rsfc.swarm.sh ] && rm ${batchDir}/run.rsfc.swarm.sh
for subID in *Sub021; do 
{	subDir=${dataDir}/${subID}

	cd $subDir
	# if [[ "$subDir" =~ "002" ]]; then
	# 	conn_dirs=($(ls -d conn_fix* conn_01Hz* conn_40Hz*))
	# elif [[ "$subDir" =~ "005" || "$subDir" =~ "007" ]]; then
	# 	conn_dirs=($(ls -d conn_fix* conn_01Hz* conn_10Hz*))
	# else 
		conn_dirs=($(ls -d conn_20Hz*))
	# fi
	for run in ${conn_dirs[@]}; do # ${conn_dirs[@]}
	{	
		# echo "bash ${batchDir}/rsfc.sh $subDir $run" >> ${batchDir}/run.rsfc.swarm.sh
		bash ${batchDir}/rsfc.sh $subDir $run
	}&
	done
	wait
}&
done
wait

cd ${dataDir}
[ ! -d swarm_output ] && mkdir swarm_output
echo ++ generating swarm script as following ...
cat ${batchDir}/run.rsfc.swarm.sh
echo ++ running swarm script with ...
echo "swarm -g 20 -t 2 --time 0:30:00 -f run.rsfc.swarm.sh --logdir ${dataDir}/swarm_output"