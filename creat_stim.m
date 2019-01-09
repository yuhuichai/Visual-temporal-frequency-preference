% compute vigilance detection rate
% generate stimuli file for afni_proc.py

batchDir = '/Volumes/data/visualFreq/batch/';
dataDir = '/Volumes/data/visualFreq/';

cd(dataDir);
sublist = [dir('*Sub*')];
det_rate = zeros(length(sublist),6);

for i = 1:length(sublist)
	fprintf('Begin analyzing %s \n',sublist(i).name); 
	cd([dataDir sublist(i).name]);
	system(['bash ' batchDir 'creat_stim.sh']);
	cd('Stim')
	stimlist = dir('*target*');
	runnum = length(dir('event_run*_target.txt'));
	for j = 1:2:length(stimlist)
		tg_t = load(stimlist(j).name);
		rp_t = load(stimlist(j+1).name);
		tg_num = length(tg_t);
		for k = 1:tg_num
			del_t = rp_t-tg_t(k);
			del_t = sum(find(del_t<2.5 & del_t>0));
			if del_t == 0
				tg_t(k) = 0;
			end
		end 
		tg_mis = length(tg_t(tg_t == 0));
		tg_t = tg_t(tg_t ~= 0)';

		fprintf('Detection Rate of %s = %f, mis %d in %d tasks \n',stimlist(j).name,length(tg_t)/tg_num,tg_mis,tg_num);
		
		if length(tg_t) > 0
			if sum(findstr(stimlist(j).name,'event'))>0
				tg_t_dis8TR = tg_t-8*1.7;
				tg_t_dis8TR = tg_t_dis8TR(tg_t_dis8TR>0);
				dlmwrite([erase(stimlist(j).name,'target.txt') 'dis8TR.txt'],tg_t_dis8TR,'delimiter','\t');
				dlmwrite([erase(stimlist(j).name,'target.txt') 'all' num2str(tg_num) '_mis' num2str(tg_mis) ...
					'.txt'],length(tg_t)/tg_num,'delimiter','\t');

				if length(tg_t)/tg_num>=0.8
					det_rate(i,1) = length(tg_t)/tg_num;
				end

			else
				tg_t_dis15TR = tg_t-15*1.7;
				tg_t_dis15TR = tg_t_dis15TR(tg_t_dis15TR>0);
				dlmwrite([erase(stimlist(j).name,'target.txt') 'dis15TR.txt'],tg_t_dis15TR,'delimiter','\t');
				dlmwrite([erase(stimlist(j).name,'target.txt') 'all' num2str(tg_num) '_mis' num2str(tg_mis) ...
					'.txt'],length(tg_t)/tg_num,'delimiter','\t'); 

				if length(tg_t)/tg_num>=0.8
					if sum(findstr(stimlist(j).name,'fix'))>0
						det_rate(i,2) = length(tg_t)/tg_num;
					elseif sum(findstr(stimlist(j).name,'01Hz'))>0
						det_rate(i,3) = length(tg_t)/tg_num;
					elseif sum(findstr(stimlist(j).name,'10Hz'))>0
						det_rate(i,4) = length(tg_t)/tg_num;
					elseif sum(findstr(stimlist(j).name,'20Hz'))>0
						det_rate(i,5) = length(tg_t)/tg_num;
					elseif sum(findstr(stimlist(j).name,'40Hz'))>0
						det_rate(i,6) = length(tg_t)/tg_num;
					end
				end

			end
		end
		delete(stimlist(j).name);
		delete(stimlist(j+1).name);
	end
	if runnum == 2
		system('echo -e "`cat *run1_dis8*`\n`cat *run2_dis8*`" > event_vigilance_dis8TR.txt');
	elseif runnum == 3		
		system('echo -e "`cat *run1_dis8*`\n`cat *run2_dis8*`\n`cat *run3_dis8*`" > event_vigilance_dis8TR.txt');
	end
	delete('*run*_dis8*');
end
cd(dataDir);
save('det_rate.mat','det_rate');
dlmwrite('det_rate.1D',det_rate,'delimiter','\t');


cd(batchDir)