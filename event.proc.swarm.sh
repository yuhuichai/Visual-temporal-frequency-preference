#!/bin/sh
# swarm loop for runing event.proc.sh
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq
cd ${dataDir}

[ -f ${batchDir}/run.event.proc.swarm.sh ] && rm ${batchDir}/run.event.proc.swarm.sh
for subID in *Sub021; do 
	subDir=${dataDir}/${subID}
	rm -rf ${subDir}/event.results
	echo "tcsh ${batchDir}/event.proc.40Hz.sh ${subDir}" >> ${batchDir}/run.event.proc.swarm.sh
done

cd ${dataDir}
[ ! -d swarm_output ] && mkdir swarm_output
echo ++ generating swarm script as following:
cat ${batchDir}/run.event.proc.swarm.sh
echo running swarm script with ...
echo "swarm -g 15 -t 8 --time 06:00:00 -f run.event.proc.swarm.sh --logdir ${dataDir}/swarm_output"