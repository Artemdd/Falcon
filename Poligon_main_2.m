%����������� ������� �������������� �����
%��������� ������, ��������������� ����� ��������� ����� �������, 
clear

%����� ��� �������
cd function

%���������
R_E=6.37111e6; %--������ �����, �
M_E=5.972e24;  %����� �����
Grav_post = 6.674e-11;
global R_E M_E Grav_post S_rocket t t_0 windage_function St_fall P GT dt

%������� ������ ���������
St_fall = 0; %��������� ���������� ������� ������������ ������
windage_function = 0;  %c������������ �������
animation_2D = 0;  %������������� 2D ������ ����������
animation_3D = 1;  %������������� 3D ������ ����������


%����� ������ 
Rocket_Choise=menu('�������� ������������ ������:', ...
    '�-36� ������', ...
    '����-2', ...
    '�������-9', ...
    '����', ...
    '�����-5', ...
    '������ ��������������� ������ ������');

[stage,M_K,M_T,Time,P,M_PN] = Rocket_base (Rocket_Choise);

%% ��������� ������� ��� ������ �������
%�����
t = 0;
for i = 1:stage
t_Fin(i) = sum(Time(1:i));
end
t_0(1) = 0; 
t_0(2:stage) = t_Fin(1:end-1);
%
%�������� ��������� ��� ������������� ����������
GT = M_T./Time;
%����� �����������
for i = 1:stage
M_Sum(i) = sum(M_K(i:end)) + sum(M_T(i:end)) + M_PN;
end
param_0 = [0.0001 pi/2 0 0 M_Sum(1)];
param_old = param_0;

% ������������ �������� �� ������� ������������(��� ����� ������� ���)
I = P./GT;
M1M2= M_Sum./(M_Sum-M_T);
V = I.*log(M1M2);
V = sum(V);
V_g = V - sum(Time)*9.81;

%������� � ������� ����������� ������� ������
D_rocket = 3.7;
S_rocket = pi*(D_rocket/2)^2;
% ����� ���������� � ������
[screen] = screen_1(stage,M_K,M_T,Time,P,M_PN,D_rocket,V);

%% ���� ����� ������� �� ��������� ������ ������ ������
[Stage_Time_Interval, Theta_Stage_Bound] = Tangagh(stage,Time);

%������������� ������ ��������� ���� ������� (��� ������ ������� ������)
for i = 1:stage
[PP_1(i,:), PP_2(i,:)] = Tangagh_corner_coeficient ( ...
    Stage_Time_Interval(i,:), Theta_Stage_Bound(i,:));
end

%�������� ���� ���������� � ������
uiwait(screen);
clear screen


%%
%�������� ��� ��������
Theta_0 = pi/2;   
alpha_0 = 0;
%������� ������ �������� ��� ������������ �������
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


%% ������ ������������� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �������� ������� ������ ������

%��� �� ������� (���������)
dt = 0.1;

for i = 1:stage
    
    param_old(5) = M_Sum(i);
    
    while 1
    t = t + dt;
    
    
    [param_new, delta, Theta, alpha, g] = ...
    fly_simulation(i,param_old,Stage_Time_Interval,Theta_Stage_Bound, ...
    PP_1,PP_2);

    %�������������� ����������
    param_old = param_new;

    %���������� ��������
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
%����������� ����������� ������� � ������ ��������� �������
param_Fall_0(i,:) = param_old;
    
    
end


%% ������� ��������������� ������� ��

%��������� �������
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

    %�������������� ����������
    param_old = param_new;
    
    %���������� ��������
    param_hist = [param_hist; param_new];
    Theta_massiv = [Theta_massiv Theta];
    alpha_massiv = [alpha_massiv alpha];
    g_massiv = [g_massiv g];
    d_massiv = [d_massiv delta];
    Time_massiv = [Time_massiv t];

h = param_new(3);

%���� ������ �������� ������ �����
PKS = sqrt((h + R_E)*g);
VKS = PKS*sqrt(2);
if param_new(1) > VKS & h > 40000000
    break
end
    
end


%% ������� ��������������� ������� ��������� �������� ������ 

for i = 1:stage
    %��������� �������
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

    %�������������� ����������
    param_old = param_new;

h_fall = param_new(3);
    
    %���������� ��������
    Time_massiv_fall(i,ii) = t_Fall;
    

 V_massiv_fall(i,ii)           = param_new(1);
 Theta_pol_g_massiv_fall(i,ii) = param_new(2);
 h_massiv_fall(i,ii)           = param_new(3);
 fi_massiv_fall(i,ii)          = param_new(4);
 m_massiv_fall(i,ii)           = param_new(5);
 
 %���� ������ �������� ������ �����
PKS = sqrt((h + R_E)*g);
VKS = PKS*sqrt(2);
if param_new(1) > VKS & h > 40000000
    break
end

    
    end
    
       
end



%% ���������� ���������� �������� �������
 %���������� param_hist
 V_massiv = param_hist(:,1)';
 Theta_pol_g_massiv = param_hist(:,2)';
 h_massiv = param_hist(:,3)';
 fi_massiv = param_hist(:,4)';
 m_massiv = param_hist(:,5)';
 
 %����������� d_massiv
 dV_massiv = d_massiv(:,1)';
 dTheta_pol_g_massiv = d_massiv(:,2)';
 dh_massiv = d_massiv(:,3)';
 dfi_massiv = d_massiv(:,4)';
 
 %�������� ����� ��������
 r_massiv = h_massiv + R_E;
 Vx_massiv = V_massiv.*cos(Theta_pol_g_massiv);
 Vy_massiv = V_massiv.*sin(Theta_pol_g_massiv);
 
 %������������� �������� ��� ���������
 h_massiv_graf = h_massiv/1000; %� ��
 
 Theta_pol_g_massiv_graf = Theta_pol_g_massiv*180/pi;
 fi_massiv_graf = fi_massiv*180/pi;
 alpha_massiv_graf = alpha_massiv*180/pi;
 Theta_massiv_graf = Theta_massiv*180/pi;
 
 % ���������� ���������� ������������ ��������
 r_massiv_fall = h_massiv_fall + R_E;
 
 %% ��������� � �������� ��� ����������, ��� �����, ����������
 
 
 
 screen2 = screen_2(h, fi, fi_Fin,param_hist,n_fall)
 
 %% ���� ��� ������ �����������
 while 1
 Result_Choise = menu ('�������� �������� ��� ������:', ...
     '������ ���������� ������ ������', ...
     '������ ������ ������ � ������������ ������������ ��������', ...
     '������������� 2D ������ ����������', ...
     '������������� 3D ������ ����������', ...
     '���� �������������� ��������');
 
 
 %% �������
 if Result_Choise == 1 | Result_Choise == 2
  %����������
  figure (1)
  %���������� �������� �������
b = r_massiv .* cos(fi_massiv);
a = r_massiv .* sin(fi_massiv);

hold on
grid on
plot (a/1000, b/1000,'c')
%���������� �����
Z = [0:pi/180:1.2*fi_massiv(end)];
x = R_E*sin(Z);
y = R_E*cos(Z);
plot (x/1000,y/1000,'k')

  title('���������� ������')
  xlabel('��')
  ylabel('��')
  axis equal 
  
  if Result_Choise == 2
 
 %���������� ������������ ��������
for i = 1:stage
b = r_massiv_fall(i,:)  .* cos(fi_massiv_fall(i,:) );
a = r_massiv_fall(i,:)  .* sin(fi_massiv_fall(i,:) );   
plot (a(1)/1000, b(1)/1000,'o')   %�������� � ������ ����������
plot (a/1000, b/1000,'Linewidth',2)
end

  end
 
 end
  
  
  %% �������� �������������� 2D �������
  if Result_Choise == 3;
 %���������� ������ �������
 figure(2)
 hold on
 grid on
Z = [0:pi/180:1.2*fi_massiv(end)];
x = R_E*sin(Z);
y = R_E*cos(Z);
plot (x/1000,y/1000,'k')
  title('���������� ������')
  xlabel('��')
  ylabel('��')
  axis equal 

  
 %�������� �������
 
 dn = 1;

 for n = 1+dn:dn:length(Time_massiv)
     
b = r_massiv(n-dn:dn:n) .* cos(fi_massiv(n-dn:dn:n));
a = r_massiv(n-dn:dn:n) .* sin(fi_massiv(n-dn:dn:n));

plot (a/1000, b/1000,'c')

pause(0.000001)
 end
 
  end
  
  
  %% �������� 3D ��������
if Result_Choise == 4;  
  
figure (3)
[x,y,z] = sphere_3D (R_E/1000, 11, 11);
view([-160 21])
grid on
hold on
xlabel('x')
ylabel('y')
zlabel('z')
  
%�������� � ����� ������
a_3D = r_massiv(1) .* sin(fi_massiv(1));
b_3D = r_massiv(1) .* cos(fi_massiv(1));
c_3D = zeros(size(a_3D));

plot3(a_3D/1000,b_3D/1000,c_3D/1000,'o')
  

dn = 10;
%�������� �������
for  n = 1+dn:dn:length(Time_massiv)
    
a_3D = r_massiv(n-dn:dn:n) .* sin(fi_massiv(n-dn:dn:n));
b_3D = r_massiv(n-dn:dn:n) .* cos(fi_massiv(n-dn:dn:n));
c_3D = zeros(size(a_3D));

plot3(a_3D/1000,b_3D/1000,c_3D/1000,'r')
  
pause (0.000001)
end
  
end


%% �������������� �������
if Result_Choise == 5;  
    while 1
    graff_choise = menu('�������� ������', ...
        '�������� ������', ...
        '������', ...
        '����� ������� �� �������', ...
        '��������� ���������� �������', ...
        '���� �������', ...
        '���������� ���� �������', ...
        '���� �����');
    
if graff_choise == 1
  figure (4)
  hold on
  grid on
  plot (Time_massiv,V_massiv/1000)
  plot (Time_massiv,Vx_massiv/1000)
  plot (Time_massiv,Vy_massiv/1000)
  title ('�������� ������')
  xlabel('�����, �.')
  ylabel('��������, ��/�')
  legend('�������� ��','�������������� ��������', '������������ ��������')
  
elseif graff_choise == 2
  figure (5)
  grid on
  plot (Time_massiv,h_massiv_graf)
  grid on
  title('������')
  xlabel('�����, �.')
  ylabel('������, ��.')
  
elseif graff_choise == 3
  figure (6)
  grid on
  plot (Time_massiv,m_massiv/1000)
  grid on
  title('����� ������� �� �������')
  xlabel('�����, �.')
  ylabel('�����, �.')
  
elseif graff_choise == 4  
  figure (7)
  grid on
  plot (Time_massiv,g_massiv)
  grid on
  title('��������� ���������� �������')
  xlabel('�����, �.')
  ylabel('g, �/�^2')
  
elseif graff_choise == 5  
  figure (8)
  plot (Time_massiv,Theta_massiv_graf)
  grid on
  title('���� �������')
  xlabel('�����, �.')
  ylabel('����')
  
elseif graff_choise == 6
  figure (9)
  plot (Time_massiv,Theta_pol_g_massiv_graf)
  grid on
  title('���������� ���� �������')
  xlabel('�����, �.')
  ylabel('����')
  
elseif graff_choise == 7
  figure (9)
  plot (Time_massiv,alpha_massiv_graf)
  grid on
  title('���� �����')
  xlabel('�����, �.')
  ylabel('����')
  
  
  
  
  
else
    break
end

end
  

end


%% �������� ���� ������ �����������
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
 
 
 
