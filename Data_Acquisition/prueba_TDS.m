%% Script para detectar y comunicar con Tektronix TDS1012 vía GPIB
clc; clear; close all;

% 1. Listar los dispositivos VISA disponibles
disp('🔍 Buscando dispositivos VISA...')
devs = visadevlist

% Verifica que en la tabla aparezca tu GPIB (ejemplo: GPIB0::1::INSTR)
if isempty(devs)
    error('❌ No se detectaron dispositivos VISA. Revisa NI-VISA + conexión.');
end

% 2. Define la dirección del instrumento (ajusta según tu configuración)
% Por ejemplo: "GPIB0::1::INSTR" -> bus GPIB0, dirección 1
addr = "GPIB0::1::INSTR";

% 3. Crear objeto VISA y abrir comunicación
try
    osci = visadev(addr);   % Crea objeto para VISA
    disp(['✅ Conectado a: ' addr]);
catch ME
    error(['❌ Error al conectar: ' ME.message]);
end

% 4. Enviar comando estándar IEEE488 (*IDN?) para identificación
writeline(osci, "*IDN?");   % Envía comando
pause(0.5);                 % Espera respuesta
idn = readline(osci);       % Lee respuesta
disp(['📟 Instrumento detectado: ' idn]);

% 5. (Opcional) Configuración básica de adquisición
% Ejemplo: consulta la escala de tiempo
writeline(osci, "HOR:MAIN:SCALE?");
timeScale = readline(osci);
disp(['⏱ Escala de tiempo actual: ' timeScale]);

% Cierra conexión al terminar
clear osci;

%%
% Crear objeto VISA GPIB
osci = visa('ni', 'GPIB0::1::INSTR');

% Abrir conexión
fopen(osci);

% Preguntar identificación
fprintf(osci, '*IDN?');
idn = fscanf(osci);

disp(['📟 Osciloscopio detectado: ' idn]);

% Cerrar conexión
fclose(osci);
delete(osci);
clear osci;

%%

% === Configuración conexión con osciloscopio Tektronix TDS1012 ===
osci = visa('tek', 'GPIB0::1::INSTR');  % Cambiar GPIB0::1 si tu dirección es distinta

% Ajustar tamaño del buffer
%osci.InputBufferSize = 10000;   % o más, por ejemplo 20000 si quieres margen

fopen(osci);

% === Preguntar identificación del instrumento ===
fprintf(osci, '*IDN?');
idn = fscanf(osci);
disp(['📟 Conectado a: ' idn]);

% === Seleccionar canal (CH1 o CH2) ===
canal = 'CH1';  % Cambiar a 'CH2' si quieres el otro canal
fprintf(osci, [':DATA:SOURCE ' canal]);

% === Configuración para obtener datos ===
fprintf(osci, ':DATA:START 1');       % Desde el primer punto
fprintf(osci, ':DATA:STOP 2500');     % Hasta el último punto (máx en TDS1012)
fprintf(osci, ':DATA:ENC RPB');       % Codificación binaria "RPB" (rápida)
fprintf(osci, ':DATA:WIDTH 1');       % Un byte por punto

% === Leer prefactor de escala (para convertir datos a voltaje) ===
fprintf(osci, 'WFMPRE:YMULT?');  ymult = str2double(fscanf(osci));
fprintf(osci, 'WFMPRE:YZERO?');  yzero = str2double(fscanf(osci));
fprintf(osci, 'WFMPRE:YOFF?');   yoff  = str2double(fscanf(osci));
fprintf(osci, 'WFMPRE:XINCR?');  xincr = str2double(fscanf(osci));

% === Descargar la forma de onda ===
fprintf(osci, ':CURVE?');
rawData = binblockread(osci, 'int8'); % Lee los datos binarios
fread(osci, 1);  % Lectura extra (terminador)

% === Convertir a valores de voltaje ===
voltData = (rawData - yoff) * ymult + yzero;

% === Crear eje de tiempo ===
t = (0:length(voltData)-1) * xincr;

% === Graficar ===
figure;
plot(t, voltData, 'b-');
xlabel('Tiempo (s)');
ylabel('Voltaje (V)');
title(['Señal adquirida de ' canal]);
grid on;

fclose(osci);
delete(osci);
clear osci;

%% === Guardar los datos ===
save('senal_osci.mat', 't', 'voltData');   % Guardar en .mat
writematrix([t(:), voltData(:)], 'senal_osci.csv'); % Guardar en .csv

disp('✅ Señal guardada en "senal_osci.mat" y "senal_osci.csv".');

%% === Cerrar conexión ===
fclose(osci);
delete(osci);
clear osci;

%%

% Crear objeto VISA (ajusta la dirección a la tuya)
osci = visa('ni', 'GPIB0::1::INSTR');

% Ajustar tamaño del buffer
osci.InputBufferSize = 10000;   % o más, por ejemplo 20000 si quieres margen

% Abrir conexión
fopen(osci);

%% Configurar el formato de datos del osciloscopio
fprintf(osci, 'DAT:ENC RPB');   % Encoding: RPB = Signed integer, little-endian
fprintf(osci, 'DAT:WID 1');     % Data width: 1 byte
fprintf(osci, 'DAT:STAR 1');    % Start point
fprintf(osci, 'DAT:STOP 2500'); % Número de puntos (ajústalo según tu TDS)

% Solicitar los datos
fprintf(osci, 'CURVE?');

% Leer los datos binarios
rawData = binblockread(osci, 'uint8');

% Limpieza del buffer
fread(osci, 1);

% Cerrar conexión
%fclose(osci);

% Obtener escala vertical y offset
ymult = str2double(query(osci, 'WFMPRE:YMULT?'));
yzero = str2double(query(osci, 'WFMPRE:YZERO?'));
yoff  = str2double(query(osci, 'WFMPRE:YOFF?'));

% Escalar datos
voltaje = (rawData - yoff) * ymult + yzero;

% Obtener escala de tiempo
xincr = str2double(query(osci, 'WFMPRE:XINCR?'));
tiempo = (0:length(voltaje)-1) * xincr;

% Graficar
plot(tiempo, voltaje);
xlabel('Tiempo (s)');
ylabel('Voltaje (V)');
title('Señal adquirida del Tektronix TDS 1012');

%% Save variables
% Generate a unique filename with timestamp
filename = sprintf('signal_data_%s.mat', datestr(now, 'yyyymmdd_HHMMSS'));
save(filename, 'voltaje', 'tiempo');
disp(['save as ', filename]);

%% === Cerrar conexión ===
fclose(osci);
delete(osci);
clear osci;