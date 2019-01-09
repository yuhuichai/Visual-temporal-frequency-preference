clear;
addpath(genpath('/data/chaiy3/Toolbox'))
batch_dir='/data/chaiy3/visualFreq/batch';
results_dir='/data/chaiy3/visualFreq/graph.results/';
data_dir='/data/chaiy3/visualFreq';

% ========= calculate mean graph across subjects ==================
cd([data_dir '/170712Sub020/conn_fix.results/rsfc']);
graph_list=[dir('roi9*_all*_cor_zcc.1D')];
cd(data_dir)
stim_list={'fix';'01Hz';'10Hz';'20Hz';'40Hz'};

for graph_index=1:length(graph_list)
	fprintf('++ Start with %s ... \n',graph_list(graph_index).name);
	graphfd_name=char(extractBefore(graph_list(graph_index).name,'_cor_zcc'));
	if exist([results_dir graphfd_name],'dir')~=7
		mkdir([results_dir graphfd_name]);
	end	

	for stim_index=1:length(stim_list)
		sub_list_stim=dir(['*Sub*/conn_' char(stim_list(stim_index)) '*']);
		sub_list_stim=struct2table(sub_list_stim);
		sub_list_stim=sub_list_stim(:,2);

		for stim2_index=(stim_index+1):length(stim_list)
			sub_list_stim2=dir(['*Sub*/conn_' char(stim_list(stim2_index)) '*']);
			sub_list_stim2=struct2table(sub_list_stim2);
			sub_list_stim2=sub_list_stim2(:,2);

			fprintf('++ Comparing %s with %s ... \n',char(stim_list(stim_index)),char(stim_list(stim2_index)));
			stimvs_name=[char(stim_list(stim_index)) '_' char(stim_list(stim2_index))];
			if exist([results_dir '/' graphfd_name '/' stimvs_name],'dir')~=7
				mkdir([results_dir '/' graphfd_name '/' stimvs_name]);
			end

			sub_list=intersect(sub_list_stim,sub_list_stim2);
			sub_list=table2array(sub_list);
			design_mat=[ones(length(sub_list),1) eye(length(sub_list));(-1)*ones(length(sub_list),1) eye(length(sub_list))];
			save([results_dir '/' graphfd_name '/' stimvs_name '_design.mat'],'design_mat');
			cnst=zeros(1,length(sub_list)+1);
			cnst(1,1)=1;
			save([results_dir '/' graphfd_name '/' stimvs_name '_contrast_pos.mat'],'cnst');
			cnst(1,1)=-1;
			save([results_dir '/' graphfd_name '/' stimvs_name '_contrast_neg.mat'],'cnst');
			exchange=[1:length(sub_list) 1:length(sub_list)];
			save([results_dir '/' graphfd_name '/' stimvs_name '_exchange.mat'],'exchange');

			for sub_index=1:length(sub_list)
				subj_name=['subj' char(extractAfter(char(sub_list(sub_index)),'Sub')) '.txt'];				
				copyfile([char(sub_list(sub_index)) '/conn_' char(stim_list(stim_index)) '.results/rsfc/' graph_list(graph_index).name], ...
					[results_dir '/' graphfd_name '/' stimvs_name '/' char(stim_list(stim_index)) '_' subj_name], 'f');
				copyfile([char(sub_list(sub_index)) '/conn_' char(stim_list(stim2_index)) '.results/rsfc/' graph_list(graph_index).name], ...
					[results_dir '/' graphfd_name '/' stimvs_name '/' char(stim_list(stim2_index)) '_' subj_name], 'f');
			end
		end
	end
end

cd(batch_dir)

