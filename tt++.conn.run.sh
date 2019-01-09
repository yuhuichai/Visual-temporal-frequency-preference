#!/bin/sh
# batch dir
batchDir=/Users/chaiy3/Data/visualFreq/batch
# data directory
dataDir=/Users/chaiy3/Data/visualFreq
cd ${dataDir}/170222Sub004/conn_fix.results/rsfc
# ROI-independent 
# fc_para_list=($(ls fc*norm*.HEAD fcs*.HEAD fc*RSFA*.HEAD))
# seed based connectivity
# fc_para_list=($(ls corr*PCC*.HEAD corr*V1*.HEAD corr*IPS*.HEAD corr*Thalamus*.HEAD \
# 	corr*PFC*.HEAD corr*MPF*.HEAD corr*M1*.HEAD \
# 		fc*norm*.HEAD fcs*.HEAD fc*RSFA*.HEAD))
# correlation matrix 
# fc_para_list=($(ls all*_cor_z_merge.1D))
# Thalamus
# fc_para_list=($(ls corr*Thalamus_z+tlrc.HEAD))
# Occipital
fc_para_list=($(ls corr_ctx_*z+tlrc.HEAD))
cd ${dataDir}

# specify and possibly create results directory
results_dir=group.results
[ ! -d ${results_dir} ] && mkdir ${results_dir}

# create group mask
if [ ! -f $results_dir/mask_group.conn+tlrc.HEAD ]; then
	sub_list=`ls 170208Sub003/conn*.results/mask_group+tlrc.HEAD 170222Sub004/conn*.results/mask_group+tlrc.HEAD`
	3dMean -prefix $results_dir/mask_tmp.conn \
		170201Sub002/conn_fix.results/mask_group+tlrc \
		170201Sub002/conn_01Hz.results/mask_group+tlrc \
		170201Sub002/conn_40Hz.results/mask_group+tlrc \
		$sub_list	\
		170222Sub005/conn_fix.results/mask_group+tlrc \
		170222Sub005/conn_01Hz.results/mask_group+tlrc \
		170222Sub005/conn_10Hz.results/mask_group+tlrc 

	3dcalc -a $results_dir/mask_tmp.conn+tlrc -expr 'equals(a,1)' \
	     -prefix $results_dir/mask_group.conn
	# optional choice, step(a-0.999), get intersection through setting any values 
	# greater than 0.999 to 1, and the rest to 0
	rm -f $results_dir/mask_tmp.conn+tlrc*
fi

fc_para_num=${#fc_para_list}
for i in `seq 0 7 $fc_para_num`; do
	for fc_para_head in ${fc_para_list[@]:$i:7}; do	
	{	if [[ "$fc_para_head" =~ "HEAD" ]]; then
			fc_para=${fc_para_head%.HEAD}
		else
			fc_para=${fc_para_head}
		fi
		tcsh ${batchDir}/tt++.conn.tcsh ${fc_para} ${results_dir} 2>&1 | tee ${results_dir}/output.tt++.${fc_para}
		mv ${results_dir}/output.tt++.${fc_para} ${results_dir}/cmd_output/
		# remove the txt part at the beginning of 1D file
		if [[ "$fc_para_head" =~ ".1D" ]]; then
			cd $results_dir
			for file in stats.tt++.*.all*_cor_z_merge.1D; do
				mv ${file} tmp.$file
				rm -f ${file}
				echo $file
				1dcat tmp.$file > ${file}
				rm -f tmp.$file
			done
			
		fi
	}&
	done
	wait
done

# 1dplot outcount_rall.
# 3dinfo -VERB pb00.Tech001_vs40Hz.r01.tcat+orig. | grep offsets
# 1dplot dfile_rall.1D
# 1dplot motion_Tech001_vs40Hz_enorm.1D 
# 1dplot -volreg motion_demean.1D[1..6]
# errts. = input. - fitts.
# 1dplot X.stim.xmat.1D[0..11]

# 3dmaskave -mask Clust_mask+tlrc.HEAD'<2>' all_runs.event_iso+tlrc.HEAD