clear;clc; close all;
format long

% Fitting Dati reali , con funzione parametrizzata

%% Carico Dataset
% !!! --> Distanza in Micrometri e Intensità in Conteggi
addpath('Data1_Camera');

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
LoadX = false;
if LoadX
    filename = 'Data1_Camera\xprofile.csv';
    var = 'X';
else
    filename = 'Data1_Camera\yprofile.csv';
    var = 'Y';
end


data = loadDataProfiles_function(filename);

%% Intensità dati reali
% Conversione delle coordinate da µm a mm:
vec_real =data(:,1)*1e-3; %(data(:,1) - mean(data(:,1))) * 1e-3;  % µm -> mm
%% Fitting Dati reali , con funzione parametrizzata
Ffit = @(a) (a(1) * exp(-2 * (vec_real - a(4)).^2 / a(2)) + a(3));

% Funzione di errore
errore = @(a)sum((Ffit(a) - data(:,2)).^2);

% Parametri iniziali
if var == 'X'
    parametri_iniziali = [3000, 1, 218, 3.1];
else
    parametri_iniziali = [3000, 2, 200, 2.25];
end

USE_FMINSEARCH = true;
USE_FIT = true;

%% ----> fminsearch() <----
if USE_FMINSEARCH
% Ottimizzazione dei parametri
    parametri_ottimali_fmin = fminsearch(errore, parametri_iniziali);
    % parametri_ottimali_fmin = parametri_iniziali;

    disp('Parametri ottimali X fminsearch:');
    disp(parametri_ottimali_fmin);
    % 
    % plot funzione parametrizzata con parametri ottimali
    figure("Name", "Fit con fminsearch");
    plot(data(:,1), data(:,2), 'LineWidth', 2); % Decommentata per plottare i dati reali
    hold on;
    plot(data(:,1), Ffit(parametri_ottimali_fmin), 'LineWidth', 2);
    title('Profilo Intensità ',var);
    xlabel([var,' [mm]']);
    ylabel('Intensità [Conteggi]');
    grid on;
    legend('Dati Reali', 'Fit Ottimale');

    % Weist (raggio!)
    w_fmin = (2*parametri_ottimali_fmin(2))^0.5;
    disp("Weist:")
    disp(w_fmin)
end
%% -----> fit() <-----
if USE_FIT
    if USE_FMINSEARCH
        parametri_ottimali_fmin = parametri_ottimali_fmin;
    else
        parametri_ottimali_fmin = parametri_iniziali;
    end

    % Definisci il modello di fit gaussiano
    gaussModel = fittype('a1*exp(- 2 * (x - a4).^2 / a2) + a3', 'independent', 'x', 'coefficients', {'a1', 'a2', 'a3','a4'});

    % Opzioni di fitting
    fitOptions = fitoptions('Method', 'NonlinearLeastSquares', 'StartPoint', parametri_ottimali_fmin ); % ...
                            %,'Lower', parametri_ottimali_fmin - [1000,0.01,1,0.001]*10^3,...
                            %,'Upper', parametri_ottimali_fmin + [1000,0.01,1,0.001]*10^3 );

    % Fitting dei dati
    fitResult = fit(data(:,1), data(:,2), gaussModel, fitOptions);

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
    plot(data(:,1), data(:,2), 'LineWidth', 2); % Decommentata per plottare i dati reali
    hold on;
    plot(data(:,1) ,Ffit(parametri_ottimali_fit), 'LineWidth', 2);
    title('Profilo Intensità ',var);
    xlabel([var,' [mm]']);
    ylabel('Intensità [Conteggi]');
    grid on;
    legend('Dati Reali', 'Fit Ottimale');
end