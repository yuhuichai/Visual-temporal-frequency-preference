function graph_module(graph_file,mgamma,thr,subj_dir,b_or_w)
% if b_or_w == 1, binary
% if b_or_w == 2, weighted

curr_dir=pwd;
results_dir='/data/chaiy3/visualFreq/graph.results';
if ~exist('subj_dir','var') || isempty(subj_dir)
    subj_dir = results_dir;
end
if ~exist('b_or_w','var') || isempty(b_or_w)
    b_or_w = '2';
end
if ~exist('mgamma','var') || isempty(mgamma)
    mgamma = 1;
else
	mgamma = str2num(mgamma);    	
end
if ~exist('thr','var') || isempty(thr)
    thr = 0.1;
else
	thr = str2num(thr);    	
end

% =============================================================================
% binary
if str2num(b_or_w) == 1
	fprintf('++ Start modular analyzing (binary) %s \n ++ in %s ... \n',graph_file,subj_dir);
	cd(results_dir)
	roi_index_file=[char(extractBefore(graph_file,'_all')) '_index.1D'];
	roi_index=load(roi_index_file);
	% mask_file=[char(extractBefore(graph_file,'_all')) '_mask.1D'];
	% mask=load(mask_file);

	cd(subj_dir)
	temp_roi_index=load(roi_index_file);
	[~,index,~]=intersect(temp_roi_index,roi_index);
	graph=load(graph_file);	
	graph=graph(index,index);
	% graph=graph.*mask;
	graph=graph.*(graph>0);
	graph=threshold_proportional(graph,thr);
	graph=weight_conversion(graph,'binarize');

	rep_times=250;
	CI=zeros(length(graph),rep_times);
	for rep=1:rep_times
		[CI(:,rep),~]=community_louvain(graph,mgamma);
	end

	[S2, Q2, X_new3, qpc] = consensus_iterative(CI');
	M = [S2(1,:)]';
	fprintf('module num = %d, modularity = %f\n',length(unique(M)),mean(Q2));
	dlmwrite(['M_r' num2str(mgamma) '_bin' num2str(thr) '_Q' num2str(mean(Q2),'%10.2f') ...
		'_' graph_file],M);
end

% =============================================================================
% weighted
if str2num(b_or_w) == 2
	fprintf('++ Start modular analyzing (weighted) %s \n ++ in %s ... \n',graph_file,subj_dir);
	cd(results_dir)
	roi_index_file=[char(extractBefore(graph_file,'_all')) '_index.1D'];
	roi_index=load(roi_index_file);
	% mask_file=[char(extractBefore(graph_file,'_all')) '_mask.1D'];
	% mask=load(mask_file);

	cd(subj_dir)
	temp_roi_index=load(roi_index_file);
	[~,index,~]=intersect(temp_roi_index,roi_index);
	graph=load(graph_file);	
	graph=graph(index,index);
	% graph=graph.*mask;
	graph=graph.*(graph>0);
	graph=threshold_proportional(graph,thr);

	rep_times=250;
	CI=zeros(length(graph),rep_times);
	for rep=1:rep_times
		[CI(:,rep),~]=community_louvain(graph,mgamma);
	end

	[S2, Q2, X_new3, qpc] = consensus_iterative(CI');
	M = [S2(1,:)]';
	fprintf('module num = %d, modularity = %f\n',length(unique(M)),mean(Q2));
	dlmwrite(['M_r' num2str(mgamma) '_thr' num2str(thr) '_Q' num2str(mean(Q2),'%10.2f') ...
		'_' graph_file],M);
end

cd(curr_dir)
end

