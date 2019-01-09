%% plot curve of voxels
clear;
dataDir='/Users/chaiy3/Data/visualFreq';
cd(dataDir)

fitts_list = [dir('170510Sub016/event.results/fit_l1.1D')];
freq_fitts = [0:0.05:40];
freq_beta = [1 5 10 20 40];

for index=1:length(fitts_list)
	fprintf('***************************************************\n');
	fprintf('++ Begin analyzing %s \n',fitts_list(index).name);

	cd(fitts_list(index).folder)
	fitts=load(fitts_list(index).name);
	fitts=fitts';
	[roi_num,freq_num]=size(fitts);

	[fitts_max,Imax]=max(fitts,[],2);
	freq_max=freq_fitts(Imax);

	beta=load(replace(fitts_list(index).name,'fit','beta'));
	beta=beta';


	color_list = [1,0,0; 0,0,1; 0,1,0; 1,1,0];
	% color_list = [222 81 69; 134 44 221; 62 214 141; 73 254 0; 226 248 46]/255;

	figure;
	for roi=1:roi_num
		hold on;
		plot(freq_fitts,fitts(roi,:),'color',color_list(roi,:),'LineWidth',3);
		hold on; plot(freq_beta,beta(roi,:),'*','LineWidth',3,'MarkerEdgeColor',color_list(roi,:),'MarkerSize',15);
		hold on; plot(freq_max(roi),fitts_max(roi),'p','MarkerEdgeColor',color_list(roi,:),'MarkerFaceColor',color_list(roi,:),'MarkerSize',22);
	end
	ylabel('Signal Change (%)','Fontsize',25,'FontWeight','bold');
	xlabel('Stimulation Frequency (Hz)','Fontsize',25,'FontWeight','bold');
	% xtickangle(0);
	% ylim([-0 1.1])
	% xlim([0.3 stim_num+0.7])
	box off
	whitebg('black');
	set(gcf,'color',[0 0 0])
	set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
	fig_name=replace(fitts_list(index).name,'.1D','.png');
	export_fig(fig_name,'-r300');
	% close all
end


