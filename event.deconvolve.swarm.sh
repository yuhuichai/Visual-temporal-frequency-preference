#!/bin/sh
module load afni
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}
[ -f ${batchDir}/run.event.deconvolve.swarm.sh ] && rm ${batchDir}/run.event.deconvolve.swarm.sh
for patID in *Sub006 *Sub003 *Sub008 *Sub013; do
{	
	patDir=${dataDir}/${patID}
	cd ${patDir}
	if [ -d event.results ]; then		
		cd ${patDir}/event.results

		run_list=($(ls pb04.*.r*.scale+tlrc.HEAD))
		run_num=${#run_list[@]}

		echo =========== ${patDir}/event.results ===========
		# cd stimuli
		# for stim in *Hz_dis8TR.txt; do
		# 	1dcat $stim > ${stim%txt}1D
		# 	cat $stim > ${stim%.txt}_onset.txt
		# 	3dcalc -a ${stim%txt}1D\' -expr "a+10" \
		# 		-prefix ${stim%.txt}_offset.1D
		# 	1dcat ${stim%.txt}_offset.1D\' > ${stim%.txt}_offset.txt
		# done
		# rm *.1D
		# cd ..
		subj_num=${patID#*Sub}
		if [ "${subj_num}" -lt "14" ]; then
			# echo "tcsh ${batchDir}/event.deconvolve.60Hz.sh ${patDir}/event.results ${run_num}" >> ${batchDir}/run.event.deconvolve.swarm.sh
			tcsh ${batchDir}/event.deconvolve.60Hz.sh ${patDir}/event.results ${run_num}
		elif [ "${subj_num}" -gt "14" ]; then
			# echo "tcsh ${batchDir}/event.deconvolve.40Hz.sh ${patDir}/event.results ${run_num}" >> ${batchDir}/run.event.deconvolve.swarm.sh
			tcsh ${batchDir}/event.deconvolve.40Hz.sh ${patDir}/event.results ${run_num}
		fi
	fi
}&
done
wait

cd ${dataDir}
echo ++ generating swarm script as following ...
cat ${batchDir}/run.event.deconvolve.swarm.sh
echo ++ running swarm script with ...
echo "swarm -g 8 -t 4 --time 0:20:00 -f run.event.deconvolve.swarm.sh --logdir ${dataDir}/swarm_output"

# 1dplot outcount_rall.
# 3dinfo -VERB pb00.Tech001_vs40Hz.r01.tcat+orig. | grep offsets
# 1dplot dfile_rall.1D
# 1dplot motion_Tech001_vs40Hz_enorm.1D 
# 1dplot -volreg motion_demean.1D[1..6]
# errts. = input. - fitts.
# 1dplot X.stim.xmat.1D[0..11]
