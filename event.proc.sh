#!/usr/bin/env tcsh
# processing block designed data, generating activity at different stimulation frequencies
# for some subjects, data of 60 Hz stimulation is also acquired
module load afni

# created by uber_subject.py: version 0.39 (March 21, 2016)
# creation date: Mon Jan 23 12:21:21 2017

# set data directories
set top_dir   = $argv[1] # /Users/chaiy3/Data/visualFreq/170201Sub002
set sdir      = $top_dir/Surf/surf/SUMA
set distr     = 8
set subj      = event

if ( ${top_dir} =~ *Sub007* ) then
        set motion_limit = 0.8
        set epi_dsets = "$top_dir/Func/event_iso1.nii.gz $top_dir/Func/event_iso2.nii.gz"
else 
        set motion_limit = 0.3
        set epi_dsets = "$top_dir/Func/event_iso1.nii.gz $top_dir/Func/event_iso2.nii.gz $top_dir/Func/event_iso3.nii.gz"
endif

# run afni_proc.py to create a single subject processing script # motion censor 0.3
afni_proc.py -subj_id $subj                                           \
        -out_dir $top_dir/${subj}.results                               \
        -script $top_dir/proc.$subj -scr_overwrite                    \
        -blocks tshift align tlrc volreg blur mask scale regress      \
        -copy_anat $sdir/brain.nii                                    \
        -anat_has_skull no                                            \
        # -anat_follower_ROI aaseg anat $sdir/aparc.a2009s+aseg_REN_gm.nii \
        # -anat_follower_ROI aeseg epi  $sdir/aparc.a2009s+aseg_REN_gm.nii \
        -tcat_remove_first_trs ${distr}                               \
        -dsets                                                        \
            ${epi_dsets}                                                \
        -align_opts_aea -giant_move -cost lpc+ZZ                                   \
        -tlrc_base MNI152_1mm_uni+tlrc                                  \
        -tlrc_NL_warp                                            \
        -volreg_align_to MIN_OUTLIER                                  \
        -volreg_align_e2a                                             \
        -volreg_tlrc_warp                                                 \
        -blur_size 4.0                                                    \
        -regress_stim_times                                               \
            $top_dir/Stim/event_01Hz_dis${distr}TR.txt                      \
            $top_dir/Stim/event_05Hz_dis${distr}TR.txt                      \
            $top_dir/Stim/event_10Hz_dis${distr}TR.txt                      \
            $top_dir/Stim/event_15Hz_dis${distr}TR.txt                      \
            $top_dir/Stim/event_20Hz_dis${distr}TR.txt                      \
            $top_dir/Stim/event_40Hz_dis${distr}TR.txt                      \
            $top_dir/Stim/event_60Hz_dis${distr}TR.txt                      \
            $top_dir/Stim/event_vigilance_dis${distr}TR.txt                \
        -regress_stim_labels                                              \
            vs01Hz vs05Hz vs10Hz vs15Hz vs20Hz vs40Hz vs60Hz vigilance    \
        -regress_basis_multi                                              \
            'BLOCK(10,1)' 'BLOCK(10,1)' 'BLOCK(10,1)' 'BLOCK(10,1)'         \
            'BLOCK(10,1)' 'BLOCK(10,1)' 'BLOCK(10,1)' 'GAM'                 \
        -regress_censor_motion ${motion_limit}                                        \
        -regress_censor_outliers 0.1                                   \
        -regress_opts_3dD                                                 \
            -jobs 3                                                       \
            -num_glt 6                                                  \
            -gltsym 'SYM: 0.2*vs01Hz +0.2*vs05Hz +0.2*vs10Hz +0.2*vs15Hz +0.2*vs20Hz' \
            -glt_label 1 mean_vs01to20Hz                                              \
            -gltsym 'SYM: 0.5*vs40Hz +0.5*vs60Hz'                                     \
            -glt_label 2 mean_vs40to60Hz                                              \
            -gltsym 'SYM: vs01Hz -vs40Hz'                                              \
            -glt_label 3 mean_vs01_vs_mean_vs40Hz                             \
            -gltsym 'SYM: 0.25*vs01Hz +0.25*vs05Hz +0.25*vs10Hz +0.25*vs15Hz'         \
            -glt_label 4 mean_vs01to15Hz                                              \
            -gltsym 'SYM: 0.333*vs01Hz +0.333*vs05Hz +0.333*vs10Hz'                   \
            -glt_label 5 mean_vs01to10Hz                                              \
            -gltsym 'SYM: 0.5*vs05Hz +0.5*vs10Hz'                                     \
            -glt_label 6 mean_vs05to10Hz                                              \
        -regress_reml_exec                                             \
        -regress_make_ideal_sum sum_ideal.1D                              \
        -regress_est_blur_epits                                           \
        -regress_est_blur_errts                                             \
        -regress_make_cbucket yes                                  

tcsh $top_dir/proc.$subj |& tee $top_dir/output.proc.$subj
mv $top_dir/proc.$subj $top_dir/${subj}.results/
mv $top_dir/output.proc.$subj $top_dir/${subj}.results/
mv $top_dir/output.$subj $top_dir/${subj}.results/