% Script to plot data from CMRR1.txt
clear; clc; close all;
% Read data from file (using ',' as separator)
data_Coherent = readmatrix('Coherent_state.txt');
data_Interference = readmatrix('Interference000.txt');
data_Interference_neg = readmatrix('Interferenceneg000.txt');

% Extract columns
xc = data_Coherent(:,1);
yc = data_Coherent(:,2);

xi = data_Interference(:,1);
yi = data_Interference(:,2);

xin = data_Interference_neg(:,1);
yin = data_Interference_neg(:,2);

% Shift time so it starts from 0
xc = xc - xc(1);
xi = xi - xi(1);
xin = xin - xin(1);

% calcolo valore interferenza in percentuale
interf_percent = (max(movmean(yi,10)) - min(movmean(yi,10)))/(max(movmean(yi,10)) + min(movmean(yi,10))) * 100;
disp(['Interference percentage: ' num2str(interf_percent) '%']);
% Create the plot
figure;
plot(xc, yc, 'DisplayName', 'Coherent State');
xlabel('Time (s)');
ylabel('Values');
legend;
title('Coherent State');
grid on;

figure;
hold on;
plot(xi, yi, 'DisplayName', 'Interference');
plot(xin, yin, 'DisplayName', 'Interference Neg');
plot(xc, yc, 'DisplayName', 'Coherent State');
xlabel('Time (s)');
ylabel('Values');
title('Interference');
legend;
grid on;


%% Variance analysis Coherent State solo sui primi 'points'
PLOT_VAR_ERRORS = false; % <-- Imposta a true per abilitare il plot degli errori
points = 50000; % <-- Scegli quanti punti vuoi considerare
N = 150;       % Numero di punti per finestra

% Prendi solo i primi 'points' valori
yc_sel = yc(1:points);
xc_sel = xc(1:points);

num_windows = floor(length(yc_sel)/N);

variances = zeros(num_windows,1);
central_times = zeros(num_windows,1);

for i = 1:num_windows
    idx_start = (i-1)*N + 1;
    idx_end = i*N;
    window = yc_sel(idx_start:idx_end);
    variances(i) = var(window);
    central_times(i) = mean(xc_sel(idx_start:idx_end));
end

errors = sqrt(2./(N-1)) .* variances; % Calcolo dell'errore standard della varianza


% Plot istogramma della varianza nel tempo e segnale coerente
figure;
yyaxis left
hBar = bar(central_times, variances, 1, 'DisplayName', 'Variance');
ylabel('Variance');
ylim([0 max(variances) * 1.1]);

hold on
if PLOT_VAR_ERRORS
    % Plot error bars if enabled
    
    hErr = errorbar(central_times, variances, errors, 'k.', 'MarkerSize', 10, 'LineWidth', 1.5, 'DisplayName', 'Error Bars');
    yline(0, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Zero Line');
end

yyaxis right
hPlot = plot(xc_sel, yc_sel, 'r', 'DisplayName', 'Coherent State');
ylabel('Coherent State Signal');
ylim([min(yc_sel) max(yc_sel)]);

xlabel('Time (s)');
title(['Variance and Coherent State Signal (first ' num2str(points) ' points, windows of ' num2str(N) 'points)']);
grid on;

if PLOT_VAR_ERRORS
    legend([hBar hErr hPlot], {'Variance', 'Error Bars', 'Coherent State'}, 'Location', 'best');
else
    legend([hBar hPlot], {'Variance', 'Coherent State'}, 'Location', 'best');
end
hold off



figure;
plot(central_times, errors, 'DisplayName', 'Errors');
xlabel('Time (s)');
ylabel('Error');
title('Error in Variance Calculation');
grid on;
legend('Location', 'best');


% Plot della somma di yi e yn 
figure;
hold on;
plot(xi, yi + yin, 'DisplayName', 'Sum of Interference and Interference Neg');
plot(xc, yc, 'DisplayName', 'Coherent State');
xlabel('Time (s)');
ylabel('Values');
title('Interference sum');
legend;
grid on;
hold off;