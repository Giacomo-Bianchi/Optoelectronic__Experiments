clear;clc; close all;
format long

% Fitting Dati reali , con funzione parametrizzata

%% Carico Dataset
% !!! --> Distanza in Micrometri e Intensità in Conteggi
addpath('Data_2');

%{
 prompt = 'Vuoi leggere i dati del profilo X o Y? (X/Y): ';
%disp(prompt);
profileType = input(prompt, 's');

if strcmpi(profileType, 'X') || strcmpi(profileType, 'x')
    filename = 'Data1_Camera\xprofile.csv';
    var = 'X';
elseif strcmpi(profileType, 'Y') || strcmpi(profileType, 'y')
    filename = 'Data1_Camera\yprofile.csv';
    var = 'Y';
else
    error('Input non valido. Inserisci "X" o "Y".');
end 
%}

LoadX = true;
if LoadX
    filename = 'Data_2\xprofile.csv';
    var = 'X';
else
    filename = 'Data_2\yprofile.csv';
    var = 'Y';
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

USE_FMINSEARCH = true;
USE_FIT = true;
DO_PLOT_INITPARAMS = false;

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

[parametri_ottimali_fmin, parametri_ottimali_fit, w_fmin, w_fit] = gaussianFitting_function(data, var,  parametri_iniziali, Ffit, fit_model, USE_FMINSEARCH, USE_FIT);
%{
 %% ----> fminsearch() <----
if USE_FMINSEARCH
    disp('--------------------------------------fminsearch()--------------------------------------');

    % Funzione di errore
    errore = @(a)sum((Ffit(a) - data(:,2)).^2);

    % Ottimizzazione dei parametri
    parametri_ottimali_fmin = fminsearch(errore, parametri_iniziali);
    % parametri_ottimali_fmin = parametri_iniziali;

    disp(['Parametri ottimali ',var,' fminsearch:']);
    disp(parametri_ottimali_fmin);
    % 
    % plot funzione parametrizzata con parametri ottimali
    figure("Name", "Fit con fminsearch");
    subplot(2,1,1);
    plot(vec_real, data(:,2), 'LineWidth', 2); % Decommentata per plottare i dati reali
    hold on;
    plot(vec_real, Ffit(parametri_ottimali_fmin), 'LineWidth', 2);
    title('fminsearch() -> Profilo Intensità ',var);
    xlabel([var,' [mm]']);
    ylabel('Intensità [Conteggi]');
    grid on;
    legend('Dati Reali', 'Fit Ottimale');
    %residui
    subplot(2,1,2);
    residui = Ffit(parametri_ottimali_fmin)- data(:,2);
    plot(vec_real, residui, 'o', 'MarkerSize', 2);
    title('Residui del fit');
    xlabel([var, ' [mm]']);
    ylabel('Residui [Conteggi]');
    grid on;


    % Weist (raggio!)
    w_fmin = (2*parametri_ottimali_fmin(2))^0.5;
    disp("Weist:")
    disp(w_fmin)

    % Errore quadratico medio fminsearch
    disp('Errore quadratico medio fminsearch:');
    disp(mean((Ffit(parametri_ottimali_fmin) - data(:,2)).^2));
end

%% -----> fit() <-----
if USE_FIT
    disp('--------------------------------------fit()--------------------------------------');

    if USE_FMINSEARCH
        parametri_ottimali_fmin = parametri_ottimali_fmin;
    else
        parametri_ottimali_fmin = parametri_iniziali;
    end

    parametri_ottimali_fmin = parametri_iniziali;


    % Definisci il modello di fit gaussiano
    gaussModel = fittype('a1*exp(- 2 * (x - a4).^2 / a2) + a3', 'independent', 'x', 'coefficients', {'a1', 'a2', 'a3','a4'});

    % Opzioni di fitting
    fitOptions = fitoptions('Method', 'NonlinearLeastSquares', ...
                                'StartPoint', parametri_ottimali_fmin);


    % Fitting dei dati
    fitResult = fit(vec_real, data(:,2), gaussModel, fitOptions);

    % Estrai i parametri ottimali
    parametri_ottimali_fit = coeffvalues(fitResult);
    disp(['Parametri ottimali fit ', var, ':']);
    disp(parametri_ottimali_fit);

    % Intervalli confidenza
    ci = confint(fitResult);
    disp(['Intervalli di confidenza ',var,':']);
    disp(ci);

    % plot funzione parametrizzata con parametri ottimali
    figure("Name", "Fit con fit()");
    subplot(2,1,1);
    plot(vec_real, data(:,2), 'LineWidth', 2); % Decommentata per plottare i dati reali
    hold on;
    plot(vec_real ,Ffit(parametri_ottimali_fit), 'LineWidth', 2);
    title('fit() -> Profilo Intensità ',var);
    xlabel([var,' [mm]']);
    ylabel('Intensità [Conteggi]');
    grid on;
    legend('Dati Reali', 'Fit Ottimale');
    %residui
    subplot(2,1,2);
    residui = Ffit(parametri_ottimali_fit)- data(:,2);
    plot(vec_real, residui, 'o', 'MarkerSize', 2);
    title('Residui del fit');
    xlabel([var, ' [mm]']);
    ylabel('Residui [Conteggi]');
    grid on;

    % Weist (raggio!)
    w_fit = (2*parametri_ottimali_fit(2))^0.5;
    disp("Weist:")
    disp(w_fit)

    % Errore quadratico medio fit
    disp('Errore quadratico medio fit:');
    disp(mean((Ffit(parametri_ottimali_fit) - data(:,2)).^2));

end 
%}


%% Parametri Scheda tecnica

%{
disp('--------------------------------------Scheda Tecnica--------------------------------------');
 % assumendo che i dati sono stati acquisiti a z [m] di distanza
W_0 = 3.33/2; % [mm] 
lambda = 1550*10^-6; % [nm -> mm] 
z_R = pi * W_0^2 / lambda; % Rayleigh range [mm]

z =  10^3; % [mm]

W_z = W_0 * sqrt(1+(z/z_R)^2);

disp(['Parametri Scheda Tecnica (z = 1000 [mm]):'])
disp("W_z:")
disp(W_z) 
%}
