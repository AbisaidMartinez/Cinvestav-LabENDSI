M=216;

num_projections = 19;
input_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database\defecto';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion02\e_original_and_discontinuity';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion02\e_original_and_discontinuity';
% 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\classification_2C\complete\b';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion02\e_original_and_discontinuity';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\a_square';
output_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\defecto';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion02\e_original_and_discontinuity_rgb';
%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\deteccion02\reconstruction_segmenter';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Reconstruction03\a';

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

batch_filtered_backprojection(input_folder, M, num_projections, output_folder);

function batch_filtered_backprojection(input_folder, M, num_projections, output_folder)
    % input_folder: carpeta con las imágenes a procesar
    % M: tamaño de las imágenes reconstruidas
    % Theta: vector de ángulos
    % output_folder: carpeta donde se guardarán las imágenes reconstruidas

    % Obtener lista de imágenes en la carpeta
    image_files = dir(fullfile(input_folder, '*.png'));

    for i = 1:length(image_files)
        img_path = fullfile(input_folder, image_files(i).name);
        img = imread(img_path);
        f = filtered_backprojection(img, M, num_projections, output_folder);
    end
end

function f = filtered_backprojection(img, M, num_projections, output_folder)
    % Theta: vector de ángulos
    % img: imagen original
    % M: tamaño de la imagen reconstruida
    % output_folder: carpeta donde se guardarán las imágenes
    Theta = round(linspace(0, 180, num_projections));
    % Obtener el sinograma
    sinogram = radon(img, Theta);
    [N, num_angles] = size(sinogram);

    % Aplicar la Transformada de Fourier a cada proyección
    sin_fft = fft(sinogram);

    % Inicializar la imagen reconstruida
    f = zeros(M);
    x_center = round(M/2);
    y_center = round(M/2);

    % Backprojection sin filtro
    for alpha = 1:num_angles
        theta_rad = deg2rad(Theta(alpha));
        Q_theta = abs(ifft(sin_fft(:, alpha))); % Proyección sin filtro
        Q_theta = Q_theta / max(Q_theta, [], "all");

        for x = 1:M
            for y = 1:M
                pixel_x = (x-x_center);
                pixel_y = (y-y_center);
                t = (x - x_center) * cos(theta_rad) + (y - y_center) * sin(theta_rad);
                s =-(x - x_center) * sin(theta_rad) + (y - y_center) * cos(theta_rad);
            
                t_index = round(s + (N / 2)); % Ajuste de índice
                if t_index >= 1 && t_index <= N
                    f(x, y) = f(x, y) + Q_theta(t_index);
                end
            end
        end
    end

    % Normalizar la imagen reconstruida
    f = f / max(f, [], "all");
    f = (pi / num_angles) * f;

    f = mat2gray(f);
    % Buscar el siguiente número disponible para guardar la imagen
    file_number = 1;
    while isfile(fullfile(output_folder, [num2str(file_number), '.png']))
        file_number = file_number + 1;
    end

    % Guardar la imagen reconstruida
    output_file = fullfile(output_folder, [num2str(file_number), '.png']);
    imwrite(f, output_file);
    disp(['Imagen guardada en: ', output_file]);
end


%% Prueba para imagenes individuales


M=216;

img = imread("736.png");

% figure;
% imshow(img, [])
%
num_projections = 19;
output_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\tests';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Reconstruction\a';

f = filtered_backprojection_ind(img, M, num_projections, output_folder);

function f = filtered_backprojection_ind(img, M, num_projections, output_folder)
    % Theta: vector de ángulos
    % img: imagen original
    % M: tamaño de la imagen reconstruida
    % output_folder: carpeta donde se guardará la imagen
    if size(img, 3) ~= 1
        img = rgb2gray(img);
    end
    Theta = round(linspace(0, 180, num_projections));
    % Obtener el sinograma
    sinogram = radon(img, Theta);
    [N, num_angles] = size(sinogram);

    % Aplicar la Transformada de Fourier a cada proyección
    sin_fft = fft(sinogram);

    % Inicializar la imagen reconstruida
    f = zeros(M);
    x_center = round(M/2);
    y_center = round(M/2);

    % Backprojection sin filtro
    for alpha = 1:num_angles
        theta_rad = deg2rad(Theta(alpha));
        Q_theta = abs(ifft(sin_fft(:, alpha))); % Proyección sin filtro
        Q_theta = Q_theta / max(Q_theta, [], "all");

        for x = 1:M
            for y = 1:M
                pixel_x = (x-x_center);
                pixel_y = (y-y_center);
                t = (x - x_center) * cos(theta_rad) + (y - y_center) * sin(theta_rad);
                s =-(x - x_center) * sin(theta_rad) + (y - y_center) * cos(theta_rad);
            
                t_index = round(s + (N / 2)); % Ajuste de índice
                if t_index >= 1 && t_index <= N
                    f(x, y) = f(x, y) + Q_theta(t_index);
                end
            end
        end
    end

    % Normalizar la imagen reconstruida
    f = f / max(f, [], "all");
    f = (pi / num_angles) * f;

    f = mat2gray(f);

    % Buscar el siguiente número disponible para guardar la imagen
    file_number = 1;
    while isfile(fullfile(output_folder, ['Pruebas', num2str(file_number), '.png']))
        file_number = file_number + 1;
    end

    % Guardar la imagen reconstruida
    output_file = fullfile(output_folder, ['Pruebas', num2str(file_number), '.png']);
    imwrite(f, output_file);
    disp(['Imagen guardada en: ', output_file]);

    figure;
    imshow(f, [])
end

%% Detecta las imagenes que ya estan y reconstruye las imagenes apartir de la numeracion asignada

M=216;

num_projections = 19;
input_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\a_square';
output_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Reconstruction03\a';

batch_filtered_backprojection_auto(input_folder, M, num_projections, output_folder);

function batch_filtered_backprojection_auto(input_folder, M, num_projections, output_folder)
    % Crear la carpeta de salida si no existe
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Obtener lista de imágenes en la carpeta de entrada
    image_files = dir(fullfile(input_folder, '*.png'));

    % Obtener numeraciones ya existentes en la carpeta de salida
    existing_files = dir(fullfile(output_folder, '*.png'));
    existing_numbers = zeros(1, length(existing_files));
    for k = 1:length(existing_files)
        [~, name, ~] = fileparts(existing_files(k).name);
        num = str2double(name);
        if ~isnan(num)
            existing_numbers(k) = num;
        end
    end

    % Usado para saber en qué número guardar la siguiente imagen
    current_number = max(existing_numbers, [], 'omitnan') + 1;

    for i = 1:length(image_files)
        img_path = fullfile(input_folder, image_files(i).name);
        img = imread(img_path);

        % Guardar con el siguiente número disponible
        f = filtered_backprojection_auto(img, M, num_projections);
        output_file = fullfile(output_folder, [num2str(current_number), '.png']);
        imwrite(f, output_file);
        disp(['Guardado: ', output_file]);
        current_number = current_number + 1;
    end
end

function f = filtered_backprojection_auto(img, M, num_projections)
    Theta = round(linspace(0, 180, num_projections));
    sinogram = radon(img, Theta);
    [N, num_angles] = size(sinogram);
    sin_fft = fft(sinogram);
    f = zeros(M);
    x_center = round(M/2);
    y_center = round(M/2);

    for alpha = 1:num_angles
        theta_rad = deg2rad(Theta(alpha));
        Q_theta = abs(ifft(sin_fft(:, alpha)));
        Q_theta = Q_theta / max(Q_theta, [], "all");

        for x = 1:M
            for y = 1:M
                t = (x - x_center) * cos(theta_rad) + (y - y_center) * sin(theta_rad);
                s =-(x - x_center) * sin(theta_rad) + (y - y_center) * cos(theta_rad);

                t_index = round(s + N/2);
                if t_index >= 1 && t_index <= N
                    f(x, y) = f(x, y) + Q_theta(t_index);
                end
            end
        end
    end

    f = f / max(f, [], "all");
    f = (pi / num_angles) * f;
    f = mat2gray(f);
end


%% Toma intervalos de imagenes

M = 216;
num_projections = 19;

input_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database\defecto';
output_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database_reconstruction\defecto';

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%%% Procesar imágenes desde la 101 hasta la 200
start_idx = 1;
end_idx = 125;

batch_filtered_backprojection_int(input_folder, M, num_projections, output_folder, start_idx, end_idx);

% function batch_filtered_backprojection_int(input_folder, M, num_projections, output_folder, start_idx, end_idx)
%     image_files = dir(fullfile(input_folder, '*.png'));
%     image_files = sort_nat({image_files.name}); % Orden natural si hay nombres tipo 'image_1.png' ... 'image_1000.png'
% 
%     % Verificar límites válidos
%     start_idx = max(start_idx, 1);
%     end_idx = min(end_idx, length(image_files));
% 
%     for i = start_idx:end_idx
%         img_path = fullfile(input_folder, image_files{i});
%         img = imread(img_path);
%         f = filtered_backprojection2(img, M, num_projections, output_folder);
%     end
% end

function batch_filtered_backprojection_int(input_folder, M, num_projections, output_folder, start_idx, end_idx)
    image_files = dir(fullfile(input_folder, '*.png'));
    image_files = sort_nat({image_files.name}); % Orden natural

    % Verificar límites válidos
    start_idx = max(start_idx, 1);
    end_idx = min(end_idx, length(image_files));
    
    % Contador fijo para sobrescribir del 1 al N
    file_counter = 1;

    for i = start_idx:end_idx
        img_path = fullfile(input_folder, image_files{i});
        img = imread(img_path);

        % Reconstrucción y sobrescritura controlada
        f = filtered_backprojection2(img, M, num_projections);

        % Guardar como 1.png, 2.png, ..., sobrescribiendo si existen
        output_file = fullfile(output_folder, [num2str(file_counter), '.png']);
        imwrite(f, output_file);
        disp(['Imagen sobrescrita en: ', output_file]);

        file_counter = file_counter + 1;
    end
end

function f = filtered_backprojection2(img, M, num_projections, output_folder)
    Theta = round(linspace(0, 180, num_projections));
    sinogram = radon(img, Theta);
    [N, num_angles] = size(sinogram);
    sin_fft = fft(sinogram);

    f = zeros(M);
    x_center = round(M/2);
    y_center = round(M/2);

    for alpha = 1:num_angles
        theta_rad = deg2rad(Theta(alpha));
        Q_theta = abs(ifft(sin_fft(:, alpha)));
        Q_theta = Q_theta / max(Q_theta, [], "all");

        for x = 1:M
            for y = 1:M
                pixel_x = (x - x_center);
                pixel_y = (y - y_center);
                t = (x - x_center) * cos(theta_rad) + (y - y_center) * sin(theta_rad);
                s =-(x - x_center) * sin(theta_rad) + (y - y_center) * cos(theta_rad);
            
                t_index = round(s + (N / 2));
                if t_index >= 1 && t_index <= N
                    f(x, y) = f(x, y) + Q_theta(t_index);
                end
            end
        end
    end

    f = f / max(f, [], "all");
    f = (pi / num_angles) * f;
    f = mat2gray(f);

    %file_number = 1;
    %while isfile(fullfile(output_folder, [num2str(file_number), '.png']))
    %    file_number = file_number + 1;
    %end

    %output_file = fullfile(output_folder, [num2str(file_number), '.png']);
    %imwrite(f, output_file);
    %disp(['Imagen guardada en: ', output_file]);
end

function sorted = sort_nat(files)
    % Ordena nombres tipo image_1, image_2, ..., image_10 de forma natural
    [~, idx] = sort_nat_internal(files);
    sorted = files(idx);
end

function [sorted, index] = sort_nat_internal(c)
    numstr = regexp(c, '\d+', 'match');
    numval = cellfun(@(x) str2double(x{end}), numstr);
    [~, index] = sort(numval);
    sorted = c(index);
end
