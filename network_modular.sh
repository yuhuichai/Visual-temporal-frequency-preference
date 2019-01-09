#!/bin/sh
module load afni R
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq

cd ${dataDir}

sub_list=`ls *Sub*/conn*.results/aseg_func_subc+tlrc.HEAD`
3dmask_tool -prefix Yeo_JNeurophysiol11_MNI152/aseg_func_subc \
	-frac 0.6 -input \
	$sub_list -overwrite

sub_list=`ls *Sub*/conn*.results/aseg_func_gm_infl+tlrc.HEAD`
cd Yeo_JNeurophysiol11_MNI152
let "s = 1"
for subj in ${sub_list[@]}; do
	echo subj $s for $subj
	3dcalc -a ../${subj} -expr "amongst(a,6,26)" \
		-prefix cerebellum_${s} -overwrite
	let "s += 1"
done

3dmask_tool -prefix cerebellum \
	-frac 0.6 -input \
	cerebellum_*+tlrc.HEAD -overwrite

rm cerebellum_*

3dresample -master aseg_func_subc+tlrc \
	-input Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz \
	-prefix Yeo_7Networks_resample \
	-overwrite

3dcalc -a Yeo_7Networks_resample+tlrc \
	-b aseg_func_subc+tlrc \
	-c cerebellum+tlrc \
	-expr "a+(8*b+9*c)*iszero(a)" \
	-prefix network_modules \
	-overwrite

3dROIMaker -inflate 1 \
	-refset network_modules+tlrc. \
	-inset network_modules+tlrc. \
	-skel_stop \
	-prefix network_modules_inflate \
	-overwrite

rm *GM+tlrc*
rm *niml*
rm aseg_func_subc*
rm cerebellum*
rm Yeo_7Networks_resample*


