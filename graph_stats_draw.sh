#!/bin/bash
module load afni

stats_1d=$1
results_dir=/data/chaiy3/visualFreq/graph.results/stats
cd $results_dir

# ====================== draw network module ===============================

tmp=${stats_1d%_allvec*}
tmp=${stats_1d%_allmean*}
brick_name=${tmp#*roi}
roi_index_file="../mean/roi${brick_name}_index.1D"
roi_num=`1d_tool.py -infile /${roi_index_file} -show_rows_cols | awk '{print $6}'`

stats_4d=${stats_1d%.1D}
if [ $brick_name = 200 ]; then
	brick_index=19
elif [ $brick_name = 500 ]; then
	brick_index=33
elif [ $brick_name = 950 ]; then
	brick_index=42
fi

atlas_file="/data/chaiy3/visualFreq/Atlas/tcorr05_2level_all_Javier.nii.gz[${brick_index}]"
3dTcat $atlas_file -prefix rm.${stats_4d}.roi${brick_name}.atlas+tlrc -overwrite
cols_num=`1d_tool.py -infile ${stats_1d} -show_rows_cols | awk '{print $6}'`

for col in `seq 1 1 ${cols_num}`; do # 2 2 
{		
	let "col_1 = $col-1"
	if [ ${#col_1} = 1 ]; then
		col_1=0${col_1}
	fi
	if [ ${#col_1} = 2 ]; then
		col_1=${col_1}
	fi

	# extract non zero stats
	1dcat ${stats_1d}[${col_1}]\' > rm.${stats_4d}_${col_1}.stats.1D
	1dcat ${stats_1d}[${col_1}] | awk '$1 != 0' \
		> rm.${stats_4d}_${col_1}.stats_non0.1D
	3dcalc -a ${roi_index_file}\' -b rm.${stats_4d}_${col_1}.stats.1D\' -expr 'a*notzero(b)' \
			-prefix rm.${stats_4d}_${col_1}.roi_index.1D -overwrite
	1dcat rm.${stats_4d}_${col_1}.roi_index.1D | awk '$1 != 0' \
		> rm.${stats_4d}_${col_1}.roi_index_non0.1D

	let "index_non0 = 1"
	rows_num=`1d_tool.py -infile rm.${stats_4d}_${col_1}.roi_index_non0.1D -show_rows_cols \
		| awk '{print $3}'`
	rows_num=${rows_num%,}
	for index in `seq 1 $rows_num`; do
		roi=`cat rm.${stats_4d}_${col_1}.roi_index_non0.1D | sed -n ${index}p`
		stats=`cat rm.${stats_4d}_${col_1}.stats_non0.1D | sed -n ${index}p`
		echo ============= col=$col, roi_value=$roi, stats=$stats ===============

		# if [[ "$stats" =~ "e" ]] || [[ "$stats" =~ "E" ]]; then
		# 	temp=$stats
		# 	stats="($(sed 's/[eE]+\{0,1\}/*10^/g' <<<"$stats"))"
		# 	echo +++++++++++++++ convert $temp to $stats +++++++++++++++++++++++++
		# fi

		# if (( $(bc <<< "$stats == 0") )); then
		# 	echo +++++++++++++++++++++ stats = 0 for roi = $index +++++++++++++++++++++++++
		# else
			3dcalc -a rm.${stats_4d}.roi${brick_name}.atlas+tlrc \
				-expr "${stats}*amongst(a,$roi)" \
				-prefix rm.${stats_4d}_${col_1}+tlrc \
				-overwrite

			if [ "$index" -gt "1" ]; then
				3dcalc -a rm.${stats_4d}_${col_1}+tlrc -b ${stats_4d}_${col_1}+tlrc -expr "a+b" \
					-prefix rm.${stats_4d}_${col_1}_2+tlrc -overwrite
				3dcopy rm.${stats_4d}_${col_1}_2+tlrc ${stats_4d}_${col_1}+tlrc -overwrite
			else
				3dcopy rm.${stats_4d}_${col_1}+tlrc ${stats_4d}_${col_1}+tlrc -overwrite
			fi
		# fi
	done
}&
done
wait

rm rm.${stats_4d}*
chmod 777 ${stats_4d}_*+tlrc*
3dbucket -prefix ${stats_4d}+tlrc ${stats_4d}_*+tlrc.HEAD -overwrite
3dcopy /data/chaiy3/visualFreq/group.results/stats/stats.LME.fc_reho_norm+tlrc rm.${stats_4d}.template1+tlrc -overwrite
# # stats.LME.corr_rV1_Van_z+tlrc
# # 3dbucket -prefix rm.${stats_4d}.template2+tlrc rm.${stats_4d}.template1+tlrc'[1..$(2)]' -overwrite
# 3dbucket -prefix rm.${stats_4d}.template2+tlrc rm.${stats_4d}.template1+tlrc'[0..$]' -overwrite
3drefit -copyaux rm.${stats_4d}.template1+tlrc ${stats_4d}+tlrc
rm ${stats_4d}_*+tlrc*
rm rm.${stats_4d}*
echo "************** done successfully ************"
