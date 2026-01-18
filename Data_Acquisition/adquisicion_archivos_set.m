%% CONFIGURACIÓN INICIAL ARCHIVO .SET
instrreset;
oscilloscopeAddress = 'USB::0x0699::0x0410::C020937::INSTR';
visaObj = visadev(oscilloscopeAddress);  % Ya no necesitas fopen

% Leer y enviar los comandos del archivo .set
archivo = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\DataSheet\señales_Experimentales\Ellipse(07_04_2025)\Ellipse_with_discontinuity\signals_complete\tek0000.set';
fid = fopen(archivo, 'r');
if fid == -1
    error('No se pudo abrir el archivo .set');
end

while ~feof(fid)
    linea = strtrim(fgets(fid));  % Leer cada línea y quitar espacios
    if ~isempty(linea)
        try
            writeline(visaObj, linea);  % Enviar el comando usando visadev
            pause(0.05);                % Pequeña pausa para estabilidad
        catch ME
            fprintf('Error al enviar: %s\n', linea);
            disp(ME.message);
        end
    end
end
fclose(fid);

% Puedes continuar con la adquisición o configuración adicional aquí
disp('Todos los comandos del archivo .set fueron enviados con éxito.');

disp('Enviando parametros ...')
% Esperar un momento después de enviar la configuración
pause(2);

% Obtener parámetros necesarios desde el osciloscopio
recordLength      = str2double(query(visaObj, 'HOR:RECO?'));
verticalOffset    = str2double(query(visaObj, 'CH1:OFFSET?'));
verticalScale     = str2double(query(visaObj, 'CH1:SCALE?'));
horizontalDelay   = str2double(query(visaObj, 'HOR:DELAY:TIME?'));
sampleInterval    = str2double(query(visaObj, 'HOR:MAIN:SAMPLERATE?'));
sampleInterval    = 1 / sampleInterval;  % Convertir frecuencia de muestreo a intervalo

% Número de iteraciones
numIterations = 5;
disp('Parametros obtenidos con exito')
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

%% FINALIZAR CONEXIÓN
fclose(visaObj);
delete(visaObj);
clear visaObj;

disp('Proceso completado.');