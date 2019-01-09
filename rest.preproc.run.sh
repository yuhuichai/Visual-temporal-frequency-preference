#!/bin/sh
# batch dir
batchDir=/Users/chaiy3/Data/visualFreq/batch
# data directory
dataDir=/Users/chaiy3/Data/visualFreq
cd ${dataDir}

# for patID in *Dan; do
# 	patDir=${dataDir}/${patID}
# 	cd ${patDir}
# 	for stim in 01Hz 10Hz 20Hz 40Hz fix checker; do
# 	{	tcsh ${batchDir}/rest.preproc.sh ${patDir} conn_$stim 20 2>&1 | tee output.conn_${stim}
# 	}&
# 	done
# done

for patID in *Sub007; do
	patDir=${dataDir}/${patID}
	cd ${patDir}
	for stim in 01Hz 10Hz fix; do
	{	tcsh ${batchDir}/rest.preproc.sh ${patDir} conn_$stim 2>&1 | tee output.conn_${stim}
	}&
	done
	wait
done

# 1dplot outcount_rall.
# 3dinfo -VERB pb00.Tech001_vs40Hz.r01.tcat+orig. | grep offsets
# 1dplot dfile_rall.1D
# 1dplot motion_Tech001_vs40Hz_enorm.1D 
# 1dplot -volreg motion_demean.1D[1..6]
# errts. = input. - fitts.
# 1dplot X.stim.xmat.1D[0..11]