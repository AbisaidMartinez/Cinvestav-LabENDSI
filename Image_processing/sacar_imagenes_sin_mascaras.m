% Rutas a tus carpetas
carpeta_imagenes = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\e_original_and_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\a_square';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentacion\e';
carpeta_mascaras = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador06\labels';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\a_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentacion\e_mask';
carpeta_sin_pareja = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\sin_mascara\e';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentacion\sin_mascara';

% Crear la carpeta sin_pareja si no existe
if ~exist(carpeta_sin_pareja, 'dir')
    mkdir(carpeta_sin_pareja);
end

% Obtener lista de archivos .png en ambas carpetas
archivos_imagenes = dir(fullfile(carpeta_imagenes, '*.png'));
archivos_mascaras = dir(fullfile(carpeta_mascaras, '*.png'));

% Obtener nombres base (sin extensión) de las máscaras
nombres_mascaras = erase({archivos_mascaras.name}, '.png');

% Revisar cada imagen
for k = 1:length(archivos_imagenes)
    nombre_imagen = archivos_imagenes(k).name;
    nombre_base = erase(nombre_imagen, '.png');

    % Si no está en la lista de máscaras, mover
    if ~ismember(nombre_base, nombres_mascaras)
        origen = fullfile(carpeta_imagenes, nombre_imagen);
        destino = fullfile(carpeta_sin_pareja, nombre_imagen);
        movefile(origen, destino);
        fprintf('Movida: %s -> sin_pareja\n', nombre_imagen);
    end
end
