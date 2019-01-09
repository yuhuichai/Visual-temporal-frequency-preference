#!/usr/bin/env tcsh
module load afni

# created by uber_subject.py: version 0.39 (March 21, 2016)
# creation date: Mon Jan 23 12:21:21 2017

# set data directories
set data_dir  = $argv[1]
set run_num   = $argv[2]
set subj      = event

cd ${data_dir}

# ------------------------------
# run the regression analysis
3dDeconvolve -input pb04.$subj.r*.scale+tlrc.HEAD                             \
    -censor censor_${subj}_combined_2.1D                                      \
    -polort 5                                                                 \
    -num_stimts 22                                                            \
    -stim_times 1 stimuli/event_01Hz_dis8TR.txt 'BLOCK(10,1)'                 \
    -stim_label 1 vs01Hz                                                      \
    -stim_times 2 stimuli/event_05Hz_dis8TR.txt 'BLOCK(10,1)'                 \
    -stim_label 2 vs05Hz                                                      \
    -stim_times 3 stimuli/event_10Hz_dis8TR.txt 'BLOCK(10,1)'                 \
    -stim_label 3 vs10Hz                                                      \
    -stim_times 4 stimuli/event_20Hz_dis8TR.txt 'BLOCK(10,1)'                 \
    -stim_label 4 vs20Hz                                                      \
    -stim_times 5 stimuli/event_40Hz_dis8TR.txt 'BLOCK(10,1)'                 \
    -stim_label 5 vs40Hz                                                      \
    -stim_times 6 stimuli/event_vigilance_dis8TR.txt 'GAM'                    \
    -stim_label 6 vigilance                                                   \
    -stim_times 7 stimuli/event_01Hz_dis8TR_onset.txt 'GAM'                 \
    -stim_label 7 vs01Hz_onset                                                      \
    -stim_times 8 stimuli/event_05Hz_dis8TR_onset.txt 'GAM'                 \
    -stim_label 8 vs05Hz_onset                                                      \
    -stim_times 9 stimuli/event_10Hz_dis8TR_onset.txt 'GAM'                 \
    -stim_label 9 vs10Hz_onset                                                      \
    -stim_times 10 stimuli/event_20Hz_dis8TR_onset.txt 'GAM'                 \
    -stim_label 10 vs20Hz_onset                                                      \
    -stim_times 11 stimuli/event_40Hz_dis8TR_onset.txt 'GAM'                 \
    -stim_label 11 vs40Hz_onset                                                      \
    -stim_times 12 stimuli/event_01Hz_dis8TR_offset.txt 'GAM'                 \
    -stim_label 12 vs01Hz_offset                                                      \
    -stim_times 13 stimuli/event_05Hz_dis8TR_offset.txt 'GAM'                 \
    -stim_label 13 vs05Hz_offset                                                      \
    -stim_times 14 stimuli/event_10Hz_dis8TR_offset.txt 'GAM'                 \
    -stim_label 14 vs10Hz_offset                                                      \
    -stim_times 15 stimuli/event_20Hz_dis8TR_offset.txt 'GAM'                 \
    -stim_label 15 vs20Hz_offset                                                      \
    -stim_times 16 stimuli/event_40Hz_dis8TR_offset.txt 'GAM'                 \
    -stim_label 16 vs40Hz_offset                                                      \
    -stim_file 17 motion_demean.1D'[0]' -stim_base 17 -stim_label 17 roll        \
    -stim_file 18 motion_demean.1D'[1]' -stim_base 18 -stim_label 18 pitch    \
    -stim_file 19 motion_demean.1D'[2]' -stim_base 19 -stim_label 19 yaw      \
    -stim_file 20 motion_demean.1D'[3]' -stim_base 20 -stim_label 20 dS       \
    -stim_file 21 motion_demean.1D'[4]' -stim_base 21 -stim_label 21 dL       \
    -stim_file 22 motion_demean.1D'[5]' -stim_base 22 -stim_label 22 dP       \
    -jobs 4                                                                   \
    -num_glt 11                                                               \
    -gltsym 'SYM: vs05Hz +vs10Hz +vs20Hz'                                             \
    -glt_label 1 mean_vs05Hz_10Hz_20Hz                                    \
    -gltsym 'SYM: vs01Hz_onset +vs01Hz_offset'                                             \
    -glt_label 2 transient_vs01Hz                                     \
    -gltsym 'SYM: vs05Hz_onset +vs05Hz_offset'                                             \
    -glt_label 3 transient_vs05Hz                                     \
    -gltsym 'SYM: vs10Hz_onset +vs10Hz_offset'  \
    -glt_label 4 transient_vs10Hz                                     \
    -gltsym 'SYM: vs20Hz_onset +vs20Hz_offset'                                             \
    -glt_label 5 transient_vs20Hz                                    \
    -gltsym 'SYM: vs40Hz_onset +vs40Hz_offset'                                             \
    -glt_label 6 transient_vs40Hz                                     \
    -gltsym 'SYM: vs01Hz -vs40Hz'                                             \
    -glt_label 7 vs01Hz_40Hz                                     \
    -gltsym 'SYM: vs01Hz -vs20Hz'                                             \
    -glt_label 8 vs01Hz_20Hz                                     \
    -gltsym 'SYM: vs01Hz -0.5*vs20Hz -0.5*vs40Hz'                     \
    -glt_label 9 vs01Hz_h20Hz_h40Hz                                     \
    -gltsym 'SYM: vs01Hz_onset -0.5*vs20Hz_onset -0.5*vs40Hz_onset'          \
    -glt_label 10 vs01Hz_h20Hz_h40Hz_onset                                     \
    -gltsym 'SYM: vs01Hz_offset -0.5*vs20Hz_offset -0.5*vs40Hz_offset'         \
    -glt_label 11 vs01Hz_h20Hz_h40Hz_offset                                     \
    -fout -tout -x1D X.xmat.transient.1D -xjpeg X.transient.jpg                                   \
    -x1D_uncensored X.nocensor.xmat.transient.1D                                        \
    -fitts fitts.$subj.transient                                                        \
    -errts errts.${subj}.transient                                                      \
    -cbucket all_betas.$subj.transient                                                  \
    -bucket stats.$subj.transient                                                       \
    -overwrite

# if 3dDeconvolve fails, terminate the script
if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dDeconvolve error, failing...'
    echo '   (consider the file 3dDeconvolve.err)'
    exit
endif


# # display any large pairwise correlations from the X-matrix
# 1d_tool.py -show_cormat_warnings -infile X.xmat.transient.1D |& tee out.cormat_warn.transient.txt -overwrite

# # -- execute the 3dREMLfit script, written by 3dDeconvolve --
# 3dREMLfit -matrix X.xmat.transient.1D \
#      -input "pb04.$subj.r*.scale+tlrc.HEAD" \
#      -Rbeta all_betas.event_REML.transient -fout -tout -Rbuck stats.event_REML.transient -Rvar stats.event_REMLvar.transient \
#      -Rfitts fitts.event_REML.transient -Rerrts errts.event_REML.transient -overwrite

# # if 3dREMLfit fails, terminate the script
# if ( $status != 0 ) then
#     echo '---------------------------------------'
#     echo '** 3dREMLfit error, failing...'
#     exit
# endif

# # ============================ blur estimation =============================
# rm blur*1D
# # set list of runs
# set runs = (`count -digits 2 1 ${run_num}`)

# # compute blur estimates
# touch blur_est.$subj.1D   # start with empty file

# # create directory for ACF curve files
# [ -d files_ACF ] && rm -rf files_ACF
# mkdir files_ACF

# # -- estimate blur for each run in epits --
# touch blur.epits.1D

# # restrict to uncensored TRs, per run
# foreach run ( $runs )
#     set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded \
#                           -show_trs_run $run`
#     if ( $trs == "" ) continue
#     3dFWHMx -detrend -mask full_mask.$subj+tlrc                          \
#             -ACF files_ACF/out.3dFWHMx.ACF.epits.r$run.1D                \
#             all_runs.$subj+tlrc"[$trs]" >> blur.epits.1D
# end

# # compute average FWHM blur (from every other row) and append
# set blurs = ( `3dTstat -mean -prefix - blur.epits.1D'{0..$(2)}'\'` )
# echo average epits FWHM blurs: $blurs
# echo "$blurs   # epits FWHM blur estimates" >> blur_est.$subj.1D

# # compute average ACF blur (from every other row) and append
# set blurs = ( `3dTstat -mean -prefix - blur.epits.1D'{1..$(2)}'\'` )
# echo average epits ACF blurs: $blurs
# echo "$blurs   # epits ACF blur estimates" >> blur_est.$subj.1D

# # -- estimate blur for each run in errts --
# touch blur.errts.1D

# # restrict to uncensored TRs, per run
# foreach run ( $runs )
#     set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded \
#                           -show_trs_run $run`
#     if ( $trs == "" ) continue
#     3dFWHMx -detrend -mask full_mask.$subj+tlrc                          \
#             -ACF files_ACF/out.3dFWHMx.ACF.errts.r$run.1D                \
#             errts.${subj}.transient+tlrc"[$trs]" >> blur.errts.1D
# end

# # compute average FWHM blur (from every other row) and append
# set blurs = ( `3dTstat -mean -prefix - blur.errts.1D'{0..$(2)}'\'` )
# echo average errts FWHM blurs: $blurs
# echo "$blurs   # errts FWHM blur estimates" >> blur_est.$subj.1D

# # compute average ACF blur (from every other row) and append
# set blurs = ( `3dTstat -mean -prefix - blur.errts.1D'{1..$(2)}'\'` )
# echo average errts ACF blurs: $blurs
# echo "$blurs   # errts ACF blur estimates" >> blur_est.$subj.1D

# # -- estimate blur for each run in err_reml --
# touch blur.err_reml.1D

# # restrict to uncensored TRs, per run
# foreach run ( $runs )
#     set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded \
#                           -show_trs_run $run`
#     if ( $trs == "" ) continue
#     3dFWHMx -detrend -mask full_mask.$subj+tlrc                          \
#             -ACF files_ACF/out.3dFWHMx.ACF.err_reml.r$run.1D             \
#             errts.${subj}_REML.transient+tlrc"[$trs]" >> blur.err_reml.1D
# end

# # compute average FWHM blur (from every other row) and append
# set blurs = ( `3dTstat -mean -prefix - blur.err_reml.1D'{0..$(2)}'\'` )
# echo average err_reml FWHM blurs: $blurs
# echo "$blurs   # err_reml FWHM blur estimates" >> blur_est.$subj.1D

# # compute average ACF blur (from every other row) and append
# set blurs = ( `3dTstat -mean -prefix - blur.err_reml.1D'{1..$(2)}'\'` )
# echo average err_reml ACF blurs: $blurs
# echo "$blurs   # err_reml ACF blur estimates" >> blur_est.$subj.1D


# # add 3dClustSim results as attributes to any stats dset
# [ -d files_ClustSim ] && rm -rf files_ClustSim
# mkdir files_ClustSim

# # run Monte Carlo simulations using method 'ACF'
# set params = ( `grep ACF blur_est.$subj.1D | tail -n 1` )
# 3dClustSim -both -mask full_mask.$subj+tlrc -acf $params[1-3]            \
#            -cmd 3dClustSim.ACF.cmd -prefix files_ClustSim/ClustSim.ACF

# # run 3drefit to attach 3dClustSim results to stats
# set cmd = ( `cat 3dClustSim.ACF.cmd` )
# $cmd stats.$subj+tlrc stats.${subj}_REML+tlrc
