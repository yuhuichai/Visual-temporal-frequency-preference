function graph_analysis_module(subj_dir,graph_file,M_file,thr,b_or_w)
% subj_dir='/data/chaiy3/visualFreq/170322Sub009/conn_fix.results/rsfc';
% graph_file='roi950_allvec_cor_z.1D';
% addpath(genpath('/data/chaiy3/Toolbox'))

curr_dir=pwd;
results_dir='/data/chaiy3/visualFreq/graph.results';
if ~exist('thr','var') || isempty(thr)
    thr = 0.1;
else
	thr = str2num(thr);    	
end

if ~exist('b_or_w','var') || isempty(b_or_w)
    b_or_w = '2';
end

cd(results_dir)
roi_index_file=[char(extractBefore(graph_file,'_all')) '_index.1D'];
roi_index=load(roi_index_file);
% mask_file=[char(extractBefore(graph_file,'_all')) '_mask.1D'];
% mask=load(mask_file);
M=load(M_file);
cd(subj_dir)
graph=load(graph_file);
temp_roi_index=load(roi_index_file);
[~,index,~]=intersect(temp_roi_index,roi_index);
graph=graph(index,index);
% graph=graph.*mask;
graph=graph.*(graph>0);
graph=threshold_proportional(graph,thr);

% =============================================================================
% weighted
if str2num(b_or_w) == 2
	fprintf('++ Start analyzing (weighted) %s \n in %s \n',graph_file,subj_dir);
	if length(strfind(M_file,'thalamus_calcarine'))>0
		nw_list={'Tha';'V1'};
	elseif length(strfind(M_file,'40Hz_sensitive'))>0
		nw_list={'01Hz';'40Hz';'both';'Tha';'DMN';'VSp';'SM';'SN';'Cb'};		
	else
		nw_list={'DMN';'VS';'VSp';'SM';'SN';'Cb';'Tha'};
	end

	fprintf('++ Start analyzing connection strength in and between modules\n');
	str_in_module=zeros(size(M));
	str_betw_module=zeros(size(M));
	M_max=max(M);
	for module=1:M_max
		str_in_module=zeros(size(M));
		% calculate intramodule connectivity strength
		[row,~]=find(M==module);
		graph_in_module=graph(row,row);
		str_in_module(row)=sum(graph_in_module,2)/(length(row)-1);
		dlmwrite(replace(graph_file,'cor_z',['str_in_' char(nw_list(module)) ...
			'_thr' num2str(thr)]),str_in_module,'precision','%.4f');

		% global efficiency for each module except thalamus
		if module~=7 && length(strfind(M_file,'thalamus_calcarine'))+length(strfind(M_file,'40Hz_sensitive'))==0
			Geff=efficiency_wei(graph_in_module);
			dlmwrite(replace(graph_file,'cor_z',['Geff_in_' char(nw_list(module)) ...
				'_thr' num2str(thr)]),Geff,'precision','%.4f');
		end

		if length(strfind(M_file,'thalamus_calcarine'))+length(strfind(M_file,'40Hz_sensitive'))==0 
			str_betw_other=zeros(size(M));
			% calculate connectivity strength of one module with all other modules
			[row_other,~]=find(M~=module);
			graph_betw_other=graph(row,row_other);
			if module==7
				str_betw_other(row_other)=[mean(graph_betw_other,1)]';
			else
				str_betw_other(row)=mean(graph_betw_other,2);
			end
			dlmwrite(replace(graph_file,'cor_z',['str_betw_' char(nw_list(module)) ...
				'_allother_thr' num2str(thr)]),str_betw_other,'precision','%.4f');
		end

		% calculate connectivity strength of one module with other specific module
		if module<M_max
			for module_2nd=(module+1):M_max
				str_betw_module=zeros(size(M));
				[row_2nd,~]=find(M==module_2nd);
				graph_betw_module=graph(row,row_2nd);
				str_betw_module(row)=mean(graph_betw_module,2);
				str_betw_module(row_2nd)=[mean(graph_betw_module,1)]';
				file_name=replace(graph_file,'cor_z',['str_betw_' char(nw_list(module))...
					'_' char(nw_list(module_2nd)) '_thr']);
				dlmwrite(insertBefore(file_name,'.1D',num2str(thr)),str_betw_module,'precision','%.4f');
			end
		end
	end

	if length(strfind(M_file,'thalamus_calcarine'))+length(strfind(M_file,'40Hz_sensitive'))==0
		fprintf('++ Start analyzing Within-module degree z-score and Participation coefficient\n');
		WD=module_degree_zscore(graph,M);
		PC=participation_coef(graph,M);
		dlmwrite(replace(graph_file,'cor_z',['WD_thr' num2str(thr)]),WD,'precision','%.4f');
		dlmwrite(replace(graph_file,'cor_z',['PC_thr'  num2str(thr)]),PC,'precision','%.4f');
	end
end

% =============================================================================
% binary
if str2num(b_or_w) == 1
	graph=weight_conversion(graph,'binarize');
	fprintf('++ Start analyzing (binary) %s \n in %s \n',graph_file,subj_dir);
	nw_list={'DMN';'VS';'VSp';'SM';'SN';'Cb';'Tha'};

	fprintf('++ Start analyzing connection strength in and between modules\n');
	str_in_module=zeros(size(M));
	str_betw_module=zeros(size(M));
	M_max=max(M);
	for module=1:M_max
		str_in_module=zeros(size(M));
		% calculate intramodule connection number
		[row,~]=find(M==module);
		graph_in_module=graph(row,row);
		str_in_module(row)=sum(graph_in_module,2);
		dlmwrite(replace(graph_file,'cor_z',['str_in_' char(nw_list(module)) ...
			'_bin' num2str(thr)]),str_in_module,'precision','%.4f');

		str_betw_other=zeros(size(M));
		% calculate connectivity strength of one module with all other modules
		[row_other,~]=find(M~=module);
		graph_betw_other=graph(row,row_other);
		str_betw_other(row)=sum(graph_betw_other,2);
		dlmwrite(replace(graph_file,'cor_z',['str_betw_' char(nw_list(module)) ...
			'_allother_bin' num2str(thr)]),str_betw_other,'precision','%.4f');

		% calculate connectivity strength of one module with other specific module
		if module<M_max
			for module_2nd=(module+1):M_max
				str_betw_module=zeros(size(M));
				[row_2nd,~]=find(M==module_2nd);
				graph_betw_module=graph(row,row_2nd);
				str_betw_module(row)=sum(graph_betw_module,2);
				str_betw_module(row_2nd)=[sum(graph_betw_module,1)]';
				file_name=replace(graph_file,'cor_z',['str_betw_' char(nw_list(module))...
					'_' char(nw_list(module_2nd)) '_bin']);
				dlmwrite(insertBefore(file_name,'.1D',num2str(thr)),str_betw_module,'precision','%.4f');
			end
		end
	end


	fprintf('++ Start analyzing Within-module degree z-score and Participation coefficient\n');
	WD=module_degree_zscore(graph,M);
	PC=participation_coef(graph,M);
	dlmwrite(replace(graph_file,'cor_z',['WD_bin' num2str(thr)]),WD,'precision','%.4f');
	dlmwrite(replace(graph_file,'cor_z',['PC_bin'  num2str(thr)]),PC,'precision','%.4f');
end

cd(curr_dir);
end

