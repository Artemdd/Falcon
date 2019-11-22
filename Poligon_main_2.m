%Виртуальный полигон баллистических ракет
%Выбираешь ракету, соответствующий закон изменения угола тангажа, 
clear

%Папка для функций
cd function

%Константы
R_E=6.37111e6; %--радиус Земли, м
M_E=5.972e24;  %масса земли
Grav_post = 6.674e-11;
global R_E M_E Grav_post S_rocket t t_0 windage_function St_fall P GT dt

%принцип работы программы
St_fall = 0; %включение свободного падения отделившихся частей
windage_function = 0;  %cопротивление воздуха
animation_2D = 0;  %Анимированный 2D график траектории
animation_3D = 1;  %Анимированный 3D график траектории


%Выбор ракеты 
Rocket_Choise=menu('Выберете используемую ракету:', ...
    'Р-36М Сатана', ...
    'Союз-2', ...
    'Фалькон-9', ...
    'Вега', ...
    'Ариан-5', ...
    'Задать характерристики ракеты самому');

[stage,M_K,M_T,Time,P,M_PN] = Rocket_base (Rocket_Choise);

%% Начальные условия для каждой ступени
%время
t = 0;
for i = 1:stage
t_Fin(i) = sum(Time(1:i));
end
t_0(1) = 0; 
t_0(2:stage) = t_Fin(1:end-1);
%
%Основные параметры для моделирования траектории
GT = M_T./Time;
%Масса конструкции
for i = 1:stage
M_Sum(i) = sum(M_K(i:end)) + sum(M_T(i:end)) + M_PN;
end
param_0 = [0.0001 pi/2 0 0 M_Sum(1)];
param_old = param_0;

% Максимальная скорость по формуле Циолковского(без учета внешних сил)
I = P./GT;
M1M2= M_Sum./(M_Sum-M_T);
V = I.*log(M1M2);
V = sum(V);
V_g = V - sum(Time)*9.81;

%Диаметр и площадь поперечного сечения ракеты
D_rocket = 3.7;
S_rocket = pi*(D_rocket/2)^2;
% Вывод информации о ракете
[screen] = screen_1(stage,M_K,M_T,Time,P,M_PN,D_rocket,V);

%% Ввод углов тангажа на различных этапах работы ракеты
[Stage_Time_Interval, Theta_Stage_Bound] = Tangagh(stage,Time);

%Коэффинциенты закона изменения угла тангажа (Для каждой ступени разные)
for i = 1:stage
[PP_1(i,:), PP_2(i,:)] = Tangagh_corner_coeficient ( ...
    Stage_Time_Interval(i,:), Theta_Stage_Bound(i,:));
end

%Закрытие окна информации о ракете
uiwait(screen);
clear screen


%%
%Значения для массивов
Theta_0 = pi/2;   
alpha_0 = 0;
%Задание пустых массивов для последующего расчета
Time_massiv = [t];
param_hist = [param_0];
Theta_massiv = [Theta_Stage_Bound(1)];
r_massiv = [R_E];
alpha_massiv = [0];
M_massiv = [0];
windage_massiv = [0];
d_massiv =[0 0 0 0 0 ];
g_massiv = [9.81];
%coordinat_massiv = [coordinat_0];


%% Начало Моделирования %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Активный участок полета ракеты

%Шаг по времени (маленький)
dt = 0.1;

for i = 1:stage
    
    param_old(5) = M_Sum(i);
    
    while 1
    t = t + dt;
    
    
    [param_new, delta, Theta, alpha, g] = ...
    fly_simulation(i,param_old,Stage_Time_Interval,Theta_Stage_Bound, ...
    PP_1,PP_2);

    %Переназначение параметров
    param_old = param_new;

    %Заполнение массивов
    param_hist = [param_hist; param_new];
    Theta_massiv = [Theta_massiv Theta];
    alpha_massiv = [alpha_massiv alpha];
    g_massiv = [g_massiv g];
    d_massiv = [d_massiv delta];
    Time_massiv = [Time_massiv t];
    
    if t >= t_Fin(i)
        break
    end
    end
%Запоминания парраметров системы в момент отделения ступени
param_Fall_0(i,:) = param_old;
    
    
end


%% Участок баллистического падения ПН

%начальные условия
m = M_PN;
alpha = 0;
h = param_old(3);
dt = 1;
fi = param_old(4);
fi_Fin = fi + 2*pi;
n_fall = length(Time_massiv);

while h > 0 & fi < fi_Fin

    t = t + dt;
    fi = param_old(4);
    
[param_new, delta,g] = fall_simulation(param_old,alpha,m);

    %Переназначение параметров
    param_old = param_new;
    
    %Заполнение массивов
    param_hist = [param_hist; param_new];
    Theta_massiv = [Theta_massiv Theta];
    alpha_massiv = [alpha_massiv alpha];
    g_massiv = [g_massiv g];
    d_massiv = [d_massiv delta];
    Time_massiv = [Time_massiv t];

h = param_new(3);

%если ракета покинула орбиту Земли
PKS = sqrt((h + R_E)*g);
VKS = PKS*sqrt(2);
if param_new(1) > VKS & h > 40000000
    break
end
    
end


%% Участок баллистического падения различных ступеней ракеты 

for i = 1:stage
    %Начальные условия
    t_Fall = t_Fin(i);
    alpha = 0;
    m = M_K(i);
    h_fall = param_Fall_0(i,3);
    dt = 1;   
    param_old = param_Fall_0(i,:);
    ii = 0; 
    
    fi = param_old(4);
    fi_Fin = fi + 2*pi;
    

    while h_fall > 0 & fi < fi_Fin
    t_Fall = t_Fall + dt;
    ii = ii + 1;
    
    fi = param_old(4);
    
[param_new, delta,g] = fall_simulation(param_old,alpha,m);

    %Переназначение параметров
    param_old = param_new;

h_fall = param_new(3);
    
    %Заполнение массивов
    Time_massiv_fall(i,ii) = t_Fall;
    

 V_massiv_fall(i,ii)           = param_new(1);
 Theta_pol_g_massiv_fall(i,ii) = param_new(2);
 h_massiv_fall(i,ii)           = param_new(3);
 fi_massiv_fall(i,ii)          = param_new(4);
 m_massiv_fall(i,ii)           = param_new(5);
 
 %если ракета покинула орбиту Земли
PKS = sqrt((h + R_E)*g);
VKS = PKS*sqrt(2);
if param_new(1) > VKS & h > 40000000
    break
end

    
    end
    
       
end



%% Распаковка параметров основной системы
 %распаковка param_hist
 V_massiv = param_hist(:,1)';
 Theta_pol_g_massiv = param_hist(:,2)';
 h_massiv = param_hist(:,3)';
 fi_massiv = param_hist(:,4)';
 m_massiv = param_hist(:,5)';
 
 %распаковска d_massiv
 dV_massiv = d_massiv(:,1)';
 dTheta_pol_g_massiv = d_massiv(:,2)';
 dh_massiv = d_massiv(:,3)';
 dfi_massiv = d_massiv(:,4)';
 
 %создание ноывх массивов
 r_massiv = h_massiv + R_E;
 Vx_massiv = V_massiv.*cos(Theta_pol_g_massiv);
 Vy_massiv = V_massiv.*sin(Theta_pol_g_massiv);
 
 %корректировка массивов для граффиков
 h_massiv_graf = h_massiv/1000; %в км
 
 Theta_pol_g_massiv_graf = Theta_pol_g_massiv*180/pi;
 fi_massiv_graf = fi_massiv*180/pi;
 alpha_massiv_graf = alpha_massiv*180/pi;
 Theta_massiv_graf = Theta_massiv*180/pi;
 
 % Распаковка параметров отработавших ступеней
 r_massiv_fall = h_massiv_fall + R_E;
 
 %% Сообщение о успешном или неуспешном, кто знает, результате
 
 
 
 screen2 = screen_2(h, fi, fi_Fin,param_hist,n_fall)
 
 %% Меню для вывода результатов
 while 1
 Result_Choise = menu ('Выберете действие для вывода:', ...
     'График траектории полета ракеты', ...
     'График полета ракеты с траекториями отработавших степеней', ...
     'Анимированный 2D график траектории', ...
     'Анимированный 3D график траектории', ...
     'Меню информационных графиков');
 
 
 %% Графики
 if Result_Choise == 1 | Result_Choise == 2
  %траектория
  figure (1)
  %Траектория основной системы
b = r_massiv .* cos(fi_massiv);
a = r_massiv .* sin(fi_massiv);

hold on
grid on
plot (a/1000, b/1000,'c')
%построение круга
Z = [0:pi/180:1.2*fi_massiv(end)];
x = R_E*sin(Z);
y = R_E*cos(Z);
plot (x/1000,y/1000,'k')

  title('траектория полета')
  xlabel('км')
  ylabel('км')
  axis equal 
  
  if Result_Choise == 2
 
 %Траектория отработавших ступеней
for i = 1:stage
b = r_massiv_fall(i,:)  .* cos(fi_massiv_fall(i,:) );
a = r_massiv_fall(i,:)  .* sin(fi_massiv_fall(i,:) );   
plot (a(1)/1000, b(1)/1000,'o')   %кружочки в момент отстыковки
plot (a/1000, b/1000,'Linewidth',2)
end

  end
 
 end
  
  
  %% Создание анимированного 2D графика
  if Result_Choise == 3;
 %Построение модели планеты
 figure(2)
 hold on
 grid on
Z = [0:pi/180:1.2*fi_massiv(end)];
x = R_E*sin(Z);
y = R_E*cos(Z);
plot (x/1000,y/1000,'k')
  title('траектория полета')
  xlabel('км')
  ylabel('км')
  axis equal 

  
 %Активный участок
 
 dn = 1;

 for n = 1+dn:dn:length(Time_massiv)
     
b = r_massiv(n-dn:dn:n) .* cos(fi_massiv(n-dn:dn:n));
a = r_massiv(n-dn:dn:n) .* sin(fi_massiv(n-dn:dn:n));

plot (a/1000, b/1000,'c')

pause(0.000001)
 end
 
  end
  
  
  %% Создание 3D анимации
if Result_Choise == 4;  
  
figure (3)
[x,y,z] = sphere_3D (R_E/1000, 11, 11);
view([-160 21])
grid on
hold on
xlabel('x')
ylabel('y')
zlabel('z')
  
%кружочки в месте старта
a_3D = r_massiv(1) .* sin(fi_massiv(1));
b_3D = r_massiv(1) .* cos(fi_massiv(1));
c_3D = zeros(size(a_3D));

plot3(a_3D/1000,b_3D/1000,c_3D/1000,'o')
  

dn = 10;
%активный участок
for  n = 1+dn:dn:length(Time_massiv)
    
a_3D = r_massiv(n-dn:dn:n) .* sin(fi_massiv(n-dn:dn:n));
b_3D = r_massiv(n-dn:dn:n) .* cos(fi_massiv(n-dn:dn:n));
c_3D = zeros(size(a_3D));

plot3(a_3D/1000,b_3D/1000,c_3D/1000,'r')
  
pause (0.000001)
end
  
end


%% Информационные графики
if Result_Choise == 5;  
    while 1
    graff_choise = menu('Выберете график', ...
        'скорость полета', ...
        'Высота', ...
        'Масса системы от времени', ...
        'Ускорение свободного падения', ...
        'Угол тангажа', ...
        'Скоростной угол тангажа', ...
        'Угол атаки');
    
if graff_choise == 1
  figure (4)
  hold on
  grid on
  plot (Time_massiv,V_massiv/1000)
  plot (Time_massiv,Vx_massiv/1000)
  plot (Time_massiv,Vy_massiv/1000)
  title ('скорость полета')
  xlabel('время, с.')
  ylabel('скорость, км/с')
  legend('Скорость ЛА','Горизонтальная скорость', 'Вертикальная скорость')
  
elseif graff_choise == 2
  figure (5)
  grid on
  plot (Time_massiv,h_massiv_graf)
  grid on
  title('Высота')
  xlabel('Время, с.')
  ylabel('Высота, км.')
  
elseif graff_choise == 3
  figure (6)
  grid on
  plot (Time_massiv,m_massiv/1000)
  grid on
  title('Масса системы от времени')
  xlabel('Время, с.')
  ylabel('Масса, т.')
  
elseif graff_choise == 4  
  figure (7)
  grid on
  plot (Time_massiv,g_massiv)
  grid on
  title('Ускорение свободного падения')
  xlabel('Время, с.')
  ylabel('g, м/с^2')
  
elseif graff_choise == 5  
  figure (8)
  plot (Time_massiv,Theta_massiv_graf)
  grid on
  title('Угол тангажа')
  xlabel('Время, с.')
  ylabel('град')
  
elseif graff_choise == 6
  figure (9)
  plot (Time_massiv,Theta_pol_g_massiv_graf)
  grid on
  title('Скоростной угол тангажа')
  xlabel('Время, с.')
  ylabel('град')
  
elseif graff_choise == 7
  figure (9)
  plot (Time_massiv,alpha_massiv_graf)
  grid on
  title('Угол атаки')
  xlabel('Время, с.')
  ylabel('град')
  
  
  
  
  
else
    break
end

end
  

end


%% Закрытие меню вывода результатов
if Result_Choise == 0
break
end


 end
 
 %%
I = P./GT;
M1M2= M_Sum./(M_Sum-M_T);
V = I.*log(M1M2);
V = sum(V);
V_g = V - sum(Time)*g_massiv(1)
 
 
 
