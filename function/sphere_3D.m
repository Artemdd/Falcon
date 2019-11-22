function [x,y,z] = sphere_3D (R, accuracy_vertical, accuracy_horizontal)

D = [0:pi/accuracy_vertical:pi];           %точность вертикальная
k = [0:pi/accuracy_horizontal/2:2*pi];     %точность горизонтальная
%под точностью понимается то, сколько отрезков будет по вертикале и
%горизонтале соответственно

%Построение дуги
x = sin(D)*R;    
z = cos(D)*R;
y = zeros(size(x));

 for n = 1:length(k)
x(n,:) = x(1,:).*cos(k(n));
y(n,:) = x(1,:).*sin(k(n));
z(n,:) = z(1,:);

 end
 
 XX = x';
 YY = y';
 ZZ = z';

 
plot3(XX,YY,ZZ,'b')
hold on
plot3(x,y,z,'b')
axis equal

end