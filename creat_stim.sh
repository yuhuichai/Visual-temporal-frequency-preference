#!/bin/bash
# compute vigilance detection rate
# generate stimuli file for afni_proc.py
export PATH="$PATH:/Users/chaiy3/abin"

if [ ! -d Stim ]; then
	mkdir Stim
else
	rm -rf Stim
	mkdir Stim
fi

cp -r exp_logs/Sub* Stim/
cd Stim
for file in *longBloc*; do
	if [[ "$file" =~ "fix" ]]; then
		stim=fix
	fi
	if [[ "$file" =~ "checker" ]]; then
		stim=checker
	fi
	if [[ "$file" =~ "1Hz" ]]; then
		stim=01Hz
	fi
	if [[ "$file" =~ "5Hz" ]]; then
		stim=05Hz
	fi
	if [[ "$file" =~ "10Hz" ]]; then
		stim=10Hz
	fi
	if [[ "$file" =~ "20Hz" ]]; then
		stim=20Hz
	fi
	if [[ "$file" =~ "40Hz" ]]; then
		stim=40Hz
	fi
	cat $file | grep -e 'target' | awk '{print $1}' > conn_${stim}_target.txt
	cat $file | grep -e 'Keypress: a' -e 'Keypress: b' -e 'Keypress: c' -e 'Keypress: d' \
		| awk '{print $1}' > conn_${stim}_target_r.txt
	rm -f $file
done

for file in *shortBloc*; do
	if [ $file != "*shortBloc*" ]; then
		if [[ "$file" =~ "run1" ]] || [[ "$file" =~ "iso1" ]]; then
			run=run1
		fi
		if [[ "$file" =~ "run2" ]] || [[ "$file" =~ "iso2" ]]; then
			run=run2
		fi
		if [[ "$file" =~ "run3" ]]; then
			run=run3
		fi
		cat $file | grep -e 'flickering rate = \[60  0 60\]' \
			| awk '{print $1}' > event_01Hz_$run.txt
		cat $file | grep -e 'flickering rate = \[12  0 12\]' \
			| awk '{print $1}' > event_05Hz_$run.txt
		cat $file | grep -e 'flickering rate = \[6 0 6\]' \
			| awk '{print $1}' > event_10Hz_$run.txt
		cat $file | grep -e 'flickering rate = \[3 0 3\]' \
			| awk '{print $1}' > event_20Hz_$run.txt
		cat $file | grep -e 'flickering rate = \[1 1 1\]' \
			| awk '{print $1}' > event_40Hz_$run.txt

		subj=${file%_run*}
		subj=${subj#Sub}
		subj=${subj%_iso*}
		if [ "$subj" -le "13" ]; then	
			cat $file | grep -e 'flickering rate = \[4 0 4\]' \
				| awk '{print $1}' > event_15Hz_$run.txt
			cat $file | grep -e 'flickering rate = \[1 0 1\]' \
				| awk '{print $1}' > event_60Hz_$run.txt
		fi
		# target
		cat $file | grep -e 'target' | awk '{print $1}' > event_${run}_target.txt
		cat $file | grep -e 'Keypress: a' -e 'Keypress: b' -e 'Keypress: c' -e 'Keypress: d' \
			| awk '{print $1}' > event_${run}_target_r.txt
		rm -f $file
	fi
done

for stim in event_*Hz_run1.txt; do
	if [ $stim != "event_*Hz_run1.txt" ]; then
		stim=${stim:6:4}
		echo `1deval -a event_${stim}_run1* -expr 'a-1.7*8'` > event_${stim}_run1_dis8TR.txt
		echo `1deval -a event_${stim}_run2* -expr 'a-1.7*8'` > event_${stim}_run2_dis8TR.txt
		if [ -f event_${stim}_run3.txt ]; then
			echo `1deval -a event_${stim}_run3* -expr 'a-1.7*8'` > event_${stim}_run3_dis8TR.txt
			echo `cat event_${stim}_run1_dis8TR*`$'\n'`cat event_${stim}_run2_dis8TR*`$'\n'`\
				cat event_${stim}_run3_dis8TR*` > event_${stim}_dis8TR.txt
		else
			echo `cat event_${stim}_run1_dis8TR*`$'\n'`cat event_${stim}_run2_dis8TR*` \
				> event_${stim}_dis8TR.txt
		fi
		rm -f event_${stim}_run*
	fi
done
