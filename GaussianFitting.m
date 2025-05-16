clear;clc; close all;
format long

% Fitting Dati reali , con funzione parametrizzata
USE_FMINSEARCH = true;
USE_FIT = true;
DO_PLOT_INITPARAMS = false;
DO_PLOTS = true;

%% Carico Dataset
% !!! --> Distanza in Micrometri e Intensità in Conteggi


% Quale dato vuoi caricare?
nomefolder = 'Data_2'; % 'Data_1' o 'Data_2'
var = 'Y'; % 'X' or 'Y'


addpath(nomefolder);

if var == 'X'
    filename = 'xprofile.csv';
elseif var == 'Y'
    filename = 'yprofile.csv';
else
    error('Input non valido. Inserisci "X" o "Y".');
end

data = loadDataProfiles_function(filename);

% converto da micrometri a millimetri
vec_real =data(:,1)*1e-3; %(data(:,1) - mean(data(:,1))) * 1e-3;  % µm -> mm

%% Fitting Dati reali , con funzione parametrizzata
Ffit = @(a) (a(1) * exp(-2 * (vec_real - a(4)).^2 / a(2)) + a(3));
fit_model = 'a1*exp(- 2 * (x - a4).^2 / a2) + a3';

% Parametri iniziali
if var == 'X'
    parametri_iniziali = [3700, 0.15, 90, 2.85];
else
    parametri_iniziali = [3700, 0.2, 90, 2.20];
end


if DO_PLOT_INITPARAMS
 
    disp(['Parametri iniziali ',var,':']);
    disp(parametri_iniziali);
    % 
    % plot funzione parametrizzata con parametri ottimali
    figure("Name", "Fit con parametri iniziali");
    subplot(2,1,1);
    plot(vec_real, data(:,2), 'LineWidth', 2); % Decommentata per plottare i dati reali
    hold on;
    plot(vec_real, Ffit(parametri_iniziali), 'LineWidth', 2);
    title('Parametri iniziali -> Profilo Intensità ',var);
    xlabel([var,' [mm]']);
    ylabel('Intensità [Conteggi]');
    grid on;
    legend('Dati Reali', 'Fit Ottimale');
    %residui
    subplot(2,1,2);
    residui = Ffit(parametri_iniziali)- data(:,2);
    plot(vec_real, residui, 'o', 'MarkerSize', 2);
    title('Residui del fit');
    xlabel([var, ' [mm]']);
    ylabel('Residui [Conteggi]');
    grid on;

end 

[parametri_ottimali_fmin, parametri_ottimali_fit, w_fmin, w_fit] = gaussianFitting_function(data, var,  parametri_iniziali, Ffit, fit_model, USE_FMINSEARCH, USE_FIT, DO_PLOTS);

if nomefolder == 'Data_1'
    %% Parametri Scheda tecnica
    % assumendo che i dati sono stati acquisiti a z [m] di distanza
    W_0 = 3.33/2; % [mm] 
    lambda = 1550*10^-6; % [nm -> mm] 
    z_R = pi * W_0^2 / lambda; % Rayleigh range [mm]

    z =  10^3; % [mm]

    W_z = W_0 * sqrt(1+(z/z_R)^2);

    disp('Parametri Scheda Tecnica (z = 1000 [mm]):')
    disp("W_z:")
    disp(W_z)
end