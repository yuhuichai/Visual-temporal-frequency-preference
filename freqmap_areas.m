function freqmap_areas(subj_dir)

cd(subj_dir)

Opt.Format = 'vector';
[err, Vareas, Infoareas, ErrMessage] = BrikLoad ('native.template_areas.resamp_inflat_GMI_tha+tlrc',Opt);
% [err, Vareas, Infomask, ErrMessage] = BrikLoad ('template_areas+tlrc',Opt);
% [err, Vecc, Infoecc, ErrMessage] = BrikLoad ('template_eccen+tlrc',Opt);
areas_list={'V1' 'V2' 'V3' 'Tha'};
% [err, Vareas, Infoareas, ErrMessage] = BrikLoad ('native.wang2015_atlas.resamp_inflat_GMI+tlrc',Opt);
% areas_list={'V1v' 'V1d' 'V2v' 'V2d' 'V3v' 'V3d' 'hV4' 'VO1' 'VO2' 'PHC1' 'PHC2' 'MST' ...
% 	'hMT' 'LO2' 'LO1' 'V3b' 'V3a' 'IPS0' 'IPS1' 'IPS2' 'IPS3' 'IPS4' 'IPS5' 'SPL1' 'FEF'};
[err, Vfreq, Infofreq, ErrMessage] = BrikLoad ('freqmap_diffexp_orig_pass0.mean_beta.freqmap+tlrc',Opt);
[err, Vfreq_corr, Infofreq, ErrMessage] = BrikLoad ('freqmap_gauss_orig_pass0.mean_beta.stats.LME.fcs_gm_Tha_fcs_gm_visual_pos_z+tlrc',Opt);
% [err, Vfreq, Infofreq, ErrMessage] = BrikLoad ('freqmap+tlrc',Opt);
% [err, Vfreq_corr, Infofreq, ErrMessage] = BrikLoad ('freqmap_corr+tlrc',Opt);


Vfreq = Vfreq(:,1);
mask = (3>=Vareas>0).*(Vfreq>0).*(Vfreq<40)+(Vareas>3).*(Vfreq>0).*(Vfreq<40);
mask_corr = (3>=Vareas>0).*(Vfreq_corr(:,1)>0).*(Vfreq_corr(:,1)<40);

% areas_list=areas0_list;
% nz_index=0;
% for roi=1:length(areas_list)
% 	vxl_num=nnz(Vfreq.*mask.*(Vareas==roi));
% 	if vxl_num>50
% 		fprintf('++ %d voxels in %s\n', vxl_num,char(areas0_list(roi)));
% 		nz_index=nz_index+1;
% 		areas_list(nz_index)=areas0_list(roi);
% 	else
% 		mask(find(Vareas==roi))=0;
% 	end
% end

index = find(mask>0);
% areas_list=areas_list(1:nz_index);
Vareas_fit = Vareas(index,:);
Vfreq_fit = Vfreq(index,:);

load('roi256rgb.mat');
color_list = flipud(roi256rgb);
for roi0=1:5:length(areas_list)
	figure;
	for roi=roi0:roi0+3
		[h x] = hist(Vfreq_fit(find(Vareas_fit==roi)),[1:33]);
		hold on; plot(x,h,'color',color_list(roi,:),'LineWidth',3);
	end
	ylabel('# of Voxels','Fontsize',25,'FontWeight','bold');
	xlabel('Peak Frequency (Hz)','Fontsize',25,'FontWeight','bold');
	% box off
	xlim([1 33]);
	ylim([0 270]);
	whitebg('black');
	set(gcf,'color',[0 0 0])
	set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
	export_fig(['freqs_v123Tha_roi0' num2str(roi0) '.png'],'-r300');
	% close all
end
end