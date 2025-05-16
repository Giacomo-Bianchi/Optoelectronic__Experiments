% Script per plottare i dati di CMRR1.txt
clear ;clc; close all;
% Leggi i dati dal file (usa il separatore ',')
data = readmatrix('CMRR1.txt');

% Estrai le colonne
x = data(:,1);
y1 = data(:,2);
y2 = data(:,3);
y3 = data(:,4);

% Crea il plot
figure;
plot(x, y1, 'r', 'DisplayName', 'Only one Photodiode');
hold on;
plot(x, y3, 'b', 'DisplayName', 'Two Photodiodes (subtraction)');

% Trova e annota il punto massimo per y1
[max_y1, idx1] = max(y1);
text(x(idx1), max_y1, sprintf('  %.2f', max_y1), 'Color', 'r', 'VerticalAlignment', 'bottom');

% Trova e annota il punto massimo per y3
[max_y3, idx3] = max(y3);
text(x(idx3), max_y3, sprintf('  %.2f', max_y3), 'Color', 'b', 'VerticalAlignment', 'bottom');

hold off;

xlabel('Frequencies (Hz)');
ylabel('Valori (dB)');
title('Plot dati CMRR1.txt');
legend;
grid on;
