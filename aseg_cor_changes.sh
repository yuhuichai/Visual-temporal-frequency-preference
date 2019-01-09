#!/bin/bash
export PATH="$PATH:/Users/chaiy3/abin"

copyDir=/Users/chaiy3/Data/visualFreq/170208Sub003/conn_10Hz.results
batchDir=/Users/chaiy3/Data/visualFreq/batch
resultsDir=/Users/chaiy3/Data/visualFreq/group.results

cd ${resultsDir}
cp $copyDir/aseg_anat_gm_infl+tlrc* $resultsDir/
cp $copyDir/anat_final* $resultsDir/

for file in *all*txt; do
	fileNM=${file%.txt}
	index=`cat $file`
	3dcalc -a aseg_anat_gm_infl+tlrc -expr "a*(amongst(a,$index))" \
		-prefix aseg_anat_infl_${fileNM}+tlrc -overwrite

	# copy labeltable
	3drefit -copytables aseg_anat_gm_infl+tlrc aseg_anat_infl_${fileNM}+tlrc
done




