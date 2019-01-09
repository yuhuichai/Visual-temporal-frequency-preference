function freqmap_kmeans(subj_dir,file_to_fit,mask_file)

cd(subj_dir)

Opt.Format = 'vector';
[err, Vbeta, Infobeta, ErrMessage] = BrikLoad (file_to_fit,Opt);
[err, Vmask, Infomask, ErrMessage] = BrikLoad (mask_file,Opt);
index = find(Vmask>0);
Vbeta_fit = Vbeta(index,:);

% kmeans
K_num = 2:4;
Km_cr = zeros(length(index),length(K_num));
freq = [1 10 20 40]';
for i=1:length(K_num)
	fprintf('++ K = %d for masked ...\n',K_num(i))
	[Km_cr(:,i),C] = kmeans(Vbeta_fit,K_num(i),'MaxIter',500,'Distance','correlation','OnlinePhase','on');
	[~,idx] = sort(C*freq);
	Km = zeros(size(Km_cr(:,i)));
	for j=1:K_num(i)
		if (j==2 || j==3) && sum(findstr(subj_dir,'Sub009'))>0 && K_num(i)==3
			Km = Km+(Km_cr(:,i)==idx(j))*(5-j);
		elseif (K_num(i)==3 && sum(findstr(subj_dir,'group.event'))>0) && (j==2 || j==3)
			Km = Km+(Km_cr(:,i)==idx(j))*(5-j);
		elseif (K_num(i)==4 && sum(findstr(subj_dir,'group.event'))>0)
			if j==2
				Km = Km+(Km_cr(:,i)==idx(j))*3;
			elseif j==3
				Km = Km+(Km_cr(:,i)==idx(j))*4;
			elseif j==4
				Km = Km+(Km_cr(:,i)==idx(j))*2;
			elseif j==1
				Km = Km+(Km_cr(:,i)==idx(j))*1;
			end
		else
			Km = Km+(Km_cr(:,i)==idx(j))*j;
		end
	end
	Km_cr(:,i) = Km;
end

% write kmeans
%Copy the header info from the .DEL brick
InfoOut = Infobeta;
InfoOut.RootName = ''; %that'll get set by WriteBrik
InfoOut.DATASET_RANK(2) = length(K_num); %two sub-bricks
InfoOut.BRICK_TYPES = 3*ones(1,length(K_num)); %store data as shorts
InfoOut.BRICK_STATS = []; %automatically set
InfoOut.BRICK_FLOAT_FACS = [];%automatically set
InfoOut.BRICK_LABS = 'K2~K3~K4';
InfoOut.IDCODE_STRING = '';%automatically set

OptOut.Scale = 1;
OptOut.verbose = 0;
OptOut.OverWrite = 'y';
OptOut.Prefix = ['Kmeans_Cr.' char(extractBefore(file_to_fit,'+tlrc'))];
output = zeros(length(Vbeta),length(K_num));
output(index,:) = Km_cr;

% if exist('Kpattern','var') && isempty(Kpattern)==0
% 	[err, VKpattern, InfoKpatten ErrMessage] = BrikLoad (Kpattern,Opt);
% 	VKpattern=VKpattern(:,[1 3]);
% 	Km=zeros(size(output));
% 	for i=1:length(K_num)
% 		rawidx_idx=zeros(K_num(i),1);
% 		for idx=1:K_num(i)
% 			row_for_idx=(VKpattern(:,i)==idx);
% 			overlay_max=0;
% 			for rawidx=1:K_num(i)
% 				row_for_rawidx=(output(:,i)==rawidx);
% 				overlay=sum(row_for_idx.*row_for_rawidx);
% 				if overlay>overlay_max && sum(rawidx_idx==rawidx)==0
% 					overlay_max=overlay;
% 					rawidx_idx(idx)=rawidx;
% 				end
% 			end
% 			Km(:,i)=Km(:,i)+(output(:,i)==rawidx_idx(idx))*idx;
% 		end
% 	end
% 	output=Km;
% end

[err, ErrMessage, InfoOut] = WriteBrik(output, InfoOut, OptOut);

end