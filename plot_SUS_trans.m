clear;

onset = load('onset.1D');
offset = load('offset.1D');
bloc = load('bloc.1D');
stim = zeros(size(bloc));
stim(11:20) = 1;

t = 1:100;
% plot(t,stim,'Color','w','LineWidth',10);
hold on,plot(t,bloc,'Color','r','LineWidth',6);
hold on,plot(t,onset,'Color','b','LineWidth',6);
hold on,plot(t,offset,'Color','y','LineWidth',6);
h = legend('Sustained','Onset','Offset');
set(h,'box','off','location','northeast','Fontsize',30,'FontWeight','bold')
xlim([8 45]);
% ylim([-.7 1.2])
% xlabel('Time (s)','Fontsize',25,'FontWeight','bold');
% ylabel('Signal change (a.u.)','Fontsize',25,'FontWeight','bold');
box off
axis off
whitebg('black');
set(gcf,'color',[0 0 0])
% set(gca,'linewidth',3.5,'fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
export_fig('HRF.png','-r300');
close all

