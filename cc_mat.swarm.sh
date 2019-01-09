#!/bin/sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}

[ -f ${batchDir}/run.cc_mat.swarm.sh ] && rm ${batchDir}/run.cc_mat.swarm.sh
for subID in *Sub*; do 
{	subDir=${dataDir}/${subID}

	cd $subDir
	if [[ "$subDir" =~ "002" ]]; then
		conn_dirs=($(ls -d conn_fix* conn_01Hz* conn_40Hz*))
	elif [[ "$subDir" =~ "005" || "$subDir" =~ "007" ]]; then
		conn_dirs=($(ls -d conn_fix* conn_01Hz* conn_10Hz*))
	else 
		conn_dirs=($(ls -d conn*))
	fi
	for run in ${conn_dirs[@]}; do
		for atlas in Power_coordinates_afni.1D tcorr05_2level_all_Javier.nii.gz shen_1mm_268_parcellation+tlrc; do # tcorr05_2level_all_Javier.nii.gz shen_1mm_268_parcellation+tlrc
			echo "bash ${batchDir}/cc_mat.sh $subDir $run $atlas" >> ${batchDir}/run.cc_mat.swarm.sh
			# bash ${batchDir}/cc_mat.sh $subDir $run $atlas
		done
	done
}&
done
wait

cd ${dataDir}
[ ! -d swarm_output ] && mkdir swarm_output
echo generating swarm script as following ...
cat ${batchDir}/run.cc_mat.swarm.sh
echo running swarm script with ...
echo "swarm -g 2 -t 3 --time 00:30:00 -f run.cc_mat.swarm.sh --logdir ${dataDir}/swarm_output"