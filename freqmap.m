function freqmap(subj_dir,file_to_fit,mask_file,freq_type,model,peak_ok_max)
% subj_dir, working directory

% file_to_fit, input "beta.freqmap+tlrc", details as following	
	% # combine frequency-dependent beta value
	% 3dbucket -prefix beta.freqmap \
	% 	stats.event.transient+tlrc.HEAD[vs01Hz#0_Coef] \
	% 	stats.event.transient+tlrc.HEAD[vs05Hz#0_Coef] \
	% 	stats.event.transient+tlrc.HEAD[vs10Hz#0_Coef] \
	% 	stats.event.transient+tlrc.HEAD[vs20Hz#0_Coef] \
	% 	stats.event.transient+tlrc.HEAD[vs40Hz#0_Coef] \
	% 	-overwrite

% mask_file, restrict fitting in visual active area
% freq_type, event or conn
% model, difference of exponential or gaussian
% peak_ok_max, ok or not if peak frequency locate at highest frequency that have been stimulate
	% happerns if the range of the stimulation frequencies is not broad enough (or not high enough)

logtype = 'orig';
pass0 = 'yes';
cd(subj_dir)

Opt.Format = 'vector';
[err, Vbeta, Infobeta, ErrMessage] = BrikLoad (file_to_fit,Opt);
[err, Vmask, Infomask, ErrMessage] = BrikLoad (mask_file,Opt);
index = find(Vmask>0);
Vbeta_fit = Vbeta(index,:);
freq_max = zeros(size(index));
freq_low = zeros(size(index));
freq_hig = zeros(size(index));
psig_max = zeros(size(index));

% % kmeans
% K_num = 2:5;
% Km_cr = zeros(length(index),length(K_num));
% for i=1:length(K_num)
% 	fprintf('++ K = %d for masked ...\n',K_num(i))
% 	Km_cr(:,i) = kmeans(Vbeta_fit,K_num(i),'MaxIter',500,'Distance','correlation','OnlinePhase','on');
% end

% Differential-Exponential model
editfit(5,'diffexp','k*(exp(-alpha1*(x-t0))-exp(-alpha2*(x-t0)))');
if strcmp(freq_type,'conn') == 1
	freq = [1 10 20 40];
elseif strcmp(freq_type,'event') == 1
	freq = [1 5 10 20 40];
elseif strcmp(freq_type,'event_dis40Hz') == 1
	freq = [1 5 10 20 30];
elseif strcmp(freq_type,'event60Hz') == 1
	freq = [1 5 10 15 20 40 60];	
end

if strcmp(pass0,'yes') == 1
	freq = [0 freq];
end

freqhres = [0:0.05:60];
out_len = length([0:0.05:40]);
psighres_out = zeros(length(index),out_len);

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

for ijk = 1:length(index)
	if rem(ijk,1000) == 0
		fprintf('++++++++++++++ start fitting the %d voxel +++++++++++++++\n', ijk);
	end
	psig = squeeze(Vbeta_fit(ijk,:));
	if strcmp(pass0,'yes') == 1
		psig = [0 psig];
	end
	if strcmp(model,'diffexp') == 1
		F = ezfit(freq_log,psig,'diffexp');
	elseif strcmp(model,'gauss') == 1
		F = ezfit(freq_log,psig,'gauss');
	end

	% fprintf('++ %d, %f\n', ijk, F.r);
	if F.r > 0.3
		if strcmp(model,'diffexp') == 1
			psighres = F.m(3)*(exp(-F.m(1)*(freqhres_log-F.m(4)))-exp(-F.m(2)*(freqhres_log-F.m(4))));
		elseif strcmp(model,'gauss') == 1
			psighres = F.m(1)*exp(-((freqhres_log-F.m(3)).^2)/(2*F.m(2)^2));
		end	
		psig_max(ijk) = max(psighres);
		index_max = find(psighres==psig_max(ijk));
		cdn = (length(index_max) == 1) && ((index_max < length(psighres) && index_max > 1) || strcmp(peak_ok_max,'ok'));
		if cdn
			freq_max(ijk) = freqhres(index_max);

			psig_1h = psighres(1:index_max);
			freq_1h = freqhres(1:index_max);
			psig_2h = psighres(index_max:end);
			freq_2h = freqhres(index_max:end);

			freq_low(ijk) = freq_1h(knnsearch(psig_1h',psig_max(ijk)/2));
			freq_hig(ijk) = freq_2h(knnsearch(psig_2h',psig_max(ijk)/2));

			psighres_out(ijk,:) = psighres(1:out_len);
		end
	end

	% figure;
	% showfit(F, 'fitcolor', 'red', 'fitlinewidth', 2); 
	% hold on; plot(freq_log,psig,'*');
	% ylim([min(psig)-0.1 max(psig)+0.15])
end

% write frequency map
%We need to setup the header info for the new data set to write out
%Copy the header info from the .DEL brick
InfoOut = Infobeta;
%modify the necessary fields
%YOU MUST READ THE HELP for the function WriteBrik and BrikInfo
InfoOut.RootName = ''; %that'll get set by WriteBrik
InfoOut.DATASET_RANK(2) = 5; %two sub-bricks
InfoOut.BRICK_TYPES = [3 3 3 3 3]; %store data as shorts
InfoOut.BRICK_STATS = []; %automatically set
InfoOut.BRICK_FLOAT_FACS = [];%automatically set
InfoOut.BRICK_LABS = 'freq at max beta~freq passband~left cutoff freq~right cutoff freq~max beta';
InfoOut.IDCODE_STRING = '';%automatically set
% InfoOut.BRICK_STATAUX = [1 2 3 160 2 2];

OptOut.Scale = 1;
OptOut.verbose = 0;
OptOut.OverWrite = 'y';
if strcmp(pass0,'yes') == 1
	OptOut.Prefix = ['freqmap_' model '_' logtype '_pass0.' char(extractBefore(file_to_fit,'+tlrc'))];
else
	OptOut.Prefix = ['freqmap_' model '_' logtype '.' char(extractBefore(file_to_fit,'+tlrc'))];
end
if strcmp(peak_ok_max,'ok') == 1
	OptOut.Prefix = insertAfter(OptOut.Prefix, model, '_peakOKmax');
end


output = zeros(length(Vbeta),5);
output(index,:) = [freq_max freq_hig-freq_low freq_low freq_hig psig_max];
[err, ErrMessage, InfoOut] = WriteBrik(output, InfoOut, OptOut);


% write fit curve
InfoOut.DATASET_RANK(2) = out_len; %two sub-bricks
InfoOut.BRICK_TYPES = 3*ones(1,out_len); %store data as shorts
InfoOut.BRICK_STATS = []; %automatically set
InfoOut.BRICK_FLOAT_FACS = [];%automatically set
InfoOut.BRICK_LABS = '';
if strcmp(pass0,'yes') == 1
	OptOut.Prefix = ['freqmap_fitc_' model '_' logtype '_pass0.' char(extractBefore(file_to_fit,'+tlrc'))];
else
	OptOut.Prefix = ['freqmap_fitc_' model '_' logtype '.' char(extractBefore(file_to_fit,'+tlrc'))];
end
if strcmp(peak_ok_max,'ok') == 1
	OptOut.Prefix = insertAfter(OptOut.Prefix, model, '_peakOKmax');
end
output = zeros(length(Vbeta),out_len);
output(index,:) = psighres_out;
[err, ErrMessage, InfoOut] = WriteBrik(output, InfoOut, OptOut);

% % write kmeans
% InfoOut.DATASET_RANK(2) = length(K_num); %two sub-bricks
% InfoOut.BRICK_TYPES = 3*ones(1,length(K_num)); %store data as shorts
% InfoOut.BRICK_STATS = []; %automatically set
% InfoOut.BRICK_FLOAT_FACS = [];%automatically set
% InfoOut.BRICK_LABS = 'K2~K3~K4~K5';
% OptOut.Prefix = ['Kmeans_Cr.' char(extractBefore(file_to_fit,'+tlrc'))];
% output = zeros(length(Vbeta),length(K_num));
% output(index,:) = Km_cr;
% [err, ErrMessage, InfoOut] = WriteBrik(output, InfoOut, OptOut);

end