function Sistema = generarSistemaElipses(M, angle_deg)
% generarSistemaElipses Genera una matriz con dos elipses superpuestas
%
%   Sistema = generarSistemaElipses(M, angle_deg)
%
%   Inputs:
%     M         - Tamaño de la matriz (ej. 216)
%     angle_deg - Ángulo de rotación en grados
%
%   Output:
%     Sistema   - Matriz MxM con la suma de las dos elipses

% Inicializar matrices
Elipse_Grande = zeros(M);
Elipse_Pequena = zeros(M);

% Parámetros de la elipse grande
a_outer = 32.75; % Semi-eje mayor
b_outer = 24.25; % Semi-eje menor
xcenter_outer = round(M / 2);
ycenter_outer = round(M / 2);

% Parámetros de la elipse pequeña
a_inner = 9.7 / 2;
b_inner = 7.43 / 2;
dx = -15;
dy = -5;

% Ángulo en radianes
theta = deg2rad(angle_deg);

% Centro de la elipse pequeña (tras rotación)
xcenter_inner = xcenter_outer + (dx * cos(theta) - dy * sin(theta));
ycenter_inner = ycenter_outer + (dx * sin(theta) + dy * cos(theta));

% Llenar las elipses
for i = 1:M
    for j = 1:M
        % --- Elipse grande ---
        pixelx_outer = (i - xcenter_outer);
        pixely_outer = (j - ycenter_outer);
        xrot_outer = pixelx_outer * cos(theta) + pixely_outer * sin(theta);
        yrot_outer = pixely_outer * cos(theta) - pixelx_outer * sin(theta);

        if (xrot_outer^2 / a_outer^2 + yrot_outer^2 / b_outer^2 <= 1)
            Elipse_Grande(M - j + 1, i) = 1;
        end

        % --- Elipse pequeña ---
        pixelx_inner = (i - xcenter_inner);
        pixely_inner = (j - ycenter_inner);
        xrot_inner = pixelx_inner * cos(theta + pi/2) + pixely_inner * sin(theta + pi/2);
        yrot_inner = pixely_inner * cos(theta + pi/2) - pixelx_inner * sin(theta + pi/2);

        if (xrot_inner^2 / a_inner^2 + yrot_inner^2 / b_inner^2 <= 1)
            Elipse_Pequena(M - j + 1, i) = 1;
        end
    end
end

% Sumar las elipses
Sistema = Elipse_Grande + Elipse_Pequena;

end
