function [Stage_Time_Interval, Theta_Stage_Bound] = Tangagh(stage,Time)

Theta_Stage_Bound (1,1) = 90;

for i = 1:stage

% ������� ���� ������� � ����� ������ ������ �������    
    if i ~= 1
 Theta_Stage_Bound(i,1) = Theta_Stage_Bound (i-1,2);
    end
    
 Theta = inputdlg( { ...
    [' �������� ���� ������� � ����� ������ ' num2str(i) '-� �������']},...
    [' ���� ������� ']);

Theta_Stage_Bound(i,2) = str2num (Theta{1});

%����������� ��������� �������� ��� ������ ��������� ���� �������
Stage_Time_Interval(i,:) = [Time(i) 5 5 5 5];

end
    
%������� �������� � �������
Theta_Stage_Bound = Theta_Stage_Bound/180*pi;