clear;
addpath(genpath('/data/chaiy3/Toolbox'))
batch_dir='/data/chaiy3/visualFreq/batch';
results_dir='/data/chaiy3/visualFreq/graph.results';
data_dir='/data/chaiy3/visualFreq';

% % ========= calculate consensus module across subjects ==================
% cd([data_dir '/170405Sub012/conn_fix.results/rsfc']);
% graph_list=dir('M_thr_roi950_all*_cor_z.1D');
% stim_list={'fix';'01Hz';'10Hz';'20Hz';'40Hz'};
% for a=1:length(graph_list)
% 	fprintf('Start with %s ... \n',graph_list(a).name);

% 	cd(results_dir)
% 	roi_index_file=[char(extractBefore(graph_list(a).name,'_all')) '_index.1D'];
% 	roi_index_file=char(extractAfter(roi_index_file,'thr_'));
% 	roi_index=load(roi_index_file);

% 	cd(data_dir)
% 	for b=1:length(stim_list)
% 		sub_list=dir(['*Sub*/conn_' char(stim_list(b)) '.results/rsfc/' graph_list(a).name]);
% 		CI_thr=zeros(length(roi_index),length(sub_list));
% 		for c=1:length(sub_list)
% 			CI_thr(:,c)=load([sub_list(c).folder '/' sub_list(c).name]);
% 		end
% 		% [S2, Q2, X_new3, qpc] = consensus_iterative(CI_thr');
% 		% D_thr = agreement(CI_thr);
% 		% [~, nmi_thr] = partition_distance(CI_thr);
% 		% CIU_thr = consensus_und(D_thr,0.5,100);
% 		[consensus, ~, ~] = consensus_similarity(CI_thr');
% 		graph_M_thr = [consensus]';
% 		fprintf('module num = %d for stim %s\n',length(unique(graph_M_thr)),char(stim_list(b)));
% 		dlmwrite([results_dir '/' replace(graph_list(a).name,'cor_z',char(stim_list(b)))],graph_M_thr);			
% 	end

% 	% dlmwrite([results_dir '/' replace(graph_list(a).name,'cor_z','mean')],mean_graph_stim,' ');	
% end

% % ========= calculate group statistic graph ==================
% cd([data_dir '/170405Sub012/conn_fix.results/rsfc']);
% graph_list=dir('roi950_allmean_cor_z1col.1D');
% for a=1:length(graph_list)
% 	fprintf('Start with %s ... \n',graph_list(a).name);

% 	cd(results_dir)
% 	roi_index_file=[char(extractBefore(graph_list(a).name,'_all')) '_index.1D'];
% 	roi_index=load(roi_index_file);

% 	cd(data_dir)
% 	sub_list=dir('*Sub*');
% 	graph=zeros(length(sub_list),length(roi_index),length(roi_index));
% 	for sub=1:length(sub_list)
% 		cd([data_dir '/' sub_list(sub).name]);
% 		run_list=dir('conn_fix.results');
% 		graph_sub=zeros(length(roi_index),length(roi_index));
% 		for run=1:length(run_list)
% 			graph_sub=graph_sub+reshape(load([run_list(run).name '/rsfc/' graph_list(a).name]),...
% 				length(roi_index),length(roi_index));
% 		end

% 		graph(sub,:,:)=graph_sub/length(run_list);
% 	end


% 	graph_p=zeros(length(roi_index),length(roi_index));
% 	for i=2:length(roi_index)
% 		for j=1:i-1
% 			[~,graph_p(i,j),~,~]=ttest(squeeze(squeeze(graph(:,i,j))),0,'Tail','right');
% 			graph_p(j,i)=graph_p(i,j);
% 		end
% 	end

% 	p=graph_p.*tril(ones(size(graph_p)),-1);
% 	p=p(find(p~=0));
% 	% dlmwrite([results_dir '/p.1D'],p,' ');
% 	q=mafdr(p,'BHFDR', true);	
% end

cd([data_dir '/170720Sub021/conn_fix.results/rsfc']);
graph_list=[dir('roi9*_all*_cor_z.1D')];
cd(data_dir)
% ========= calculate mean graph across subjects ==================
stim_list={'fix';'01Hz';'10Hz';'20Hz';'40Hz'};
for a=1:length(graph_list)
	fprintf('++ Start with %s ... \n',graph_list(a).name);
	% make roi_index consistent across different subjs and runs
	roi_index_file=[char(extractBefore(graph_list(a).name,'_all')) '_index.1D'];
	roi_index_list=dir(['*Sub*/conn*results/rsfc/' roi_index_file]);
	for d=1:length(roi_index_list)
		if d==1
			roi_index=load([roi_index_list(d).folder '/' roi_index_list(d).name]);
		else
			temp=load([roi_index_list(d).folder '/' roi_index_list(d).name]);
			roi_index=intersect(temp,roi_index);
		end
		fprintf('ROI number is %d for %s \n',length(roi_index),roi_index_list(d).folder);
	end
	dlmwrite([results_dir '/mean/' roi_index_file],roi_index,' ');
	fprintf('ROI number is %d for %s \n',length(roi_index),graph_list(a).name); 

	% coordinate for roi_index
	roi_name=char(extractBetween(graph_list(a).name,'roi','_all'));
	atlas=load(['Atlas/atlas' roi_name '_coordinate.1D']);
	if sum(findstr(roi_name,'0'))>0
		atlas(:,3) = -atlas(:,3);
	end
	if sum(findstr(roi_name,'268'))>0
		atlas(:,3) = -atlas(:,3);
	end
	if sum(findstr(roi_name,'27'))>0
		atlas(:,2) = -atlas(:,2);
	end
	[~,ia,~]=intersect([atlas(:,1)]',roi_index);
	atlas=[atlas(ia,2:5) ones(length(roi_index),1) ones(length(roi_index),1)];
	dlmwrite([results_dir '/mean/atlas' roi_name '_coordinate.node'],atlas,'delimiter','\t');

	% fdrmask
	fdrmask = triu(ones(length(roi_index),length(roi_index)),1);
	fdrmask = reshape(fdrmask,length(roi_index)*length(roi_index),1);
	dlmwrite([results_dir '/stats/roi' roi_name '_fdrmask.1D'],fdrmask);

	% mean graph
	for b=1:length(stim_list)
		sub_list=dir(['*Sub*/conn_' char(stim_list(b)) '.results/rsfc/' graph_list(a).name]);
		for c=1:length(sub_list)
			fprintf('++ Start with %s ... \n',sub_list(c).folder);
			temp_graph=load([sub_list(c).folder '/' sub_list(c).name]);
			temp_index=load([sub_list(c).folder '/' roi_index_file]);
			[~,ia,~]=intersect(temp_index,roi_index);
			temp_graph=temp_graph(ia,ia);
			dlmwrite([sub_list(c).folder '/' insertBefore(sub_list(c).name,'.1D','cc')],temp_graph);
			% sub_graph=reshape(temp_graph,length(temp_graph)*length(temp_graph),1);
			% dlmwrite([sub_list(c).folder '/' insertBefore(sub_list(c).name,'.1D','1col')],sub_graph);
			% if c==1
			% 	mean_graph=temp_graph;
			% else
			% 	mean_graph=mean_graph+temp_graph;
			% end
		end
		% mean_graph=mean_graph/length(sub_list);

		% if b==1
		% 	mean_graph_stim=mean_graph;
		% else
		% 	mean_graph_stim=mean_graph_stim+mean_graph;
		% end
		
		% dlmwrite([results_dir '/' replace(graph_list(a).name,'cor_z',char(stim_list(b)))],mean_graph,' ');
	end

	% dlmwrite([results_dir '/' replace(graph_list(a).name,'cor_z','mean')],mean_graph_stim,' ');	
end

% % ============================ plot group mean graph =============================
% cd(results_dir)
% graph=load('roi950_allvec_mean.1D');
% graph=threshold_proportional(graph,0.1);
% M=load('sort.M_r2_thr0.1_Q0.69_roi950_allvec_mean.1D');
% nw_list={'DMN';'Visual';'Attention';'Sensorimotor';'Salience';'Cerebellum';'Subcortical';'other'};

% % reoder graph
% M(find(M==0))=M(find(M==0))+max(M)+1;
% [M_sort,M_index] = sort(M);
% graph_sort=graph(M_index,:);
% graph_sort=graph_sort(:,M_index);

% tick_index=zeros(8,1);
% for i=1:8
% 	if i==1
% 		tick_index(i)=length(find(M==i))/2;
% 	else
% 		tick_index(i)=length(find(M<i))+length(find(M==i))/2;
% 	end
% end
% figure;
% imagesc(graph_sort,[0 4.5])
% colormap(jet);
% colorbar('location','eastoutside','Fontsize',11,'Color','white')
% set(gcf,'color',[0 0 0])
% set(gca,'XTick',tick_index,'XTickLabel',[],'YTick',tick_index, ...
% 	'YTickLabel',nw_list,'fontsize',15,'Xcolor',[1 1 1],'Ycolor',[1 1 1])
% % xtickangle(45);
% % ytickangle(45);
% box off
% export_fig(['cc_mean.png'],'-r300');


% % ============================ generate statistical group graph =============================
% cd(results_dir)
% graph_stats_list=dir('stats.LME.roi950_allvec_cor_z1col.1D');
% for roi=1:length(graph_stats_list)
% 	fprintf('Start with %s ... \n',graph_stats_list(roi).name);
% 	graph_stats=load(graph_stats_list(roi).name);
% 	roi_num=extractBefore(graph_stats_list(roi).name,'_all');
% 	roi_num=extractAfter(roi_num,'roi');
% 	graph_stats=graph_stats(:,24:2:end); % fix, 01Hz, 10Hz, 20Hz, 40Hz, mean
% 	node_num=sqrt(length(graph_stats));
% 	for stim=1:6
% 		graph=reshape(graph_stats(:,stim),[node_num,node_num]);
% 		if stim==1
% 			dlmwrite(['stats' char(roi_num) '_allvec_fix.1D'],graph);
% 		elseif stim==2
% 			dlmwrite(['stats' char(roi_num) '_allvec_01Hz.1D'],graph);
% 		elseif stim==3
% 			dlmwrite(['stats' char(roi_num) '_allvec_10Hz.1D'],graph);
% 		elseif stim==4
% 			dlmwrite(['stats' char(roi_num) '_allvec_20Hz.1D'],graph);
% 		elseif stim==5
% 			dlmwrite(['stats' char(roi_num) '_allvec_40Hz.1D'],graph);
% 		elseif stim==6
% 			dlmwrite(['stats' char(roi_num) '_allvec_mean.1D'],graph);
% 		end
% 	end
% end

cd(batch_dir)

