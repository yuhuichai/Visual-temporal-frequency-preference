dataDir=/data/chaiy3/visualFreq
batchDir=/data/chaiy3/visualFreq/batch

cd $dataDir
# [ ! -d Kmeans_ts ] && mkdir Kmeans_ts
# [ -f Kmeans_ts/${effect}.1D ] && rm Kmeans_ts/${effect}.1D

for roiFile in Kmeans_*.mean_beta.freqmap*+orig.HEAD; do
	betaFile=${roiFile#*.}
	3dcalc -a ${roiFile} -expr a -datum short -prefix ${roiFile%+orig.HEAD}_short -overwrite
	for Knum in 2 3 4 5; do
		effect=K${Knum}.${roiFile%+orig.HEAD}
		echo "***************** start with ${effect} ********************"
		3dROIstats -quiet -mask ${roiFile%+orig.HEAD}_short+orig[K${Knum}] ${betaFile} > ${effect}.1D -overwrite
	done
done
