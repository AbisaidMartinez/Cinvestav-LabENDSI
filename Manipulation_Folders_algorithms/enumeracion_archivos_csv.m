clc; clear;

% Seleccionar la carpeta con los archivos .csv
ruta = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\DataSheet\signals_reconstruction';%uigetdir(pwd, 'Selecciona la carpeta con los archivos CSV');

if ruta == 0
    disp('No se seleccionó ninguna carpeta.');
    return;
end

% Obtener la lista de archivos .csv
archivos = dir(fullfile(ruta, '*.csv'));

% Verificar si hay archivos CSV
if isempty(archivos)
    disp('No se encontraron archivos CSV en el directorio.');
    return;
end

% Pedir al usuario el número inicial para renombrar
numeroInicio = input('Introduce el número desde el cual deseas empezar la numeración: ');

% Renombrar los archivos
for i = 1:length(archivos)
    % Obtener nombre y extensión
    [~, ~, ext] = fileparts(archivos(i).name);
    
    % Crear nuevo nombre (Ejemplo: Archivo_10.csv, Archivo_11.csv, ...)
    nuevoNombre = fullfile(ruta, sprintf('tek0%d%s', numeroInicio + i - 1, ext));
    
    % Ruta original
    rutaOriginal = fullfile(ruta, archivos(i).name);
    
    % Verificar si el nombre ya es el esperado
    if strcmp(rutaOriginal, nuevoNombre)
        fprintf('El archivo %s ya tiene el nombre correcto.\n', archivos(i).name);
        continue; % Saltar este archivo
    end

    % Renombrar el archivo
    movefile(rutaOriginal, nuevoNombre);
    fprintf('Renombrado: %s -> %s\n', archivos(i).name, nuevoNombre);
end

disp('Proceso completado.');
