close all
clear
clc

% === File paths ===
filepath1 = 'CMR_Data/CMR_OSCILLANTE.txt';
filepath2 = 'CMR_Data/TwoBeamsCMR001.txt';
filepath3 = 'CMR_Data/TwoBeamsCMRonlyone000.txt';

% === Data reading with error handling ===
try
    dataOsc = readmatrix(filepath1);
    dataTwoBeams = readmatrix(filepath2);
    dataOneBeam = readmatrix(filepath3);
catch ME
    error('Error reading files: %s', ME.message);
end

% === First plot: comparison two beams ON/OFF ===
figure;
plot(dataTwoBeams(:,1), dataTwoBeams(:,2), 'LineWidth', 1.5, 'DisplayName', 'Two beams ON');
hold on;
plot(dataOneBeam(:,1), dataOneBeam(:,2), 'LineWidth', 1.5, 'DisplayName', 'One beam ON');
legend('Location', 'best');
xlabel('Time (s)');
ylabel('Signal (V)');
title('Signal comparison: two beams vs one');
grid on;

% === Second plot: CMR and related value ===
[maxVal, idxMax] = max(dataOsc(:,2));
relVal = dataOsc(idxMax,3);

figure;
plot(dataOsc(:,1), dataOsc(:,2), 'LineWidth', 1.5, 'DisplayName', 'CMR');
hold on;
plot(dataOsc(:,1), dataOsc(:,3), 'LineWidth', 1.5, 'DisplayName', 'One beam only');
legend('Location', 'best');
xlabel('Time (Hz)');
ylabel('Value (dB)');
title('CMR and comparison with one beam only');
grid on;

% Highlight maximum and related value
plot(dataOsc(idxMax,1), maxVal, 'bo', 'MarkerFaceColor', 'b');
plot(dataOsc(idxMax,1), relVal, 'ro', 'MarkerFaceColor', 'r');
text(dataOsc(idxMax,1), maxVal, sprintf(' Max: %.4f', maxVal), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'FontSize', 10, 'Color', 'b');
text(dataOsc(idxMax,1), relVal, sprintf(' Rel: %.4f', relVal), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 10, 'Color', 'r');