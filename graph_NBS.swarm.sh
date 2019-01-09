#!/bin/sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq/graph.results
cd ${dataDir}

[ -f ${batchDir}/run.graph_NBS.swarm.sh ] && rm ${batchDir}/run.graph_NBS.swarm.sh

# for cctype in roi*0_all*; do
# 	cd $dataDir/$cctype
# 	for stimVS in *Hz; do
# 		for stat_method in nbs_intensity; do # fdr nbs_extent nbs_intensity 2.4 2.8 3.2 3.6 4.0
# 			for cnst_sign in pos neg; do
# 				for t_thresh in 2.4 2.8 3.2 3.6 4.0; do
# 					echo "bash ${batchDir}/run_graph_NBS.sh /usr/local/matlab-compiler/v91 $dataDir/$cctype $stimVS ${stat_method} ${cnst_sign} ${t_thresh}" \
# 						>> ${batchDir}/run.graph_NBS.swarm.sh
# 				done
# 			done
# 		done
# 	done
# done

# BrainNet view NBS results
for cctype in stats; do # roi*_all*
{	cd $dataDir/$cctype
	for edge in stats.LME.roi*.edge; do
	{	net_pic=${edge%.edge}.jpg
		if [ ! -f ${net_pic} ]; then
			echo "bash ${batchDir}/run_graph_NBS_viewer.sh /usr/local/matlab-compiler/v91 $dataDir/$cctype $edge" \
				>> ${batchDir}/run.graph_NBS.swarm.sh
			#bash ${batchDir}/run_graph_NBS_viewer.sh /usr/local/matlab-compiler/v91 $dataDir/$cctype $edge
		fi
	}&
	done
	wait
}&
done
wait

cd ${dataDir}
echo ++ generating swarm script as following ...
cat ${batchDir}/run.graph_NBS.swarm.sh
echo ++ running swarm script with ...
echo "swarm -g 2 -t 1 --time 0:10:00 -f run.graph_NBS.swarm.sh --logdir ${dataDir}/output"
echo "++ apply 4g for roi950 fdr"

