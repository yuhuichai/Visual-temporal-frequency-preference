%% compare freq-dependent activation in different Kmeans area
clear;
dataDir='/Users/chaiy3/Data/visualFreq';
cd(dataDir)

fitts_list = [dir('*Sub021/event.results/fit.sus_lf_hf_tha.1D')];
% fitts_list = [dir('group.results/freqmap/fit.K2.Kmeans_Cr.mean_beta.stats.LME.fcs_gm_Thalamus_inters_01Hz_40Hz_frac1_pos_z.1D')];
freq_fitts = [0:0.05:40];
freq_beta = [0 1 5 10 20 40];

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
	beta=[zeros(roi_num,1) beta'];

	% fitfunc='gauss';
	% for roi=1:roi_num
	% 	F = ezfit(freq_beta,beta(roi,:),fitfunc);
	% 	if strcmp(fitfunc,'diffexp') == 1
	% 		fitts(roi,:) = F.m(3)*(exp(-F.m(1)*(freq_fitts-F.m(4)))-exp(-F.m(2)*(freq_fitts-F.m(4))));
	% 	elseif strcmp(fitfunc,'gauss') == 1
	% 		fitts(roi,:) = F.m(1)*exp(-((freq_fitts-F.m(3)).^2)/(2*F.m(2)^2));
	% 	elseif strcmp(fitfunc,'poly2') == 1
	% 		fitts(roi,:) = F.m(1)+F.m(2)*freq_fitts+F.m(3)*freq_fitts.^2;
	% 	elseif strcmp(fitfunc,'poly3') == 1
	% 		fitts(roi,:) = F.m(1)+F.m(2)*freq_fitts+F.m(3)*freq_fitts.^2+F.m(4)*freq_fitts.^3;
	% 	end
				
	% 	fitts_max(roi) = max(fitts(roi,:));
	% 	index_max = find(fitts(roi,:)==fitts_max(roi));
	% 	freq_max(roi) = freq_fitts(index_max);
	% end

	% color_list = [1,0,0; 0,0,1; 0,1,0; 1,1,0];
	color_list = [222 81 69; 134 44 221; 62 214 141; 73 254 0; 226 248 46]/255;

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
	% ylim([-0.05 0.7])
	% xlim([0.3 stim_num+0.7])
	box off
	whitebg('black');
	set(gcf,'color',[0 0 0])
	set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
	fig_name=replace(fitts_list(index).name,'.1D','.png');
	export_fig(fig_name,'-r300');
	close all
end


