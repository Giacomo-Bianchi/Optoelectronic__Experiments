% Script to plot data from data001.txt
% Clears workspace and closes figures
clear all; close all; clc;

% Reads data from file
data = readmatrix('data001.txt');

% Extracts columns
x = data(:, 1);  % First column (time)
y = data(:, 2);  % Second column (amplitude)

% Creates the plot
figure('Name', 'Squeezing Data Plot', 'NumberTitle', 'off');
plot(x, y, 'b-', 'LineWidth', 1.5);
grid on;

% Labels and title
xlabel('Time (s)'); % Modificato
ylabel('Amplitude');  % Modificato
title('Squeezing Data'); % Modificato

% Graph formatting
set(gca, 'FontSize', 12);
axis tight;

%% Analisi della varianza per finestre
% Parametri per l'analisi
points = 5000; % <-- Scegli quanti punti vuoi considerare
N = 15;       % Numero di punti per finestra

% Prendi solo i primi 'points' valori
y_sel = y(1:min(points, length(y)));
x_sel = x(1:min(points, length(x)));

num_windows = floor(length(y_sel)/N);

variances = zeros(num_windows,1);
central_times = zeros(num_windows,1);

for i = 1:num_windows
    idx_start = (i-1)*N + 1;
    idx_end = i*N;
    window = y_sel(idx_start:idx_end);
    variances(i) = var(window);
    central_times(i) = mean(x_sel(idx_start:idx_end));
end

errors = sqrt(2./(N-1)) .* variances; % Calcolo dell'errore standard della varianza

% Plot istogramma della varianza nel tempo e segnale originale
figure;
yyaxis left
hBar = bar(central_times, variances, 1, 'DisplayName', 'Variance');
ylabel('Variance');
ylim([0 max(variances) * 1.1]);

hold on
% Plot error bars
%hErr = errorbar(central_times, variances, errors, 'k.', 'MarkerSize', 10, 'LineWidth', 1.5, 'DisplayName', 'Error Bars');
%yline(0, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Zero Line');

yyaxis right
hPlot = plot(x_sel, y_sel, 'r', 'DisplayName', 'Squeesing Signal');
ylabel('Squeesing Signal');
ylim([min(y_sel) max(y_sel)]);

xlabel('Time (s)');
title(['Variance and Squeesing Signal (first ' num2str(length(y_sel)) ' points, windows of ' num2str(N) ' points)']);
grid on;

legend([hBar hErr hPlot], {'Variance', 'Error Bars', 'Squeesing Signal'}, 'Location', 'best');
hold off;

% Plot separato degli errori
figure;
plot(central_times, errors, 'b-o', 'DisplayName', 'Errors');
xlabel('Time (s)');
ylabel('Error');
title('Error in Variance Calculation');
grid on;
legend('Location', 'best');

% Statistiche finali
fprintf('\n--- Analisi della varianza ---\n');
fprintf('Numero di finestre: %d\n', num_windows);
fprintf('Punti per finestra: %d\n', N);
fprintf('Varianza media: %.6f\n', mean(variances));
fprintf('Errore medio: %.6f\n', mean(errors));
fprintf('Varianza min/max: %.6f / %.6f\n', min(variances), max(variances)); 
