clear;
addpath(genpath('/data/chaiy3/Toolbox'))
batch_dir='/data/chaiy3/visualFreq/batch';
results_dir='/data/chaiy3/visualFreq/graph.results';
data_dir='/data/chaiy3/visualFreq';

% generate proper threshold range based on fragment, small-world sigma and modularity across all subjects 
cd(results_dir)
for roi_num=[950]
	graph_list=[dir('stats950_allmean*Hz.1D');dir('stats950_allmean*fix.1D')];
		% dir('roi950_allmean*fix.1D');dir('stats950_allmean*fix.1D')];
	fprintf('\n ++++++++++++++++++++++++++++++++++++++++++++++++++ \n');
    fprintf('Start with %s ... \n',graph_list(1).name);
    fprintf('++++++++++++++++++++++++++++++++++++++++++++++++++ \n');
	% roi_index_file='roi950_index.1D';
	% roi_index_group=load([results_dir '/roi950_index.1D']);
	thr_min=0.12;
	thr_max=0.12;
	for thr=0.05:0.01:0.25
		fprintf('************************************************* \n');
		fprintf('Start with threshold of %f ... \n',thr);
		% determine good or bad threshold based on fragment
		frag_min=1;
		for a=1:length(graph_list)
			graph=load(graph_list(a).name);
			% temp_index=load([graph_list(a).folder '/' roi_index_file]);
			% [~,ia,~]=intersect(temp_index,roi_index_group);
			% graph=temp_graph(ia,ia);

			graph=graph.*(graph>0);
			graph_thr=threshold_proportional(graph,thr);
			% graph_bin=weight_conversion(graph_thr,'binarize');
			[~,comp_sizes]=get_components(graph_thr);
			frag=max(comp_sizes)/length(graph_thr);
			if a==1
				frag_mean=frag;
			else
				frag_mean=frag_mean+frag;
			end
			if frag<frag_min
				frag_min=frag;
			end
		end
		frag_mean=frag_mean/length(graph_list);
		fprintf('frag_mean = %f, frag_min = %f ... \n', frag_mean, frag_min);

		if frag_min>=0.9
			% determine good or bad threshold based on modularity
			graph_Q_min=1;
			for a=1:length(graph_list)
				graph=load(graph_list(a).name);
				% temp_index=load([graph_list(a).folder '/' roi_index_file]);
				% [~,ia,~]=intersect(temp_index,roi_index_group);
				% graph=temp_graph(ia,ia);

				graph=graph.*(graph>0);
				graph_thr=threshold_proportional(graph,thr);
				% graph_bin=weight_conversion(graph_thr,'binarize');
				mgama=1;
				[~,graph_Q]=community_louvain(graph_thr,mgama);
				if graph_Q<graph_Q_min
					graph_Q_min=graph_Q;
				end
				if a==1
					graph_Q_mean=graph_Q;
				else
					graph_Q_mean=graph_Q+graph_Q_mean;
				end
			end
			graph_Q_mean=graph_Q_mean/length(graph_list);
			fprintf('graph_Q_mean = %f, graph_Q_min = %f ... \n', graph_Q_mean, graph_Q_min);

			if graph_Q_min>=0.3
				% determine good or bad threshold based on small-worldness
				graph_sigma_mean=0;
				graph_sigma_min=0;
				if graph_Q_min<0.31
					graph_sigma_min=3;
					for a=1:length(graph_list)
						graph=load(graph_list(a).name);
						% temp_index=load([graph_list(a).folder '/' roi_index_file]);
						% [~,ia,~]=intersect(temp_index,roi_index_group);
						% graph=temp_graph(ia,ia);

						graph_sigma=small_world(graph,num2str(thr),1,'w');
						if a==1
							graph_sigma_mean=graph_sigma;
						else
							graph_sigma_mean=graph_sigma_mean+graph_sigma;
						end	
						if graph_sigma<graph_sigma_min
							graph_sigma_min=graph_sigma;
						end
					end
					graph_sigma_mean=graph_sigma_mean/length(graph_list);
					fprintf('graph_sigma_mean = %f, graph_sigma_min = %f ... \n', ...
						graph_sigma_mean,graph_sigma_min);
				end

				if graph_sigma_min==0 || graph_sigma_min>1
					fprintf('Threshold = %f meets all requirements ... \n', thr);
					if thr_min>thr
						thr_min=thr;
					elseif thr_max<thr
						thr_max=thr;
					end
				end
			end
		end
	end
	% if graph_sigma_min==0 || graph_sigma_min<1
	% 	fprintf('Have not calculated the small-worldness, exiting early.\n');
	% 	fprintf('Reset the threshold to jump into small-worldness situation.\n');
	% 	return;
	% else
	% 	dlmwrite([results_dir '/roi' num2str(roi_num) '_thr_frag_Q_sw.1D'],[thr_min thr_max]);
	% end
end

cd(batch_dir)

