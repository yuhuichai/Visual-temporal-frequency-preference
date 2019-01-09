module load afni
dataDir=/data/chaiy3/visualFreq
batchDir=/data/chaiy3/visualFreq/batch
fitFile=freqmap_fitc_diffexp_orig_pass0.beta.freqmap+tlrc.HEAD

cd $dataDir
for subj in *Sub*; do
{	cd $dataDir/$subj 
	if [ -d event.results ]; then
		cd $dataDir/$subj/event.results
		3dcalc -a ${fitFile} -expr 'a' -prefix freqmap_fitc -float

		3dcalc -a freqmap_diffexp_orig_pass0.beta.freqmap+tlrc[0] \
			-b beta.freqmap+tlrc -expr "b*step(a)" \
			-prefix beta.freqmap.masked -overwrite

		# # using subjectself's Kmeans ROI
		# roiFile=Kmeans_Cr.beta.freqmap+tlrc.HEAD
		# 3dcalc -a ${roiFile} -expr a -datum short -prefix ${roiFile%+tlrc.HEAD}_short -overwrite
		# for Knum in 2 3 4; do
		# 	effect=K${Knum}.${roiFile%+tlrc.HEAD}
		# 	echo "***************** start with ${effect} in $subj ********************"
		# 	3dROIstats -quiet -nzmean -mask ${roiFile%+tlrc.HEAD}_short+tlrc[K${Knum}] freqmap_fitc+tlrc \
		# 		> rm.fit.${effect}.1D -overwrite
		# 	# mean nzmean in output
		# 	sleep 1
		# 	1dcat rm.fit.${effect}.1D'[1..$(2)]' > fit.${effect}.1D
		# 	3dROIstats -quiet -nzmean -mask ${roiFile%+tlrc.HEAD}_short+tlrc[K${Knum}] beta.freqmap.masked+tlrc \
		# 		> rm.beta.${effect}.1D -overwrite
		# 	sleep 1
		# 	1dcat rm.beta.${effect}.1D'[1..$(2)]' > beta.${effect}.1D
		# done
		# rm ${roiFile%+tlrc.HEAD}_short*
		
		# # using group ROI of 
		# 3dcalc -a aseg_func_V1_Vh+tlrc. \
		# 	-b ../../group.event.results/01Hz_mask_0001+tlrc. \
		# 	-c ../../group.event.results/40Hz_mask_0001+tlrc. \
		# 	-d ../conn_fix.results/Thalamus_masked+tlrc. \
		# 	-expr '1*amongst(a,1)*step(b)+2*amongst(a,2)*step(c)+3*step(d)' \
		# 	-prefix aseg_func_V1_Vh_01Hz_40Hz_Thalamus_masked \
		# 	-overwrite

		roiFile=lhfroi_01_vs_h20_h40_Thalamus_masked+tlrc
		effect=sus_lf_hf_tha
		echo "***************** start with ${effect} in $subj ********************"
		3dROIstats -quiet -nzmean -mask ${roiFile} freqmap_fitc+tlrc > rm.fit.${effect}.1D -overwrite
		sleep 1
		1dcat rm.fit.${effect}.1D'[1..$(2)]' > fit.${effect}.1D
		3dROIstats -quiet -nzmean -mask ${roiFile} beta.freqmap.masked+tlrc > rm.beta.${effect}.1D -overwrite
		sleep 1
		1dcat rm.beta.${effect}.1D'[1..$(2)]' > beta.${effect}.1D

		rm freqmap_fitc+tlrc*
		rm beta.freqmap.masked*
		rm rm*
	fi	
}&
done
wait

# group.event.results
# dataDir=/data/chaiy3/visualFreq/group.event.results/freqmap
# fitFile=freqmap_fitc_diffexp_orig_pass0.mean_beta.freqmap+tlrc.HEAD
# freqmapFile=freqmap_diffexp_orig_pass0.mean_beta.freqmap+tlrc.HEAD
# betaFile=mean_beta.freqmap+tlrc.HEAD
# roiFile=Kmeans_Cr.mean_beta.freqmap+tlrc.HEAD

# dataDir=/data/chaiy3/visualFreq/group.results/freqmap
# fitFile=freqmap_fitc_gauss_orig_pass0.mean_beta.stats.LME.fcs_gm_Thalamus_inters_01Hz_40Hz_frac1_pos_z+tlrc.HEAD
# freqmapFile=freqmap_gauss_orig_pass0.mean_beta.stats.LME.fcs_gm_Thalamus_inters_01Hz_40Hz_frac1_pos_z+tlrc.HEAD
# betaFile=mean_beta.stats.LME.fcs_gm_Thalamus_inters_01Hz_40Hz_frac1_pos_z+tlrc.HEAD
# # roiFile=Kmeans_Cr.mean_beta.stats.LME.fcs_gm_Thalamus_inters_01Hz_40Hz_frac1_pos_z+tlrc.HEAD
# roiFile=native.template_areas.resamp_inflat_GMI_corrmask+tlrc.HEAD

# cd $dataDir
# 3dcalc -a ${fitFile} -expr 'a' -prefix freqmap_fitc -float

# 3dcalc -a ${freqmapFile}[0] \
# 	-b ${betaFile} -expr "b*step(a)" \
# 	-prefix beta.freqmap.masked -overwrite

# # using Kmeans ROI
# 3dcalc -a ${roiFile} -expr a -datum short -prefix ${roiFile%+tlrc.HEAD}_short -overwrite
# for Knum in 2 3 4; do
# 	effect=K${Knum}.${roiFile%+tlrc.HEAD}
# 	echo "***************** start with ${effect} ********************"
# 	3dROIstats -quiet -nzmean -mask ${roiFile%+tlrc.HEAD}_short+tlrc[K${Knum}] freqmap_fitc+tlrc \
# 		> rm.fit.${effect}.1D -overwrite
# 	# mean nzmean in output
# 	sleep 1
# 	1dcat rm.fit.${effect}.1D'[1..$(2)]' > fit.${effect}.1D
# 	3dROIstats -quiet -nzmean -mask ${roiFile%+tlrc.HEAD}_short+tlrc[K${Knum}] beta.freqmap.masked+tlrc \
# 		> rm.beta.${effect}.1D -overwrite
# 	sleep 1
# 	1dcat rm.beta.${effect}.1D'[1..$(2)]' > beta.${effect}.1D
# done

	# effect=benson2014.${roiFile%+tlrc.HEAD}
	# echo "***************** start with ${effect} ********************"
	# 3dROIstats -quiet -nzmean -mask ${roiFile} freqmap_fitc+tlrc \
	# 	> rm.fit.${effect}.1D -overwrite
	# # mean nzmean in output
	# sleep 1
	# 1dcat rm.fit.${effect}.1D'[1..$(2)]' > fit.${effect}.1D
	# 3dROIstats -quiet -nzmean -mask ${roiFile} \
	# 	mean_beta.stats.LME.fcs_gm_Thalamus_inters_01Hz_40Hz_frac1_pos_z+tlrc \
	# 	> rm.beta.${effect}.1D -overwrite
	# sleep 1
	# 1dcat rm.beta.${effect}.1D'[1..$(2)]' > beta.${effect}.1D

# rm ${roiFile%+tlrc.HEAD}_short*
# rm freqmap_fitc+tlrc*
# rm beta.freqmap.masked*
# rm rm*	