# 1 group with 5 subjects
# 5 conditions: fix vs01Hz vs10Hz vs20Hz vs40Hz
# Mising data with some subject
module load afni R
set fc_para = $argv[1] # e.g., fc_reho_norm
set dataDir = /data/chaiy3/visualFreq/
set results_dir = $argv[2]
set rsfc_dir = $argv[3]

if ( ${fc_para} =~ *fcs* ) then
        set mask_file = mask_gm_group.conn+tlrc
else 
        set mask_file = mask_group.conn+tlrc
endif
echo ${mask_file}

cd $dataDir

3dLME -prefix ${results_dir}/stats.LME.gamma.${fc_para} \
	-jobs 6 \
	-model "Cond" \
	-SS_type 3 \
	-ranEff '~1' \
	-mask ${results_dir}/${mask_file} \
	-num_glt 16 \
	-gltLabel 1 'fix-vs01Hz' -gltCode	1 'Cond : 1*fix -1*vs01Hz' \
	-gltLabel 2 'fix-vs10Hz' -gltCode	2 'Cond : 1*fix -1*vs10Hz' \
	-gltLabel 3 'fix-vs20Hz' -gltCode	3 'Cond : 1*fix -1*vs20Hz' \
	-gltLabel 4 'fix-vs40Hz' -gltCode	4 'Cond : 1*fix -1*vs40Hz' \
	-gltLabel 5 'vs01Hz-vs10Hz' -gltCode	5 'Cond : 1*vs01Hz -1*vs10Hz' \
	-gltLabel 6 'vs01Hz-vs20Hz' -gltCode	6 'Cond : 1*vs01Hz -1*vs20Hz' \
	-gltLabel 7 'vs01Hz-vs40Hz' -gltCode	7 'Cond : 1*vs01Hz -1*vs40Hz' \
	-gltLabel 8 'vs10Hz-vs20Hz' -gltCode	8 'Cond : 1*vs10Hz -1*vs20Hz' \
	-gltLabel 9 'vs10Hz-vs40Hz' -gltCode	9 'Cond : 1*vs10Hz -1*vs40Hz' \
	-gltLabel 10 'vs20Hz-vs40Hz' -gltCode	10 'Cond : 1*vs20Hz -1*vs40Hz' \
	-gltLabel 11 'fix' -gltCode	11 'Cond : 1*fix' \
	-gltLabel 12 'vs01Hz' -gltCode	12 'Cond : 1*vs01Hz' \
	-gltLabel 13 'vs10Hz' -gltCode	13 'Cond : 1*vs10Hz' \
	-gltLabel 14 'vs20Hz' -gltCode	14 'Cond : 1*vs20Hz' \
	-gltLabel 15 'vs40Hz' -gltCode	15 'Cond : 1*vs40Hz' \
	-gltLabel 16 'mean' -gltCode	16 'Cond : 0.2*fix +0.2*vs01Hz +0.2*vs10Hz +0.2*vs20Hz +0.2*vs40Hz' \
	-dataTable \
	Subj Cond InputFile \
	S004 fix "170222Sub004/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S005 fix "170222Sub005/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S006 fix "170301Sub006/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S009 fix "170322Sub009/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S010 fix "170329Sub010/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S011 fix "170329Sub011/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S016 fix "170510Sub016/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S004 vs01Hz "170222Sub004/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S005 vs01Hz "170222Sub005/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S006 vs01Hz "170301Sub006/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S009 vs01Hz "170322Sub009/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S010 vs01Hz "170329Sub010/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S011 vs01Hz "170329Sub011/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S016 vs01Hz "170510Sub016/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S004 vs10Hz "170222Sub004/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S005 vs10Hz "170222Sub005/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S006 vs10Hz "170301Sub006/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S009 vs10Hz "170322Sub009/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S010 vs10Hz "170329Sub010/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S011 vs10Hz "170329Sub011/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S016 vs10Hz "170510Sub016/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S004 vs20Hz "170222Sub004/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S006 vs20Hz "170301Sub006/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S009 vs20Hz "170322Sub009/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S010 vs20Hz "170329Sub010/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S011 vs20Hz "170329Sub011/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S016 vs20Hz "170510Sub016/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S004 vs40Hz "170222Sub004/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S006 vs40Hz "170301Sub006/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S009 vs40Hz "170322Sub009/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S010 vs40Hz "170329Sub010/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S011 vs40Hz "170329Sub011/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S016 vs40Hz "170510Sub016/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" 


