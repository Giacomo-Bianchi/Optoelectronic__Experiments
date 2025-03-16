function [Uxy, Ixy] = gaussian_beam_function(A1, W0, z0, k, X, Y, z)
    % X, Y sono matrici (griglia) con coordinate x e y
    % z è la coordinata assiale dove calcoliamo il campo

    A0 = A1 / (1i * z0); % Ampiezza/fase iniziale

    % r^2 = x^2 + y^2
    R2 = X.^2 + Y.^2;

    % W(z) = W0 * sqrt(1 + (z/z0)^2)
    Wz = W0 * sqrt(1 + (z / z0)^2);

    % R(z) = z [1 + (z0/z)^2] (occhio a z=0 -> Rz = inf)
    % Se z=0, poniamo Rz=Inf => exp(-j k r^2 / (2 Rz)) = 1
    if abs(z) < 1e-15
        Rz = Inf;
    else
        Rz = z * (1 + (z0^2)/(z^2));
    end

    % Fase di Gouy: zeta(z) = arctan(z / z0)
    zeta = atan(z / z0);

    % Ampiezza gaussiana
    amp_factor = A0 * (W0 / Wz) .* exp(- R2 / (Wz^2));

    % Fattore di fase
    phase_factor = exp(-1i * k * z) ...
                 .* exp(-1i * k * (R2) / (2 * Rz)) ...
                 .* exp( 1i * zeta);

    % Campo complesso
    Uxy = amp_factor .* phase_factor;

    % Intensità
    Ixy = abs(Uxy).^2;