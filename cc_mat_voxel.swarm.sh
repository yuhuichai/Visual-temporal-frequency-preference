#!/bin/sh
module load afni
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}

# create group gm mask
sub_list=`ls *Sub*/conn*.results/aseg_func_gm_infl+tlrc.HEAD`
3dmask_tool -prefix graph.results/mask/mask_gm_group.cc \
	-frac 0.7 -input \
	$sub_list -overwrite
3dresample -dxyz 6 6 6 -prefix graph.results/mask/mask_gm_6mm_group.cc+tlrc \
	-input graph.results/mask/mask_gm_group.cc+tlrc. -overwrite
rm graph.results/mask/mask_gm_group.cc+tlrc*
mask=/data/chaiy3/visualFreq/graph.results/mask/mask_gm_6mm_group.cc+tlrc
echo "================= voxel numbers in mask =================="
3dBrickStat -count -non-zero ${mask}

[ -f ${batchDir}/run.cc_mat_voxel.swarm.sh ] && rm ${batchDir}/run.cc_mat_voxel.swarm.sh
for subID in *Sub*; do 
{	subDir=${dataDir}/${subID}

	cd $subDir
	conn_dirs=($(ls -d conn*))
	for run in ${conn_dirs[@]}; do
		echo "bash ${batchDir}/cc_mat_voxel.sh $subDir $run $mask" >> ${batchDir}/run.cc_mat_voxel.swarm.sh
		# bash ${batchDir}/cc_mat_voxel.sh $subDir $run $mask
	done
}&
done
wait

cd ${dataDir}
[ ! -d swarm_output ] && mkdir swarm_output
echo generating swarm script as following ...
cat ${batchDir}/run.cc_mat_voxel.swarm.sh
echo running swarm script with ...
echo "swarm -g 8 -t 6 --time 01:30:00 -f run.cc_mat_voxel.swarm.sh --logdir ${dataDir}/swarm_output"