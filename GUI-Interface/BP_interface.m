function varargout = BP_interface(varargin)
% BP_INTERFACE MATLAB code for BP_interface.fig
%      BP_INTERFACE, by itself, creates a new BP_INTERFACE or raises the existing
%      singleton*.
%
%      H = BP_INTERFACE returns the handle to a new BP_INTERFACE or the handle to
%      the existing singleton*.
%
%      BP_INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BP_INTERFACE.M with the given input arguments.
%
%      BP_INTERFACE('Property','Value',...) creates a new BP_INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BP_interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BP_interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BP_interface

% Last Modified by GUIDE v2.5 12-Oct-2025 00:07:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BP_interface_OpeningFcn, ...
                   'gui_OutputFcn',  @BP_interface_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BP_interface is made visible.
function BP_interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BP_interface (see VARARGIN)

% imagen sobre botones de movimiento 
img_up = imresize(imread('up.jpg'), [25 25]);
img_down = imresize(imread('down.jpg'), [25 25]);
img_left = imresize(imread('left.jpg'), [25 25]);
img_right = imresize(imread('right.jpg'), [25 25]);

img_CW = imresize(imread('CW.jpg'), [25 25]);
img_CCW = imresize(imread('CCW.jpg'), [25 25]);
img_folder = imresize(imread('foldr.jpg'), [25 25]);

% Asignacion xy
set(handles.upxy_bottom, 'CData', img_up);
set(handles.downxy_bottom, 'CData', img_down);
set(handles.leftxy_bottom, 'CData', img_left);
set(handles.rightxy_bottom, 'CData', img_right);

% Asignacion z
set(handles.upz_bottom, 'CData', img_up);
set(handles.downz_bottom, 'CData', img_down);

% Asignacion rot
set(handles.z_rot_right, 'CData', img_CCW);
set(handles.z_rot_left, 'CData', img_CW);

set(handles.pendulum_rot_right, 'CData', img_CCW);
set(handles.pendulum_rot_left, 'CData', img_CW);

set(handles.path_bottom, 'CData', img_folder);
set(handles.path_button02, 'CData', img_folder);
set(handles.file_save, 'CData', img_folder);

% Crear imagen negra de 256x256 píxeles
imagenNegra = zeros(216, 216);  % Imagen completamente negra

% Mostrarla en el axes (Reconstrucciones)
axes(handles.Time_reconstruction);         % Establecer el eje activo
imshow(imagenNegra);               % Mostrar imagen negra

axes(handles.time_proj);         % Establecer el eje activo
% axes(handles.time_proj);
plot(0,0)
%imshow(imresize(imread('energy_projections.jpg'), [512 1000]));               % Mostrar imagen negra
 
% axes(handles.Energy_reconstruction);         % Establecer el eje activo
% imshow(imagenNegra);               % Mostrar imagen negra

% Original
% matriz de 216x216, con 0° de rotación
Sistema = SistemaElipses(216, 0);
axes(handles.Original_image)
imshow(Sistema, [])

axes(handles.signals);
plot(0,0)
xlim([0,90e-6])
ylim([-10, 10])
% Choose default command line output for BP_interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BP_interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BP_interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in upxy_bottom.
function upxy_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to upxy_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200 / 1.2;
puerto_xy = sprintf('COM%s', get(handles.COM03, 'String'));
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));

% Configurar comunicación serial
s1 = serialport(puerto_xy, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_y = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_y ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I2M%d,R^', -steps_y);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
          posicionY=positionY+handles.step.Value;
         logMessage(handles, ["Posicion en Y:",posicionY , "mm"]);

    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;

% --- Executes on button press in rightxy_bottom.
function rightxy_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to rightxy_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200 / 1.2;
puerto_xy = sprintf('COM%s', get(handles.COM03, 'String'));
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));

% Configurar comunicación serial
s1 = serialport(puerto_xy, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_x = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_x ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I1M%d,R^', -steps_x);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
          posicionX=positionX+handles.step.Value;
         logMessage(handles, ["Posicion en Y:",posicionX , "mm"]);

    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;


% --- Executes on button press in downxy_bottom.
function downxy_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to downxy_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200 / 1.2;
puerto_xy = sprintf('COM%s', get(handles.COM03, 'String'));
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));

% Configurar comunicación serial
s1 = serialport(puerto_xy, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_y = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_y ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I2M%d,R^', steps_y);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
          posicionY=positionY+handles.step.Value;
         logMessage(handles, ["Posicion en Y:",posicionY , "mm"]);

    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;

% --- Executes on button press in leftxy_bottom.
function leftxy_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to leftxy_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200 / 1.2;
puerto_xy = sprintf('COM%s', get(handles.COM03, 'String'));
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));

% Configurar comunicación serial
s1 = serialport(puerto_xy, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_x = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_x ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I1M%d,R^', steps_x);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
          posicionX=positionX+handles.step.Value;
         logMessage(handles, ["Posicion en X:",posicionX , "mm"]);

    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;

% --- Executes on button press in downz_bottom.
function downz_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to downz_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200 / 1.2; % Pasos por milímetro

Controller01 = get(handles.COM01, 'string');
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));

% Configurar comunicación serial
com=sprintf("COM%s",Controller01);
s1 = serialport(com, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_z = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_z ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I1M%d,R^', steps_z);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
                posicionZ=positionZ+handles.step.Value;
         logMessage(handles, ["Posicion en Z:",posicionZ , "mm"]);
    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;


% --- Executes on button press in upz_bottom.
function upz_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to upz_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200 / 1.2; % Pasos por milímetro

Controller01 = get(handles.COM01, 'string');
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));

% Configurar comunicación serial
com=sprintf("COM%s",Controller01);
s1 = serialport(com, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_z = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_z ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I1M%d,R^', -steps_z);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
                posicionZ=positionZ+handles.step.Value;
         logMessage(handles, ["Posicion en Z:",posicionZ , "mm"]);
    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;


% --- Executes on button press in pendulum_rot_right.
function pendulum_rot_right_Callback(hObject, eventdata, handles)
% hObject    handle to pendulum_rot_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200/6; % Pasos por milímetro
% Configurar comunicación serial
Controller02 = get(handles.COM02, 'string');
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));

% Configurar comunicación serial
com=sprintf("COM%s", Controller02);
s1 = serialport(com, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_z = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_z ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I1M%d,R^', steps_z);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;

% --- Executes on button press in z_rot_right.
function z_rot_right_Callback(hObject, eventdata, handles)
% hObject    handle to z_rot_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200 / 6; % Pasos por milímetro

Controller01 = get(handles.COM01, 'string');
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));

% Configurar comunicación serial
com=sprintf("COM%s", Controller01);
s1 = serialport(com, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_z = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_z ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I2M%d,R^', -steps_z);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;


% --- Executes on button press in pendulum_rot_left.
function pendulum_rot_left_Callback(hObject, eventdata, handles)
% hObject    handle to pendulum_rot_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200/6; % Pasos por milímetro
% Configurar comunicación serial
Controller02 = get(handles.COM02, 'string');
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));


% Configurar comunicación serial
com=sprintf("COM%s", Controller02);
s1 = serialport(com, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_z = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_z ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I1M%d,R^', -steps_z);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;

% --- Executes on button press in z_rot_left.
function z_rot_left_Callback(hObject, eventdata, handles)
% hObject    handle to z_rot_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

steps_per_mm = 200 / 6; % Pasos por milímetro

Controller01 = get(handles.COM01, 'string');
baudrate = str2double(get(handles.Bits, 'String'));
mm_to_move = str2double(get(handles.step_size, 'String'));

% Configurar comunicación serial
com=sprintf("COM%s", Controller01);
s1 = serialport(com, baudrate); % Puerto para el controlador
configureTerminator(s1, 'CR'); % Terminador Carriage Return
s1.Timeout = 5; % Tiempo de espera
steps_z = round(mm_to_move*steps_per_mm);
% Verificar si los pasos a mover son diferentes
if steps_z ~= 0
    % Generar comando para mover el motor a la nueva posición
    command = sprintf('F,C,I2M%d,R', steps_z);
    logMessage(handles, ['Enviando comando: ', command]);
    writeline(s1, command);
    
    % Leer respuesta
    try
        response = readline(s1);
        logMessage(handles, ['Respuesta del controlador: ', response]);
    catch
        logMessage(handles, 'No se recibió respuesta del controlador.');
    end
else
    logMessage(handles, 'Cero movimiento.');
end
clear s1;

function Folder_name_Callback(hObject, eventdata, handles)
% hObject    handle to Folder_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Folder_name as text
%        str2double(get(hObject,'String')) returns contents of Folder_name as a double
rutaManual = get(hObject, 'String');

% Comprobar si la ruta ingresada es una carpeta válida
if isfolder(rutaManual)
    handles.folderSelected = rutaManual;
    logMessage(handles, ['✔ Carpeta cargada manualmente: ' rutaManual]);
    guidata(hObject, handles);  % Guardar cambios
else
    logMessage(handles, '⚠ La ruta ingresada no es una carpeta válida.');
end

% --- Executes during object creation, after setting all properties.
function Folder_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Folder_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in path_bottom.
function path_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to path_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folderPath = uigetdir('', 'Selecciona una carpeta para guardar los datos');

if isequal(folderPath, 0)
    logMessage(handles, '❌ Selección de carpeta cancelada.');
else
    logMessage(handles, [' Carpeta seleccionada: ' folderPath]);

    % Guarda el path de la carpeta en handles para usar después
    handles.folderSelected = folderPath;

    % ACTUALIZAR CUADRO EDITABLE
    set(handles.Folder_name, 'String', folderPath);

    guidata(hObject, handles);  % Actualiza los handles
end

% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

resp = questdlg('¿Deseas iniciar el movimiento?', ...
                'Confirmación', ...
                'Sí', 'No', 'No');

if ~strcmp(resp, 'Sí')
    logMessage(handles, ' Finalizando...');
    return;
end

logMessage(handles,  '▶️ Iniciando secuencia de movimiento...');

saveFolder = handles.folderSelected;
% Buscar archivos previos para continuar numeración
files = dir(fullfile(saveFolder, 'signal*.csv'));
lastIndex = 0;
if ~isempty(files)
    % Extraer el número más alto usado
    numbers = regexp({files.name}, 'signal(\d+)\.csv', 'tokens');
    numbers = cellfun(@(x) str2double(x{1}), numbers);
    lastIndex = max(numbers);
end

% Obtener opción seleccionada en el menú desplegable
contents = cellstr(get(handles.Images_to_reconstruction, 'String'));
selected = contents{get(handles.Images_to_reconstruction, 'Value')};

cantidad_archivos = length(files);

multiplo = floor(cantidad_archivos / 30);
if cantidad_archivos == 0
    angulo = 0;
else
    angulo = multiplo * 10;
end

switch selected
    case 'Ellipse'
        Sistema = SistemaElipses(216, angulo);
    case 'a character'
        Sistema = Charactergenerator('a', 216, angulo);
    case 'b character'
        Sistema = Charactergenerator('b', 216, angulo);
    case 'e character'
        Sistema = Charactergenerator('e', 216, angulo);
    otherwise
        Sistema = zeros(216); % por si acaso
end

% Mostrar en la GUI
axes(handles.Original_image);
imshow(Sistema, []);

logMessage(handles, [' Ángulo aplicado: ', num2str(angulo), '°']);

instrreset;
oscilloscopeAddress = get(handles.Oscilloscope, 'String');

try
    % Primero intentamos con VISA genérico
    visaObj = visa('ni', oscilloscopeAddress);
    %visaObj = visadev(oscilloscopeAddress); Este comando estaba
    %originalmente en el formato DPO
    fopen(visaObj);
    idn = query(visaObj, '*IDN?');
    logMessage(handles, ['Osciloscopio detectado: ' idn]);
catch
    logMessage(handles, '⚠️ No se pudo identificar el osciloscopio con VISA.');
    idn = 'UNKNOWN';
end

if contains(idn, 'DPO')
    deviceType = "DPO";
elseif contains(idn, 'TBS')  % -----> TBS1000C
    deviceType = "TBS";
elseif contains(idn, 'TDS')
    deviceType = 'TDS';
else
    deviceType = 'UNKNOWN';
end

%POR TERMINAR

archivo = get(handles.set_text, 'String');

if exist(archivo, 'file') == 2
    % ============================
    % ✅ Leer y enviar comandos del archivo .set
    % ============================
    fid = fopen(archivo, 'r');
    if fid == -1
        error('No se pudo abrir el archivo .set');
    end

    while ~feof(fid)
        linea = strtrim(fgets(fid));  % Leer línea
        if ~isempty(linea)
            try
                writeline(visaObj, linea);  % Enviar comando
                pause(0.05);  % Esperar para evitar saturar el buffer
            catch ME
                fprintf('⚠️ Error al enviar: %s\n', linea);
                disp(ME.message);
            end
        end
    end
    fclose(fid);
    disp('✅ Todos los comandos del archivo .set fueron enviados con éxito.');

else
    % ============================
    % ⚠️ No hay archivo .set: leer configuración actual del osciloscopio
    % ============================
    logMessage(handles, '⚠️ No se proporcionó archivo .set. Leyendo parámetros actuales del osciloscopio...');

    % Puedes consultar y guardar estos parámetros como desees
    canal = 'CH1'; % Canal por defecto
    escala = str2double(query(visaObj, canal + ":SCALE?"));
    offset = str2double(query(visaObj, canal + ":OFFSET?"));
    acqMode = query(visaObj, "ACQ:MODE?");
    samplerate = str2double(query(visaObj, "HOR:MAIN:SAMPLERATE?"));
    recordLength = str2double(query(visaObj, "HOR:RECO?"));
    tiempoDiv = str2double(query(visaObj, "HOR:MAIN:SCALE?"));

    logMessage(handles, 'Lectura directa desde el osciloscopio:');
    logMessage(handles, sprintf("Canal: %s", canal));
    logMessage(handles, sprintf("Escala: %.3f V/div", escala));
    logMessage(handles, sprintf("Offset: %.3f V", offset));
    logMessage(handles, sprintf("Modo de adquisición: %s", strtrim(acqMode)));
    logMessage(handles, sprintf("Frecuencia de muestreo: %.2e Hz", samplerate));
    logMessage(handles, sprintf("Longitud de registro: %d puntos", recordLength));
    logMessage(handles, sprintf("Tiempo/div: %.3e s/div", tiempoDiv));
    
    % Si quieres que MATLAB configure algo por defecto aquí también puedes hacerlo:
    % writeline(visaObj, "ACQ:MODE SAMPLE");
end

% fid = fopen(archivo, 'r');
% if fid == -1
%     logMessage(handles, error('No se pudo abrir el archivo .set'));
% end
% while ~feof(fid)
%     linea = strtrim(fgets(fid));
%     if ~isempty(linea)
%         try
%             writeline(visaObj, linea);
%             pause(0.05);
%         catch ME
%             fprintf('Error al enviar: %s\n', linea);
%             handles.MessageConsole.String = ME.message;
%         end
%     end
% end
% fclose(fid);
pause(2);

% Obtener parámetros del osciloscopio
recordLength    = str2double(query(visaObj, 'HOR:RECO?'));
verticalOffset  = str2double(query(visaObj, 'CH1:OFFSET?'));
verticalScale   = str2double(query(visaObj, 'CH1:SCALE?'));
horizontalDelay = str2double(query(visaObj, 'HOR:DELAY:TIME?'));
sampleRate      = str2double(query(visaObj, 'HOR:MAIN:SAMPLERATE?'));
sampleInterval  = 1 / sampleRate;

steps_per_mm = 200 / 1.2;

Controller03 = get(handles.COM03, 'string');

% Configurar comunicación serial
puerto_xy = sprintf("COM%s", Controller03);
baudrate = str2num(get(handles.Bits, 'String'));
num_steps = str2num(get(handles.steps_robot, 'String'));

try
    controller_xy = serialport(puerto_xy, baudrate, 'Timeout', 10);
    configureTerminator(controller_xy, 'CR');
    pause(2);
    logMessage(handles, '✅ Conexión establecida correctamente.');
catch ME
    logMessage(handles, error(['❌ Error al conectar con el controlador: ', ME.message]));
end

writeline(controller_xy, 'N');
logMessage(handles, ' Ceros definidos para X e Y.');

writeline(controller_xy, 'S1M1000');
writeline(controller_xy, 'S2M1000');
pause(0.5);
distance = str2num(get(handles.distance_number, 'String'));
x = linspace(0.0, 0.0, num_steps);
y = linspace(0.00, (1/1000)*distance, num_steps);%0.075
positions = [x; y]';
positions_mm = positions * 1000;
positions_steps = round(positions_mm * steps_per_mm);
initial_steps = positions_steps(1, :);

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
            logMessage(handles, ['✅ Posición alcanzada: X=', num2str(pos_x), ', Y=', num2str(pos_y)]);
            break;
        else
            logMessage(handles, '⏳ Esperando a que finalice el movimiento...');
        end
    end

    % ADQUISICIÓN DE SEÑAL DESDE OSCILOSCOPIO   
    fprintf(visaObj, 'ACQUIRE:STATE?');% STOP');
    fprintf(visaObj, 'DATA:SOURCE CH1');
    fprintf(visaObj, 'TRIGger:A:SETHold:DATa?')
    fprintf(visaObj, 'DATA:WIDTH?');
    %fprintf(visaObj, 'DATA:DELAY?');
    fprintf(visaObj, 'DATA:ENCdg?');% ASCII');
    fprintf(visaObj, 'DATA:START?');
    fprintf(visaObj, 'DATA:STOP?'); %d', recordLength);
    fprintf(visaObj, 'CH1:BANDWIDTH?');

    if deviceType == "DPO"
        fprintf(visaObj, 'CURVE?');
        waveform = fscanf(visaObj);
        y_values = str2double(split(waveform, ','));
        y_values = (y_values - verticalOffset) * verticalScale;
        y_values = y_values';
        %y_processed = wdenoise(y_values, 9, 'Wavelet', 'sym4', NoiseEstimate="LevelIndependent");

        x_values = horizontalDelay + (0:recordLength-1) * sampleInterval;

    elseif deviceType == "TBS" %|| deviceType == "TDS"
        interfaceObj = instrfind('Type', 'visa-usb', 'RsrcName', oscilloscopeAddress, 'Tag', '');
        % ya se tienen X, Y de readwaveform arriba
        if isempty(interfaceObj)
            interfaceObj = visa('NI', oscilloscopeAddress);
        else
            fclose(interfaceObj);
            interfaceObj = interfaceObj(1);
        end

        deviceObj = icdevice('tektronix_tds2024.mdd', interfaceObj);
        connect(deviceObj);

        groupObj = get(deviceObj, 'Waveform');
        [Y, X] = invoke(groupObj, 'readwaveform', 'channel1');
        x_values = X;
        y_values = Y;
    elseif deviceType == "TDS"

        interfaceObj = instrfind('Type', 'visa-gpib', 'RsrcName', oscilloscopeAddress, 'Tag', '');
        if isempty(interfaceObj)
            interfaceObj = visa('NI', oscilloscopeAddress);
        else
            fclose(interfaceObj);
            interfaceObj = interfaceObj(1);
        end

        deviceObj = icdevice('tektronix_tds2024.mdd', interfaceObj);
        connect(deviceObj);

        groupObj = get(deviceObj, 'Waveform');
        [Y, X] = invoke(groupObj, 'readwaveform', 'channel1');
        x_values = X;
        y_values = Y;
    else 
        logMessage(handles, 'No hay ninguna señal almacenada ');%['La señal no se ha almacenado ', outputFile]);
    end
    % Guardar señal con nombre único
    t_start = str2double(get(handles.time_start, 'String')) * 1e-6;%0.55e-4;  % Ajusta este umbral si es necesario
    t_end = str2double(get(handles.time_end, 'String')) * 1e-6;%0.75e-4;
    %idx_corte = find(x_values >= t_corte, 1, 'first');

    % Definir índice de corte según si t_end es cero
    if t_end == 0
        idx_range = find(x_values >= t_start);
    else
        idx_range = find(x_values >= t_start & x_values <= t_end);
    end

    x_values = x_values(idx_range);%idx_corte:end);
    y_values = y_values(idx_range);%idx_corte:end);
    
        %t_corte = 0.3e-4;  % Ajusta este umbral si es necesario
        %idx_corte = find(x_values >= t_corte, 1, 'first');
        %x_values = x_values(idx_corte:end);
        %y_values = y_values(idx_corte:end);
        %y_processed = y_processed(idx_corte:end);
    % Guardar señal con nombre único
    outputFileName = sprintf('signal%d.csv', lastIndex + i);
    outputFile = fullfile(handles.folderSelected, outputFileName);
    writematrix([x_values(:), y_values(:)], outputFile);%y_processed(:)], outputFile);

    axes(handles.signals); % Usa el nombre real del axes si es distinto
    cla reset;
    plot(x_values, y_values, 'b');
    %xlim([0.3e-4,2e-4])
    ylim([-10, 10])
    title([' Señal Adquirida - Iteración ' num2str(lastIndex + i)]);
    xlabel('Tiempo (s)');
    ylabel('Amplitud');

    logMessage(handles, [' Señal guardada en: ', outputFile]);

    % Reanudar adquisición (opcional)
    fprintf(visaObj, 'ACQUIRE:STATE RUN');
    pause(1);
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
        logMessage(handles, ' Retornado a posición inicial.');
        break;
    else
        logMessage(handles, '↩️ Retornando...');
    end
end

logMessage(handles, '✔️ Todo el proceso fue completado.');

% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
% hObject    handle to stopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Establece bandera de detención
handles.stopFlag = true;
guidata(hObject, handles);

% Intenta cerrar y borrar el puerto si está activo
try
    if exist('visaObj', 'var') && isvalid(visaObj)
        if strcmp(visaObj.Status, 'open')
            fclose(visaObj);
        end
        delete(visaObj);
        clear visaObj;
        clear controller_xy;
    end
catch ME
    logMessage(handles, ['Error al cerrar el puerto: ', ME.message]);
end

% Mensaje y actualización de botones
logMessage(handles, ' Movimiento detenido por el usuario.');
set(handles.startButton, 'Enable', 'on');
set(handles.stopbutton, 'Enable', 'off');

% --- Executes on button press in Continuebutton.
function Continuebutton_Callback(hObject, eventdata, handles)
% hObject    handle to Continuebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function COM01_Callback(hObject, eventdata, handles)
% hObject    handle to COM01 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of COM01 as text
%        str2double(get(hObject,'String')) returns contents of COM01 as a double


% --- Executes during object creation, after setting all properties.
function COM01_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COM01 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function COM02_Callback(hObject, eventdata, handles)
% hObject    handle to COM02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of COM02 as text
%        str2double(get(hObject,'String')) returns contents of COM02 as a double


% --- Executes during object creation, after setting all properties.
function COM02_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COM02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function COM03_Callback(hObject, eventdata, handles)
% hObject    handle to COM03 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of COM03 as text
%        str2double(get(hObject,'String')) returns contents of COM03 as a double


% --- Executes during object creation, after setting all properties.
function COM03_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COM03 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in path_button02.
function path_button02_Callback(hObject, eventdata, handles)
% hObject    handle to path_button02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile({'*.set','Archivos .SET (*.set)'}, ...
                              'Selecciona un archivo .set');

if isequal(file, 0)
    logMessage(handles, ' Selección cancelada.');
else
    fullPath = fullfile(path, file);
    logMessage(handles, ['️ Archivo .set seleccionado: ' fullPath]);

    % Aquí puedes cargar o procesar el archivo según tus necesidades
    % Por ejemplo, si es de EEGLAB:
    % EEG = pop_loadset('filename', file, 'filepath', path);

    % Guarda el path completo en handles para su uso posterior
    set(handles.set_text, 'String', fullPath);

    handles.selectedSetFile = fullPath;
    guidata(hObject, handles); % Actualiza los handles
end

function set_text_Callback(hObject, eventdata, handles)
% hObject    handle to set_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of set_text as text
%        str2double(get(hObject,'String')) returns contents of set_text as a double
% Obtener lo que el usuario escribió
rutaManual = get(hObject, 'String');

% Comprobar si el archivo existe y tiene extensión .set
if exist(rutaManual, 'file') && endsWith(rutaManual, '.set')
    handles.selectedSetFile = rutaManual;
    logMessage(handles, ['✔ Archivo .set cargado manualmente: ' rutaManual]);
    guidata(hObject, handles);  % Guardar cambios
else
    logMessage(handles, '⚠ Ruta no válida o archivo no es .set');
end


% --- Executes during object creation, after setting all properties.
function set_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to set_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in projection_button.
function projection_button_Callback(hObject, eventdata, handles)
% hObject    handle to projection_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in capture.
function capture_Callback(hObject, eventdata, handles)
% hObject    handle to capture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 % Obtener el valor actual del slider
     sliderValue = get(hObject, 'Value');
     
    % Obtener todo el texto actual de la consola
    fullText = get(handles.MessageConsole, 'String');  % Esto puede ser un cell array de líneas
     
    % Cantidad de líneas visibles en el edit box
    visibleLines = 10;  % Ajusta este valor a lo que se muestre sin hacer scroll
     
    % Calcular el índice de inicio basado en el slider
    totalLines = length(fullText);
    maxIndex = totalLines - visibleLines + 1;
    startIndex = round((1-sliderValue) * maxIndex);
    startIndex = max(1, min(startIndex, totalLines - visibleLines + 1));
    
    % Obtener el segmento de texto visible
    visibleText = fullText(startIndex:startIndex+visibleLines-1);
    
    % Mostrar esas líneas
    set(handles.MessageConsole, 'String', visibleText);
    %if ~isfield(handles, 'consoleBuffer')
    %    return;
    %end

    actualizarConsola(handles);  % Actualiza solo la porción visible

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function MessageConsole_Callback(hObject, eventdata, handles)
% hObject    handle to MessageConsole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MessageConsole as text
%        str2double(get(hObject,'String')) returns contents of MessageConsole as a double


% --- Executes during object creation, after setting all properties.
function MessageConsole_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MessageConsole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%handles.MessageConsole.Max = 100; % Allow multi-line text
%handles.MessageConsole.Min = 0;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'Max', 2);  % Habilita múltiples líneas
set(hObject, 'Min', 0);


function steps_robot_Callback(hObject, eventdata, handles)
% hObject    handle to steps_robot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of steps_robot as text
%        str2double(get(hObject,'String')) returns contents of steps_robot as a double


% --- Executes during object creation, after setting all properties.
function steps_robot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to steps_robot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function step_size_Callback(hObject, eventdata, handles)
% hObject    handle to step_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of step_size as text
%        str2double(get(hObject,'String')) returns contents of step_size as a double


% --- Executes during object creation, after setting all properties.
function step_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to step_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on selection change in menu_reconstruction.
function menu_reconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to menu_reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_reconstruction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_reconstruction

datos = handles.datosGuardados;
x = handles.x;
[delta_t, N_time, N_amp, N_energy, Phi] = deal(datos.delta_t, datos.N_time, datos.N_amp, datos.N_energy, datos.Phi);
Nx = 216;

contents = cellstr(get(hObject, 'String')); 
selected = contents{get(hObject, 'Value')}; % Opción seleccionada

%fig = figure('Visible', 'off');

switch selected
        case 'Time'
            reconstruction = flip(iradon(N_time, Phi, x));
    case 'Time Standard'
            reconstruction = flip(iradon(delta_t, Phi, x));
        case 'Amplitude'
            reconstruction = flip(iradon(N_amp, Phi, x));
        case 'Energy'
            reconstruction = flip(iradon(N_energy, Phi, x));
    end

% Normalizar y redimensionar
reconstruction = reconstruction / max(reconstruction, [], 'all');
reconstruction_resized = imresize(reconstruction, [Nx, Nx]);

handles.ultimaReconstruccion = reconstruction_resized;
guidata(hObject, handles);  % Muy importante para actualizar los cambios

%figure(fig)
%imshow(reconstruction_resized, []); % Mostrar la reconstrucción
%drawnow; % Asegura que la imagen se dibuje

% Capturar figura como imagen
%    frame = getframe(fig);
%    img = frame.cdata;
%    close(fig); % cerrar figura invisible

    % Mostrar imagen dentro del axes en la GUI
    axes(handles.Time_reconstruction);
    imshow(reconstruction_resized, [], 'Parent', handles.Time_reconstruction);

% --- Executes during object creation, after setting all properties.
function menu_reconstruction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in projection_menu.
function projection_menu_Callback(hObject, eventdata, handles)

% Obtener número de elementos
numElementos = str2double(get(handles.steps_robot, 'String'));
if isnan(numElementos) || numElementos <= 0
    numElementos = 30;
end

% Obtener número de elementos
numprojection = str2double(get(handles.number_projections, 'String'));
if isnan(numprojection) || numprojection <= 0
    numprojection = 19;
end


% Preparar datos si no existen
if ~isfield(handles, 'datosGuardados')
    handles = prepararDatos(hObject, handles, numElementos, numprojection);
    guidata(hObject, handles);  % Muy importante actualizar
end

% Leer qué opción seleccionó el usuario
contenido = get(hObject, 'String');
seleccion = get(hObject, 'Value');
opcion = contenido{seleccion};

% Actualizar la visualización
actualizarProyecciones(handles, opcion, numElementos, numprojection);


% --- Executes during object creation, after setting all properties.
function projection_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projection_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in menu_filters.
function menu_filters_Callback(hObject, eventdata, handles)
% hObject    handle to menu_filters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_filters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_filters
% Leer qué opción seleccionó el usuario
contenido = get(hObject, 'String');
seleccion = get(hObject, 'Value');
opcion = contenido{seleccion};

switch opcion
    case 'None'
        x = 'None';

    case 'Ram-Lak'
        x = 'Ram-Lak';
    
    case 'Shepp-Logan'
        x = 'Shepp-Logan'; 

    case 'Cosine'
        x = 'Cosine';  

    case 'Hamming'
        x = 'Hamming';

    case 'Hann' 
        x = 'Hann';

end

handles.x = x;

guidata(hObject, handles);  % Muy importante para actualizar los cambios


% --- Executes during object creation, after setting all properties.
function menu_filters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_filters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in kalman.
function kalman_Callback(hObject, eventdata, handles)
% hObject    handle to kalman (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Obtener la ruta desde la interfaz (ya guardada en handles)
carpeta = handles.folderSelected;
rangoX = 'A1:A8500';
rangoY = 'B1:B8500';

[X, Y, nombres] = leerCSVdesdeCarpeta(carpeta, rangoX, rangoY);

% Puedes guardar los datos en handles si los necesitas más adelante:
handles.X = X;
handles.Y = Y;
guidata(hObject, handles);

 % Verifica que existen señales
if ~isfield(handles, 'Y')
    logMessage(handles, '⚠ No se encontraron señales para filtrar.');
    return;
end

% Aplica el filtro de Kalman a cada señal (ejemplo simple)
Y_Filtradas = zeros(size(Y));
for i = 1:size(Y, 3)
    Y_Filtradas(:,:,i) = kalman_filtrar(Y(:,:,i), 1e-5, 1e-2);
end

% Guarda las señales filtradas en handles
handles.Y_Filtradas = Y_Filtradas;
guidata(hObject, handles);  % Actualiza los handles

% Muestra un ejemplo en el eje correspondiente
axes(handles.signals);  % Asegúrate que esto apunta al axes deseado en tu GUI
cla; hold on;
plot(Y(:,1), 'r--');         % Señal original
plot(Y_Filtradas(:,1), 'b');  % Señal filtrada
%xlim([0,90e-6])
ylim([-10, 10])
legend('Original', 'Filtrada');
title('Señal con Filtro de Kalman');

% Hint: get(hObject,'Value') returns toggle state of kalman


% --- Executes on button press in Homebutton.
function Homebutton_Callback(hObject, eventdata, handles)
% hObject    handle to Homebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Regresar a la posición inicial (asignada por ti en initial_steps)

Controller03 = get(handles.COM03, 'string');

% Configurar comunicación serial
puerto_xy = sprintf("COM%s", Controller03);
baudrate = str2num(get(handles.Bits, 'String'));

X_home = 0;   % Posición "home" en pasos para el eje X
Y_home = 0;   % Posición "home" en pasos para el eje Y

% === INICIALIZAR CONTROLADOR ===
controller_xy = serialport(puerto_xy, baudrate);
configureTerminator(controller_xy, 'CR'); 
controller_xy.Timeout = 5;

% === MOVER A HOME ===
command = sprintf('F,C,IA1M%d,IA2M%d,R', X_home, Y_home);
logMessage(handles, ['➡️ Enviando comando para volver a home: ', command]);
writeline(controller_xy, command);

% === PAUSA PARA QUE COMPLETE EL MOVIMIENTO ===
estimated_time = max(abs([X_home, Y_home])) * 0.01;  % Ajusta el factor según tu velocidad real
pause(estimated_time);

logMessage(handles, '✅ Movimiento a posición home completado.');


function Oscilloscope_Callback(hObject, eventdata, handles)
% hObject    handle to Oscilloscope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Oscilloscope as text
%        str2double(get(hObject,'String')) returns contents of Oscilloscope as a double


% --- Executes during object creation, after setting all properties.
function Oscilloscope_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Oscilloscope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Bits_Callback(hObject, eventdata, handles)
% hObject    handle to Bits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bits as text
%        str2double(get(hObject,'String')) returns contents of Bits as a double


% --- Executes during object creation, after setting all properties.
function Bits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Capture_signal.
function Capture_signal_Callback(hObject, eventdata, handles)
% hObject    handle to Capture_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Buscar archivos previos para continuar numeración
files = dir(fullfile(handles.folderSelected, 'individual_signal*.csv'));
lastIndex = 0;
if ~isempty(files)
    % Extraer el número más alto usado
    numbers = regexp({files.name}, 'signal(\d+)\.csv', 'tokens');
    numbers = cellfun(@(x) str2double(x{1}), numbers);
    lastIndex = max(numbers);
end

% Obtener dirección del osciloscopio desde la GUI
oscilloscopeAddress = get(handles.Oscilloscope, 'String');

% Reiniciar instrumentos previos
instrreset;

% Crear objeto VISA usando la dirección del campo
visaObj = visa('ni', oscilloscopeAddress);
fopen(visaObj);
%visadev(oscilloscopeAddress);

% Intentar identificar el osciloscopio
try
    idn = query(visaObj, '*IDN?');
    logMessage(handles, ['Osciloscopio detectado: ' idn]);
catch
    logMessage(handles, '⚠️ No se pudo leer *IDN?. Usando método alterno...');
    idn = 'UNKNOWN';
end

% ===============================
% ✅ Adquisición según modelo
% ===============================
if contains(idn, 'DPO')  % -----> DPO3012
logMessage(handles, 'Usando flujo de adquisición para DPO...');

% Identificar modelo del osciloscopio
%try
%    idn = query(visaObj, '*IDN?');
%    logMessage(handles, ['Osciloscopio detectado: ' idn]);
%catch
%    logMessage(handles, '⚠️ No se pudo leer *IDN?. Intentando con icdevice...');
%    idn = 'UNKNOWN';
%end

%instrreset;
%oscilloscopeAddress = get(handles.Oscilloscope, 'String');
%visaObj = visa('NI', oscilloscopeAddress);%visadev(oscilloscopeAddress);
archivo = get(handles.set_text, 'String');

if exist(archivo, 'file') == 2
    % ============================
    % ✅ Leer y enviar comandos del archivo .set
    % ============================
    fid = fopen(archivo, 'r');
    if fid == -1
        error('No se pudo abrir el archivo .set');
    end

    while ~feof(fid)
        linea = strtrim(fgets(fid));  % Leer línea
        if ~isempty(linea)
            try
                writeline(visaObj, linea);  % Enviar comando
                pause(0.05);  % Esperar para evitar saturar el buffer
            catch ME
                fprintf('⚠️ Error al enviar: %s\n', linea);
                logMessage(handles, ME.message);
            end
        end
    end
    fclose(fid);
    logMessage(handles, '✅ Todos los comandos del archivo .set fueron enviados con éxito.');

else
    % ============================
    % ⚠️ No hay archivo .set: leer configuración actual del osciloscopio
    % ============================
    logMessage(handles, '⚠️ No se proporcionó archivo .set. Leyendo parámetros actuales del osciloscopio...');

    % Puedes consultar y guardar estos parámetros como desees
    canal = 'CH1'; % Canal por defecto
    escala = str2double(query(visaObj, canal + ":SCALE?"));
    offset = str2double(query(visaObj, canal + ":OFFSET?"));
    acqMode = query(visaObj, "ACQ:MODE?");
    samplerate = str2double(query(visaObj, "HOR:MAIN:SAMPLERATE?"));
    recordLength = str2double(query(visaObj, "HOR:RECO?"));
    tiempoDiv = str2double(query(visaObj, "HOR:MAIN:SCALE?"));
    horizontalDelay = str2double(query(visaObj, 'HOR:DELay:TIMe?'));
    %triggerPosition = str2double(query(visaObj, 'HOR:POS?')); % Obtener posición del trigger
%sampleRate      = str2double(query(visaObj, 'HOR:MAIN:SAMPLERATE?'));
%sampleInterval  = 1 / sampleRate;



    fprintf("Lectura directa desde el osciloscopio:\n");
    fprintf("Canal: %s\n", canal);
    fprintf("Escala: %.3f V/div\n", escala);
    fprintf("Offset: %.3f V\n", offset);
    fprintf("Modo de adquisición: %s\n", strtrim(acqMode));
    fprintf("Frecuencia de muestreo: %.2e Hz\n", samplerate);
    fprintf("Longitud de registro: %d puntos\n", recordLength);
    fprintf("Tiempo/div: %.3e s/div\n", tiempoDiv);
    %fprintf("Trigger: %.3e s\n", triggerPosition);
    fprintf("Tiempo inicial %.3f (s):\n", horizontalDelay);

    % Si quieres que MATLAB configure algo por defecto aquí también puedes hacerlo:
    % writeline(visaObj, "ACQ:MODE SAMPLE");
end
pause(2);

% Obtener parámetros del osciloscopio
recordLength    = str2double(query(visaObj, 'HOR:RECO?'));
horizontalScale = str2double(query(visaObj, 'HOR:SCAle?'));
verticalOffset  = str2double(query(visaObj, 'CH1:OFFSET?'));
verticalScale   = str2double(query(visaObj, 'CH1:SCALE?'));
triggerPosition = str2double(query(visaObj, 'HOR:POS?')); % Obtener posición del trigger
horizontalDelay = str2double(query(visaObj, 'HOR:DELAY:TIME?'));
sampleRate      = str2double(query(visaObj, 'HOR:MAIN:SAMPLERATE?'));
sampleInterval  = 1 / sampleRate;

%fprintf("Tiempo inicial (s):", horizontalDelay);

% ADQUISICIÓN DE SEÑAL DESDE OSCILOSCOPIO
fprintf(visaObj, 'ACQUIRE:STATE?');% STOP');
    fprintf(visaObj, 'DATA:SOURCE CH1');
    fprintf(visaObj, 'TRIGger:A:SETHold:DATa?')
    fprintf(visaObj, 'DATA:WIDTH?');
    fprintf(visaObj, 'DATA:ENCdg?');
    fprintf(visaObj, 'DATA:START?');
    fprintf(visaObj, 'DATA:STOP?'); %d', recordLength);
    fprintf(visaObj, 'CH1:BANDWIDTH?');

fprintf(visaObj, 'CURVE?');
waveform = fscanf(visaObj);
y_values = str2double(split(waveform, ','));
y_values = (y_values - verticalOffset) * verticalScale;
y_values = y_values';
y_processed = wdenoise(y_values, 9, 'Wavelet', 'sym4', NoiseEstimate="LevelIndependent");

x_values = horizontalDelay + (0:recordLength-1) * sampleInterval; %horizontalScale;%
%x_values = ((0:recordLength-1) - triggerPosition) * sampleInterval; % Ajustar el eje de tiempo centrando el trigger en 0
% Guardar señal con nombre único
%t_corte 
t_start = str2double(get(handles.time_start, 'String')) * 1e-6;%0.55e-4;  % Ajusta este umbral si es necesario
t_end = str2double(get(handles.time_end, 'String')) * 1e-6;%0.75e-4;
%idx_corte = find(x_values >= t_corte, 1, 'first');

% Definir índice de corte según si t_end es cero
if t_end == 0
    idx_range = find(x_values >= t_start);
else
    idx_range = find(x_values >= t_start & x_values <= t_end);
end

x_values = x_values(idx_range);%idx_corte:end);
%y_values = y_values(idx_range);%idx_corte:end);
y_processed = y_processed(idx_range);%idx_corte:end);


outputFileName = sprintf('individual_signal%d.csv', lastIndex + 1);
outputFile = fullfile(handles.folderSelected, outputFileName);
writematrix([x_values(:), y_processed(:)], outputFile);

axes(handles.signals); % Usa el nombre real del axes si es distinto
cla reset;
plot(x_values, y_processed, 'b');
%xlim([0.3e-4,2e-4])
ylim([-10, 10])
title([' Señal Adquirida - Iteración ' num2str(lastIndex + 1)]);
xlabel('Tiempo (s)');
ylabel('Amplitud');

logMessage(handles, [' Señal guardada en: ', outputFile]);

% Reanudar adquisición (opcional)
fprintf(visaObj, 'ACQUIRE:STATE RUN');
pause(1);

elseif contains(idn, 'TBS')  % -----> TBS1000C
    logMessage(handles, 'Usando flujo de adquisición para TBS...');
    
    % Crear VISA-USB con icdevice usando el mismo address de la GUI
    interfaceObj = instrfind('Type', 'visa-usb', 'RsrcName', oscilloscopeAddress, 'Tag', '');
    if isempty(interfaceObj)
        interfaceObj = visa('NI', oscilloscopeAddress);
    else
        fclose(interfaceObj);
        interfaceObj = interfaceObj(1);
    end
    
    deviceObj = icdevice('tektronix_tds2024.mdd', interfaceObj);
    connect(deviceObj);
    
    % Leer waveform
    groupObj = get(deviceObj, 'Waveform');
    [Y, X] = invoke(groupObj, 'readwaveform', 'channel1');
    
    % Procesamiento y guardado igual que en tu flujo actual
    %y_processed = wdenoise(Y, 9, 'Wavelet', 'sym4', NoiseEstimate="LevelIndependent");
    
    outputFileName = sprintf('individual_signal%d.csv', lastIndex + 1);
    outputFile = fullfile(handles.folderSelected, outputFileName);
    writematrix([X(:), Y(:)], outputFile);
    
    axes(handles.signals);
    cla reset;
    plot(X, Y, 'r');
    title([' Señal TBS - Iteración ' num2str(lastIndex + 1)]);
    xlabel('Tiempo (s)');
    ylabel('Amplitud');
    
    logMessage(handles, ['✅ Señal guardada en: ', outputFile]);
    
    disconnect(deviceObj);
    delete(deviceObj);


elseif contains(idn, 'TDS')%'GPIB') || contains(oscilloscopeAddress, '0x03C4') % -----> TDS1012
    % Crear VISA-USB con icdevice usando el mismo address de la GUI
    interfaceObj = instrfind('Type', 'visa-gpib', 'RsrcName', oscilloscopeAddress, 'Tag', '');
    if isempty(interfaceObj)
        interfaceObj = visa('NI', oscilloscopeAddress);
    else
        fclose(interfaceObj);
        interfaceObj = interfaceObj(1);
    end

    deviceObj = icdevice('tektronix_tds2024.mdd', interfaceObj);
    connect(deviceObj);

    groupObj = get(deviceObj, 'Waveform');
    [Y, X] = invoke(groupObj, 'readwaveform', 'channel1');

    outputFileName = sprintf('individual_signal%d.csv', lastIndex + 1);
    outputFile = fullfile(handles.folderSelected, outputFileName);
    writematrix([X(:), Y(:)], outputFile);

    axes(handles.signals);
    cla reset;
    plot(X, Y, 'r');
    title(['Señal adquirida - TDS1012' num2str(lastIndex + 1)]);

    logMessage(handles, ['✅ Señal guardada en: ', outputFile]);
    
    disconnect(deviceObj);
    delete(deviceObj);

else
    logMessage(handles, '⚠️ Modelo no reconocido. Verifica dirección o driver.');
end


% --- Executes on selection change in Images_to_reconstruction.
function Images_to_reconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to Images_to_reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Images_to_reconstruction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Images_to_reconstruction

contents = cellstr(get(hObject, 'String')); 
selected = contents{get(hObject, 'Value')}; % Opción seleccionada

switch selected
    case 'Ellipse'
        Sistema = SistemaElipses(216, 0);
    case 'a character'
        Sistema = Charactergenerator('a', 216, 0);
    case 'b character'
        Sistema = Charactergenerator('b', 216, 0);
    case 'e character'
        Sistema = Charactergenerator('e', 216, 0);
    otherwise
        Sistema = zeros(216); % por si acaso
end

% Mostrar directamente en el axes de la GUI
fig = figure('Visible', 'off');

% Capturar imagen
frame = getframe(fig);
img = frame.cdata;
close(fig);

axes(handles.Original_image); % activar el axes deseado
imshow(Sistema, [], 'Parent', handles.Original_image);



% --- Executes during object creation, after setting all properties.
function Images_to_reconstruction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Images_to_reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time_start_Callback(hObject, eventdata, handles)
% hObject    handle to time_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_start as text
%        str2double(get(hObject,'String')) returns contents of time_start as a double


% --- Executes during object creation, after setting all properties.
function time_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time_end_Callback(hObject, eventdata, handles)
% hObject    handle to time_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_end as text
%        str2double(get(hObject,'String')) returns contents of time_end as a double


% --- Executes during object creation, after setting all properties.
function time_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GuardarDatos.
function GuardarDatos_Callback(hObject, eventdata, handles)
% hObject    handle to GuardarDatos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Elegir carpeta de guardado
%carpeta = uigetdir(pwd, 'Selecciona la carpeta para guardar los datos');
%if carpeta == 0
%    logMessage(handles,'❌ Cancelado por el usuario.');
%    return;
%end
carpeta = handles.folderSelectedsave;

% Leer estado de checkboxes
guardar_senales = get(handles.checkbox_senales, 'Value');
guardar_proyecciones = get(handles.checkbox_proyecciones, 'Value');
guardar_reconstruccion = get(handles.checkbox_reconstruccion, 'Value');

    % Guardar señales
    if guardar_senales
        if isfield(handles, 'X') && isfield(handles, 'Y')
            X = handles.X;
            Y = handles.Y;%_filtrada;
            save(fullfile(carpeta, 'señales_experimentales.mat'), 'X', 'Y');
            logMessage(handles,'✅ Señales guardadas.');
        else
            logMessage(handles,'⚠️ No se encontraron datos de señales en memoria.');
        end
    end

    % Guardar proyecciones
    if guardar_proyecciones
        if isfield(handles, 'datosGuardados')
            datos = handles.datosGuardados;
            save(fullfile(carpeta, 'proyecciones.mat'), '-struct', 'datos');
            logMessage(handles,'✅ Proyecciones guardadas.');
        else
            logMessage(handles,'⚠️ No se encontraron proyecciones en memoria.');
        end
    end

    % Guardar reconstrucción
    if guardar_reconstruccion
        if isfield(handles, 'ultimaReconstruccion')
            reconstruction = handles.ultimaReconstruccion;
            save(fullfile(carpeta, 'reconstruccion.mat'), 'reconstruction');
            logMessage(handles, '✅ Reconstrucción guardada.');
        else
            logMessage(handles, '⚠️ No se encontró una reconstrucción previa.');
        end
    end

    logMessage(handles, 'Guardado completado. ✅ Éxito');

% --- Executes on button press in checkbox_senales.
function checkbox_senales_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_senales (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_senales


% --- Executes on button press in checkbox_reconstruccion.
function checkbox_reconstruccion_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_reconstruccion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_reconstruccion


% --- Executes on button press in checkbox_proyecciones.
function checkbox_proyecciones_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_proyecciones (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_proyecciones



function text_file_save_Callback(hObject, eventdata, handles)
% hObject    handle to text_file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_file_save as text
%        str2double(get(hObject,'String')) returns contents of text_file_save as a double
rutaManual = get(hObject, 'String');

% Comprobar si la ruta ingresada es una carpeta válida
if isfolder(rutaManual)
    handles.folderSelectedsave = rutaManual;
    logMessage(handles, ['✔ Carpeta cargada manualmente: ' rutaManual]);
    guidata(hObject, handles);  % Guardar cambios
else
    logMessage(handles, '⚠ La ruta ingresada no es una carpeta válida.');
end

% --- Executes during object creation, after setting all properties.
function text_file_save_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in file_save.
function file_save_Callback(hObject, eventdata, handles)
% hObject    handle to file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folderPath = uigetdir('', 'Selecciona una carpeta para guardar los datos');

if isequal(folderPath, 0)
    logMessage(handles, '❌ Selección de carpeta cancelada.');
else
    logMessage(handles, [' Carpeta seleccionada: ' folderPath]);

    % Guarda el path de la carpeta en handles para usar después
    handles.folderSelectedsave = folderPath;

    % ACTUALIZAR CUADRO EDITABLE
    set(handles.text_file_save, 'String', folderPath);

    guidata(hObject, handles);  % Actualiza los handles
end


% --- Executes on selection change in CNN_Network.
function CNN_Network_Callback(hObject, eventdata, handles)
contenido = get(hObject, 'String');
seleccion = get(hObject, 'Value');
opcion = contenido{seleccion};

% Obtener la imagen del axes (Original_image)
frame = getframe(handles.Time_reconstruction);
inputImg = frame.cdata;

% Redimensionar según sea necesario (ej. 216x216)
inputImg = imresize(inputImg, [224, 224]);

switch opcion
    case 'Classification Ellipses'
        load('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\nets_classifications\resnet50_ellipse03.mat', 'net');  % Ajusta nombre
        % Asegúrate de convertir a RGB si es necesario
        if size(inputImg,3) == 1
            %inputImg = imresize(img, [224, 224]);
            inputImg = repmat(inputImg, [1 1 3]);
        end
        label = classify(net, inputImg);
        logMessage(handles, [' Clasificación (Elipses): ', char(label)]);
        
    case 'Detection Ellipses'
        load('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\nets_detections\VGG16_discontinuidades_detector_ellipse.mat', 'detector');  % Ajusta nombre
        [bboxes, scores, labels] = detect(detector, inputImg);
        detectedImg = insertObjectAnnotation(inputImg, 'Rectangle', bboxes, cellstr(labels));
        axes(handles.Time_reconstruction);
        imshow(detectedImg, []);
        logMessage(handles, ' Detección realizada (Elipses).');

    case 'Classification Letters'
        load('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\nets_classifications\resnet50_with_100kwave.mat', 'net');  % Ajusta nombre
        if size(inputImg,3) == 1
            inputImg = imresize(img, [224, 224]);
            inputImg = repmat(inputImg, [1 1 3]);
        end
        label = classify(net, inputImg);
        logMessage(handles, [' Clasificación (Letras): ', char(label)]);

    case 'Detection Letters'
        load('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\nets_detections\VGG16_discontinuidades_detector_abe.mat', 'detector');  % Ajusta nombre
        [bboxes, scores, labels] = detect(detector, inputImg);
        detectedImg = insertObjectAnnotation(inputImg, 'Rectangle', bboxes, cellstr(labels));
        axes(handles.Time_reconstruction);
        imshow(detectedImg, []);
        logMessage(handles, ' Detección realizada (Letras).');

    otherwise
        logMessage(handles, '⚠️ Opción desconocida.');
end

% Hints: contents = cellstr(get(hObject,'String')) returns CNN_Network contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CNN_Network


% --- Executes during object creation, after setting all properties.
function CNN_Network_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CNN_Network (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_Image_reconstruction.
function Save_Image_reconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Image_reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Ruta donde se guardará la imagen
%carpeta = handles.folderSelectedsave;  % Asegúrate de que esta carpeta exista
%nombreArchivo = 'reconstruccion_guardada.png';  % Puedes hacer esto dinámico si quieres

% Obtener la imagen del axes (donde fue mostrada con imshow)
%axesHandle = handles.Time_reconstruction;
%frame = getframe(axesHandle);  % Captura el contenido del axes
%img = frame.cdata;

% Guardar imagen como .png
%rutaCompleta = fullfile(carpeta, nombreArchivo);
%imwrite(img, rutaCompleta);

% Confirmación
%logMessage(handles, ['✅ Imagen guardada en: ', rutaCompleta]);

   % Obtener el contenido del axes
    axesHandle = handles.Time_reconstruction;
    frame = getframe(axesHandle);
    img = frame.cdata;

    % Carpeta de guardado
    carpeta = handles.folderSelectedsave;

    % Buscar archivos previos guardados en esa carpeta
    archivos = dir(fullfile(carpeta, 'reconstruccion_*.png'));
    indices = [];

    for i = 1:length(archivos)
        nombre = archivos(i).name;
        num = regexp(nombre, 'reconstruccion_(\d+)\.png', 'tokens');
        if ~isempty(num)
            indices(end+1) = str2double(num{1});
        end
    end

    % Definir nuevo índice
    if isempty(indices)
        nuevoIndice = 1;
    else
        nuevoIndice = max(indices) + 1;
    end

    % Crear nombre dinámico
    nombreArchivo = sprintf('reconstruccion_%03d.png', nuevoIndice);
    rutaCompleta = fullfile(carpeta, nombreArchivo);

    % Guardar imagen
    imwrite(img, rutaCompleta);

    % Confirmación
    logMessage(handles, [' Imagen guardada como: ', nombreArchivo]);




function distance_number_Callback(hObject, eventdata, handles)
% hObject    handle to distance_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of distance_number as text
%        str2double(get(hObject,'String')) returns contents of distance_number as a double


% --- Executes during object creation, after setting all properties.
function distance_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distance_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function number_projections_Callback(hObject, eventdata, handles)
% hObject    handle to number_projections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of number_projections as text
%        str2double(get(hObject,'String')) returns contents of number_projections as a double


% --- Executes during object creation, after setting all properties.
function number_projections_CreateFcn(hObject, eventdata, handles)
% hObject    handle to number_projections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
