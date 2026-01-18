% Ruta del conjunto de datos
dataPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\e_square';

% Crear un imageDatastore para recorrer las imágenes
imds = imageDatastore(dataPath, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% Inicializar variables
numImages = numel(imds.Files);
nonSquareImages = {}; % Lista de imágenes no cuadradas

% Recorrer todas las imágenes
for i = 1:numImages
    imgInfo = imfinfo(imds.Files{i}); % Obtener información de la imagen
    width = imgInfo.Width;
    height = imgInfo.Height;

    % Verificar si la imagen no es cuadrada
    if width ~= height
        fprintf('Imagen no cuadrada encontrada: %s (%d x %d)\n', imds.Files{i}, width, height);
        nonSquareImages{end+1} = imds.Files{i}; %#ok<AGROW> % Guardar ruta
    end
end

% Mostrar resultados finales
if isempty(nonSquareImages)
    disp('✅ Todas las imágenes son cuadradas.');
else
    disp('❌ Se encontraron imágenes no cuadradas:');
    disp(nonSquareImages);
end



%info = imfinfo('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\a_square\28.png');
%disp([info.Width, info.Height]);
