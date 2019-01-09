%% compute tuning curve of brain connections 
clear;
roiDir='/Users/chaiy3/Data/visualFreq/graph.results/stats';
conDir='/Users/chaiy3/Data/visualFreq/graph.results/roi500_allmean';
stim_list={'01' '10' '20' '40'};
stim_num=length(stim_list);
effect_mean=zeros(stim_num,1);
effect_std=zeros(stim_num,1);

cd(roiDir);
roiList=[dir('stats.LME.roi500_allmean_fix-*edge')];
for ind=1:length(roiList)
	if ind==1
		roi=load(roiList(ind).name);
		roi=roi>0;
	else
		tmp=load(roiList(ind).name);
		roi=(tmp>0)+roi;
	end
end
roi=roi>0;

for ind=1:length(stim_list)
	cd([conDir '/fix_' char(stim_list(ind)) 'Hz']);
	re_list=dir('fix*.txt');
	vs_list=dir('*Hz*.txt');
	subj_num=length(re_list);
	effect=zeros(subj_num,1);
	for subid=1:subj_num
		effect(subid)=sum(sum((load(vs_list(subid).name)-load(re_list(subid).name)).*roi))/sum(sum(roi));
	end
	effect_mean(ind)=mean(effect);
	effect_std(ind)=std(effect)/sqrt(subj_num);
end

cd(conDir);
color_list = [222 81 69; 134 44 221; 62 214 141; 73 254 0; 226 248 46]/255;
color_list = [1 0 0];

% fit curve
freq = [0 1 10 20 40];


effect1_mean = [0; effect_mean];
effect1_std = [0; effect_std];
freqhres = [0:0.1:41];
freq_log = (freq);
freqhres_log = (freqhres);

fitfunc='gauss';

% 01Hz ROI
F1 = ezfit(freq_log,effect1_mean',fitfunc);
if strcmp(fitfunc,'diffexp') == 1
	psighres1 = F1.m(3)*(exp(-F1.m(1)*(freqhres_log-F1.m(4)))-exp(-F1.m(2)*(freqhres_log-F1.m(4))));
elseif strcmp(fitfunc,'gauss') == 1
	psighres1 = F1.m(1)*exp(-((freqhres_log-F1.m(3)).^2)/(2*F1.m(2)^2));
elseif strcmp(fitfunc,'poly2') == 1
	psighres1 = F1.m(1)+F1.m(2)*freqhres_log+F1.m(3)*freqhres_log.^2;
elseif strcmp(fitfunc,'poly3') == 1
	psighres1 = F1.m(1)+F1.m(2)*freqhres_log+F1.m(3)*freqhres_log.^2+F1.m(4)*freqhres_log.^3;
end
		
psig1_max = max(psighres1);
index1_max = find(psighres1==psig1_max);
freq1_max = freqhres(index1_max);

psig1_1h = psighres1(1:index1_max);
freq1_1h = freqhres(1:index1_max);
psig1_2h = psighres1(index1_max:end);
freq1_2h = freqhres(index1_max:end);

freq1_low = freq1_1h(knnsearch(psig1_1h',psig1_max/2));
freq1_hig = freq1_2h(knnsearch(psig1_2h',psig1_max/2));
psig1_low = psig1_1h(knnsearch(psig1_1h',psig1_max/2));
psig1_hig = psig1_2h(knnsearch(psig1_2h',psig1_max/2));

figure
plot(freqhres,psighres1,'color',color_list(1,:),'LineWidth',3);
hold on; plot(freq,effect1_mean','*','LineWidth',3,'MarkerEdgeColor',color_list(1,:),'MarkerSize',15);
hold on; plot(freq1_max,psig1_max,'p','MarkerEdgeColor',color_list(1,:),'MarkerFaceColor',color_list(1,:),'MarkerSize',22);
hold on; errorbar(freq, effect1_mean', effect1_std','x','MarkerEdgeColor','none','LineWidth',1.5,'Color',color_list(1,:));
% h = legend('01 Hz','05 Hz');
% set(h,'box','off','location','east','Fontsize',28,'FontWeight','bold')
xlim([0 41]);
% ylim([-0.003 0.05])
xlabel('Stimulation Frequency (Hz)','Fontsize',25,'FontWeight','normal');
ylabel('Correlation Rel. to Ctrl (a.u.)','Fontsize',25,'FontWeight','normal');
box off
whitebg('white');
set(gcf,'color',[1 1 1])
set(gca,'linewidth',3,'fontsize',25,'FontWeight','normal','Xcolor',[0 0 0],'Ycolor',[0 0 0])
export_fig('runing_curve.png','-r300');

