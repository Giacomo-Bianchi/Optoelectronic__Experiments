% Script per plottare i dati di CMRR1.txt
clear ;clc; close all;
% Leggi i dati dal file (usa il separatore ',')
data_Coherent = readmatrix('Coherent_state.txt');
data_Interference = readmatrix('Interference000.txt');
data_Interference_neg = readmatrix('Interferenceneg000.txt');

% Estrai le colonne
xc = data_Coherent(:,1);
yc = data_Coherent(:,2);

xi = data_Interference(:,1);
yi = data_Interference(:,2);

xin = data_Interference_neg(:,1);
yin = data_Interference_neg(:,2);


% Crea il plot
figure;
plot(xc, yc, 'DisplayName', 'Coherent State');
xlabel('Time (s)');
ylabel('Valori');
legend;
title('Coherent State ');

grid on;

figure;
hold on;
plot(xi, yi, 'DisplayName', 'Interference');
plot(xin, yin, 'DisplayName', 'Interference Neg');
plot(xc, yc, 'DisplayName', 'Coherent State');
xlabel('Time (s)');
ylabel('Valori');
title('Interference');
legend;
grid on;
