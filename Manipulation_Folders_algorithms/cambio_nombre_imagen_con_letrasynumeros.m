%clc; clear;

% === CONFIGURACIÓN MANUAL ===
input_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\reconstruction_rgb\b_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_byTomo_for_Trainingset_rgb\b';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo_rgb\e';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentacion04\e2';  % Cambia esto
output_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion04\e_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\reconstruction_rgb\b';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\segmentador05\e_original_and_discontinuity'; % Cambia esto
numero_inicial = 01;
formato_nombre = '%04d';
letra_inicial = 'B';  % <== Letra que quieres anteponer

extensionesValidas = {'.png'};

% Obtener archivos
archivos = dir(input_folder);
archivos = archivos(~[archivos.isdir]);
archivos = archivos(contains(lower({archivos.name}), extensionesValidas));

if isempty(archivos)
    disp('No se encontraron imágenes en la carpeta de entrada.');
    return;
end

contador = numero_inicial;

for i = 1:length(archivos)
    [~, ~, ext] = fileparts(archivos(i).name);
    ext = lower(ext);

    % Buscar nombre disponible
    while isfile(fullfile(output_folder, [letra_inicial, sprintf(formato_nombre, contador), ext]))
        contador = contador + 1;
    end

    % Generar nuevo nombre con la letra
    nuevo_nombre = [letra_inicial, sprintf(formato_nombre, contador), ext];
    origen = fullfile(input_folder, archivos(i).name);
    destino = fullfile(output_folder, nuevo_nombre);

    copyfile(origen, destino);
    fprintf('Copiado: %s -> %s\n', archivos(i).name, nuevo_nombre);

    contador = contador + 1;
end

disp('✅ Proceso completado exitosamente.');

%% Orden numero, no lexicografico

% === CONFIGURACIÓN MANUAL ===
input_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\reconstruction_rgb\a_discontinuity';
output_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion04\e_discontinuity';

numero_inicial = 01;
formato_nombre = '%04d';
letra_inicial = 'A';
extensionesValidas = {'.png'};

% Obtener archivos
archivos = dir(fullfile(input_folder, '*.png'));
archivos = archivos(~[archivos.isdir]);

if isempty(archivos)
    disp('No se encontraron imágenes en la carpeta de entrada.');
    return;
end

% === ORDEN NUMÉRICO ===
% Extraer número desde el nombre del archivo
numeros = zeros(length(archivos), 1);
for i = 1:length(archivos)
    nombre = archivos(i).name;
    numero = regexp(nombre, '\d+', 'match');
    if ~isempty(numero)
        numeros(i) = str2double(numero{end});  % Tomar el último número del nombre
    else
        numeros(i) = inf;  % Si no hay número, poner al final
    end
end

[~, orden] = sort(numeros);
archivos = archivos(orden);  % Reordenar los archivos

% === COPIA Y RENOMBRE ===
contador = numero_inicial;
for i = 1:length(archivos)
    [~, ~, ext] = fileparts(archivos(i).name);
    ext = lower(ext);

    % Buscar nombre disponible
    while isfile(fullfile(output_folder, [letra_inicial, sprintf(formato_nombre, contador), ext]))
        contador = contador + 1;
    end

    nuevo_nombre = [letra_inicial, sprintf(formato_nombre, contador), ext];
    origen = fullfile(input_folder, archivos(i).name);
    destino = fullfile(output_folder, nuevo_nombre);

    copyfile(origen, destino);
    fprintf('Copiado: %s -> %s\n', archivos(i).name, nuevo_nombre);

    contador = contador + 1;
end

disp('✅ Proceso completado exitosamente (ordenado numéricamente).');
