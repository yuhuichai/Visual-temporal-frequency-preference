clear;
resultsDir='~/Data/visualFreq/graph.results';
cd(resultsDir)
M_file=dir('sort.M_r2_thr0.1_Q0.69_roi950_allvec_mean.1D');
M=load(M_file(1).name);
effectDir='~/Data/visualFreq/group.effects';
cd(effectDir)
batchDir='~/Data/visualFreq/batch';
stim_list={'Ctrl' '01Hz' '10Hz' '20Hz' '40Hz'};
nw_list={'DMN';'VS';'VSp';'SM';'SN';'Cb';'Tha'};
% nw_list={'01Hz';'40Hz';'both';'Tha';'DMN';'VSp';'SM';'SN';'Cb'};
stim_num=length(stim_list);

effect_list = [dir('corr_*Thalamus_z_*.vs40Hz_mask.1D')]; % ;dir('*_LMeff*.1D')
for index=1:length(effect_list)
	fprintf('***************************************************\n');
	fprintf('++ Begin analyzing %s \n',effect_list(index).name);
	% node_num=0;
	% if length(strfind(effect_list(index).name,'_str_'))>0
	% 	for nw_index=1:length(nw_list)
	% 		if length(strfind(effect_list(index).name,['_' char(nw_list(nw_index)) '_']))>0
	% 			node_num=node_num+length(find(M==nw_index));
	% 			fprintf('++ include %s \n',char(nw_list(nw_index)));
	% 		end
	% 	end
	% end
	effect_delta=load(replace(effect_list(index).name,'vs40Hz','vs01Hz_gt_40Hz'));
	effect_gamma=load(effect_list(index).name);
	% if node_num>0
	% 	effect0=effect0/node_num;
	% end
	% effect=zeros(size(effect0));

	% for subj=1:size(effect0,1)
	% 	stim_n0=find(effect0(subj,:)~=0);
	% 	effect(subj,stim_n0)=(effect0(subj,stim_n0)-effect0(subj,1)); % remove control baseline
	% end
	% effect=effect(:,2:end);

	effect=effect0;
	effect_mean=zeros(stim_num,1);
	effect_std=zeros(stim_num,1);
	for stim=1:stim_num
		subj_n0=find(effect(:,stim)~=0);
		effect_mean(stim)=mean(effect(subj_n0,stim));
		effect_std(stim)=std(effect(subj_n0,stim))/sqrt(length(subj_n0));
	end

	figure;
	bar(effect_mean,0.6,'FaceColor',[.5 .5 .5],'EdgeColor',[0.5 0.5 0.5],'LineWidth',2)
	hold on; errorbar(effect_mean,effect_std,'x','MarkerEdgeColor','none','LineWidth',3,'Color','w');
	% for subj=1:length(effect)
	% 	hold on
	% 	x=1:length(stim_list);
	% 	y=effect(subj,:);
	% 	x=x(find(y));
	% 	y=y(find(y));		
	% 	plot(x,y,'-d','LineWidth',2.5);
	% end

	ylabel('Net. Str. of Gamma vs. Delta','Fontsize',25,'FontWeight','bold');
	set(gca,'xticklabel',stim_list);,
	xtickangle(0);
	% ylim([0 0.7])
	xlim([0.3 stim_num+0.7])
	box off
	whitebg('black');
	set(gcf,'color',[0 0 0])
	set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
	fig_name=replace(effect_list(index).name,'.1D','.png');
	export_fig(fig_name,'-r300');
	% close all

	for i=1:stim_num
		eff_p=effect(:,i);
		eff_p=eff_p(find(eff_p~=0));
		[h_r,p_r]=ttest(eff_p,0,'Tail','right');
		[h_l,p_l]=ttest(eff_p,0,'Tail','right');
		if p_r<=p_l
			h=h_r;
			p=p_r;
		else
			h=h_l;
			p=p_l;
		end
			
		if h==1
			fprintf('Warning: there is a significant difference (p = %f) between %s and control \n', ...
				p,string(stim_list(i))); 
		else 
			fprintf('No significant difference, (p = %f) between %s and control \n', ...
				p,string(stim_list(i)));
		end
		if i<stim_num		
		for j=i+1:stim_num
				eff_p=effect(:,i)-effect(:,j);
				index_n0=intersect(find(effect(:,i)~=0),find(effect(:,j)~=0));
				eff_p=eff_p(index_n0);
				[h_r,p_r]=ttest(eff_p,0,'Tail','right');
				[h_l,p_l]=ttest(eff_p,0,'Tail','right');
				if p_r<=p_l
					h=h_r;
					p=p_r;
				else
					h=h_l;
					p=p_l;
				end
				if h==1
					fprintf('Warning: there is a significant difference (p = %f) between %s and %s \n', ...
						p,string(stim_list(i)),string(stim_list(j))); 
				else 
					fprintf('No significant difference (p = %f) between %s and %s \n', ...
						p,string(stim_list(i)),string(stim_list(j))); 
				end
			end
		end
	end
end

% cd(batchDir)
