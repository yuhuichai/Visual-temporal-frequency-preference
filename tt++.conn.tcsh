#!/bin/tcsh -xef

# created by uber_ttest.py: version 1.1 (October 18, 2012)
# creation date: Fri Feb 10 15:03:55 2017

# ---------------------- set process variables ----------------------
set fc_para = $argv[1] # e.g., fc_reho_norm
set dataDir = /Users/chaiy3/Data/visualFreq/
set results_dir = $argv[2]
cd $dataDir

# ------------------------- 3dttest++, fix vs. 01Hz -------------------------
3dttest++ \
     -prefix ${results_dir}/stats.tt++.fixVS01Hz.${fc_para} \
     -paired \
     -mask ${results_dir}/mask_group.conn+tlrc \
     -setA fix \
          Sub002 "170201Sub002/conn_fix.results/rsfc/${fc_para}[0]" \
          Sub003 "170208Sub003/conn_fix.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_fix.results/rsfc/${fc_para}[0]" \
          Sub005 "170222Sub005/conn_fix.results/rsfc/${fc_para}[0]" \
     -setB 01Hz \
          Sub002 "170201Sub002/conn_01Hz.results/rsfc/${fc_para}[0]" \
          Sub003 "170208Sub003/conn_01Hz.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_01Hz.results/rsfc/${fc_para}[0]" \
          Sub005 "170222Sub005/conn_01Hz.results/rsfc/${fc_para}[0]" 

# ------------------------- 3dttest++, fix vs. 10Hz -------------------------
3dttest++ \
     -prefix ${results_dir}/stats.tt++.fixVS10Hz.${fc_para} \
     -paired \
     -mask ${results_dir}/mask_group.conn+tlrc \
     -setA fix \
          Sub003 "170208Sub003/conn_fix.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_fix.results/rsfc/${fc_para}[0]" \
          Sub005 "170222Sub005/conn_fix.results/rsfc/${fc_para}[0]" \
     -setB 10Hz \
          Sub003 "170208Sub003/conn_10Hz.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_10Hz.results/rsfc/${fc_para}[0]" \
          Sub005 "170222Sub005/conn_10Hz.results/rsfc/${fc_para}[0]" 


# ------------------------- 3dttest++, fix vs. 40Hz -------------------------
3dttest++ \
     -prefix ${results_dir}/stats.tt++.fixVS40Hz.${fc_para} \
     -paired \
     -mask ${results_dir}/mask_group.conn+tlrc \
     -setA fix \
          Sub002 "170201Sub002/conn_fix.results/rsfc/${fc_para}[0]" \
          Sub003 "170208Sub003/conn_fix.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_fix.results/rsfc/${fc_para}[0]" \
     -setB 40Hz \
          Sub002 "170201Sub002/conn_40Hz.results/rsfc/${fc_para}[0]" \
          Sub003 "170208Sub003/conn_40Hz.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_40Hz.results/rsfc/${fc_para}[0]" 

# ------------------------- 3dttest++, 01Hz vs. 10Hz -------------------------
3dttest++ \
     -prefix ${results_dir}/stats.tt++.01VS10Hz.${fc_para} \
     -paired \
     -mask ${results_dir}/mask_group.conn+tlrc \
     -setA 01Hz \
          Sub003 "170208Sub003/conn_01Hz.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_01Hz.results/rsfc/${fc_para}[0]" \
          Sub005 "170222Sub005/conn_01Hz.results/rsfc/${fc_para}[0]" \
     -setB 10Hz \
          Sub003 "170208Sub003/conn_10Hz.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_10Hz.results/rsfc/${fc_para}[0]" \
          Sub005 "170222Sub005/conn_10Hz.results/rsfc/${fc_para}[0]" 

# ------------------------- 3dttest++, 01Hz vs. 40Hz -------------------------
3dttest++ \
     -prefix ${results_dir}/stats.tt++.01VS40Hz.${fc_para} \
     -paired \
     -mask ${results_dir}/mask_group.conn+tlrc \
     -setA 01Hz \
          Sub002 "170201Sub002/conn_01Hz.results/rsfc/${fc_para}[0]" \
          Sub003 "170208Sub003/conn_01Hz.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_01Hz.results/rsfc/${fc_para}[0]" \
     -setB 40Hz \
          Sub002 "170201Sub002/conn_40Hz.results/rsfc/${fc_para}[0]" \
          Sub003 "170208Sub003/conn_40Hz.results/rsfc/${fc_para}[0]" \
          Sub004 "170222Sub004/conn_40Hz.results/rsfc/${fc_para}[0]" 


