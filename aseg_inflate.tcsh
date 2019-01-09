#!/bin/tcsh

# inflate some freesurfer GM rois, but *not* into CSF or vent
# v1.0
# written by PA Taylor

# REN_gm rm following from REN_all
# "1" "Left-Cerebral-White-Matter"
# "2" "Left-Lateral-Ventricle"
# "3" "Left-Inf-Lat-Vent"
# "4" "Left-Cerebellum-White-Matter"
# "10" "3rd-Ventricle"
# "11" "4th-Ventricle"
# "15" "CSF"
# "18" "Left-vessel"
# "19" "Left-choroid-plexus"
# "20" "Right-Cerebral-White-Matter"
# "21" "Right-Lateral-Ventricle"
# "22" "Right-Inf-Lat-Vent"
# "23" "Right-Cerebellum-White-Matter"
# "33" "Right-vessel"
# "34" "Right-choroid-plexus"
# "35" "5th-Ventricle"
# "36" "WM-hypointensities"
# "37" "non-WM-hypointensities"
# "38" "Optic-Chiasm"
# "39" "CC_Posterior"
# "40" "CC_Mid_Posterior"
# "41" "CC_Central"
# "42" "CC_Mid_Anterior"
# "43" "CC_Anterior"
# "44" "ctx-lh-unknown"
# "45" "ctx-rh-unknown"
# "46" "ctx_lh_Unknown"
# "121" "ctx_rh_Unknown"


set infl_size  = $argv[1]
set img  = $argv[2] # anat or func
set mygm  = aseg_${img}_gm+tlrc
set gm_infl = aseg_${img}_gm_infl+tlrc
set subc = aseg_${img}_subc+tlrc

# avoid inflate to the following regions
set mycsf   = aseg_${img}_csf+tlrc
set myvent  = aseg_${img}_vent+tlrc
# set ok_mask = "mask_region_toinflate.nii.gz"

# inflat aseg of following regions
set to_infl_aseg = "to_infl_aseg.nii.gz"
# don't inflat aseg of following regions
set noinfl_aseg_mask = "noinfl_aseg_mask.nii.gz"
# index range of aseg regions not to inflate
set noinfl_index_min = 3
set noinfl_index_max = 48

# makes mask of subcortical regions to "cut away"
# to avoid inflat aseg of index betw
# cerebellum need to be inflated
3dcalc \
    -overwrite \
    -a $mygm \
    -expr "within(a,${noinfl_index_min},${noinfl_index_max})-amongst(a,5,6,25,26)" \
    -prefix $noinfl_aseg_mask

# need ok_mask if use file of REN_all
# 3dcalc \
#     -overwrite \
#     -a $mygm \
#     -b $mycsf \
#     -c $myvent \
#     -expr "step(a)*not(b)*not(c)" \
#     -prefix $ok_mask


# inflate following aseg
3dcalc \
    -overwrite \
    -a $mygm \
    -b $noinfl_aseg_mask \
    -expr "a*not(b)" \
    -prefix $to_infl_aseg

# does inflation
3dROIMaker \
    -overwrite \
    # -nifti \
    -inflate $infl_size \
    # -mask $ok_mask \
    -refset $to_infl_aseg \
    -inset  $to_infl_aseg \
    -csf_skel $noinfl_aseg_mask \
    -skel_stop \
    -prefix $gm_infl

# combine the inflated cortical regions with uninflated subcortical regions
3dcalc \
    -overwrite \
    -a ${gm_infl} \
    -b $mygm \
    -c $noinfl_aseg_mask \
    -expr "a*not(c)+b*c" \
    -prefix $gm_infl

3drefit -copytables $mygm $gm_infl

# extract uninflated subcortical regions
3dcalc \
    -overwrite \
    -a $mygm \
    -b $noinfl_aseg_mask \
    -expr "a*b" \
    -prefix $subc

3drefit -copytables $mygm $subc

rm -f *GM*
rm -f $to_infl_aseg
rm -f $noinfl_aseg_mask