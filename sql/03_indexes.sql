-- Indici per i filtri di ricerca (Query)
CREATE INDEX idx_docente_cognome_nome ON docente (cognome, nome);
CREATE INDEX idx_insegnamento_nome ON insegnamento (nome);
CREATE INDEX idx_insegnamento_edizione_ricerca ON insegnamento_edizione (codice_insegnamento, anno_accademico, periodo);
CREATE INDEX idx_abilitazione_insegnamento ON abilitazione_docente_insegnamento (codice_insegnamento);

-- Indici per le seconde colonne di PK composite (Query + FK)
CREATE INDEX idx_piano_di_studio_insegnamento ON piano_di_studio (codice_insegnamento);
CREATE INDEX idx_esame_insegnamento ON esame (codice_insegnamento);

-- Navigazione inversa dei prerequisiti (CTE ricorsiva nel trigger)
CREATE INDEX idx_prerequisito_prerequisito ON prerequisito (codice_prerequisito);
