% clear all
% load obj_cal101
% load obj_ETH
% load obj_LFW
load obj_YTC_TMP
% save('obj_cal101.mat','obj_cal101');
% save('obj_ETH.mat','obj_ETH');
% save('obj_YTC.mat','obj_YTC');
% save('obj_LFW.mat','obj_LFW');


y = [1:1:30]';
% CAL = obj_cal101';
% ETH = obj_ETH';
% LFW = obj_LFW';
YTC = obj_YTC';

lineStyles = linspecer(5);

% yyaxis left
ylim([0 2]);
% xlim([1 30]);

p = plot(y,YTC,'-o','LineWidth',2.5);
% p = plot(y,CAL,'-o',y,ETH,'-o',y,LFW,'-o',y,YTC,'-o','LineWidth',2.5);
p(1).Color = lineStyles(1,:);
% p(2).Color = lineStyles(2,:);
% p(3).Color = lineStyles(3,:);



ax=gca;
ax.FontSize = 17;

% yyaxis right
% pr = plot(y,YTC,'-*','LineWidth',2.5);
% pr(1).Color = lineStyles(4,:);
% ax.YLim = [0 200];

% set(gcf, 'position', [0 0 620 440]);
% legend('Caltech101','ETH','LFW','YTC');

% yyaxis left
% xlabel('Iteration Numeber','FontSize',22)
xlabel('迭代次数','FontSize',22)
% yyaxis right
ylabel('目标值','FontSize',22)
ax.XLim = [0:5:30];
