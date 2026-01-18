% Carpeta origen (donde están las imágenes originales)
folderPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Programas\interfaz\guide\imagenes_a_detectar';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\pruebas_modelo_deteccion';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\defecto';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion04\e_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion02\e_original_and_discontinuity_rgb';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_byTomo_for_Trainingset\a_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo_resize_tests\a';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\labels';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo03\a_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\reconstruction\b';

% Carpeta destino (donde se guardarán las imágenes redimensionadas)
outputPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Programas\interfaz\guide\imagenes_a_detectar_rgb';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction_rgb\tests';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction_rgb\defecto';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion05\discontinuities';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion02\e_original_and_discontinuity_rgb';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_byTomo_for_Trainingset_rgb\a_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo_rgb_resize\a';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\labels';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo_rgb\a_discontinuity';

% Crear carpeta destino si no existe
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

% Obtener lista de todas las imágenes PNG
imageFiles = dir(fullfile(folderPath, '*.png'));

for k = 1:length(imageFiles)
    fileName = imageFiles(k).name;
    fullPath = fullfile(folderPath, fileName);

    % Leer imagen
    img = imread(fullPath);

    % Si la imagen es RGB, convertir a gris
    if size(img, 3) ~= 3
        %fprintf('Convirtiendo %s a escala de grises...\n', fileName);
        fprintf('Convirtiendo %s a escala rgb...\n', fileName);
        img = cat(3, img, img, img); % Replica el canal gris en R, G, B
        %img = gray2rgb(img);
    end
    Value = 224;
    % Redimensionar la imagen
    imgResized = imresize(img, [Value, Value]);

    % Guardar en la carpeta de salida
    outputFile = fullfile(outputPath, fileName);
    imwrite(imgResized, outputFile);

    fprintf('Imagen %s redimensionada y guardada.\n', fileName);
end

disp('¡Todas las imágenes han sido redimensionadas y guardadas!');

%% Orden numerico

% === CONFIGURACIÓN ===
% Carpeta origen (donde están las imágenes originales)
folderPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Databases_for_publish\Database01\training_set\a_square';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Databases_for_publish\Database02\';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\e';%_discontinuity';%
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\normal';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\pruebas_modelo_deteccion';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\defecto';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion04\e_discontinuity';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion02\e_original_and_discontinuity_rgb';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_byTomo_for_Trainingset\a_discontinuity';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo_resize_tests\a';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\labels';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo03\a_discontinuity';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\reconstruction\b';

% Carpeta destino (donde se guardarán las imágenes redimensionadas)
outputPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Databases_for_publish\Database01\rgb\a_square';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Databases_for_publish\Database03\complete_rgb\e';%_discontinuity';%
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction_rgb\normal';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction_rgb\defecto';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion05\discontinuities';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion02\e_original_and_discontinuity_rgb';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_byTomo_for_Trainingset_rgb\a_discontinuity';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo_rgb_resize\a';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\labels';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo_rgb\a_discontinuity';
%folderPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\defecto';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion04\e_discontinuity';
%outputPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction_rgb\defecto';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion05\discontinuities';

% Crear carpeta de salida si no existe
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

% Obtener lista de imágenes
imageFiles = dir(fullfile(folderPath, '*.png'));
imageFiles = imageFiles(~[imageFiles.isdir]);

% === ORDEN NUMÉRICO ===
numeros = zeros(length(imageFiles), 1);
for i = 1:length(imageFiles)
    nombre = imageFiles(i).name;
    numero = regexp(nombre, '\d+', 'match');
    if ~isempty(numero)
        numeros(i) = str2double(numero{end});  % Último número del nombre
    else
        numeros(i) = inf;  % Si no hay número, poner al final
    end
end

[~, orden] = sort(numeros);
imageFiles = imageFiles(orden);  % Reordenar los archivos

% Redimensionar
Value = 224;

for k = 1:length(imageFiles)
    fileName = imageFiles(k).name;
    fullPath = fullfile(folderPath, fileName);

    % Leer imagen
    img = imread(fullPath);

    % Si es escala de grises, convertir a RGB
    if size(img, 3) ~= 3
        fprintf('Convirtiendo %s a RGB...\n', fileName);
        img = cat(3, img, img, img);
    end

    % Redimensionar la imagen
    imgResized = imresize(img, [Value, Value]);

    if ~isa(imgResized, 'uint8')
    imgResized = im2uint8(imgResized);
    end

    % Guardar en la carpeta de salida
    outputFile = fullfile(outputPath, fileName);
    imwrite(imgResized, outputFile);

    fprintf('Imagen %s redimensionada y guardada.\n', fileName);
end

disp('✅ ¡Todas las imágenes han sido redimensionadas y guardadas en orden numérico!');

%% Variables a .png

guardarVariablesComoImagenes({reconstruction}, 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction_rgb\Exp_tests', 'reconstruccion');

function guardarVariablesComoImagenes(variables, outputPath, nombre_base)
% guardarVariablesComoImagenes Guarda imágenes RGB 224x224 desde variables en memoria
%
% variables: cell array de matrices (cada una es una imagen)
% outputPath: carpeta donde guardar
% nombre_base: (opcional) prefijo del nombre, default = 'img'

    if nargin < 3
        nombre_base = 'img';
    end

    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
    end

    for k = 1:length(variables)
        img = variables{k};

        % Convertir a double si es necesario
        if ~isa(img, 'double')
            img = im2double(img);
        end

        % Convertir a RGB si es escala de grises
        if size(img, 3) ~= 3
            img = cat(3, img, img, img);
        end

        % Redimensionar a 224x224
        img_resized = imresize(img, [224, 224]);

        % Guardar imagen
        nombre_archivo = sprintf('%s_%03d.png', nombre_base, k);
        imwrite(img_resized, fullfile(outputPath, nombre_archivo));

        fprintf('✅ Imagen %s guardada.\n', nombre_archivo);
    end

    disp('📁 Todas las variables fueron guardadas como imágenes.');
end
