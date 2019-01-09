clear;
dataDir='/Volumes/data/visualFreq/';
batchDir='/Volumes/data/visualFreq/batch';
stim_list={'fix';'01Hz';'10Hz';'20Hz';'40Hz'};
power_file='power_thalamus.1D';
power_all=zeros(length(stim_list),108);
cd(dataDir)

for stim=1:length(stim_list)
	sub_list=dir(['*Sub*/conn_' char(stim_list(stim)) '.results/' power_file]);
	for subj=1:length(sub_list)
		temp_power=load([sub_list(subj).folder '/' sub_list(subj).name]);
		if subj==1
			mean_power=temp_power;
		else
			mean_power=mean_power+temp_power;
		end
	end
	mean_power=mean_power/length(sub_list);
	power_all(stim,:)=mean_power;
end


cl1 = [255 0 0]/255;
cl2 = [0 255 0]/255;
cl3 = [0 255 255]/255;
cl4 = [0 0 255]/255;
cl5 = [255 0 255]/255;			
f = 0.00272*(1:108);
plot(f,power_all(1,:),'Color',cl1,'LineWidth',3.5);
hold on,plot(f,power_all(2,:),'Color',cl2,'LineWidth',3.5);
hold on,plot(f,power_all(3,:),'Color',cl3,'LineWidth',3.5);
hold on,plot(f,power_all(4,:),'Color',cl4,'LineWidth',3.5);
hold on,plot(f,power_all(5,:),'Color',cl5,'LineWidth',3.5);
h = legend('Ctrl','01 Hz','10 Hz','20 Hz','40 Hz');
set(h,'box','off','location','northeast','Fontsize',25)
xlim([0.01 0.15]);
% ylim([-.7 1.2])
xlabel('Frequency (Hz)','Fontsize',25,'FontWeight','bold');
ylabel('Power','Fontsize',25,'FontWeight','bold');
box off
whitebg('black');
set(gcf,'color',[0 0 0])
set(gca,'linewidth',3.5,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
export_fig(['power.png'],'-r300');
% close all

movefile('power*','group.results/')
cd(batchDir)

