function [Ffit] = Fitting_function(a1, a2, a3)
% funzione parametrizzata dell'intensità gaussiana
    Ffit = @(a1,a2,a3)a1 * exp(-2 * x / a2) + a3;
    

end