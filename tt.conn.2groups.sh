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

3dttest++ -prefix ${results_dir}/stats.tt40Hz_2grps.${fc_para}      \
	-setA delta \
	S003 "170208Sub003/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S008 "170315Sub008/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S012 "170405Sub012/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S013 "170419Sub013/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	-setB gamma \
	S004 "170222Sub004/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S006 "170301Sub006/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S009 "170322Sub009/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S010 "170329Sub010/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S011 "170329Sub011/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S016 "170510Sub016/conn_40Hz.results/${rsfc_dir}/${fc_para}[0]" \
	-overwrite \
	# -mask ${results_dir}/${mask_file} &

3dttest++ -prefix ${results_dir}/stats.ttfix_2grps.${fc_para}      \
	-setA delta \
	S003 "170208Sub003/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S007 "170308Sub007/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S008 "170315Sub008/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S012 "170405Sub012/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S013 "170419Sub013/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	-setB gamma \
	S004 "170222Sub004/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S005 "170222Sub005/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S006 "170301Sub006/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S009 "170322Sub009/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S010 "170329Sub010/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S011 "170329Sub011/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	S016 "170510Sub016/conn_fix.results/${rsfc_dir}/${fc_para}[0]" \
	-overwrite \
	# -mask ${results_dir}/${mask_file} &

3dttest++ -prefix ${results_dir}/stats.tt01Hz_2grps.${fc_para}      \
	-setA delta \
	S003 "170208Sub003/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S007 "170308Sub007/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S008 "170315Sub008/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S012 "170405Sub012/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S013 "170419Sub013/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	-setB gamma \
	S004 "170222Sub004/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S005 "170222Sub005/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S006 "170301Sub006/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S009 "170322Sub009/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S010 "170329Sub010/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S011 "170329Sub011/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S016 "170510Sub016/conn_01Hz.results/${rsfc_dir}/${fc_para}[0]" \
	-overwrite \
	# -mask ${results_dir}/${mask_file} &

3dttest++ -prefix ${results_dir}/stats.tt10Hz_2grps.${fc_para}      \
	-setA delta \
	S003 "170208Sub003/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S007 "170308Sub007/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S008 "170315Sub008/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S012 "170405Sub012/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S013 "170419Sub013/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	-setB gamma \
	S004 "170222Sub004/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S005 "170222Sub005/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S006 "170301Sub006/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S009 "170322Sub009/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S010 "170329Sub010/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S011 "170329Sub011/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S016 "170510Sub016/conn_10Hz.results/${rsfc_dir}/${fc_para}[0]" \
	-overwrite \
	# -mask ${results_dir}/${mask_file} &

3dttest++ -prefix ${results_dir}/stats.tt20Hz_2grps.${fc_para}      \
	-setA delta \
	S003 "170208Sub003/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S008 "170315Sub008/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S012 "170405Sub012/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S013 "170419Sub013/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	-setB gamma \
	S004 "170222Sub004/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S006 "170301Sub006/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S009 "170322Sub009/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S010 "170329Sub010/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S011 "170329Sub011/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	S016 "170510Sub016/conn_20Hz.results/${rsfc_dir}/${fc_para}[0]" \
	-overwrite \
	# -mask ${results_dir}/${mask_file} &

