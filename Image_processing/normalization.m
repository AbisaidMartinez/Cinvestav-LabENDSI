function normaldata = normalization(data)
    % Obtener los valores mínimos y máximos por columna
    a = min(data, [], 1);  % Mínimo de cada columna
    b = max(data, [], 1);  % Máximo de cada columna
    
    % Normalizar la matriz completa
    normaldata = (data - a) ./ (b - a);
end

% function [a, b, normaldata] = normalization(data)
%     % Obtener los valores mínimos y máximos por columna
%     a = min(data, [], 1);  % Mínimo de cada columna
%     b = max(data, [], 1);  % Máximo de cada columna
% 
%     % Normalizar la matriz completa
%     normaldata = (data - a) ./ (b - a);
% end
