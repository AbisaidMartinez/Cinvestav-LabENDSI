function [delta_t, N_time, N_amp, N_energy] = analizarMaximos(X, Y_filtrada, numElementos)
% analizarMaximos Extrae máximos, energía y diferencias normalizadas
%
%   [delta_t, N_time, N_amp, N_energy] = analizarMaximos(X, Y_filtrada)
%
%   Inputs:
%     X          - Matriz 3D con coordenadas X (Nx × 30 × Ns)
%     Y_filtrada - Matriz 3D con señales filtradas (Nx × 30 × Ns)
%
%   Outputs:
%     delta_t    - Diferencia de tiempos (máximo - mínimo en cada columna)
%     N_time     - Normalización de tiempos
%     N_amp      - Normalización de amplitudes
%     N_energy   - Normalización de energía

% Inicialización
N_amp = [];
N_time = [];
N_energy = [];

% Índice de columna
columna = 1;

% Prealocación (opcional si sabes el tamaño)
maximos_y = zeros(numElementos, ceil(size(Y_filtrada,3)/numElementos));
maximos_x = zeros(numElementos, ceil(size(Y_filtrada,3)/numElementos));
Energia    = zeros(numElementos, ceil(size(Y_filtrada,3)/numElementos));

% Bucle principal para hallar máximos
for i = 1:size(Y_filtrada, 3)
    datax = X(:,:,i);
    datay = Y_filtrada(:,:,i);
    L = length(datax);
    
    % Energía de la señal
    Energy = (1/L) * trapz(abs(datay).^2, 1);

    % Máximo
    [max_value, max_index] = max(datay);%abs(datay));
    max_x = datax(max_index);

    fila = mod(i-1, numElementos) + 1; 
    maximos_y(fila, columna) = max_value;
    maximos_x(fila, columna) = max_x;
    Energia(fila, columna)   = Energy;

    % Aumentar columna cada numElementos señales
    if mod(i, numElementos) == 0
        columna = columna + 1;
    end
end

% Cálculo de diferencias normalizadas
for a = 1:size(maximos_y, 2)
    N_amp    = [N_amp, abs(maximos_y(:,a)  - max(maximos_y(:,a)))];
    N_time   = [N_time, abs(maximos_x(:,a) - max(maximos_x(:,a)))];
    N_energy = [N_energy, abs(Energia(:,a) - max(Energia(:,a)))];
end

% Delta t (rango en tiempo por columna)
delta_t = maximos_x;%max(maximos_x) - min(maximos_x);

end
