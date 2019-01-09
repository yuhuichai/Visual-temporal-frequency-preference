#!/bin/sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq/graph.results/stats
cd ${dataDir}

[ -f ${batchDir}/run.graph_stats_draw.swarm.sh ] && rm ${batchDir}/run.graph_stats_draw.swarm.sh
for graph in stats.LME.roi*0_all*_*_thr1.1D; do
{	if [ ! -f ${graph%.1D}+tlrc.HEAD ] && [[ ! "$graph" =~ "z1col" ]]; then
		echo "bash ${batchDir}/graph_stats_draw.sh $graph" \
			>> ${batchDir}/run.graph_stats_draw.swarm.sh
		# bash ${batchDir}/graph_stats_draw.sh $graph
	fi
}&
done
wait

echo generating swarm script as following ...
cat ${batchDir}/run.graph_stats_draw.swarm.sh
echo running swarm script with ...
echo "swarm -g 3 -t 17 --time 40:00 -f run.graph_stats_draw.swarm.sh --logdir /data/chaiy3/visualFreq/swarm_output"