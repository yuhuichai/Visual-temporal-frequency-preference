#!/usr/bin/env tcsh
module load afni

# ------------------------------------------------------------
# ------------ pretend this is resting state data ------------
#
# apply Example 11 from "afni_proc.py -help"
# This is considered to be a very modern example.
# Just process one run.
# ------------------------------------------------------------

set top_dir   = $argv[1] #/Users/chaiy3/Data/visualFreq/170125Sub001
set sdir      = $top_dir/Surf/surf/SUMA
set subj      = $argv[2]
set distr     = 15

# if ( ${top_dir} =~ *Sub007* ) then
#         set motion_limit = 0.5
# else if ( ${top_dir} =~ *Sub014* ) then
#         set motion_limit = 0.35
# else if ( ${top_dir} =~ *Sub015* ) then
#         set motion_limit = 0.35
# else 
#         set motion_limit = 0.2
# endif

set motion_limit = 0.3

# run afni_proc.py to create a single subject processing script
afni_proc.py -subj_id $subj                                      \
        -out_dir $top_dir/${subj}.results                         \
        -script $top_dir/proc.$subj -scr_overwrite                \
        -blocks despike tshift align tlrc volreg blur mask regress \
        -copy_anat $sdir/brain.nii                                 \
        -anat_has_skull no                                         \
        -anat_follower_ROI aaseg anat $sdir/aparc.a2009s+aseg_REN_gm.nii \
        -anat_follower_ROI aeseg epi  $sdir/aparc.a2009s+aseg_REN_gm.nii \
        -anat_follower_ROI vent epi $sdir/SUMA_vent.nii          \
        -anat_follower_ROI WM epi $sdir/SUMA_WM.nii           \
        -anat_follower_erode vent WM                          \
        -dsets $top_dir/Func/${subj}.nii.gz                      \
        -tcat_remove_first_trs ${distr}                          \
        -align_opts_aea -giant_move -cost lpc+ZZ                 \
        -tlrc_base MNI152_1mm_uni+tlrc                           \
        -tlrc_NL_warp                                            \
        -volreg_align_to MIN_OUTLIER                             \
        -volreg_align_e2a                                        \
        -volreg_tlrc_warp                                        \
        -blur_size 4.0                                           \
        -regress_stim_times $top_dir/Stim/${subj}_dis${distr}TR.txt   \
        -regress_stim_labels ${subj}                            \
        -regress_basis GAM                                      \
        -regress_reml_exec                                      \
        -regress_ROI_PC vent 3                                 \
        -regress_make_corr_vols aeseg vent                     \
        -regress_anaticor_fast                                   \
        -regress_anaticor_label WM                             \
        -regress_censor_motion ${motion_limit}                               \
        -regress_censor_outliers 0.1                             \
        -regress_apply_mot_types demean deriv                    \
        -regress_est_blur_epits                                  \
        -regress_est_blur_errts                                  \
        -regress_run_clustsim no

tcsh $top_dir/proc.$subj |& tee $top_dir/output.proc.$subj
mv $top_dir/proc.$subj $top_dir/${subj}.results/
mv $top_dir/output.proc.$subj $top_dir/${subj}.results/
mv $top_dir/output.$subj $top_dir/${subj}.results/