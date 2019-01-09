#!/bin/sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}

[ -f ${batchDir}/run.graph_analysis.swarm.sh ] && rm ${batchDir}/run.graph_analysis.swarm.sh
for subID in *Sub*; do 
	subDir=${dataDir}/${subID}

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
		for graph in roi950_all*_cor_zcc.1D; do
			for thr in 1; do
				for type in 2; do
					echo "bash ${batchDir}/run_graph_analysis.sh /usr/local/matlab-compiler/v91 $subDir/$run/rsfc $graph $thr $type" \
						>> ${batchDir}/run.graph_analysis.swarm.sh
				done
			done
		done
	done
done

cd ${dataDir}
[ ! -d swarm_output ] && mkdir swarm_output
echo generating swarm script as following ...
cat ${batchDir}/run.graph_analysis.swarm.sh
echo running swarm script with ...
echo "swarm -g 2 -t 2 --time 01:00:00 -f run.graph_analysis.swarm.sh --logdir ${dataDir}/swarm_output"