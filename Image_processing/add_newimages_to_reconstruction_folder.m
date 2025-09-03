%% function batch_filtered_backprojection_incremental(input_folder, M, num_projections, output_folder)

M=216;

num_projections = 19;
input_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\a_square';
output_folder = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Reconstruction03\a';

batch_filtered_backprojection_incremental(input_folder, M, num_projections, output_folder)

function batch_filtered_backprojection_incremental(input_folder, M, num_projections, output_folder)
    % Crear la carpeta de salida si no existe
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Obtener lista de imágenes de entrada
    image_files = dir(fullfile(input_folder, '*.png'));

    % Ordenar alfabéticamente por nombre para mantener el orden
    image_files = sort_nat({image_files.name})';

    % Detectar cuántas imágenes ya existen en la carpeta de salida
    existing_files = dir(fullfile(output_folder, '*.png'));
    num_existing = length(existing_files);
    disp(['Imágenes ya procesadas: ', num2str(num_existing)]);

    % Calcular cuántas faltan por procesar
    total_input = length(image_files);
    num_to_process = total_input - num_existing;
    disp(['Imágenes nuevas por procesar: ', num2str(num_to_process)]);

    % Empezar desde donde se quedó
    start_index = num_existing + 1;
    current_number = start_index;

    for i = start_index:total_input
        img_path = fullfile(input_folder, image_files{i});
        img = imread(img_path);

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

% --- Esta función sirve para ordenar nombres como '1.png', '2.png', ..., '10.png'
function sorted = sort_nat(c)
    [~,idx] = sort(str2double(regexp(c,'\d+','match','once')));
    sorted = c(idx);
end
