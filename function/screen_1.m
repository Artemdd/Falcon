function screen = screen_1(stage,M_K,M_T,Time,P,M_PN,D_rocket,V)
%����� ���������� � �������� ������ 
Text{1} =         ['          ��������� ��������'];

for i = 1:stage
    
    Text{i*6-3} = ['               ' num2str(i) '-� �������'];
    Text{i*6-2} = [' ����� ����� ������� - ' num2str(M_K(i)) ' ��'];
    Text{i*6-1} = [' ����� ������� - ' num2str(M_T(i)) ' ��'];
    Text{i*6}   = [' ����� ������ ������� - ' num2str(Time(i)) ' c'];
    Text{i*6+1} = [' �������� ���� ������� - ' num2str(P(i)) ' �'];
    
end

    Text{i*6+3} = [' ����� �������� �������� - ' num2str(M_PN) ' ��'];
    Text{i*6+4} = [' ������� ������ - ' num2str(D_rocket) ' �'];
    Text{i*6+5} = ['������������ �������� �� ������� '];
    Text{i*6+6} = ['������������ = ' num2str(V/1000) ' ��/�' ];
   
screen = msgbox(Text, '��������������� ������' ,'warn');