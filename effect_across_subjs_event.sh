# extract ROI-mean effect (e.g., percent signal changes)
module load afni
dataDir=/data/chaiy3/visualFreq
batchDir=/data/chaiy3/visualFreq/batch
# roiFile=../conn_fix.results/Thalamus_masked+tlrc
# roiFile="aseg_func_V1_Vh+tlrc<2..2>"
resultDir=/data/chaiy3/visualFreq/group.effects
# maskFile=aseg_func_gm_infl+tlrc
roiFile=/data/chaiy3/visualFreq/group.event.results/freqmap/native.template_areas.resamp_inflat_GMI_tha_freqmask_event+tlrc"<4..4>"
maskFile=mask_group_epi+tlrc
effect=sus_tha

# for K in 2 3 4; do
# 	for idx in `seq 1 $K`; do
		# roiFile=/data/chaiy3/visualFreq/group.event.results/freqmap/Kmeans_Cr.mean_beta.freqmap+tlrc.HEAD"[K${K}]<${idx}..${idx}>"
		# roiFile=Kmeans_Cr.beta.freqmap+tlrc.HEAD"[K${K}]<${idx}..${idx}>"
		# effect=sus_K${K}_idx${idx}_subj

		cd $dataDir
		[ ! -d group.effects ] && mkdir group.effects
		[ -f group.effects/${effect}.1D ] && rm group.effects/${effect}.1D
		# rm group.effects/visual_atlas*.1D

		for patID in *Sub*; do
			patDir=$dataDir/$patID
			if [ -d $patDir/event.results ]; then
				cd $patDir/event.results
				echo $patDir/event.results

				# 3dcalc -a ../../group.event.results/hfroi_01_vs_h20_h40_mask_0002+tlrc.HEAD -b mask_group_epi+tlrc \
				# 	-expr 'step(a)*step(b)' -prefix hfroi_01_vs_h20_h40_masked+tlrc -overwrite
				# 3dcalc -a ../../group.event.results/lfroi_01_vs_h20_h40_mask_0001+tlrc.HEAD -b mask_group_epi+tlrc \
				# 	-expr 'step(a)*step(b)' -prefix lfroi_01_vs_h20_h40_masked+tlrc -overwrite
				# 3dcalc -a lfroi_01_vs_h20_h40_masked+tlrc. -b hfroi_01_vs_h20_h40_masked+tlrc. \
				# 	-c ../conn_fix.results/Thalamus_masked+tlrc. -expr "a+2*b+3*c" -prefix lhfroi_01_vs_h20_h40_Thalamus_masked+tlrc. -overwrite

				for stim in 01Hz 05Hz 10Hz 20Hz 40Hz; do
					# calculate mean effect inside ROI  -cmask "-a ${maskFile} -expr amongst(a,7,27)"
					3dmaskdump -noijk -mask ${roiFile} -cmask "-a ${maskFile} -expr step(a)" \
						stats.event.transient+tlrc[vs${stim}#0_Coef] | \
						1d_tool.py -show_mmms -infile - > tmp.1D
					tmp=`cat tmp.1D | grep -e 'col' | awk '{print $8}'` 
					mean=${tmp%,}
					echo $mean >> $resultDir/${effect}_${stim}.1D
					rm tmp.1D
				done

				# for roiFile in visual_atlas*HEAD; do
				# 	for i in `seq 1 5`; do
				# 		nvoxels=`3dBrickStat -count -non-zero ${roiFile}"<$i..$i>"`
				# 		if [ "$nvoxels" -gt 0 ]; then
				# 			effect=${roiFile%.infl*}_V${i}
				# 			for stim in 01Hz 05Hz 10Hz 20Hz 40Hz; do
				# 				# calculate mean effect inside ROI  -cmask "-a ${maskFile} -expr amongst(a,7,27)"
				# 				3dmaskdump -noijk -mask ${roiFile}"<$i..$i>" \
				# 					stats.event.transient+tlrc[vs${stim}#0_Coef] | \
				# 					1d_tool.py -show_mmms -infile - > tmp.1D
				# 				tmp=`cat tmp.1D | grep -e 'col' | awk '{print $8}'` 
				# 				mean=${tmp%,}
				# 				echo $mean >> $resultDir/${effect}_${stim}.1D
				# 				rm tmp.1D
				# 			done
				# 		fi
				# 	done
				# done
			fi
		done

		cd $resultDir
		1dcat ${effect}_*Hz.1D > ${effect}.1D
		rm ${effect}_*Hz.1D

		# for effect_01Hz in visual_atlas*01Hz.1D; do
		# 	1dcat ${effect_01Hz%01Hz.1D}*Hz.1D > ${effect_01Hz%_01Hz.1D}.1D
		# 	rm ${effect_01Hz%01Hz.1D}*Hz.1D
		# done
# 	done
# done

