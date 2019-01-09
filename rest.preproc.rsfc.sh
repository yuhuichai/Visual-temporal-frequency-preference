#!/usr/bin/env tcsh

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

# run afni_proc.py to create a single subject processing script # motion censor use o.5 for Sub007
afni_proc.py -subj_id ${subj}_rsfc                                      \
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
        -align_opts_aea -cost lpc+ZZ                                   \
        -tlrc_base TT_N27+tlrc                                  \
        -tlrc_NL_warp                                            \
        -volreg_align_to MIN_OUTLIER                             \
        -volreg_align_e2a                                        \
        -volreg_tlrc_warp                                        \
        -blur_size 5.0                                           \
        -regress_stim_times $top_dir/Stim/${subj}_dis${distr}TR.txt   \
        -regress_stim_labels ${subj}                            \
        -regress_basis GAM                                      \
        -regress_reml_exec                                      \
        -regress_ROI_PC vent 3                                 \
        -regress_make_corr_vols aeseg vent                     \
        -regress_anaticor_fast                                   \
        -regress_anaticor_label WM                             \
        -regress_apply_mot_types demean deriv                    \
        -regress_est_blur_epits                                  \
        -regress_est_blur_errts                                  \
        -regress_RSFC -regress_bandpass 0.01 0.1                \
        -regress_run_clustsim no

# tcsh $top_dir/proc.$subj |& tee $top_dir/output.proc.$subj
# mv $top_dir/proc.$subj $top_dir/${subj}.results/
# mv $top_dir/output.proc.$subj $top_dir/${subj}.results/
# mv $top_dir/output.$subj $top_dir/${subj}.results/