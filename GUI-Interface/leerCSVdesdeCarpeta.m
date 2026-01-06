function [X, Y, nombresArchivos] = leerCSVdesdeCarpeta(carpeta, rangoX, rangoY)
    % Lee todos los archivos CSV de una carpeta y extrae datos de rangos específicos
    % ahora con ordenamiento correcto basado en los números del nombre

    dircsv = dir(fullfile(carpeta, '*.csv'));
    ncsv = length(dircsv);
    
    if ncsv == 0
        error('No se encontraron archivos CSV en la carpeta seleccionada.');
    end

    % === ORDENAMIENTO NATURAL DE ARCHIVOS ===
    fileNames = {dircsv.name};
    fileNumbers = zeros(size(fileNames));

    for i = 1:ncsv
        tokens = regexp(fileNames{i}, 'signal(\d+)\.csv', 'tokens');
        if ~isempty(tokens)
            fileNumbers(i) = str2double(tokens{1}{1});
        else
            warning('Nombre de archivo "%s" no coincide con patrón esperado.', fileNames{i});
        end
    end

    [~, sortIdx] = sort(fileNumbers);
    dircsv = dircsv(sortIdx);  % ordenar archivos

    % === LECTURA DE ARCHIVOS YA ORDENADOS ===
    for n = 1:ncsv
        archivo = fullfile(carpeta, dircsv(n).name);
        X(:, :, n) = readmatrix(archivo, 'Range', rangoX);
        Y(:, :, n) = readmatrix(archivo, 'Range', rangoY);
        nombresArchivos{n} = dircsv(n).name; %#ok<AGROW>
    end
end




% function [X, Y, nombresArchivos] = leerCSVdesdeCarpeta(carpeta, rangoX, rangoY)
%     % Lee todos los archivos CSV de una carpeta y extrae datos de rangos específicos
% 
%     dircsv = dir(fullfile(carpeta, '*.csv'));
%     ncsv = length(dircsv);
% 
%     if ncsv == 0
%         error('No se encontraron archivos CSV en la carpeta seleccionada.');
%     end
% 
%     for n = 1:ncsv
%         archivo = fullfile(carpeta, dircsv(n).name);
%         X(:, :, n) = readmatrix(archivo, 'Range', rangoX);
%         Y(:, :, n) = readmatrix(archivo, 'Range', rangoY);
%         nombresArchivos{n} = dircsv(n).name; %#ok<AGROW>
%     end
% end
