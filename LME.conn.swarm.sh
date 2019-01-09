#!/bin/sh
module load afni R
rsfc_dir=rsfc
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq/
cd ${dataDir}/170720Sub021/conn_fix.results/${rsfc_dir}
fc_para_list=($(ls fcs_gm_Tha_fcs_gm_visual_pos_z+tlrc.HEAD)) # *vec*thr0.1.1D
cd ${dataDir}

# specify and possibly create results directory
if [[ "$fc_para_list" =~ "HEAD" ]]; then
	results_dir=group.results
else
	results_dir=graph.results
fi
[ ! -d ${results_dir} ] && mkdir ${results_dir}
[ ! -d ${results_dir}/output ] && mkdir ${results_dir}/output

# create group mask
sub_list=`ls *Sub*/conn*.results/mask_group_epi+tlrc.HEAD`
3dmask_tool -prefix $results_dir/mask/mask_group.conn \
	-frac 0.3 -input \
	$sub_list -overwrite

# create group gm mask
sub_list=`ls *Sub*/conn*.results/aseg_func_gm_infl+tlrc.HEAD`
3dmask_tool -prefix $results_dir/mask/mask_gm_group.conn \
	-frac 0.3 -input \
	$sub_list -overwrite

# create group visual mask
sub_list=`ls *Sub*/conn*.results/visual_masked+tlrc.HEAD`
3dmask_tool -prefix $results_dir/mask/mask_visual_group.conn \
	-frac 0.3 -input \
	$sub_list -overwrite

[ -f ${batchDir}/run.LME.conn.swarm.sh ] && rm ${batchDir}/run.LME.conn.swarm.sh
fc_para_num=${#fc_para_list[@]}
echo "******** ${fc_para_num} files to analyze **********************"
for fc_para_head in ${fc_para_list[@]}; do	
{	if [[ "$fc_para_head" =~ "HEAD" ]]; then
		fc_para=${fc_para_head%.HEAD}
	else
		fc_para=${fc_para_head}
	fi
	if [ ! -f ${results_dir}/stats/stats.LME.${fc_para_head} ] && [[ ! "$fc_para_head" =~ "Geff" ]] \
		&& [[ ! "$fc_para_head" =~ "sigma" ]]; then
		# echo "tcsh ${batchDir}/LME.conn.sh ${fc_para} ${results_dir} ${rsfc_dir}" >> ${batchDir}/run.LME.conn.swarm.sh
		tcsh ${batchDir}/LME.conn.sh ${fc_para} ${results_dir} ${rsfc_dir}
	fi
}&
done
wait

cd ${batchDir}
echo generating swarm script as following:
cat run.LME.conn.swarm.sh
echo running swarm script with ...
if  [[ "$fc_para_list" =~ "HEAD" ]]; then
	echo "swarm -g 6 -t 6 --time 02:00:00 -f run.LME.conn.swarm.sh --logdir ${dataDir}/${results_dir}/output"
elif [[ "$fc_para_list" =~ "z1" ]]; then
	echo "swarm -g 6 -t 8 --time 04:00:00 -f run.LME.conn.swarm.sh --logdir ${dataDir}/${results_dir}/output"
else
	echo "swarm -g 2 -t 2 --time 20:00 -f run.LME.conn.swarm.sh --logdir ${dataDir}/${results_dir}/output"
fi

