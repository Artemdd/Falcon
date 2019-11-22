% ������� ��� ����������� ����������� ���� ������� �������� ������ �������

function [Theta_t] = Tangagh_corner (t, Stage_Time_Interval, ...
    Theta_Stage_Bound, PP_1, PP_2, t_0)

% - �������� ��������� ������ ��������� �������
% t_0 - ����� ������ ������ �������
%
t = t - t_0;
% Stage_Time_Interval ������������ �� ���� ������ �� ���� ��������  
% (������ �������� ������ ���� ������ ����� ���� ���������)
% [����� ��� �������, 
% ������������ ����� ������(�� ������ ��������� �� �������),
% ������ ���������� �������, 2 ���������� �������,
% ������������ ������� � ����� ��� �������]
%
Delta_t = Stage_Time_Interval(1);
tau_1 = Stage_Time_Interval(2);
tau_2 = Stage_Time_Interval(3);
tau_4 = Stage_Time_Interval(4);
tau_5 = Stage_Time_Interval(5);
tau_3 = Delta_t - sum(Stage_Time_Interval(2:end)); 

% ��������� �������� ���� �������
Theta_S = Theta_Stage_Bound(1);
Theta_F = Theta_Stage_Bound(2);
Theta_A = Theta_S;
Theta_D = Theta_F;

% ��������� ������� �������� ������ ����������
t_S = 0;
t_A = tau_1;
t_B = tau_1 + tau_2;
t_C = Delta_t - (tau_4 + tau_5);
t_D = Delta_t - tau_5;
t_F = Delta_t;

% ������� ������� ��� ���������� �������� �������
t_a = tau_1 + tau_2/2;
t_b = Delta_t - tau_5 - tau_4/2;


     % ���������� ����� ����������� ��� ������ ���������� ��������

      if t < t_A
          Theta_t = Theta_S;
      elseif (t_A <= t) & (t < t_B)
          Theta_t = polyval(PP_1, t);
      elseif (t >= t_B)&(t < t_C)
          Theta_t = (Theta_S/(t_b - t_a))*(t_b - t) + ... 
         (Theta_F/(t_b - t_a))*(t - t_a);
      elseif (t >= t_C)&(t < t_D)
          Theta_t = polyval(PP_2, t);
      else
           Theta_t = Theta_F;
      end
      
      
  
  
end



