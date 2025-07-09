clear; close all; clc;

%% Grid parameters
q = linspace(-5, 5, 200);
p = linspace(-5, 5, 200);
[Q, P] = meshgrid(q, p);
alpha = 2 + 0i; % coherent state parameter

%% Wigner function for coherent state
W_coherent = (1/pi) * exp(- (Q - real(alpha)).^2 - (P - imag(alpha)).^2);

%% Squeezed state parameters
r = 0.8;         % squeezing parameter
theta = 0;       % squeezing angle (0 = squeezing on q)

% Modified variances
sigma_q = exp(-r);
sigma_p = exp(r);

% Wigner function for squeezed state (centered at origin for simplicity)
W_squeezed = (1/pi) * exp( - Q.^2 / sigma_q^2 - P.^2 / sigma_p^2 );

%% Squeezed displaced state (optional)
% If you also want to displace the squeezed state like a coherent one, add an alpha
% W_squeezed = (1/pi) * exp( - (Q - real(alpha)).^2 / sigma_q^2 - (P - imag(alpha)).^2 / sigma_p^2 );

%% Plot coherent and squeezed states using subplots
figure;

subplot(1,2,1);
contourf(q, p, W_coherent, 50, 'LineColor', 'none');
colorbar;
xlabel('q');
ylabel('p');
title('Wigner Function - Coherent State');
axis equal tight;

subplot(1,2,2);
contourf(q, p, W_squeezed, 50, 'LineColor', 'none');
colorbar;
xlabel('q');
ylabel('p');
title('Wigner Function - Squeezed State');
axis equal tight;
