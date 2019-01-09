clear;
resultsDir='~/Data/visualFreq/graph.results';
cd(resultsDir)
M_file=dir('sort.M_r2_thr0.1_Q*_roi950_allvec_mean.1D');
M=load(M_file(1).name);
effectDir='~/Data/visualFreq/group.effects';
cd(effectDir)
nw_list={'DMN';'VS';'VSp';'SM';'SN';'Cb';'Tha'};

% stim=4;
% subj=12;
act=load('event_calcarine.1D');
% act=act-repmat(mean(act,2),1,7);
% act=act(:,[1 3 4 5]);
act=sum(act)./sum(act~=0);
% act=act(:,stim);

cor_name='roi950_allvec_str_betw_Tha_V1_thr0.3_calcarine.1D';
cor=load(cor_name);
cor=[cor(2:(end-3),:);cor(end,:)];
cor=cor-repmat(cor(:,1),1,5).*(cor~=0);
cor=cor(:,2:end);
cor=sum(cor)./sum(cor~=0);
% cor=cor(:,stim);

node_num=0;
if length(strfind(cor_name,'_str_'))>0
	for nw_index=1:length(nw_list)
		if length(strfind(cor_name,['_' char(nw_list(nw_index)) '_']))>0
			node_num=node_num+length(find(M==nw_index));
			fprintf('++ include %s \n',char(nw_list(nw_index)));
		end
	end
end
if node_num>0
	cor=cor/node_num;
end

act=act(find(cor~=0));
cor=cor(find(cor~=0));

[p,S] = polyfit(act,cor,1);
x_min = min(act)-0.1;
x_max = max(act)+0.1;
x = linspace(x_min,x_max);
y = polyval(p,x);
R = corrcoef(act,cor);
R2=R(2).^2;

plot(act,cor,'d',x,y,'Color','w','LineWidth',3);
xlabel('Signal changes in V1 (%)','Fontsize',25,'FontWeight','bold');
ylabel('V1-Tha Conn. Rel. to Ctrl','Fontsize',25,'FontWeight','bold');
title(['R2 = ' num2str(R2,'%10.2f') ', S = ' num2str(p(1),'%10.2f')],'fontsize',25,'FontWeight','bold')
% ylim([0 0.7])
xlim([x_min-0.1 x_max+0.1])
box off
whitebg('black');
set(gcf,'color',[0 0 0])
set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
export_fig('fit.png','-r300');
% close all

% ===================================================================================================
% correlationship between different nerwork strength
stim=1;
act_name='roi950_allvec_str_betw_VS_SN_thr0.1.1D';
act=load(act_name);
% act=act-repmat(act(:,1),1,5).*(act~=0);
act=act(:,stim);
node_num=0;
if length(strfind(act_name,'_str_'))>0
	for nw_index=1:length(nw_list)
		if length(strfind(act_name,['_' char(nw_list(nw_index)) '_']))>0
			node_num=node_num+length(find(M==nw_index));
			fprintf('++ include %s \n',char(nw_list(nw_index)));
		end
	end
end
if node_num>0
	act=act/node_num;
end


cor_name='roi950_allvec_str_in_SN_thr0.1.1D';
cor=load(cor_name);
% cor=cor-repmat(cor(:,1),1,5).*(cor~=0);
cor=cor(:,stim);
node_num=0;
if length(strfind(cor_name,'_str_'))>0
	for nw_index=1:length(nw_list)
		if length(strfind(cor_name,['_' char(nw_list(nw_index)) '_']))>0
			node_num=node_num+length(find(M==nw_index));
			fprintf('++ include %s \n',char(nw_list(nw_index)));
		end
	end
end
if node_num>0
	cor=cor/node_num;
end


act=act(find(cor~=0));
cor=cor(find(cor~=0));

[p,S] = polyfit(act,cor,1);
x_min = min(act)-0.1;
x_max = max(act)+0.1;
x = linspace(x_min,x_max);
y = polyval(p,x);
R = corrcoef(act,cor);
R2=R(2).^2;

plot(act,cor,'d',x,y,'Color','w','LineWidth',3);
xlabel('Network Strength of VS-SN','Fontsize',25,'FontWeight','bold');
ylabel('Network Strength in SN','Fontsize',25,'FontWeight','bold');
title(['R2 = ' num2str(R2,'%10.2f') ', S = ' num2str(p(1),'%10.2f')],'fontsize',25,'FontWeight','bold')
% ylim([0 0.7])
% xlim([0.3 5.7])
box off
whitebg('black');
set(gcf,'color',[0 0 0])
set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
export_fig('fit.png','-r300');

% effect0=load('roi950_allvec_str_in_VS_thr0.1.1D');
% effect=zeros(size(effect0));
% for subj=1:size(effect0,1)
% 	stim_n0=find(effect0(subj,:)~=0);
% 	effect(subj,stim_n0)=(effect0(subj,stim_n0)-effect0(subj,1)); % remove control baseline
% end
% effect=effect(:,2:end);
% effect=effect-repmat(mean(effect,2),1,4).*(effect~=0);
% stim=zeros(size(effect));
% stim(:,1)=1;
% stim(:,2)=2;
% stim(:,3)=3;
% stim(:,4)=4;

% stim=stim(find(effect~=0));
% effect=effect(find(effect~=0));

% [p,S] = polyfit(stim,effect,1);
% x = linspace(0,6);
% y = polyval(p,x);
% R = corrcoef(stim,effect);

% plot(stim,effect,'*',x,y,'Color','w','LineWidth',3);
% xlabel('stim','Fontsize',25,'FontWeight','bold');
% ylabel('Global Correlation','Fontsize',25,'FontWeight','bold');
% % ylim([0 0.7])
% % xlim([0.3 5.7])
% box off
% whitebg('black');
% set(gcf,'color',[0 0 0])
% set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
% export_fig('effect.png','-r300');
% close all

cd(batchDir)

