# extract ROI-mean value (e.g., correlation, TSNR)

module load afni
dataDir=/data/chaiy3/visualFreq
batchDir=/data/chaiy3/visualFreq/batch
resultDir=/data/chaiy3/visualFreq/group.effects

# roiFile=hfroi_01_vs_h20_h40_masked+tlrc
# roiFile=Thalamus_masked+tlrc.HEAD
# roiFile=/data/chaiy3/visualFreq/group.event.results/Thalamus_groupevent+tlrc.HEAD
# roiFile=/data/chaiy3/visualFreq/group.results/freqmap/Kmeans_Cr.mean_beta.stats.LME.fcs_gm_Tha_fcs_gm_visual_pos_z+tlrc.HEAD"<2..2>"
# roiFile=/data/chaiy3/visualFreq/group.event.results/freqmap/native.template_areas.resamp_inflat_GMI_tha_freqmask+tlrc"<3..3>"
# maskFile=/data/chaiy3/visualFreq/group.event.results/40Hz_mask_0001+tlrc
# roiFile=/data/chaiy3/visualFreq/group.results/freqmap/visual_mask+tlrc.HEAD
roiFile=../Thalamus_masked+tlrc.HEAD
roiFile=../visual_masked+tlrc.HEAD

cd /data/chaiy3/visualFreq/170712Sub020/conn_fix.results/
for effectFile in fcs_gm_Thalamus_pos_z+tlrc.HEAD; do #
	echo ++ start analyzing $effectFile
	if [[ "$effectFile" =~ "tlrc" ]]; then
		effect=${effectFile%+tlrc*}_visual
	elif [[ "$effectFile" =~ ".1D" ]]; then
		effect=${effectFile%.1D}
	else
		effect=${effectFile}_oc
	fi
	group=common
	# effect=TSNR_Thalamus_mask

	cd $dataDir
	[ ! -d group.effects ] && mkdir group.effects
	[ -f group.effects/${effect}.1D ] && rm group.effects/${effect}*

	if [[ "$group" =~ "gamma" ]]; then
		effect=${effect}_${group}
		subj_list=($(ls -d *Sub004 *Sub005 *Sub006 *Sub008 *Sub009 *Sub011 *Sub016 *Sub017 *Sub019 *Sub021))
	else
		subj_list=($(ls -d *Sub*))
	fi

	for patID in ${subj_list[@]}; do
		patDir=$dataDir/$patID
		# if [ -d $patDir/event.results ]; then
			for stim in fix 01Hz 10Hz 20Hz 40Hz; do
			{				
				subj=conn_$stim
				if [[ "$patDir" =~ "Sub005" ]] && [[ $stim = 20Hz || $stim = 40Hz ]]; then
					echo 0 >> $resultDir/${effect}_${stim}.1D
				elif [[ "$patDir" =~ "Sub002" ]] && [[ $stim = 10Hz || $stim = 20Hz ]]; then
					echo 0 >> $resultDir/${effect}_${stim}.1D
				elif [[ "$patDir" =~ "Sub007" ]] && [[ $stim = 20Hz || $stim = 40Hz ]]; then
					echo 0 >> $resultDir/${effect}_${stim}.1D
				elif [[ "$patDir" =~ "Sub015" ]] && [[ $stim = 10Hz ]]; then
					echo 0 >> $resultDir/${effect}_${stim}.1D
				else
					cd $patDir/$subj.results/rsfc
					if [[ "$effectFile" =~ "vigilance" ]]; then
						cd ..
						effectFile="stats.conn_$stim+tlrc[conn_${stim}#0_Coef]"
						3dcalc -a ${effectFile} -b stats.conn_$stim+tlrc[conn_${stim}#0_Tstat] \
							-expr "a*step(b-3)" -prefix vigilance -overwrite
						effectFile=vigilance+tlrc.HEAD
					fi
					if [[ "$effectFile" =~ "TSNR" ]]; then
						cd ..
						effectFile=TSNR.conn_$stim+tlrc
					fi
					# calculate mean effect inside ROI
					# 3dcalc -a aseg_func_gm_infl+tlrc -expr "a*(amongst(a,92,167))" \
					# 	-prefix aseg_func_infl_calcarine_both \
					# 	-overwrite
					# roiFile=aseg_func_infl_calcarine_both+tlrc -mask $roiFile -cmask "-a ${maskFile} -expr step(a-0)"
					#  -cmask "-a ../aseg_func_gm_infl+tlrc -expr amongst(a,7,27)"
					if [[ "$effectFile" =~ "tlrc" ]]; then # -cmask "-a ../aseg_func_gm_infl+tlrc -expr amongst(a,27)"
						3dmaskdump -noijk -mask $roiFile ${effectFile} | \
							1d_tool.py -show_mmms -infile - > tmp.1D
						tmp=`cat tmp.1D | grep -e 'col' | awk '{print $8}'` 
						mean=${tmp%,}
					elif [[ "$effectFile" =~ "str_betw" ]] || [[ "$effectFile" =~ "str_in" ]]; then
						mean=`paste -sd+ ${effectFile} | bc` # sum
					else
						1d_tool.py -show_mmms -infile ${effectFile} > tmp.1D
						tmp=`cat tmp.1D | grep -e 'col' | awk '{print $8}'` 
						mean=${tmp%,}
					fi

					echo $mean >> $resultDir/${effect}_${stim}.1D
				fi
			}&
			done
			wait
		# fi
	done


	cd $resultDir
	1dcat ${effect}_fix.1D ${effect}_01Hz.1D ${effect}_10Hz.1D ${effect}_20Hz.1D \
		${effect}_40Hz.1D > ${effect}.1D
	rm ${effect}_fix.1D
	rm ${effect}_*Hz.1D
	[ -f tmp.1D ] && rm tmp.1D
done

# # calculate correlation matrix
# 3dNetCorr \
# 	-inset errts.${run%.results}+tlrc. \
# 	-in_rois follow_ROI_gm_aeseg+tlrc. \
# 	-fish_z -ts_wb_corr \
# 	-mask full_mask.${run%.results}+tlrc \
# 	-prefix 3dnetcorr
# 	-overwrite


# # A PREFIX_???.niml.dset is now also output
#    # automatically.  This NIML/SUMA-esque file is mainly for use in SUMA,
#    # for visualizing connectivity matrix info in a 3D brain.  It can be
#    # opened via, for example:
#    # suma -vol follow_ROI_aeseg+tlrc. -gdset 3dnetcorr_000.niml.dset

#    # plot correlation matrix
#    fat_mat_sel.py -m "3dnetcorr_000.netcc" -o -P 'FZ'