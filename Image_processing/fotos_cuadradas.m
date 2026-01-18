%% CONVERSION DE IMAGENES .PNG TO .JPG

% Directorio donde están las imágenes
inputFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\a\a_recortes';
outputFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\a_square';

% Crear la carpeta de salida si no existe
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

vet_files=dir(fullfile(inputFolder, '*.png'));

% Calidad del JPEG (100 es máxima calidad)
QF = 100;

for i=1:length(vet_files)

    inputFullFileName = fullfile(inputFolder, vet_files(i).name);
    
    thisImage = imread(inputFullFileName);

    % Crear el nombre del archivo de salida
    [~, name, ~] = fileparts(vet_files(i).name); % Obtener el nombre sin extensión
    outputFullFileName = fullfile(outputFolder, [name, '.jpg']); % Cambiar extensión a .jpg
    
    % Guardar la imagen en formato JPEG con la calidad especificada
    imwrite(thisImage, outputFullFileName, 'Quality', QF);

    % Mostrar progreso
    fprintf('Procesada: %s\n', vet_files(i).name);
end

disp('¡Proceso completado!');

%% CONVERSION DE IMAGENES CUADRADAS (216X216)

% Directorio donde están las imágenes
inputFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\e\e_recortes03';
outputFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\e_square';

% Crear la carpeta de salida si no existe
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Obtener la lista de archivos PNG en la carpeta
archivos = dir(fullfile(inputFolder, '*.png'));

% Tamaño deseado
nuevoTamano = [172, 172];

% Procesar cada imagen
for i = 1:length(archivos)
    % Cargar la imagen
    img = imread(fullfile(inputFolder, archivos(i).name));

    [X, Y, Z] = size(img);
    if Z ~= 1
    img = rgb2gray(img);
    % else
    %     img = im2gray(img);
    end

    [X, Y] = size(img);
    Imagen = zeros(216, 216);
    
    % for x=1:X
    %     for y=1:Y
    %         if img(x,y) ~= 0
    %             img(x,y) = 255;
    %         end
    %     end
    % end
    
    %img = imbinarize(img);

    % Redimensionar la imagen
    img_resized = imresize(img, nuevoTamano);
    
    % Obtener las coordenadas para centrar la imagen
    startX = floor((216 - 172) / 2) + 1;
    startY = floor((216 - 172) / 2) + 1;

    % Insertar la imagen en el centro
    Imagen(startX:startX+171, startY:startY+171) = img_resized;

    % Guardar la imagen redimensionada
    nombreSalida = fullfile(outputFolder, archivos(i).name);
    imwrite(Imagen, nombreSalida);
    
    % Mostrar progreso
    fprintf('Procesada: %s\n', archivos(i).name);
end

disp('¡Proceso completado!');

%% PRUEBA DE IMAGENES INDIVIDUALES

% Leer la imagen mat2gray
Imagen = zeros(216, 216);
% C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\test.png
img = B;%imread('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\a\a_recortes03\1248.png');%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Reconstruction\a\Reconstructed_Image_1.png');

% figure;
% imshow(img, []);
[X, Y, Z] = size(img);
if Z ~= 1
    img = rgb2gray(img);
end

% SE = strel('square', 3);
% SE.Neighborhood;

%[X, Y] = size(img);

% for x=1:X
%     for y=1:Y
%         if img(x,y) ~= 0
%             img(x,y) = 255;
%         end
%     end
% end

%img = imbinarize(img);

img = imresize(img, [150, 150]);%[172, 172]);

% Obtener las coordenadas para centrar la imagen
startX = floor((216 - 150) / 2) + 1;
startY = floor((216 - 150) / 2) + 1;

%img = imdilate(img, SE);
%img = imopen(img, SE);
%img = imclose(img, SE);
%img = imerode(img, SE);


% Insertar la imagen en el centro
Imagen(startX:startX+149, startY:startY+149) = img;

% figure;
% imshow(Imagen, []);
%title('Letter: b')

% Guardar la imagen procesada
outputPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\B.png';
imwrite(mat2gray(Imagen), outputPath);

disp(['Imagen guardada en: ', outputPath]);

%% Proceso por intervalos

% Ruta de la carpeta con las imágenes
inputFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\a\a_recortes02';
outputFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\a_square';

% Crear la carpeta de salida si no existe
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Obtener la lista de imágenes en la carpeta
imageFiles = dir(fullfile(inputFolder, '*.png')); % Cambia la extensión si necesitas otro formato

% Rango de imágenes a procesar (por ejemplo, 1260 a 1265)
inicio = 436;
fin = 442;

for i = 1:length(imageFiles)
    % Obtener el número de la imagen desde el nombre del archivo
    [~, name, ~] = fileparts(imageFiles(i).name);
    imageNumber = str2double(name);
    
    % Verificar si la imagen está dentro del rango deseado
    if imageNumber >= inicio && imageNumber <= fin
        % Leer la imagen
        img = imread(fullfile(inputFolder, imageFiles(i).name));
        [X, Y, Z] = size(img);
        if Z ~= 1
            img = rgb2gray(img);
        end
        
        % Redimensionar la imagen
        img = imresize(img, [172, 172]);
        
        % Crear una matriz negra de 216x216
        Imagen = zeros(216, 216);
        
        % Coordenadas para centrar la imagen
        startX = floor((216 - 172) / 2) + 1;
        startY = floor((216 - 172) / 2) + 1;
        
        % Insertar la imagen redimensionada
        Imagen(startX:startX+171, startY:startY+171) = img;
        
        % Guardar la imagen procesada
        outputFile = fullfile(outputFolder, [name, '.png']);
        imwrite(mat2gray(Imagen), outputFile);
        
        disp(['Imagen guardada: ', outputFile]);
    end
end

disp('Proceso finalizado.');


