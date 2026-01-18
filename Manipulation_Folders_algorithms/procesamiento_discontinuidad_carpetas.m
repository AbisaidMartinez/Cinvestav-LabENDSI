% Carpetas de entrada y salida
folderInput = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\a_square';
folderOutput = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\a_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\resultado_discontinuidad';

% Crear carpeta de salida si no existe
if ~exist(folderOutput, 'dir')
    mkdir(folderOutput);
end

% Obtener lista de archivos PNG en la carpeta
imageFiles = dir(fullfile(folderInput, '*.png'));

% Parámetros del círculo
radio = 5 + randi(5);

for k = 1:length(imageFiles)
    % Leer imagen
    fileName = imageFiles(k).name;
    fullPath = fullfile(folderInput, fileName);
    img = imread(fullPath);

    % Convertir a escala de grises si es RGB
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Binarizar imagen
    bw = imbinarize(img);

    % Obtener contornos
    [B, ~] = bwboundaries(bw, 'holes');

    % Identificar el contorno interior más grande (asumiendo que B{1} es exterior)
    maxPoints = 0;
    externalContourIdx = 1;
    innerContourIdx = 2;

    for i = 2:length(B)
        numPoints = size(B{i}, 1);
        if numPoints > maxPoints
            maxPoints = numPoints;
            innerContourIdx = i;
        end
    end

    % Crear máscaras
    maskExternal = poly2mask(B{externalContourIdx}(:,2), B{externalContourIdx}(:,1), size(bw,1), size(bw,2));
    maskInner = poly2mask(B{innerContourIdx}(:,2), B{innerContourIdx}(:,1), size(bw,1), size(bw,2));
    maskBetween = maskExternal & ~maskInner;

    % Seleccionar punto aleatorio dentro del área entre contornos
    idx = find(maskBetween);
    if isempty(idx)
        warning('No se encontró área válida en %s, se omite.', fileName);
        continue;
    end
    randIdx = idx(randi(length(idx)));
    [yRand, xRand] = ind2sub(size(maskBetween), randIdx);

    % Crear círculo de discontinuidad
    [xx, yy] = meshgrid(1:size(bw,2), 1:size(bw,1));
    circleMask = ((xx - xRand).^2 + (yy - yRand).^2) <= radio^2;

    % Insertar discontinuidad
    bw_con_discontinuidad = bw;
    bw_con_discontinuidad(circleMask & maskBetween) = 0;

    % Guardar imagen modificada
    outputFilePath = fullfile(folderOutput, fileName);
    imwrite(bw_con_discontinuidad, outputFilePath);
end

disp('¡Proceso completado con éxito!');

%% Casos donde la e no logra cerrarse por completo y las que si pueden

% Carpetas de entrada y salida
%folderInput = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\e_square';
%folderOutput = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\resultado_discontinuidad';
folderInput = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\a_square';
folderOutput = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\a_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\resultado_discontinuidad';

% Crear carpeta de salida si no existe
if ~exist(folderOutput, 'dir')
    mkdir(folderOutput);
end

% Obtener lista de archivos PNG en la carpeta
imageFiles = dir(fullfile(folderInput, '*.png'));

for k = 1:length(imageFiles)
    % Leer imagen
    fileName = imageFiles(k).name;
    fullPath = fullfile(folderInput, fileName);
    img = imread(fullPath);

    % Convertir a escala de grises si es RGB
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Binarizar imagen
    bw = imbinarize(img);

    % Obtener contornos
    [B, ~] = bwboundaries(bw, 'holes');

    % Verificar existencia de contornos
    if isempty(B)
        warning('No se encontraron contornos en %s, se omite.', fileName);
        continue;
    end

    % Crear máscara del contorno exterior
    maskExternal = poly2mask(B{1}(:,2), B{1}(:,1), size(bw,1), size(bw,2));

    % Revisar si hay contorno interior
    if length(B) >= 2
        % Buscar el contorno interior más grande
        maxPoints = 0;
        innerContourIdx = 2;
        for i = 2:length(B)
            numPoints = size(B{i}, 1);
            if numPoints > maxPoints
                maxPoints = numPoints;
                innerContourIdx = i;
            end
        end

        maskInner = poly2mask(B{innerContourIdx}(:,2), B{innerContourIdx}(:,1), size(bw,1), size(bw,2));
        maskBetween = maskExternal & ~maskInner;
    else
        % Si no hay contorno interior, usar todo el exterior
        maskBetween = maskExternal;
    end

    % Verificar que hay una región válida donde insertar el círculo
    idx = find(maskBetween);
    if isempty(idx)
        warning('No se encontró área válida en %s, se omite.', fileName);
        continue;
    end

    % Escoger punto aleatorio dentro de la máscara válida
    randIdx = idx(randi(length(idx)));
    [yRand, xRand] = ind2sub(size(maskBetween), randIdx);

    % Generar radio aleatorio entre 5 y 10 para esta imagen
    radio = 5 + randi(5);

    % Crear máscara del círculo
    [xx, yy] = meshgrid(1:size(bw,2), 1:size(bw,1));
    circleMask = ((xx - xRand).^2 + (yy - yRand).^2) <= radio^2;

    % Insertar discontinuidad
    bw_con_discontinuidad = bw;
    bw_con_discontinuidad(circleMask & maskBetween) = 0;

    % Guardar imagen
    outputFilePath = fullfile(folderOutput, fileName);
    imwrite(bw_con_discontinuidad, outputFilePath);
end

disp('¡Proceso completado con éxito!');

%% Mostrar algunas imagenes con discontinuidad

% Obtener lista de imágenes procesadas
outputFiles = dir(fullfile(folderOutput, '*.png'));

% Verificar que haya suficientes imágenes
numToShow = min(20, length(outputFiles));

% Seleccionar imágenes aleatorias
perm = randperm(length(outputFiles), numToShow);

% Mostrar imágenes seleccionadas
figure;
for i = 1:numToShow
    % Leer imagen
    imgPath = fullfile(folderOutput, outputFiles(perm(i)).name);
    img = imread(imgPath);
    
    % Mostrar en subplot
    subplot(4, 5, i);
    imshow(img);
    title(outputFiles(perm(i)).name, 'Interpreter', 'none'); % Mostrar nombre de archivo
end

sgtitle("Handwriting with Hole Database");

%%

img = imread('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\resultado_discontinuidad\01.png')

figure;
imshow(img, [])

%% Intervalos de nombres output

% Carpetas de entrada y salida
folderInput = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\b_square';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentacion\e';
folderOutput = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\sin_mascara\b_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentacion\e_mask';

% Crear carpeta de salida si no existe
if ~exist(folderOutput, 'dir')
    mkdir(folderOutput);
end

% Obtener lista de archivos PNG en la carpeta
imageFiles = dir(fullfile(folderInput, '*.png'));

% Definir rango de nombres
startIndex = 1100;%1698;
endIndex = 1120;%1700;
maxImages = endIndex - startIndex + 1;

% Contador para el nombre
imageCounter = 0;

% Recorrer imágenes
for k = 1:length(imageFiles)
    if imageCounter >= maxImages
        break;  % ya se han guardado todas las imágenes necesarias
    end

    i = randi(length(imageFiles));
    % Leer imagen
    fileName = imageFiles(i).name;
    fullPath = fullfile(folderInput, fileName);
    img = imread(fullPath);

    % Convertir a escala de grises si es RGB
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Binarizar imagen
    bw = imbinarize(img);

    % Obtener contornos
    [B, ~] = bwboundaries(bw, 'holes');

    % Identificar el contorno interior más grande
    maxPoints = 0;
    externalContourIdx = 1;
    innerContourIdx = 2;

    for i = 2:length(B)
        numPoints = size(B{i}, 1);
        if numPoints > maxPoints
            maxPoints = numPoints;
            innerContourIdx = i;
        end
    end

    % Crear máscaras
    maskExternal = poly2mask(B{externalContourIdx}(:,2), B{externalContourIdx}(:,1), size(bw,1), size(bw,2));
    maskInner = poly2mask(B{innerContourIdx}(:,2), B{innerContourIdx}(:,1), size(bw,1), size(bw,2));
    maskBetween = maskExternal & ~maskInner;

    % Seleccionar punto aleatorio dentro del área entre contornos
    idx = find(maskBetween);
    if isempty(idx)
        warning('No se encontró área válida en %s, se omite.', fileName);
        continue;
    end
    randIdx = idx(randi(length(idx)));
    [yRand, xRand] = ind2sub(size(maskBetween), randIdx);

    % Parámetros del círculo (puedes personalizar el rango si quieres)
    radio = 5 + randi(5);

    % Crear círculo
    [xx, yy] = meshgrid(1:size(bw,2), 1:size(bw,1));
    circleMask = ((xx - xRand).^2 + (yy - yRand).^2) <= radio^2;

    % Insertar discontinuidad
    bw_con_discontinuidad = bw;
    bw_con_discontinuidad(circleMask & maskBetween) = 0;

    % Generar nombre nuevo (ej: 1668.png, 1669.png, ...)
    newName = sprintf('%d.png', startIndex + imageCounter);
    outputFilePath = fullfile(folderOutput, newName);

    % Guardar imagen
    imwrite(bw_con_discontinuidad, outputFilePath);
    fprintf('Imagen guardada: %s\n', newName);

    % Incrementar contador
    imageCounter = imageCounter + 1;
end

disp('¡Proceso completado con éxito!');
