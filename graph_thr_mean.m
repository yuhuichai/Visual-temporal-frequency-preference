clear;
addpath(genpath('/data/chaiy3/Toolbox'))
batch_dir='/data/chaiy3/visualFreq/batch';
results_dir='/data/chaiy3/visualFreq/graph.results';
data_dir='/data/chaiy3/visualFreq';

% % generate proper threshold range based on fragment, small-world sigma and modularity across all subjects 
% cd(data_dir)
% for roi_num=[950]
% 	graph_list=dir(['*Sub*/conn*results/rsfc/roi' num2str(roi_num) '_allmean_cor_z.1D']);
% 	fprintf('\n ++++++++++++++++++++++++++++++++++++++++++++++++++ \n');
%     fprintf('Start with %s ... \n',graph_list(1).name);
%     fprintf('++++++++++++++++++++++++++++++++++++++++++++++++++ \n');
% 	% roi_index_file='roi950_index.1D';
% 	% roi_index_group=load([results_dir '/roi950_index.1D']);
% 	thr_min=0.12;
% 	thr_max=0.12;
% 	for thr=0.05:0.01:0.25
% 		fprintf('************************************************* \n');
% 		fprintf('Start with threshold of %f ... \n',thr);
% 		% determine good or bad threshold based on fragment
% 		frag_min=1;
% 		for a=1:length(graph_list)
% 			graph=load([graph_list(a).folder '/' graph_list(a).name]);
% 			% temp_index=load([graph_list(a).folder '/' roi_index_file]);
% 			% [~,ia,~]=intersect(temp_index,roi_index_group);
% 			% graph=temp_graph(ia,ia);

% 			graph=graph.*(graph>0);
% 			graph_thr=threshold_proportional(graph,thr);
% 			graph_bin=weight_conversion(graph_thr,'binarize');
% 			[~,comp_sizes]=get_components(graph_bin);
% 			frag=max(comp_sizes)/length(graph_bin);
% 			if a==1
% 				frag_mean=frag;
% 			else
% 				frag_mean=frag_mean+frag;
% 			end
% 			if frag<frag_min
% 				frag_min=frag;
% 			end
% 		end
% 		frag_mean=frag_mean/length(graph_list);
% 		fprintf('frag_mean = %f, frag_min = %f ... \n', frag_mean, frag_min);

% 		if frag_mean>=0.9
% 			% determine good or bad threshold based on modularity
% 			for a=1:length(graph_list)
% 				graph=load([graph_list(a).folder '/' graph_list(a).name]);
% 				% temp_index=load([graph_list(a).folder '/' roi_index_file]);
% 				% [~,ia,~]=intersect(temp_index,roi_index_group);
% 				% graph=temp_graph(ia,ia);

% 				graph=graph.*(graph>0);
% 				graph_thr=threshold_proportional(graph,thr);
% 				graph_bin=weight_conversion(graph_thr,'binarize');
% 				mgama=1;
% 				[~,graph_Q]=community_louvain(graph_bin,mgama);
% 				if a==1
% 					graph_Q_mean=graph_Q;
% 				else
% 					graph_Q_mean=graph_Q+graph_Q_mean;
% 				end
% 			end
% 			graph_Q_mean=graph_Q_mean/length(graph_list);
% 			fprintf('graph_Q_mean = %f ... \n', graph_Q_mean);

% 			if graph_Q_mean>=0.3
% 				% determine good or bad threshold based on small-worldness
% 				graph_sigma_mean=0;
% 				if graph_Q_mean<0.31
% 					for a=1:length(graph_list)
% 						graph=load([graph_list(a).folder '/' graph_list(a).name]);
% 						% temp_index=load([graph_list(a).folder '/' roi_index_file]);
% 						% [~,ia,~]=intersect(temp_index,roi_index_group);
% 						% graph=temp_graph(ia,ia);

% 						graph_sigma=small_world(graph,num2str(thr),1,'b');
% 						if a==1
% 							graph_sigma_mean=graph_sigma;
% 						else
% 							graph_sigma_mean=graph_sigma_mean+graph_sigma;
% 						end
% 						% fprintf('graph_sigma = %f for %s ... \n', graph_sigma, graph_list(a).folder);		
% 					end
% 					graph_sigma_mean=graph_sigma_mean/length(graph_list);
% 					fprintf('graph_sigma_mean = %f ... \n', graph_sigma_mean);
% 				end

% 				if graph_sigma_mean==0 || graph_sigma_mean>1
% 					fprintf('Threshold = %f meets all requirements ... \n', thr);
% 					if thr_min>thr
% 						thr_min=thr;
% 					elseif thr_max<thr
% 						thr_max=thr;
% 					end
% 				end
% 			end
% 		end
% 	end
% 	if graph_sigma_mean==0 || graph_sigma_mean<1
% 		fprintf('Have not calculated the small-worldness, exiting early.\n');
% 		fprintf('Reset the threshold to jump into small-worldness situation.\n');
% 		return;
% 	else
% 		dlmwrite([results_dir '/roi' num2str(roi_num) '_bin_frag_Q_sw.1D'],[thr_min thr_max]);
% 	end
% end

cd(data_dir)
for roi_num=[950]
	graph_list=dir(['*Sub*/conn*results/rsfc/roi' num2str(roi_num) '_allvec_cor_z.1D']);
	fprintf('\n ++++++++++++++++++++++++++++++++++++++++++++++++++ \n');
    fprintf('Start with %s ... \n',graph_list(1).name);
    fprintf('++++++++++++++++++++++++++++++++++++++++++++++++++ \n');
	roi_index_file='roi950_index.1D';
	roi_index_group=load([results_dir '/roi950_index.1D']);
	thr_min=0.12;
	thr_max=0.12;
	thr=0.06;
	while thr<0.4
		fprintf('************************************************* \n');
		fprintf('Start with threshold of %f ... \n',thr);
		% determine good or bad threshold based on fragment
		frag=zeros(length(graph_list),1);
		for a=1:length(graph_list)
			temp_graph=load([graph_list(a).folder '/' graph_list(a).name]);
			temp_index=load([graph_list(a).folder '/' roi_index_file]);
			[~,ia,~]=intersect(temp_index,roi_index_group);
			graph=temp_graph(ia,ia);

			graph=graph.*(graph>0);
			graph_thr=threshold_proportional(graph,thr);
			[~,comp_sizes]=get_components(graph_thr);
			frag(a)=max(comp_sizes)/length(graph_thr);
		end
		[~,frag_p]=ttest(frag,0.9,'Tail','right');
		fprintf('frag_mean = %f, frag_p = %f for frag larger than 0.9 ... \n', ...
			mean(frag), frag_p);

		if frag_p>0.001
			thr=thr+0.01;
		else
			if thr_min>thr
				thr_min=thr;
			end
			if thr<0.2
				thr=0.34;
				fprintf('************************************************* \n');
				fprintf('Start with threshold of %f ... \n',thr);
			end
			
			sw=zeros(length(graph_list),1);
			for a=1:length(graph_list)
				temp_graph=load([graph_list(a).folder '/' graph_list(a).name]);
				temp_index=load([graph_list(a).folder '/' roi_index_file]);
				[~,ia,~]=intersect(temp_index,roi_index_group);
				graph=temp_graph(ia,ia);

				graph=graph.*(graph>0);
				graph_thr=threshold_proportional(graph,thr);
				sw(a)=small_world(graph_thr,1,'w','Temp');
				fprintf('sigma = %f for %s ... \n', sw(a), graph_list(a).folder);					
			end
			[~,sw_p]=ttest(sw,1,'Tail','right');
			fprintf('sigma_mean = %f, sw_p = %f for sw > 1 ... \n', mean(sw),sw_p);
			if thr_max<thr && sw_p<=0.001
				thr_max=thr;
				fprintf('============================================= \n');
				fprintf('++ thr_max = %f ... \n', thr_max);
			end
			if sw_p<0.001
				thr=thr+0.01;
			else
				thr=thr-0.01;
			end
			if thr<=thr_max || thr_max<=0.34
				fprintf('============================================= \n');
				fprintf('++ Have found proper threshold range ... \n');
				dlmwrite([results_dir '/roi' num2str(roi_num) '_thr_frag_sw.1D'],[thr_min thr_max]);
				return;
			end
		end
	end
end

cd(batch_dir)

