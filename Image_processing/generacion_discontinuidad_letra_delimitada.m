% Leer imagen y convertir a binaria
img = imread('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\e_square\1100.png');

if size(img, 3) == 3
    img = rgb2gray(img); % Convertir a escala de grises si es necesario
end
bw = imbinarize(img);  % Asegurar que sea binaria (fondo negro, letra blanca)

% Obtener contornos del carácter
[B, ~] = bwboundaries(bw, 'holes');

% Identificar automáticamente el contorno interior
maxPoints = 0; % Variable para almacenar el máximo número de puntos
externalContourIdx = 1; % Índice del contorno exterior
innerContourIdx = 2; % Índice del contorno interior

for i = 2:length(B)
    numPoints = size(B{i}, 1); % Número de puntos en el contorno actual
    if numPoints > maxPoints
        maxPoints = numPoints; % Actualizar el máximo
        innerContourIdx = i;   % Guardar índice del contorno interior
    end
end

% Crear máscaras de los contornos
maskExternal = poly2mask(B{externalContourIdx}(:,2), B{externalContourIdx}(:,1), size(bw,1), size(bw,2));
maskInner = poly2mask(B{innerContourIdx}(:,2), B{innerContourIdx}(:,1), size(bw,1), size(bw,2));

% Crear máscara que represente el área entre los contornos
maskBetween = maskExternal & ~maskInner; % Área entre el contorno exterior e interior

% Buscar un punto aleatorio dentro de la zona entre los límites
idx = find(maskBetween); % Índices de los píxeles en la zona entre los contornos
randIdx = idx(randi(length(idx))); % Seleccionar un índice aleatorio
[yRand, xRand] = ind2sub(size(maskBetween), randIdx); % Convertir índice a coordenadas

% Parámetros del círculo (discontinuidad)
radio = 6; % Puedes ajustar este valor

% Crear una máscara de círculo en blanco (1)
[xx, yy] = meshgrid(1:size(bw,2), 1:size(bw,1));
circleMask = ((xx - xRand).^2 + (yy - yRand).^2) <= radio^2;

% Insertar el círculo como discontinuidad en la imagen binaria (en el área entre los límites)
bw_con_discontinuidad = bw;
bw_con_discontinuidad(circleMask & maskBetween) = 0; % Asegurar que el círculo sólo afecta el área entre los contornos

% Mostrar resultado
figure;
subplot(1,2,1);
imshow(img);
title('Original Image')
%title('Imagen original');
hold on;
plot(B{externalContourIdx}(:,2), B{externalContourIdx}(:,1), 'g', 'LineWidth', 2); % Contorno exterior
plot(B{innerContourIdx}(:,2), B{innerContourIdx}(:,1), 'b', 'LineWidth', 2); % Contorno interior

subplot(1,2,2);
imshow(bw_con_discontinuidad);
title('with an anomaly between the bouunding boxes')