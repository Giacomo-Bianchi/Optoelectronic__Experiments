close all
clear
clc

% === Percorsi dei file ===
filepath1 = 'CMR_Data/CMR_OSCILLANTE.txt';
filepath2 = 'CMR_Data/TwoBeamsCMR000.txt';
filepath3 = 'CMR_Data/TwoBeamsCMRonlyone000.txt';

% === Lettura dati con gestione errori ===
try
    dataOsc = readmatrix(filepath1);
    dataTwoBeams = readmatrix(filepath2);
    dataOneBeam = readmatrix(filepath3);
catch ME
    error('Errore nella lettura dei file: %s', ME.message);
end

% === Primo grafico: confronto due fasci ON/OFF ===
figure;
plot(dataTwoBeams(:,1), dataTwoBeams(:,2), 'LineWidth', 1.5, 'DisplayName', 'Due fasci ON');
hold on;
plot(dataOneBeam(:,1), dataOneBeam(:,2), 'LineWidth', 1.5, 'DisplayName', 'Un fascio ON');
legend('Location', 'best');
xlabel('Tempo (s)');
ylabel('Segnale (V)');
title('Confronto segnale: due fasci vs uno');
grid on;

% === Secondo grafico: CMR e relativo valore ===
[maxVal, idxMax] = max(dataOsc(:,2));
relVal = dataOsc(idxMax,3);

figure;
plot(dataOsc(:,1), dataOsc(:,2), 'LineWidth', 1.5, 'DisplayName', 'CMR');
hold on;
plot(dataOsc(:,1), dataOsc(:,3), 'LineWidth', 1.5, 'DisplayName', 'Un solo fascio');
legend('Location', 'best');
xlabel('Tempo (Hz)');
ylabel('Valore (dB)');
title('CMR e confronto con un solo fascio');
grid on;

% Evidenzia massimo e relativo
plot(dataOsc(idxMax,1), maxVal, 'bo', 'MarkerFaceColor', 'b');
plot(dataOsc(idxMax,1), relVal, 'ro', 'MarkerFaceColor', 'r');
text(dataOsc(idxMax,1), maxVal, sprintf(' Max: %.4f', maxVal), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'FontSize', 10, 'Color', 'b');
text(dataOsc(idxMax,1), relVal, sprintf(' Rel: %.4f', relVal), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 10, 'Color', 'r');