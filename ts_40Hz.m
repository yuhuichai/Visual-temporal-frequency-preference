clear;
dataDir='/Volumes/data/visualFreq/';
cd(dataDir)
subj_list=[dir('*Sub005') dir('*Sub006') dir('*Sub009') dir('*Sub010') dir('*Sub011') dir('*Sub016')];
batchDir='/Volumes/data/visualFreq/batch';

tr_per_trial = 17;
roi_num = 3;
roi_list={'01Hz';'40Hz';'overlay'};
sub_num = length(subj_list);
ts_in_trial_all = zeros(sub_num,roi_num,5,tr_per_trial); % 7 stim conditions

for index=1:sub_num
	subDir=[dataDir subj_list(index).name];
	fprintf('Begin analyzing %s \n',subj_list(index).name); 
	cd([subDir '/Stim']);
	filelist = [dir('event_01Hz*.txt') dir('event_05Hz*.txt') dir('event_10Hz*.txt') ...
		dir('event_20Hz*.txt') dir('event_40Hz*.txt')];
	stim_kinds = length(filelist);
	if findstr(subj_list(index).name,'Sub007')>0
		trial_rcyls = 6;
		tr_all = 764;
	elseif findstr(subj_list(index).name,'Sub016')>0
		trial_rcyls = 8;
		tr_all = 728;
	else
		trial_rcyls = 9;
		tr_all = 1146;
	end
	stimT = zeros(stim_kinds,trial_rcyls);
	for stim = 1:stim_kinds
	    temp = load(filelist(stim).name);
	    if trial_rcyls == 6 || trial_rcyls == 9
		    stimT(stim,1:3) = temp(1,:);
		    stimT(stim,4:6) = temp(2,:)+382*1.7;
		    if trial_rcyls == 9
		    	stimT(stim,7:9) = temp(3,:)+382*1.7*2;
		    end
		else
			stimT(stim,1:4) = temp(1,:);
		    stimT(stim,5:8) = temp(2,:)+364*1.7;
		end
	end

	cd([subDir '/event.results']);
	filelist = [dir('gamma_ts.*Hz.1D') ];
	ts = zeros(roi_num,stim_kinds,tr_all);
	for stim = 1:stim_kinds
	    temp = load(filelist(stim).name);
	    ts(:,stim,:) = temp';
	end

	ts_in_trial = zeros(roi_num,stim_kinds,tr_per_trial);
	for stim = 1:stim_kinds
	    for trial = 1:trial_rcyls
	    	n = round(stimT(stim,trial)/1.7);
	        ts_in_trial(:,stim,:) = ts_in_trial(:,stim,:) + ts(:,stim,n:(n+tr_per_trial-1));
	    end
	end

	% save('ts_in_trial.mat','ts_in_trial');
	ts_in_trial_all(index,:,:,:) = ts_in_trial;
 
	for roi = 1:roi_num
		ts_roi = squeeze(ts_in_trial(roi,:,:));
		t = (1:tr_per_trial)*1.7;
		plot(t,ts_roi(1,:),t,ts_roi(2,:),t,ts_roi(3,:),t,ts_roi(4,:),t,ts_roi(5,:),'r','LineWidth',3.5);
		h = legend('01 Hz','05 Hz','10 Hz','20 Hz','40 Hz');
		set(h,'box','off','location','east','Fontsize',28,'FontWeight','bold')
		xlim([min(t)-1 max(t)+12]);
		% ylim([-.7 1.2])
		xlabel('Time (s)','Fontsize',25,'FontWeight','bold');
		ylabel('Signal change (a.u.)','Fontsize',25,'FontWeight','bold');
		box off
		whitebg('black');
		set(gcf,'color',[0 0 0])
		set(gca,'linewidth',3.5,'fontsize',28,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
		% export_fig(['vs40Hz_occipital_ts_REML.png'],'-r300');
		export_fig(['ts_roi' char(roi_list(roi)) '.png'],'-r300');
	end
	close all 

	% mkdir('ts_roi_oc')
	% movefile('ts*.png','ts_roi_oc/')
	cd(batchDir)
end

cd(dataDir);
ts_in_trial_mean = squeeze(mean(ts_in_trial_all,1));
ts_in_trial_std = squeeze(std(ts_in_trial_all,1))/sqrt(sub_num);
% save('ts_in_trial_mean_std.mat','ts_in_trial_mean','ts_in_trial_std');

cl5 = [255 0 0]/255;
cl2 = [0 255 0]/255;
cl3 = [0 255 255]/255;
cl4 = [0 0 255]/255;
cl1 = [255 0 255]/255;

for roi = 1:roi_num
	ts_roi = squeeze(ts_in_trial_mean(roi,:,:));
	t = (1:tr_per_trial)*1.7;
	plot(t,ts_roi(1,:),'Color',cl1,'LineWidth',3.5);
	hold on,plot(t,ts_roi(2,:),'Color',cl2,'LineWidth',3.5);
	hold on,plot(t,ts_roi(3,:),'Color',cl3,'LineWidth',3.5);
	hold on,plot(t,ts_roi(4,:),'Color',cl4,'LineWidth',3.5);
	hold on,plot(t,ts_roi(5,:),'Color',cl5,'LineWidth',3.5);
	% h = legend('01 Hz','05 Hz','10 Hz','20 Hz','40 Hz');
	% set(h,'box','off','location','east','Fontsize',25)
	xlim([min(t)-1 max(t)+1]);
	% ylim([-.7 1.2])
	xlabel('Time (s)','Fontsize',25,'FontWeight','bold');
	ylabel('Signal change (a.u.)','Fontsize',25,'FontWeight','bold');
	box off
	whitebg('black');
	set(gcf,'color',[0 0 0])
	set(gca,'linewidth',3.5,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
	export_fig(['ts_roi' char(roi_list(roi)) '.png'],'-r300');
	close all

	% ts_roi_std = squeeze(ts_in_trial_std(roi,:,:));
	% errorbar(t,ts_roi(1,:), ts_roi_std(1,:),'Color',cl1,'LineWidth',3.5);
	% hold on,errorbar(t,ts_roi(2,:), ts_roi_std(2,:),'Color',cl2,'LineWidth',3.5);
	% hold on,errorbar(t,ts_roi(3,:), ts_roi_std(3,:),'Color',cl3,'LineWidth',3.5);
	% hold on,errorbar(t,ts_roi(4,:), ts_roi_std(4,:),'Color',cl4,'LineWidth',3.5);
	% hold on,errorbar(t,ts_roi(5,:), ts_roi_std(5,:),'Color',cl5,'LineWidth',3.5);
	% % h = legend('01 Hz','05 Hz','10 Hz','15 Hz','20 Hz','40 Hz','60 Hz');
	% % set(h,'box','off','location','east','Fontsize',25)
	% xlabel('Time (s)','Fontsize',25,'FontWeight','bold');
	% ylabel('Signal change (a.u.)','Fontsize',25,'FontWeight','bold');
	% xlim([min(t)-1 max(t)+1]);
	% % ylim([min(min(ts_roi))-1.1 max(max(ts_roi))+1.2])
	% box off
	% whitebg('black');
	% set(gcf,'color',[0 0 0])
	% set(gca,'linewidth',3.5,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
	% export_fig(['ts_roi' char(roi_list(roi)) '_errbar.png'],'-r300');
end

% mkdir('group.ts_oc_60Hz')
movefile('ts*','group.event.results/')

cd(batchDir)

