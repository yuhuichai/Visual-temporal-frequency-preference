#!/bin/sh
module load afni R
rsfc_dir=rsfc
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq/
cd ${dataDir}/170510Sub016/conn_fix.results/${rsfc_dir}
fc_para_list=($(ls *.HEAD))
cd ${dataDir}

# specify and possibly create results directory
if [[ "$fc_para_list" =~ "HEAD" ]]; then
	results_dir=group.results
else
	results_dir=graph.results
fi
[ ! -d ${results_dir} ] && mkdir ${results_dir}
[ ! -d ${results_dir}/output ] && mkdir ${results_dir}/output


for fc_para_head in ${fc_para_list[@]}; do	
{	if [[ "$fc_para_head" =~ "HEAD" ]]; then
		fc_para=${fc_para_head%.HEAD}
	else
		fc_para=${fc_para_head}
	fi
	if [ ! -f ${results_dir}/stats.LME.gamma.${fc_para_head} ] && [[ ! "$fc_para_head" =~ "Geff" ]] \
		&& [[ ! "$fc_para_head" =~ "sigma" ]]; then
		echo "tcsh ${batchDir}/LME.conn.gamma.sh ${fc_para} ${results_dir} ${rsfc_dir}" >> ${batchDir}/run.LME.conn.gamma.swarm.sh
		# tcsh ${batchDir}/LME.conn.gamma.sh ${fc_para} ${results_dir} ${rsfc_dir}
	fi
}&
done
wait

cd ${batchDir}
echo generating swarm script as following:
cat run.LME.conn.gamma.swarm.sh
echo running swarm script with ...
if  [[ "$fc_para_list" =~ "HEAD" ]]; then
	echo "swarm -g 2 -t 6 --time 03:00:00 -f run.LME.conn.gamma.swarm.sh --logdir ${dataDir}/${results_dir}/output"
elif [[ "$fc_para_list" =~ "z1col" ]]; then
	echo "swarm -g 4 -t 10 --time 08:00:00 -f run.LME.conn.gamma.swarm.sh --logdir ${dataDir}/${results_dir}/output"
else
	echo "swarm -g 1 -t 1 --time 10:00 -f run.LME.conn.gamma.swarm.sh --logdir ${dataDir}/${results_dir}/output"
fi

