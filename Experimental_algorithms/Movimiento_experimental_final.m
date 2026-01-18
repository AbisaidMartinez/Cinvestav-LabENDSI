clc;
clear;

%% Configuración Inicial
% Parámetros
steps_per_mm = 200 / 1.2; % Pasos por milímetro
puerto_xy = "COM7";
baudrate = 9600;
num_steps = 30;

% Intentar conectar
try
    controller_xy = serialport(puerto_xy, baudrate, 'Timeout', 10);
    configureTerminator(controller_xy, 'CR');
    pause(2); % Espera para estabilizar
    disp('✅ Conexión establecida correctamente.');
catch ME
    error(['❌ Error al conectar con el controlador: ', ME.message]);
end

% Establecer ceros
writeline(controller_xy, 'N'); % Cero en posición actual
disp('📍 Ceros definidos para X e Y.');

% Establecer velocidades (puedes ajustar)
writeline(controller_xy, 'S1M1000'); % Velocidad eje X
writeline(controller_xy, 'S2M1000'); % Velocidad eje Y
pause(0.5);

% Movimiento predefinido (solo eje Y)
x = linspace(0.0, 0.0, num_steps);         % Mantener X en 0
y = linspace(0.00, 0.075, num_steps);     % Movimiento en Y
positions = [x; y]';
positions_mm = positions * 1000;
positions_steps = round(positions_mm * steps_per_mm);
initial_steps = positions_steps(1, :);

%% Bucle de ejecución controlado por el usuario
while true
    resp = input('¿Deseas iniciar el movimiento? (s/n): ', 's');
    if lower(resp) ~= 's'
        disp('👋 Finalizando...');
        break;
    end

    disp('▶️ Iniciando secuencia de movimiento...');

    for i = 1:size(positions_steps, 1)
        steps_x = positions_steps(i, 1);
        steps_y = positions_steps(i, 2);
        command = sprintf('F,C,IA1M%d,IA2M%d,R', steps_x, steps_y);
        writeline(controller_xy, command);
        pause(0.5); % Dejar que el controlador procese

        % Esperar hasta alcanzar la posición deseada
        while true
            pause(1);
            writeline(controller_xy, 'X');
            pos_x = str2double(readline(controller_xy));
            writeline(controller_xy, 'Y');
            pos_y = str2double(readline(controller_xy));

            if pos_x == steps_x && pos_y == steps_y
                disp(['✅ Posición alcanzada: X=', num2str(pos_x), ', Y=', num2str(pos_y)]);
                break;
            else
                disp('⏳ Esperando a que finalice el movimiento...');
            end
        end
    end

    % Regresar a la posición inicial
    command = sprintf('F,C,IA1M%d,IA2M%d,R', initial_steps(1), initial_steps(2));
    writeline(controller_xy, command);
    pause(0.5);

    % Confirmar retorno
    while true
        pause(1);
        writeline(controller_xy, 'X');
        pos_x = str2double(readline(controller_xy));
        writeline(controller_xy, 'Y');
        pos_y = str2double(readline(controller_xy));

        if pos_x == initial_steps(1) && pos_y == initial_steps(2)
            disp('🏁 Retornado a posición inicial.');
            break;
        else
            disp('↩️ Retornando...');
        end
    end
end

%% Finalizar
clear controller_xy;
disp('✔️ Programa finalizado.');
