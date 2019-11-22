function [Stage_Time_Interval, Theta_Stage_Bound] = Tangagh(stage,Time)

Theta_Stage_Bound (1,1) = 90;

for i = 1:stage

% «адание угла тангажа в конце работы каждой ступени    
    if i ~= 1
 Theta_Stage_Bound(i,1) = Theta_Stage_Bound (i-1,2);
    end
    
 Theta = inputdlg( { ...
    [' ¬ыберете угол тангажа в конце работы ' num2str(i) '-й ступени']},...
    [' ”гол тангажа ']);

Theta_Stage_Bound(i,2) = str2num (Theta{1});

%ќпределение временных участков дл€ закона изменени€ угла тангажа
Stage_Time_Interval(i,:) = [Time(i) 5 5 5 5];

end
    
%ѕеревод градусов в радианы
Theta_Stage_Bound = Theta_Stage_Bound/180*pi;