#!/bin/sh
# batch dir
batchDir=/data/NIMH_SFIM/chai/visualFreq/batch
# data directory
dataDir=/data/NIMH_SFIM/chai/visualFreq/
cd ${dataDir}/170222Sub004/conn_fix.results/RSFC_fanaticor
# ROI-independent 
# fc_para_list=($(ls fc*norm*.HEAD fcs*.HEAD fc*RSFA*.HEAD))
# seed based connectivity
# fc_para_list=($(ls corr*PCC*.HEAD corr*V1*.HEAD corr*Thalamus_afni*.HEAD \
# 		fc_reho_norm*.HEAD fcs*.HEAD fc_ALFF_norm+tlrc.HEAD fc_fALFF_norm+tlrc.HEAD \
# 		corr_ctx_lh_S_oc-temp_med_and_Lingual_vec_z+tlrc.HEAD corr_ctx*lh*calcarine*vec*.HEAD))
fc_para_list=($(ls corr_*Thalamus_z+tlrc.HEAD fcs_*_cerebellum_z+tlrc.HEAD))
echo ${fc_para_list[@]}
# correlation matrix 
# fc_para_list=($(ls all*_cor_z_merge.1D))
cd ${dataDir}

# specify and possibly create results directory
results_dir=group.fanaticor.results
[ ! -d ${results_dir} ] && mkdir ${results_dir}
[ ! -d ${results_dir}/output ] && mkdir ${results_dir}/output

# create group mask
if [ ! -f $results_dir/mask_group.conn+tlrc.HEAD ]; then
	sub_list=`ls 170208Sub003/conn*.results/mask_group_epi+tlrc.HEAD \
				 170222Sub004/conn*.results/mask_group_epi+tlrc.HEAD \
				 170301Sub006/conn*.results/mask_group_epi+tlrc.HEAD`
	3dMean -prefix $results_dir/mask_tmp.conn \
		170201Sub002/conn_fix.results/mask_group_epi+tlrc \
		170201Sub002/conn_01Hz.results/mask_group_epi+tlrc \
		170201Sub002/conn_40Hz.results/mask_group_epi+tlrc \
		$sub_list	\
		170222Sub005/conn_fix.results/mask_group_epi+tlrc \
		170222Sub005/conn_01Hz.results/mask_group_epi+tlrc \
		170222Sub005/conn_10Hz.results/mask_group_epi+tlrc \
		170308Sub007/conn_fix.results/mask_group_epi+tlrc \
		170308Sub007/conn_01Hz.results/mask_group_epi+tlrc \
		170308Sub007/conn_10Hz.results/mask_group_epi+tlrc \

	3dcalc -a $results_dir/mask_tmp.conn+tlrc -expr 'equals(a,1)' \
	     -prefix $results_dir/mask_group.conn
	# optional choice, step(a-0.999), get intersection through setting any values 
	# greater than 0.999 to 1, and the rest to 0
	rm -f $results_dir/mask_tmp.conn+tlrc*
fi

fc_para_num=${#fc_para_list[@]}
for i in `seq 0 8 $fc_para_num`; do
	for fc_para_head in ${fc_para_list[@]:$i:8}; do
	{	
		if [[ "$fc_para_head" =~ "HEAD" ]]; then
			fc_para=${fc_para_head%.HEAD}
		else
			fc_para=${fc_para_head}
		fi
		echo start analyzing $fc_para ...
		tcsh ${batchDir}/LME.conn.tcsh ${fc_para} ${results_dir} 2>&1 | tee ${results_dir}/output/output.LME.${fc_para}
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