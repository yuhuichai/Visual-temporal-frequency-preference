#!/bin/tcsh -xef

# created by uber_ttest.py: version 1.1 (October 18, 2012)
# creation date: Fri Feb 10 15:03:55 2017

# ---------------------- set process variables ----------------------
# set cnst = $argv[1]

# specify and possibly create results directory
set results_dir = group.results

# ------------------------- 3dttest++ tcorr_01_40hz+tlrc -------------------------
gen_group_command.py -command 3dttest++                               \
               -write_script $results_dir/tt++.01Hz_40Hz.tcsh  \
               -prefix $results_dir/tt++.01Hz_40Hz    \
               -dsets *Sub*/conn*.results/rsfc/tcorr_01_40hz+tlrc.HEAD    \
               -subs_betas "Pear.Corr."          \
               -set_labels tcorr_01_40hz                                \
               -options                                            \
                    -mask $results_dir/mask_group.conn+tlrc

tcsh $results_dir/tt++.01Hz_40Hz.tcsh &
wait
rm -f $results_dir/tt++.01Hz_40Hz.tcsh


