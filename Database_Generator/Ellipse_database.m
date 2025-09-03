% Parámetros generales
numSamples = 5000;  % Número total de imágenes
outputDir = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\Ellipses_database';  % Carpeta principal de la base
mkdir(fullfile(outputDir, 'normal'));
mkdir(fullfile(outputDir, 'defecto'));
mkdir(fullfile(outputDir, 'mascara_defecto'));

M = 216;  % Tamaño de imagen

for idx = 1:numSamples
    % Crear lienzo
    img = zeros(M);
    
    % Generar elipse con tamaños aleatorios
    a = randi([20, 50]);  % semieje mayor
    b = randi([10, a-5]); % semieje menor
    theta = deg2rad(randi([0, 180]));  % rotación aleatoria

    dx = randi([-5, 5]);  % Traslación aleatoria en X
    dy = randi([-5, 5]);  % Traslación aleatoria en Y
    
    xcenter = round(M/2) + dx;
    ycenter = round(M/2) + dy;
    
    for i = 1:M
        for j = 1:M
            pixelx = (i - xcenter);
            pixely = (j - ycenter);
            
            xrot = pixelx * cos(theta) + pixely * sin(theta);
            yrot = pixely * cos(theta) - pixelx * sin(theta);
            
            if (xrot^2 / a^2 + yrot^2 / b^2 <= 1)
                img(M - j + 1, i) = 1;
            end
        end
    end
    
    % Guardar imagen sin defecto
    imgSinDefecto = img;
    filenameNormal = fullfile(outputDir, 'normal', sprintf('ellipse_%04d.png', idx));
    imwrite(imgSinDefecto, filenameNormal);
    
    % Crear máscara del contorno de la elipse
    bw = logical(imgSinDefecto);
    [B, ~] = bwboundaries(bw, 'noholes');
    
    if isempty(B)
        continue; % Saltar si no se detectó contorno
    end
    
    % Seleccionar contorno más grande (el principal)
    maxPoints = 0;
    mainContourIdx = 1;
    for k = 1:length(B)
        if size(B{k}, 1) > maxPoints
            maxPoints = size(B{k}, 1);
            mainContourIdx = k;
        end
    end
    
    % Crear máscara de contorno
    maskContour = poly2mask(B{mainContourIdx}(:,2), B{mainContourIdx}(:,1), M, M);
    
    % Seleccionar punto aleatorio en el contorno
    idxs = find(maskContour);
    if isempty(idxs)
        continue;  % Si por algún motivo no hay contorno, saltar
    end
    randIdx = idxs(randi(length(idxs)));
    [yRand, xRand] = ind2sub(size(maskContour), randIdx);
    
    % Generar radio aleatorio para la discontinuidad
    radio = randi([3, 12]);  % Rango del tamaño del círculo (defecto)

    % Crear círculo (discontinuidad)
    [xx, yy] = meshgrid(1:M, 1:M);
    circleMask = ((xx - xRand).^2 + (yy - yRand).^2) <= radio^2;
    
    % Insertar defecto en la imagen
    imgConDefecto = imgSinDefecto;
    imgConDefecto(circleMask & maskContour) = 0;
    
    % Guardar imagen con defecto
    filenameDefecto = fullfile(outputDir, 'defecto', sprintf('ellipse_def_%04d.png', idx));
    imwrite(imgConDefecto, filenameDefecto);
    
    % Guardar máscara del defecto
    mascaraDefecto = circleMask & maskContour;
    filenameMascara = fullfile(outputDir, 'mascara_defecto', sprintf('mask_def_%04d.png', idx));
    imwrite(mascaraDefecto, filenameMascara);
end

fprintf('✅ Base generada en: %s\n', outputDir);
