#!/bin/sh
module load afni R
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq/group.event.results

cd ${dataDir}
# combine beta value from all individuals
# for stim in vs01Hz vs05Hz vs10Hz vs20Hz vs40Hz; do
# 	3dbucket -prefix freqmap/mean_beta.${stim} \
# 		../*Sub*/event.results/stats.event.transient+tlrc.HEAD[${stim}#0_Coef] \
# 		-overwrite
# done

# combine group-mean beta
3dbucket -prefix freqmap/mean_beta.freqmap \
	tt++.vs01Hz+tlrc.HEAD[vs01Hz_mean] \
	tt++.vs05Hz+tlrc.HEAD[vs05Hz_mean] \
	tt++.vs10Hz+tlrc.HEAD[vs10Hz_mean] \
	tt++.vs20Hz+tlrc.HEAD[vs20Hz_mean] \
	tt++.vs40Hz+tlrc.HEAD[vs40Hz_mean] \
	-overwrite

# calculate mask
3dcopy visual_mask_0001+tlrc freqmap/visual_mask -overwrite
# 3dcalc -a visual05Hz_mask_0001+tlrc \
# 	-b visual10Hz_mask_0001+tlrc \
# 	-c visual20Hz_mask_0001+tlrc \
# 	-expr "or(a,b,c)" \
# 	-prefix freqmap/visual_mask \
# 	-overwrite

cd ${dataDir}/freqmap
3dcalc -a mean_beta.freqmap+tlrc[vs01Hz_mean] \
	-b mean_beta.freqmap+tlrc[vs05Hz_mean] \
	-c mean_beta.freqmap+tlrc[vs10Hz_mean] \
	-d mean_beta.freqmap+tlrc[vs20Hz_mean] \
	-e mean_beta.freqmap+tlrc[vs40Hz_mean] \
	-f visual_mask+tlrc \
	-expr "(1*a+5*b+10*c+20*d+40*e)/(a+b+c+d+e)*step(f)" \
	-prefix freqmap.weighted -overwrite

# 3dTstat -max -argmax1 -mask visual_mask+tlrc mean_beta.freqmap+tlrc -overwrite

# [ -f ${batchDir}/run_freqmap.swarm.sh ] && rm ${batchDir}/run_freqmap.swarm.sh
# for logtype in log10 ln; do
# 	echo "bash ${batchDir}/run_freqmap.sh /usr/local/matlab-compiler/v91 ${dataDir}/freqmap mean_beta.freqmap+tlrc visual_mask+tlrc ${logtype} freqmap.freq_${logtype}" \
# 		>> ${batchDir}/run_freqmap.swarm.sh
# done

# cd ${dataDir}
# echo ++ generating swarm script as following ...
# cat ${batchDir}/run_freqmap.swarm.sh
# echo ++ running swarm script with ...
# echo "swarm -g 2 -t 2 --time 0:30:00 -f run_freqmap.swarm.sh --logdir ${dataDir}/output"

# cd ${dataDir}/freqmap
# echo "1 5 10 20 40" > freq.1D
# 1deval -a freq.1D\' -expr "log10(a)" > freq_log10.1D
# 3dNLfim -input mean_beta.freqmap+tlrc \
# 	-mask visual_mask+tlrc \
# 	-time freq_log10.1D \
# 	-signal DiffExp \
# 	-noise Zero \
# 	-BOTH \
# 	-bucket 0 OUT \
# 	-sfit OUTPUTFIT \
# 	-progress 10000 \
# 	-jobs 8 -overwrite



