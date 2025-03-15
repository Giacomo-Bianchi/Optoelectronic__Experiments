function [data] = loadDataProfiles_function(filename)
    % loadDataProfiles carica dati dai file CSV specificati,
    % sostituisce le virgole con punti e restituisce le matrici numeriche.
    %
    % Input:
    %   filename - percorso completo del file CSV per il profilo 
    %
    % Output:
    %   data - matrice numerica dei dati per il profilo  (N2)
    
    % Leggi il contenuto dei file
    file = fileread(filename);
    
    % Sostituisci le virgole con i punti per la corretta interpretazione dei numeri
    file = strrep(file, ',', '.');
    
    % Crea file temporanei per salvare i dati modificati
    tempfile = 'temp_profile.csv';
    
    fid = fopen(tempfile, 'w');
    
    if fid == -1 
        error('Impossibile aprire i file temporanei.');
    end
    
    fwrite(fid, file);
    fclose(fid);
    
    % Leggi i dati numerici dai file temporanei, saltando le prime 2 righe (header)
    data = readmatrix(tempfile, 'NumHeaderLines', 2);
    
    % Elimina i file temporanei
    delete(tempfile);
end
