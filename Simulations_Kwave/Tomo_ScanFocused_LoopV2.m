%%% Example based on example Focused transducer
tic
clearvars;

%ang=[0,90];
%ang=[0,45,90];
ang=[0,10,20,30,40,50,60,70,80,90, 100, 110, 120, 130, 140, 150, 160, 170, 180];
k=1;
signals=zeros(866,length(ang));

for j=1:length(ang)


% =========================================================================
% SIMULATION
% =========================================================================

% create the computational grid
Nx = 216;           % number of grid points in the x (row) direction
Ny = Nx;           % number of grid points in the y (column) direction
dx = 50e-3/Nx;    	% grid point spacing in the x direction [m]
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
    t_end = 40e-6;       % [s]
    %kgrid.makeTime(medium.sound_speed, [], t_end);
    kgrid.t_array = makeTime(kgrid, medium.sound_speed, [], t_end);

% =========================================================================
% DEFINE THE INPUT SIGNAL
% =========================================================================
    
    % define properties of the input signal
    source_strength = 1e6;          % [Pa]
    tone_burst_freq = 0.5e6;        % [Hz]
    tone_burst_cycles = 5;
    
    % create the input signal using toneBurst 
    input_signal_s = toneBurst(1/kgrid.dt, tone_burst_freq, tone_burst_cycles);
    
    % scale the source magnitude by the source_strength divided by the
    % impedance (the source is assigned to the particle velocity)
    input_signal = (source_strength ./ (medium.sound_speed(1) * medium.density(1))) .* input_signal_s;


% =======================================================================
% To the define an Elipse as discontinuity
%===================
a = 30;  % Radio mayor del elipse 
b = 10;  % Radio menor del elipse 
x0 = Nx/2; % Centro del elipse en x
y0 = Ny/2; % Centro del elipse en y

[x, y] = meshgrid(1:Nx, 1:Ny);


    disp('----------------')
    disp(['Ang = ',num2str(ang(j))])
    disp('----------------')
    theta=deg2rad(ang(j));
    %ellipse_mask = ((x - x0).^2 / a^2 + (y - y0).^2 / b^2) <= 1;
    ellipse_mask = ((x - x0)*cos(theta)+(y-y0)*sin(theta)).^2/a^2+...
         ((x - x0)*sin(theta)-(y-y0)*cos(theta)).^2/b^2<= 1;

    %figure;
    %imshow(ellipse_mask, []);
    
    medium.sound_speed(ellipse_mask) = 1540; % Velocidad del sonido en el sólido [m/s]
    medium.density(ellipse_mask) = 1100;     % Densidad del sólido [kg/m^3] 
    medium.alpha_coeff(ellipse_mask) = 10.75;  % [dB/(MHz^y cm)]
    medium.alpha_power = 1.5;
       
    % Position of the transducer's center
    z= Nx/2-80:10:Nx/2+80;
    
    amplitude=zeros(2,length(z)); 
    
    for i=1:length(z)
        pos=z(i); %Position of the transducer in x-axis
         %disp('----------------')
        disp(['-------- > Angle = ', num2str(ang(j)), '-------- > Sensor = ',num2str(i)])
        %disp('----------------')
        % define a curved transducer element
        arc_pos = [35, pos];         % [grid points]    
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
        sensor.mask(Nx - 20, z) = 1;
        sensor.record = {'p'};
        
        % assign the input options
        input_args = {'DisplayMask', ...
            display_mask+sensor.mask+ellipse_mask, 'PMLInside', false, ...
            'PlotPML', false    'PlotLayout', false,'PlotScale', ...
            [-1 1],'PlotSim', true};
        
        % run the simulation
        sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor,...
       input_args{:});
       %figure() 
       %plot(sensor_data.p(i,:))
       %amplitude(j,k)=max(sensor_data.p(i,:));
       signals(:,k)=sensor_data.p(i,:);
       k=k+1;
    end
    %figure()
    %plot(amplitude(j,:))
    %title(['Angle= ',num2str(ang(j))])
    %SensorRes(:,j)=amplitude(:);
    %figure
    
    
end
toc
%%
figure('Position',[1 1 500 800])
t=1:866;
h = stackedplot(t,signals(:,18:34),'k');

%%
%save Results0_to_90.mat signals
%load results1.mat
%figure   %(Modficar, fijo)
amp=zeros(length(z),length(ang));
delta_t = zeros(length(z),length(ang));
N_amp = [];
N_time = [];

for a=1:length(ang)
    k=1;
    for i=1+(a-1)*length(z):length(z)*a
        [amp(k,a), indice]=max(signals(:,i));
        delta_t(k,a) = kgrid.t_array(indice);

        k=k+1;
    end
    N_amp = [N_amp, abs(amp(:,a)-max(amp(:,a)))];
    N_time = [N_time, abs(delta_t(:,a)-max(delta_t(:,a)))];
end

%%
%clearvars
%load Results1.mat

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
%% Si corriste K-wave simulation toma esto para el error
phi = round(linspace(0,180,19));%0:10:180;
reconstruction = iradon(N_amp, phi,'None');
reconstruction2 = iradon(N_time, phi,'None');
Nx = 216;
reconstruction_resized = imresize(reconstruction, [Nx, Nx]);
reconstruction_resized2 = imresize(reconstruction2, [Nx, Nx]);
%%
figure; 
imshow(reconstruction_resized, [])
title('Reconstruction with amplitude')

figure; 
imshow(reconstruction_resized2, [])
title('Reconstruction with time')
%% Projection error
Elipse = double(ellipse_mask);


iradon_error = [];
iradon_error2 = [];
for projections=1:19%num_angles
     
    Theta = round(linspace(0, 180, projections));  
    num_angles = length(Theta);  % Número de ángulos para esta iteración

    %reconstruction = iradon(N_time(:,1:num_angles), Theta,"None");%,"Ram-Lak");
    reconstruction = iradon(N_amp(:,1:num_angles), Theta,"None");
    reconstruction = reconstruction / max(reconstruction, [], "all");
    reconstruction_resized = imresize(reconstruction, [Nx, Nx]);

    %reconstruction2 = iradon(N_amp(:,1:num_angles), Theta,"None");%,"Ram-Lak");
    %reconstruction2 = reconstruction2 / max(reconstruction2, [], "all");
    %reconstruction_resized2 = imresize(reconstruction2, [Nx, Nx]);
    %reconstruction_resized = reconstruction_resized / max(reconstruction_resized, [], 'all');

    R=radon(Elipse,Theta);
    I=iradon(R,Theta,'None');
    I / max(I,  [],'all');
    I_resized = imresize(reconstruction, [Nx, Nx]);
    %I_resized = I_resized/max(I, [], 'all');

    % figure;
    % imshow(reconstruction_resized, []);
    % title(['Iradon reconstruction with ', num2str(projections)])

    je = abs(reconstruction_resized-Elipse);
    %je = je / max(je,[],'all');
    %je2 = abs(reconstruction_resized2-Elipse);
    
    figure;
    imshow(je, []);
    title('Numerical error')

    % figure;
    % imshow(je2, []);
    % title('Analytic error')

    xdd = rms(je(:));
    error = immse(reconstruction_resized,Elipse);
    iradon_error = [iradon_error, error];

    %xd2 = rms(je2(:));
    %error_immse = immse(reconstruction_resized2,Elipse);
    %iradon_error2 = [iradon_error2, error_immse];
end

figure;
plot(iradon_error,'o-')
%hold on;
%plot(iradon_error2,'o-')
hold on;
plot(error_vector2, 'o-')
hold off;
%plot(iradon_error2,'o-')
xlabel('angles number')
ylabel('mse error')
%legend('Kwave time projections','Kwave amplitude projections', 'Radon')
legend('Kwave amplitude projections', 'Radon')
title("Radon vs K-wave error")
% figure;
% imshow(reconstruction, []);
% title('reconstruction amplitude')
% 
% figure;
% imshow(reconstruction2, []);
% title('reconstruction \Delta t')

%% Rays error
Elipse = double(ellipse_mask);


iradon_error_rays = [];
iradon_error_rays2 = [];

[num_rays, num_angles] = size(N_amp);  % Número de ángulos para esta iteración

for rays=1:num_rays
     
    Theta = round(linspace(0, 180, 19));  
    
    reconstruction = iradon(N_amp(1:rays,:), Theta,"None");%,"Ram-Lak");
    reconstruction = reconstruction / max(reconstruction, [], "all");
    reconstruction_resized = imresize(reconstruction, [Nx, Nx]);
    %reconstruction_resized = reconstruction_resized / max(reconstruction_resized, [], 'all');

    % R=radon(Elipse,Theta);
    % I=iradon(R(1:rays,:),Theta,'None');
    % I=I / max(I,  [],'all');
    % I_resized = imresize(reconstruction, [Nx, Nx]);
    %I_resized = I_resized/max(I, [], 'all');

    % figure;
    % imshow(reconstruction_resized, []);
    % title(['Iradon reconstruction with ', num2str(projections)])

    je = abs(reconstruction_resized-Elipse);
    % je = je / max(je,[],'all');
    % je2 = abs(I_resized-Elipse);
    
    % figure;
    % imshow(je, []);
    % title('Numerical error')

    % figure;
    % imshow(je2, []);
    % title('Analytic error')

    xdd = rms(je(:));
    error = immse(reconstruction_resized,Elipse);
    iradon_error_rays = [iradon_error_rays, error];

    xd2 = rms(je2(:));
    error_immse = immse(I_resized,Elipse);
    iradon_error_rays2 = [iradon_error_rays2, error_immse];
end

figure;
plot(iradon_error,'o-')
hold on;
plot(error_vector2, 'o-')
%plot(iradon_error2,'o-')
xlabel('projections number')
ylabel('mse error')
legend('Kwave','Analytic')
title("Analytic vs numerical error")
% figure;
% imshow(reconstruction, []);
% title('reconstruction amplitude')
% 
% figure;
% imshow(reconstruction2, []);
% title('reconstruction \Delta t')

%%
% set the record mode capture the final wave-field and the statistics at
% each sensor point 
%sensor.record = {'p_final', 'p_max', 'p_rms'};

% assign the input options
input_args = {'DisplayMask', display_mask, 'PMLInside', false, 'PlotPML', false};%    'PlotLayout', true,'PlotScale', [-0.25 0.25]};

% run the simulation
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});

% =========================================================================
% VISUALISATION
% =========================================================================

%%

%projections=10;
Theta = 0:10:180;%round(linspace(0, 180, projections));
B = fliplr(Energia(:,1:10));

si = [delta_t(:,1:10), B];
% Columnas representan los sinogramas para cada ángulo
sinogram = N_amp;%si;%amp;%delta_t;%radon(Elipse, Theta);  % 367x360
[N, num_angles] = size(sinogram);

% 3. Aplicar la Transformada de Fourier a cada proyección
sin_fft = fft(sinogram); % S_theta(w) Fourier Slice Theorem 

% 4. Filtrado
L = 1/(20*t_end);
w = linspace(-L, L, N)';
H = abs(w); % filtro de Ram-Lak
%H = abs(w).* sinc(w); % Filtro de Sheep - Logan
%H = abs(w).* cos(w/2*); % Filtro Coseno
% beta= 0.54;
%H = abs(w).* (beta+(1-beta)*cos(w)); % Filtro Hamming
filtered_projection = abs(ifft(sin_fft .* H));

% 5. Inicializar la imagen reconstruida
f = zeros(Nx);

x_center = round(Nx/2);
y_center = round(Nx/2);

% 6. Backprojection
for alpha = 1:num_angles-1
    theta_rad = deg2rad(Theta(alpha));
    Q_theta = filtered_projection(:, alpha);

    for x = 1:Nx
        for y = 1:Nx
            pixel_x = (x-x_center);
            pixel_y = (y-y_center);
            t = (x - x_center) * cos(theta_rad) + (y - y_center) * sin(theta_rad);
            s =-(x - x_center) * sin(theta_rad) + (y - y_center) * cos(theta_rad);
        
            t_index = round(s + (N / 2)); % Ajuste de índice
            if t_index >= 1 && t_index <= N
                f(x, y) = f(x, y) + Q_theta(t_index);
            end
        end
    end
end

% Normalizar la imagen reconstruida
f = f/max(f,[],"all");
f = (pi / (2*num_angles))*f;

figure;
imshow(f, []);
title('Reconstruction')


%% Comparative projections error

iradon_error = [];  % Para almacenar el error cuadrático entre reconstrucciones
prev_reconstruction = [];  % Para almacenar la imagen anterior

for projections = 2:19  % Comenzamos en 2 para calcular diferencias con n-1
    
    % Definir ángulos equiespaciados según el número de proyecciones
    Theta = round(linspace(0, 180, projections));
    num_angles = length(Theta);  

    % Realizar la reconstrucción usando iradon
    reconstruction = iradon(N_amp(:, 1:num_angles), Theta, "None");
    reconstruction_resized = imresize(reconstruction, size(Elipse), 'bicubic');
    reconstruction_resized = reconstruction_resized / max(reconstruction_resized, [], "all");

    % Mostrar la reconstrucción actual
    figure;
    imshow(reconstruction_resized, []);
    title(['Reconstrucción con ', num2str(projections), ' proyecciones']);

    % Calcular el error cuadrático entre imágenes consecutivas
    if ~isempty(prev_reconstruction)
        error = sum((reconstruction_resized(:) - prev_reconstruction(:)).^2);
        iradon_error = [iradon_error, error];
    end

    % Actualizar la imagen anterior
    prev_reconstruction = reconstruction_resized;
end
%%
% Graficar el error cuadrático en función del número de proyecciones
figure;
plot(2:19, iradon_error, '-o');
xlabel('Número de Proyecciones');
ylabel('Error Cuadrático');
title('Variación Cuadrática entre Reconstrucciones Consecutivas');
