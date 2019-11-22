function [param_new, delta, Theta, alpha, g] = ...
    fly_simulation(i,param_old,Stage_Time_Interval,Theta_Stage_Bound, ...
    PP_1,PP_2)

global R_E M_E Grav_post S_rocket t t_0 windage_function St_fall P GT dt

    %распаковка параметров
    V =           param_old(1);
    Theta_pol_g = param_old(2);
    h =           param_old(3);
    fi =          param_old(4);
    m =           param_old(5);
 
    
    %расчет углов на новом временном слое
    %
    [Theta] = Tangagh_corner (t, Stage_Time_Interval(i,:), ...
        Theta_Stage_Bound(i,:), PP_1(i,:), PP_2(i,:), t_0(i));
    Theta_g = Theta + fi;
    alpha = Theta_g - Theta_pol_g;
    
    %силы притяжения
    r = h+R_E;
    g = M_E*Grav_post/r^2;
    G = m*g;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %сопротивление воздуха
    if windage_function == 1  h <= 50000;
    %параметры атмосферы на данной высоте
    [Pressure,Density,Temperature,A]=atm_stand(h);
    M = V/A;
    % коэффициенты сопротивления
    [Cx, Cy] = aerodinamic_koeficient (M, alpha);
    %Силы сопротивления воздуха
    X_windage = 0.5*Cx*Density*V^2*S_rocket;
    Y_windage = 0.5*Cy*Density*V^2*S_rocket;
    windage = sqrt(X_windage^2 + Y_windage^2);
    else
    X_windage = 0; Y_windage = 0;
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %математическая модель связанная с центром земли
    
    dV = (P(i)*cos(alpha) - G*sin(Theta_pol_g) - X_windage)/m;
    
    d_Theta_pol_g = (P(i)*sin(alpha) - G*cos(Theta_pol_g) ...
        + (V^2*m)/r*cos(Theta_pol_g) + Y_windage)/(m*V);
    
    dh = V*sin(Theta_pol_g);
    
    dfi = V/r*cos(Theta_pol_g); 
    
    %расчет основных параметров на новом временном слое
    %
    %массив для дифференцирования
    delta = [dV d_Theta_pol_g dh dfi -GT(i)];
    
    param_new = param_old + dt * delta(end, :);
    
    


        