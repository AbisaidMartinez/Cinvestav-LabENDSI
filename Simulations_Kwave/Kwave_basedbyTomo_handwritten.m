%%% Example based on example Focused transducer
tic
% clearvars;

%ang=[0,90];
%ang=[0,45,90];
ang=[0,10,20,30,40,50,60,70,80,90, 100, 110, 120, 130, 140, 150, 160, 170, 180];
k=1;
signals=zeros(902,length(ang));%866,length(ang));


for j=1:length(ang)


% =========================================================================
% SIMULATION
% =========================================================================

% create the computational grid
Nx = 216;          % number of grid points in the x (row) direction
Ny = Nx;           % number of grid points in the y (column) direction
dx = 5e-4;%50e-3/Nx;    	% grid point spacing in the x direction [m]
dy = dx;            % grid point spacing in the y direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% define the properties of the propagation medium
medium.sound_speed = 1500* ones(Nx, Ny);  % [m/s]
%medium.sound_speed(1:Nx/2, :) = 1600;       % [m/s]
medium.alpha_coeff = 0.75* ones(Nx, Ny);  % [dB/(MHz^y cm)]
medium.alpha_power = 1.5* ones(Nx, Ny);
medium.density = 1000* ones(Nx, Ny);     % [kg/m^3]
%medium.sound_speed(1:Nx/2, :) = 900;       % [m/s]

%=====================
    % create time array
    %kgrid.makeTime(medium.sound_speed);
    t_end = 90e-6;       % [s]
    %kgrid.makeTime(medium.sound_speed, [], t_end);
    kgrid.t_array = makeTime(kgrid, medium.sound_speed, [], t_end);

% =========================================================================
% DEFINE THE INPUT SIGNAL
% =========================================================================
    
    % define properties of the input signal
    source_strength = 1e6;          % [Pa]
    tone_burst_freq = 1e6;        % [Hz]
    tone_burst_cycles = 5;
    
    % create the input signal using toneBurst 
    input_signal_s = toneBurst(1/kgrid.dt, tone_burst_freq, tone_burst_cycles);
    
    % scale the source magnitude by the source_strength divided by the
    % impedance (the source is assigned to the particle velocity)
    input_signal = (source_strength ./ (medium.sound_speed(1) * medium.density(1))) .* input_signal_s;


% =======================================================================
% To the define an Elipse as discontinuity
%===================
%a = 30;  % Radio mayor del elipse 
%b = 10;  % Radio menor del elipse 
x0 = Nx/2; % Centro del elipse en x
y0 = Ny/2; % Centro del elipse en y

%[x, y] = meshgrid(1:Nx, 1:Ny);


    disp('----------------')
    disp(['Ang = ',num2str(ang(j))])
    disp('----------------')
    theta=ang(j);
    
    % Leer la imagen
    Imagen = zeros(Nx);
    img = imread('C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Handwritting\training_set\e_square\750.png');
    
    [X, Y] = size(img);

    for x=1:X
       for y=1:Y
           if img(x,y) ~= 0
               img(x,y) = 255;
           end
       end
    end
    
    img = imbinarize(img);
    value = 150; %150;
    img = imresize(img, [value, value]);%, Side="both");%imresize
    
    %figure;
    %imshow(img, [])
    
    %
    % Obtener las coordenadas para centrar la imagen
    startX = floor((216 - value) / 2) + 1;
    startY = floor((216 - value) / 2) + 1;
    
    % Insertar la imagen en el centro
    Imagen(startX:startX+(value-1), startY:startY+(value-1)) = img;
    rot = imrotate(Imagen, theta, 'nearest', 'crop');

    % Asignar propiedades de la LETRA al medio
    medium.sound_speed(rot == 1) = 1639;%1540;  % velocidad del sonido en la elipse
    medium.density(rot == 1) = 1000;      % Densidad de la elipse (Phlantom Materials for Elastography)
    medium.alpha_coeff(rot == 1) = 2;  % [dB/(MHz^y cm)]
    medium.alpha_power = 1.5;

    %figure;
    %imshow(ellipse_mask, []);
    
    % medium.sound_speed(ellipse_mask) = 1540; % Velocidad del sonido en el sólido [m/s]
    % medium.density(ellipse_mask) = 1100;     % Densidad del sólido [kg/m^3] 
    % medium.alpha_coeff(ellipse_mask) = 10.75;  % [dB/(MHz^y cm)]
    % medium.alpha_power = 1.5;
       
    % Position of the transducer's center
    z= Nx/2-80:10:Nx/2+80;
    
    amplitude=zeros(2,length(z)); 
    
    for i=1:length(z)
        pos=z(i); %Position of the transducer in x-axis
         %disp('----------------')
        disp(['-------- > Angle = ', num2str(ang(j)), '-------- > Sensor = ',num2str(i)])
        %disp('----------------')
        % define a curved transducer element
        arc_pos = [50, pos];         % [grid points]    
        radius = 50;                % [grid points]
        diameter = 41;              % [grid points]
        %focus_pos = [Nx/2, Nx/2];   % [grid points]
        focus_pos = [200, pos];   % [grid points]
        source.p_mask = makeArc([Nx, Ny], arc_pos, radius, diameter, focus_pos);
        source.p = input_signal;

        % define a time varying sinusoidal source
        %source_freq = 0.25e6;       % [Hz]
        %source_mag = 0.5;           % [Pa]
        %source.p = source_mag * sin(2 * pi * source_freq * kgrid.t_array);
        
        % filter the source to remove high frequencies not supported by the grid
        source.p = filterTimeSeries(kgrid, medium, source.p);
        
        % create a display mask to display the transducer
        display_mask = source.p_mask;
        
        % create a sensor mask covering the entire computational domain using the
        % opposing corners of a rectangle
        sensor.mask = [1, 1, Nx, Ny].';
        
        % Sensor mask several sensors on the bottom
        sensor.mask = zeros(Nx, Ny);
        sensor.mask(Nx - 50, z) = 1;
        sensor.record = {'p'};
        
        % assign the input options
        input_args = {'DisplayMask', ...
            display_mask+sensor.mask+rot, 'PMLInside', false, ...
            'PlotPML', false, 'PlotLayout', false,'PlotScale', ...
            [-1 1],'PlotSim', false};%true}; % , 'RecordMovie', true, 'MovieName', '07'
       
        % run the simulation
        sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor,...
       input_args{:});
       %figure() 
       %plot(sensor_data.p(i,:))
       %amplitude(j,k)=max(sensor_data.p(i,:));
       signals(:,k)=sensor_data.p(i,:);
       k=k+1;

       % figure;
       % imagesc(medium.sound_speed);
       % hold on;
       % plot(x0, y0, 'rx', 'MarkerSize', 10, 'LineWidth', 2); % centro de la elipse
       % [y_sensor_pos, x_sensor_pos] = find(sensor.mask == 1);
       % plot(x_sensor_pos, y_sensor_pos, 'ro', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de los sensores
       % [y_source_pos, x_source_pos] = find(source.p_mask == 1);
       % plot(x_source_pos, y_source_pos, 'go', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de las fuentes        title(['Rotación de Sensores y Fuentes en Ángulo: ', num2str(theta)]);
       % colorbar;
       % axis image;
       % hold off;
    end
    %figure()
    %plot(amplitude(j,:))
    %title(['Angle= ',num2str(ang(j))])
    %SensorRes(:,j)=amplitude(:);
    %figure
    
end
toc
%% Señales en tratamiento estandar
for a = 1:length(ang)
    figure('Position', [1 1 500 800]);
    sgtitle(['Señales para angulo ', num2str(ang(a))])

    %t = 1:size(signals, 1);
    k = 1;
    indices = 1 + (a - 1) * length(z) : length(z) * a; % Índices correspondientes
 
    % Graficar solo si los índices son válidos
    if max(indices) <= size(signals, 2)
        %subplot(length(ang), 1, a); % Crear una subfigura para cada ángulo
        stackedplot(kgrid.t_array, signals(:, indices), 'k');%hilbert(abs(signals(:, indices))), 'k');
        %title(['Señales para ángulo ', num2str(ang(a))]);
        %xlabel('Tiempo (índices)');
        %ylabel('Amplitud');
    end
end

%% Plot Hilbert transform

figure;
plot(t,x)
hold on
plot(t,env)
hold off
%xlim([0 0.04])
title('Hilbert Envelope')


%% Acquiring normal signals

amp=zeros(length(z),length(ang));
delta_t = zeros(length(z),length(ang));
Energy = zeros(length(z), length(ang));

N_amp = [];
N_time = [];
N_energy = [];
L=length(kgrid.t_array);
for a=1:length(ang)
    k=1;
    for i=1+(a-1)*length(z):length(z)*a
        [amp(k,a), indice]=max(abs(signals(:,i)));
        delta_t(k,a) = kgrid.t_array(indice);
       
        Energy(k, a) = (1/L) * trapz(kgrid.t_array, abs(signals(:, i)).^2);

        k=k+1;
    end
    N_amp = [N_amp, abs(amp(:,a)-max(amp(:,a)))];
    N_time = [N_time, abs(delta_t(:,a)-max(delta_t(:,a)))];
    N_energy = [N_energy, abs(Energy(:,a)-max(Energy(:,a)))];
end

%% Acquiring Time with Hilbert Transform

amp=zeros(length(z),length(ang));
delta_t = zeros(length(z),length(ang));

N_amp = [];
N_time_h = [];

L=length(kgrid.t_array);
for a=1:length(ang)
    k=1;
    for i=1+(a-1)*length(z):length(z)*a
        
        [amp(k,a), indice]=max(hilbert(abs(signals(:,i))));
        delta_t(k,a) = kgrid.t_array(indice);

        k=k+1;
    end
    N_amp = [N_amp, abs(amp(:,a)-max(amp(:,a)))];
    N_time_h = [N_time_h, abs(delta_t(:,a)-max(delta_t(:,a)))];

end

%%
%clearvars
%load Results1.mat

%z = 1:17;
%ang = linspace(0,180, 19);

%Amplitudes
figure
hold on
x=1:length(z);
for Id = 1 : length(ang)
    subplot(4, 5, Id) ;
    plot(x,N_amp(:,Id),'-o');
    sgtitle('Max amplitude projections')
    title(['Angle =',num2str(ang(Id))])
    xlim([0,length(z)])
    %ylim([0.1,.5])
end

%Energias
figure
hold on
x=1:length(z);
for Id = 1 : length(ang)
    subplot(4, 5, Id) ;
    plot(x,N_energy(:,Id),'-o');
    sgtitle('Energy projections')
    title(['Angle =',num2str(ang(Id))])
    xlim([0,length(z)])
    %ylim([0.1,.5])
end

%Tiempos 
figure;
hold on;
for Id = 1 : length(ang)
    subplot(4, 5, Id) ;
    plot(x,N_time(:,Id),'-o');
    sgtitle('Time arrival projections')
    title(['Angle =',num2str(ang(Id))])
    xlim([0,length(z)])
    %ylim([3e-5,3.07e-5])
end

%% IRadon

% B = fliplr(N_amp(:,1:19));
 
% si = [N_amp(:,1:19), B];

Phi = round(linspace(0,180,19));

%reconstruction = iradon(maximos, theta);
reconstruction2 = iradon(N_time, Phi,"Ram-Lak");%"None");%
reconstruction2 = reconstruction2 / max(reconstruction2, [], 'all');

reconstruction_resized = imresize(reconstruction2, [Nx, Nx]);
%reconstruction_resized2 = imresize(reconstruction2, [Nx, Nx]);

reconstruction_resized = flip(reconstruction_resized);
%%
figure;
%imshow(reconstruction, []);
imshow(reconstruction_resized, []);
title('reconstruction iradon with imresize')

figure;
imshow(reconstruction2, []);%reconstruction_resized2, []);
title('reconstruction iradon original');% \Delta t')

% === GUARDAR LA IMAGEN COMO ARCHIVO ===
folderPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\fotos_basedbyTomo\a'; % o la ruta que prefieras
if ~exist(folderPath, 'dir')
    mkdir(folderPath);
end

fileName = '1500.png'; % Puedes cambiar el nombre o hacerlo dinámico
fullPath = fullfile(folderPath, fileName);

% Normalizar a 0-255 y convertir a uint8 si es necesario
img_to_save = uint8(255 * mat2gray(reconstruction_resized));
imwrite(img_to_save, fullPath);

disp(['Imagen guardada en: ', fullPath])

%% Error projections

iradon_error = [];
%iradon_error2 = [];

%ImagenBinaria = x01;
%ImagenBinaria = double(ImagenBinaria);
ImagenBinaria = double(Elipse);

for projections=1:19
    
    Theta = round(linspace(0, 180, projections));  
    num_angles = length(Theta);  % Número de ángulos para esta iteración
    vector = round(linspace(1,19,projections));
    reconstruction2 = flip(iradon(N_amp(:,vector), Theta,"None")); %1:num_angles
    %reconstruction2 = 100*reconstruction2;
    reconstruction2 = reconstruction2 / max(reconstruction2, [], "all");

    reconstruction_resized = imresize(reconstruction2, size(ImagenBinaria), 'bicubic');
    %Elipse_resized = imresize(Elipse, size(reconstruction2), 'bicubic');

    % figure;
    % imshow(reconstruction_resized, []);
    % title(['Iradon reconstruction with ', num2str(projections)])

    je = abs(reconstruction_resized-ImagenBinaria);
    %je = abs(reconstruction2-Elipse_resized);
    %je = je/max(je, [], "all");
    
    figure;
    imshow(je, []);
    title('error')

    xdd = rms(je(:));
    xddd = immse(reconstruction_resized,ImagenBinaria);
    %xddd = immse(reconstruction2,Elipse_resized);

    iradon_error = [iradon_error, xddd];
    %iradon_error2 = [iradon_error2, xddd];
    %iradon_error3 = [iradon_error3, xddd];
    %iradon_error4 = [iradon_error4, xddd];
    %iradon_error6 = [iradon_error6, xddd];
    %iradon_error5 = [iradon_error5, xddd];
end

%%
figure;
plot(iradon_error);
