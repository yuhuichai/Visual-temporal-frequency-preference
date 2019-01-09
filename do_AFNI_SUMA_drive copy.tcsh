#!/bin/tcsh -e

########################################################################
#
# Movie Maker: open up AFNI, overlay a value dset, no threshold,
# project into SUMA, rotate the brain to sagittal views for each
# hemisphere, record jpgs.
#
# v1.1, PA Taylor (NIMH, NIH), Aug 15 2017.
#
########################################################################

# ======================= main user settings =========================
set subj_dir  = $argv[1]
cd ${subj_dir} 

# dsets
set afni_ulay = "/data/chaiy3/visualFreq/suma_MNI_N27/MNI_N27_SurfVol.nii"
set afni_olay = $argv[2]
set olay_brik = $argv[3] #0                    # which brick to display
set suma_spec = "/data/chaiy3/visualFreq/suma_MNI_N27/MNI_N27_both.spec"
set suma_sv   = "$afni_ulay"              # same as volume space in AFNI

# set values for things in driven AFNI
set func_range = $argv[4] #32
set my_cbar    = $argv[5] #"ROI_i32" 
set thr_thresh = 0.001 

# image props
set image_dir = "./DRIVE_SUMA_IMAGES"        # store jpgs here
set image_prefix = $argv[6] #"freqmap"
set time2set_colorbar_range = $argv[7]
# set image_pre = `3dinfo -prefix_noext $afni_olay`

if ( ${my_cbar} =~ *A.* ) then
        set my_cbar = "A.+5 1.2=yellow 0.9=green 0.6=blue 0.3=red 0.1=none"
else 
        set my_cbar = " A.+99 1.0 $argv[5]"
endif

# size of the image window (bigger -> higher res), given as:
# leftcorner_X  leftcorner_Y  windowwidth_X  windowwith_Y
setenv SUMA_Position_Original "50 50 3000 3000" #"50 50 3500 3500"
setenv SUMA_Light0Position "10 1 1"

# ==================================================================

# --------------------- preliminary settings -----------------------

set portnum = `afni -available_npb_quiet`

setenv AFNI_ENVIRON_WARNINGS NO
setenv AFNI_PBAR_FULLRANGE NO
setenv AFNI_PBAR_THREE YES
setenv SUMA_DriveSumaMaxCloseWait 20 #6
setenv SUMA_DriveSumaMaxWait 10 #6

setenv SUMA_AutoRecordPrefix "${image_dir}/${image_prefix}"
rm -f ${image_dir}/${image_prefix}.A.*.jpg
#setenv SUMA_SnapshotOverSampling $OVERSAMP

# ------------------- Open up AFNI viewer and drive ------------------
afni -npb $portnum -niml -yesplugouts $afni_ulay $afni_olay &

# Need to slooow things down occasionally (-> sleep commands) for
# proper viewing behavior.  The number/length of naps may be
# computer/data set dependent.
echo "\n\nNAP 0/4...\n\n"
sleep 2

# NB: Plugout drive options located at:
# http://afni.nimh.nih.gov/pub/dist/doc/program_help/README.driver.html
plugout_drive -echo_edu                                  \
    -npb $portnum                                        \
    -com "SWITCH_UNDERLAY A.${afni_ulay}"                \
    -com "SWITCH_OVERLAY  A.${afni_olay}"                \
    -com "SET_SUBBRICKS   0 $olay_brik $olay_brik"       \
    -com "SEE_OVERLAY     +"                             \
    -com "SET_FUNC_RANGE  A.${func_range}"               \
    -com "SET_FUNC_VISIBLE A.+"                          \
    -com "SET_THRESHNEW A ${thr_thresh}"                 \
    -com "SET_PBAR_ALL $my_cbar"               \
    -quit


sleep ${time2set_colorbar_range}

# -com "SET_PBAR_ALL A.+99 1.0 $my_cbar" 
#### ----> for stat thresholding, user might want to use something
#### ----> like this instead of the above one!!!
#    -com 'SET_THRESHNEW A 0.01 *p'                       \

# --------------------- SUMA setup------------------------------

suma                    \
    -npb $portnum       \
    -niml               \
    -spec  $suma_spec   \
    -sv    $suma_sv     &

echo "++ more sleepy time..."
sleep 2

# DriveSuma -echo_edu \
#     -npb $portnum \
#     -com  viewer_cont  -key ctrl+right               \
#     -com surf_cont -switch_cmap ngray20              \
#     -com surf_cont -I_sb  0  -I_range -0.75 0.75     \
#     -T_sb -1 

# sleep 2

# start driving: connect to AFNI & switch to brain we want
DriveSuma     -echo_edu                                \
    -npb $portnum                                      \
    -com viewer_cont -key 't' -key '.' -key '.' 

sleep 2

# crosshair off, node off, faceset off, label off
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'F3' -key 'F4' -key 'F5' -key 'F9'


# example, sagittal profile, turn off one hemi, rotate, SNAP
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+shift+down' -key 'Ctrl+[' \
    -key 'left' -key 'left' -key 'left' -key 'left' -key 'left' -key 'left' \
    -com viewer_cont -key 'Ctrl+r'

sleep 1
convert -crop 420x500+527+120 ${image_dir}/${image_prefix}.A*.jpg ${image_dir}/${image_prefix}.rh_out.jpg
rm ${image_dir}/${image_prefix}.A*.jpg


# same hemi, other orient, SNAP
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+shift+down' \
    -key 'right' -key 'right' -key 'right' -key 'right' -key 'right' -key 'right' \
    -com viewer_cont -key 'Ctrl+r'

sleep 1
convert -crop 420x500+700+110 ${image_dir}/${image_prefix}.A*.jpg ${image_dir}/${image_prefix}.rh_in.jpg
rm ${image_dir}/${image_prefix}.A*.jpg

# # sagittal profile, turn off one hemi, SNAP
# DriveSuma                                              \
#     -npb $portnum                                      \
#     -com viewer_cont -key 'Ctrl+left' -key 'Ctrl+['    \
#     -com viewer_cont -key 'Ctrl+r'

# sleep 1

# # same hemi, other orient, SNAP
# DriveSuma                                              \
#     -npb $portnum                                      \
#     -com viewer_cont -key 'Ctrl+right'                 \
#     -com viewer_cont -key 'Ctrl+r'

# sleep 1

# change hemi, same orient, SNAP
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+]' -key 'Ctrl+['       \
    -com viewer_cont -key 'Ctrl+r'

sleep 1
convert -crop 420x500+530+130 ${image_dir}/${image_prefix}.A*.jpg ${image_dir}/${image_prefix}.lh_out.jpg
rm ${image_dir}/${image_prefix}.A*.jpg

# same hemi, other orient, SNAP
DriveSuma                                              \
    -npb $portnum                                      \
    -com viewer_cont -key 'Ctrl+shift+down'  \
    -key 'left' -key 'left' -key 'left' -key 'left' -key 'left' -key 'left' \
    -com viewer_cont -key 'Ctrl+r'

sleep 1
convert -crop 420x500+320+115 ${image_dir}/${image_prefix}.A*.jpg ${image_dir}/${image_prefix}.lh_in.jpg
rm ${image_dir}/${image_prefix}.A*.jpg

# close AFNI/SUMAs with given portnum
@Quiet_Talkers -npb_val $portnum

echo "++ DONE!"
