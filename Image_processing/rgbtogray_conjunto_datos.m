% Carpeta donde están tus imágenes
%folderPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\b_square';
folderPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentacion\e_mask'


% Obtener lista de todas las imágenes PNG (puedes cambiar *.png por *.jpg o *.tif)
imageFiles = dir(fullfile(folderPath, '*.png'));

for k = 1:length(imageFiles)
    fileName = imageFiles(k).name;
    fullPath = fullfile(folderPath, fileName);

    % Leer imagen
    img = imread(fullPath);

    % Verificar si es RGB (3 canales)
    if size(img, 3) == 3
        fprintf('Convirtiendo %s a escala de grises...\n', fileName);

        grayImg = rgb2gray(img);

        % Sobrescribir la imagen original con la versión en escala de grises
        imwrite(grayImg, fullPath);
    else
        fprintf('%s ya está en escala de grises.\n', fileName);
    end
end

disp('¡Conversión completada!');
