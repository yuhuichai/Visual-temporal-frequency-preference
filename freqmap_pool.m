clear;
batch_dir='/data/chaiy3/visualFreq/batch';
data_dir='/data/chaiy3/visualFreq';
mask_file='visual_mask+tlrc';

cd(data_dir)
% subj_list=dir('group.results/freqmap/mean_beta.stats.LME.fcs_gm_Thalamus_inters_01Hz_40Hz_frac1_pos_z+tlrc.HEAD');
subj_list=dir('group.event.results/freqmap/mean_beta.freqmap+tlrc.HEAD');
% Kpattern='/data/chaiy3/visualFreq/group.event.results/freqmap/Kmeans_Cr.mean_beta.freqmap+tlrc';
% job=length(subj_list);

% myCluster = parcluster('local');
% myCluster.NumWorkers = job;
% saveProfile(myCluster);

% poolobj=parpool(job)
% par
for subj=1:length(subj_list)
	fprintf('++ Start with %s ... \n',subj_list(subj).folder);
	% freqmap(subj_list(subj).folder,subj_list(subj).name,mask_file,'event','diffexp','notok');
	% freqmap(subj_list(subj).folder,subj_list(subj).name,mask_file,'event','diffexp','ok');
	freqmap_kmeans(subj_list(subj).folder,subj_list(subj).name,mask_file)
end
% delete(poolobj)





