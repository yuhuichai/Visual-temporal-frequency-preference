clear;
batch_dir='/data/chaiy3/visualFreq/batch';
results_dir='/data/chaiy3/visualFreq/graph.results';
data_dir='/data/chaiy3/visualFreq';

cd([data_dir '/170405Sub012/conn_fix.results/rsfc']);
graph_list=[dir('roi950_allvec_cor_z.1D')];%dir('roi950_allmean_cor_z.1D')]; 


% ========= generate graph threshold mask ==================
stim_list={'fix';'01Hz';'10Hz';'20Hz';'40Hz'};
for a=1:length(graph_list)

	% make roi_index consistent across different subjs and runs
	cd(data_dir)
	roi_index_file=[char(extractBefore(graph_list(a).name,'_all')) '_index.1D'];
	roi_index_list=dir(['*Sub*/conn*results/rsfc/' roi_index_file]);
	for d=1:length(roi_index_list)
		if d==1
			roi_index=load([roi_index_list(d).folder '/' roi_index_list(d).name]);
		else
			temp=load([roi_index_list(d).folder '/' roi_index_list(d).name]);
			roi_index=intersect(temp,roi_index);
		end
	end
	dlmwrite([results_dir '/' roi_index_file],roi_index,'delimiter','\n');
	fprintf('ROI number is %d for %s \n',length(roi_index),graph_list(a).name);

	cd(data_dir)
	graph=zeros(length(roi_index),length(roi_index),length(stim_list));
	graph_pos_mask=zeros(length(roi_index),length(roi_index),length(stim_list));
	graph_neg_mask=zeros(length(roi_index),length(roi_index),length(stim_list));
	for stim=1:length(stim_list)
		sub_list=dir(['*Sub*/conn_' char(stim_list(stim)) '.results/rsfc/' graph_list(a).name]);
		for c=1:length(sub_list)
			temp_graph=load([sub_list(c).folder '/' sub_list(c).name]);
			temp_index=load([sub_list(c).folder '/' roi_index_file]);
			[~,ia,~]=intersect(temp_index,roi_index);
			temp_graph=temp_graph(ia,ia);
			graph(:,:,stim)=graph(:,:,stim)+temp_graph;
			if c==1
				graph_pos_mask(:,:,stim)=(temp_graph>0);
				graph_neg_mask(:,:,stim)=(temp_graph<0);
			else
				graph_pos_mask(:,:,stim)=graph_pos_mask(:,:,stim).*(temp_graph>0);
				graph_neg_mask(:,:,stim)=graph_neg_mask(:,:,stim).*(temp_graph<0);
			end
		end
		graph(:,:,stim)=graph(:,:,stim)/length(sub_list);


		if stim==1
			graph_pos_mask_all=graph_pos_mask(:,:,stim);
			graph_neg_mask_all=graph_neg_mask(:,:,stim);
		else
			graph_pos_mask_all=graph_pos_mask(:,:,stim).*graph_pos_mask_all;
			graph_neg_mask_all=graph_neg_mask(:,:,stim).*graph_neg_mask_all;
		end
	end
	% graph_mask=graph_mask-diag(diag(graph_mask));
	% graph=graph.*repmat(graph_mask,1,1,length(stim_list));
	% graph=log((1+graph)./(1-graph))/2; % fisher z transform
	% for stim=1:length(stim_list)
	% 	dlmwrite([results_dir '/' insertBefore(graph_list(a).name,'.1D',['_' char(stim_list(stim))])], ...
	% 		squeeze(graph(:,:,stim)));
	% end
	% graph_mean=squeeze(mean(graph,3));
	% dlmwrite([results_dir '/' insertBefore(graph_list(a).name,'.1D','_mean')], ...
	% 		squeeze(graph(:,:,stim)));
	% dlmwrite([results_dir '/' char(extractBefore(graph_list(a).name,'_all')) '_mask.1D'], ...
	% 		graph_mask);
end


% figure;
% imagesc(graph_pos_thr)%,[10 35]
% colormap(jet);
% colorbar('location','eastoutside','Fontsize',11,'Color','white')
% set(gcf,'color',[0 0 0])
% set(gca,'XTick',1:length(index),'XTickLabel',cor_label,'YTick',1:length(index), ...
% 	'YTickLabel',cor_label,'fontsize',11,'Xcolor',[1 1 1],'Ycolor',[1 1 1])
% xtickangle(45);
% ytickangle(45);
% box off
% export_fig([para_name '.png'],'-r300');

cd(batch_dir)

