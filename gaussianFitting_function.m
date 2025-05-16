function [parametri_ottimali_fmin, parametri_ottimali_fit, w_fmin, w_fit] = gaussianFitting_function(data, var, parametri_iniziali, Ffit,gaussian_fit_model, USE_FMINSEARCH, USE_FIT, DO_PLOTS);
% GaussianFitting_function: Funzione per il fitting di dati reali con una funzione gaussiana parametrizzata
% ------------------------------------------------------------------------------------------------%
% INPUT:
    % data:                 dati reali
    % var:                  variabile indipendente (X o Y)
    % parametri_iniziali:   parametri iniziali per il fitting
    % Ffit:                 funzione di fitting
    % gaussian_fit_model:   modello di fitting gaussiano
    % USE_FMINSEARCH:       flag per l'utilizzo di fminsearch()
    % USE_FIT:              flag per l'utilizzo di fit()
    % DO_PLOTS:             flag per il plotting
%
% OUTPUT:
    % parametri_ottimali_fmin:  parametri ottimali ottenuti con fminsearch()
    % parametri_ottimali_fit:   parametri ottimali ottenuti con fit()
    % w_fmin:                   Weist ottenuto con fminsearch()
    % w_fit:                    Weist ottenuto con fit()

% ------------------------------------------------------------------------------------------------%

% Se le flag non sono settate, impostale a vere
if ~exist('USE_FMINSEARCH', 'var')
    USE_FMINSEARCH = true;
end
if ~exist('USE_FIT', 'var')
    USE_FIT = true;
end
if ~exist('DO_PLOTS', 'var')
    DO_PLOTS = false;
end

% converto da micrometri a millimetri
vec_real =data(:,1)*1e-3; %(data(:,1) - mean(data(:,1))) * 1e-3;  % µm -> mm

parametri_ottimali_fit = [];
parametri_ottimali_fmin = [];

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
    
    if DO_PLOTS
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
    end

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
    gaussModel = fittype(gaussian_fit_model, 'independent', 'x', 'coefficients', {'a1', 'a2', 'a3','a4'});

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

    if DO_PLOTS
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
    end

    % Weist (raggio!)
    w_fit = (2*parametri_ottimali_fit(2))^0.5;
    disp("Weist:")
    disp(w_fit)

    % Errore quadratico medio fit
    disp('Errore quadratico medio fit:');
    disp(mean((Ffit(parametri_ottimali_fit) - data(:,2)).^2));

end