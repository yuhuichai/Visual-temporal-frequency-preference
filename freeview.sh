# SkullStripFix_freeview
freeview -v Surf/mri/T1.mgz \
Surf/mri/brainmask.mgz \
-f Surf/surf/lh.white:edgecolor=yellow \
Surf/surf/lh.pial:edgecolor=red \
Surf/surf/rh.white:edgecolor=yellow \
Surf/surf/rh.pial:edgecolor=red

# view the results of recon-all
freeview -v \
Surf/mri/T1.mgz \
Surf/mri/wm.mgz \
Surf/mri/brainmask.mgz \
Surf/mri/aseg.mgz:colormap=lut:opacity=0.2 \
-f Surf/surf/lh.white:edgecolor=blue \
Surf/surf/lh.pial:edgecolor=red \
Surf/surf/rh.white:edgecolor=blue \
Surf/surf/rh.pial:edgecolor=red

# check your surface to make sure the segmentation is good
freeview -v Anat/mp2rage_uni.nii.gz -f Surf/surf/lh.pial -f Surf/surf/rh.pial

# Check coregistration of surface and volume
afni -niml &
suma -spec SUMA_both.spec -sv SUMA_SurfVol.nii

# convert volume file to spec
for hemi in rh lh; do
	3dVol2Surf -spec ~/Data/visualFreq/suma_MNI_N27/std.141.MNI_N27_${hemi}.spec   \
	           -sv ~/Data/visualFreq/suma_MNI_N27/MNI_N27_SurfVol.nii           \
	           -surf_A ${hemi}.smoothwm                            \
	           -surf_B ${hemi}.pial                                \
	           -f_index nodes                              \
	           -f_steps 10                                 \
	           -map_func ave                               \
	           -oob_value 0                                \
	           -grid_parent freqmap_diffexp_orig_pass0.mean_beta.freqmap+tlrc   \
	           -out_niml freqmap_${hemi}.surf.niml.dset
done
suma -spec ../../suma_MNI_N27/std.141.MNI_N27_both.spec -sv ../../suma_MNI_N27/brain.nii