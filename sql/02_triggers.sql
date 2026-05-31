CREATE OR REPLACE FUNCTION controlla_prerequisiti() 
RETURNS TRIGGER AS $$
DECLARE
    mancanti TEXT;
BEGIN
    SELECT string_agg(p.codice_prerequisito, ', ')
    INTO mancanti
    FROM prerequisito p
    WHERE p.codice_corso = NEW.codice_corso
      AND NOT EXISTS (
          SELECT 1 FROM esame e
          WHERE e.matricola = NEW.matricola
            AND e.codice_corso = p.codice_prerequisito
            AND e.punteggio >= 18
      );

    IF mancanti IS NOT NULL THEN
        RAISE EXCEPTION 'Prerequisiti mancanti: %', mancanti;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_controlla_prerequisiti
BEFORE INSERT ON esame
FOR EACH ROW
EXECUTE FUNCTION controlla_prerequisiti();

CREATE OR REPLACE FUNCTION aggiorna_crediti_acquisiti() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.punteggio >= 18 THEN 
        UPDATE studente
        SET crediti_acquisiti = crediti_acquisiti + (SELECT crediti FROM corso WHERE codice = NEW.codice_corso)
        WHERE matricola = NEW.matricola;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_aggiorna_crediti_acquisiti
AFTER INSERT ON esame
FOR EACH ROW
EXECUTE FUNCTION aggiorna_crediti_acquisiti();