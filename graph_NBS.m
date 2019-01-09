function graph_NBS(data_dir,stimVS,stat_method,cnstSign,t_thresh)

fprintf('++ Start analyzing %s \n in %s \n',stimVS,data_dir);

if ~exist('cnstSign','var') || isempty(cnstSign)
    cnstSign = 'pos';   	
end

if ~exist('t_thresh','var') || isempty(t_thresh)
    t_thresh = '3';   	
end

if length(strfind(stat_method,'nbs_extent'))>0
	load('/data/chaiy3/visualFreq/graph.results/UI_nbs_extent.mat');
elseif length(strfind(stat_method,'nbs_intensity'))>0
	load('/data/chaiy3/visualFreq/graph.results/UI_nbs_intensity.mat');
elseif length(strfind(stat_method,'fdr'))>0
	load('/data/chaiy3/visualFreq/graph.results/UI_fdr.mat');				
end

cd(data_dir);
UI.design.ui=[stimVS '_design.mat'];
UI.contrast.ui=[stimVS '_contrast_' cnstSign '.mat'];
graph_list=dir([stimVS '/*.txt']);
UI.matrices.ui=[stimVS '/' graph_list(1).name];
UI.alpha.ui='0.05';
UI.exchange.ui=[stimVS '_exchange.mat'];
UI.thresh.ui=t_thresh;

node_num=char(extractBetween(data_dir,'roi','_all'));
UI.node_coor.ui=['/data/chaiy3/visualFreq/graph.results/mean/atlas' node_num '_coordinate.txt'];

if length(strfind(stat_method,'nbs'))>0
	UI.perms.ui='10000';
else
	if str2num(node_num)<300
		UI.perms.ui='100000';
	else
		UI.perms.ui='50000';
	end				
end

NBSrun(UI,[]);
global nbs;
if nbs.NBS.n>0
	full(nbs.NBS.con_mat{1});
	sup_thr_con=full(nbs.NBS.con_mat{1,1});
	dlmwrite([stimVS '_' stat_method '_t' t_thresh '_' cnstSign '.edge'], sup_thr_con, 'delimiter', '\t');
	save([stimVS '_' stat_method '_t' t_thresh '_' cnstSign '.mat'],'nbs');
	close all;

	node_file=['/data/chaiy3/visualFreq/graph.results/mean/atlas' node_num '_coordinate.node'];
	BrainNet_MapCfg('/data/chaiy3/Toolbox/BrainNetViewer_20170403/Data/SurfTemplate/BrainMesh_ICBM152_smoothed.nv',...
		node_file,[stimVS '_' stat_method '_t' t_thresh '_' cnstSign '.edge'],'../BrainNet_Cfg.mat',...
		[stimVS '_' stat_method '_t' t_thresh '_' cnstSign '.jpg']);
	close all;
else
	fail_stat=[stat_method '_t' t_thresh '_' cnstSign '_' UI.perms.ui];
	fid=fopen([stimVS '_fail.txt'], 'a');
	fprintf(fid,'%s\n',fail_stat);
	fclose(fid);
end

end

