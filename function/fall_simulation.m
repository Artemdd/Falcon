function [param_new, delta,g] = fall_simulation(param_old,alpha,m)

global R_E M_E Grav_post S_rocket windage_function St_fall dt

    %распаковка параметров
    V =           param_old(1);
    Theta_pol_g = param_old(2);
    h =           param_old(3);
    fi =          param_old(4);
    
    
    %силы притяжения
    r = h+R_E;
    g = M_E*Grav_post/r^2;
    G = m*g;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %сопротивление воздуха
    if windage_function == 1 &  h <= 50000
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
    
    dV = (- G*sin(Theta_pol_g) - X_windage)/m;
    
    d_Theta_pol_g = (- G*cos(Theta_pol_g) ...
        + (V^2*m)/r*cos(Theta_pol_g) + Y_windage)/(m*V);
    
    dh = V*sin(Theta_pol_g);
    
    dfi = V/r*cos(Theta_pol_g); 
    
    %расчет основных параметров на новом временном слое
    %
    %массив для дифференцирования
    delta = [dV d_Theta_pol_g dh dfi 0];
    
    param_new = param_old + dt * delta(end, :);
    
    
    
    
    
    
    