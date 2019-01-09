#!/bin/tcsh -xef
# group analysis of activity for stimulation at different temporal frequencies

# created by uber_ttest.py: version 1.1 (October 18, 2012)
# creation date: Fri Feb 10 15:03:55 2017

# ---------------------- set process variables ----------------------
set cnst = $argv[1]

# specify and possibly create results directory
set results_dir = group.event.results

# # ------------------------- 3dMEMA -------------------------
# gen_group_command.py -command 3dMEMA                               \
#                -write_script $results_dir/mema.${cnst}.tcsh  \
#                -prefix $results_dir/mema.${cnst}    \
#                -dsets *Sub*/event.results/stats.event_REML.transient+tlrc.HEAD    \
#                -subs_betas "${cnst}#0_Coef"                   \
#                -subs_tstats "${cnst}#0_Tstat"                 \
#                -set_labels ${cnst}                                \
#                -options                                            \
#                     -mask $results_dir/mask_group.event+tlrc    \
#                -overwrite

# tcsh $results_dir/mema.${cnst}.tcsh
# rm -f $results_dir/mema.${cnst}.tcsh

# ------------------------- 3dttest++ -------------------------
gen_group_command.py -command 3dttest++                               \
               -write_script $results_dir/tt++.${cnst}.tcsh  \
               -prefix $results_dir/tt++.${cnst}    \
               -dsets *Sub*/event.results/stats.event.transient+tlrc.HEAD    \
               -subs_betas "${cnst}#0_Coef"                   \
               -set_labels ${cnst}                                \
               -options                                            \
               		-overwrite
                    # -mask $results_dir/mask_group.event+tlrc       \

# # ------------------------- 3dttest++ -------------------------
# gen_group_command.py -command 3dttest++                               \
#                -write_script $results_dir/tt++.${cnst}.tcsh  \
#                -prefix $results_dir/tt++.${cnst}    \
#                -dsets *Sub00*/event.results/stats.event.transient+tlrc.HEAD    \
#                	*Sub010/event.results/stats.event.transient+tlrc.HEAD    \
#                	*Sub011/event.results/stats.event.transient+tlrc.HEAD    \
#                	*Sub012/event.results/stats.event.transient+tlrc.HEAD    \
#                	*Sub013/event.results/stats.event.transient+tlrc.HEAD    \
#                -subs_betas "${cnst}#0_Coef"                   \
#                -set_labels ${cnst}                                \
#                -options                                            \
#                     -mask $results_dir/mask_group.event+tlrc       \
#                -overwrite

tcsh $results_dir/tt++.${cnst}.tcsh
rm -f $results_dir/tt++.${cnst}.tcsh

# # ------------------------- 3dttest++ in 40Hz-sensitive group -------------------------
# gen_group_command.py -command 3dttest++                               \
#                -write_script $results_dir/tt++.40Hz_sensitive.${cnst}.tcsh  \
#                -prefix $results_dir/tt++.40Hz_sensitive.${cnst}    \
#                -dsets *Sub004/event.results/stats.event.transient+tlrc.HEAD    \
#                		*Sub005/event.results/stats.event.transient+tlrc.HEAD    \
#                		*Sub006/event.results/stats.event.transient+tlrc.HEAD    \
#                		*Sub009/event.results/stats.event.transient+tlrc.HEAD    \
#                     *Sub011/event.results/stats.event.transient+tlrc.HEAD    \
#                     *Sub016/event.results/stats.event.transient+tlrc.HEAD    \
#                     *Sub019/event.results/stats.event.transient+tlrc.HEAD    \
#                     *Sub021/event.results/stats.event.transient+tlrc.HEAD    \
#                -subs_betas "${cnst}#0_Coef"         \
#                -set_labels ${cnst}                                \
#                -options                                            \
#                     -mask $results_dir/mask_group.event+tlrc

# tcsh $results_dir/tt++.40Hz_sensitive.${cnst}.tcsh
# rm -f $results_dir/tt++.40Hz_sensitive.${cnst}.tcsh

# # ------------------------- 3dttest++ paired -------------------------
# gen_group_command.py -command 3dttest++                               \
#                -write_script $results_dir/tt++.01Hz_20Hz.tcsh  \
#                -prefix $results_dir/tt++.01Hz_20Hz    \
#                -dsets *Sub*/event.results/stats.event.transient+tlrc.HEAD    \
#                -subs_betas "vs01Hz#0_Coef" "vs20Hz#0_Coef"          \
#                -set_labels vs01Hz vs20Hz                                \
#                -options                                            \
#                     -paired -mask $results_dir/mask_group.event+tlrc

# tcsh $results_dir/tt++.01Hz_20Hz.tcsh
# rm $results_dir/tt++.01Hz_20Hz.tcsh

# # ------------------------- 3dttest++ thalamus -------------------------
# gen_group_command.py -command 3dttest++                               \
#                -write_script $results_dir/tt++.01Hz_20Hz.tcsh  \
#                -prefix $results_dir/tt++.01Hz_20Hz    \
#                -dsets *Sub*/event.results/stats.event+tlrc.HEAD    \
#                -subs_betas "mean_vs01to20Hz_GLT#0_Coef"          \
#                -set_labels vs01Hz_20Hz                                \
#                -options                                            \
#                     -mask $results_dir/mask_group.event+tlrc

# tcsh $results_dir/tt++.01Hz_20Hz.tcsh &
# wait
# rm -f $results_dir/tt++.01Hz_20Hz.tcsh


