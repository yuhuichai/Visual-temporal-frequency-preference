#!/bin/sh
module load afni R
# batch dir
batchDir=/data/chaiy3/visualFreq/batch

# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}

results_dir=group.event.results
[ ! -d ${results_dir} ] && mkdir ${results_dir}
[ ! -d ${results_dir}/output ] && mkdir ${results_dir}/output

# create group mask
sub_list=`ls *Sub*/event.results/mask_group_epi+tlrc.HEAD`
3dmask_tool -prefix $results_dir/mask_group.event \
	-frac 0.6 -input \
	$sub_list -overwrite

# mean_vs01to10Hz mean_vs05to10Hz mean_vs01to20HzVS mean_vs40to60Hz vs01Hz vs05Hz vs10Hz vs20Hz vs40Hz vigilance
# vs01Hz_h20Hz_h40Hz_onset vs01Hz_h20Hz_h40Hz_offset mean_vs05Hz_10Hz_20Hz 
for cnst in vs01Hz_h20Hz_h40Hz; do
{	
	# if [[ "$cnst" =~ "mean" ]]; then
		cnst=${cnst}_GLT
	# fi
	tcsh ${batchDir}/event.mema.sh ${cnst}
	# tcsh ${batchDir}/event.mema.sh ${cnst}_offset
	# tcsh ${batchDir}/event.mema.sh ${cnst}_onset
}&
done
wait
