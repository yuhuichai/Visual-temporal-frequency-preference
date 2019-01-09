clear;
batchDir='/Users/chaiy3/Data/visualFreq/batch';
results_dir='/Users/chaiy3/Data/visualFreq/group.results';
cd(results_dir)
label=importdata('allvec_label.1D');
label=string(label);
label_roi_value=extractBefore(label,'" "');
label_roi_value=extractAfter(label_roi_value,'"');

label=extractAfter(label,'" "');
label=extractBefore(label,'"');
label=replace(label,'Left','L');
label=replace(label,'Right','R');
label=replace(label,'ctx_lh','L');
label=replace(label,'ctx_rh','R');
label=replace(label,'_','-');
label=replace(label,'-and-','-');

filelist=dir('stats*all*_cor_z_merge.1D');
for i=1:length(filelist)
	cor_vec_name=filelist(i).name;
	cor_vec=load(cor_vec_name);
	vec_num=sqrt(length(cor_vec));
	cor_condF=reshape(cor_vec(:,2),[vec_num,vec_num]);

	% extract the some greatest correlation area
	[value,index]=sort(cor_condF(:),'descend');
	cor_condF(index(41:end))=0;
	index=find(sum(cor_condF));
	cor_condF=cor_condF(index,index);
	cor_label=label(index);

	cor_roi_value=double(label_roi_value(index));
	para_name=erase(cor_vec_name,{'_z_merge.1D','stats.'});
	dlmwrite([para_name '.txt'],cor_roi_value');

	figure;
	imagesc(cor_condF)%,[10 35]
	colormap(jet);
	colorbar('location','eastoutside','Fontsize',11,'Color','white')
	set(gcf,'color',[0 0 0])
	set(gca,'XTick',1:length(index),'XTickLabel',cor_label,'YTick',1:length(index), ...
		'YTickLabel',cor_label,'fontsize',11,'Xcolor',[1 1 1],'Ycolor',[1 1 1])
	xtickangle(45);
	ytickangle(45);
	box off
	export_fig([para_name '.png'],'-r300');
end
cd(batchDir)
system('bash aseg_cor_changes.sh');
