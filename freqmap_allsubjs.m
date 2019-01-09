function freqmap(subj_dir,file_to_fit,mask_file,model,logtype)

cd(subj_dir)

Opt.Format = 'vector';
[err, Vmask, Infomask, ErrMessage] = BrikLoad (mask_file,Opt);
index = find(Vmask>0);

stim_list={'01Hz' '05Hz' '10Hz' '20Hz' '40Hz'};
for stim=1:length(stim_list)
	if stim==1
		[err, Vbeta, Infobeta, ErrMessage] = BrikLoad (file_to_fit,Opt);
		Vbeta_fit = zeros(length(index),size(Vbeta,2),length(stim_list));
		Vbeta_fit(:,:,stim) = Vbeta(index,:);
	else
		[err, Vbeta, Infobeta, ErrMessage] = BrikLoad (replace(file_to_fit,'01Hz',stim_list(stim)),Opt);
	end
	Vbeta_fit(:,:,stim) = Vbeta(index,:);
end

for subj=1:size(Vbeta,2)
	mean(mean(Vbeta_fit(:,subj,:)))
	Vbeta_fit(:,subj,:) = Vbeta_fit(:,subj,:)/mean(mean(Vbeta_fit(:,subj,:)));
end

freq_max = zeros(size(index));
psig_max = zeros(size(index));

% Differential-Exponential model
% editfit(5,'diffexp','k*(exp(-alpha1*(x-t0))-exp(-alpha2*(x-t0)))');
freq = [1 5 10 20 40];
freqhres = [1:0.1:40];

if strcmp(logtype,'orig') == 1
	freq_log = freq;
	freqhres_log = freqhres;
elseif strcmp(logtype,'log10') == 1
	freq_log = log10(freq);
	freqhres_log = log10(freqhres);
elseif strcmp(logtype,'ln') == 1
	freq_log = log(freq);
	freqhres_log = log(freqhres);
end		

fprintf('++ freq_log = ...')
freq_log

% freq_log = reshape([repmat(freq_log',1,size(Vbeta,2))]',1,size(Vbeta,2)*length(stim_list));
% for ijk = 1:length(index)
	ijk = 3157;
	if rem(ijk,1000) == 0
		fprintf('++++++++++++++ start fitting the %d voxel +++++++++++++++\n', ijk);
	end
	psig = reshape(squeeze(Vbeta_fit(ijk,8,:)),size(freq_log));
	if strcmp(model,'diffexp') == 1
		F = ezfit(freq_log,psig,'diffexp');
	elseif strcmp(model,'gauss') == 1
		F = ezfit(freq_log,psig,'gauss');
	end

	if F.r > 0.3
		if strcmp(model,'diffexp') == 1
			psighres = F.m(3)*(exp(-F.m(1)*(freqhres_log-F.m(4)))-exp(-F.m(2)*(freqhres_log-F.m(4))));
		elseif strcmp(model,'gauss') == 1
			psighres = F.m(1)*exp(-((freqhres_log-F.m(3)).^2)/(2*F.m(2)^2));
		end	
		psig_max(ijk) = max(psighres);
		if length(find(psighres==psig_max(ijk))) == 1
			freq_max(ijk) = freqhres(find(psighres==psig_max(ijk)));
		end
	else
		psig_max(ijk) = 0;
		freq_max(ijk) = 0;
	end

	figure;
	showfit(F, 'fitcolor', 'red', 'fitlinewidth', 2); 
	hold on; plot(freq_log,psig,'*');
	% ylim([min(psig)-0.1 max(psig)+0.15])
% end

%We need to setup the header info for the new data set to write out
%Copy the header info from the .DEL brick
InfoOut = Infobeta;
%modify the necessary fields
%YOU MUST READ THE HELP for the function WriteBrik and BrikInfo
InfoOut.RootName = ''; %that'll get set by WriteBrik
InfoOut.DATASET_RANK(2) = 2; %two sub-bricks
InfoOut.BRICK_TYPES = [1 1]; %store data as shorts
InfoOut.BRICK_STATS = []; %automatically set
InfoOut.BRICK_FLOAT_FACS = [];%automatically set
InfoOut.BRICK_LABS = 'freq at max beta~max beta';
InfoOut.IDCODE_STRING = '';%automatically set
% InfoOut.BRICK_STATAUX = [1 2 3 160 2 2];

OptOut.Scale = 1;
OptOut.Prefix = ['freqmap_' model '_' logtype '.' char(extractBefore(file_to_fit,'+tlrc'))];
OptOut.verbose = 0;

output = zeros(length(Vbeta),2);
output(index,:) = [freq_max psig_max];
[err, ErrMessage, InfoOut] = WriteBrik(output, InfoOut, OptOut);

end