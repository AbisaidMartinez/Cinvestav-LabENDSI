M = 256;
P=zeros(M);

[rows, cols] = size(P);

xcenter=round(cols/2);
ycenter=round(rows/2);
 
%Tabla de datos paper Tabla 1
Elipse_Data =[%Centrox %Centroy %Eje Mayor %Eje Menor %Theta %Valor Pixel
                 0         0         .69        .92      0            1
                 0       -0.0184    .6624      .874      0         -0.8
                 0.22      0         .11        .31     -18        -.2
                -0.22      0         .16        .41      18        -.2
                 0        0.35       .21        .25      0          .1
                 0        0.1       .046        .046     0          .1
                 0        -0.1       .046       .046     0          .1   
                 -0.08    -.605      .046       .023     0          .1
                 0        -.605      .023       .023     0          .1
                 .06      -.605      .023       .046     0          .1];       

for i=1:M
    for j=1:M

        %Coordenadas de Imagen
        pixelx=(i-xcenter)/xcenter;
        pixely=(j-ycenter)/ycenter;
        
        for k=1:size(Elipse_Data,1)

            %Debe de Cumplir la forma x^2/A^2+y^2/B^2<=1
            x0=Elipse_Data(k,1);
            y0=Elipse_Data(k,2);

            %Eje mayor y menor
            a=Elipse_Data(k,3);
            b=Elipse_Data(k,4);

            %Intensidad de Pixel
            I=Elipse_Data(k,6);

            %Angulo
            theta=deg2rad(Elipse_Data(k,5));
            xrot=(pixelx-x0)*cos(theta)+(pixely-y0)*sin(theta);
            yrot=(pixely-y0)*cos(theta)-(pixelx-x0)*sin(theta);
            if(xrot^2/a^2+yrot^2/b^2<=1)
                P(256-j+1,i)=P(256-j+1,i)+I;
            end
        end
    end
end

figure;
imshow(P, []);
title('Sheep-Logan Head Phantom')

Theta=1:1:180;
% Columnas representan los senogramas para cada angulo
% Si Theta=0 ----  sinogram(:,1)
% Si Theta=1 ----  sinogram(:,2)
% Si Theta=n ----  sinogram(:,i+1)

sinogram=radon(P,Theta); 
[N, num_angles] = size(sinogram);

% Backprojection
f = zeros(M);

x_center = round(M / 2);
y_center = round(M / 2);

fig = figure;
h = imshow(f, []);
title('Backprojection Animation');
hold on;

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

    set(h, 'CData', f/max(f,[],"all"));

    frame = getframe(fig);
    img = frame2im(frame);
    [imind, cm] = rgb2ind(img, M);
    
    if alpha == 1
        % Crear el archivo GIF
        imwrite(imind, cm, 'Backprojection_phantom_demo.gif', 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    else
        % Añadir frame al GIF
        imwrite(imind, cm, 'Backprojection_phantom_demo.gif', 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end

    pause(0.1); % Pausa para visualizar la animación
end

