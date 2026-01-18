%%% Example based on example Focused transducer
tic
% clearvars;

%ang=[0,90];
%ang=[0,45,90];
ang=[0,10,20,30,40,50,60,70,80,90, 100, 110, 120, 130, 140, 150, 160, 170, 180];
%ang=[0, 4, 7, 11, 15, 18, 22, 26, 29, 33, 37, 40, 44, 48, 51, 55, 59, 62, 66, 70, 73, 77, 81, 84, 88, 92, 96, 99, 103, 107, 110, 114, 118, 121, 125, 129, 132, 136, 140, 143, 147, 151, 154, 158, 162, 165, 169, 173, 176, 180];
k=1;
signals=zeros(866,length(ang));


for j=1:length(ang)


% =========================================================================
% SIMULATION
% =========================================================================

% create the computational grid
Nx = 216;          % number of grid points in the x (row) direction
Ny = Nx;           % number of grid points in the y (column) direction
dx = 50e-3/Nx;    	% grid point spacing in the x direction [m]
dy = dx;            % grid point spacing in the y direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% define the properties of the propagation medium
medium.sound_speed = 1500* ones(Nx, Ny);  % [m/s]
medium.alpha_coeff = 0.75* ones(Nx, Ny);  % [dB/(MHz^y cm)]
medium.alpha_power = 1.5* ones(Nx, Ny);
medium.density = 1000* ones(Nx, Ny);     % [kg/m^3]

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
%a = 30;  % Radio mayor del elipse 
%b = 10;  % Radio menor del elipse 
x0 = Nx/2; % Centro del elipse en x
y0 = Ny/2; % Centro del elipse en y

%[x, y] = meshgrid(1:Nx, 1:Ny);


    disp('----------------')
    disp(['Ang = ',num2str(ang(j))])
    disp('----------------')
    theta=ang(j);
    
    Imagen = zeros(Nx, Ny);
    texto = 'a'; % Cambia 'A' por la letra que desees
    posicion = [x0, y0-10]; % Posición aproximada en el centro
    ImagenConTexto = insertText(Imagen, posicion, texto, 'FontSize', 100,  'BoxOpacity', 0, 'TextColor', 'white',Anchorpoint='center');
    % 'Font', 'Lucida Calligraphy',
    % ImagenBinaria = IB;
    ImagenBinaria = imbinarize(rgb2gray(ImagenConTexto), 0); %im2double for gets the double value letters directly                

    rot = imrotate(ImagenBinaria, theta, 'nearest', 'crop');

    % Asignar propiedades de la LETRA al medio
    medium.sound_speed(rot == 1) = 1639;%1540;  % velocidad del sonido en la elipse
    medium.density(rot == 1) = 1100;      % Densidad de la elipse (Phlantom Materials for Elastography)
    medium.alpha_coeff(rot == 1) = 10.75;  % [dB/(MHz^y cm)]
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
        arc_pos = [1, pos];         % [grid points]    
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
        sensor.mask(Nx, z) = 1;
        sensor.record = {'p'};
        
        % assign the input options
        input_args = {'DisplayMask', ...
            display_mask+sensor.mask+rot, 'PMLInside', false, ...
            'PlotPML', false    'PlotLayout', false,'PlotScale', ...
            [-1 1],'PlotSim', true, 'RecordMovie', true, 'MovieName', '04'};
        
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
    %subplot(4, 5, Id) ;
    subplot(5, 10, Id);
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
    %subplot(4, 5, Id) ;
    subplot(5, 10 , Id) ;
    plot(x,N_time(:,Id),'-o');
    sgtitle('Time arrival projections')
    title(['Angle =',num2str(ang(Id))])
    xlim([0,length(z)])
    %ylim([3e-5,3.07e-5])
end

%% IRadon

% B = fliplr(N_amp(:,1:19));
 
% si = [N_amp(:,1:19), B];
Nx = 216;
Phi = round(linspace(0,180,19));

%reconstruction = iradon(maximos, theta);
reconstruction2 = iradon(N_time, Phi,"None");%,"Ram-Lak");delta_tflip(
reconstruction2 = reconstruction2 / max(reconstruction2, [], 'all');

reconstruction_resized = imresize(reconstruction2, [Nx, Nx]);
%reconstruction_resized2 = imresize(reconstruction2, [Nx, Nx]);

reconstruction_resized = flip(reconstruction_resized);

figure;
%imshow(reconstruction, []);
imshow(reconstruction_resized, []);
title('reconstruction iradon with imresize')

figure;
imshow(reconstruction2, []);%reconstruction_resized2, []);
title('reconstruction iradon original');% \Delta t')

%% Error projections

Nx = 216;
iradon_error = [];
%iradon_error2 = [];

ImagenBinaria = double(ImagenBinaria);%ImagenEscalada);%

% figure;
% imshow(reconstruction_resized, [])

%%
iradon_error = [];

[num_rays, num_angles02] = size(N_amp);  % Número de ángulos para esta iteración

%ImagenBinaria = double(ImagenBinaria);
%Imagen = ImagenBinaria;
% ImagenBinaria02 = imcrop(ImagenBinaria, [80,80,60,60]);
% ImagenBinaria02 = imresize(ImagenBinaria02,[216,216]);
% ImagenBinaria02 = ImagenBinaria02 / max(ImagenBinaria02, [], 'all');
ellipse_mask = double(img);%ellipse_mask);


for projections=1:num_angles02
    
    Theta = round(linspace(0, 180, projections));  
    %num_angles = length(Theta);  % Número de ángulos para esta iteración
    vector = round(linspace(1,num_angles02,projections));
    reconstruction2 = flip(iradon(N_time(:,vector), Theta, "Ram-Lak"));% Theta,"None");
    %reconstruction2 = reconstruction2 / max(reconstruction2, [], "all");

    %reconstruction_resized = imresize(reconstruction2, size(ellipse_mask), 'bicubic');%size(ImagenBinaria), 'bicubic');
    %reconstruction_resized = reconstruction_resized / max(reconstruction_resized, [], "all");
    %reconstruction_resized = imresize(reconstruction2, size(ImagenBinaria), 'bicubic');
    reconstruction_resized = imresize(reconstruction2, size(ellipse_mask), 'bicubic');
    reconstruction_resized = reconstruction_resized / max(reconstruction_resized, [], "all");

    %reconstruction_resized = imbinarize(reconstruction_resized);
    %reconstruction_resized = double(reconstruction_resized);
    % figure;
    % imshow(reconstruction_resized, []);
    % title(['Iradon reconstruction with ', num2str(projections)])

    %je = abs(reconstruction_resized-Imagen);%ImagenBinaria02);%
    je = abs(reconstruction_resized-ellipse_mask);

    xdd = rms(je(:));
    %xddd = immse(reconstruction_resized,Imagen);%ImagenBinaria02);%
    xddd = immse(reconstruction_resized,ellipse_mask);

    figure;
    imshow(je, []);
    title(['mse error ', num2str(xddd)])

    iradon_error = [iradon_error, xddd];
end
%je = je/max(je, [], "all");
%iradon_error = iradon_error/max(iradon_error, [], 'all');
%%
figure;
plot(iradon_error);


%%
figure;
plot(Imagen(:, 216/2));
hold on;
plot(reconstruction_resized(:,216/2));
legend('Original', 'Reconstruction')

%%

%Elipse = double(ellipse_mask);


iradon_error_rays = [];
iradon_error_rays2 = [];

[num_rays, num_angles] = size(N_amp);  % Número de ángulos para esta iteración

for rays=1:num_rays
     
    Theta = round(linspace(0, 180, 19));  
    vector = round(linspace(1, num_rays, rays));
    reconstruction = iradon(N_amp(vector,:), Theta,"None");%,"Ram-Lak");
    %reconstruction = reconstruction / max(reconstruction, [], "all");
    reconstruction_resized = imresize(reconstruction, [Nx, Nx], 'bicubic');
    reconstruction_resized = reconstruction_resized / max(reconstruction_resized, [], 'all');

    %R=radon(Elipse,Theta);
    %I=iradon(R(vector,:),Theta,'None');
    % I=I / max(I,  [],'all');
    % I_resized = imresize(reconstruction, [Nx, Nx]);
    %I_resized = I_resized/max(I, [], 'all');

    % figure;
    % imshow(reconstruction_resized, []);
    % title(['Iradon reconstruction with ', num2str(projections)])

    je = abs(reconstruction_resized-Elipse);
    % je = je / max(je,[],'all');
    % je2 = abs(I_resized-Elipse);
    
    figure;
    imshow(je, []);
    title('Numerical error')

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
plot(iradon_error_rays2,'o-')
hold on;
%plot(error_vector2, 'o-')
%plot(iradon_error2,'o-')
xlabel('rays number')
ylabel('mse error')
%legend('Kwave','Analytic')
title("Analytic vs numerical error")
% figure;
% imshow(reconstruction, []);
% title('reconstruction amplitude')
% 
% figure;
% imshow(reconstruction2, []);
% title('reconstruction \Delta t')

