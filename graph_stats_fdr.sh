#!/bin/bash
module load afni

results_dir=/data/chaiy3/visualFreq/graph.results/stats
cd ${results_dir}
# if [[ "${results_dir}" =~ "vxl" ]]; then
# 	cat stats.LME.roi5000_allmean_cor_z1triu_*.1D > stats.LME.roi5000_allmean_cor_z1triu.1D
# 	rm stats.LME.roi5000_allmean_cor_z1triu_*.1D
# fi

# ================= covert Z-value to P-value =======================
for cc_file in stats.LME.roi*_all*_cor_z1*.1D; do
{	
	echo "++ start fdr ${cc_file}"
	fdrmask=${cc_file%_all*}
	fdrmask=${fdrmask#stats.LME.}_fdrmask.1D

	for col in `seq 1 2 33`; do
	{	echo "======================= coverting z to p for subbrick $col ===================" 
		if [ "$col" -eq "1" ]; then
			echo "*************************** remember set right df ****************************"
			1deval -a ${cc_file}[$col] -expr 'fift_t2p(a,4,69)' > rm.${cc_file%.1D}_${col}p.1D
		elif [ "$col" -gt "1" ]; then
			1deval -a ${cc_file}[$col] -expr 'fizt_t2p(abs(a))' > rm.${cc_file%.1D}_${col}p.1D
		fi

		if [ ${#col} = 1 ]; then
			fz_index=0${col}
		else
			fz_index=${col}
		fi

		let "q_index = col + 1"
		if [ ${#q_index} = 1 ]; then
			q_index=0${q_index}	
		fi

		1dcat ${cc_file}[$col] > rm.${cc_file%.1D}_fzq${fz_index}.1D
		if [[ "${cc_file}" =~ "triu" ]]; then
			3dFDR -input1D rm.${cc_file%.1D}_${col}p.1D -qval \
				-output rm.${cc_file%.1D}_fzq${q_index}.1D -overwrite
		else
			3dFDR -input1D rm.${cc_file%.1D}_${col}p.1D -mask_file ${fdrmask} -qval \
				-output rm.${cc_file%.1D}_fzq${q_index}.1D -overwrite
		fi

		# 1dcat ${cc_file}[$col] > rm.${cc_file%.1D}_fzp${fz_index}.1D
		# 1dcat rm.${cc_file%.1D}_${col}p.1D > rm.${cc_file%.1D}_fzp${fz_index}.1D	
	}&
	done
	wait
	1dcat rm.${cc_file%.1D}_fzq*.1D > ${cc_file%.1D}_fdr.1D
	# 1dcat rm.${cc_file%.1D}_fzp*.1D > ${cc_file%.1D}_fzp.1D
	rm rm.${cc_file%.1D}*
}
done
# wait

