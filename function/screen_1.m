function screen = screen_1(stage,M_K,M_T,Time,P,M_PN,D_rocket,V)
%Вывод информации о выбраной ракете 
Text{1} =         ['          Параметры ступеней'];

for i = 1:stage
    
    Text{i*6-3} = ['               ' num2str(i) '-я ступень'];
    Text{i*6-2} = [' Сухая масса ступени - ' num2str(M_K(i)) ' кг'];
    Text{i*6-1} = [' Масса топлива - ' num2str(M_T(i)) ' кг'];
    Text{i*6}   = [' Время работы ступени - ' num2str(Time(i)) ' c'];
    Text{i*6+1} = [' Сумарная тяга ступени - ' num2str(P(i)) ' Н'];
    
end

    Text{i*6+3} = [' Масса полезной нагрузки - ' num2str(M_PN) ' кг'];
    Text{i*6+4} = [' Диаметр раекты - ' num2str(D_rocket) ' м'];
    Text{i*6+5} = ['Максимальная скорость по формуле '];
    Text{i*6+6} = ['Циолковского = ' num2str(V/1000) ' км/с' ];
   
screen = msgbox(Text, 'Характерристики ракеты' ,'warn');