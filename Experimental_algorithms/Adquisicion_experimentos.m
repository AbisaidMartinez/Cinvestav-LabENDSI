clc;
clear;

%% CONFIGURACIÓN INICIAL OSCILOSCOPIO
instrreset;
oscilloscopeAddress = 'USB::0x0699::0x0410::C020937::INSTR';
visaObj = visadev(oscilloscopeAddress);

% Cargar archivo .SET para configuración
archivo = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\Osciloscopio\tek0000.set';%'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\DataSheet\señales_Experimentales\Ellipse(07_04_2025)\Ellipse_with_discontinuity\signals_complete\tek0000.set';  % <<-- CAMBIA ESTA RUTA
fid = fopen(archivo, 'r');
if fid == -1
    error('No se pudo abrir el archivo .set');
end
while ~feof(fid)
    linea = strtrim(fgets(fid));
    if ~isempty(linea)
        try
            writeline(visaObj, linea);
            pause(0.05);
        catch ME
            fprintf('Error al enviar: %s\n', linea);
            disp(ME.message);
        end
    end
end
fclose(fid);
pause(2);

% Obtener parámetros del osciloscopio
recordLength    = str2double(query(visaObj, 'HOR:RECO?'));
verticalOffset  = str2double(query(visaObj, 'CH1:OFFSET?'));
verticalScale   = str2double(query(visaObj, 'CH1:SCALE?'));
horizontalDelay = str2double(query(visaObj, 'HOR:DELAY:TIME?'));
sampleRate      = str2double(query(visaObj, 'HOR:MAIN:SAMPLERATE?'));
sampleInterval  = 1 / sampleRate;
% Configuración de adquisición en modo promedio
%fprintf(visaObj, 'ACQUIRE:MODE AVERAGE'); % Cambiar al modo "average"
acqMode = query(visaObj, 'ACQ:MODE?');
%numavg = query(visaObj, 'ACQ:NUMAVG?');
disp(['Modo de adquisición: ', acqMode]);
fprintf(visaObj, 'CH1:BANDWIDTH 1E6'); % Limitar a 5 MHz
fprintf(visaObj, 'ACQUIRE:NUMAVG 64'); % Aumentar a 64 promedios
fprintf(visaObj, 'TRIGGER:A:LEVEL -80E-3'); % Nivel de disparo a -80 mV
%% CONFIGURACIÓN INICIAL SIN ARCHIVO .SET (consulta directa con SET?)

instrreset;
oscilloscopeAddress = 'USB::0x0699::0x0410::C020937::INSTR';
visaObj = visadev(oscilloscopeAddress);  % Abre la conexión automáticamente

% Consultar configuración actual del osciloscopio con SET?
writeline(visaObj, 'SET?');
configResponse = readline(visaObj);

% Mostrar la configuración en consola (puedes guardarla o procesarla)
disp('Configuración actual obtenida del osciloscopio (SET?):');
disp(configResponse);

recordLength    = str2double(query(visaObj, 'HOR:RECO?'));
verticalOffset  = str2double(query(visaObj, 'CH1:OFFSET?'));
verticalScale   = str2double(query(visaObj, 'CH1:SCALE?'));
horizontalDelay = str2double(query(visaObj, 'HOR:DELAY:TIME?'));
sampleRate      = str2double(query(visaObj, 'HOR:MAIN:SAMPLERATE?'));
sampleInterval  = 1 / sampleRate;

% Configuración del osciloscopio
fprintf(visaObj, 'SELECT:CH1 ON');
fprintf(visaObj, 'CH1:SCALE?'); %f', verticalScale);
fprintf(visaObj, 'HORizontal:SCAle?'); %e', sampleInterval * recordLength / 10);
fprintf(visaObj, 'HORizontal:POSition?'); %e', horizontalDelay);
fprintf(visaObj, 'PERSISTENCE ON');

% Configuración de adquisición en modo promedio
%fprintf(visaObj, 'ACQUIRE:MODE AVERAGE'); % Cambiar al modo "average"
%fprintf(visaObj, 'ACQUIRE:NUMAVG %d', numAverages); % Número de promedios


%% CONFIGURACIÓN INICIAL ROBOT
steps_per_mm = 200 / 1.2;
puerto_xy = "COM7";
baudrate = 9600;
num_steps = 10;

try
    controller_xy = serialport(puerto_xy, baudrate, 'Timeout', 10);
    configureTerminator(controller_xy, 'CR');
    pause(2);
    disp('✅ Conexión establecida correctamente.');
catch ME
    error(['❌ Error al conectar con el controlador: ', ME.message]);
end

writeline(controller_xy, 'N');
disp('📍 Ceros definidos para X e Y.');

writeline(controller_xy, 'S1M1000');
writeline(controller_xy, 'S2M1000');
pause(0.5);

x = linspace(0.0, 0.0, num_steps);
y = linspace(0.00, 0.025, num_steps);
positions = [x; y]';
positions_mm = positions * 1000;
positions_steps = round(positions_mm * steps_per_mm);
initial_steps = positions_steps(1, :);

%% INICIAR MOVIMIENTO
while true
    resp = input('¿Deseas iniciar el movimiento? (s/n): ', 's');
    if lower(resp) ~= 's'
        disp('👋 Finalizando...');
        break;
    end

    disp('▶️ Iniciando secuencia de movimiento...');

    % Buscar archivos previos para continuar numeración
    files = dir('signal*.csv');
    lastIndex = 0;
    if ~isempty(files)
        % Extraer el número más alto usado
        numbers = regexp({files.name}, 'signal(\d+)\.csv', 'tokens');
        numbers = cellfun(@(x) str2double(x{1}), numbers);
        lastIndex = max(numbers);
    end

    for i = 1:size(positions_steps, 1)
        steps_x = positions_steps(i, 1);
        steps_y = positions_steps(i, 2);
        command = sprintf('F,C,IA1M%d,IA2M%d,R', steps_x, steps_y);
        writeline(controller_xy, command);
        pause(0.5);

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

       % ADQUISICIÓN DE SEÑAL DESDE OSCILOSCOPIO
        % Detener adquisición y configurar captura

        fprintf(visaObj, 'ACQUIRE:STATE?');% STOP');
        fprintf(visaObj, 'DATA:SOURCE CH1');
        fprintf(visaObj, 'TRIGger:A:SETHold:DATa?')
        fprintf(visaObj, 'DATA:WIDTH?');
        %fprintf(visaObj, 'DATA:DELAY?');
        fprintf(visaObj, 'DATA:ENCdg?');% ASCII');
        fprintf(visaObj, 'DATA:START?');
        fprintf(visaObj, 'DATA:STOP?'); %d', recordLength);
        fprintf(visaObj, 'CH1:BANDWIDTH?');
        bw = fscanf(visaObj);

        fprintf(visaObj, 'CURVE?');
        waveform = fscanf(visaObj);
        y_values = str2double(split(waveform, ','));
        y_values = (y_values - verticalOffset) * verticalScale + verticalOffset;
        %y_values = y_values';
        y_processed = wdenoise(y_values, 9, 'Wavelet', 'sym4', NoiseEstimate="LevelIndependent");

        x_values = horizontalDelay + (0:recordLength-1) * sampleInterval;

        % Guardar señal con nombre único
        outputFile = sprintf('signal%d.csv', lastIndex + i);
        writematrix([x_values(:), y_values(:)], outputFile);
        disp(['📉 Señal guardada en: ', outputFile]);

        figure;
        plot(x_values, y_processed)%y_values)
        title(['señal ', num2str(lastIndex + i)])
        
        % Reanudar adquisición (opcional)
        fprintf(visaObj, 'ACQUIRE:STATE RUN');
        pause(3);
    end

    % Regresar a la posición inicial
    command = sprintf('F,C,IA1M%d,IA2M%d,R', initial_steps(1), initial_steps(2));
    writeline(controller_xy, command);
    pause(0.5);
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

%% FINALIZACIÓN
clear controller_xy;

fclose(visaObj);
delete(visaObj);
clear visaObj;
disp('✔️ Todo el proceso fue completado.');
