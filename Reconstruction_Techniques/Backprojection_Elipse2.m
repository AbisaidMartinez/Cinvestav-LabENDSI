M=216;
Elipse = zeros(M);

[rows, cols] = size(Elipse);

a = 30;
b = 10;

xcenter = round(cols / 2);
ycenter = round(rows / 2);
x0 = 0;
y0 = 0;
theta = deg2rad(0);

for i = 1:M
    for j = 1:M
        pixelx = (i - xcenter);
        pixely = (j - ycenter);
        
        xrot =(pixelx - x0)*cos(theta) + (pixely - y0)*sin(theta);
        yrot =(pixely - y0)*cos(theta) - (pixelx - x0)*sin(theta);
        if (xrot^2 / a^2 + yrot^2 / b^2 <= 1)
            Elipse(M - j + 1, i) = 1;
        end
    end
end

figure;
imshow(Elipse)%, [])
%%

img = imread("C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\a\a_square\01.png");%"Pando.jpg");

% Convertir a escala de grises si es necesario
if size(img, 3) == 3
    img = rgb2gray(img);
end

Elipse = imbinarize(img);

%%
Theta = round(linspace(0, 180, 19));

%Elipse = double(ellipse_mask);
%M = Nx;
%x = 309;
% Columnas representan los sinogramas para cada ángulo
sinogram = radon(Elipse, Theta);  % 367x360
[N, num_angles] = size(sinogram);%(1:x,:));

reconstruction2 = iradon(sinogram, Theta,"None");%"Ram-Lak");%

figure;
imshow(reconstruction2, [])

%%
%figure;
%plot(sinogram(:,1))

% 3. Aplicar la Transformada de Fourier a cada proyección
sin_fft = fft(sinogram);%(1:x,:)); % S_theta(w) Fourier Slice Theorem 

% figure;
% imshow(log(abs(sin_fft)), []);
% title('FST')

%plot(abs(sin_fft))
%

dx = 1e-3;
% 4. Filtrado
L = 1/(2*dx);
w = linspace(-L, L, N)';
disp(['Eliga el filtro que desea 1) None 2) Ram-Lak 3) Sheep-Logan 4) Cosine 5) Hamming']);
filter = input('Ingrese el numero: ');
if(filter == 1)
    H = ones(N, 1);       % without filter
elseif(filter == 2)
    H = abs(w); % filtro de Ram-Lak
elseif(filter == 3)
    H = abs(w).* sinc(w / (2*max(w))); % Filtro de Sheep - Logan
elseif(filter == 4)
    H = abs(w).* cos(pi*w/max(w)); % Filtro Coseno
elseif(filter == 5)
    beta= 0.54;
    H = abs(w).* (beta+(1-beta)*cos(2 * pi * w / max(w))); % Filtro Hamming
elseif(filter == 6)
    H = abs(w) .* (0.5 * (1 + cos(2 * pi * w / max(w))));
elseif(filter == 7)
    n = 2;  % Orden del filtro
    wc = 0.5;  % Frecuencia de corte normalizada
    H = abs(w) ./ sqrt(1 + (w/wc).^(2*n));
end
disp(['se selecciono filtro ', num2str(filter)]);

filtered_projection =abs(ifft(sin_fft .* H));
filtered_projection = filtered_projection/max(filtered_projection,[],"all");

figure;
plot(filtered_projection(:,1));%/max(filtered_projection,[],"all"));
%%

% 5. Inicializar la imagen reconstruida
f = zeros(M);

x_center = round(M/2);
y_center = round(M/2);

% 6. Backprojection
for alpha = 1:num_angles
    theta_rad = deg2rad(Theta(alpha));
    Q_theta = filtered_projection(:, alpha);
    
    for x = 1:M
        for y = 1:M
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
end

% Normalizar la imagen reconstruida
f = f/max(f,[],"all");
f = (pi / (num_angles))*f;

%error = (f - Elipse);
% figure;
% imshow(Elipse, []);
% title('2D Object')

figure;
imshow(f, []);
title(['Reconstruction filter ', num2str(filter)])

  

%figure;
%imshow(abs(f-A), [])
%title('Error between filters ')

% figure;
% imshow(sinogram, []);
% title('sinogram')
%%
figure;
imhist(f)


%%
%------Para encontrar el error necesito hacer del mismo tamaño que la
%reconstruccion--------
%[xB, yB] = meshgrid(1:size(Elipse, 2), 1:size(Elipse, 1));

% Crear una cuadrícula de coordenadas para la matriz más grande (destino)
%[xA, yA] = meshgrid(linspace(1, size(Elipse, 2), size(f, 2)), linspace(1, size(Elipse, 1), size(f, 1)));

% Interpolar la matriz B a las dimensiones de A
%Elipse_resized = interp2(xB, yB, Elipse, xA, yA, 'linear'); % 'linear' es la opción de interpolación

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

[X, Y]= size(f);
err = 0;
xd = err;

for x=1:X
    for y=1:X
        err = mean2(err + error2(x,y)); 
        xd = [xd, err];
        
    end
end
%err=err/X*Y;

figure;
plot(xd);
title('error Dr. Balta')
ylabel('error')
xlabel('projections number')

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
