#!/bin/sh
module load afni R
rsfc_dir=rsfc
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq/
cd ${dataDir}/170510Sub016/conn_fix.results/${rsfc_dir}
fc_para_list=($(ls roi950_allvec_str_thr*.1D))
cd ${dataDir}

# specify and possibly create results directory
if [[ "$fc_para_list" =~ "HEAD" ]]; then
	results_dir=group.results
else
	results_dir=graph.results
fi
[ ! -d ${results_dir} ] && mkdir ${results_dir}
[ ! -d ${results_dir}/output ] && mkdir ${results_dir}/output

fc_para_num=${#fc_para_list}
for fc_para_head in ${fc_para_list[@]}; do	
{	if [[ "$fc_para_head" =~ "HEAD" ]]; then
		fc_para=${fc_para_head%.HEAD}
	else
		fc_para=${fc_para_head}
	fi
	# echo "tcsh ${batchDir}/tt.conn.2groups.sh ${fc_para} ${results_dir} ${rsfc_dir}" >> ${batchDir}/run.tt.conn.2groups.swarm.sh
	tcsh ${batchDir}/tt.conn.2groups.sh ${fc_para} ${results_dir} ${rsfc_dir}
}&
done
wait

cd ${batchDir}
echo generating swarm script as following:
cat run.tt.conn.2groups.swarm.sh
echo running swarm script with ...
echo "swarm -g 1 -t 1 --time 20:00 -f run.tt.conn.2groups.swarm.sh --logdir ${dataDir}/${results_dir}/output"

