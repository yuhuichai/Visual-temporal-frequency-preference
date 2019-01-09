#!/bin/sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}

[ -f ${batchDir}/run.rest.preproc.swarm.sh ] && rm ${batchDir}/run.rest.preproc.swarm.sh
for subID in *Sub021; do 
	subDir=${dataDir}/${subID}
	cd $subDir
	# rm -rf conn*results
	cd $subDir/Func
	if [[ "$subDir" =~ "002" ]]; then
		conn_files=($(ls -f conn_fix* conn_01Hz* conn_40Hz*))
	elif [[ "$subDir" =~ "005" || "$subDir" =~ "007" ]]; then
		conn_files=($(ls -f conn_fix* conn_01Hz* conn_10Hz*))
	else 
		conn_files=($(ls -f conn*))
	fi
	for file in ${conn_files[@]}; do
		stim=${file%.nii.gz}
		echo "tcsh ${batchDir}/rest.preproc.sh ${subDir} $stim" >> ${batchDir}/run.rest.preproc.swarm.sh
	done
done

cd ${dataDir}
[ ! -d swarm_output ] && mkdir swarm_output
echo ++ generating swarm script as following:
cat ${batchDir}/run.rest.preproc.swarm.sh
echo ++ running swarm script with ...
echo "swarm -g 4 -t 8 --time 01:30:00 -f run.rest.preproc.swarm.sh --logdir ${dataDir}/swarm_output"