close all; clc; clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gaussian_beam_DataComparison.m
% Il fascio si propaga lungo l'asse z, con waist in z=0.
%
%   U(x,y,z) = A0 * (W0 / W(z)) * exp(-(x^2 + y^2)/W(z)^2) ...
%              * exp[-j*k*z - j*k*(x^2 + y^2)/(2*R(z)) + j*zeta(z)]
%
% e I(x,y) = |U(x,y,z)|^2.
%
% Tutte le unità di misura sono espresse in millimetri (mm).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%% Parametri fisici (in mm)
lambda = 632.8e-6;     % lunghezza d'onda in mm (632.8 nm = 0.0006328 mm)
W0     = 1;            % raggio del fascio al waist in mm (1 mm)
k      = 2*pi / lambda; % numero d'onda [mm^-1]
z0     = pi * W0^2 / lambda;  % raggio di Rayleigh in mm
A0     = 10;            % ampiezza al waist

% Coordinata z in cui osservare la sezione trasversale (in mm)
z_val  = 10;   % ad esempio, 10 mm

%% Definizione dominio per i dati calcolati
% Usiamo l'intervallo reale dei dati come riferimento
x_min = min(x_vec_real);
x_max = max(x_vec_real);
y_min = min(y_vec_real);
y_max = max(y_vec_real);

Nx = 100;   % numero di punti su x
Ny = 100;   % numero di punti su y

x_vec = linspace(x_min, x_max, Nx);
y_vec = linspace(y_min, y_max, Ny);

% Creiamo la griglia 2D di coordinate (X,Y)
[X, Y] = meshgrid(x_vec, y_vec);

% Calcoliamo campo e intensità del fascio gaussiano
[Uxy, Ixy] = gaussian_beam_function(A0, W0, z0, k, X, Y, z_val);

%% Visualizzazione dei dati
DO_PLOTS = true; 
if DO_PLOTS
    % INTENSITA NEL PIANO X-Y
    figure(1);
    % Intensità Calcolata
    subplot(1,2,1);
    surf(x_vec, y_vec, Ixy, 'EdgeColor','none'); 
    view(2);            % vista dall'alto (2D)
    shading interp;     % interpolazione liscia
    colormap jet;       % mappa di colori
    colorbar;           % barra dei colori
    xlabel('x [mm]');
    ylabel('y [mm]');
    title(['Intensità (piano X-Y) a z = ', num2str(z_val), ' mm']);
    axis equal;         
    axis tight;     
    grid on;
    
    % Intensità Dati Reali
    subplot(1,2,2);
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

    % Subplots Profili di Intensità
    figure(3);
    % Profilo di intensità X (dati calcolati)
    subplot(2,2,1);
    plot(x_vec, Ixy(round(Ny/2), :), 'LineWidth', 2);
    xlabel('x [mm]');
    ylabel('Intensità');
    title(['Profilo di intensità X a z = ', num2str(z_val), ' mm']);
    grid on;

    % Profilo di intensità Y (dati calcolati)
    subplot(2,2,2);
    plot(y_vec, Ixy(:, round(Nx/2)), 'LineWidth', 2);
    xlabel('y [mm]');
    ylabel('Intensità');
    title(['Profilo di intensità Y a z = ', num2str(z_val), ' mm']);
    grid on;

    % Profilo di intensità X (Dati Reali)
    subplot(2,2,3);
    plot(x_vec_real, Ixy_real(round(minLength/2), :), 'LineWidth', 2);
    xlabel('x [mm]');
    ylabel('Intensità');
    title('Profilo di intensità X - Dati Reali');
    grid on;

    % Profilo di intensità Y (Dati Reali)
    subplot(2,2,4);
    plot(y_vec_real, Ixy_real(:, round(minLength/2)), 'LineWidth', 2);
    xlabel('y [mm]');
    ylabel('Intensità');
    title('Profilo di intensità Y - Dati Reali');
    grid on;

    % confronto profili di intensità
    figure(5);
    % Profili di intensità X
    subplot(1,2,1);
    hold on;
    plot(x_vec, Ixy(round(Ny/2), :), 'LineWidth', 2);
    plot(x_vec_real, Ixy_real(round(minLength/2), :), 'LineWidth', 2);
    hold off;
    xlabel('x [mm]');
    ylabel('Intensità');
    title('Profilo di intensità X');
    legend('Calcolato', 'Dati Reali');
    grid on;

    % Profili di intensità Y
    subplot(1,2,2);
    hold on;
    plot(y_vec, Ixy(:, round(Nx/2)), 'LineWidth', 2);
    plot(y_vec_real, Ixy_real(:, round(minLength/2)), 'LineWidth', 2);
    hold off;
    xlabel('y [mm]');
    ylabel('Intensità');
    title('Profilo di intensità Y');
    legend('Calcolato', 'Dati Reali');
    grid on;




end
