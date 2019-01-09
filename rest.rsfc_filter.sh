#!/usr/bin/env tcsh
module load afni

# created by uber_subject.py: version 0.39 (March 21, 2016)
# creation date: Mon Jan 23 12:21:21 2017

# set data directories
set subj      = $argv[1]
# and make note of repetitions (TRs) per run
set tr_counts = ( 212 )
# set list of runs
set runs = (`count -digits 2 1 1`)
# note TRs that were not censored
set ktrs = `1d_tool.py -infile censor_${subj}_combined_2.1D                \
                       -show_trs_uncensored encoded`

# remove temporary files
\rm -fr rm.* awpy

#============================= 3dTproject ===================================
# -- use 3dTproject to project out regression matrix --
3dTproject -polort 0 -input pb04.$subj.r*.blur+tlrc.HEAD                   \
           -censor censor_${subj}_combined_2.1D -cenmode ZERO              \
           -dsort Local_WM_rall+tlrc                                       \
           -ort X.nocensor.xmat.1D -prefix errts.$subj.fanaticor    \
           -overwrite

# --------------------------------------------------
# create a temporal signal to noise ratio dataset 
#    signal: if 'scale' block, mean should be 100
#    noise : compute standard deviation of errts
3dTstat -mean -prefix rm.signal.all all_runs.$subj+tlrc"[$ktrs]"
3dTstat -stdev -prefix rm.noise.all errts.$subj.fanaticor+tlrc"[$ktrs]"
3dcalc -a rm.signal.all+tlrc                                               \
       -b rm.noise.all+tlrc                                                \
       -c full_mask.$subj+tlrc                                             \
       -expr 'c*a/b' -prefix TSNR.$subj -overwrite

# ============================ blur estimation =============================
rm blur_est.$subj.1D
rm blur.epits.1D
rm blur.errts.1D
# compute blur estimates
touch blur_est.$subj.1D   # start with empty file

rm -rf files_ACF
# create directory for ACF curve files
mkdir files_ACF

# -- estimate blur for each run in epits --
touch blur.epits.1D

# restrict to uncensored TRs, per run
foreach run ( $runs )
    set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded   \
                          -show_trs_run $run`
    if ( $trs == "" ) continue
    3dFWHMx -detrend -mask full_mask.$subj+tlrc                            \
            -ACF files_ACF/out.3dFWHMx.ACF.epits.r$run.1D                  \
            all_runs.$subj+tlrc"[$trs]" >> blur.epits.1D
end

# compute average FWHM blur (from every other row) and append
set blurs = ( `3dTstat -mean -prefix - blur.epits.1D'{0..$(2)}'\'` )
echo average epits FWHM blurs: $blurs
echo "$blurs   # epits FWHM blur estimates" >> blur_est.$subj.1D

# compute average ACF blur (from every other row) and append
set blurs = ( `3dTstat -mean -prefix - blur.epits.1D'{1..$(2)}'\'` )
echo average epits ACF blurs: $blurs
echo "$blurs   # epits ACF blur estimates" >> blur_est.$subj.1D

# -- estimate blur for each run in errts --
touch blur.errts.1D

# restrict to uncensored TRs, per run
foreach run ( $runs )
    set trs = `1d_tool.py -infile X.xmat.1D -show_trs_uncensored encoded   \
                          -show_trs_run $run`
    if ( $trs == "" ) continue
    3dFWHMx -detrend -mask full_mask.$subj+tlrc                            \
            -ACF files_ACF/out.3dFWHMx.ACF.errts.r$run.1D                  \
            errts.$subj.fanaticor+tlrc"[$trs]" >> blur.errts.1D
end

# compute average FWHM blur (from every other row) and append
set blurs = ( `3dTstat -mean -prefix - blur.errts.1D'{0..$(2)}'\'` )
echo average errts FWHM blurs: $blurs
echo "$blurs   # errts FWHM blur estimates" >> blur_est.$subj.1D

# compute average ACF blur (from every other row) and append
set blurs = ( `3dTstat -mean -prefix - blur.errts.1D'{1..$(2)}'\'` )
echo average errts ACF blurs: $blurs
echo "$blurs   # errts ACF blur estimates" >> blur_est.$subj.1D


# #============================= 3dTproject with filtering ===========================
# # create bandpass regressors (instead of using 3dBandpass, say)
# 1dBport -nodata 212 1.7 -band 0.01 0.1 -invert -nozero > bandpass_rall.1D

# # ------------------------------
# # run the regression analysis
# 3dDeconvolve -input pb04.$subj.r*.blur+tlrc.HEAD                           \
#     -censor censor_${subj}_combined_2.1D                                   \
#     -ortvec bandpass_rall.1D bandpass                                      \
#     -ortvec ROIPC.vent.1D ROIPC.vent                                       \
#     -polort 3                                                              \
#     -num_stimts 13                                                         \
#     -stim_times 1 stimuli/${subj}_dis15TR.txt 'GAM'                      \
#     -stim_label 1 ${subj}                                                \
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
#     -fout -tout -x1D bp.X.xmat.1D -xjpeg bp.X.jpg                                \
#     -x1D_uncensored bp.X.nocensor.xmat.1D                                     \
#     -errts bp.errts.${subj}                                                   \
#     -x1D_stop                                                              \
#     -nobucket

# # -- use 3dTproject to project out regression matrix --
# 3dTproject -polort 0 -input pb04.$subj.r*.blur+tlrc.HEAD                   \
#            -censor censor_${subj}_combined_2.1D -cenmode ZERO              \
#            -dsort Local_WM_rall+tlrc                                       \
#            -ort bp.X.nocensor.xmat.1D -prefix bp.errts.$subj.fanaticor

# #=================== no censoring processing for rsfc calculation ===========
# # ------------------------------
# # create ROI PC ort sets: vent

# # create a time series dataset to run 3dpc on...

# # detrend, so principal components are not affected
# foreach run ( $runs )
#     3dTproject -polort 3 -prefix rm.det_pcin_r$run                         \
#                -input pb03.$subj.r$run.volreg+tlrc
# end

# # catenate runs
# 3dTcat -prefix rm.det_pcin_rall rm.det_pcin_r*+tlrc.HEAD

# # make ROI PCs : vent
# 3dpc -mask follow_ROI_vent+tlrc -pcsave 3                                  \
#      -prefix ROIPC.vent rm.det_pcin_rall+tlrc -overwrite

# # ------------------------------
# # run the regression analysis with no censoring
# 3dDeconvolve -input pb04.$subj.r*.blur+tlrc.HEAD                           \
#     -ortvec ROIPC.vent_vec.1D ROIPC.vent                                   \
#     -polort 3                                                              \
#     -num_stimts 13                                                         \
#     -stim_times 1 stimuli/${subj}_dis15TR.txt 'GAM'                      \
#     -stim_label 1 ${subj}                                                \
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
#     -fout -tout -x1D rsfc.X.xmat.1D -xjpeg rsfc.X.jpg                      \
#     -errts rsfc.errts.${subj}                                              \
#     -nobucket


# # if 3dDeconvolve fails, terminate the script
# if ( $status != 0 ) then
#     echo '---------------------------------------'
#     echo '** 3dDeconvolve error, failing...'
#     echo '   (consider the file 3dDeconvolve.err)'
#     exit
# endif

# # -- use 3dTproject to project out regression matrix --
# 3dTproject -polort 0 -input pb04.$subj.r*.blur+tlrc.HEAD                   \
#            -dsort Local_WM_rall+tlrc                                       \
#            -ort rsfc.X.xmat.1D -prefix rsfc.errts.$subj.fanaticor   \
#            -overwrite

# remove temporary files
\rm -fr rm.* awpy