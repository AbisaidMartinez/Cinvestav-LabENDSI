clc; clear;

% === CONFIGURACIÓN MANUAL ===
input_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\LetrasCinvestav-20250408T061707Z-001\LetrasCinvestav\E_full\E'; %'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\LetrasCinvestav-20250408T061707Z-001\LetrasCinvestav\E_full\e_oleo';%      % Cambia esto
output_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\letras_tec\e';                                 % Cambia esto
numero_inicial = 1678;                                                                                                                                      % Número desde el cual comenzar la enumeración
formato_nombre = '%04d';                                                                                                                                    % Para nombres con ceros a la izquierda (0001, 0002...)

% === EXTENSIONES VÁLIDAS ===
extensionesValidas = {'.png'};

% Obtener archivos de imagen en la carpeta de entrada
archivos = dir(input_folder);
archivos = archivos(~[archivos.isdir]); % Eliminar carpetas

% Filtrar por extensiones válidas
archivos = archivos(contains(lower({archivos.name}), extensionesValidas));

if isempty(archivos)
    disp('No se encontraron imágenes en la carpeta de entrada.');
    return;
end

% Procesar y renombrar las imágenes
contador = numero_inicial;

for i = 1:length(archivos)
    [~, ~, ext] = fileparts(archivos(i).name);
    ext = lower(ext);

    % Evitar sobrescritura: buscar siguiente nombre disponible
    while isfile(fullfile(output_folder, [sprintf(formato_nombre, contador), ext]))
        contador = contador + 1;
    end

    nuevo_nombre = [sprintf(formato_nombre, contador), ext];
    origen = fullfile(input_folder, archivos(i).name);
    destino = fullfile(output_folder, nuevo_nombre);

    % Copiar archivo renombrado
    copyfile(origen, destino);
    fprintf('Copiado: %s -> %s\n', archivos(i).name, nuevo_nombre);

    contador = contador + 1;
end

disp('✅ Proceso completado exitosamente.');
