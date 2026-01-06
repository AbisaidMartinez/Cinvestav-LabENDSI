function Y_filtrada = kalman_filtrar(Y, Q, R)
% kalman_filtrar Aplica un filtro de Kalman a un conjunto de señales
%
%   Y_filtrada = kalman_filtrar(Y, Q, R)
%
%   Entradas:
%     Y - Matriz 3D de señales [Nx1xS] (N puntos por señal, S señales)
%     Q - Varianza del proceso (controla suavizado)
%     R - Varianza del ruido de medición (controla confianza en la medición)
%
%   Salida:
%     Y_filtrada - Señales suavizadas por el filtro de Kalman

    N = length(Y);
    Y_filtrada = zeros(size(Y));
    P = 1;

    % Inicialización
    y_est = Y(1);
    Y_filtrada(1) = y_est;

    for k = 2:N
        y_pred = y_est;
        P_pred = P + Q;
        K = P_pred / (P_pred + R);
        y_est = y_pred + K * (y(k) - y_pred);
        P = (1 - K) * P_pred;
        Y_filtrada(k) = y_est;
    end
end
