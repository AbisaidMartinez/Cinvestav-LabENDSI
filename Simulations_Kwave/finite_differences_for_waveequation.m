% Finite Differences for wave equation
%Variables iniciales del problema
a = 0;
b = 10; % Se toma el intervalo de x \in (0, b)
t_end = 3e-4;
alpha = 1498; % sound speed on water
m = 1000;
N = 1000;
h = (b-a)/m; % l representa un punto extremo, m es un iterador 
k = t_end/N;
lambda = (k * alpha)/h;

A = 5; % Amplitud
gamma = 41943.83;  % Wave number (Considering a 10 MHz Transducer)
w = zeros(m+1,N+1);
% Funcion y Velocidad inicial
f = @(x, t) A* cos(gamma*(x-alpha*t));%exp(-t) * sin(pi * x);%2.5*((1-cos(2 * pi * .25e6 * x/20))*sin(2 * pi * .25e6 * x)); % Ejemplo de condición inicial
g = @(x, t) 0;           % Ejemplo de velocidad inicial

w(a+1,:) = 0; %For x=a
w(m+1,:) = 0; %For x=b


%Boundary Conditions
w(a+1,1) = f(a+1,1);
w(m,1) = f(b,1);    

for i=1:N
   w(i,1) = f((i-1)*h,1);
   w(i,2) = (1-lambda^2)*f(i*h,2)+(lambda^2/2)*(f((i)*h,2)+f((i-2)*h,2))+k*g((i-1)*h,2);
end

for j=2:N
    for i=2:m
        w(i,j+1)=2*(1-lambda^2)*w(i,j)+(lambda^2)*(w(i+1,j)+w(i-1,j))-w(i,j-1);
    end
end

x = linspace(a, b, m+1); % Discretización espacial
t = linspace(0, t_end, N+1); % Discretización temporal

figure;
plot(x, w(:,end))
xlabel('Posición x(m)');
ylabel('Proyeccion w(x,:)');
title('Projeccion de onda en el espacio');

figure;
plot(t, w(end-1,:))
xlabel('Tiempo t(s)');
ylabel('Proyeccion w(:,t)');
title('Projeccion de onda en el tiempo');

[X, T] = meshgrid(x, t); % Crear malla para el gráfico
figure;
surf(X, T, w'); % Graficar superficie (se transpone w para coincidir con dimensiones)
xlabel('Posición x');
ylabel('Tiempo t');
zlabel('Desplazamiento w(x, t)');
title('Evolución de la onda en el tiempo y el espacio');
shading interp; % Para suavizar la visualización
