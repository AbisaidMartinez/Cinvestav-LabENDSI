% Parametros
a = 0; b = 1.5;           % Dominio espacial en x, y, z
t_end = 25e-4;           % Tiempo final de simulación
alpha = 1498;           % Velocidad de la onda (agua)
m = 50;                 % Numero de puntos espaciales en cada eje
N = 300;                % Numero de pasos de tiempo

h = (b-a)/m;            % Paso espacial
k = t_end/N;            % Paso temporal
lambda = (alpha * k) / h;

% Checar la condicion de estabilidad (importante)
if lambda >= 1/sqrt(3)
    warning('El esquema podría ser inestable: reducir k o aumentar m');
end

% Crear mallas de espacio
x = linspace(a, b, m+1);
y = linspace(a, b, m+1);
z = linspace(a, b, m+1);

% Inicializar solucion
w = zeros(m+1, m+1, m+1, N+1);

% Condicion inicial f(x,y,z)
f = @(x,y,z) sin(pi*x) .* sin(pi*y) .* sin(pi*z);

for i = 1:m+1
    for j = 1:m+1
        for k_index = 1:m+1
            w(i,j,k_index,1) = f(x(i), y(j), z(k_index)); % t=0
        end
    end
end

% Inicializar el primer paso en tiempo (n=1) usando f y su derivada temporal g(x,y,z)
% Asumiendo g(x,y,z) = 0 para este ejemplo (onda en reposo inicialmente)
g = @(x,y,z) 0;

for i = 2:m
    for j = 2:m
        for k_index = 2:m
            w(i,j,k_index,2) = (1 - 3*lambda^2) * w(i,j,k_index,1) + ...
                (lambda^2/2) * (w(i+1,j,k_index,1) + w(i-1,j,k_index,1) + ...
                                w(i,j+1,k_index,1) + w(i,j-1,k_index,1) + ...
                                w(i,j,k_index+1,1) + w(i,j,k_index-1,1)) + ...
                k * g(x(i), y(j), z(k_index));
        end
    end
end

% Ciclo principal: avanzar en el tiempo
for n = 2:N
    for i = 2:m
        for j = 2:m
            for k_index = 2:m
                w(i,j,k_index,n+1) = 2*(1 - 3*lambda^2)*w(i,j,k_index,n) + ...
                    lambda^2 * (w(i+1,j,k_index,n) + w(i-1,j,k_index,n) + ...
                                w(i,j+1,k_index,n) + w(i,j-1,k_index,n) + ...
                                w(i,j,k_index+1,n) + w(i,j,k_index-1,n)) - ...
                    w(i,j,k_index,n-1);
            end
        end
    end
end

% Animar la onda en 3D
[X, Y, Z] = meshgrid(x, y, z);

for n = 1:5:N+1
    figure(1); clf;
    slice(X, Y, Z, w(:,:,:,n), b/2, b/2, b/2);
    shading interp
    colorbar
    axis([a b a b a b])
    xlabel('x')
    ylabel('y')
    zlabel('z')
    title(['Tiempo t = ', num2str((n-1)*k, '%.4f')])
    drawnow
end
