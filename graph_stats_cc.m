clear;
% addpath(genpath('/Volumes/data/Toolbox'))
batch_dir='/Volumes/data/visualFreq/batch';
results_dir='/Volumes/data/visualFreq/graph.results';
data_dir='/Volumes/data/visualFreq';

% ============================ generate statistical group graph =============================
cd(results_dir)
graph_stats_list=dir('stats.LME.roi950_allvec_cor_z1col.1D');
stim_list={'01Hz';'10Hz';'20Hz';'40Hz'};
for index=1:length(graph_stats_list)
	fprintf('++ Start with %s ... \n',graph_stats_list(index).name);
	graph_stats=load(graph_stats_list(index).name);
	roi_num=extractBefore(graph_stats_list(index).name,'_all');
	roi_num=extractAfter(roi_num,'roi');
	graph_z=graph_stats(:,4:2:end); % fix, 01Hz, 10Hz, 20Hz, 40Hz, mean
	% graph_p_neg=normcdf(graph_z);
	% graph_p_pos=1-graph_p_neg;
	% graph_z=graph_z.*((graph_p_neg<0.05)+(graph_p_pos<0.05));
	node_num=sqrt(length(graph_stats));

	% reoder graph
	M=load('sort.M_r2_thr0.1_Q0.69_roi950_allvec_mean.1D');
	nw_list={'DMN';'Visual';'Attention';'Sensorimotor';'Salience';'Cerebellum';'Thalamus';'other'};	
	M(find(M==0))=M(find(M==0))+max(M)+1;
	[M_sort,M_index]=sort(M);
	tick_index=zeros(8,1);
	for i=1:8
		if i==1
			tick_index(i)=length(find(M==i))/2;
		else
			tick_index(i)=length(find(M<i))+length(find(M==i))/2;
		end
	end

	for stim=1:4
		graph=-reshape(graph_z(:,stim),[node_num,node_num]);
		graph_sort=graph(M_index,:);
		graph_sort=graph_sort(:,M_index);

		figure;
		imagesc(graph_sort,[-3 3])
		colormap(jet);
		% colorbar('location','eastoutside','Fontsize',11,'Color','white')
		set(gcf,'color',[0 0 0])
		set(gca,'XTick',tick_index,'XTickLabel',[],'YTick',tick_index, ...
			'YTickLabel',nw_list,'fontsize',15,'Xcolor',[1 1 1],'Ycolor',[1 1 1])
		% xtickangle(45);
		% ytickangle(45);
		box off
		export_fig(['cc_' char(stim_list(stim)) '_fix.png'],'-r300');
	end
end

cd(batch_dir)

