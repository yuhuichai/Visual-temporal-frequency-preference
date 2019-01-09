clear;
addpath(genpath('/data/chaiy3/Toolbox'))
batch_dir='/data/chaiy3/visualFreq/batch';
results_dir='/data/chaiy3/visualFreq/graph.results/stats';

% ============================ generate statistical group graph =============================
brick_list={'F';'fix-01Hz';'fix-10Hz';'fix-20Hz';'fix-40Hz';'vs01Hz-vs10Hz';'vs01Hz-vs20Hz';...
	'vs01Hz-vs40Hz';'vs10Hz-vs20Hz';'vs10Hz-vs40Hz';'vs20Hz-vs40Hz';'fix';'vs01Hz';'vs10Hz';...
	'vs20Hz';'vs40Hz';'mean'};

cd(results_dir)
graph_stats_list=dir('stats.LME.roi*_all*_cor_z1*_fdr.1D');
for index=1:length(graph_stats_list)
	fprintf('++ Start with %s ... \n',graph_stats_list(index).name);
	graph_stats=load(graph_stats_list(index).name);
	if length(strfind(graph_stats_list(index).name,'triu'))>0
		graph_full=ones(6510,6510);
		idx=find(tril(graph_full,-1)>0);
		graph_full=zeros(6510*6510,34);
		graph_full(idx,:)=graph_stats;
		graph_stats=graph_full;
	end

	roi_realnum=sqrt(length(graph_stats));
	fprintf('++ ROI number is %d ... \n',roi_realnum);
	graph_stats=reshape(graph_stats,roi_realnum,roi_realnum,34);

	for stim=1:2:21
		edge_fdr=graph_stats(:,:,stim).*(graph_stats(:,:,stim+1)<=0.05);
		edge_fdr=edge_fdr+edge_fdr';
		if max(max(edge_fdr))>0 || min(min(edge_fdr))<0
			edge_name=[char(extractBefore(graph_stats_list(index).name,'cor_z1')) ...
				char(brick_list((stim+1)/2)) '_neg-pos.edge'];
			dlmwrite(edge_name,-edge_fdr,'delimiter','\t');
		end		
		% if max(max(edge_fdr))>0
		% 	edge_name=[char(extractBefore(graph_stats_list(index).name,'cor_z1')) ...
		% 		char(brick_list((stim+1)/2)) '_pos.edge'];
		% 	dlmwrite(edge_name,edge_fdr.*(edge_fdr>0),'delimiter','\t');
		% end
		% if min(min(edge_fdr))<0
		% 	edge_name=[char(extractBefore(graph_stats_list(index).name,'cor_z1')) ...
		% 		char(brick_list((stim+1)/2)) '_neg.edge'];
		% 	dlmwrite(edge_name,edge_fdr.*(edge_fdr<0),'delimiter','\t');			
		% end
	end
end

% graph_stats_list=dir('stats.LME.roi*_all*_cor_z1col_fzp.1D');
% for index=1:length(graph_stats_list)
% 	fprintf('++ Start with %s ... \n',graph_stats_list(index).name);
% 	graph_stats=load(graph_stats_list(index).name);
% 	roi_realnum=sqrt(length(graph_stats));
% 	graph_stats=reshape(graph_stats,roi_realnum,roi_realnum,34);

% 	for stim=[1:2:21 33]
% 		edge_p=triu(graph_stats(:,:,stim+1),1);
% 		triu_index=find(edge_p>0);
% 		edge_p=edge_p(triu_index);
% 		[pthr,pcor,padj] = fdr(pvals)
		
% 		edge_fdr=graph_stats(:,:,stim).*(graph_stats(:,:,stim+1)<=0.05);
% 		edge_fdr=edge_fdr+edge_fdr';
% 		if max(max(edge_fdr))>0
% 			edge_name=[char(extractBefore(graph_stats_list(index).name,'cor_z1col_fdr')) ...
% 				char(brick_list((stim+1)/2)) '.edge'];
% 			dlmwrite(edge_name,edge_fdr,'delimiter','\t');
% 		end
% 	end
% end

cd(batch_dir)

