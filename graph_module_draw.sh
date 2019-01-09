#!/bin/bash
module load afni

nw_dir=/data/chaiy3/visualFreq/Functional_ROIs
cd ${nw_dir}
nw_list=($(ls *.nii.gz))

results_dir=/data/chaiy3/visualFreq/graph.results
cd ${results_dir}

# ====================== draw network module ===============================
min_voxels=100
for M_file in M_r2_thr0.1_Q*_roi950_allvec_mean.1D; do
{	tmp=${M_file%_all*}
	if [[ "${M_file}" =~ "roi" ]]; then
		roi_num=${tmp#*roi}
	elif [[ "${M_file}" =~ "stats" ]]; then
		roi_num=${tmp#*stats}
	fi
	roi_index_file="roi${roi_num}_index.1D"
	atlas_module_name=${M_file%.1D}+tlrc

	if [ $roi_num = 200 ]; then
		brick_index=19
	elif [ $roi_num = 500 ]; then
		brick_index=33
	elif [ $roi_num = 950 ]; then
		brick_index=42
	fi

	atlas_file="/data/chaiy3/visualFreq/craddock_2011_parcellations/tcorr05_2level_all_Javier.nii.gz[$brick_index]"
	3dresample -master $atlas_file -inset mask_gm_group.conn+tlrc \
		-prefix rm.${M_file%.1D}.mask -overwrite
	3dcalc -a $atlas_file -b rm.${M_file%.1D}.mask+tlrc -expr 'a*b' \
		-prefix rm.${M_file%.1D}.atlas_1brick -overwrite
	3dTcat $atlas_file -prefix rm.${M_file%.1D}.atlas_1brick -overwrite

	1d_tool.py -show_mmms -infile ${M_file} > rm.${M_file%.1D}.max.1D
	tmp=`cat rm.${M_file%.1D}.max.1D | grep -e 'col' | awk '{print $11}'` 
	max=${tmp%.*}

	let "m_num = 0"
	let "m_del = 0"
	for i in `seq 1 $max`; do
		3dcalc -a ${roi_index_file} -b ${M_file}\' -expr "a*amongst(b,$i)" \
			-prefix rm.${M_file%.1D}.tmp.1D -overwrite
		1dcat rm.${M_file%.1D}.tmp.1D\' | awk '$1 > 0' > rm.${M_file%.1D}.roi_index_row.1D
		1dcat rm.${M_file%.1D}.roi_index_row.1D\' > rm.${M_file%.1D}.roi_index_col.1D

		# seperate roi_index as amongst less than 50
		cols_num=`1d_tool.py -infile rm.${M_file%.1D}.roi_index_col.1D -show_rows_cols | awk '{print $6}'`
		echo ==================== start module_num = $i for ${M_file} ========================
		for col_bgn in `seq 1 50 $cols_num`; do
			let "col_end = $col_bgn+49"
			if [ "$col_end" -gt "$cols_num" ]; then
				col_end=$cols_num
			fi
			if [ "$cols_num" -gt "1" ]; then
				index=`cat rm.${M_file%.1D}.roi_index_col.1D | cut -d ' ' -f ${col_bgn}-${col_end} | xargs | sed -e 's/ /,/g'`
			else
				index=`cat rm.${M_file%.1D}.roi_index_col.1D`
			fi
			
			3dcalc -a rm.${M_file%.1D}.atlas_1brick+tlrc -expr "${i}*amongst(a,$index)" \
				-prefix rm.${M_file%.1D}.atlas_tmp1 -overwrite

			let "tmp = $i+$col_bgn"
			if [ "$tmp" -gt "2" ]; then
				3dcalc -a rm.${M_file%.1D}.atlas_tmp1+tlrc -b ${atlas_module_name} -expr "a+b" \
					-prefix rm.${M_file%.1D}.atlas_tmp2 -overwrite
				3dcopy rm.${M_file%.1D}.atlas_tmp2+tlrc ${atlas_module_name} -overwrite
			else
				3dcopy rm.${M_file%.1D}.atlas_tmp1+tlrc ${atlas_module_name} -overwrite
			fi
		done

		3dBrickStat -count -non-zero ${atlas_module_name}"<$i..$i>" > rm.${M_file%.1D}.nvoxels.1D
		nvoxels=`cat rm.${M_file%.1D}.nvoxels.1D`
		if [ "$nvoxels" -lt "${min_voxels}" ]; then
			3dcalc -a ${atlas_module_name} -expr "a*(1-amongst(a,$i))" \
				-prefix rm.${M_file%.1D}.atlas_tmp3 -overwrite
			3dcopy rm.${M_file%.1D}.atlas_tmp3+tlrc ${atlas_module_name} -overwrite
		fi
	done


	# sort network modules
	3dmaskdump -noijk -mask ${atlas_module_name} ${atlas_module_name} | \
		1d_tool.py -show_mmms -infile - > rm.${M_file%.1D}.tmp.1D
	tmp=`cat rm.${M_file%.1D}.tmp.1D | grep -e 'col' | awk '{print $11}'`
	max=${tmp%.*}
	let "m_index = 1"
	for nw in ${nw_list[@]}; do
		echo ======================= $nw ==============================
		3dresample -master ${atlas_module_name} -inset ${nw_dir}/${nw} \
			-prefix rm.${M_file%.1D}.${nw} -overwrite
		nvxls_max=0
		for i in `seq 1 $max`; do
			3dROIstats -quiet -nzvoxels -nomeanout -mask rm.${M_file%.1D}.${nw} \
				${atlas_module_name}"<$i..$i>" > rm.${M_file%.1D}.nvoxels.1D
			nvoxels=`cat rm.${M_file%.1D}.nvoxels.1D`
			if [ "$nvoxels" -gt "${nvxls_max}" ]; then
				 nvxls_max=$nvoxels
				 M=$i
			fi
		done
		if [ "${m_index}" -eq "1" ]; then
			3dcalc -a ${atlas_module_name} -expr "${m_index}*amongst(a,$M)" \
				-prefix rm.${M_file%.1D}.atlas.module -overwrite
			3dcalc -a ${M_file}\' -expr "${m_index}*amongst(a,$M)" \
				-prefix sort.${M_file} -overwrite
		else
			3dcalc -a ${atlas_module_name} -b rm.${M_file%.1D}.atlas.module+tlrc \
				-expr "${m_index}*amongst(a,$M)+b" \
				-prefix rm.${M_file%.1D}.atlas.module.tmp -overwrite
			3dcopy rm.${M_file%.1D}.atlas.module.tmp+tlrc rm.${M_file%.1D}.atlas.module \
				-overwrite

			3dcalc -a ${M_file}\' -b sort.${M_file} \
				-expr "${m_index}*amongst(a,$M)+b" \
				-prefix rm.sort.${M_file} -overwrite
			1dcat rm.sort.${M_file}\' > sort.${M_file}
		fi
		let "m_index += 1"
	done
	3dcopy rm.${M_file%.1D}.atlas.module ${atlas_module_name} -overwrite

	# add thalamus module
	echo ======================= 7. thalamus ==============================
	thalamus_file=/data/chaiy3/visualFreq/graph.results/atlas950_tha+tlrc
	3dROIstats -quiet -nzmean -nomeanout -mask ${thalamus_file} ${thalamus_file} \
		> rm.${M_file%.1D}.thalamus.index.1D

	for tha_index in `cat rm.${M_file%.1D}.thalamus.index.1D`; do
		tha_index=${tha_index%.*}
		nvxls=`3dROIstats -quiet -nzvoxels -nomeanout -mask "${thalamus_file}<${tha_index}..${tha_index}>" ${thalamus_file}`
		echo $nvxls

		if [ "$nvxls" -gt "12" ]; then
			echo ++ index = ${tha_index} has $nvxls voxels
			3dcalc -a ${atlas_module_name} -b rm.${M_file%.1D}.atlas_1brick+tlrc \
				-expr "7*amongst(b,${tha_index})+a*(1-amongst(b,${tha_index}))" \
				-prefix rm.${M_file%.1D}.atlas.module.tmp -overwrite
			3dcopy rm.${M_file%.1D}.atlas.module.tmp+tlrc ${atlas_module_name} \
				-overwrite

			3dcalc -a ${roi_index_file} -b sort.${M_file}\' \
				-expr "7*amongst(a,${tha_index})+b*(1-amongst(a,${tha_index}))" \
				-prefix rm.sort.${M_file} -overwrite
			1dcat rm.sort.${M_file}\' > sort.${M_file}
		fi
	done

	# create M with only thalamus and calcarine module
	echo ======================= 8. thalamus + calcarine ==============================
	3dcalc -a ${atlas_module_name} -expr "1*amongst(a,7)+3*amongst(a,2)" -prefix M_thalamus_V1_V2 -overwrite
	3dcalc -a sort.${M_file}\' -expr "1*amongst(a,7)+3*amongst(a,2)" -prefix rm.sort.M_thalamus_V1_V2.1D -overwrite
	1dcat rm.sort.M_thalamus_V1_V2.1D\' > sort.M_thalamus_V1_V2.1D

	calcarine_file=/data/chaiy3/visualFreq/graph.results/atlas950_calcarine+tlrc
	3dROIstats -quiet -nzmean -nomeanout -mask ${calcarine_file} ${calcarine_file} \
		> rm.${M_file%.1D}.calcarine.index.1D

	for calcarine_index in `cat rm.${M_file%.1D}.calcarine.index.1D`; do
		calcarine_index=${calcarine_index%.*}
		nvxls=`3dROIstats -quiet -nzvoxels -nomeanout -mask "${calcarine_file}<${calcarine_index}..${calcarine_index}>" ${calcarine_file}`
		echo $nvxls

		if [ "$nvxls" -gt "12" ]; then
			3dcalc -a M_thalamus_V1_V2+tlrc -b rm.${M_file%.1D}.atlas_1brick+tlrc \
				-expr "2*amongst(b,${calcarine_index})+a*(1-amongst(b,${calcarine_index}))" \
				-prefix rm.${M_file%.1D}.atlas.module.tmp -overwrite
			3dcopy rm.${M_file%.1D}.atlas.module.tmp+tlrc M_thalamus_V1_V2+tlrc \
				-overwrite

			3dcalc -a ${roi_index_file} -b sort.M_thalamus_V1_V2.1D\' \
				-expr "2*amongst(a,${calcarine_index})+b*(1-amongst(a,${calcarine_index}))" \
				-prefix rm.sort.${M_file} -overwrite
			1dcat rm.sort.${M_file}\' > sort.M_thalamus_V1_V2.1D
		fi
	done

	# # create M with 01Hz and 40Hz sensitive module
	# echo ======================= 9. 01Hz and 40Hz sensitive module ==============================
	# 3dcalc -a ${atlas_module_name} -expr "4*amongst(a,7)+5*amongst(a,1)+6*amongst(a,3)+7*amongst(a,4)+8*amongst(a,5)+9*amongst(a,6)" \
	# 	-prefix M_40Hz_sensitive -overwrite
	# 3dcalc -a sort.${M_file}\' -expr "4*amongst(a,7)+5*amongst(a,1)+6*amongst(a,3)+7*amongst(a,4)+8*amongst(a,5)+9*amongst(a,6)" \
	# 	-prefix rm.sort.M_40Hz_sensitive.1D -overwrite
	# 1dcat rm.sort.M_40Hz_sensitive.1D\' > sort.M_40Hz_sensitive.1D

	# let "m_index = 1"
	# for freq_file in atlas950_*_sensitive+tlrc.HEAD; do
	# 	echo ======================= 9. M = $m_index for ${freq_file} ==============================
	# 	3dROIstats -quiet -nzmean -nomeanout -mask ${freq_file} ${freq_file} \
	# 		> rm.${M_file%.1D}.freq.index.1D

	# 	for freq_index in `cat rm.${M_file%.1D}.freq.index.1D`; do
	# 		freq_index=${freq_index%.*}
	# 		nvxls=`3dROIstats -quiet -nzvoxels -nomeanout -mask "${freq_file}<${freq_index}..${freq_index}>" ${freq_file}`
	# 		echo == $nvxls voxels for M=$m_index

	# 		if [ "$nvxls" -gt "20" ]; then
	# 			3dcalc -a M_40Hz_sensitive+tlrc -b rm.${M_file%.1D}.atlas_1brick+tlrc \
	# 				-expr "${m_index}*amongst(b,${freq_index})+a*(1-amongst(b,${freq_index}))" \
	# 				-prefix rm.${M_file%.1D}.atlas.module.tmp -overwrite
	# 			3dcopy rm.${M_file%.1D}.atlas.module.tmp+tlrc M_40Hz_sensitive+tlrc \
	# 				-overwrite

	# 			3dcalc -a ${roi_index_file} -b sort.M_40Hz_sensitive.1D\' \
	# 				-expr "${m_index}*amongst(a,${freq_index})+b*(1-amongst(a,${freq_index}))" \
	# 				-prefix rm.sort.${M_file} -overwrite
	# 			1dcat rm.sort.${M_file}\' > sort.M_40Hz_sensitive.1D
	# 		fi
	# 	done
	# 	let "m_index += 1"
	# done
				 
	rm rm.${M_file%.1D}*
}&
done
wait
rm rm.*

# ====================== draw atlas of roi950 ===============================
# roi_to_draw=/Volumes/data/visualFreq/170315Sub008/conn_fix.results/rsfc/roi950_index.1D
# atlas_file="tcorr05_2level_all_Javier.nii.gz[42]"

# cd /Volumes/data/visualFreq/craddock_2011_parcellations
# 3dTcat $atlas_file -prefix rm.${M_file%.1D}.atlas_1brick -overwrite

# cols_num=`1d_tool.py -infile ${roi_to_draw} -show_rows_cols | awk '{print $6}'`
# for i in `seq 1 50 $cols_num`; do
# 	let "j = $i+49"
# 	if [ "$j" -gt "$cols_num" ]; then
# 		j=$cols_num
# 	fi
# 	index=`cat ${roi_to_draw} | cut -d ' ' -f $i-$j | xargs | sed -e 's/ /,/g'`
# 	3dcalc -a rm.${M_file%.1D}.atlas_1brick+tlrc -expr "a*amongst(a,$index)" \
# 		-prefix rm.${M_file%.1D}.atlas_tmp1 -overwrite
# 	echo $index
# 	if [ "$i" -gt "1" ]; then
# 		3dcalc -a rm.${M_file%.1D}.atlas_tmp1+tlrc -b atlas_select+tlrc -expr "a+b" \
# 			-prefix rm.${M_file%.1D}.atlas_tmp2 -overwrite
# 		3dcopy rm.${M_file%.1D}.atlas_tmp2+tlrc atlas_select+tlrc -overwrite
# 	else
# 		3dcopy rm.${M_file%.1D}.atlas_tmp1+tlrc atlas_select -overwrite
# 	fi

# done

# rm.${M_file%.1D} rm.${M_file%.1D}.atlas_tmp*
# rm.${M_file%.1D} rm.${M_file%.1D}.atlas_1brick*