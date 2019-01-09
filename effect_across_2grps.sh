# extract ROI-mean effect for two groups (significantly respond to gamma stimuli vs. not respond to gamma stimuli)
module load afni
dataDir=/data/chaiy3/visualFreq
batchDir=/data/chaiy3/visualFreq/batch
# roiFile=/data/chaiy3/visualFreq/group.results/mask_gm_group.conn+tlrc
roiFile=/data/chaiy3/visualFreq/group.event.results/vs01Hz_gt_40Hz_mask_0001+tlrc
# roiFile=/data/chaiy3/visualFreq/graph.results/M_visual_resample+tlrc
# roiFile=../Thalamus_masked+tlrc
cd /data/chaiy3/visualFreq/170510Sub016/conn_fix.results/rsfc
for effectFile in roi950_allvec_str*40Hz_Tha*.1D roi950_allvec_str*01Hz_Tha*.1D roi950_allvec_str*both_Tha*.1D; do 
	echo ++ start analyzing $effectFile
	for group in gamma; do
		if [[ "$effectFile" =~ "tlrc" ]]; then
			effect=${effectFile%+tlrc*}
		elif [[ "$effectFile" =~ ".1D" ]]; then
			effect=${effectFile%.1D}
		else
			effect=$effectFile
		fi
		effect=${effect}_${group}
		resultDir=/data/chaiy3/visualFreq/group.effects

		cd $dataDir
		[ ! -d group.effects ] && mkdir group.effects
		[ -f group.effects/${effect}.1D ] && rm group.effects/${effect}*

		if [[ "$group" =~ "gamma" ]]; then
			subj_list=($(ls -d *Sub004 *Sub005 *Sub006 *Sub009 *Sub010 *Sub011 *Sub016))
		else	
			subj_list=($(ls -d *Sub003 *Sub007 *Sub008 *Sub012 *Sub013))
		fi

		for patID in ${subj_list[@]}; do
			patDir=$dataDir/$patID
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
					# roiFile=aseg_func_infl_calcarine_both+tlrc
					if [[ "$effectFile" =~ "tlrc" ]]; then

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
		done


		cd $resultDir
		1dcat ${effect}_fix.1D ${effect}_01Hz.1D ${effect}_10Hz.1D ${effect}_20Hz.1D \
			${effect}_40Hz.1D > ${effect}.1D
		rm ${effect}_fix.1D
		rm ${effect}_*Hz.1D
		[ -f tmp.1D ] && rm tmp.1D
	done
done