#!/usr/bin/env tcsh

# created by uber_subject.py: version 0.39 (March 21, 2016)
# creation date: Mon Jan 23 12:21:21 2017

# set data directories
set subj      = $argv[1]
# set list of runs
set runs = (`count -digits 2 1 1`)
# and make note of repetitions (TRs) per run
set tr_counts = ( 212 )
rm rm*

# # create censor file motion_${subj}_censor.1D, for censoring motion 
# 1d_tool.py -infile dfile_rall.1D -set_nruns 1                              \
#     -show_censor_count -censor_prev_TR                                     \
#     -censor_motion 0.5 motion_${subj} -overwrite

# # combine multiple censor files
# 1deval -a motion_${subj}_censor.1D -b outcount_${subj}_censor.1D           \
#        -expr "a*b" > censor_${subj}_combined_2.1D -overwrite

# # note TRs that were not censored
# set ktrs = `1d_tool.py -infile censor_${subj}_combined_2.1D                \
#                        -show_trs_uncensored encoded`

# # ------------------------------
# # create ROI PC ort sets: vent

# # create a time series dataset to run 3dpc on...

# # detrend, so principal components are not affected
# foreach run ( $runs )
#     # to censor, create per-run censor files
#     1d_tool.py -set_run_lengths $tr_counts -select_runs $run               \
#                -infile censor_${subj}_combined_2.1D -write rm.censor.r$run.1D

#     # do not let censored time points affect detrending
#     3dTproject -polort 3 -prefix rm.det_pcin_r$run                         \
#                -censor rm.censor.r$run.1D -cenmode KILL                    \
#                -input pb03.$subj.r$run.volreg+tlrc
# end

# # catenate runs, prepare to censor TRs
# 3dTcat -prefix rm.det_pcin_rall rm.det_pcin_r*+tlrc.HEAD

# # make ROI PCs : vent
# 3dpc -mask follow_ROI_vent+tlrc -pcsave 3                                  \
#      -prefix rm.ROIPC.vent rm.det_pcin_rall+tlrc

# # zero pad censored TRs
# 1d_tool.py -censor_fill_parent censor_${subj}_combined_2.1D                \
#     -infile rm.ROIPC.vent_vec.1D                                           \
#     -write ROIPC.vent.1D -overwrite

# # ------------------------------
# # run the regression analysis
# 3dDeconvolve -input pb04.$subj.r*.blur+tlrc.HEAD                           \
#     -censor censor_${subj}_combined_2.1D                                   \
#     -ortvec ROIPC.vent.1D ROIPC.vent                                       \
#     -polort 3                                                              \
#     -num_stimts 13                                                         \
#     -stim_times 1 stimuli/${subj}_dis15TR.txt 'GAM'                       \
#     -stim_label 1 ${subj}                                                 \
#     -stim_file 2 motion_demean.1D'[0]' -stim_base 2 -stim_label 2 roll_01  \
#     -stim_file 3 motion_demean.1D'[1]' -stim_base 3 -stim_label 3 pitch_01 \
#     -stim_file 4 motion_demean.1D'[2]' -stim_base 4 -stim_label 4 yaw_01   \
#     -stim_file 5 motion_demean.1D'[3]' -stim_base 5 -stim_label 5 dS_01    \
#     -stim_file 6 motion_demean.1D'[4]' -stim_base 6 -stim_label 6 dL_01    \
#     -stim_file 7 motion_demean.1D'[5]' -stim_base 7 -stim_label 7 dP_01    \
#     -stim_file 8 motion_deriv.1D'[0]' -stim_base 8 -stim_label 8 roll_02   \
#     -stim_file 9 motion_deriv.1D'[1]' -stim_base 9 -stim_label 9 pitch_02  \
#     -stim_file 10 motion_deriv.1D'[2]' -stim_base 10 -stim_label 10 yaw_02 \
#     -stim_file 11 motion_deriv.1D'[3]' -stim_base 11 -stim_label 11 dS_02  \
#     -stim_file 12 motion_deriv.1D'[4]' -stim_base 12 -stim_label 12 dL_02  \
#     -stim_file 13 motion_deriv.1D'[5]' -stim_base 13 -stim_label 13 dP_02  \
#     -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                                \
#     -x1D_uncensored X.nocensor.xmat.1D                                     \
#     -fitts fitts.$subj                                                     \
#     -errts errts.${subj}                                                   \
#     -bucket stats.$subj -overwrite


# # if 3dDeconvolve fails, terminate the script
# if ( $status != 0 ) then
#     echo '---------------------------------------'
#     echo '** 3dDeconvolve error, failing...'
#     echo '   (consider the file 3dDeconvolve.err)'
#     exit
# endif


# # display any large pairwise correlations from the X-matrix
# 1d_tool.py -show_cormat_warnings -infile X.xmat.1D |& tee out.cormat_warn.txt -overwrite

# # --------------------------------------------------
# # fast ANATICOR: generate local WM time series averages
# # create catenated volreg dataset
# 3dTcat -prefix rm.all_runs.volreg pb03.$subj.r*.volreg+tlrc.HEAD -overwrite

# # mask white matter before blurring
# 3dcalc -a rm.all_runs.volreg+tlrc -b follow_ROI_WM+tlrc                    \
#        -expr "a*bool(b)" -datum float -prefix rm.all_runs.volreg.mask

# # generate ANATICOR voxelwise regressors via blur
# 3dmerge -1blur_fwhm 30 -doall -prefix Local_WM_rall                        \
#     rm.all_runs.volreg.mask+tlrc -overwrite

# rm *REML+tlrc*
# # -- execute the 3dREMLfit script, written by 3dDeconvolve --
# # (include ANATICOR regressors via -dsort)
# tcsh -x stats.REML_cmd -dsort Local_WM_rall+tlrc 

# # if 3dREMLfit fails, terminate the script
# if ( $status != 0 ) then
#     echo '---------------------------------------'
#     echo '** 3dREMLfit error, failing...'
#     exit
# endif


# # create an all_runs dataset to match the fitts, errts, etc.
# 3dTcat -prefix all_runs.$subj pb04.$subj.r*.blur+tlrc.HEAD -overwrite

# # --------------------------------------------------
# # create a temporal signal to noise ratio dataset 
# #    signal: if 'scale' block, mean should be 100
# #    noise : compute standard deviation of errts
# 3dTstat -mean -prefix rm.signal.all all_runs.$subj+tlrc"[$ktrs]" -overwrite
# 3dTstat -stdev -prefix rm.noise.all errts.${subj}_REML+tlrc"[$ktrs]" -overwrite
# 3dcalc -a rm.signal.all+tlrc                                               \
#        -b rm.noise.all+tlrc                                                \
#        -c full_mask.$subj+tlrc                                             \
#        -expr 'c*a/b' -prefix TSNR.$subj -overwrite

# # ---------------------------------------------------
# # compute and store GCOR (global correlation average)
# # (sum of squares of global mean of unit errts)
# 3dTnorm -norm2 -prefix rm.errts.unit errts.${subj}_REML+tlrc -overwrite
# 3dmaskave -quiet -mask full_mask.$subj+tlrc rm.errts.unit+tlrc             \
#           > gmean.errts.unit.1D -overwrite
# 3dTstat -sos -prefix - gmean.errts.unit.1D\' > out.gcor.1D -overwrite
# echo "-- GCOR = `cat out.gcor.1D`"

# # ---------------------------------------------------
# # compute correlation volume
# # (per voxel: average correlation across masked brain)
# # (now just dot product with average unit time series)
# 3dcalc -a rm.errts.unit+tlrc -b gmean.errts.unit.1D -expr 'a*b' -prefix rm.DP
# 3dTstat -sum -prefix corr_brain rm.DP+tlrc -overwrite

# # compute 2 requested correlation volume(s)
# # create correlation volume corr_af_aeseg
# 3dcalc -a follow_ROI_aeseg+tlrc -b full_mask.$subj+tlrc -expr 'a*b'        \
#        -prefix rm.fm.aeseg
# 3dmaskave -q -mask rm.fm.aeseg+tlrc rm.errts.unit+tlrc > mean.unit.aeseg.1D -overwrite
# 3dcalc -a rm.errts.unit+tlrc -b mean.unit.aeseg.1D                         \
#        -expr 'a*b' -prefix rm.DP.aeseg
# 3dTstat -sum -prefix corr_af_aeseg rm.DP.aeseg+tlrc -overwrite

# # create correlation volume corr_af_vent
# 3dcalc -a follow_ROI_vent+tlrc -b full_mask.$subj+tlrc -expr 'a*b'         \
#        -prefix rm.fm.vent -overwrite
# 3dmaskave -q -mask rm.fm.vent+tlrc rm.errts.unit+tlrc > mean.unit.vent.1D -overwrite
# 3dcalc -a rm.errts.unit+tlrc -b mean.unit.vent.1D                          \
#        -expr 'a*b' -prefix rm.DP.vent
# 3dTstat -sum -prefix corr_af_vent rm.DP.vent+tlrc -overwrite

# # create ideal files for fixed response stim types
# 1dcat X.nocensor.xmat.1D'[4]' > ideal_${subj}.1D -overwrite

# # --------------------------------------------------------
# # compute sum of non-baseline regressors from the X-matrix
# # (use 1d_tool.py to get list of regressor colums)
# set reg_cols = `1d_tool.py -infile X.nocensor.xmat.1D -show_indices_interest`
# 3dTstat -sum -prefix sum_ideal.1D X.nocensor.xmat.1D"[$reg_cols]" -overwrite

# # also, create a stimulus-only X-matrix, for easy review
# 1dcat X.nocensor.xmat.1D"[$reg_cols]" > X.stim.xmat.1D -overwrite

# # ============================ blur estimation =============================
# # compute blur estimates
# touch blur_est.$subj.1D   # start with empty file

# rm -rf files_ACF
# # create directory for ACF curve files
# mkdir files_ACF

# # -- estimate blur for each run in epits --
# touch blur.epits.1D

# # restrict to uncensored TRs, per run
# foreach run ( $runs )
#     set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded   \
#                           -show_trs_run $run`
#     if ( $trs == "" ) continue
#     3dFWHMx -detrend -mask full_mask.$subj+tlrc                            \
#             -ACF files_ACF/out.3dFWHMx.ACF.epits.r$run.1D                  \
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
#     set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded   \
#                           -show_trs_run $run`
#     if ( $trs == "" ) continue
#     3dFWHMx -detrend -mask full_mask.$subj+tlrc                            \
#             -ACF files_ACF/out.3dFWHMx.ACF.errts.r$run.1D                  \
#             errts.${subj}+tlrc"[$trs]" >> blur.errts.1D
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
#     set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded   \
#                           -show_trs_run $run`
#     if ( $trs == "" ) continue
#     3dFWHMx -detrend -mask full_mask.$subj+tlrc                            \
#             -ACF files_ACF/out.3dFWHMx.ACF.err_reml.r$run.1D               \
#             errts.${subj}_REML+tlrc"[$trs]" >> blur.err_reml.1D
# end

# # compute average FWHM blur (from every other row) and append
# set blurs = ( `3dTstat -mean -prefix - blur.err_reml.1D'{0..$(2)}'\'` )
# echo average err_reml FWHM blurs: $blurs
# echo "$blurs   # err_reml FWHM blur estimates" >> blur_est.$subj.1D

# # compute average ACF blur (from every other row) and append
# set blurs = ( `3dTstat -mean -prefix - blur.err_reml.1D'{1..$(2)}'\'` )
# echo average err_reml ACF blurs: $blurs
# echo "$blurs   # err_reml ACF blur estimates" >> blur_est.$subj.1D


# ================== auto block: generate review scripts ===================
rm @epi_review.$subj
# generate a review script for the unprocessed EPI data
gen_epi_review.py -script @epi_review.$subj \
    -dsets pb00.$subj.r*.tcat+orig.HEAD

# generate scripts to review single subject results
# (try with defaults, but do not allow bad exit status)
gen_ss_review_scripts.py -mot_limit 0.5 -out_limit 0.1 -exit0

# ========================== auto block: finalize ==========================

# remove temporary files
\rm -fr rm.* awpy

# if the basic subject review script is here, run it
# (want this to be the last text output)
if ( -e @ss_review_basic ) ./@ss_review_basic |& tee out.ss_review.$subj.txt

# return to parent directory
cd ..

echo "execution finished: `date`"
