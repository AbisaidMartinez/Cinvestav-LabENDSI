% Para eliminar todo
clc;
clear all;
%close all;
%Variables
syms q1 q2 q3 q4 q5;


q=[q1; q2; q3; q4; q5];


assume(q,"real");

%Parametros del robot

%Longitud de cada eslabón.

% en m
l0=0.350;
l1=0.120;
l2=0.6860;
lr=0.034

l=[l0 l1 l2 ];

%Parametros de la tabla de GRyMA
%lambdan=[d;R]
lambda0=[0;0;0;0;0;0];
lambda1=[0;1;0;0;0;0];
lambda2=[1;0;0;0;0;0];
lambda3=[0;0;1;0;0;0];
lambda4=[0;0;0;0;0;1];
lambda5=[0;0;0;1;0;0];

%An=GRyMA_V2(dxn,dyn,dzn,lambdan,qn)
A1=GRyMA_V2(0,0,0,lambda1,q(1));
A2=GRyMA_V2(0,0,0,lambda2,q(2));
A3=GRyMA_V2(0,l(2),l(1),lambda3,q(3));
A4=GRyMA_V2(0,0,0,lambda4,q(4));
A5=GRyMA_V2(0,0,-l(3),lambda5,q(5));
Ar=GRyMA_V2(0,0,-lr,lambda0,0);

%Matriz de Transformacion con DH
T_1 = A1;
T_2 = T_1*A2;
T_3 = T_2*A3;
T_4 = T_3*A4;
T_5 = T_4*A5;
T_r = T_5*Ar


%Antisimetrica
function skew=antisimetrica(A,i)

        skew = [0 ,-(A(3,i)), A(2,i);
                A(3,i), 0, -(A(1,i));
                -(A(2,i)) , A(1,i), 0];
end

%Metodo Gryma para las Matrices Homogeneas
function An=GRyMA_V2(dx,dy,dz,lambda,q)

lambdaR=lambda(4:6,1);
lambdaT=lambda(1:3,1);

dv=[dx;dy;dz];
d=dv+lambdaT*q;

ex=eye(3)+antisimetrica(lambdaR,1)*sin(q)+(antisimetrica(lambdaR,1)*antisimetrica(lambdaR,1))*(1-cos(q));

An=[ex,d;
    zeros(1,3),1];
end


%% Jacobianos

J_v1 = diff(T_r(1:3, end), q(1));
J_v2 = diff(T_r(1:3, end), q(2));
J_v3 = diff(T_r(1:3, end), q(3));
J_v4 = diff(T_r(1:3, end), q(4));
J_v5 = diff(T_r(1:3, end), q(5));

J_v=[J_v1 J_v2 J_v3 J_v4 J_v5]

%% Pseuda Inversa
alpha=0.01
I=eye(5)
JT=transpose(J_v)
Jpseu=(inv((JT*J_v)+alpha*I))*JT

%% Control con Cinematica Inversa

% % x=.4
% % y=.3
% % z=.5
% % x_vector=[x;y;z]
% % 
% % x_d=[.6;.2;.10]
% % e=x_vector-x_d
% % x_p=-Kp*e
% % q_p=Jpseu*x_p
% 
% %derivar la q_p para obtener la q
Kp=4
delta_t=0.001
t_sim=25
x_actual=[0; 0.12; -0.37]

x_deseada=[0.25; 0.3; -0.15]
T=25
[gamaM,deltae] = gd(T)

qf = [0; 0; 0; 0; 0]; % Inicialización de ángulos articulares numéricos.

for i = linspace(0, t_sim, round(100 * t_sim))
    t = i;
    func = sigmoide(gamaM, deltae, t, T);

    delta = (x_actual - x_deseada) * func;
    xt = x_actual + delta;

    e = xt - x_actual;
    x_p = -Kp * e;

    % Sustituir valores simbólicos por numéricos.
    PseuJaco = subs(Jpseu, [q1, q2, q3, q4, q5], qf.');
    PseuJaco = double(PseuJaco); % Asegurar que sea numérica.

    q_p = PseuJaco * x_p;

    qf = qf + (q_p * delta_t); % Actualización de qf numérico.

    x_actual = x_actual + (x_p * delta_t); % Actualización de la posición.
end



function [gamaM,deltae]= gd(T)
fi=0.99
eps=(T/2)
a=-(log((1-fi)/fi)-eps)/T

diff=1
while diff>0.001
        a=-(log((1-fi)/fi)-eps)/T;
        eps_prev=eps;
        eps=a*(T/2);
        diff=abs(eps-eps_prev);
end
gamaM=a;
deltae=eps;
end

function sig=sigmoide(gamaM,deltae,t,T)

sig=1/(1+exp(-(gamaM*t)+deltae));
if t>T
    sig=1
end
end


%% Graficas
q1n=0
q2n=0
q3n=0
q4n=0
q5n=0

%Para mostrar la posicion Home del robot
v1 = double(subs(T_1(1:3, end),[q1,q2,q3,q4,q5],[q1n,q2n,q3n,q4n,q5n]));
v2 = double(subs(T_2(1:3, end),[q1,q2,q3,q4,q5],[q1n,q2n,q3n,q4n,q5n]));
v3 = double(subs(T_3(1:3, end),[q1,q2,q3,q4,q5],[q1n,q2n,q3n,q4n,q5n]));
v4 = double(subs(T_4(1:3, end),[q1,q2,q3,q4,q5],[q1n,q2n,q3n,q4n,q5n]));
v5 = double(subs(T_5(1:3, end),[q1,q2,q3,q4,q5],[q1n,q2n,q3n,q4n,q5n]));
vr = double(subs(T_r(1:3, end),[q1,q2,q3,q4,q5],[q1n,q2n,q3n,q4n,q5n]));

% Jsubs=subs(J_v,[q1,q2,q3,q4,q5],[q1n,q2n,q3n,q4n,q5n])


x = [v1(1), v2(1), v3(1), v4(1), v5(1),vr(1)];
y = [v1(2), v2(2), v3(2), v4(2), v5(2),vr(2)];
z = [v1(3), v2(3), v3(3), v4(3), v5(3),vr(3)];
figure;
plot3(x, y, z, '-o', 'MarkerSize', 10,'LineWidth',3);
hold on;
plot3(v1(1), v1(2), v1(3), 'o', 'MarkerSize', 5,'LineWidth',3);
plot3(v2(1), v2(2), v2(3), 'o', 'MarkerSize', 10,'LineWidth',3);
plot3(v3(1), v3(2), v3(3), 'o', 'MarkerSize', 15,'LineWidth',3);
plot3(v4(1), v4(2), v4(3), 'o', 'MarkerSize', 20,'LineWidth',3);
plot3(v5(1), v5(2), v5(3), 'o', 'MarkerSize', 10,'LineWidth',3);

hold off;
title('Home Balta Robot')
xlabel('x')
ylabel('y')
zlabel('z')
legend('plot','T_1','T_2','T_3','T_4','T_5')


%Para mostrar la posicion final del robot
v1f = double(subs(T_1(1:3, end),[q1,q2,q3,q4,q5],[qf(1),qf(2),qf(3),qf(4),qf(5)]));
v2f = double(subs(T_2(1:3, end),[q1,q2,q3,q4,q5],[qf(1),qf(2),qf(3),qf(4),qf(5)]));
v3f = double(subs(T_3(1:3, end),[q1,q2,q3,q4,q5],[qf(1),qf(2),qf(3),qf(4),qf(5)]));
v4f = double(subs(T_4(1:3, end),[q1,q2,q3,q4,q5],[qf(1),qf(2),qf(3),qf(4),qf(5)]));
v5f = double(subs(T_5(1:3, end),[q1,q2,q3,q4,q5],[qf(1),qf(2),qf(3),qf(4),qf(5)]));
vrf = double(subs(T_r(1:3, end),[q1,q2,q3,q4,q5],[qf(1),qf(2),qf(3),qf(4),qf(5)]));

% Jsubs=subs(J_v,[q1,q2,q3,q4,q5],[q1n,q2n,q3n,q4n,q5n])


xf = [v1f(1), v2f(1), v3f(1), v4f(1), v5f(1),vrf(1)];
yf = [v1f(2), v2f(2), v3f(2), v4f(2), v5f(2),vrf(2)];
zf = [v1f(3), v2f(3), v3f(3), v4f(3), v5f(3),vrf(3)];
figure;
plot3(xf, yf, zf, '-o', 'MarkerSize', 10,'LineWidth',3);
hold on;
plot3(v1f(1), v1f(2), v1f(3), 'o', 'MarkerSize', 5,'LineWidth',3);
plot3(v2f(1), v2f(2), v2f(3), 'o', 'MarkerSize', 10,'LineWidth',3);
plot3(v3f(1), v3f(2), v3f(3), 'o', 'MarkerSize', 15,'LineWidth',3);
plot3(v4f(1), v4f(2), v4f(3), 'o', 'MarkerSize', 20,'LineWidth',3);
plot3(v5f(1), v5f(2), v5f(3), 'o', 'MarkerSize', 10,'LineWidth',3);

hold off;
title('Final Balta Robot')
xlabel('xf')
ylabel('yf')
zlabel('zf')
legend('plot','T_1','T_2','T_3','T_4','T_5')