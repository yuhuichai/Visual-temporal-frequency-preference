#!/bin/sh
module load freesurfer afni
source $FREESURFER_HOME//SetUpFreeSurfer.sh
#fsl data directory
dataDIR=/data/chaiy3/visualFreq
cd ${dataDIR}
subj_list=($(ls -d *Sub*))
subj_num=${#subj_list[@]}
echo "********************* ${subj_num} subjects to analyze **********************"
 
#makes the orient file
for i in `seq 0 7 $subj_num`; do
{	for patID in ${subj_list[@]:$i:7}; do
	{	
		echo "***************************** start with ${patID} *********************"
		patDIR=${dataDIR}/${patID}
		cd ${patDIR}
		# # tar -zcvf dicom.tar.gz Dicom
		# 3dUnifize -input Anat/mp2rage.nii.gz -prefix Anat/mp2rage_uni.nii.gz -overwrite
		# export SUBJECTS_DIR=${patDIR}
		# recon-all -i Anat/mp2rage_uni.nii.gz -subjid Surf -all -openmp 10 # continue with -autorecon3
		# recon-all -s Surf -ba-labels -no-isrunning
		# wait

		# [ ! -d fsaverage_sym ] && cp -r ../fsaverage_sym ./
		# # Invert the right hemisphere
		# xhemireg --s Surf
		# # Register the left hemisphere to fsaverage_sym
		# surfreg --s Surf --t fsaverage_sym --lh
		# # Register the inverted right hemisphere to fsaverage_sym
		# surfreg --s Surf --t fsaverage_sym --lh --xhemi

		# docker run -ti --rm -v ${patDIR}/Surf:/input nben/occipital_atlas

		mri_convert Surf/mri/native.template_angle.mgz Surf/surf/SUMA/native.template_angle.nii.gz
		mri_convert Surf/mri/native.template_eccen.mgz Surf/surf/SUMA/native.template_eccen.nii.gz
		mri_convert Surf/mri/native.template_areas.mgz Surf/surf/SUMA/native.template_areas.nii.gz
		mri_convert Surf/mri/native.wang2015_atlas.mgz Surf/surf/SUMA/native.wang2015_atlas.nii.gz

		# # # convert freesurfer files for AFNI use
		# # @SUMA_Make_Spec_FS -fspath Surf/surf -sid SUMA -NIFTI

		# # convert label to ROI.nii.gz
		# # Label files
		# mri_label2vol \
		# 	--label Surf/label/lh.V1_exvivo.thresh.label \
		# 	--label Surf/label/lh.V2_exvivo.thresh.label \
		# 	--label Surf/label/lh.MT_exvivo.thresh.label \
		# 	--subject Surf --identity --temp Surf/mri/T1.mgz \
		# 	--hemi lh --proj frac 0 1 0.01 \
		# 	--o Surf/surf/SUMA/visual.lh.nii.gz

		# mri_label2vol \
		# 	--label Surf/label/rh.V1_exvivo.thresh.label \
		# 	--label Surf/label/rh.V2_exvivo.thresh.label \
		# 	--label Surf/label/rh.MT_exvivo.thresh.label \
		# 	--subject Surf --identity --temp Surf/mri/T1.mgz \
		# 	--hemi rh --proj frac 0 1 0.01 \
		# 	--o Surf/surf/SUMA/visual.rh.nii.gz

		# # create ventricle and white matter masks
		# cd Surf/surf/SUMA
	 # #    3dcalc -a aparc+aseg.nii -datum byte -prefix SUMA_vent.nii \
	 # #           -expr 'amongst(a,4,43)'
	 # #    3dcalc -a aparc+aseg.nii -datum byte -prefix SUMA_WM.nii \
	 # #           -expr 'amongst(a,2,7,41,46,251,252,253,254,255)'	

	 # 	3dcalc -a visual.lh.nii.gz -b visual.rh.nii.gz \
	 # 		-expr "a+b" -prefix atlas.visual.nii.gz -overwrite

	 # 	rm visual.*h.nii.gz

	}&
	done
	wait
}&
done
wait
