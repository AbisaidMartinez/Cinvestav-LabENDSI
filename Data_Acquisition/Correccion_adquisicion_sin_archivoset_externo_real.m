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

%%

horizontalDelay = str2double(query(visaObj, 'HOR:DELAY:TIME?'));



%% Opcional: Parsear o usar configResponse para ajustar parámetros
% (esto depende del formato y qué quieres hacer con esa info)

% --- Continuar con configuración específica si quieres ---
% Por ejemplo, puedes usar valores específicos hardcodeados o derivados

recordLength = 10000;              % Número de puntos
sampleInterval = 4.00E-08;         % Intervalo de muestra
horizontalDelay = 7.9e-5;          % Retraso horizontal
verticalScale = 0.2;               % Escala vertical
verticalOffset = 0;                % Offset vertical
numAverages = 16;                  % Número de promedios para el filtrado

% Configuración del osciloscopio
fprintf(visaObj, 'SELECT:CH1 ON');
fprintf(visaObj, 'CH1:SCALE %f', verticalScale);
fprintf(visaObj, 'HORizontal:SCAle %e', sampleInterval * recordLength / 10);
fprintf(visaObj, 'HORizontal:POSition %e', horizontalDelay);

% Configuración de adquisición en modo promedio
fprintf(visaObj, 'ACQUIRE:MODE AVERAGE'); % Cambiar al modo "average"
fprintf(visaObj, 'ACQUIRE:NUMAVG %d', numAverages); % Número de promedios

% Número de iteraciones
numIterations = 5;

%% INICIO DEL CICLO FOR
for i = 1:numIterations
    disp(['Iteración: ', num2str(i)]);
    
    % Detener adquisición y configurar captura
    fprintf(visaObj, 'ACQUIRE:STATE STOP');
    fprintf(visaObj, 'DATA:SOURCE CH1');
    fprintf(visaObj, 'DATA:WIDTH 1');
    fprintf(visaObj, 'DATA:ENCdg ASCII');
    fprintf(visaObj, 'DATA:START 1');
    fprintf(visaObj, 'DATA:STOP %d', recordLength);
    
    % Capturar datos
    fprintf(visaObj, 'CURVE?');
    waveform = fscanf(visaObj);
    y_values = str2double(split(waveform, ','));
    
    % Ajustar valores del eje Y
    y_values = (y_values - verticalOffset) * verticalScale;
    y_values = y_values';
    
    % Calcular valores del eje X
    x_values = horizontalDelay + (0:recordLength-1) * sampleInterval;

    % Crear el nombre del archivo para esta iteración
    outputFile = sprintf('waveform_data_iter_%d.csv', i); 
    
    % Guardar datos en archivo CSV
    data = [x_values(:), y_values(:)];
    writematrix(data, outputFile);
    disp(['Datos guardados en: ', outputFile]);
    
    % Reanudar adquisición para la próxima iteración
    fprintf(visaObj, 'ACQUIRE:STATE RUN');
    
    % Pausa opcional entre iteraciones
    pause(1); % Ajustar según sea necesario
end

% Cerrar la conexión
fclose(visaObj);
delete(visaObj);
clear visaObj;

disp('Proceso completado.');