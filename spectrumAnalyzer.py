import pyvisa
import numpy as np
import matplotlib.pyplot as plt

# Inizializza la risorsa manager
rm = pyvisa.ResourceManager()

# Sostituisci l'indirizzo con quello corretto per il tuo strumento
# Esempio per GPIB: 'GPIB0::18::INSTR'
# Esempio per RS-232: 'ASRL1::INSTR'
instrument_address = 'GPIB0::18::INSTR'

# Apri la connessione con lo strumento
sa = rm.open_resource(instrument_address)

# Imposta il timeout (in millisecondi)
sa.timeout = 5000

# Imposta il formato dei dati su ASCII
sa.write('FORM ASC')

# Inizia una nuova acquisizione
sa.write('INIT;*WAI')

# Leggi i dati della traccia
trace_data = sa.query('TRAC? TRACE1')

# Converti la stringa di dati in un array di numeri
trace_points = np.array([float(val) for val in trace_data.strip().split(',')])

# (Opzionale) Visualizza i dati
plt.plot(trace_points)
plt.title('Dati della Traccia')
plt.xlabel('Punti')
plt.ylabel('Ampiezza (dBm)')
plt.grid(True)
plt.show()

# Chiudi la connessione
sa.close()
