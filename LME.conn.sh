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
        if ( ${fc_para} =~ fcs_vs* ) then
        	set mask_file = mask_visual_group.conn+tlrc
        endif
else 
        set mask_file = mask_group.conn+tlrc
endif
echo ${mask_file}

cd $dataDir

3dLME -prefix ${results_dir}/stats/stats.LME.${fc_para} \
	-jobs 6 \
	-model "Cond" \
	-SS_type 3 \
	-ranEff '~1' \
	-mask ${results_dir}/mask/${mask_file} \
	-num_glt 18 \
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
	-gltLabel 17 'fix-vs10Hz-vs20Hz' -gltCode	17 'Cond : 1*fix -0.5*vs10Hz -0.5*vs20Hz' \
	-gltLabel 18 'fix-vs01Hz-vs10Hz-vs20Hz' -gltCode	18 'Cond : 0.99*fix -0.33*vs01Hz -0.33*vs10Hz -0.33*vs20Hz' \
	-dataTable \
	Subj Cond InputFile \
	S002 fix "170201Sub002/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S003 fix "170208Sub003/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S004 fix "170222Sub004/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S005 fix "170222Sub005/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S006 fix "170301Sub006/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S007 fix "170308Sub007/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S008 fix "170315Sub008/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S009 fix "170322Sub009/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S010 fix "170329Sub010/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S011 fix "170329Sub011/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S012 fix "170405Sub012/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S013 fix "170419Sub013/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S014 fix "170503Sub014/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S015 fix "170503Sub015/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S016 fix "170510Sub016/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S017 fix "170524Sub017/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S018 fix "170614Sub018/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S019 fix "170620Sub019/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S020 fix "170712Sub020/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S021 fix "170720Sub021/conn_fix.results/${rsfc_dir}/${fc_para}" \
	S002 vs01Hz "170201Sub002/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S003 vs01Hz "170208Sub003/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S004 vs01Hz "170222Sub004/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S005 vs01Hz "170222Sub005/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S006 vs01Hz "170301Sub006/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S007 vs01Hz "170308Sub007/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S008 vs01Hz "170315Sub008/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S009 vs01Hz "170322Sub009/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S010 vs01Hz "170329Sub010/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S011 vs01Hz "170329Sub011/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S012 vs01Hz "170405Sub012/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S013 vs01Hz "170419Sub013/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S014 vs01Hz "170503Sub014/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S015 vs01Hz "170503Sub015/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S016 vs01Hz "170510Sub016/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S017 vs01Hz "170524Sub017/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S018 vs01Hz "170614Sub018/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S019 vs01Hz "170620Sub019/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S020 vs01Hz "170712Sub020/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S021 vs01Hz "170720Sub021/conn_01Hz.results/${rsfc_dir}/${fc_para}" \
	S003 vs10Hz "170208Sub003/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S004 vs10Hz "170222Sub004/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S005 vs10Hz "170222Sub005/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S006 vs10Hz "170301Sub006/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S007 vs10Hz "170308Sub007/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S008 vs10Hz "170315Sub008/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S009 vs10Hz "170322Sub009/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S010 vs10Hz "170329Sub010/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S011 vs10Hz "170329Sub011/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S012 vs10Hz "170405Sub012/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S013 vs10Hz "170419Sub013/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S014 vs10Hz "170503Sub014/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S016 vs10Hz "170510Sub016/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S017 vs10Hz "170524Sub017/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S018 vs10Hz "170614Sub018/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S019 vs10Hz "170620Sub019/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S020 vs10Hz "170712Sub020/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S021 vs10Hz "170720Sub021/conn_10Hz.results/${rsfc_dir}/${fc_para}" \
	S003 vs20Hz "170208Sub003/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S004 vs20Hz "170222Sub004/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S006 vs20Hz "170301Sub006/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S008 vs20Hz "170315Sub008/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S009 vs20Hz "170322Sub009/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S010 vs20Hz "170329Sub010/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S011 vs20Hz "170329Sub011/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S012 vs20Hz "170405Sub012/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S013 vs20Hz "170419Sub013/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S014 vs20Hz "170503Sub014/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S015 vs20Hz "170503Sub015/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S016 vs20Hz "170510Sub016/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S017 vs20Hz "170524Sub017/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S018 vs20Hz "170614Sub018/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S019 vs20Hz "170620Sub019/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S020 vs20Hz "170712Sub020/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S021 vs20Hz "170720Sub021/conn_20Hz.results/${rsfc_dir}/${fc_para}" \
	S002 vs40Hz "170201Sub002/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S003 vs40Hz "170208Sub003/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S004 vs40Hz "170222Sub004/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S006 vs40Hz "170301Sub006/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S008 vs40Hz "170315Sub008/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S009 vs40Hz "170322Sub009/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S010 vs40Hz "170329Sub010/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S011 vs40Hz "170329Sub011/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S012 vs40Hz "170405Sub012/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S013 vs40Hz "170419Sub013/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S014 vs40Hz "170503Sub014/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S015 vs40Hz "170503Sub015/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S016 vs40Hz "170510Sub016/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S017 vs40Hz "170524Sub017/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S018 vs40Hz "170614Sub018/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S019 vs40Hz "170620Sub019/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S020 vs40Hz "170712Sub020/conn_40Hz.results/${rsfc_dir}/${fc_para}" \
	S021 vs40Hz "170720Sub021/conn_40Hz.results/${rsfc_dir}/${fc_para}"


