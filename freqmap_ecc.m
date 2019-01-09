function freqmap_ecc(subj_dir)

cd(subj_dir)

Opt.Format = 'vector';
[err, Vmask, Infomask, ErrMessage] = BrikLoad ('template_areas+tlrc',Opt);
[err, Vecc, Infoecc, ErrMessage] = BrikLoad ('template_eccen+tlrc',Opt);
[err, Vfreq, Infofreq, ErrMessage] = BrikLoad ('freqmap+tlrc',Opt);
[err, Vfreq_corr, Infofreq, ErrMessage] = BrikLoad ('freqmap_corr+tlrc',Opt);

% [err, Kevent, Infofreq, ErrMessage] = BrikLoad ('Kmeans_Cr.mean_beta.freqmap+tlrc',Opt);
% [err, Kcorr, Infofreq, ErrMessage] = BrikLoad ('Kmeans_Cr.mean_beta.stats.LME.fcs_gm_Thalamus_inters_01Hz_40Hz_frac1_pos_z+tlrc',Opt);
% Kevent = Kevent(:,1);
% Kcorr = Kcorr(:,1);
% Kmask = (Kevent>0).*(Kcorr>0);
% Kindex = find(Kmask>0);
% Kevent_fit = Kevent(Kindex,1);
% Kcorr_fit = Kcorr(Kindex,1);
% Nsame = sum(Kevent_fit==Kcorr_fit);
% Ndiff = sum(Kevent_fit~=Kcorr_fit);


Vfreq = Vfreq(:,1);
Vfreq_corr = Vfreq_corr(:,1);
% mask = (Vecc>0).*(Vfreq>0).*(Vfreq<40).*(Vfreq_corr>0).*(Vfreq_corr<40).*(Vmask>0);
mask = (Vecc>0).*(Vfreq>0).*(Vfreq<40).*(Vmask>0);

% mask = (Vecc>0).*(Vfreq>0).*(Vfreq<40).*(Vmask>0);
index = find(mask>0);

Vecc_fit = Vecc(index,:);
Vfreq_fit = Vfreq(index,:);

% Vecc_fit = Vfreq(index,:);
% Vfreq_fit = Vfreq_corr(index,:);


figure;
xedges = [min(Vecc_fit):1.5:max(Vecc_fit)];
yedges = [min(Vfreq_fit):0.75:max(Vfreq_fit)];
h = histogram2(Vecc_fit,Vfreq_fit,xedges,yedges,'DisplayStyle','tile','ShowEmptyBins','on');
colormap('jet');
% colorbar;
set(gca,'CLim',[20 320]);
xlabel('Eccentricity (deg)','Fontsize',25,'FontWeight','bold');
ylabel('Peak frequency (Hz)','Fontsize',25,'FontWeight','bold');
box off
xlim([0 30]);
ylim([0 28]);
% whitebg('white');
set(gcf,'color',[0 0 0])
set(gca,'linewidth',0.0000001,'fontsize',25,'FontWeight','bold','Xcolor',[1 1 1],'Ycolor',[1 1 1])
export_fig(['freqevent_ecc.png'],'-r300');

% [p,S] = polyfit(Vecc_fit,Vfreq_fit,1);
% x_min = min(Vecc_fit);
% x_max = max(Vecc_fit);
% x = linspace(x_min,x_max);
% y = polyval(p,x);
% R = corrcoef(Vecc_fit,Vfreq_fit);
% R2=R(2).^2;

% figure;
% plot(Vecc_fit,Vfreq_fit,'r.','MarkerSize',15);
% hold on;plot(x,y,'g','LineWidth',3);
% xlabel('Eccentricity (deg)','Fontsize',25,'FontWeight','bold');
% ylabel('Peak frequency (Hz)','Fontsize',25,'FontWeight','bold');
% % title(['R2 = ' num2str(R2,'%10.2f') ', S = ' num2str(p(1),'%10.2f')],'fontsize',25,'FontWeight','bold')
% ylim([min(Vfreq_fit)-1 max(Vfreq_fit)+1])
% xlim([x_min-0.1 x_max+0.1])
% box off
% whitebg('white');
% set(gcf,'color',[1 1 1])
% set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
% export_fig(['fit_corr_ecc_R2_' num2str(R2,'%10.2f') '_S_' num2str(p(1),'%10.2f') '.png'],'-r300');

end