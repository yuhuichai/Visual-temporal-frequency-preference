#!/bin/sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}/graph.results
# M_vec=`ls sort.M_r2_thr0.1_Q*_roi950_allvec_mean.1D`
M_vec=`ls sort.M_40Hz_sensitive.1D`
# M_mean=`ls sort.M_r2_thr0.1_Q*_roi950_allmean_mean.1D`
cd ${dataDir}

[ -f ${batchDir}/run.graph_analysis_module.swarm.sh ] && rm ${batchDir}/run.graph_analysis_module.swarm.sh
for subID in *Sub*; do 
{	subDir=${dataDir}/${subID}

	cd $subDir
	if [[ "$subDir" =~ "002" ]]; then
		conn_dirs=($(ls -d conn_fix* conn_01Hz* conn_40Hz*))
	elif [[ "$subDir" =~ "005" || "$subDir" =~ "007" ]]; then
		conn_dirs=($(ls -d conn_fix* conn_01Hz* conn_10Hz*))
	else 
		conn_dirs=($(ls -d conn*))
	fi
	for run in ${conn_dirs[@]}; do
		cd $subDir/$run/rsfc
		for graph in roi950_allvec_cor_z.1D; do
			if [[ "$graph" =~ "vec" ]]; then
				M_file=${M_vec}
			else
				M_file=${M_mean}
			fi

			for thr in 0.1 0.2 0.3 1; do
				for type in 2; do
					echo "bash ${batchDir}/run_graph_analysis_module.sh /usr/local/matlab-compiler/v91 $subDir/$run/rsfc $graph ${M_file} $thr $type" \
						>> ${batchDir}/run.graph_analysis_module.swarm.sh
					# bash ${batchDir}/run_graph_analysis_module.sh /usr/local/matlab-compiler/v91 $subDir/$run/rsfc $graph ${M_file} $thr $type
				done
			done
		done
	done
}
done
wait

cd ${dataDir}
[ ! -d swarm_output ] && mkdir swarm_output
echo generating swarm script as following ...
cat ${batchDir}/run.graph_analysis_module.swarm.sh
echo running swarm script with ...
echo "swarm -g 1 -t 1 --time 10:00 -f run.graph_analysis_module.swarm.sh --logdir ${dataDir}/swarm_output"
