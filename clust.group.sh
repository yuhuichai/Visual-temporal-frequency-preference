#!/bin/sh
module load afni
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq

cd ${dataDir}

for type in event; do
{
	# specify and possibly create results directory
	if [[ "$type" =~ "event" ]]; then
		results_dir=group.event.results
	elif [[ "$type" =~ "conn" ]]; then
		results_dir=group.results
	fi

	# create group mask
	[ -d $results_dir/files_ClustSim ] && rm -rf $results_dir/files_ClustSim
	mkdir $results_dir/files_ClustSim

	# event
	sub_list=`ls *Sub*/${type}*.results/blur_est.${type}*.1D`
	3dMean -prefix $results_dir/tmp1.blur.errts.mean.1D \
		$sub_list -overwrite

	1dcat $results_dir/tmp1.blur.errts.mean.1D | sed -n '4p' | \
		awk '{print $1" "$2" "$3}' > $results_dir/blur.errts.mean.1D

	3dClustSim -acf `cat $results_dir/blur.errts.mean.1D` \
		-mask $results_dir/mask_group.${type}+tlrc \
		-prefix $results_dir/files_ClustSim/clust \
		-overwrite

	rm -f $results_dir/tmp*

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

# 3dmaskave -mask Clust_mask+tlrc.HEAD'<2>' all_runs.event_iso+tlrc.HEAD