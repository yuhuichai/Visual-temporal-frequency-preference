

%% compare activation in V1 and higher-level visual areas
clear;
data_dir='/data/chaiy3/visualFreq';
cd(data_dir)
subj_list=dir('*Sub*/event.results/freqmap_ijk.txt');
for subj=1:1 %length(subj_list)
	cd(subj_list(subj).folder);
	fprintf('***************************************************\n');
	fprintf('++ Begin analyzing %s \n',subj_list(subj).folder);
	[err, Vm, Infobeta, ErrMessage] = BrikLoad('beta.freqmap+tlrc');
	ijk_list=load(subj_list(subj).name);
	for index=1:length(ijk_list)
		x=ijk_list(index,1)+1;
		y=ijk_list(index,2)+1;
		z=ijk_list(index,3)+1;
		psig=squeeze(Vm(x,y,z,:));

		color_list = [222 81 69; 134 44 221]/255;

		% fit curve
		figure
		freq = [0 1 5 10 20 40];
		psig = [0; psig];
		freqhres = [0:0.1:60];
		freq_log = (freq);
		freqhres_log = (freqhres);

		fitfunc='diffexp';

		% 01Hz ROI
		F1 = ezfit(freq_log,psig',fitfunc);
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

		plot(freqhres,psighres1,'color',color_list(1,:),'LineWidth',3);
		hold on; plot(freq,psig','*','LineWidth',3,'MarkerEdgeColor',color_list(1,:),'MarkerSize',15);
		% hold on; plot(freq1_low,psig1_low,'s','MarkerEdgeColor',color_list(1,:),'MarkerFaceColor',color_list(1,:),'MarkerSize',15);
		hold on; plot(freq1_max,psig1_max,'p','MarkerEdgeColor',color_list(1,:),'MarkerFaceColor',color_list(1,:),'MarkerSize',22);
		% hold on; plot(freq1_hig,psig1_hig,'d','MarkerEdgeColor',color_list(1,:),'MarkerFaceColor',color_list(1,:),'MarkerSize',15);


		% h = legend('01 Hz','05 Hz');
		% set(h,'box','off','location','east','Fontsize',28,'FontWeight','bold')
		xlim([0 41]);
		% ylim([-0 1.15])
		xlabel('Stimulation Frequency (Hz)','Fontsize',25,'FontWeight','bold');
		ylabel('Signal Change (%)','Fontsize',25,'FontWeight','bold');
		box off
		whitebg('black');
		set(gcf,'color',[0 0 0])
		set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
		export_fig(['freqmap_ijk' num2str(ijk_list(index,:)) '.png'],'-r300');
	end
end

