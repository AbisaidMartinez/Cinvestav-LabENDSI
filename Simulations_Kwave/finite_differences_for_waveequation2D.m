% Parámetros del problema
a = 0; b = 10; % Dominio en x ∈ (a, b)
c = 0; d = 10; % Dominio en y ∈ (c, d)
t_end = 3e-4; % Tiempo final
alpha = 1498; % Velocidad del sonido en el agua
m = 100; % Número de puntos en x
n = 100; % Número de puntos en y
N = 100; % Número de puntos en el tiempo
h_x = (b - a) / m; % Tamaño del paso en x
h_y = (d - c) / n; % Tamaño del paso en y
k = t_end / N; % Tamaño del paso en el tiempo
lambda_x = (k * alpha) / h_x; % Parámetro de estabilidad en x
lambda_y = (k * alpha) / h_y; % Parámetro de estabilidad en y

% Verificación de la condición CFL
if lambda_x > 1 || lambda_y > 1
    error('El método es inestable: lambda_x o lambda_y > 1');
end

% Inicialización de la matriz de solución
w = zeros(m + 1, n + 1, N + 1); % w(x, y, t)

% Funciones de condición inicial y velocidad inicial
A = 5; % Amplitud
gamma = 41943.83; % Número de onda
f = @(x, y) A * cos(gamma * sqrt((x - b/2).^2 + (y - d/2).^2)); % Condición inicial
g = @(x, y) 0; % Velocidad inicial

% Condiciones iniciales
for i = 1:m + 1
    for j = 1:n + 1
        x_i = a + (i - 1) * h_x; % Posición en x
        y_j = c + (j - 1) * h_y; % Posición en y
        w(i, j, 1) = f(x_i, y_j); % Condición inicial en t = 0
        if i > 1 && i < m + 1 && j > 1 && j < n + 1
            w(i, j, 2) = (1 - 2 * lambda_x^2 - 2 * lambda_y^2) * f(x_i, y_j) + ...
                         lambda_x^2 * (f(x_i + h_x, y_j) + f(x_i - h_x, y_j)) + ...
                         lambda_y^2 * (f(x_i, y_j + h_y) + f(x_i, y_j - h_y)) + ...
                         k * g(x_i, y_j); % Condición inicial en t = k
        end
    end
end

% Iteración en el tiempo
for p = 2:N
    for i = 2:m
        for j = 2:n
            w(i, j, p + 1) = 2 * (1 - lambda_x^2 - lambda_y^2) * w(i, j, p) + ...
                             lambda_x^2 * (w(i + 1, j, p) + w(i - 1, j, p)) + ...
                             lambda_y^2 * (w(i, j + 1, p) + w(i, j - 1, p)) - ...
                             w(i, j, p - 1);
        end
    end
end

% Discretización del espacio y tiempo
x = linspace(a, b, m + 1); % Espacio en x
y = linspace(c, d, n + 1); % Espacio en y
t = linspace(0, t_end, N + 1); % Tiempo

% Gráfica de la solución en 3D para un instante de tiempo
time_index = N + 1; % Instante de tiempo final
figure;
surf(x, y, w(:, :, time_index)'); % Transponer para coincidir con dimensiones
xlabel('Posición x (m)');
ylabel('Posición y (m)');
zlabel('Desplazamiento w(x, y, t)');
title(['Evolución de la onda en el espacio (t = ', num2str(t(time_index)), ' s)']);
shading interp;
colorbar;

gifFile = 'Finite_differences.gif';

% Animación de la evolución de la onda en el tiempo
figure;
for p = 1:N + 1
    surf(x, y, w(:, :, p)');
    xlabel('Posición x (m)');
    ylabel('Posición y (m)');
    zlabel('Desplazamiento w(x, y, t)');
    title(['Evolución de la onda en el tiempo (t = ', num2str(t(p)), ' s)']);
    shading interp;
    colorbar;
    view(90, 90);
    zlim([-A, A]); % Límites fijos para el eje z

    % Capturar el frame actual
    frame = getframe(gcf);
    img = frame2im(frame);
    [imind, cm] = rgb2ind(img, 256);
    
    % Guardar el frame en el archivo GIF
    if p == 1
        imwrite(imind, cm, gifFile, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    else
        imwrite(imind, cm, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end
    
    pause(0.1); % Pausa para la animación
end


disp(['Animación guardada como ', gifFile]);

%% Funcion gif

% function gif(filename, delayTime)
%     % Función para guardar una animación como GIF
%     % filename: Nombre del archivo GIF (por ejemplo, 'animacion.gif')
%     % delayTime: Tiempo entre frames (en segundos)
% 
%     % Verificar si el archivo ya existe
%     if exist(filename, 'file')
%         delete(filename); % Eliminar el archivo si ya existe
%     end
% 
%     % Capturar los frames de la figura actual
%     frames = getframe(gcf);
%     img = frame2im(frames);
%     [imind, cm] = rgb2ind(img, 256);
% 
%     % Guardar el primer frame
%     imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', delayTime);
% 
%     % Guardar los frames restantes
%     for i = 2:length(frames)
%         img = frame2im(frames(i));
%         [imind, cm] = rgb2ind(img, 256);
%         imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
%     end
% 
%     disp(['Animación guardada como ', filename]);
% end