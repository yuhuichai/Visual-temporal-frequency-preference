#!/bin/sh
# inflate surface/freesurfer rois in volume space
module load afni

dataDir=/data/chaiy3/visualFreq
batchDir=/data/chaiy3/visualFreq/batch

cd ${dataDir}
for patID in *Sub*; do
{	patDir=$dataDir/$patID
	sumaDir=$patDir/Surf/surf/SUMA

	cd $patDir
	for subj_results in event.results; do # a few subjs have no event.results, ignore the error message for this
	{	subj=${subj_results%.results}
		cd $patDir/$subj_results

		# # transform asseg into tlrc space through warp operations
		# for matter in gm csf vent; do
		# 	3dNwarpApply -source ${sumaDir}/aparc.a2009s+aseg_REN_${matter}.nii.gz                                   \
		# 	             -master anat_final.$subj+tlrc                                \
		# 	             -ainterp NN -nwarp anat.un.aff.qw_WARP.nii anat.un.aff.Xat.1D\
		# 	             -prefix aseg_anat_${matter} -overwrite

		# 	3dNwarpApply -source ${sumaDir}/aparc.a2009s+aseg_REN_${matter}.nii.gz                                   \
		# 	             -master $(ls pb0*.r01.volreg+tlrc.HEAD)                                \
		# 	             -ainterp NN -nwarp anat.un.aff.qw_WARP.nii anat.un.aff.Xat.1D\
		# 	             -prefix aseg_func_${matter} -overwrite

		# 	3drefit -copytables ${sumaDir}/aparc.a2009s+aseg_REN_${matter}.nii.gz aseg_anat_${matter}+tlrc
		# 	3drefit -copytables ${sumaDir}/aparc.a2009s+aseg_REN_${matter}.nii.gz aseg_func_${matter}+tlrc
		# done

		# # inflate aseg, output aseg_func_gm_infl+tlrc
		# tcsh ${batchDir}/aseg_inflate.tcsh 3 anat
		# tcsh ${batchDir}/aseg_inflate.tcsh 2 func
		# # labeltable info can be checked with: 3dinfo -labeltable follow_ROI_aeseg+tlrc.

		# # apply mask
		# # combine anatomic and epi mask
		# 3dcalc -a mask_group+tlrc -b full_mask.${subj}+tlrc -c TSNR.${subj}+tlrc -expr 'a*b*step(c-50)' \
		# 	-prefix mask_group_epi -overwrite
		# 3dcalc -a aseg_func_gm_infl+tlrc -b mask_group_epi+tlrc -expr 'a*b' -prefix aseg_func_gm_infl+tlrc \
		# 	-overwrite
		# 3drefit -copytables ${sumaDir}/aparc.a2009s+aseg_REN_gm.nii.gz aseg_func_gm_infl+tlrc

		# transform visual atlas into tlrc space through warp operations
		for atlas in atlas.visual.nii.gz native.template_areas.nii.gz native.wang2015_atlas.nii.gz; do
			3dNwarpApply -source ${sumaDir}/${atlas}                                   \
			             -master $(ls pb0*.r01.volreg+tlrc.HEAD)                                \
			             -ainterp NN -nwarp anat.un.aff.qw_WARP.nii anat.un.aff.Xat.1D\
			             -prefix ${atlas#native.} -overwrite

			atlas_infl=${atlas#native.}
			atlas_infl=${atlas_infl%.nii.gz}.infl
			# does inflation
			3dROIMaker -inflate 1 -refset ${atlas#native.} -inset  ${atlas#native.} \
			    -skel_stop -prefix ${atlas_infl} -overwrite

			3dcalc -a aseg_func_gm_infl+tlrc -b ${atlas_infl}_GMI+tlrc -expr 'step(a)*b' \
				-prefix ${atlas_infl} -overwrite

			rm ${atlas_infl}_GM*
		done
		3dcalc -a wang2015_atlas.infl+tlrc \
			-expr "1*amongst(a,1,2)+2*amongst(a,3,4)+3*amongst(a,5,6,16,17)+4*amongst(a,7)+5*amongst(a,13)" \
			-prefix visual_atlas_wang2015.infl+tlrc -overwrite
		rm wang2015*

		3dcopy template_areas.infl+tlrc visual_atlas_benson2014.infl
		rm template_areas*

		3dcalc -a atlas.visual.infl+tlrc \
			-expr "1*amongst(a,1)+2*amongst(a,2)+5*amongst(a,3)" \
			-prefix visual_atlas_fs.infl+tlrc -overwrite
		rm atlas.visual*

		# # extract occipital regions of following
		# # "7" "Left-Thalamus-Proper"
		# # "27" "Right-Thalamus-Proper"
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
		# # 3dcalc -a aseg_anat_gm_infl+tlrc -expr 'a*(amongst(a,7,27,50,59,67,68,69,70,90,92,105,106,107,108,109,113,125)
		# # 	+amongst(a,134,142,143,144,145,165,167,180,181,182,183,184,188))' \
		# # 	-prefix aseg_anat_oc_infl+tlrc -overwrite
		# 3dcalc -a aseg_func_gm_infl+tlrc -expr 'a*(amongst(a,7,27,50,59,67,68,69,70,90,92,105,106,107,108,109,113,125)
		# 	+amongst(a,134,142,143,144,145,165,167,180,181,182,183,184,188))' \
		# 	-prefix aseg_func_oc_infl+tlrc -overwrite
		# # copy labeltable
		# # 3drefit -copytables aseg_anat_gm_infl+tlrc aseg_anat_oc_infl+tlrc
		# 3drefit -copytables aseg_func_gm_infl+tlrc aseg_func_oc_infl+tlrc

		# # create occipital mask without thalamus
		# 3dcalc -a aseg_func_gm_infl+tlrc -expr 'a*(amongst(a,50,59,67,68,69,70,90,92,105,106,107,108,109,113,125)
		# 	+amongst(a,134,142,143,144,145,165,167,180,181,182,183,184,188))' \
		# 	-prefix aseg_func_oc_wotha_infl+tlrc -overwrite		
		# # copy labeltable
		# 3drefit -copytables aseg_func_gm_infl+tlrc aseg_func_oc_wotha_infl+tlrc

		# # create calcarine and higher-level visual mask
		# 3dcalc -a aseg_func_gm_infl+tlrc -expr 'amongst(a,92,167)+2*(amongst(a,50,59,67,68,69,70,90,105,106,107,108,109,113,125)
		# 	+amongst(a,134,142,143,144,145,165,180,181,182,183,184,188))' \
		# 	-prefix aseg_func_V1_Vh+tlrc -overwrite		
		# # copy labeltable
		# 3drefit -copytables aseg_func_gm_infl+tlrc aseg_func_V1_Vh+tlrc

		# # rm cerebellar
		# 3dcalc -a aseg_func_gm_infl+tlrc -expr 'a*not(amongst(a,6,26))' \
		# 	-prefix aseg_func_cerebrum_infl+tlrc -overwrite
		# # copy labeltable
		# 3drefit -copytables aseg_anat_gm_infl+tlrc aseg_func_cerebrum_infl+tlrc
	}
	done
}&
done
wait

