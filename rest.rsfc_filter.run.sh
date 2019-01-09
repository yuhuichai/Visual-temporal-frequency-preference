#!/bin/sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}

for patID in *Sub021; do
{	patDir=${dataDir}/${patID}
	cd ${patDir}

	if [[ "$patID" =~ "002" ]]; then
		conn_dirs=($(ls -d conn_fix* conn_01Hz* conn_40Hz*))
	elif [[ "$patID" =~ "005" || "$patID" =~ "007" ]]; then
		conn_dirs=($(ls -d conn_fix* conn_01Hz* conn_10Hz*))
	else 
		conn_dirs=($(ls -d conn*))
	fi
	echo $patID
	for run in ${conn_dirs[@]}; do
	{	cd ${patDir}/${run}
		tcsh ${batchDir}/rest.rsfc_filter.sh ${run%.results}
	}&
	done
	wait
}&
done
wait

# 1dplot outcount_rall.
# 3dinfo -VERB pb00.Tech001_vs40Hz.r01.tcat+orig. | grep offsets
# 1dplot dfile_rall.1D
# 1dplot motion_Tech001_vs40Hz_enorm.1D 
# 1dplot -volreg motion_demean.1D[1..6]
# errts. = input. - fitts.
# 1dplot X.stim.xmat.1D[0..11]