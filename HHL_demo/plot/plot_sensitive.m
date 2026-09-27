warning off
clear all;

% load sensi
% load sensi_honda
load YTC_TMP
result=[];
for j=1:7
    for i=1:7
        result(i,j) = total_res(i+7*(j-1),1);
    end
end



bar3(result);

% xlabel('\beta');ylabel('\alpha');zlabel('Accuracy');

set(gca,'Xticklabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','10^{1}','10^{2}'});
set(gca,'Yticklabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','10^{1}','10^{2}'});
set(gca,'FontSize',20),'bold';
xlabel('\alpha','FontSize',30),'bold';
ylabel('\beta','FontSize',30),'bold';  
zlabel('Accuracy','FontSize',30),'bold';  

set(gcf, 'position', [0 0 800 600]);
% title('The results of three students');