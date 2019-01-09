#!/bin/sh
# generate SUMA surface map automatically
module load afni

dataDir=/data/chaiy3/visualFreq
batchDir=/data/chaiy3/visualFreq/batch
time2set_colorbar_range=1

# cd ${dataDir}
# for patID in *Sub*19; do
# {	patDir=$dataDir/$patID
# 	sumaDir=$patDir/Surf/surf/SUMA

# 	cd $patDir
# 	if [ -d event.results ]; then
# 		subj_dir=$patDir/event.results
# 		cd ${subj_dir}
# 		for olay in freqmap_diffexp_orig_pass0.beta.freqmap+tlrc.HEAD Kmeans_Cr.beta.freqmap+tlrc.HEAD; do
# 		{	
# 			if [[ "$olay" =~ "Kmeans" ]]; then
# 				func_range=4
# 				cbar="A.+5" #1.2=yellow 0.9=green 0.6=blue 0.3=red 0.1=none"
# 				echo ${cbar}
# 				# tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} 0 ${func_range} ${cbar} Kmeans_Cr_K2 ${time2set_colorbar_range}
# 				tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} 1 ${func_range} ${cbar} Kmeans_Cr_K3 ${time2set_colorbar_range}
# 				# tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} 2 ${func_range} ${cbar} Kmeans_Cr_K4 ${time2set_colorbar_range}
# 			else
# 				func_range=20
# 				cbar="Spectrum:red_to_blue"
# 				image_prefix=${olay%_orig*}
# 				# tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} "freq at max beta" ${func_range} ${cbar} ${image_prefix} ${time2set_colorbar_range}
# 			fi
# 		}
# 		done
# 	fi
# }
# done

# display group results Kmeans_Cr.mean_beta.*+tlrc.HEAD
subj_dir=${dataDir}/group.event.results/freqmap
cd ${subj_dir}
for olay in freqmap_diffexp_orig_pass0.mean_beta.freqmap+tlrc.HEAD; do
	if [[ "$olay" =~ "Kmeans" ]]; then
		func_range=4
		cbar="A.+5" #1.2=yellow 0.9=green 0.6=blue 0.3=red 0.1=none"
		tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} 0 ${func_range} ${cbar} Kmeans_Cr_K2 ${time2set_colorbar_range}
		tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} 1 ${func_range} ${cbar} Kmeans_Cr_K3 ${time2set_colorbar_range}
		tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} 2 ${func_range} ${cbar} Kmeans_Cr_K4 ${time2set_colorbar_range}
	else
		cbar="Spectrum:red_to_blue"

		func_range=17
		image_prefix=freqmap_peak
		time2set_colorbar_range=5
		echo "================= set colorbar threhsold = 0 ======================"
		tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} 0 ${func_range} ${cbar} ${image_prefix} ${time2set_colorbar_range}

		# func_range=40
		# image_prefix=freqmap_rightcut
		# time2set_colorbar_range=40
		# echo "================= set colorbar threhsold = 0.2 ======================"
		# tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} 2 ${func_range} ${cbar} ${image_prefix} ${time2set_colorbar_range}

		# func_range=15
		# image_prefix=freqmap_lefttcut
		# time2set_colorbar_range=40
		# echo "================= set colorbar threhsold = 0.2 ======================"
		# tcsh ${batchDir}/do_AFNI_SUMA_drive.tcsh ${subj_dir} ${olay} 1 ${func_range} ${cbar} ${image_prefix} ${time2set_colorbar_range}
	fi
done
