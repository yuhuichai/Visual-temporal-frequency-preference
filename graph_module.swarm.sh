#!/bin/sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq/graph.results
cd ${dataDir}

[ -f ${batchDir}/run.graph_module.swarm.sh ] && rm ${batchDir}/run.graph_module.swarm.sh
for graph in roi950_allvec*.1D; do
{	gamma=2
	threshold=0.1
	bash ${batchDir}/run_graph_module.sh /usr/local/matlab-compiler/v91 $graph $gamma
	# echo "bash ${batchDir}/run_graph_module.sh /usr/local/matlab-compiler/v91 $graph $gamma $threshold" \
	# 	>> ${batchDir}/run.graph_module.swarm.sh
}&
done
wait

# cd ${dataDir}
# [ ! -d output ] && mkdir output
# echo generating swarm script as following ...
# cat ${batchDir}/run.graph_module.swarm.sh
# echo running swarm script with ...
# echo "swarm -g 1 -t 1 --time 00:08:00 -f run.graph_module.swarm.sh --logdir ${dataDir}/output"