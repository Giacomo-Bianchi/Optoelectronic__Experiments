% Script per plottare i dati di test3.txt
clear; clc; close all;

% Leggi i dati dal file (usa il separatore ',')
data = readmatrix('test3.txt');

Ttot = 1; %secondo


% Estrai le colonne
x = data(:,1);
dt = Ttot / length(x);
t = (0:length(x)-1) * dt;
y1 = data(:,2);
y2 = data(:,3);
y3 = data(:,4);

% Crea il plot
figure;
plot(t, y1, 'r', 'DisplayName', 'Eletronic Noise');
hold on;
plot(t, y2, 'g', 'DisplayName', ' Shot Noise');
plot(t, y3, 'b', 'DisplayName', 'Squeesing');
hold off;

xlabel('Time (s)');
ylabel('Valore (dB)');
title('Plot dei dati da test3.txt');
legend;
grid on;