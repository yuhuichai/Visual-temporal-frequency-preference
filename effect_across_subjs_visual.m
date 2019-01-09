%% compare activation in V1 and higher-level visual areas
clear;
effectDir='/Users/chaiy3/Data/visualFreq/group.effects';
cd(effectDir)
batchDir='/Users/chaiy3/Data/visualFreq/batch';
stim_list={'1' '5' '10' '20' '40'};
stim_num=length(stim_list);

effect_list = [dir('sus_v1.1D')];
% subj_list = [3:13 16:21];
% for subj_index = 1:length(subj_list)
	for index=1:length(effect_list)
		fprintf('***************************************************\n');
		fprintf('++ Begin analyzing %s \n',effect_list(index).name);

		effect1=load(effect_list(index).name);
		effect1_mean=[mean(effect1,1)]';
		effect1_std=[std(effect1)]'/sqrt(length(effect1));

		effect2=load(replace(effect_list(index).name,'v1','v2'));
		effect2_mean=[mean(effect2,1)]';
		effect2_std=[std(effect2)]'/sqrt(length(effect2));

		effect3=load(replace(effect_list(index).name,'v1','v3'));
		effect3_mean=[mean(effect3,1)]';
		effect3_std=[std(effect3)]'/sqrt(length(effect3));

		effect4=load('sus_tha.1D');
		effect4_mean=[mean(effect4,1)]';
		effect4_std=[std(effect4)]'/sqrt(length(effect4));

		% if length(strfind(effect_list(index).name,'benson'))>0
		% 	effect3=load(replace(effect_list(index).name,'V1','V3'));
		% 	effect3_mean=[mean(effect3,1)]';
		% elseif length(strfind(effect_list(index).name,'fs'))>0
		% 	effect5=load(replace(effect_list(index).name,'V1','V5'));
		% 	effect5_mean=[mean(effect5,1)]';
		% elseif length(strfind(effect_list(index).name,'wang'))>0
		% 	effect3=load(replace(effect_list(index).name,'V1','V3'));
		% 	effect3_mean=[mean(effect3,1)]';
		% 	effect4=load(replace(effect_list(index).name,'V1','V3'));
		% 	effect4_mean=[mean(effect4,1)]';
		% 	effect5=load(replace(effect_list(index).name,'V1','V5'));
		% 	effect5_mean=[mean(effect5,1)]';
		% end

		% effect1_mean = [effect1(subj_index,:)]';
		% effect2_mean = [effect2(subj_index,:)]';
		% effect3_mean = [effect3(subj_index,:)]';
		effect1_mean = [0; effect1_mean];
		effect2_mean = [0; effect2_mean];
		effect3_mean = [0; effect3_mean];
		effect4_mean = [0; effect4_mean];

		effect1_std = [0; effect1_std];
		effect2_std = [0; effect2_std];
		effect3_std = [0; effect3_std];
		effect4_std = [0; effect4_std];
		freq = [0 1 5 10 20 40];

		% effect for corr
		% effect1_mean = [0; 0.0189; 0.0327; 0.0513; 0.0091];
		% effect2_mean = [0; 0.0143; 0.0239; 0.0436; 0.0058];
		% effect3_mean = [0; 0.0137; 0.0196; 0.0384; 0.0059];
		% freq = [0 1 10 20 40];		

		color_list = [222 81 69; 134 44 221; 62 214 141; 73 254 0; 226 248 46]/255;

		% fit curve
		figure
		
		freqhres = [0:0.1:41];
		freq_log = (freq);
		freqhres_log = (freqhres);

		fitfunc='diffexp';

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

		% 40Hz ROI
		F2 = ezfit(freq_log,effect2_mean',fitfunc);
		if strcmp(fitfunc,'diffexp') == 1
			psighres2 = F2.m(3)*(exp(-F2.m(1)*(freqhres_log-F2.m(4)))-exp(-F2.m(2)*(freqhres_log-F2.m(4))));
		elseif strcmp(fitfunc,'gauss') == 1
			psighres2 = F2.m(1)*exp(-((freqhres_log-F2.m(3)).^2)/(2*F2.m(2)^2));
		elseif strcmp(fitfunc,'poly2') == 1
			psighres2 = F2.m(1)+F2.m(2)*freqhres_log+F2.m(3)*freqhres_log.^2;
		elseif strcmp(fitfunc,'poly3') == 1
			psighres2 = F2.m(1)+F2.m(2)*freqhres_log+F2.m(3)*freqhres_log.^2+F2.m(4)*freqhres_log.^3;
		end
		psig2_max = max(psighres2);
		index2_max = find(psighres2==psig2_max);
		freq2_max = freqhres(index2_max);

		psig2_1h = psighres2(1:index2_max);
		freq2_1h = freqhres(1:index2_max);
		psig2_2h = psighres2(index2_max:end);
		freq2_2h = freqhres(index2_max:end);

		freq2_low = freq2_1h(knnsearch(psig2_1h',psig2_max/2));
		freq2_hig = freq2_2h(knnsearch(psig2_2h',psig2_max/2));
		psig2_low = psig2_1h(knnsearch(psig2_1h',psig2_max/2));
		psig2_hig = psig2_2h(knnsearch(psig2_2h',psig2_max/2));

		% Thalamus
		F3 = ezfit(freq_log,effect3_mean',fitfunc);
		if strcmp(fitfunc,'diffexp') == 1
			psighres3 = F3.m(3)*(exp(-F3.m(1)*(freqhres_log-F3.m(4)))-exp(-F3.m(2)*(freqhres_log-F3.m(4))));
		elseif strcmp(fitfunc,'gauss') == 1
			psighres3 = F3.m(1)*exp(-((freqhres_log-F3.m(3)).^2)/(2*F3.m(2)^2));
		end
		psig3_max = max(psighres3);
		index3_max = find(psighres3==psig3_max);
		freq3_max = freqhres(index3_max);

		psig3_1h = psighres3(1:index3_max);
		freq3_1h = freqhres(1:index3_max);
		psig3_2h = psighres3(index3_max:end);
		freq3_2h = freqhres(index3_max:end);

		freq3_low = freq3_1h(knnsearch(psig3_1h',psig3_max/2));
		freq3_hig = freq3_2h(knnsearch(psig3_2h',psig3_max/2));
		psig3_low = psig3_1h(knnsearch(psig3_1h',psig3_max/2));
		psig3_hig = psig3_2h(knnsearch(psig3_2h',psig3_max/2));

		% Thalamus
		F4 = ezfit(freq_log,effect4_mean',fitfunc);
		if strcmp(fitfunc,'diffexp') == 1
			psighres4 = F4.m(3)*(exp(-F4.m(1)*(freqhres_log-F4.m(4)))-exp(-F4.m(2)*(freqhres_log-F4.m(4))));
		elseif strcmp(fitfunc,'gauss') == 1
			psighres4 = F4.m(1)*exp(-((freqhres_log-F4.m(3)).^2)/(2*F4.m(2)^2));
		end
		psig4_max = max(psighres4);
		index4_max = find(psighres4==psig4_max);
		freq4_max = freqhres(index4_max);

		plot(freqhres,psighres1,'color',color_list(1,:),'LineWidth',3);
		hold on; plot(freq,effect1_mean','*','LineWidth',3,'MarkerEdgeColor',color_list(1,:),'MarkerSize',15);
		% hold on; plot(freq1_low,psig1_low,'s','MarkerEdgeColor',color_list(1,:),'MarkerFaceColor',color_list(1,:),'MarkerSize',15);
		hold on; plot(freq1_max,psig1_max,'p','MarkerEdgeColor',color_list(1,:),'MarkerFaceColor',color_list(1,:),'MarkerSize',22);
		% hold on; plot(freq1_hig,psig1_hig,'d','MarkerEdgeColor',color_list(1,:),'MarkerFaceColor',color_list(1,:),'MarkerSize',15);
		hold on; errorbar(freq, effect1_mean', effect1_std','x','MarkerEdgeColor','none','LineWidth',1.5,'Color',color_list(1,:));

		hold on; plot(freqhres,psighres2,'color',color_list(2,:),'LineWidth',3);
		hold on; plot(freq,effect2_mean','*','LineWidth',3,'MarkerEdgeColor',color_list(2,:),'MarkerSize',15);
		% hold on; plot(freq2_low,psig2_low,'s','MarkerEdgeColor',color_list(2,:),'MarkerFaceColor',color_list(2,:),'MarkerSize',15);
		hold on; plot(freq2_max,psig2_max,'p','MarkerEdgeColor',color_list(2,:),'MarkerFaceColor',color_list(2,:),'MarkerSize',22);
		% hold on; plot(freq2_hig,psig2_hig,'d','MarkerEdgeColor',color_list(2,:),'MarkerFaceColor',color_list(2,:),'MarkerSize',15);
		hold on; errorbar(freq, effect2_mean', effect2_std','x','MarkerEdgeColor','none','LineWidth',1.5,'Color',color_list(2,:));

		% fprintf('++ F.r = %f for subj %d \n',F3.r, subj_list(subj_index));
		% if F3.r>0.3 && F3.r<1
			hold on; plot(freqhres,psighres3,'color',color_list(3,:),'LineWidth',3);
			hold on; plot(freq,effect3_mean','*','LineWidth',3,'MarkerEdgeColor',color_list(3,:),'MarkerSize',15);
			% hold on; plot(freq3_low,psig3_low,'s','MarkerEdgeColor',color_list(3,:),'MarkerFaceColor',color_list(3,:),'MarkerSize',15);
			hold on; plot(freq3_max,psig3_max,'p','MarkerEdgeColor',color_list(3,:),'MarkerFaceColor',color_list(3,:),'MarkerSize',22);
			% hold on; plot(freq3_hig,psig3_hig,'d','MarkerEdgeColor',color_list(3,:),'MarkerFaceColor',color_list(3,:),'MarkerSize',15);
			hold on; errorbar(freq, effect3_mean', effect3_std','x','MarkerEdgeColor','none','LineWidth',1.5,'Color',color_list(3,:));
		% end

		hold on; plot(freqhres,psighres4,'color',color_list(4,:),'LineWidth',3);
		hold on; plot(freq,effect4_mean','*','LineWidth',3,'MarkerEdgeColor',color_list(4,:),'MarkerSize',15);
		hold on; plot(freq4_max,psig4_max,'p','MarkerEdgeColor',color_list(4,:),'MarkerFaceColor',color_list(4,:),'MarkerSize',22);
		hold on; errorbar(freq, effect4_mean', effect4_std','x','MarkerEdgeColor','none','LineWidth',1.5,'Color',color_list(4,:));

		% h = legend('01 Hz','05 Hz');
		% set(h,'box','off','location','east','Fontsize',28,'FontWeight','bold')
		xlim([0 41]);
		ylim([-0 1.3])
		xlabel('Stimulation Frequency (Hz)','Fontsize',25,'FontWeight','bold');
		ylabel('Signal Changes (%)','Fontsize',25,'FontWeight','bold');
		box off
		whitebg('black');
		set(gcf,'color',[0 0 0])
		set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
		% fig_name=replace(effect_list(index).name,'.1D',['_sub' num2str(subj_list(subj_index)) '.png']);
		fig_name=replace(effect_list(index).name,'.1D','.png');
		export_fig(['fit_' fig_name],'-r300');
	end
% end
