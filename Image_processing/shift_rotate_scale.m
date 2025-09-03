%A = shift_rotate_scale(ellipse_mask, 0, 0, 0, 3);

function transformed_image = shift_rotate_scale(image, shift_x, shift_y, angle, scale_factor)
    % Función que aplica desplazamiento, rotación y escalado a una imagen manteniendo su posición.
    %
    % Parámetros:
    % image         - Imagen de entrada en formato matriz.
    % shift_x       - Desplazamiento en el eje X.
    % shift_y       - Desplazamiento en el eje Y.
    % angle         - Ángulo de rotación en grados.
    % scale_factor  - Factor de escala (1 = mismo tamaño, >1 aumenta, <1 reduce).
    %
    % Retorna:
    % transformed_image - Imagen transformada.

    % Obtener tamaño original de la imagen
    [rows, cols] = size(image);

    % Calcular el centro de la imagen
    center_x = cols / 2;
    center_y = rows / 2;

    % 1. Matriz de transformación para el desplazamiento
    T_shift = affine2d([1 0 0; 0 1 0; shift_x shift_y 1]);

    % 2. Matriz de transformación para la rotación alrededor del centro
    angle_rad = deg2rad(angle);
    T_rotate = affine2d([cos(angle_rad) -sin(angle_rad) 0; 
                         sin(angle_rad)  cos(angle_rad) 0; 
                         (1 - cos(angle_rad)) * center_x + sin(angle_rad) * center_y, ...
                         (1 - cos(angle_rad)) * center_y - sin(angle_rad) * center_x, 1]);

    % 3. Matriz de transformación para el escalado respecto al centro
    T_scale = affine2d([scale_factor 0 0; 0 scale_factor 0; ...
                        (1 - scale_factor) * center_x, (1 - scale_factor) * center_y, 1]);

    % Aplicar las transformaciones en orden: desplazamiento → escalado → rotación
    image_shifted = imwarp(image, T_shift, 'OutputView', imref2d(size(image)));
    image_scaled = imwarp(image_shifted, T_scale, 'OutputView', imref2d(size(image)));
    transformed_image = imwarp(image_scaled, T_rotate, 'OutputView', imref2d(size(image)));

    % Mostrar resultados
    figure;
    subplot(1,4,1), imshow(image), title('Imagen Original');
    subplot(1,4,2), imshow(image_shifted), title('Desplazada');
    subplot(1,4,3), imshow(image_scaled), title('Escalada');
    subplot(1,4,4), imshow(transformed_image), title('Rotada');
end
