#!/bin/sh
module load afni
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}

[ -f ${batchDir}/run.freqmap.swarm.sh ] && rm ${batchDir}/run.freqmap.swarm.sh

# event
for subID in *Sub*; do 
{	
	subj_dir=${dataDir}/${subID}/event.results
	if [ -d ${subj_dir} ]; then
		cd ${subj_dir}

		# combine frequency-dependent beta value
		3dbucket -prefix beta.freqmap \
			stats.event.transient+tlrc.HEAD[vs01Hz#0_Coef] \
			stats.event.transient+tlrc.HEAD[vs05Hz#0_Coef] \
			stats.event.transient+tlrc.HEAD[vs10Hz#0_Coef] \
			stats.event.transient+tlrc.HEAD[vs20Hz#0_Coef] \
			stats.event.transient+tlrc.HEAD[vs40Hz#0_Coef] \
			-overwrite

		# calculate visual mask
		3dcalc -a Clust_mask+tlrc \
			-b mask_group_epi+tlrc \
			-expr "and(a,b)" \
			-prefix visual_mask -overwrite

		# calculate frequency-weighted mean
		3dcalc -a stats.event.transient+tlrc.HEAD[vs01Hz#0_Coef] \
			-b stats.event.transient+tlrc.HEAD[vs05Hz#0_Coef] \
			-c stats.event.transient+tlrc.HEAD[vs10Hz#0_Coef] \
			-d stats.event.transient+tlrc.HEAD[vs20Hz#0_Coef] \
			-e stats.event.transient+tlrc.HEAD[vs40Hz#0_Coef] \
			-f visual_mask+tlrc \
			-expr "(1*a+5*b+10*c+20*d+40*e)/(a+b+c+d+e)*step(f)" \
			-prefix freqmap.weighted -overwrite

		subj_num=${subID#*Sub}
		if [ "${subj_num}" -lt "14" ]; then
			# combine frequency-dependent beta value
			3dbucket -prefix beta.freqmap_60Hz \
				stats.event.transient+tlrc.HEAD[vs01Hz#0_Coef] \
				stats.event.transient+tlrc.HEAD[vs05Hz#0_Coef] \
				stats.event.transient+tlrc.HEAD[vs10Hz#0_Coef] \
				stats.event.transient+tlrc.HEAD[vs15Hz#0_Coef] \
				stats.event.transient+tlrc.HEAD[vs20Hz#0_Coef] \
				stats.event.transient+tlrc.HEAD[vs40Hz#0_Coef] \
				stats.event.transient+tlrc.HEAD[vs60Hz#0_Coef] \
				-overwrite

			# calculate frequency-weighted mean
			3dcalc -a stats.event.transient+tlrc.HEAD[vs01Hz#0_Coef] \
				-b stats.event.transient+tlrc.HEAD[vs05Hz#0_Coef] \
				-c stats.event.transient+tlrc.HEAD[vs10Hz#0_Coef] \
				-d stats.event.transient+tlrc.HEAD[vs15Hz#0_Coef] \
				-e stats.event.transient+tlrc.HEAD[vs20Hz#0_Coef] \
				-f stats.event.transient+tlrc.HEAD[vs40Hz#0_Coef] \
				-g stats.event.transient+tlrc.HEAD[vs60Hz#0_Coef] \
				-h visual_mask+tlrc \
				-expr "(1*a+5*b+10*c+15*d+20*e+40*f+60*g)/(a+b+c+d+e+f+g)*step(h)" \
				-prefix freqmap_60Hz.weighted -overwrite
		fi


		# echo "bash ${batchDir}/run_freqmap.sh /usr/local/matlab-compiler/v91 ${subj_dir} beta.freqmap+tlrc aseg_func_oc_infl+tlrc event diffexp" \
		# 			>> ${batchDir}/run.freqmap.swarm.sh
	fi
}&
done
wait

# cd ${dataDir}
# [ ! -d swarm_output ] && mkdir swarm_output
# echo ++ generating swarm script as following:
# cat ${batchDir}/run.freqmap.swarm.sh
# echo running swarm script with ...
# echo "swarm -g 2 -t 2 --time 00:30:00 -f run.freqmap.swarm.sh --logdir ${dataDir}/swarm_output"





