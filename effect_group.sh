dataDir=/Volumes/chai/visualFreq
batchDir=/Volumes/chai/visualFreq/batch
roiFile=/Volumes/chai/visualFreq/group.results/mask_gm_group.conn+tlrc
resultDir=/Volumes/chai/visualFreq/group.effects

cd ${dataDir}/group.results
3dcopy stats.LME.fcs_pos_wt_cerebellum_z+tlrc fcs_p_tmp0.1D
3dcopy stats.LME.fcs_neg_wt_cerebellum_z+tlrc fcs_n_tmp0.1D
3dcopy ${roiFile} mask_tmp0.1D
1dcat fcs_p_tmp0.1D > fcs_p_tmp1.1D
1dcat fcs_n_tmp0.1D > fcs_n_tmp1.1D

1dcat mask_tmp0.1D > mask_stims.1D
1dcat fcs_p_tmp1.1D[23,25,27,29,31] > fcs_pos_wt_cerebellum_z_stims.1D
1dcat fcs_n_tmp1.1D[23,25,27,29,31] > fcs_neg_wt_cerebellum_z_stims.1D

mv -f *stims.1D ${resultDir}/
rm *tmp*.1D

# 1d_tool.py -show_rows_cols -infile fcs_pos_wt_cerebellum_z_stims.1D