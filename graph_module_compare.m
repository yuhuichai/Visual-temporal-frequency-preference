clear;
batch_dir='/data/chaiy3/visualFreq/batch';
results_dir='/data/chaiy3/visualFreq/graph.results';

cd(results_dir)
M_list=[dir('M_r2*roi950_allvec*Hz.1D');dir('M_r2*roi950_allvec*fix.1D');...
	dir('M_r2*roi950_allvec*mean.1D')];
for index=1:length(M_list)
	M_temp=load(M_list(index).name);
	if index==1
		M=zeros(length(M_temp),length(M_list));
	end
	M(:,index)=M_temp;
end
[~, nmi_vec] = partition_distance(M);

M_list=[dir('M_r2*roi950_allmean*Hz.1D');dir('M_r2*roi950_allmean*fix.1D');...
	dir('M_r2*roi950_allmean*mean.1D')];
for index=1:length(M_list)
	M_temp=load(M_list(index).name);
	if index==1
		M=zeros(length(M_temp),length(M_list));
	end
	M(:,index)=M_temp;
end

[~, nmi_mean] = partition_distance(M);

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

