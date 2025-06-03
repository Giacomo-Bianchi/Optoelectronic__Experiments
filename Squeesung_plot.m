% Script to plot data from test3.txt
clear; clc; close all;

% Read data from file (using ',' as separator)
data = readmatrix('test3.txt');

Ttot = 1; % second

% Extract columns
x = data(:,1);
dt = Ttot / length(x);
t = (0:length(x)-1) * dt;
y1 = data(:,2);
y2 = data(:,3);
y3 = data(:,4);

% Create the plot
figure;
plot(t, y1, 'r', 'DisplayName', 'Electronic Noise');
hold on;
plot(t, y2, 'g', 'DisplayName', 'Shot Noise');
plot(t, y3, 'b', 'DisplayName', 'Squeezing');
hold off;

xlabel('Time (s)');
ylabel('Value (dB)');
title('Plot of data from test3.txt');
legend;
grid on;
