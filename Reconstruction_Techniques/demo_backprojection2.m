M=256;
Elipse = zeros(M);

[rows, cols] = size(Elipse);

a = 75;
b = 50;

xcenter = round(cols / 2);
ycenter = round(rows / 2);
x0 = 0;
y0 = 0;
theta = deg2rad(100);

for i = 1:256
    for j = 1:256
        pixelx = (i - xcenter);
        pixely = (j - ycenter);
        
        xrot =(pixelx - x0)*cos(theta) + (pixely - y0)*sin(theta);
        yrot =(pixely - y0)*cos(theta) - (pixelx - x0)*sin(theta);
        if (xrot^2 / a^2 + yrot^2 / b^2 <= 1)
            Elipse(256 - j + 1, i) = 0.5;
        end
    end
end

Theta = 1:1:360;


% Columnas representan los sinogramas para cada ángulo
sinogram = radon(Elipse, Theta);  % 367x360
[N, num_angles] = size(sinogram);

% 3. Aplicar la Transformada de Fourier a cada proyección
sin_fft = fft(sinogram); % S_theta(w) Fourier Slice Theorem 

dx = 1e-3;
L = 1/(2*dx);
% 4. Filtrado
w = linspace(-L, L, N)';
H = abs(w); % filtro de Ram-Lak
filtered_projection = abs(ifft(sin_fft .* H));

% 5. Inicializar la imagen reconstruida
f = zeros(N);

x_center = round(N/2);
y_center = round(N/2);

fig = figure;
h = imshow(f, []);
title('Backprojection Animation');
hold on;

% 6. Backprojection
for alpha = 1:num_angles
    theta_rad = deg2rad(Theta(alpha));
    Q_theta = filtered_projection(:, alpha);
    
    for x = 1:N
        for y = 1:N
            pixel_x = (x-x_center);
            pixel_y = (y-y_center);
            t = (x - x_center) * cos(theta_rad) + (y - y_center) * sin(theta_rad);
            s =-(x - x_center) * sin(theta_rad) + (y - y_center) * cos(theta_rad);
            
            t_index = round(s + (N / 2)); % Ajuste de índice
            if t_index >= 1 && t_index <= N
                f(x, y) = f(x, y) + Q_theta(t_index);
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

% Normalizar la imagen reconstruida
f = f/max(f,[],"all");
f = (pi / (num_angles))*f;

%error = (f - Elipse);
figure;
imshow(Elipse, []);
title('2D Object')

figure;
imshow(f, []);
title('Reconstruction')

%%
% ------Para encontrar el error necesito hacer del mismo tamaño que la
%reconstruccion--------
[xB, yB] = meshgrid(1:size(Elipse, 2), 1:size(Elipse, 1));

% Crear una cuadrícula de coordenadas para la matriz más grande (destino)
[xA, yA] = meshgrid(linspace(1, size(Elipse, 2), size(f, 2)), linspace(1, size(Elipse, 1), size(f, 1)));

% Interpolar la matriz B a las dimensiones de A
Elipse_resized = interp2(xB, yB, Elipse, xA, yA, 'linear'); % 'linear' es la opción de interpolación

%----- Tambien imresize puede ayudarme en esto pero como logre hacerlo con
%la interpolacion lo dejare con este :D
% B_resized = imresize(Elipse, [size(f, 1), size(f, 2)]);

figure;
imshow(Elipse_resized, []);
title('interpolación')

%-------Una vez hecho esto ya puedo obtener el error---------

error = vecnorm(f-Elipse_resized, 2, 1);
si=immse(f,Elipse_resized)
%figure;
%imshow(B_resized, []);

error2=abs(f-Elipse_resized);

X= size(f);
err = 0;
for x=1:X
    for y=1:X
        err = err + error2(x,y);
    end
end


figure;
plot(error)
title('error')
xlabel('projections')
ylabel('error')

for i = 1:N-1
    mse(:,i) = mean((f(:,i)-Elipse_resized(:,i)).^2);
end

figure;
plot(abs(mse));

%figure;
%imagesc(sinogram);
%title('Radon Transform')

%figure;
%imshow(real(sin_fft));
%title('FST')

%figure(4)
%for i=1:360
%    for j=1:N
