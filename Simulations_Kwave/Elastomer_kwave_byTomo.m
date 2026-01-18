%% Simulacion para una elipse sin fallas del sistema
% Example based on example Focused transducer

tic
clearvars;

%ang=[0,90];
%ang=[0,45,90];
ang=[0,10,20,30,40,50,60,70,80,90, 100, 110, 120, 130, 140, 150, 160, 170, 180];
k=1;
signals=zeros(973,length(ang));

for j=1:length(ang)

% =========================================================================
% SIMULATION
% =========================================================================

% create the computational grid
Nx = 216;                   % number of grid points in the x (row) direction
Ny = Nx;                    % number of grid points in the y (column) direction
dx = 10e-3/Nx;%5e-4;%50e-3/Nx;    % grid point spacing in the x direction [m]
dy = dx;                    % grid point spacing in the y direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% define the properties of the propagation medium
medium.sound_speed = 1500* ones(Nx, Ny);  % [m/s]
medium.alpha_coeff = 0.75* ones(Nx, Ny);  % [dB/(MHz^y cm)]
medium.alpha_power = 1.5* ones(Nx, Ny);
medium.density = 1000* ones(Nx, Ny);     % [kg/m^3]

%=====================
    % create time array
    %kgrid.makeTime(medium.sound_speed);
    t_end = 9e-6;       % [s]
    %kgrid.makeTime(medium.sound_speed, [], t_end);
    kgrid.t_array = makeTime(kgrid, medium.sound_speed, [], t_end);

% =========================================================================
% DEFINE THE INPUT SIGNAL
% =========================================================================
    
    % define properties of the input signal
    source_strength = 0.99e6;%1e6;%          % Elastomer properties [Pa]
    tone_burst_freq = 5e6;        % [Hz]
    tone_burst_cycles = 5;
    
    % create the input signal using toneBurst 
    input_signal_s = toneBurst(1/kgrid.dt, tone_burst_freq, tone_burst_cycles);
    
    % scale the source magnitude by the source_strength divided by the
    % impedance (the source is assigned to the particle velocity)
    input_signal = (source_strength ./ (medium.sound_speed(1) * medium.density(1))) .* input_signal_s;


% =======================================================================
% To the define an Elipse as discontinuity
%===================
a = 32.75;  % Radio mayor del elipse 
b = 24.25;  % Radio menor del elipse 
x0 = Nx/2; % Centro del elipse en x
y0 = Ny/2; % Centro del elipse en y

[x, y] = meshgrid(1:Nx, 1:Ny);

    disp('----------------')
    disp(['Ang = ',num2str(ang(j))])
    disp('----------------')
    %theta=ang(j);
    theta = deg2rad(ang(j));
    %radius = 20;
    %disc = makeDisc(Nx, Ny, x0, y0, radius);
    %rot = imrotate(disc, theta, 'nearest', 'crop');
    %ellipse_mask = rot;
    
    ellipse_mask = ((x - x0)*cos(theta)+(y-y0)*sin(theta)).^2/a^2+...
         ((x - x0)*sin(theta)-(y-y0)*cos(theta)).^2/b^2<= 1;

    medium.sound_speed(ellipse_mask == 1) = 951;%1540; % Velocidad del sonido en el sólido [m/s]
    medium.density(ellipse_mask == 1) = 1040;     % Densidad del sólido [kg/m^3] 
    medium.alpha_coeff(ellipse_mask == 1) = 10;%.75;  % [dB/(MHz^y cm)]
    medium.alpha_power = 1.5;
       
    % Position of the transducer's center
    z= Nx/2-80:25:Nx/2+80; %round(3/(1000*dx))
    
    amplitude=zeros(2,length(z)); 
    
    for i=1:length(z)
        pos=z(i); %Position of the transducer in x-axis
         %disp('----------------')
        disp(['-------- > Angle = ', num2str(ang(j)), '-------- > Sensor = ',num2str(i)])
        %disp('----------------')
        % define a curved transducer element
        arc_pos = [50, pos];         % [grid points]    
        radius = 50;                 % [grid points]
        diameter = 41;               % [grid points]
        %focus_pos = [Nx/2, Nx/2];   % [grid points]
        focus_pos = [200, pos];      % [grid points]
        source.p_mask = makeArc([Nx, Ny], arc_pos, radius, diameter, focus_pos);
        source.p = input_signal;
        
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

%% Elipse con discontinuidad

tic
clearvars;

%ang=[0,90];
%ang=[0,45,90];
ang=[0,10,20,30,40,50,60,70,80,90, 100, 110, 120, 130, 140, 150, 160, 170, 180];
k=1;
signals=zeros(958,length(ang));

for j=1:length(ang)

% =========================================================================
% SIMULATION
% =========================================================================

    % create the computational grid
    Nx = 216;                   % number of grid points in the x (row) direction
    Ny = Nx;                    % number of grid points in the y (column) direction
    dx = 4.7e-4;%50e-3/Nx;    % grid point spacing in the x direction [m]
    dy = dx;                    % grid point spacing in the y direction [m]
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
    kgrid.t_array = makeTime(kgrid, medium.sound_speed, [], t_end);

% =========================================================================
% DEFINE THE INPUT SIGNAL
% =========================================================================
    
    % define properties of the input signal
    source_strength = 0.99e6;          % Elastomer properties [Pa]
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

    disp('----------------')
    disp(['Ang = ',num2str(ang(j))])
    disp('----------------')
    %theta=ang(j);
    Theta = deg2rad(ang(j));
    %radius = 20;
    %disc = makeDisc(Nx, Ny, x0, y0, radius);
    %rot = imrotate(disc, theta, 'nearest', 'crop');
    %ellipse_mask = rot;
    
    % Matrices independientes para cada elipse
    ellipse_mask = zeros(Nx);
    ellipse_mask2 = zeros(Nx);
    
    % Parámetros de la elipse grande
    a_outer = 32.75;  % Radio mayor del elipse 
    b_outer = 24.25;  % Radio menor del elipse 
    x0 = Nx/2; % Centro del elipse en x
    y0 = Ny/2; % Centro del elipse en y
    
    % Parámetros de la elipse pequeña (dentro de la grande)
    a_inner = 9.7/2;
    b_inner = 7.43/2;
    
    % Posición relativa de la elipse pequeña respecto al centro de la grande
    deltax = -15;
    deltay = -5;
    
    % Ángulo de rotación (en grados)
    %angle_deg = 0;
    theta = Theta;%deg2rad(angle_deg);
    
    % Rellenar las elipses
    for x = 1:Nx
        for y = 1:Nx
            % Coordenadas relativas al centro de cada elipse
            % Elipse grande
            pixelx_outer = (x - x0);
            pixely_outer = (y - y0);
    
            % Calcular la nueva posición de la elipse pequeña tras la rotación
            xcenter_inner = x0 + (deltax * cos(theta) - dy * sin(theta));
            ycenter_inner = y0 + (deltax * sin(theta) + dy * cos(theta));
    
            xrot_outer = pixelx_outer * cos(theta) + pixely_outer * sin(theta);
            yrot_outer = pixely_outer * cos(theta) - pixelx_outer * sin(theta);
            
            if (xrot_outer^2 / a_outer^2 + yrot_outer^2 / b_outer^2 <= 1)
                ellipse_mask(Nx - y + 1, x) = 1;
            end
    
            % Elipse pequeña (mantiene su posición relativa a la grande)
            pixelx_inner = (x - xcenter_inner);
            pixely_inner = (y - ycenter_inner);
            xrot_inner = pixelx_inner * cos(theta+pi/2) + pixely_inner * sin(theta+pi/2);
            yrot_inner = pixely_inner * cos(theta+pi/2) - pixelx_inner * sin(theta+pi/2);
            
            if (xrot_inner^2 / a_inner^2 + yrot_inner^2 / b_inner^2 <= 1)
                ellipse_mask2(Nx - y + 1, x) = 1;
            end
        end
    end
    
    % Sumar las dos matrices sin fusionarlas
    Sistema = ellipse_mask + ellipse_mask2;

    %rot = imrotate(Sistema, Theta, 'nearest', 'crop');
    %ellipse_mask = rot;

    medium.sound_speed(ellipse_mask == 1) = 951;%1639;%%1540; % Velocidad del sonido en el sólido [m/s]
    medium.density(ellipse_mask == 1) = 1040;%1000;%     % Densidad del sólido [kg/m^3] 
    medium.alpha_coeff(ellipse_mask == 1) = 10;%.75;%2;%  % [dB/(MHz^y cm)]
    medium.alpha_power = 1.5;

    medium.sound_speed(ellipse_mask2 == 1) = 1500; % Velocidad del sonido en el sólido [m/s]
    medium.density(ellipse_mask2 == 1) = 1000;     % Densidad del sólido [kg/m^3] 
    medium.alpha_coeff(ellipse_mask2 == 1) = 0.75;  % [dB/(MHz^y cm)]
    medium.alpha_power = 1.5;
       
    % Position of the transducer's center
    z= Nx/2-80:round(3/(1000*dx)):Nx/2+80; 
    
    amplitude=zeros(2,length(z)); 
    
    for i=1:length(z)
        pos=z(i); %Position of the transducer in x-axis
         %disp('----------------')
        %disp(['-------- > Angle = ', num2str(ang(j)), '-------- > Sensor = ',num2str(i)])
        %disp('----------------')
        % define a curved transducer element
        arc_pos = [50, pos];         % [grid points]    
        radius = 50;                 % [grid points]
        diameter = 41;               % [grid points]
        %focus_pos = [Nx/2, Nx/2];   % [grid points]
        focus_pos = [200, pos];      % [grid points]
        source.p_mask = makeArc([Nx, Ny], arc_pos, radius, diameter, focus_pos);
        source.p = input_signal;
        
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
            display_mask+sensor.mask+Sistema, 'PMLInside', false, ...
            'PlotPML', false, 'PlotLayout', false,'PlotScale', ...
            [-1 1],'PlotSim', true};
        
        % run the simulation
        sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor,...
       input_args{:});
       %figure() 
       %plot(sensor_data.p(i,:))
       %amplitude(j,k)=max(sensor_data.p(i,:));
       signals(:,k)=sensor_data.p(i,:);
       k=k+1;

        
       % Visualizar la distribución de sensores y fuentes
    figure;
    imagesc(medium.sound_speed);
    hold on;
    plot(x0, y0, 'rx', 'MarkerSize', 10, 'LineWidth', 2); % centro de la elipse
    [y_sensor_pos, x_sensor_pos] = find(sensor.mask == 1);
    plot(x_sensor_pos, y_sensor_pos, 'ro', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de los sensores
    [y_source_pos, x_source_pos] = find(source.p_mask == 1);
    plot(x_source_pos, y_source_pos, 'go', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de las fuentes
    title(['Velocidad del sonido sobre el medio en Ángulo: ', num2str(theta)]);
    colorbar;
    axis image;
    hold off;

    figure;
    imagesc(medium.density);
    hold on;
    plot(x0, y0, 'rx', 'MarkerSize', 10, 'LineWidth', 2); % centro de la elipse
    [y_sensor_pos, x_sensor_pos] = find(sensor.mask == 1);
    plot(x_sensor_pos, y_sensor_pos, 'ro', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de los sensores
    [y_source_pos, x_source_pos] = find(source.p_mask == 1);
    plot(x_source_pos, y_source_pos, 'go', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de las fuentes
    title(['Densidad sobre el medio en Ángulo: ', num2str(theta)]);
    colorbar;
    axis image;
    hold off;


    figure;
    imagesc(medium.alpha_coeff);
    hold on;
    plot(x0, y0, 'rx', 'MarkerSize', 10, 'LineWidth', 2); % centro de la elipse
    [y_sensor_pos, x_sensor_pos] = find(sensor.mask == 1);
    plot(x_sensor_pos, y_sensor_pos, 'ro', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de los sensores
    [y_source_pos, x_source_pos] = find(source.p_mask == 1);
    plot(x_source_pos, y_source_pos, 'go', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de las fuentes
    title(['Coeficiente de atenuación en el medio en Ángulo: ', num2str(theta)]);
    colorbar;
    axis image;
    hold off;


    figure;
    imagesc(medium.alpha_power);
    hold on;
    plot(x0, y0, 'rx', 'MarkerSize', 10, 'LineWidth', 2); % centro de la elipse
    [y_sensor_pos, x_sensor_pos] = find(sensor.mask == 1);
    plot(x_sensor_pos, y_sensor_pos, 'ro', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de los sensores
    [y_source_pos, x_source_pos] = find(source.p_mask == 1);
    plot(x_source_pos, y_source_pos, 'go', 'MarkerSize', 5, 'LineWidth', 1.5); % posiciones de las fuentes
    title(['Exponente de atenuación sobre el medio en Ángulo: ', num2str(theta)]);
    colorbar;
    axis image;
    hold off;
    

    end
    %figure()
    %plot(amplitude(j,:))
    %title(['Angle= ',num2str(ang(j))])
    %SensorRes(:,j)=amplitude(:);
    %figure    
    
end
toc

%% ESCALAMIENTO DEL SISTEMA ELIPSE-DISCONTINUIDAD PARA 5 MHZ
tic
clearvars;

%ang=[0,90];
%ang=[0,45,90];
ang=[0,10,20,30,40,50,60,70,80,90, 100, 110, 120, 130, 140, 150, 160, 170, 180];
k=1;
signals=zeros(973,length(ang));

for j=1:length(ang)

% =========================================================================
% SIMULATION
% =========================================================================

    % create the computational grid
    Nx = 216;                   % number of grid points in the x (row) direction
    Ny = Nx;                    % number of grid points in the y (column) direction
    dx = 10e-3/Nx;    % grid point spacing in the x direction [m]
    dy = dx;                    % grid point spacing in the y direction [m]
    kgrid = kWaveGrid(Nx, dx, Ny, dy);
    
    % define the properties of the propagation medium
    medium.sound_speed = 1500* ones(Nx, Ny);  % [m/s]
    %medium.sound_speed(1:Nx/2, :) = 1600;       % [m/s]
    medium.alpha_coeff = 0.75* ones(Nx, Ny);  % [dB/(MHz^y cm)]
    medium.alpha_power = 1.5;%* ones(Nx, Ny);
    medium.density = 1000* ones(Nx, Ny);     % [kg/m^3]
    %medium.sound_speed(1:Nx/2, :) = 900;       % [m/s]

%=====================
    % create time array
    %kgrid.makeTime(medium.sound_speed);
    t_end = 9e-6;       % [s]
    kgrid.t_array = makeTime(kgrid, medium.sound_speed, [], t_end);

% =========================================================================
% DEFINE THE INPUT SIGNAL
% =========================================================================
    
    % define properties of the input signal
    source_strength = 0.99e6;          % Elastomer properties [Pa]
    tone_burst_freq = 5e6;        % [Hz]
    tone_burst_cycles = 5;
    
    % create the input signal using toneBurst 
    input_signal_s = toneBurst(1/kgrid.dt, tone_burst_freq, tone_burst_cycles);
    
    % scale the source magnitude by the source_strength divided by the
    % impedance (the source is assigned to the particle velocity)
    input_signal = (source_strength ./ (medium.sound_speed(1) * medium.density(1))) .* input_signal_s;


% =======================================================================
% To the define an Elipse as discontinuity
%===================

    disp('----------------')
    disp(['Ang = ',num2str(ang(j))])
    disp('----------------')
    %theta=ang(j);
    Theta = deg2rad(ang(j));
    %radius = 20;
    %disc = makeDisc(Nx, Ny, x0, y0, radius);
    %rot = imrotate(disc, theta, 'nearest', 'crop');
    %ellipse_mask = rot;
    
    % Matrices independientes para cada elipse
    ellipse_mask = zeros(Nx);
    ellipse_mask2 = zeros(Nx);
    
    % Parámetros de la elipse grande
    a_outer = 32.75;  % Radio mayor del elipse 
    b_outer = 24.25;  % Radio menor del elipse 
    x0 = Nx/2; % Centro del elipse en x
    y0 = Ny/2; % Centro del elipse en y
    
    % Parámetros de la elipse pequeña (dentro de la grande)
    a_inner = 9.7/2;
    b_inner = 7.43/2;
    
    % Posición relativa de la elipse pequeña respecto al centro de la grande
    deltax = -15;
    deltay = -5;
    
    % Ángulo de rotación (en grados)
    %angle_deg = 0;
    theta = Theta;%deg2rad(angle_deg);
    
    % Rellenar las elipses
    for x = 1:Nx
        for y = 1:Nx
            % Coordenadas relativas al centro de cada elipse
            % Elipse grande
            pixelx_outer = (x - x0);
            pixely_outer = (y - y0);
    
            % Calcular la nueva posición de la elipse pequeña tras la rotación
            xcenter_inner = x0 + (deltax * cos(theta) - dy * sin(theta));
            ycenter_inner = y0 + (deltax * sin(theta) + dy * cos(theta));
    
            xrot_outer = pixelx_outer * cos(theta) + pixely_outer * sin(theta);
            yrot_outer = pixely_outer * cos(theta) - pixelx_outer * sin(theta);
            
            if (xrot_outer^2 / a_outer^2 + yrot_outer^2 / b_outer^2 <= 1)
                ellipse_mask(Nx - y + 1, x) = 1;
            end
    
            % Elipse pequeña (mantiene su posición relativa a la grande)
            pixelx_inner = (x - xcenter_inner);
            pixely_inner = (y - ycenter_inner);
            xrot_inner = pixelx_inner * cos(theta+pi/2) + pixely_inner * sin(theta+pi/2);
            yrot_inner = pixely_inner * cos(theta+pi/2) - pixelx_inner * sin(theta+pi/2);
            
            if (xrot_inner^2 / a_inner^2 + yrot_inner^2 / b_inner^2 <= 1)
                ellipse_mask2(Nx - y + 1, x) = 1;
            end
        end
    end
    
    % Sumar las dos matrices sin fusionarlas
    Sistema = ellipse_mask + ellipse_mask2;

    %rot = imrotate(Sistema, Theta, 'nearest', 'crop');
    %ellipse_mask = rot;

    medium.sound_speed(ellipse_mask == 1) = 951;%1540; % Velocidad del sonido en el sólido [m/s]
    medium.density(ellipse_mask == 1) = 1040;     % Densidad del sólido [kg/m^3] 
    medium.alpha_coeff(ellipse_mask == 1) = 10;%.75;  % [dB/(MHz^y cm)]
    %medium.alpha_power(ellipse_mask == 1) = 1.3;

    medium.sound_speed(ellipse_mask2 == 1) = 1500; % Velocidad del sonido en el sólido [m/s]
    medium.density(ellipse_mask2 == 1) = 1000;     % Densidad del sólido [kg/m^3] 
    medium.alpha_coeff(ellipse_mask2 == 1) = 0.75;%368;  % [dB/(MHz^y cm)]
    %medium.alpha_power(ellipse_mask2 == 1) = 1.24;
       
    % Position of the transducer's center
    z= Nx/2-80:25:Nx/2+80; %round(3/(1000*dx))
    
    amplitude=zeros(2,length(z)); 
    
    for i=1:length(z)
        pos=z(i); %Position of the transducer in x-axis
         %disp('----------------')
        %disp(['-------- > Angle = ', num2str(ang(j)), '-------- > Sensor = ',num2str(i)])
        %disp('----------------')
        % define a curved transducer element
        arc_pos = [50, pos];         % [grid points]    
        radius = 50;                 % [grid points]
        diameter = 41;               % [grid points]
        %focus_pos = [Nx/2, Nx/2];   % [grid points]
        focus_pos = [Nx - 50, pos];      % [grid points]
        source.p_mask = makeArc([Nx, Ny], arc_pos, radius, diameter, focus_pos);
        source.p = input_signal;
        
        % filter the source to remove high frequencies not supported by the grid
        %source.p = filterTimeSeries(kgrid, medium, source.p);
        
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
            display_mask+sensor.mask+Sistema, 'PMLInside', false, ...
            'PlotPML', false, 'PlotLayout', false,'PlotScale', ...
            [-1 1],'PlotSim', true};
        
       % run the simulation
       sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor,...
       input_args{:});
       %figure 
       %plot(sensor_data.p(i,:));
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

%% Mostrar señales
%figure('Position',[1 1 500 800])
%t=1:size(signals, 1);
%h = stackedplot(t,signals(:,218:234),'k');

for a = 1:length(ang)
    figure('Position', [1 1 500 800]);
    sgtitle(['Señales para angulo ', num2str(ang(a))])

    t = kgrid.t_array;
    k = 1;
    indices = 1 + (a - 1) * length(z) : length(z) * a; % Índices correspondientes

    % Graficar solo si los índices son válidos
    if max(indices) <= size(signals, 2)
        %subplot(length(ang), 1, a); % Crear una subfigura para cada ángulo
        stackedplot(t, signals(:, indices), 'k');%hilbert(abs(signals(:, indices))), 'k');%
        stackedplot(t, signals_failure(:, indices), 'k');
        %title(['Señales para ángulo ', num2str(ang(a))]);
        %xlabel('Tiempo (índices)');
        %ylabel('Amplitud');
    end
end


%% A partir de ahora vamos a adquirir las señales con abs(signals)

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

%% Solo considerando abs(signals) (NORMALIZACIONES DE PRUEBA)

amp2=zeros(length(z),length(ang));
delta_t2 = zeros(length(z),length(ang));
Energy2 = zeros(length(z), length(ang));

N_amp2 = [];
N_time2 = [];
N_energy2 = [];
L=length(kgrid.t_array);
for a=1:length(ang)
    k=1;
    for i=1+(a-1)*length(z):length(z)*a
        [amp2(k,a), indice2]=max(abs(signals(:,i)));
        delta_t2(k,a) = kgrid.t_array(indice2);
       
        Energy2(k, a) = (1/L) * trapz(kgrid.t_array, abs(signals(:, i)).^2);


        k=k+1;
    end
    N_amp2 = normalization(amp2);
    N_time2 = normalization(delta_t2);
    N_energy2 = normalization(Energy2);%[N_energy2, abs(Energy2(:,a)-max(Energy2(:,a)))];
end 

for a=1:length(ang)
     N_amp2(:, a) = max(N_amp2(:, a)) - N_amp2(:, a);
     %N_time2(:,a) = max(N_time2(:, a)) - N_time2(:, a);
     N_energy2(:,a) = max(N_energy2(:, a)) - N_energy2(:,a);
end

%% Solo considerando hilbert

amp3 = zeros(length(z),length(ang));
delta_t3 = zeros(length(z),length(ang));
Energy3 = zeros(length(z), length(ang));

N_amp3 = [];
N_time3 = [];
N_energy3 = [];
L=length(kgrid.t_array);
for a=1:length(ang)
    k=1;
    for i=1+(a-1)*length(z):length(z)*a
        [amp3(k,a), indice3]=max(hilbert(abs(signals(:,i))));
        delta_t3(k,a) = kgrid.t_array(indice3);
       
        Energy3(k, a) = (1/L) * trapz(kgrid.t_array, hilbert(abs(signals(:, i))).^2);


        k=k+1;
    end
    N_amp3 = [N_amp3, abs(amp3(:,a)-max(amp3(:,a)))];
    N_time3 = [N_time3, abs(delta_t3(:,a)-max(delta_t3(:,a)))];
    N_energy3 = [N_energy3, abs(Energy3(:,a)-max(Energy3(:,a)))];
end 

%% Projections
%clearvars
%load Results1.mat

%Amplitudes
figure
hold on
x=1:length(z);
for Id = 1 : length(ang)
    subplot(4, 5, Id) ;
    %subplot(5, 10, Id);
    plot(x,N_amp(:,Id),'-o');
    %hold on;
    %plot(x, N_amp2(:,Id), '-square')
    %plot(x, N_amp3(:,Id), '-diamond')
    sgtitle('Max amplitude projections')
    title(['Angle =',num2str(ang(Id))])
    xlim([0,length(z)])
    %ylim([0.1,.5])
end
%
%legend('normal signals', 'absolute signals', 'hilbert signals')

%Energias 
figure;
hold on;
for Id = 1 : length(ang)
    subplot(4, 5, Id) ;
    %subplot(5, 10 , Id) ;
    plot(x,N_energy(:,Id),'-o');
    %hold on;
    %plot(x, N_energy2(:,Id), '-square')
    %plot(x, N_energy3(:,Id), '-diamond')
    sgtitle('Energy projections')
    title(['Angle =',num2str(ang(Id))])
    xlim([0,length(z)])
    %ylim([3e-5,3.07e-5])
end
%legend('normal signals', 'absolute signals', 'hilbert signals')
%
%Tiempos 
figure;
hold on;
for Id = 1 : length(ang)
    subplot(4, 5, Id) ;
    %subplot(5, 10 , Id) ;
    plot(x,delta_t(:,Id),'-o');
    %hold on;
    %plot(x, N_time2(:,Id), '-square')
    %plot(x, delta_t3(:,Id), '-diamond')
    sgtitle('Time arrival projections')
    title(['Angle =',num2str(ang(Id))])
    xlim([0,length(z)])
    %ylim([3e-5,3.07e-5])
end
%legend('normal signals', 'absolute signals', 'hilbert signals')

%% IRadon

% B = fliplr(N_amp(:,1:19));
 
% si = [N_amp(:,1:19), B];
Nx = 216;
Phi = round(linspace(0,180,19));

%reconstruction = iradon(maximos, theta);
reconstruction2 = iradon(N_energy, Phi,"None");%"Ram-Lak");%
reconstruction2 = reconstruction2 / max(reconstruction2, [], 'all');

reconstruction_resized = imresize(reconstruction2, [Nx, Nx]);
%reconstruction_resized2 = imresize(reconstruction2, [Nx, Nx]);

%reconstruction_resized = flip(reconstruction_resized);

figure;
%imshow(reconstruction, []);
imshow(reconstruction_resized, []);
title('reconstruction iradon with imresize')
%%
figure;
imshow(reconstruction2, []);%reconstruction_resized2, []);
title('reconstruction iradon original');% \Delta t')
