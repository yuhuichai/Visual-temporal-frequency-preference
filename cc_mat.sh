#!/bin/bash
module load afni
sub_dir=$1 # /Users/chaiy3/Data/visualFreq/*Sub003
run_dir=$2
atlas=$3
atlasFile=/data/chaiy3/visualFreq/Atlas/${atlas}
	
subj=${run_dir%.results}
cd $sub_dir/$run_dir
[ ! -d rsfc  ] && mkdir rsfc

if [[ "$atlasFile" =~ "Power" ]]; then
	brick_list=(3 5) # represent ROI radius
else
	# rm area with high SD in aseg_ROI
	# 3dTstat -mask mask_group_epi+tlrc -stdev -prefix SD.errts.${subj}.fanaticor \
	# 	errts.${subj}.fanaticor+tlrc -overwrite
	# 3dmaskdump -noijk -mask mask_group_epi+tlrc SD.errts.${subj}.fanaticor+tlrc | \
	# 	1d_tool.py -show_mmms -infile - > tmp.1D
	# tmp=`cat tmp.1D | grep -e 'col' | awk '{print $8}'` 
	# mean=${tmp%,}
	# stdev=`cat tmp.1D | grep -e 'col' | awk '{print $14}'`
	# 3dcalc -a SD.errts.${subj}.fanaticor+tlrc -b mask_group_epi+tlrc -expr "within(a,0,$mean+$stdev)*b" \
	# 	-prefix mask.SD.errts.${subj}.fanaticor -overwrite
	3dresample -master errts.${subj}.fanaticor+tlrc -inset ${atlasFile} -prefix rm.resample.${atlas} -overwrite
	# 3dcalc -a mask.SD.errts.${subj}.fanaticor+tlrc -b atlas+tlrc -expr "a*b" \
	# 	-prefix atlas_SDmask -overwrite
	# rm tmp.1D
	3dcalc -a aseg_func_gm_infl+tlrc -b rm.resample.${atlas} -expr "b*ispositive(a-1)" \
		-prefix rm.gm.${atlas} -overwrite

	if [[ "$atlasFile" =~ "tcorr05" ]]; then
		brick_list=(19 33 42)
	elif [[ "$atlasFile" =~ "shen" ]]; then
		brick_list=(0)
	fi
fi

for brick_index in ${brick_list[@]}; do
{	
	if [ $brick_index = 19 ]; then
		roi_num=200
		min_voxels=1
	elif [ $brick_index = 33 ]; then
		roi_num=500
		min_voxels=1
	elif [ $brick_index = 42 ]; then
		roi_num=950
		min_voxels=1
	elif [ $brick_index = 0 ]; then
		roi_num=268
		min_voxels=1
	elif [ $brick_index = 3 ] || [ $brick_index = 5 ]; then
		roi_num=27$brick_index
		radius=$brick_index
		min_voxels=1
		3dcalc -a aseg_func_gm_infl+tlrc -expr "a*0" \
			-prefix Power_r${radius} -overwrite
	fi

	rm -f rsfc/*roi${roi_num}*
	# #======================= extract mean time course of each aseg ROI =========================
	# # count voxel number within each ROI: 
	# 3dROIstats -quiet -nzvoxels -nomeanout -mask rm.gm.${atlas}[$brick_index] \
	# 	rm.gm.${atlas}[$brick_index] > rm.nzvoxels_atlas${roi_num}.1D
	# 3dROIstats -quiet -nzmean -nomeanout -mask rm.gm.${atlas}[$brick_index] \
	# 	rm.gm.${atlas}[$brick_index] > rm.nzmean_atlas${roi_num}.1D
	# 3dcalc -a rm.nzvoxels_atlas${roi_num}.1D\' -b rm.nzmean_atlas${roi_num}.1D\' \
	# 	-expr "step(${min_voxels}+1-a)*b" -prefix rm.nzmean_atlas0${roi_num}.1D
	# 3dcalc -a rm.nzvoxels_atlas${roi_num}.1D\' -b rm.nzmean_atlas${roi_num}.1D\' \
	# 	-expr "step(a-${min_voxels})*b" -prefix rm.roi${roi_num}_index.1D
	# 1dcat rm.roi${roi_num}_index.1D | awk '$1 > 0' > roi${roi_num}_index.1D
	# index20=`1dcat rm.nzmean_atlas0${roi_num}.1D | awk '$1 > 0'`
	
	# if [ "${#index20}" -gt "1" ]; then
	# 	cols_num=`echo $index20 | 1d_tool.py -show_rows_cols -infile - | awk '{print $6}'`
	# 	if [ "${cols_num}" -eq "1" ]; then
	# 		3dcalc -a rm.gm.${atlas}[$brick_index] -expr "a*(1-amongst(a,${index20}))" \
	# 			-prefix atlas${roi_num}_gm -overwrite
	# 	elif [ "${cols_num}" -gt "1" ]; then
	# 		index=`echo $index20 | sed 's/ /,/g'`
	# 		3dcalc -a rm.gm.${atlas}[$brick_index] -expr "a*(1-amongst(a,${index}))" \
	# 			-prefix atlas${roi_num}_gm -overwrite
	# 	fi
	# else
	# 	3dTcat rm.gm.${atlas}[$brick_index] -prefix atlas${roi_num}_gm -overwrite
	# fi

	# 3dROIstats -quiet -mask atlas${roi_num}_gm+tlrc errts.${subj}.fanaticor+tlrc \
	# 	> roi${roi_num}_allmean.1D -overwrite
	# # correlation matrix
	# 1ddot -terse roi${roi_num}_allmean.1D > roi${roi_num}_allmean_cor.1D -overwrite
	# # fisher z-transform
	# 3dcalc -a roi${roi_num}_allmean_cor.1D\' -expr 'log((1+a)/(1-a))/2' \
	# 	-prefix roi${roi_num}_temp.1D  -overwrite
	# 1dcat roi${roi_num}_temp.1D > roi${roi_num}_allmean_cor_z.1D -overwrite

	#================= extract principal singular vector of each aseg ROI ======================			
	let "svd_index = 0"
	for i in `seq 1 ${roi_num}`; do # 1 ${roi_num}
		if [[ "$atlasFile" =~ "Power" ]]; then
			if [ "$i" -gt "264" ]; then
				echo 0 > roi${roi_num}_nvoxels.1D
			else
				sed -n ${i}p ${atlasFile} > rm.roi${roi_num}.seed.1D
				3dUndump -prefix rm.roi${roi_num}.roi -master errts.${subj}.fanaticor+tlrc \
					-mask aseg_func_gm_infl+tlrc -srad ${radius} -xyz rm.roi${roi_num}.seed.1D \
					-overwrite
				3dBrickStat -count -non-zero rm.roi${roi_num}.roi+tlrc \
					> roi${roi_num}_nvoxels.1D
			fi
		else
			3dBrickStat -count -non-zero rm.gm.${atlas}"[$brick_index]<$i..$i>" \
				> roi${roi_num}_nvoxels.1D
		fi
		nvoxels=`cat roi${roi_num}_nvoxels.1D`
		if [ "$nvoxels" -gt "${min_voxels}" ]; then
			if [ ${#svd_index} = 1 ]; then
				sv_index=00${svd_index}
			fi
			if [ ${#svd_index} = 2 ]; then
				sv_index=0${svd_index}
			fi
			if [ ${#svd_index} = 3 ]; then
				sv_index=${svd_index}
			fi
			echo =============== roi $i =======================
			# Compute the individual SVD vectors
			if [[ "$atlasFile" =~ "Power" ]]; then
				3dmaskSVD -vnorm -mask rm.roi${roi_num}.roi+tlrc \
					errts.${subj}.fanaticor+tlrc > roi${roi_num}_qvec${sv_index}.1D	
			else			
				3dmaskSVD -vnorm -mask rm.gm.${atlas}"[$brick_index]<$i..$i>" \
					errts.${subj}.fanaticor+tlrc > roi${roi_num}_qvec${sv_index}.1D
			fi

			tmp=`cat roi${roi_num}_qvec${sv_index}.1D`
			if [ "${#tmp}" -gt "0" ]; then
				echo $i > roi${roi_num}_roi${sv_index}.1D
				# extract mean time course from ROI
				if [[ "$atlasFile" =~ "Power" ]]; then
					3dmaskave -quiet -mask rm.roi${roi_num}.roi+tlrc \
						errts.${subj}.fanaticor+tlrc > roi${roi_num}_qmean${sv_index}.1D
					3dcalc -a rm.roi${roi_num}.roi+tlrc -b Power_r${radius}+tlrc \
						-expr "a*(${svd_index}+1)+b" -prefix rm.roi${roi_num}.tmp -overwrite
					3dcopy rm.roi${roi_num}.tmp+tlrc Power_r${radius}+tlrc -overwrite
				else	
					3dmaskave -quiet -mask rm.gm.${atlas}"[$brick_index]<$i..$i>" \
						errts.${subj}.fanaticor+tlrc > roi${roi_num}_qmean${sv_index}.1D
				fi		
				let "svd_index += 1"
			fi
		fi
	done
	rm roi${roi_num}_nvoxels.1D

	# Glue them together into 1 big file, then delete the individual files
	1dcat roi${roi_num}_qvec*.1D > roi${roi_num}_allvec.1D -overwrite
	rm -f roi${roi_num}_qvec*.1D
	1dcat roi${roi_num}_roi*.1D > roi${roi_num}_index.1D -overwrite
	rm -f roi${roi_num}_roi*.1D
	1dcat roi${roi_num}_qmean*.1D > roi${roi_num}_allmean.1D -overwrite
	rm -f roi${roi_num}_qmean*.1D
	# Plot the results to a JPEG file, then compute their correlation matrix
	# 1dplot -one -nopush -jpg allvec.jpg allvec.1D
	# 1dplot -one -nopush -jpg allmean.jpg allmean.1D
	1ddot -terse roi${roi_num}_allvec.1D > roi${roi_num}_allvec_cor.1D -overwrite
	1ddot -terse roi${roi_num}_allmean.1D > roi${roi_num}_allmean_cor.1D -overwrite
	# fisher z-transform
	3dcalc -a roi${roi_num}_allvec_cor.1D\' -expr 'log((1+a)/(1-a))/2' \
		-prefix roi${roi_num}_temp.1D  -overwrite
	1dcat roi${roi_num}_temp.1D > roi${roi_num}_allvec_cor_z.1D -overwrite
	3dcalc -a roi${roi_num}_allmean_cor.1D\' -expr 'log((1+a)/(1-a))/2' \
		-prefix roi${roi_num}_temp.1D  -overwrite
	1dcat roi${roi_num}_temp.1D > roi${roi_num}_allmean_cor_z.1D -overwrite
	
	# Display number of rows and columns for a 1D dataset
	# cols_num=`1d_tool.py -infile allvec_cor_z.1D -show_rows_cols | awk '{print $6}'`
	# [ -f allvec_cor_z_merge.1D ] && rm -f allvec_cor_z_merge.1D
	# [ -f allmean_cor_z_merge.1D ] && rm -f allmean_cor_z_merge.1D
	# for i in `seq 1 $cols_num`; do
	# 	let "i -= 1"
	# 	1dcat allvec_cor_z.1D[$i] >> allvec_cor_z_merge.1D
	# 	1dcat allmean_cor_z.1D[$i] >> allmean_cor_z_merge.1D
	# done
	rm -f roi${roi_num}*temp*.1D
	rm -f roi${roi_num}*all*cor.1D
	rm -f roi${roi_num}*allmean.1D
	rm -f roi${roi_num}*allvec.1D
	rm -f rm.roi${roi_num}*
	mv roi${roi_num}*.1D rsfc/
}&
done
wait
rm rm.*${atlas}*