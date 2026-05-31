CREATE OR UPDATE FUNCTION aggiorna_crediti_acquisiti() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.punteggio >= 18 THEN 
        UPDATE studente
        SET crediti_acquisiti = crediti_acquisiti + NEW.punteggio
        WHERE matricola = NEW.matricola_studente;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_aggiorna_crediti_acquisiti
AFTER INSERT ON esame
FOR EACH ROW
EXECUTE FUNCTION aggiorna_crediti_acquisiti();