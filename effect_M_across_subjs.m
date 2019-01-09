clear;
addpath(genpath('/data/chaiy3/Toolbox'))
batch_dir='/data/chaiy3/visualFreq/batch';
results_dir='/data/chaiy3/visualFreq/graph.results';
data_dir='/data/chaiy3/visualFreq';
effect_dir='/data/chaiy3/visualFreq/group.effects';

cd(results_dir)
M=load('sort.M_r2_thr0.1_Q0.69_roi950_allvec_mean.1D');
nw_list={'DMN';'Visual';'Attention';'Sensorimotor';'Salience';'Cerebellum'};	
cd([data_dir '/170419Sub013/conn_fix.results/rsfc']);
para_list=[dir('*_WD_thr*.1D');dir('*_PC_thr*.1D');dir('*_deg_thr*.1D');...
	dir('*_str_thr*.1D');dir('*_eff_thr*.1D')];
cd(data_dir)
stim_list={'fix';'01Hz';'10Hz';'20Hz';'40Hz'};
subj_list=dir('*Sub*');
for para_index=1:length(para_list)
	fprintf('++ Start with %s ... \n',para_list(para_index).name);
	effect=zeros(length(subj_list),length(stim_list),length(nw_list));
	for subj_index=1:length(subj_list)
		for stim_index=1:length(stim_list)
			file_name=[subj_list(subj_index).name '/conn_' char(stim_list(stim_index)) ...
				'.results/rsfc/' para_list(para_index).name];
			if exist(file_name,'file')==2
				para=load(file_name);
				for module=1:length(nw_list)
					effect(subj_index,stim_index,module)=mean(para(find(M==module)));
				end
			else
				effect(subj_index,stim_index,:)=0;
			end
		end		
	end
	for module=1:length(nw_list)
		dlmwrite([effect_dir '/' char(nw_list(module)) '_' para_list(para_index).name],...
			squeeze(effect(:,:,module)),' ');
	end	
end

cd(batch_dir)

