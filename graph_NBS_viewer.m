function graph_NBS_viewer(data_dir,edge_file)

fprintf('++ Start viewing %s \n in %s \n',edge_file,data_dir);
cd(data_dir)
node_num=char(extractBetween([data_dir '/' edge_file],'roi','_all'));

node_file=['/data/chaiy3/visualFreq/graph.results/mean/atlas' node_num '_coordinate.node'];
BrainNet_MapCfg('/data/chaiy3/Toolbox/BrainNetViewer_20170403/Data/SurfTemplate/BrainMesh_ICBM152_smoothed.nv',...
	node_file,edge_file,'../BrainNet_Cfg.mat',replace(edge_file,'.edge','.jpg'));
close all;

end

