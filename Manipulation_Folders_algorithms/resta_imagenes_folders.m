% Rutas de las carpetas
folder1 = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\e';
folder2 = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\e_discontinuity';
outputFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\labels';
identicalFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\iguales';

% Crear carpetas de salida si no existen
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
if ~exist(identicalFolder, 'dir')
    mkdir(identicalFolder);
end

% Obtener lista de archivos de la primera carpeta
imageFiles = dir(fullfile(folder1, '*.png')); % puedes cambiar la extensión si es .jpg, etc.

% Recorrer todas las imágenes
for k = 1:length(imageFiles)
    filename = imageFiles(k).name;

    % Leer imágenes
    img1 = imread(fullfile(folder1, filename));
    img2 = imread(fullfile(folder2, filename));

    % Convertir a escala de grises si es necesario
    if size(img1, 3) == 3
        img1 = rgb2gray(img1);
    end
    if size(img2, 3) == 3
        img2 = rgb2gray(img2);
    end

    % Asegurar que tienen el mismo tamaño
    if ~isequal(size(img1), size(img2))
        warning('Las imágenes %s no tienen el mismo tamaño. Se omiten.', filename);
        continue;
    end

    % Convertir a tipo double para la resta
    diffImg = imabsdiff(im2double(img1), im2double(img2));

    % Verificar si la diferencia es completamente cero
    if all(diffImg(:) == 0)
        fprintf('La imagen %s es idéntica.\n', filename);
        imwrite(img1, fullfile(identicalFolder, filename));
    else
        % Guardar la diferencia en la carpeta de salida
        imwrite(diffImg, fullfile(outputFolder, filename));
    end
end

%% Pruebas individuales

% Leer imágenes
img1 = imread('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\e\1228.png');
img2 = imread('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\e_discontinuity\1228.png');

% Convertir a escala de grises si es necesario
if size(img1, 3) == 3
    img1 = rgb2gray(img1);
end
if size(img2, 3) == 3
    img2 = rgb2gray(img2);
end

% Convertir a tipo double en [0,1]
img1 = im2double(img1);
img2 = im2double(img2);

img1 = imbinarize(img1);
img2 = imbinarize(img2);

% Calcular diferencia absoluta
diffImg = abs(img2 - img1);

% Mostrar diferencia original
figure;
subplot(1,3,1);
imshow(diffImg, []);
title('Diferencia original');

% Aplicar umbral para eliminar contorno leve
umbral = 0.9;
diffUmbral = diffImg;
diffUmbral(diffUmbral < umbral) = 0;

subplot(1,3,2);
imshow(diffUmbral, []);
title(['Diferencia con umbral (', num2str(umbral), ')']);

% (Opcional) Limitar a región de la letra
% Crear una máscara binaria desde la imagen sin discontinuidad
letraMask = img1;%imbinarize(img1);
diffFinal = diffUmbral .* letraMask;

subplot(1,3,3);
imshow(diffFinal, []);
title('Discontinuidad limpia (solo dentro de letra)');

%% Folder con thresholding (si las carpetas tienen la misma cantidad de archivos)

% Rutas
carpetaA = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\e';
carpetaB = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\e_discontinuity';
carpetaC = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\labels';
carpetaD = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\iguales';
% Crear carpetas si no existen
if ~exist(carpetaC, 'dir'), mkdir(carpetaC); end
if ~exist(carpetaD, 'dir'), mkdir(carpetaD); end

% Obtener lista de archivos
archivosA = dir(fullfile(carpetaA, '*.png'));
archivosB = dir(fullfile(carpetaB, '*.png'));

% Verificar que ambas carpetas tienen el mismo número de archivos
assert(length(archivosA) == length(archivosB), 'Las carpetas no tienen la misma cantidad de imágenes');

% Umbral para descartar contornos pequeños
umbral = 0.2;

for k = 1:length(archivosA)
    % Leer imágenes correspondientes
    imgA = imread(fullfile(carpetaA, archivosA(k).name));
    imgB = imread(fullfile(carpetaB, archivosB(k).name));

    % Convertir a escala de grises si es necesario
    if size(imgA, 3) == 3, imgA = rgb2gray(imgA); end
    if size(imgB, 3) == 3, imgB = rgb2gray(imgB); end

    % Convertir a double
    imgA = im2double(imgA);
    imgB = im2double(imgB);

    imgA = imbinarize(imgA);
    imgB = imbinarize(imgB);

    % Resta absoluta
    diffImg = abs(imgB - imgA);

    % Aplicar umbral para eliminar residuos de borde
    diffImg(diffImg < umbral) = 0;

    % Aplicar máscara de letra (solo considerar diferencias dentro de la letra)
    maskLetra = imbinarize(imgA);
    diffFinal = diffImg .* maskLetra;

    % Revisar si es una matriz de ceros (sin diferencia)
    if all(diffFinal(:) == 0)
        % Guardar en carpeta de restas cero
        imwrite(diffFinal, fullfile(carpetaD, archivosA(k).name));
        fprintf('Imagen %s: sin diferencia significativa.\n', archivosA(k).name);
    else
        % Guardar imagen resultante en carpeta de salida
        imwrite(diffFinal, fullfile(carpetaC, archivosA(k).name));
        fprintf('Imagen %s: diferencia guardada.\n', archivosA(k).name);
    end
end

%% Rutas
carpetaA = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\e';
carpetaB = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\e_discontinuity';
carpetaC = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\labels';
carpetaD = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\iguales';

% Crear carpetas si no existen
if ~exist(carpetaC, 'dir'), mkdir(carpetaC); end
if ~exist(carpetaD, 'dir'), mkdir(carpetaD); end

% Obtener listas de archivos .png
archivosA = dir(fullfile(carpetaA, '*.png'));
archivosB = dir(fullfile(carpetaB, '*.png'));

% Obtener nombres de archivos
nombresA = {archivosA.name};
nombresB = {archivosB.name};

% Encontrar nombres comunes
nombresComunes = intersect(nombresA, nombresB);

% Umbral para diferencia mínima
umbral = 0.9;

for k = 1:length(nombresComunes)
    nombre = nombresComunes{k};

    % Leer imágenes
    imgA = imread(fullfile(carpetaA, nombre));
    imgB = imread(fullfile(carpetaB, nombre));

    % Convertir a escala de grises si es necesario
    if size(imgA, 3) == 3, imgA = rgb2gray(imgA); end
    if size(imgB, 3) == 3, imgB = rgb2gray(imgB); end

    % Convertir a double
    imgA = im2double(imgA);
    imgB = im2double(imgB);

    % Resta absoluta
    diffImg = abs(imgB - imgA);

    % Aplicar umbral para eliminar residuos de borde
    diffImg(diffImg < umbral) = 0;

    % Máscara de letra
    maskLetra = imbinarize(imgA);
    diffFinal = diffImg .* maskLetra;

    % Verificar si la imagen resultante es toda ceros
    if all(diffFinal(:) == 0)
        imwrite(diffFinal, fullfile(carpetaD, nombre));
        fprintf('Imagen %s: sin diferencia significativa.\n', nombre);
    else
        imwrite(diffFinal, fullfile(carpetaC, nombre));
        fprintf('Imagen %s: diferencia guardada.\n', nombre);
    end
end
