#!/bin/bash
module load afni

nw_module=/data/chaiy3/visualFreq/Yeo_JNeurophysiol11_MNI152/network_modules_inflate_GMI+tlrc
atlas_dir=/data/chaiy3/visualFreq/Atlas
# atlas_file=/data/chaiy3/visualFreq/graph.results/mask/mask_gm_6mm_group.cc+tlrc #tcorr05_2level_all_Javier.nii.gz
atlas_file=shen_1mm_268_parcellation+tlrc
cd $atlas_dir

if [[ "$atlas_file" =~ "mask" ]]; then

	cd /data/chaiy3/visualFreq/graph.results/mean
	3dcalc -a $atlas_file \
		-b /data/chaiy3/visualFreq/Yeo_JNeurophysiol11_MNI152/network_modules_6mm_inflate_GMI+tlrc. \
		-expr 'step(a)*b' \
		-prefix /data/chaiy3/visualFreq/Yeo_JNeurophysiol11_MNI152/network_modules_6mm_inflate_GMI_mask \
		-overwrite

	nw_module=/data/chaiy3/visualFreq/Yeo_JNeurophysiol11_MNI152/network_modules_6mm_inflate_GMI_mask+tlrc
	vxl_num=`3dBrickStat -count -non-zero ${nw_module}`
	roi_num=`3dBrickStat -count -non-zero ${atlas_file}`
	if [ "${vxl_num}" -ne "${roi_num}" ]; then
		echo ============================================================
		echo "Voxel number of module template is not equal with that in mask"
		echo ============================================================
	fi
	roi_num=5000
	#================= extract coordinate of each ROI ======================			
	[ -f atlas${roi_num}_coordinate.1D ] && rm atlas${roi_num}_coordinate.1D
	# 3dmaskdump -xyz -mask ${atlas_file} ${atlas_file} > rm.atlas${roi_num}_pos.1D
	3dmaskdump -xyz -mask ${atlas_file} ${nw_module} > rm.atlas${roi_num}_module.1D
	1deval -a rm.atlas${roi_num}_module.1D[4] -expr "-a" > rm.atlas${roi_num}_negy.1D
	1deval -start 1 -num ${vxl_num} -expr '1' > rm.atlas${roi_num}_one.1D
	1dcat rm.atlas${roi_num}_module.1D[3] rm.atlas${roi_num}_negy.1D rm.atlas${roi_num}_module.1D[5..6] \
		rm.atlas${roi_num}_one.1D rm.atlas${roi_num}_one.1D \
		> atlas${roi_num}_coordinate.node

	rm rm.atlas${roi_num}*
else
	for brick_index in 0; do # 19 33 42
	{	
		if [ $brick_index = 19 ]; then
			roi_num=200
		elif [ $brick_index = 33 ]; then
			roi_num=500
		elif [ $brick_index = 42 ]; then
			roi_num=950
		elif [ $brick_index = 0 ]; then
			roi_num=268 
		fi

		#================= extract coordinate of each ROI ======================			
		[ -f atlas${roi_num}_coordinate.1D ] && rm atlas${roi_num}_coordinate.1D
		module=0
		for i in `seq 1 ${roi_num}`; do 		
			nvoxels=`3dBrickStat -count -non-zero ${atlas_file}"[$brick_index]<$i..$i>"`
			if [ "$nvoxels" -gt "0" ]; then
				3dmaskdump -xyz -mask ${atlas_file}"[$brick_index]<$i..$i>" ${atlas_file}"[$brick_index]" \
					> rm.atlas${roi_num}_pos.1D
				1dcat rm.atlas${roi_num}_pos.1D[3..5] | 1d_tool.py -show_mmms -infile - > rm.atlas${roi_num}.tmp.1D
				mean_pos=`cat rm.atlas${roi_num}.tmp.1D | grep -e 'col' | awk '{print $8}' | tr ',\n' ' '`

				# distribute ROIs into network modules
				if [[ "$atlas_file" =~ "shen" ]]; then
					module=`sed -n ${i}p shen_268_parcellation_networklabels.txt`
				else
					3dresample -master ${atlas_file} -inset ${nw_module} \
						-prefix rm.atlas${roi_num}.nw_module -overwrite
					nvxls_max=0
					for m in `seq 1 9`; do
						3dROIstats -quiet -nzvoxels -nomeanout -mask ${atlas_file}"[$brick_index]<$i..$i>" \
							rm.atlas${roi_num}.nw_module+tlrc"<$m..$m>" > rm.atlas${roi_num}.nvoxels.1D
						nvoxels=`cat rm.atlas${roi_num}.nvoxels.1D`
						if [ "$nvoxels" -gt "${nvxls_max}" ]; then
							 nvxls_max=$nvoxels
							 module=$m
						fi
					done

					if [ "${nvxls_max}" -eq "0" ]; then
						module=0
						echo ============================================================
						echo "This roi ($i) is not in any of the network modules."
						echo ============================================================
					fi
				fi

				echo $i ${mean_pos} $module >> atlas${roi_num}_coordinate.1D
			fi
		done
		rm rm.atlas${roi_num}*
	}&
	done
	wait
fi
