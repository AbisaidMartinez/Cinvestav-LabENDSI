% Configuración inicial del lienzo
figure('Name', 'Lienzo con presión', 'NumberTitle', 'off');
axis([0 1 0 1]);
hold on;
set(gca, 'Color', 'black');
set(gca, 'XTick', [], 'YTick', []); % Ocultar ejes
xlim([0 1]);
ylim([0 1]);
title('Mantén presionado el clic izquierdo para dibujar. ↑ y ↓ ajustan la presión.');

% Variables globales
global brushSize pressure drawing;
brushSize = 5; % Tamaño del pincel
pressure = 0.5; % Intensidad inicial (0 a 1)
drawing = false; % Bandera para saber si se está dibujando

% Eventos del mouse y teclado
set(gcf, 'WindowButtonDownFcn', @startDrawing);
set(gcf, 'WindowButtonUpFcn', @stopDrawing);
set(gcf, 'WindowButtonMotionFcn', @draw);
set(gcf, 'WindowKeyPressFcn', @adjustPressure);

% Función para iniciar el dibujo al presionar el mouse
function startDrawing(~, ~)
    global drawing;
    drawing = true;
end

% Función para detener el dibujo al soltar el mouse
function stopDrawing(~, ~)
    global drawing;
    drawing = false;
end

% Función para dibujar mientras el mouse está presionado
function draw(~, ~)
    global brushSize pressure drawing;
    if drawing
        point = get(gca, 'CurrentPoint');
        x = point(1, 1);
        y = point(1, 2);
        
        % Color basado en la presión (negro = alta presión, blanco = baja)
        color = [1 - pressure, 1 - pressure, 1 - pressure];
        
        % Dibujar el pincel (círculo)
        rectangle('Position', [x - brushSize/200, y - brushSize/200, brushSize/100, brushSize/100], ...
            'Curvature', [1, 1], 'FaceColor', color, 'EdgeColor', 'none');
    end
end

% Función para ajustar la presión con las flechas del teclado
function adjustPressure(~, event)
    global pressure;
    if strcmp(event.Key, 'uparrow')
        pressure = min(1, pressure + 0.1); % Aumentar presión
    elseif strcmp(event.Key, 'downarrow')
        pressure = max(0, pressure - 0.1); % Disminuir presión
    end
    title(['Presión actual: ', num2str(pressure)]);
end
