#!/bin/sh
module load afni
rsfc_dir=rsfc
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq/
cd ${dataDir}/170222Sub004/conn_fix.results/${rsfc_dir}
cor_mat_list=($(ls roi*all*cor_z.1D))
echo ${cor_mat_list[@]}
cd ${dataDir}

# specify and possibly create results directory
results_dir=graph.results
[ ! -d ${results_dir} ] && mkdir ${results_dir}
[ ! -d ${results_dir}/output ] && mkdir ${results_dir}/output

# create group graph matric
for cor_mat in ${cor_mat_list[@]}; do
{
	for stim in fix 01Hz 10Hz 20Hz 40Hz; do
	{	
		if [[ "$stim" =~ "fix" || "$stim" =~ "01Hz" ]]; then
			3dMean -overwrite -prefix $results_dir/rm.${stim}_${cor_mat} \
				170201Sub002/conn_fix.results/${rsfc_dir}/${cor_mat}\' \
				170208Sub003/conn_${stim}.results/${rsfc_dir}/${cor_mat}\' \
				170222Sub004/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'	\
				170222Sub005/conn_fix.results/${rsfc_dir}/${cor_mat}\' \
				170301Sub006/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'	\
				170308Sub007/conn_fix.results/${rsfc_dir}/${cor_mat}\' \
				170315Sub008/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'
		elif [[ "$stim" =~ "10Hz" ]]; then
			3dMean -overwrite -prefix $results_dir/rm.${stim}_${cor_mat} \
				170208Sub003/conn_${stim}.results/${rsfc_dir}/${cor_mat}\' \
				170222Sub004/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'	\
				170222Sub005/conn_fix.results/${rsfc_dir}/${cor_mat}\' \
				170301Sub006/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'	\
				170308Sub007/conn_fix.results/${rsfc_dir}/${cor_mat}\' \
				170315Sub008/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'
		elif [[ "$stim" =~ "20Hz" ]]; then
			3dMean -overwrite -prefix $results_dir/rm.${stim}_${cor_mat} \
				170208Sub003/conn_${stim}.results/${rsfc_dir}/${cor_mat}\' \
				170222Sub004/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'	\
				170301Sub006/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'	\
				170315Sub008/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'
		elif [[ "$stim" =~ "40Hz" ]]; then
			3dMean -overwrite -prefix $results_dir/rm.${stim}_${cor_mat} \
				170201Sub002/conn_fix.results/${rsfc_dir}/${cor_mat}\' \
				170208Sub003/conn_${stim}.results/${rsfc_dir}/${cor_mat}\' \
				170222Sub004/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'	\
				170301Sub006/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'	\
				170315Sub008/conn_${stim}.results/${rsfc_dir}/${cor_mat}\'
		fi
		wait
		1dcat $results_dir/rm.${stim}_${cor_mat} > $results_dir/${stim}_${cor_mat}
		# rm rm.${stim}_${cor_mat}
	}&
	done
	wait
}&
done
wait
