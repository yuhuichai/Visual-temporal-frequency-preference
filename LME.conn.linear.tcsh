# 1 group with 2 subjects
# 5 conditions: fix vs40Hz
# Mising data with some subject

set fc_para = $argv[1] # e.g., fc_reho_norm
set dataDir = /Users/chaiy3/Data/visualFreq/
set results_dir = $argv[2]
cd $dataDir

# for 4D file
3dLME -prefix ${results_dir}/stats.LME.${fc_para} \
-jobs 1 \
-model "LocAct" \
-qVars "LocAct" \
-qVarCenters 0 \
-SS_type 3 \
-ranEff '~1+LocAct' \
-mask ${results_dir}/mask_group.conn+tlrc \
-num_glt 1 \
-gltLabel 1 'LocAct' -gltCode	1 'LocAct :' \
-dataTable \
Subj LocAct  InputFile \
S003 0	    "170208Sub003/conn_fix.results/rsfc/${fc_para}[0]" \
S004 0       "170222Sub004/conn_fix.results/rsfc/${fc_para}[0]" \
S005 0	    "170222Sub005/conn_fix.results/rsfc/${fc_para}[0]" \
S006 0	    "170301Sub006/conn_fix.results/rsfc/${fc_para}[0]" \
S003 0.6272  "170208Sub003/conn_01Hz.results/rsfc/${fc_para}[0]" \
S004 0.6317  "170222Sub004/conn_01Hz.results/rsfc/${fc_para}[0]" \
S005 0.2106  "170222Sub005/conn_01Hz.results/rsfc/${fc_para}[0]" \
S006 0.4501  "170301Sub006/conn_01Hz.results/rsfc/${fc_para}[0]" \
S003 0.5146  "170208Sub003/conn_10Hz.results/rsfc/${fc_para}[0]" \
S004 0.866   "170222Sub004/conn_10Hz.results/rsfc/${fc_para}[0]" \
S005 0.3456  "170222Sub005/conn_10Hz.results/rsfc/${fc_para}[0]" \
S006 0.5582  "170301Sub006/conn_10Hz.results/rsfc/${fc_para}[0]" \
S003 0.1141  "170208Sub003/conn_20Hz.results/rsfc/${fc_para}[0]" \
S004 0.5206  "170222Sub004/conn_20Hz.results/rsfc/${fc_para}[0]" \
S006 0.1815  "170301Sub006/conn_20Hz.results/rsfc/${fc_para}[0]" \
S003 -0.0375 "170208Sub003/conn_40Hz.results/rsfc/${fc_para}[0]" \
S004 -0.1518 "170222Sub004/conn_40Hz.results/rsfc/${fc_para}[0]" \
S006 -0.0062 "170301Sub006/conn_40Hz.results/rsfc/${fc_para}[0]" \

