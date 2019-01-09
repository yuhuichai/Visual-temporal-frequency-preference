#!/bin/sh
module load afni

dataDir=/data/chaiy3/visualFreq
batchDir=/data/chaiy3/visualFreq/batch
roiFile=/data/chaiy3/visualFreq/graph.results/M_visual_resample+tlrc

cd ${dataDir}
for patID in *Sub*; do
{	patDir=$dataDir/$patID

	cd $patDir
	for subj_results in conn*.results; do
		subj=${subj_results%.results}
		cd $patDir/$subj_results
		3dPeriodogram -prefix power errts.${subj}.fanaticor+tlrc -overwrite
		3dROIstats -quiet -mask Thalamus_masked+tlrc power+tlrc > power_thalamus.1D -overwrite
		3dROIstats -quiet -mask ${roiFile} power+tlrc > power_visual.1D -overwrite
	done
}&
done
wait

