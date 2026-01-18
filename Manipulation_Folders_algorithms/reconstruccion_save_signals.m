% Ruta a la carpeta con archivos .mat
dataFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Variables\defecto';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Variables\discontinuities_signals\trainingset\b';%_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Variables\discontinuities_signals\testset\e';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Variables\kwave_handwriting_signals_without_discontinuity\e_discontinuities';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Variables\discontinuities_signals\a_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Variables\kwave_handwriting_signals_without_discontinuity\e'; 
outputFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\defecto';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_byTomo_for_Trainingset\b';%_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo_resize_tests\e';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Obtener lista de archivos .mat
files = dir(fullfile(dataFolder, '*.mat'));

for f = 1:length(files)
    % Cargar archivo
    fileName = files(f).name;
    fullPath = fullfile(dataFolder, fileName);
    load(fullPath);  % se espera que contenga: signals, z, ang, kgrid, Nx, etc.

    % Procesamiento
    amp = zeros(length(z), length(ang));
    delta_t = zeros(length(z), length(ang));
    Energy = zeros(length(z), length(ang));
    
    N_amp = [];
    N_time = [];
    N_energy = [];
    L = length(kgrid.t_array);

    for a = 1:length(ang)
        k = 1;
        for i = 1 + (a-1)*length(z) : length(z)*a
            [amp(k,a), idx] = max(abs(signals(:,i)));
            delta_t(k,a) = kgrid.t_array(idx);
            Energy(k,a) = (1/L) * trapz(kgrid.t_array, abs(signals(:,i)).^2);
            k = k + 1;
        end
        N_amp = [N_amp, abs(amp(:,a)-max(amp(:,a)))];
        N_time = [N_time, abs(delta_t(:,a)-max(delta_t(:,a)))];
        N_energy = [N_energy, abs(Energy(:,a)-max(Energy(:,a)))];
    end

    % Reconstrucción
    Phi = round(linspace(0,180,19));
    reconstruction2 = iradon(N_time, Phi, "Ram-Lak");
    reconstruction2 = reconstruction2 / max(reconstruction2, [], 'all');
    reconstruction_resized = imresize(flip(reconstruction2), [Nx, Nx]);

    % Guardar imagen
    [~, baseFileName, ~] = fileparts(fileName);
    outputImageName = fullfile(outputFolder, [baseFileName, '.png']);
    img_to_save = uint8(255 * mat2gray(reconstruction_resized));
    imwrite(img_to_save, outputImageName);

    disp(['Imagen guardada: ', outputImageName]);
end

%% Intervalos de .mat en folders

% Rutas
dataFolder = 'D:\Ellipse_signals\normal';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Variables\defecto';
outputFolder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_tests\tests\normal';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\normal';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\pruebas_modelo_deteccion';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\defecto';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Definir intervalo de archivos .mat a procesar
Nx = 224;
start_num = 301;
end_num = 325;

% Obtener lista de archivos .mat
files = dir(fullfile(dataFolder, '*.mat'));

% Obtener cuántas imágenes ya hay en la carpeta de salida
existing_imgs = dir(fullfile(outputFolder, '*.png'));
next_img_number = length(existing_imgs) + 1;

% Contador interno para las nuevas imágenes
new_img_counter = 0;

for f = 1:length(files)
    fileName = files(f).name;
    [~, baseFileName, ~] = fileparts(fileName);

    % Convertir nombre a número (e.g. '01' -> 1)
    fileNum = str2double(baseFileName);

    % Verificar si está dentro del intervalo deseado
    if isnan(fileNum) || fileNum < start_num || fileNum > end_num
        continue;
    end

    % Cargar archivo
    fullPath = fullfile(dataFolder, fileName);
    load(fullPath);  % se espera que contenga: signals, z, ang, kgrid, Nx, etc.

    % Procesamiento
    amp = zeros(length(z), length(ang));
    delta_t = zeros(length(z), length(ang));
    Energy = zeros(length(z), length(ang));

    N_amp = [];
    N_time = [];
    N_energy = [];
    L = length(kgrid.t_array);

    for a = 1:length(ang)
        k = 1;
        for i = 1 + (a-1)*length(z) : length(z)*a
            [amp(k,a), idx] = max(abs(signals(:,i)));
            delta_t(k,a) = kgrid.t_array(idx);
            Energy(k,a) = (1/L) * trapz(kgrid.t_array, abs(signals(:,i)).^2);
            k = k + 1;
        end
        N_amp = [N_amp, abs(amp(:,a) - max(amp(:,a)))];
        N_time = [N_time, abs(delta_t(:,a) - max(delta_t(:,a)))];
        N_energy = [N_energy, abs(Energy(:,a) - max(Energy(:,a)))];
    end

    % Reconstrucción
    Phi = round(linspace(0, 180, 19));
    reconstruction2 = iradon(N_time, Phi, "Ram-Lak");
    reconstruction2 = reconstruction2 / max(reconstruction2, [], 'all');
    reconstruction_resized = imresize(flip(reconstruction2), [Nx, Nx]);

    % Generar nombre secuencial de salida
    outputFileName = sprintf('%d.png', next_img_number + new_img_counter);
    outputImageName = fullfile(outputFolder, outputFileName);

    img_to_save = uint8(255 * mat2gray(reconstruction_resized));
    imwrite(img_to_save, outputImageName);

    disp(['Imagen guardada: ', outputImageName]);
    new_img_counter = new_img_counter + 1;
end
