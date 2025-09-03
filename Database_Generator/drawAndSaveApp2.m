function drawAndSaveApp()
    % Parámetros
    canvas_size = [200, 200]; % Tamaño del lienzo
    save_path = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\e\e_recortes02';
    start_index = 1370; % Índice inicial para el nombre de archivo
    brush_mode = "solid"; % Modo de pincel inicial
    brush_thickness = randi([2, 40]); % Grosor del pincel inicial
    brush_color = 255; % Color del pincel (blanco)

    % Crear carpeta si no existe
    if ~exist(save_path, 'dir')
        mkdir(save_path);
    end

    % Crear lienzo en blanco (negro)
    canvas = zeros(canvas_size(1), canvas_size(2), 'uint8');

    % Crear la figura
    fig = figure('Name', 'Dibuja', 'NumberTitle', 'off', 'KeyPressFcn', @keyPress);
    ax = axes(fig, 'XLim', [1, canvas_size(2)], 'YLim', [1, canvas_size(1)], 'Color', 'k', 'XColor', 'none', 'YColor', 'none', 'NextPlot', 'replacechildren');
    hold(ax, 'on');
    im = imshow(canvas, 'Parent', ax);

    % Configurar interactividad del mouse
    set(fig, 'WindowButtonDownFcn', @mouseDown);
    set(fig, 'WindowButtonMotionFcn', @mouseMove);
    set(fig, 'WindowButtonUpFcn', @mouseUp);

    % Variables globales
    drawing = false;
    last_position = [];

    % Función para manejar el clic del mouse
    function mouseDown(~, ~)
        drawing = true;
        last_position = get(gca, 'CurrentPoint');
    end

    % Función para manejar el movimiento del mouse
    function mouseMove(~, ~)
        if drawing
            pos = get(gca, 'CurrentPoint');
            x = round(pos(1,1));
            y = round(pos(1,2));

            if brush_mode == "solid"
                canvas = insertShape(canvas, 'Line', [last_position(1,1), last_position(1,2), x, y], 'Color', 'white', 'LineWidth', brush_thickness);
            elseif brush_mode == "spray"
                for i = 1:10
                    dx = randi([-5, 5]);
                    dy = randi([-5, 5]);
                    x_spray = min(max(x + dx, 1), canvas_size(2));
                    y_spray = min(max(y + dy, 1), canvas_size(1));
                    canvas(y_spray, x_spray) = brush_color;
                end
            elseif brush_mode == "oil"
                canvas = insertShape(canvas, 'Line', [last_position(1,1), last_position(1,2), x, y], 'Color', 'white', 'LineWidth', brush_thickness);
                canvas = imgaussfilt(canvas, 2); % Difuminado estilo óleo
            end

            last_position = pos;
            set(im, 'CData', canvas);
        end
    end

    % Función para manejar el soltar del mouse
    function mouseUp(~, ~)
        drawing = false;
    end

    % Función para manejar eventos de teclado
    function keyPress(~, event)
        persistent index;
        if isempty(index)
            index = start_index;
        end

        switch event.Key
            case 'return' % Enter para guardar
                filename = fullfile(save_path, sprintf('%d.png', index));
                imwrite(canvas, filename);
                disp(['Imagen guardada: ', filename]);
                index = index + 1;
                canvas = zeros(canvas_size(1), canvas_size(2), 'uint8'); % Limpiar lienzo
                set(im, 'CData', canvas);
                brush_thickness = randi([2, 20]); % Cambiar grosor al iniciar nuevo dibujo

            case 'escape' % ESC para salir
                close(fig);

            case '1'
                brush_mode = "solid";
                disp('Modo de pincel: Sólido');

            case '2'
                brush_mode = "spray";
                disp('Modo de pincel: Aerógrafo');

            case '3'
                brush_mode = "oil";
                disp('Modo de pincel: Pintura al óleo');
        end
    end
end
