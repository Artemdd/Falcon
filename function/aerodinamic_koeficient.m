function [Cx, Cy] = aerodinamic_koeficient (M, alpha)

%поиск аэродинамических коэффицентов для баллистических 
%ракет с конической боевой частью

if M <= 0.8
    Cx = 0.29;
elseif (M > 0.8) & (M<=1.068)
    Cx = M - 0.51;
else
    Cx = 0.091 + 0.5*M^(-1);
end


if M <= 0.25
    Cy = 2.8;
elseif (M > 0.25) & (M<=1.1)
    Cy = 2.8 + 0.477*(M - 0.25);
elseif (M > 1.1) & (M<=1.6)
    Cy = 3.18 - 0.66*(M - 1.1);
elseif (M > 1.6) & (M<=3.6)
    Cy = 2.85 + 0.35*(M - 1.6);
else
    Cy = 3.55;
end

Cy = alpha*Cy;

end
    