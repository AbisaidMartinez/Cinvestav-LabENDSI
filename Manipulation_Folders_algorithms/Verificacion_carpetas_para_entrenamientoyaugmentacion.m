%% Script de diagnóstico para estructura de carpetas
clear; clc; close all;

% Rutas de tus carpetas
normalPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\detector_autoencoder\normal';
discontinuityPath = 'C:\Users\qbo28\OneDrive\Documentos\Materias RyMA\Tesis Maestria\fotos\database\detector_autoencoder\discontinuity';

%% Análisis de carpeta NORMAL
fprintf('=== ANÁLISIS CARPETA NORMAL ===\n');
try
    imdsNormal = imageDatastore(normalPath, 'IncludeSubfolders', true);
    fprintf('✅ Carpeta normal encontrada\n');
    fprintf('📁 Número total de archivos: %d\n', length(imdsNormal.Files));
    
    % Mostrar primeros 5 archivos
    fprintf('\n📋 Primeros 5 archivos:\n');
    for i = 1:min(5, length(imdsNormal.Files))
        fprintf('   %d. %s\n', i, imdsNormal.Files{i});
    end
    
    % Verificar extensiones
    [~, ~, extensions] = fileparts(imdsNormal.Files);
    uniqueExts = unique(extensions);
    fprintf('\n🔍 Extensiones encontradas: %s\n', strjoin(uniqueExts, ', '));
    
    % Intentar leer la primera imagen
    try
        firstImg = readimage(imdsNormal, 1);
        fprintf('✅ Primera imagen leída correctamente\n');
        fprintf('📐 Dimensiones: %dx%dx%d\n', size(firstImg,1), size(firstImg,2), size(firstImg,3));
        fprintf('📊 Tipo de datos: %s\n', class(firstImg));
        fprintf('📈 Rango de valores: [%.3f, %.3f]\n', min(firstImg(:)), max(firstImg(:)));
    catch ME
        fprintf('❌ Error al leer primera imagen: %s\n', ME.message);
    end
    
catch ME
    fprintf('❌ Error al acceder carpeta normal: %s\n', ME.message);
end

%% Análisis de carpeta DISCONTINUIDAD
fprintf('\n=== ANÁLISIS CARPETA DISCONTINUIDAD ===\n');
try
    imdsDiscont = imageDatastore(discontinuityPath, 'IncludeSubfolders', true);
    fprintf('✅ Carpeta discontinuidad encontrada\n');
    fprintf('📁 Número total de archivos: %d\n', length(imdsDiscont.Files));
    
    % Mostrar primeros 5 archivos
    fprintf('\n📋 Primeros 5 archivos:\n');
    for i = 1:min(5, length(imdsDiscont.Files))
        fprintf('   %d. %s\n', i, imdsDiscont.Files{i});
    end
    
    % Verificar extensiones
    [~, ~, extensions] = fileparts(imdsDiscont.Files);
    uniqueExts = unique(extensions);
    fprintf('\n🔍 Extensiones encontradas: %s\n', strjoin(uniqueExts, ', '));
    
    % Intentar leer la primera imagen
    try
        firstImg = readimage(imdsDiscont, 1);
        fprintf('✅ Primera imagen leída correctamente\n');
        fprintf('📐 Dimensiones: %dx%dx%d\n', size(firstImg,1), size(firstImg,2), size(firstImg,3));
        fprintf('📊 Tipo de datos: %s\n', class(firstImg));
        fprintf('📈 Rango de valores: [%.3f, %.3f]\n', min(firstImg(:)), max(firstImg(:)));
    catch ME
        fprintf('❌ Error al leer primera imagen: %s\n', ME.message);
    end
    
catch ME
    fprintf('❌ Error al acceder carpeta discontinuidad: %s\n', ME.message);
end

%% Prueba de augmentedImageDatastore
fprintf('\n=== PRUEBA AUGMENTED DATASTORE ===\n');
try
    % Crear un pequeño subset para prueba
    if exist('imdsNormal', 'var') && length(imdsNormal.Files) > 0
        % Tomar solo los primeros 5 archivos para prueba
        testFiles = imdsNormal.Files(1:min(5, length(imdsNormal.Files)));
        testImds = imageDatastore(testFiles);
        
        % Crear augmented datastore
        inputSize = [128 128];
        augTest = augmentedImageDatastore(inputSize, testImds, 'ColorPreprocessing', 'gray2rgb');
        
        fprintf('✅ AugmentedImageDatastore creado\n');
        
        % Intentar leer una imagen
        reset(augTest);
        if hasdata(augTest)
            testImg = read(augTest);
            fprintf('✅ Imagen leída desde augmented datastore\n');
            fprintf('📐 Dimensiones después de augmentation: %dx%dx%d\n', size(testImg,1), size(testImg,2), size(testImg,3));
            fprintf('📊 Tipo de datos: %s\n', class(testImg));
            fprintf('📈 Rango de valores: [%.3f, %.3f]\n', min(testImg(:)), max(testImg(:)));
        end
    end
    
catch ME
    fprintf('❌ Error con augmented datastore: %s\n', ME.message);
end

%% Recomendaciones
fprintf('\n=== RECOMENDACIONES ===\n');
if exist('imdsNormal', 'var') && exist('imdsDiscont', 'var')
    normalCount = length(imdsNormal.Files);
    discontCount = length(imdsDiscont.Files);
    
    fprintf('🔢 Imágenes normales: %d\n', normalCount);
    fprintf('🔢 Imágenes discontinuidad: %d\n', discontCount);
    fprintf('🔢 Total: %d\n', normalCount + discontCount);
    
    if abs(normalCount - discontCount) > 100
        fprintf('⚠️  Las carpetas tienen tamaños muy diferentes\n');
    end
    
    if normalCount > 0 && discontCount > 0
        fprintf('✅ Estructura parece correcta para entrenamiento\n');
        fprintf('💡 Sugerencia: Proceder con el entrenamiento\n');
    else
        fprintf('❌ Problema con la estructura de carpetas\n');
        fprintf('💡 Sugerencia: Verificar rutas y contenido\n');
    end
else
    fprintf('❌ No se pudieron cargar las carpetas\n');
    fprintf('💡 Sugerencias:\n');
    fprintf('   - Verificar que las rutas existan\n');
    fprintf('   - Verificar permisos de acceso\n');
    fprintf('   - Considerar mover imágenes a carpetas sin subcarpetas\n');
end

%% Mostrar estructura de carpetas (opcional)
fprintf('\n=== ESTRUCTURA DE CARPETAS ===\n');
fprintf('¿Quieres ver la estructura detallada de subcarpetas? (y/n): ');
response = input('', 's');
if strcmpi(response, 'y')
    fprintf('\nEstructura de carpeta NORMAL:\n');
    if exist('imdsNormal', 'var')
        folders = unique(fileparts(imdsNormal.Files));
        for i = 1:length(folders)
            filesInFolder = sum(contains(imdsNormal.Files, folders{i}));
            fprintf('  📁 %s (%d archivos)\n', folders{i}, filesInFolder);
        end
    end
    
    fprintf('\nEstructura de carpeta DISCONTINUIDAD:\n');
    if exist('imdsDiscont', 'var')
        folders = unique(fileparts(imdsDiscont.Files));
        for i = 1:length(folders)
            filesInFolder = sum(contains(imdsDiscont.Files, folders{i}));
            fprintf('  📁 %s (%d archivos)\n', folders{i}, filesInFolder);
        end
    end
end