dataDir=/data/chaiy3/visualFreq
batchDir=/data/chaiy3/visualFreq/batch
roi_file=/data/chaiy3/visualFreq/group.event.results/vs01Hz_40Hz+tlrc

cd $dataDir
for patID in *Sub005 *Sub006 *Sub009 *Sub010 *Sub011 *Sub016 *Sub003 *Sub004 *Sub007 *Sub008 *Sub012 *Sub013; do 
{	patDir=$dataDir/$patID
	sumaDir=$patDir/Surf/surf/SUMA
	cd $patDir
	for subj_results in event.results; do
		subj=${subj_results%.results}
		cd $patDir/$subj_results

		# 3dcalc -a aseg_func_oc_wotha_infl+tlrc -b vs40Hz_mask*tlrc.HEAD \
		# 	-expr "step(a)*step(b)" -prefix vs40Hz_occipital -overwrite
		# 3dcalc -a aseg_func_infl_calcarine_both+tlrc -b vs01Hz_mask*tlrc.HEAD \
		# 	-expr "step(a)*step(b)" -prefix vs01Hz_calcarine -overwrite	

		if [[ "$patID" =~ "Sub007" ]]; then
			stim_all_index=(12 13 14 16 17)
		elif [[ "$patID" =~ "Sub016" ]]; then
			stim_all_index=(12 13 14 15 16)
		else
			stim_all_index=(18 19 20 22 23)
		fi
		let "stim_index = 0"
		for stim in 01Hz 05Hz 10Hz 20Hz 40Hz; do	
			uninterest_index_stim=( "${stim_all_index[@]::$stim_index}" "${stim_all_index[@]:$((stim_index+1))}")

			# extract effect of uninterest regressors 
			# items for -select from: grep ColumnLabels X.xmat.1D 
			if [[ "$patID" =~ "Sub007" ]]; then
				3dSynthesize -prefix uninterest.$stim -matrix X.nocensor.xmat.1D -cbucket all_betas.${subj}+tlrc \
				    -select 0 1 2 3 4 5 6 7 8 9 10 11 15 18 ${uninterest_index_stim[@]} 19 20 21 22 23 24 25 \
				    -overwrite
			elif [[ "$patID" =~ "Sub016" ]]; then
				3dSynthesize -prefix uninterest.$stim -matrix X.nocensor.xmat.1D -cbucket all_betas.${subj}+tlrc \
				    -select 0 1 2 3 4 5 6 7 8 9 10 11 ${uninterest_index_stim[@]} 17 18 19 20 21 22 23 \
				    -overwrite
			else
				3dSynthesize -prefix uninterest.$stim -matrix X.nocensor.xmat.1D -cbucket all_betas.${subj}+tlrc \
				    -select 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 21 24 ${uninterest_index_stim[@]} 25 26 27 28 29 30 31 \
				    -overwrite
			fi
			# remove uninterest effects
			3dcalc -a all_runs.$subj+tlrc -b uninterest.$stim+tlrc -expr 'a-b' -prefix interest.$stim+tlrc -overwrite

			# extract mean time course of occipital regions
			# 3dROIstats -quiet -mask aseg_func_oc_infl+tlrc interest.$stim+tlrc > occipital_ts.$stim.1D -overwrite
			3dROIstats -quiet -mask ${roi_file} interest.$stim+tlrc > gamma_ts.$stim.1D -overwrite
			# 3dROIstats -quiet -mask vs40Hz_occipital+tlrc interest.$stim+tlrc > vs40Hz_occipital_ts.$stim.1D -overwrite
			# 3dROIstats -quiet -mask vs01Hz_calcarine+tlrc interest.$stim+tlrc > vs01Hz_calcarine_ts.$stim.1D -overwrite

			# # extract mean time course of occipital regions
			# 3dROIstats -quiet -mask aseg_func_oc_infl+tlrc all_runs.$subj+tlrc > occipital_ts.$stim.1D -overwrite

			rm -f *interest.$stim+tlrc*
			let "stim_index += 1" # cannot use paralell computing here

			# echo $stim $patID
			# echo ${uninterest_index_stim[@]} $patID
		done
	done
}&
done
wait