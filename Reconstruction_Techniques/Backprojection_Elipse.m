M=256;
Elipse=zeros(M);

[rows, cols]=size(Elipse);

a=75;
b=50;

xcenter=round(cols/2);
ycenter=round(rows/2);
x0=0;
y0=0;
theta=deg2rad(100);

for i=1:256
    for j=1:256
        pixelx=(i-xcenter);
        pixely=(j-ycenter);
        
        xrot=(pixelx-x0)*cos(theta)+(pixely-y0)*sin(theta);
        yrot=(pixely-y0)*cos(theta)-(pixelx-x0)*sin(theta);
        if(xrot^2/a^2+yrot^2/b^2<=1)
            Elipse(256-j+1,i)=0.5;
        end
    end
end

Theta=1:1:180;
% Columnas representan los senogramas para cada angulo
% Si Theta=0 ----  sinogram(:,1)
% Si Theta=1 ----  sinogram(:,2)
% Si Theta=n ----  sinogram(:,i+1)

sinogram=radon(Elipse,Theta); 
[N, num_angles] = size(sinogram);

% Backprojection
f = zeros(M);

x_center = round(M / 2);
y_center = round(M / 2);

%Recorrer los valores de la longitud angular
for alpha = 1:num_angles
    %Transformacion a radianes
    theta_rad = deg2rad(Theta(alpha));
    
    % Proyección para este ángulo
    projection = sinogram(:, alpha);
    
    %Iteracion sobre cada eje de la funcion
    for x = 1:M
        for y = 1:M
            t = (x - x_center) * cos(theta_rad + theta) + (y - y_center) * sin(theta_rad + theta);
            s =-(x - x_center) * sin(theta_rad) + (y - y_center) * cos(theta_rad);
            
            %t= (x-x_center)*cos(theta_rad)+(y-y_center)*sin(theta_rad); 
            t_index = round(s+ N/2); %La posicion de la integral de linea
            
            if t_index >= 1 && t_index <= N
                f(x, y) = f(x, y) + projection(t_index);
            end
        end
    end
end

f = (pi / 2*num_angles)*f; % Normalización

figure;
imshow(Elipse, []);
title('2D Object');

figure;
imagesc(sinogram);
xlabel('Angle \theta')
title('Sinogram');

figure;
imshow(f, []);
title('Reconstruction');


f = f/max(f,[],"all");

figure;
imshow(f, []);
title('Reconstruction');

% for i=1:num_angles
%     figure;
%     plot(sinogram(:,i))
%     title(['Sinogram with \theta =', num2str(Theta(i))])
%     xlabel('t')
%     ylabel('P_{\theta}(t)')
% end