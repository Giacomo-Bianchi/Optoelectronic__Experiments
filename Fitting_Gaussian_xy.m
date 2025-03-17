clear;clc; close all;

% Fitting Dati reali , con funzione parametrizzata

%% Carico Dataset
% !!! --> Distanza in Micrometri e Intensità in Conteggi
addpath('Data1_Camera');
filenameX = 'Data1_Camera\xprofile.csv';
filenameY = 'Data1_Camera\yprofile.csv';


dataX = loadDataProfiles_function(filenameX);
dataY = loadDataProfiles_function(filenameY);

lenX = size(dataX, 1);
lenY = size(dataY, 1);
minLength = min(lenX, lenY);

% Calcola quanti valori eliminare per ciascun dataset, in modo simmetrico
trimAmountX = floor((lenX - minLength) / 2);
trimAmountY = floor((lenY - minLength) / 2);

% Estrai solo la porzione centrale dei dati per avere minLength righe
dataX = dataX(trimAmountX+1 : trimAmountX+minLength, :);
dataY = dataY(trimAmountY+1 : trimAmountY+minLength, :);

%% Intensità dati reali
% Calcolo della matrice intensità (outer product delle intensità X e Y)
Ixy_real = dataX(:,2) * dataY(:,2)';
% Normalizzazione
%Ixy_real = Ixy_real / max(Ixy_real(:));

% Conversione delle coordinate da µm a mm:
x_vec_real = (dataX(:,1) - mean(dataX(:,1))) * 1e-3;  % µm -> mm
y_vec_real = (dataY(:,1) - mean(dataY(:,1))) * 1e-3;  % µm -> mm

DO_REAL_PLOTS = false;
if DO_REAL_PLOTS
    % Plot dei dati reali
    figure;
    surf(x_vec_real, y_vec_real, Ixy_real, 'EdgeColor','none');
    view(2);            % vista dall'alto (2D)
    shading interp;     % interpolazione liscia
    colormap jet;       % mappa di colori
    colorbar;           % barra dei colori
    xlabel('x [mm]');
    ylabel('y [mm]');
    title('Intensità Dati Reali (piano X-Y)');
    axis equal;
    axis tight;
    grid on;

    figure;
    plot(x_vec_real, dataX(:,2), 'r', 'LineWidth', 2);
    title('Profilo Intensità X');
    xlabel('x [mm]');
    ylabel('Intensità [Conteggi]');
    grid on;

    figure;
    plot(y_vec_real, dataY(:,2), 'b', 'LineWidth', 2);
    title('Profilo Intensità Y');
    xlabel('y [mm]');
    ylabel('Intensità [Conteggi]');
    grid on;

end

%% Fitting Dati reali , con funzione parametrizzata

FfitX = @(a)a(1) * exp(-2 * (x_vec_real - a(4)).^2 / a(2)) + a(3);
FfitY = @(a)a(1) * exp(-2 * (y_vec_real - a(4)).^2 / a(2)) + a(3);

% Funzione di errore
erroreX = @(a)sum((FfitX(a) - dataX(:,2)).^2);
erroreY = @(a)sum((FfitY(a) - dataY(:,2)).^2);

% Parametri iniziali
parametri_iniziali_X = [5534, 10, 218, 0];
parametri_iniziali_Y = [4742.1, 10, 0, 0];

%% ----> fminsearch() <----
% Ottimizzazione dei parametri
parametri_ottimali_X_fmin = fminsearch(erroreX, parametri_iniziali_X);
parametri_ottimali_Y_fmin = fminsearch(erroreY, parametri_iniziali_Y); 
disp('Parametri ottimali X fminsearch:');
disp(parametri_ottimali_X_fmin);
disp('Parametri ottimali Y fminsearch:');
disp(parametri_ottimali_Y_fmin);

% plot funzione parametrizzata con parametri ottimali
figure("Name", "Fit con fminsearch");
subplot(1,2,1);
plot(dataX(:,1), dataX(:,2), 'LineWidth', 2); % Decommentata per plottare i dati reali
hold on;
plot(dataX(:,1), FfitX(parametri_ottimali_X_fmin), 'LineWidth', 2);
title('Profilo Intensità X');
xlabel('x [mm]');
ylabel('Intensità [Conteggi]');
grid on;
legend('Dati Reali', 'Fit Ottimale');

subplot(1,2,2);
plot(dataY(:,1), dataY(:,2), 'LineWidth', 2); % Decommentata per plottare i dati reali
hold on;
plot(dataY(:,1), FfitY(parametri_ottimali_Y_fmin), 'LineWidth', 2);
title('Profilo Intensità Y');
xlabel('y [mm]');
ylabel('Intensità [Conteggi]');
grid on;
legend('Dati Reali', 'Fit Ottimale');

%% -----> fit() <-----
% Definisci il modello di fit gaussiano
gaussModel = fittype('a1*exp(- 2 * (x - 4*a4).^2 / a2) + a3', 'independent', 'x', 'coefficients', {'a1', 'a2', 'a3','a4'});

% Opzioni di fitting
fitOptions = fitoptions('Method', 'NonlinearLeastSquares', 'StartPoint', parametri_ottimali_X_fmin,...
                        'Lower', parametri_ottimali_X_fmin - [1000,0.01,1,0.001]*10^3,...
                        'Upper', parametri_ottimali_X_fmin + [1000,0.01,1,0.001]*10^3);

% Fitting dei dati X
fitResultX = fit(dataX(:,1), dataX(:,2), gaussModel, fitOptions);

% Fitting dei dati Y
fitOptions.StartPoint = parametri_ottimali_Y_fmin; % Aggiorna i parametri iniziali per Y
fitOptions.Lower = parametri_ottimali_Y_fmin - [1000,0.01,1,0.001]*10^3; % Aggiorna i limiti inferiori per Y
fitOptions.Upper = parametri_ottimali_Y_fmin + [1000,0.01,1,0.001]*10^3; % Aggiorna i limiti superiori per Y

fitResultY = fit(dataY(:,1), dataY(:,2), gaussModel, fitOptions);

% Estrai i parametri ottimali
parametri_ottimali_X_fit = coeffvalues(fitResultX);
parametri_ottimali_Y_fit = coeffvalues(fitResultY);
disp('Parametri ottimali X fit:');
disp(parametri_ottimali_X_fit);
disp('Parametri ottimali Y fit:');
disp(parametri_ottimali_Y_fit);

% Intervalli confidenza
ciX = confint(fitResultX);
ciY = confint(fitResultY);
disp('Intervalli di confidenza X:');
disp(ciX);
disp('Intervalli di confidenza Y:');
disp(ciY);

% plot funzione parametrizzata con parametri ottimali
figure("Name", "Fit con fit()");
subplot(1,2,1);
plot(dataX(:,1), dataX(:,2), 'LineWidth', 2); % Decommentata per plottare i dati reali
hold on;
plot(dataX(:,1) ,FfitX(parametri_ottimali_X_fit), 'LineWidth', 2);
title('Profilo Intensità X');
xlabel('x [mm]');
ylabel('Intensità [Conteggi]');
grid on;
legend('Dati Reali', 'Fit Ottimale');

subplot(1,2,2);
plot(dataY(:,1), dataY(:,2), 'LineWidth', 2); % Decommentata per plottare i dati reali
hold on;
plot(dataY(:,1), FfitY(parametri_ottimali_Y_fit), 'LineWidth', 2);
title('Profilo Intensità Y');
xlabel('y [mm]');
ylabel('Intensità [Conteggi]');
grid on;
legend('Dati Reali', 'Fit Ottimale');


