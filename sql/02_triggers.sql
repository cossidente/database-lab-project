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
        IF NOT EXISTS (
            SELECT 1 FROM esame
            WHERE matricola = NEW.matricola
              AND codice_corso = NEW.codice_corso
              AND punteggio >= 18
              AND data_esame <> NEW.data_esame
        ) THEN
            UPDATE studente
            SET crediti_acquisiti = crediti_acquisiti + (
                SELECT crediti FROM corso WHERE codice = NEW.codice_corso
            )
            WHERE matricola = NEW.matricola;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_aggiorna_crediti_acquisiti
AFTER INSERT ON esame
FOR EACH ROW
EXECUTE FUNCTION aggiorna_crediti_acquisiti();

CREATE OR REPLACE FUNCTION blocca_modifica_esame() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Un esame registrato non può essere modificato o eliminato.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_blocca_modifica_esame
BEFORE UPDATE OR DELETE ON esame
FOR EACH ROW
EXECUTE FUNCTION blocca_modifica_esame();

CREATE OR REPLACE FUNCTION controlla_abilitazione_docente()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM abilitazione_docente_corso a
        WHERE a.cf_docente = NEW.cf_docente
          AND a.codice_corso = NEW.codice_corso
    ) THEN
        RAISE EXCEPTION 'Il docente % non è abilitato a insegnare il corso %', 
            NEW.cf_docente, NEW.codice_corso;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_controlla_abilitazione_docente
BEFORE INSERT ON insegnamento_edizione
FOR EACH ROW
EXECUTE FUNCTION controlla_abilitazione_docente();

CREATE OR REPLACE FUNCTION controlla_ciclo_prerequisiti()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        WITH RECURSIVE raggiungibili(codice) AS (
            SELECT NEW.codice_prerequisito
            UNION
            SELECT p.codice_prerequisito
            FROM prerequisito p
            JOIN raggiungibili r ON r.codice = p.codice_corso
        )
        SELECT 1 FROM raggiungibili WHERE codice = NEW.codice_corso
    ) THEN
        RAISE EXCEPTION 'Inserimento creerebbe un ciclo nei prerequisiti tra % e %',
            NEW.codice_corso, NEW.codice_prerequisito;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_controlla_ciclo_prerequisiti
BEFORE INSERT ON prerequisito
FOR EACH ROW
EXECUTE FUNCTION controlla_ciclo_prerequisiti();

CREATE OR REPLACE FUNCTION controlla_corso_in_piano()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM piano_di_studio
        WHERE matricola = NEW.matricola
          AND codice_corso = NEW.codice_corso
    ) THEN
        RAISE EXCEPTION 'Lo studente % non ha il corso % nel proprio piano di studi',
            NEW.matricola, NEW.codice_corso;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_controlla_corso_in_piano
BEFORE INSERT ON esame
FOR EACH ROW
EXECUTE FUNCTION controlla_corso_in_piano();