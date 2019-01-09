# 1 group with 4 subjects
# 7 conditions: vs01Hz vs05Hz vs10Hz vs15Hz vs20Hz vs40Hz vs60Hz
# Mising data with some subject

set dataDir = /Users/chaiy3/Data/visualFreq/
cd $dataDir

# specify and possibly create results directory
set results_dir = group.event.results
if ( ! -d ${results_dir} ) mkdir ${results_dir}

# create group mask
if ( ! -f $results_dir/mask_group.event+tlrc.HEAD ) then
	3dMean -prefix $results_dir/mask_tmp.event \
		170208Sub003/event.results/mask_group_epi+tlrc \
		170222Sub004/event.results/mask_group_epi+tlrc \
		170222Sub005/event.results/mask_group_epi+tlrc \
		170301Sub006/event.results/mask_group_epi+tlrc \
		170308Sub007/event.results/mask_group_epi+tlrc

	3dcalc -a $results_dir/mask_tmp.event+tlrc -expr 'equals(a,1)' \
	     -prefix $results_dir/mask_group.event
	# optional choice, step(a-0.999), get intersection through setting any values 
	# greater than 0.999 to 1, and the rest to 0
	rm -f $results_dir/mask_tmp.event+tlrc*
endif

3dLME -prefix ${results_dir}/stats.LME.event \
-jobs 2 \
-model "Cond" \
-SS_type 3 \
-ranEff '~1' \
-mask ${results_dir}/mask_group.event+tlrc \
-num_glt 21 \
-gltLabel 1 'vs01Hz-vs05Hz' -gltCode	1 'Cond : 1*vs01Hz -1*vs05Hz' \
-gltLabel 2 'vs01Hz-vs10Hz' -gltCode	2 'Cond : 1*vs01Hz -1*vs10Hz' \
-gltLabel 3 'vs01Hz-vs15Hz' -gltCode	3 'Cond : 1*vs01Hz -1*vs15Hz' \
-gltLabel 4 'vs01Hz-vs20Hz' -gltCode	4 'Cond : 1*vs01Hz -1*vs20Hz' \
-gltLabel 5 'vs01Hz-vs40Hz' -gltCode	5 'Cond : 1*vs01Hz -1*vs40Hz' \
-gltLabel 6 'vs01Hz-vs60Hz' -gltCode	6 'Cond : 1*vs01Hz -1*vs60Hz' \
-gltLabel 7 'vs05Hz-vs10Hz' -gltCode	7 'Cond : 1*vs05Hz -1*vs10Hz' \
-gltLabel 8 'vs05Hz-vs15Hz' -gltCode	8 'Cond : 1*vs05Hz -1*vs15Hz' \
-gltLabel 9 'vs05Hz-vs20Hz' -gltCode	9 'Cond : 1*vs05Hz -1*vs20Hz' \
-gltLabel 10 'vs05Hz-vs40Hz' -gltCode	10 'Cond : 1*vs05Hz -1*vs40Hz' \
-gltLabel 11 'vs05Hz-vs60Hz' -gltCode	11 'Cond : 1*vs05Hz -1*vs60Hz' \
-gltLabel 12 'vs10Hz-vs15Hz' -gltCode	12 'Cond : 1*vs10Hz -1*vs15Hz' \
-gltLabel 13 'vs10Hz-vs20Hz' -gltCode	13 'Cond : 1*vs10Hz -1*vs20Hz' \
-gltLabel 14 'vs10Hz-vs40Hz' -gltCode	14 'Cond : 1*vs10Hz -1*vs40Hz' \
-gltLabel 15 'vs10Hz-vs60Hz' -gltCode	15 'Cond : 1*vs10Hz -1*vs60Hz' \
-gltLabel 16 'vs15Hz-vs20Hz' -gltCode	16 'Cond : 1*vs15Hz -1*vs20Hz' \
-gltLabel 17 'vs15Hz-vs40Hz' -gltCode	17 'Cond : 1*vs15Hz -1*vs40Hz' \
-gltLabel 18 'vs15Hz-vs60Hz' -gltCode	18 'Cond : 1*vs15Hz -1*vs60Hz' \
-gltLabel 19 'vs20Hz-vs40Hz' -gltCode	19 'Cond : 1*vs20Hz -1*vs40Hz' \
-gltLabel 20 'vs20Hz-vs60Hz' -gltCode	20 'Cond : 1*vs20Hz -1*vs60Hz' \
-gltLabel 21 'vs40Hz-vs60Hz' -gltCode	21 'Cond : 1*vs40Hz -1*vs60Hz' \
-dataTable \
Subj Cond InputFile \
S001 vs01Hz "170125Sub001/event_iso.results/stats.event_iso_REML+tlrc.HEAD[vs01Hz#0_Coef]" \
S003 vs01Hz "170208Sub003/event.results/stats.event_REML+tlrc.HEAD[vs01Hz#0_Coef]" \
S004 vs01Hz "170222Sub004/event.results/stats.event_REML+tlrc.HEAD[vs01Hz#0_Coef]" \
S005 vs01Hz "170222Sub005/event.results/stats.event_REML+tlrc.HEAD[vs01Hz#0_Coef]" \
S003 vs05Hz "170208Sub003/event.results/stats.event_REML+tlrc.HEAD[vs05Hz#0_Coef]" \
S004 vs05Hz "170222Sub004/event.results/stats.event_REML+tlrc.HEAD[vs05Hz#0_Coef]" \
S005 vs05Hz "170222Sub005/event.results/stats.event_REML+tlrc.HEAD[vs05Hz#0_Coef]" \
S001 vs10Hz "170125Sub001/event_iso.results/stats.event_iso_REML+tlrc.HEAD[vs10Hz#0_Coef]" \
S003 vs10Hz "170208Sub003/event.results/stats.event_REML+tlrc.HEAD[vs10Hz#0_Coef]" \
S004 vs10Hz "170222Sub004/event.results/stats.event_REML+tlrc.HEAD[vs10Hz#0_Coef]" \
S005 vs10Hz "170222Sub005/event.results/stats.event_REML+tlrc.HEAD[vs10Hz#0_Coef]" \
S003 vs15Hz "170208Sub003/event.results/stats.event_REML+tlrc.HEAD[vs15Hz#0_Coef]" \
S004 vs15Hz "170222Sub004/event.results/stats.event_REML+tlrc.HEAD[vs15Hz#0_Coef]" \
S005 vs15Hz "170222Sub005/event.results/stats.event_REML+tlrc.HEAD[vs15Hz#0_Coef]" \
S001 vs20Hz "170125Sub001/event_iso.results/stats.event_iso_REML+tlrc.HEAD[vs20Hz#0_Coef]" \
S003 vs20Hz "170208Sub003/event.results/stats.event_REML+tlrc.HEAD[vs20Hz#0_Coef]" \
S004 vs20Hz "170222Sub004/event.results/stats.event_REML+tlrc.HEAD[vs20Hz#0_Coef]" \
S005 vs20Hz "170222Sub005/event.results/stats.event_REML+tlrc.HEAD[vs20Hz#0_Coef]" \
S001 vs40Hz "170125Sub001/event_iso.results/stats.event_iso_REML+tlrc.HEAD[vs40Hz#0_Coef]" \
S003 vs40Hz "170208Sub003/event.results/stats.event_REML+tlrc.HEAD[vs40Hz#0_Coef]" \
S004 vs40Hz "170222Sub004/event.results/stats.event_REML+tlrc.HEAD[vs40Hz#0_Coef]" \
S005 vs40Hz "170222Sub005/event.results/stats.event_REML+tlrc.HEAD[vs40Hz#0_Coef]" \
S003 vs60Hz "170208Sub003/event.results/stats.event_REML+tlrc.HEAD[vs60Hz#0_Coef]" \
S004 vs60Hz "170222Sub004/event.results/stats.event_REML+tlrc.HEAD[vs60Hz#0_Coef]" \
S005 vs60Hz "170222Sub005/event.results/stats.event_REML+tlrc.HEAD[vs60Hz#0_Coef]"
