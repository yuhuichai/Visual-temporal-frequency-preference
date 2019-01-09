#!/bin/tcsh -xef
module load afni R

subDir=$1 # /Users/chaiy3/Data/visualFreq/*Sub003
sumaDir=${subDir}/Surf/surf/SUMA
run=$2

# seed files
seedDir=/data/chaiy3/visualFreq/seedROI_MNI
cd $seedDir
seedFiles=($(ls *.txt))

# result folder of different stim conditions
cd $subDir/$run
# Create network File Directory only if not Exists
[ ! -d rsfc  ] && mkdir rsfc

# # ======================= calculate occipital-based networks ====================
# cd ${subDir}
# cd ${subDir}/${run}	
# # rm area with high SD in aseg_ROI
# 3dTstat -mask mask_group_epi+tlrc -stdev -prefix SD.errts.${run%.results}.fanaticor \
# 	errts.${run%.results}.fanaticor+tlrc -overwrite
# 3dmaskdump -noijk -mask mask_group_epi+tlrc SD.errts.${run%.results}.fanaticor+tlrc | \
# 	1d_tool.py -show_mmms -infile - > tmp.1D
# tmp=`cat tmp.1D | grep -e 'col' | awk '{print $8}'` 
# mean=${tmp%,}
# stdev=`cat tmp.1D | grep -e 'col' | awk '{print $14}'`
# 3dcalc -a SD.errts.${run%.results}.fanaticor+tlrc -b mask_group_epi+tlrc \
# 	-expr "within(a,0,$mean+2*$stdev)*b" \
# 	-prefix mask.SD.errts.${run%.results}.fanaticor -overwrite

# 3dcalc -a mask.SD.errts.${run%.results}.fanaticor+tlrc -b aseg_func_gm_infl+tlrc -expr "a*b" \
# 	-prefix aseg_func_gm_infl_SDmask -overwrite
# 3drefit -copytables aseg_func_gm_infl+tlrc aseg_func_gm_infl_SDmask+tlrc
# rm tmp.1D
# rm SD*
# rm mask.SD.errts.${run%.results}*

# # "50" "ctx_lh_G_and_S_occipital_inf"
# # "59" "ctx_lh_G_cuneus"
# # "67" "ctx_lh_G_occipital_middle"
# # "68" "ctx_lh_G_occipital_sup"
# # "69" "ctx_lh_G_oc-temp_lat-fusifor"
# # "70" "ctx_lh_G_oc-temp_med-Lingual"
# # "90" "ctx_lh_Pole_occipital"
# # "92" "ctx_lh_S_calcarine"
# # "105" "ctx_lh_S_oc_middle_and_Lunatus"
# # "106" "ctx_lh_S_oc_sup_and_transversal"
# # "107" "ctx_lh_S_occipital_ant"
# # "108" "ctx_lh_S_oc-temp_lat"
# # "109" "ctx_lh_S_oc-temp_med_and_Lingual"
# # "113" "ctx_lh_S_parieto_occipital"
# # "125" "ctx_rh_G_and_S_occipital_inf"
# # "134" "ctx_rh_G_cuneus"
# # "142" "ctx_rh_G_occipital_middle"
# # "143" "ctx_rh_G_occipital_sup"
# # "144" "ctx_rh_G_oc-temp_lat-fusifor"
# # "145" "ctx_rh_G_oc-temp_med-Lingual"
# # "165" "ctx_rh_Pole_occipital"
# # "167" "ctx_rh_S_calcarine"
# # "180" "ctx_rh_S_oc_middle_and_Lunatus"
# # "181" "ctx_rh_S_oc_sup_and_transversal"
# # "182" "ctx_rh_S_occipital_ant"
# # "183" "ctx_rh_S_oc-temp_lat"
# # "184" "ctx_rh_S_oc-temp_med_and_Lingual"
# # "188" "ctx_rh_S_parieto_occipital"

# oc_index=(50 59 67 68 69 70 90 92 105 106 107 108 109 113 125 134 142 143 144 145 165 167 180 181 182 183 184 188)
# for seed_index in ${oc_index[@]}; do		
# {	tmp1=`3dinfo -labeltable aseg_func_gm_infl_SDmask+tlrc | grep -e \"$seed_index\" | awk '{print $2}'`
# 	tmp2=${tmp1%\"}
# 	seed_name=${tmp2#\"}
# 	for seedNM in ${seed_name}_vec; do #  ${seed_name}_mean
# 		if [[ "$seedNM" =~ "mean" ]]; then
# 			# extract time course from ROI
# 			3dmaskave -quiet -mask aseg_func_gm_infl_SDmask+tlrc"<$seed_index..$seed_index>" \
# 				errts.${run%.results}.fanaticor+tlrc > tc_${seedNM}.txt
# 		fi
# 		if [[ "$seedNM" =~ "vec" ]]; then
# 			# extract time course from ROI
# 			3dmaskSVD -vnorm -mask aseg_func_gm_infl_SDmask+tlrc"<$seed_index..$seed_index>" \
# 				errts.${run%.results}.fanaticor+tlrc > tc_${seedNM}.txt
# 		fi			
# 		# calculate connectivity map
# 		3dfim+ -input errts.${run%.results}.fanaticor+tlrc. -mask mask_group_epi+tlrc \
# 			-ideal_file tc_${seedNM}.txt -out Correlation -bucket corr_${seedNM}
# 		# convert correlation to z value
# 		3dcalc -a corr_${seedNM}+tlrc -expr 'log((1+a)/(1-a))/2' -prefix corr_${seedNM}_z
# 		# mv -f network files to the folder of rsfc
# 		mv -f corr_${seedNM}_z+tlrc* rsfc/

# 		rm -f corr_${seedNM}+tlrc*
# 		rm -f tc_${seedNM}.txt
# 	done
# }&
# done
# wait

# # # ======================= calculate thalamus-based networks ====================

# # ===================== calculate thalamus mask ==================================
# # "7" "Left-Thalamus-Proper"
# # "27" "Right-Thalamus-Proper"
# if [ -d ../event.results ]; then
# 	# mask right thalamus
# 	3dcalc -a aseg_func_gm_infl+tlrc -b ../event.results/rThalamus_mask_*+tlrc.HEAD \
# 		-c mask_group_epi+tlrc -expr 'amongst(a,27)*step(b)*step(c)' -prefix rThalamus_masked+tlrc -overwrite
# 	# mask left thalamus
# 	3dcalc -a aseg_func_gm_infl+tlrc -b ../event.results/lThalamus_mask_*+tlrc.HEAD \
# 		-c mask_group_epi+tlrc -expr 'amongst(a,7)*step(b)*step(c)' -prefix lThalamus_masked+tlrc -overwrite
# 	3dcalc -a rThalamus_masked+tlrc -b lThalamus_masked+tlrc -expr 'a+b' \
# 		-prefix Thalamus_masked+tlrc -overwrite
# else
# 	# mask right thalamus
# 	3dcalc -a aseg_func_gm_infl+tlrc -b ../../group.event.results/rThalamus_mask_*+tlrc.HEAD \
# 		-c mask_group_epi+tlrc -expr 'amongst(a,27)*step(b)*step(c)' -prefix rThalamus_masked+tlrc -overwrite
# 	# mask left thalamus
# 	3dcalc -a aseg_func_gm_infl+tlrc -b ../../group.event.results/lThalamus_mask_*+tlrc.HEAD \
# 		-c mask_group_epi+tlrc -expr 'amongst(a,7)*step(b)*step(c)' -prefix lThalamus_masked+tlrc -overwrite
# 	3dcalc -a rThalamus_masked+tlrc -b lThalamus_masked+tlrc -expr 'a+b' \
# 		-prefix Thalamus_masked+tlrc -overwrite
# fi

# mask v1 and vh with aseg_func_V1_Vh+tlrc<1..1>
# 3dcalc -a aseg_func_V1_Vh+tlrc -b ../../group.event.results/01Hz_mask_*+tlrc.HEAD \
# 	-c mask_group_epi+tlrc -expr 'amongst(a,1)*step(b)*step(c)' -prefix v1_masked+tlrc -overwrite
# 3dcalc -a aseg_func_V1_Vh+tlrc -b ../../group.event.results/40Hz_mask_*+tlrc.HEAD \
# 	-c mask_group_epi+tlrc -expr 'amongst(a,2)*step(b)*step(c)' -prefix vh_masked+tlrc -overwrite

3dcalc -a aseg_func_V1_Vh+tlrc -b ../../group.event.results/visual_mask_0001+tlrc.HEAD \
	-c mask_group_epi+tlrc -expr 'amongst(a,1,2)*step(b)*step(c)' -prefix visual_masked+tlrc -overwrite

# 3dcalc -a ../../group.event.results/lfroi_01_vs_h20_h40_mask_0001+tlrc.HEAD \
# 	-b mask_group_epi+tlrc -expr 'step(a)*step(b)' -prefix lfroi_01_vs_h20_h40_masked+tlrc -overwrite

# 3dcalc -a ../../group.event.results/hfroi_01_vs_h20_h40_mask_0002+tlrc.HEAD \
# 	-b mask_group_epi+tlrc -expr 'step(a)*step(b)' -prefix hfroi_01_vs_h20_h40_masked+tlrc -overwrite

# 3dcalc -a ../../group.event.results/lfroi_01_vs_20_mask_0002+tlrc.HEAD \
# 	-b mask_group_epi+tlrc -expr 'step(a)*step(b)' -prefix lfroi_01_vs_20_masked+tlrc -overwrite

# 3dcalc -a ../../group.event.results/hfroi_01_vs_20_mask_0001+tlrc.HEAD \
# 	-b mask_group_epi+tlrc -expr 'step(a)*step(b)' -prefix hfroi_01_vs_20_masked+tlrc -overwrite

# # mask right thalamus connected to 40Hz-ROI
# 3dcalc -a aseg_func_gm_infl+tlrc -b ../../group.results/stats/40Hz_right_mask_*+tlrc.HEAD \
# 	-c mask_group_epi+tlrc -expr 'amongst(a,27)*step(b)*step(c)' -prefix rThalamus_40HzConn_masked+tlrc -overwrite
# # mask left thalamus connected to 40Hz-ROI
# 3dcalc -a aseg_func_gm_infl+tlrc -b ../../group.results/stats/40Hz_left_mask_*+tlrc.HEAD \
# 	-c mask_group_epi+tlrc -expr 'amongst(a,7)*step(b)*step(c)' -prefix lThalamus_40HzConn_masked+tlrc -overwrite
# # mask thalamus connected to 40Hz-ROI
# 3dcalc -a rThalamus_40HzConn_masked+tlrc -b lThalamus_40HzConn_masked+tlrc -expr 'a+b' \
# 	-prefix Thalamus_40HzConn_masked+tlrc -overwrite

# # mask intersection of thalamus connected to 01Hz and 40Hz-ROI
# 3dcalc -a aseg_func_gm_infl+tlrc -b ../../group.results/stats/inters_01Hz_40Hz_frac1+tlrc \
# 	-c mask_group_epi+tlrc -expr 'amongst(a,7,27)*step(b)*step(c)' -prefix Thalamus_inters_01Hz_40Hz_frac1_masked+tlrc -overwrite

# mask thalamus whose correlation with visual mask is significantly modulated
3dcalc -a aseg_func_gm_infl+tlrc -b ../../group.results/stats/Tha_fcs_gm_visual_mask+tlrc \
	-c mask_group_epi+tlrc -expr 'amongst(a,7,27)*step(b)*step(c)' -prefix Tha_fcs_gm_visual_masked+tlrc -overwrite


# for seedNM in lfroi_01_vs_h20_h40 hfroi_01_vs_h20_h40 lfroi_01_vs_20 hfroi_01_vs_20; do #	Thalamus_inters_01Hz_40Hz_frac1
# {	
# 	#  Create network File Directory only if not Exists
# 	[ ! -d rsfc  ] && mkdir rsfc
# 	# extract time course from ROI
# 	# 3dmaskave -quiet -mask ${seedNM}_masked+tlrc errts.${run%.results}.fanaticor+tlrc. \
# 	# 	> tc_${seedNM}.txt
# 	3dmaskSVD -vnorm -mask ${seedNM}_masked+tlrc errts.${run%.results}.fanaticor+tlrc. \
# 		> tc_${seedNM}.txt
# 	# calculate connectivity map
# 	3dfim+ -input errts.${run%.results}.fanaticor+tlrc. -mask mask_group_epi+tlrc \
# 		-ideal_file tc_${seedNM}.txt -out Correlation -bucket corr_${seedNM}
# 	# convert correlation to z value
# 	3dcalc -a corr_${seedNM}+tlrc -expr 'log((1+a)/(1-a))/2' -prefix corr_${seedNM}_z
# 	# mv -f network files to the folder of rsfc
# 	mv -f corr_${seedNM}_z+tlrc* rsfc/
# 	rm -f corr_${seedNM}+tlrc*
# 	rm -f tc_${seedNM}.txt
# }&
# done
# wait

# # ======================= calculate seed-based networks ====================
# for seed in ${seedFiles[@]}; do
# {	seedNM=${seed%.txt}
# 	# create ROI
# 	3dUndump -prefix ${seedNM} -master errts.${run%.results}.fanaticor+tlrc -srad 3 -xyz ${seedDir}/${seed} 
# 	# extract time course from ROI
# 	3dmaskave -quiet -mask ${seedNM}+tlrc errts.${run%.results}.fanaticor+tlrc > tc_${seedNM}.txt
# 	# calculate connectivity map
# 	3dfim+ -input errts.${run%.results}.fanaticor+tlrc -mask mask_group_epi+tlrc \
# 		-ideal_file tc_${seedNM}.txt -out Correlation -bucket corr_${seedNM}
# 	# convert correlation to z value
# 	3dcalc -a corr_${seedNM}+tlrc -expr 'log((1+a)/(1-a))/2' -prefix corr_${seedNM}_z
# 	# mv -f network files to the folder of typical_netw
# 	mv -f corr_${seedNM}_z+tlrc* rsfc/
# 	rm -f corr_${seedNM}+tlrc*
# 	rm -f tc_${seedNM}.txt
# 	[ ! -d seed_roi  ] && mkdir seed_roi
# 	mv -f ${seedNM}+tlrc* seed_roi/
# }&
# done
# wait


# # ======= caculate functional connectivity strength inside visual cortex =========	
# # mask visual cortex
# 3dcalc -a aseg_func_oc_wotha_infl+tlrc -b ../../group.event.results/visual_mask_0001+tlrc \
# 	-c mask_group_epi+tlrc -expr 'step(a-0)*step(b)*step(c)' -prefix visual_masked+tlrc -overwrite

# 3dTcorrMap \
# 	-input errts.${run%.results}.fanaticor+tlrc \
# 	-mask visual_masked+tlrc \
# 	-Cexpr 'step(z)*z' fcs_vs_pos_z \
# 	-overwrite
# # convert correlation to z value
# 3dcalc -a rm.fcs_vs_r0+tlrc -expr 'log((1+a)/(1-a))/2' -prefix fcs_vs_r0_z \
# 	-overwrite

# ==================== calculate fcs between thalamus and gm ====================
for ROI in Tha_fcs_gm_visual; do # lfroi_01_vs_h20_h40 hfroi_01_vs_h20_h40 lfroi_01_vs_20 hfroi_01_vs_20 visual
{
	if [ ! -f fcs_gm_${ROI}_pos_z+tlrc.HEAD ]; then
		echo "++ analyzing $ROI of $subDir/$run ..."
		# extract time course from all voxels in thalamus
		3dmaskdump -noijk -mask ${ROI}_masked+tlrc errts.${run%.results}.fanaticor+tlrc \
			> rm.tc_${ROI}.row.1D
		1dcat rm.tc_${ROI}.row.1D\' > rm.tc_${ROI}.1D
		# ======= caculate functional connectivity strength with thalamus =========
		3dTcorr1D -prefix rm.fcs_gm_${ROI} -mask aseg_func_gm_infl+tlrc  \
			errts.${run%.results}.fanaticor+tlrc rm.tc_${ROI}.1D -overwrite
		rm rm.tc_${ROI}.1D
		rm rm.tc_${ROI}.row.1D

		# convert correlation to z value
		3dcalc -a rm.fcs_gm_${ROI}+tlrc -expr 'log((1+a)/(1-a))/2' \
			-prefix rm.fcs_gm_${ROI}_z -overwrite
		rm rm.fcs_gm_${ROI}+tlrc*

		3dTstat -prefix fcs_gm_${ROI}_z -mean rm.fcs_gm_${ROI}_z+tlrc -overwrite
		# average all z larger than 0
		3dcalc -a rm.fcs_gm_${ROI}_z+tlrc -expr "a*step(a-0)" -prefix rm.fcs_gm_${ROI}_pos_z -overwrite
		# 3dcalc -a rm.fcs_gm_${ROI}_z+tlrc -expr "a*step(-a)" -prefix rm.fcs_gm_${ROI}_neg_z -overwrite
		rm rm.fcs_gm_${ROI}_z+tlrc*

		3dTstat -prefix fcs_gm_${ROI}_pos_z -mean rm.fcs_gm_${ROI}_pos_z+tlrc -overwrite
		rm rm.fcs_gm_${ROI}_pos*
		
		# 3dTstat -prefix fcs_gm_${ROI}_neg_z -mean rm.fcs_gm_${ROI}_neg_z+tlrc -overwrite
		# rm rm.fcs_gm_${ROI}_neg*

		mv -f fcs_gm_${ROI}* rsfc/
	fi
}&
done
wait

# # # ============ caculate correlation between 01Hz and 40Hz stimulation =============
# # if [[ "$run" =~ "01Hz" ]] && [ -d $subDir/conn_40Hz.results ]; then
# # 	3dTcorrelate -prefix -automask tcorr_01_40hz errts.${run%.results}.fanaticor+tlrc \
# # 		$subDir/conn_40Hz.results/errts.conn_40Hz.fanaticor+tlrc -overwrite
# # 	mv -f tcorr_01_40hz+tlrc* rsfc/
# # fi


# # ===== caculate ROI independent connection parameters, local activity of RS ======
# # ======================== REHO ================================================
# 3dReHo -prefix fc_reho -inset errts.${run%.results}.fanaticor+tlrc \
# 	-mask mask_group_epi+tlrc -overwrite

# # normalize reho
# 3dmaskdump -noijk -mask mask_group_epi+tlrc fc_reho+tlrc[ReHo] | \
# 	1d_tool.py -show_mmms -infile - > reho.tmp.1D
# tmp=`cat reho.tmp.1D | grep -e 'col' | awk '{print $8}'` 
# mean=${tmp%,}
# stdev=`cat reho.tmp.1D | grep -e 'col' | awk '{print $14}'`

# 3dcalc \
# 	-a fc_reho+tlrc[ReHo] \
# 	-b mask_group_epi+tlrc \
# 	-expr "b*(a-$mean)/$stdev" \
# 	-prefix fc_reho_norm	\
# 	-overwrite

# rm -f fc_reho+tlrc*
# rm reho.tmp.1D
# mv -f fc_reho_norm* rsfc/

# # # calculate LFFs (i.e., the filtered time series,
# # # here containing frequencies between 0.01-0.1 Hz), ALFF, fALFF,
# # # mALFF, RSFA, fRSFA, and mRSFA.
# # 3dRSFC                          \
# #     -nodetrend                  \
# #     -mask mask_group_epi+tlrc \
# #     -prefix fc      			\
# #     -band 0.01 0.1                    \
# #     -input rsfc.errts.${run%.results}.fanaticor+tlrc   \
# #     -overwrite
# # rm -f fc_LFF*

# # # =========================== ALFF =====================================
# # # normalize ALFF
# # 3dmaskdump -noijk -mask mask_group_epi+tlrc fc_ALFF+tlrc | \
# # 	1d_tool.py -show_mmms -infile - > tmp.1D
# # tmp=`cat tmp.1D | grep -e 'col' | awk '{print $8}'` 
# # mean=${tmp%,}
# # stdev=`cat tmp.1D | grep -e 'col' | awk '{print $14}'`

# # 3dcalc \
# # 	-a fc_ALFF+tlrc \
# # 	-b mask_group_epi+tlrc \
# # 	-expr "b*(a-$mean)/$stdev" \
# # 	-prefix fc_ALFF_norm	\
# # 	-overwrite
# # rm -f fc_ALFF+tlrc*

# # # =========================== fALFF ===================================
# # # normalize fALFF
# # 3dmaskdump -noijk -mask mask_group_epi+tlrc fc_fALFF+tlrc | \
# # 	1d_tool.py -show_mmms -infile - > tmp.1D
# # tmp=`cat tmp.1D | grep -e 'col' | awk '{print $8}'` 
# # mean=${tmp%,}
# # stdev=`cat tmp.1D | grep -e 'col' | awk '{print $14}'`

# # 3dcalc \
# # 	-a fc_fALFF+tlrc \
# # 	-b mask_group_epi+tlrc \
# # 	-expr "b*(a-$mean)/$stdev" \
# # 	-prefix fc_fALFF_norm	\
# # 	-overwrite
# # rm -f fc_fALFF+tlrc*

# # # ========================== mALFF ====================================
# # # normalize mALFF
# # 3dmaskdump -noijk -mask mask_group_epi+tlrc fc_mALFF+tlrc | \
# # 	1d_tool.py -show_mmms -infile - > tmp.1D
# # tmp=`cat tmp.1D | grep -e 'col' | awk '{print $8}'` 
# # mean=${tmp%,}
# # stdev=`cat tmp.1D | grep -e 'col' | awk '{print $14}'`

# # 3dcalc \
# # 	-a fc_mALFF+tlrc \
# # 	-b mask_group_epi+tlrc \
# # 	-expr "b*(a-$mean)/$stdev" \
# # 	-prefix fc_mALFF_norm	\
# # 	-overwrite
# # rm -f fc_mALFF+tlrc*

# # ======== caculate functional connectivity strength inside gray matter ======
# 3dTcorrMap \
# 	-input errts.${run%.results}.fanaticor+tlrc \
# 	-mask aseg_func_gm_infl+tlrc \
# 	-Cexpr 'step(z)*z' fcs_wt_cerebellum_pos_z \
# 	-overwrite &

# wait
# mv -f fcs_wt_cerebellum_pos_z* rsfc/

# # 3dTcorrMap \
# # 	-input errts.${run%.results}.fanaticor+tlrc \
# # 	-mask aseg_func_gm_infl+tlrc \
# # 	-Cexpr 'step(-r-0.1)*r' rm.fcs_wt_cerebellum_rn0.1 \
# # 	-overwrite &

# # wait

# # 3dcalc -a rm.fcs_wt_cerebellum_r0+tlrc -expr 'log((1+a)/(1-a))/2' \
# # 	-prefix fcs_wt_cerebellum_r0_z -overwrite

# # 3dcalc -a rm.fcs_wt_cerebellum_rn0.1+tlrc -expr 'log((1+a)/(1-a))/2' \
# # 	-prefix fcs_wt_cerebellum_rn0.1_z -overwrite

# # 3dTcorrMap \
# # 	-input errts.${run%.results}.fanaticor+tlrc \
# # 	-mask aseg_func_gm_infl+tlrc \
# # 	-Cexpr 'step(-z)*z' fcs_neg_wt_cerebellum_z &

# # 3dTcorrMap \
# # 	-input errts.${run%.results}.fanaticor+tlrc \
# # 	-mask aseg_func_cerebrum_infl+tlrc \
# # 	-Cexpr 'step(z)*z' fcs_pos_wo_cerebellum_z &

# # 3dTcorrMap \
# # 	-input errts.${run%.results}.fanaticor+tlrc \
# # 	-mask aseg_func_cerebrum_infl+tlrc \
# # 	-Cexpr 'step(-z)*z' fcs_neg_wo_cerebellum_z &

