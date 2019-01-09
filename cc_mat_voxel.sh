#!/bin/bash
module load afni
sub_dir=$1 # /Users/chaiy3/Data/visualFreq/*Sub003
run_dir=$2
mask_file=$3 # /data/chaiy3/visualFreq/group.results/mask_gm_6mm_group.conn+tlrc.HEAD
	
subj=${run_dir%.results}
cd $sub_dir/$run_dir
[ ! -d rsfc  ] && mkdir rsfc
rm rsfc/roi5000*.1D

3dresample -master ${mask_file} -inset errts.${subj}.fanaticor+tlrc \
	-prefix rm.roi5000.errts.${subj}.fanaticor+tlrc -overwrite

3dAutoTcorrelate -mask ${mask_file} -mask_source ${mask_file} \
	-out1D rm.roi5000_allmean_cor.1D \
	-overwrite rm.roi5000.errts.${subj}.fanaticor+tlrc
rm ATcorr+tlrc*
rm rm.roi5000.errts.${subj}.fanaticor+tlrc*

sed '/#/d' rm.roi5000_allmean_cor.1D > rm.roi5000_allmean_cor_trans1.1D
1dcat rm.roi5000_allmean_cor_trans1.1D[1..$] > rm.roi5000_allmean_cor_trans2.1D
3dcalc -a rm.roi5000_allmean_cor_trans2.1D\' -expr 'log((1+a)/(1-a))/2' \
	-prefix rm.roi5000_allmean_cor_z.1D -overwrite
1dcat rm.roi5000_allmean_cor_z.1D > rm.roi5000_allmean_cor_z_trans.1D -overwrite

# awk '{ for (i=1; i<=NF; i++) print $i }' rm.roi5000_allmean_cor_z_trans.1D \
# 	> roi5000_allmean_cor_z1col.1D
awk '{for (i=1;i<=NF;i++) if (i>NR) printf  $i FS "\n"}' rm.roi5000_allmean_cor_z_trans.1D \
	> roi5000_allmean_cor_z1triu.1D

index=0
vxl_num=`3dBrickStat -count -non-zero ${mask_file}`
let "cc_num=vxl_num*(vxl_num-1)/2"
echo "******************* ${cc_num} correlations for ${vxl_num} voxels in mask *************"
for row1 in `seq 1 100000 ${cc_num}`; do
	echo "******************* row = ${row1} *************"
	let "row2=row1+99999"
	let "index += 1"
	if [ ${#index} = 1 ]; then
		cc_index=00${index}
	fi
	if [ ${#index} = 2 ]; then
		cc_index=0${index}
	fi
	if [ ${#index} = 3 ]; then
		cc_index=${index}
	fi
	sed -n ${row1},${row2}p roi5000_allmean_cor_z1triu.1D \
		> roi5000_allmean_cor_z1triu_${cc_index}.1D
done
rm roi5000_allmean_cor_z1triu.1D	

mv -f roi5000_allmean_cor_z1triu_*.1D rsfc/
rm rm.roi5000*