function graph_analysis(subj_dir,graph_file,thr,b_or_w)
% if b_or_w == 1, binary
% if b_or_w == 2, weighted
% subj_dir='/data/chaiy3/visualFreq/170322Sub009/conn_fix.results/rsfc';
% graph_file='roi950_allvec_cor_zcc.1D';
% addpath(genpath('/data/chaiy3/Toolbox'))

if ~exist('b_or_w','var') || isempty(b_or_w)
    b_or_w = '2';
end
if ~exist('thr','var') || isempty(thr)
    thr = 0.1;
else
	thr = str2num(thr);    	
end
curr_dir=pwd;
results_dir='/data/chaiy3/visualFreq/graph.results/mean';

% =============================================================================
% binary
if str2num(b_or_w) == 1
	cd(results_dir)
	roi_index_file=[char(extractBefore(graph_file,'_all')) '_index.1D'];
	roi_index=load(roi_index_file);
	% mask_file=[char(extractBefore(graph_file,'_all')) '_mask.1D'];
	% mask=load(mask_file);
	cd(subj_dir)
	graph=load(graph_file);
	temp_roi_index=load(roi_index_file);
	[~,index,~]=intersect(temp_roi_index,roi_index);
	graph=graph(index,index);
	% graph=graph.*mask;
	graph=graph.*(graph>0);
	graph=threshold_proportional(graph,thr);
	graph=weight_conversion(graph,'binarize');

	fprintf('++ Start analyzing (binary) %s \n in %s \n',graph_file,subj_dir);
	% betweenness centrality measures how often nodes occur on the shortest paths between other nodes
	% Local efficiency: The inverse of the shortest path length for a given node
	deg=degrees_und(graph);
	eff=efficiency_bin(graph,1);
	Geff=efficiency_bin(graph);
	bc=betweenness_bin(graph);
	fprintf('++ Start small_world analyzing ...');
	TempDir=[char(extractBefore(graph_file,'.1D')) '_bin' num2str(thr)];
	if exist(TempDir)==7
		rmdir(TempDir,'s');
	end
	sigma=small_world(graph,100,'b',TempDir);

	cd(subj_dir)		
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','deg'),'.1D',['_bin' num2str(thr)]),deg','precision','%.4f');
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','bc'),'.1D',['_bin' num2str(thr)]),bc','precision','%.4f');
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','eff'),'.1D',['_bin' num2str(thr)]),eff,'precision','%.4f');
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','Geff'),'.1D',['_bin' num2str(thr)]),Geff,'precision','%.4f');
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','sigma'),'.1D',['_bin' num2str(thr)]),sigma,'precision','%.4f');
end

% =============================================================================
% weighted
if str2num(b_or_w) == 2
	% cd(results_dir)
	% roi_index_file=[char(extractBefore(graph_file,'_all')) '_index.1D'];
	% roi_index=load(roi_index_file);
	% % mask_file=[char(extractBefore(graph_file,'_all')) '_mask.1D'];
	% % mask=load(mask_file);
	cd(subj_dir)
	graph=load(graph_file);
	% temp_roi_index=load(roi_index_file);
	% [~,index,~]=intersect(temp_roi_index,roi_index);
	% graph=graph(index,index);
	% % graph=graph.*mask;
	graph=graph.*(graph>0);
	graph=threshold_proportional(graph,thr);

	fprintf('++ Start analyzing (weighted) %s \n in %s \n',graph_file,subj_dir);
	% betweenness centrality measures how often nodes occur on the shortest paths between other nodes
	% Local efficiency: The inverse of the shortest path length for a given node
	deg=degrees_und(graph);
	L=1./graph;
	L(L==Inf)=0;
	bc=betweenness_wei(L);
	eff=efficiency_wei(graph,2);
	Geff=efficiency_wei(graph);
	str=strengths_und(graph);
	cd(subj_dir)		
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','deg'),'.1D',['_thr' num2str(thr)]),deg','precision','%.4f');
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','bc'),'.1D',['_thr' num2str(thr)]),bc,'precision','%.4f');
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','eff'),'.1D',['_thr' num2str(thr)]),eff,'precision','%.4f');
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','Geff'),'.1D',['_thr' num2str(thr)]),Geff,'precision','%.4f');
	dlmwrite(insertBefore(replace(graph_file,'cor_zcc','str'),'.1D',['_thr' num2str(thr)]),str','precision','%.4f');
	
	% fprintf('++ Start small_world analyzing ...');
	% TempDir=[char(extractBefore(graph_file,'.1D')) '_wei' num2str(thr)];
	% if exist(TempDir)==7
	% 	rmdir(TempDir,'s');
	% end
	% sigma=small_world(graph,100,'w',TempDir);

	% cd(subj_dir)		
	% % dlmwrite(insertBefore(replace(graph_file,'cor_zcc','deg'),'.1D',['_thr' num2str(thr)]),deg','precision','%.4f');
	% % dlmwrite(insertBefore(replace(graph_file,'cor_zcc','bc'),'.1D',['_thr' num2str(thr)]),bc,'precision','%.4f');
	% % dlmwrite(insertBefore(replace(graph_file,'cor_zcc','eff'),'.1D',['_thr' num2str(thr)]),eff,'precision','%.4f');
	% % dlmwrite(insertBefore(replace(graph_file,'cor_zcc','Geff'),'.1D',['_thr' num2str(thr)]),Geff,'precision','%.4f');
	% % dlmwrite(insertBefore(replace(graph_file,'cor_zcc','str'),'.1D',['_thr' num2str(thr)]),str','precision','%.4f');
	% dlmwrite(insertBefore(replace(graph_file,'cor_zcc','sigma'),'.1D',['_thr' num2str(thr)]),sigma,'precision','%.4f');
end

cd(curr_dir);
end

