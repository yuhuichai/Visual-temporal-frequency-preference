#!/bin/bash
module load afni
dataDir=/data/chaiy3/visualFreq/170322Sub009/Eccentricity
cd ${dataDir}

# 3dSkullStrip -push_to_edge -input anat*nii -prefix brain+orig -overwrite

# # ================================== tlrc ==================================
# # warp anatomy to standard space (non-linear warp)
# auto_warp.py -base MNI152_1mm_uni+tlrc -input brain+orig \
#              -skull_strip_input no

# move results up out of the awpy directory
# (NL-warped anat, affine warp, NL warp)
# (use typical standard space name for anat)
# (wildcard is a cheap way to go after any .gz)
# 3dbucket -prefix brain awpy/brain.aw.nii*
# mv awpy/anat.un.aff.Xat.1D .
# mv awpy/anat.un.aff.qw_WARP.nii .

# # verify that we have a +tlrc warp dataset
# if ( ! -f brain+tlrc.HEAD ) then
#     echo "** missing +tlrc warp dataset: brain+tlrc.HEAD" 
#     exit
# endif

# for tomni in eccentricity r2 v1; do
# {    3dNwarpApply -source ${tomni}+orig                                  \
#                -master brain+tlrc                                \
#                -ainterp NN -nwarp anat.un.aff.qw_WARP.nii anat.un.aff.Xat.1D \
#                -prefix ${tomni} -overwrite
# }&
# done
# wait

3dcalc -a eccentricity+tlrc -b r2+tlrc \
    -expr "a*step(10-a)*step(b-0.1)" -prefix eccentricity_lt10_r0.1 \
    -overwrite

3dresample -master eccentricity+tlrc \
    -inset ../event.results/freqmap_diffexp_orig_pass0.beta.freqmap+tlrc \
    -prefix freqmap_resamp -overwrite