#!/bin/sh
# batch dir
batchDir=/Users/chaiy3/Data/visualFreq/batch
# data directory
dataDir=/Users/chaiy3/Data/visualFreq
cd ${dataDir}

for patID in *Sub*; do 
	patDir=${dataDir}/${patID}
	cd ${patDir}
	sh ${batchDir}/rsfc.sh $patDir
done

# 1dplot outcount_rall.
# 3dinfo -VERB pb00.Tech001_vs40Hz.r01.tcat+orig. | grep offsets
# 1dplot dfile_rall.1D
# 1dplot motion_Tech001_vs40Hz_enorm.1D 
# 1dplot -volreg motion_demean.1D[1..6]
# errts. = input. - fitts.
# 1dplot X.stim.xmat.1D[0..11]

# 3dmaskave -mask Clust_mask+tlrc.HEAD'<2>' all_runs.event_iso+tlrc.HEAD