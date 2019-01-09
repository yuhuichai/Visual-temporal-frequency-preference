#!/bin/sh
module load afni R
# batch dir
batchDir=/data/chaiy3/visualFreq/batch
# data directory
dataDir=/data/chaiy3/visualFreq/group.results/
# mask=/data/chaiy3/visualFreq/group.event.results/freqmap/visual_mask+tlrc

cd ${dataDir}
[ ! -d freqmap ] && mkdir freqmap

# # 3dcopy ${mask} freqmap/visual_mask -overwrite
# 3dcalc -a stats/Clust_fcm_Tha_fix20_mask_0001+tlrc \
# 	-b stats/Clust_fcm_Tha_fix10_mask_0001+tlrc \
# 	-c stats/Clust_fcm_Tha_fix1020_mask_0001+tlrc \
# 	-d stats/Clust_fcm_Tha_fix011020_mask_0001+tlrc \
# 	-expr "or(a,b,c,d)" \
# 	-prefix freqmap/visual_mask -overwrite

# 3dcopy stats/Clust_fcm_Tha_fix1020_mask+tlrc freqmap/visual_mask -overwrite
# 3dcopy stats/Clust_reho_fix10_mask+tlrc freqmap/reho_mask -overwrite

cd ${dataDir}/stats
for freqweigh in stats.LME.fcs_gm_Tha_fcs_gm_visual_pos_z+tlrc.HEAD; do #stats.LME.fc_reho_norm+tlrc.HEAD
{	
	if [[ "$freqweigh" =~ "reho" ]]; then
		mask=reho_mask+tlrc
	else
		mask=visual_mask+tlrc
	fi
	# 3dcalc -a ${freqweigh}[3] \
	# 	-b ${freqweigh}[5] \
	# 	-c ${freqweigh}[7] \
	# 	-d ${freqweigh}[9] \
	# 	-e ../freqmap/${mask} \
	# 	-expr "(1*a+10*b+20*c+40*d)/(a+b+c+d)*step(e)" \
	# 	-prefix ../freqmap/freqmap.${freqweigh%+tlrc.HEAD} -overwrite

	# 3dcalc -a ${freqweigh}"[fix]" \
	# 	-b ${freqweigh}"[vs01Hz]" \
	# 	-c ${freqweigh}"[vs10Hz]" \
	# 	-d ${freqweigh}"[vs20Hz]" \
	# 	-e ${freqweigh}"[vs40Hz]" \
	# 	-f ../freqmap/${mask} \
	# 	-expr "(1*b+10*c+20*d+40*e)/(a+b+c+d+e)*step(f)" \
	# 	-prefix ../freqmap/freqmap_fix.${freqweigh%+tlrc.HEAD} -overwrite

	3dbucket -prefix ../freqmap/rm.mean_beta.${freqweigh%+tlrc.HEAD} \
		${freqweigh}"[fix-vs01Hz]" \
		${freqweigh}"[fix-vs10Hz]" \
		${freqweigh}"[fix-vs20Hz]" \
		${freqweigh}"[fix-vs40Hz]" \
		-overwrite

	3dcalc -a ../freqmap/rm.mean_beta.${freqweigh%.HEAD} -expr "-a" \
		-prefix ../freqmap/mean_beta.${freqweigh%+tlrc.HEAD} -overwrite

	rm ../freqmap/rm.mean_beta.${freqweigh%.HEAD}*
}&
done
wait



