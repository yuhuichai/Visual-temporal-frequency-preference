dataDir=/Users/chaiy3/Data/visualFreq
batchDir=/Users/chaiy3/Data/visualFreq/batch

for patID in *Sub001 *Dan; do
{	patDir=$dataDir/$patID
	sumaDir=$patDir/Surf/surf/SUMA
	cd $patDir
	for subj_results in event*.results; do
	{	cd $patDir/$subj_results
		subj=${subj_results%.results}

		stim_all_index=(6 7 8 9)
		let "stim_index = 0"
		for stim in 01Hz 10Hz 20Hz 40Hz; do	
			uninterest_index_stim=( "${stim_all_index[@]::$stim_index}" "${stim_all_index[@]:$((stim_index+1))}")

			# extract effect of uninterest regressors 
			# items for -select from: grep ColumnLabels X.xmat.1D 
			3dSynthesize -prefix uninterest.$stim -matrix X.nocensor.xmat.1D -cbucket all_betas.${subj}_REML+tlrc \
			    -select 0 1 2 3 4 5 ${uninterest_index_stim[@]} 10 11 12 13 14 15 16 -overwrite
			# remove uninterest effects
			3dcalc -a all_runs.$subj+tlrc -b uninterest.$stim+tlrc -expr 'a-b' -prefix interest.$stim+tlrc -overwrite

			# extract mean time course of occipital regions
			3dROIstats -quiet -mask aseg_func_oc_infl+tlrc interest.$stim+tlrc > occipital_ts.$stim.1D -overwrite

			rm -f *interest.$stim+tlrc*
			let "stim_index += 1"
		done

		# # extract effects of non visual stim
		# 3dSynthesize -prefix uninterest -matrix X.nocensor.xmat.1D -cbucket all_betas.${subj}_REML+tlrc \
		#     -select 0 1 2 3 4 5 10 11 12 13 14 15 16 -overwrite
		# # remove uninterest effects
		# 3dcalc -a all_runs.${subj}+tlrc -b uninterest+tlrc -expr 'a-b' -prefix interest+tlrc -overwrite

		# # extract mean time course of occipital regions
		# 3dROIstats -quiet -mask aseg_func_oc_infl+tlrc interest+tlrc > occipital_ts.stim.1D -overwrite

		# rm -f *interest+tlrc*
		rm -f occipital_ts.stim.1D
	}&
	done
	wait
}&
done
wait

