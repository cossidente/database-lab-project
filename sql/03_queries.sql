-- Determinare quale insegnamento compare più frequentemente nei piani di studio
SELECT corso.nome, COUNT(*) AS frequenza
FROM piano_di_studio
JOIN corso ON piano_di_studio.codice_corso = corso.codice
GROUP BY corso.codice, corso.nome
ORDER BY frequenza DESC
LIMIT 1;

-- Dato nome e cognome di un professore, un anno accademico e un periodo didattico restituire il suo calendario settimanale delle lezioni (insegnamento, giorno, fascia oraria, aula)
SELECT corso.nome, lezione.giorno, lezione.fascia_oraria, lezione.aula
FROM lezione
JOIN corso ON lezione.codice_corso = corso.codice
JOIN insegnamento_edizione ON lezione.codice_corso = insegnamento_edizione.codice_corso 
    AND lezione.anno_accademico = insegnamento_edizione.anno_accademico 
    AND lezione.periodo = insegnamento_edizione.periodo
JOIN docente ON insegnamento_edizione.cf_docente = docente.cf
WHERE docente.nome = 'Maria' 
    AND docente.cognome = 'Gozzi' 
    AND lezione.anno_accademico = '2024/2025' 
    AND lezione.periodo = '2';

-- Dato un insegnamento, calcolare la percentuale di prove superate rispetto al totale dei tentativi registrati
WITH tentativi_totali (codice_corso, totali) AS (
    SELECT codice_corso, COUNT(*)
    FROM esame
    GROUP BY codice_corso
), 
tentativi_superati (codice_corso, superati) AS (
    SELECT codice_corso, COUNT(*) AS superati
    FROM esame
    WHERE punteggio >= 18
    GROUP BY codice_corso
)
SELECT corso.nome, (tentativi_superati.superati * 100.0 / tentativi_totali.totali) AS percentuale_superamento
FROM tentativi_totali
JOIN tentativi_superati ON tentativi_totali.codice_corso = tentativi_superati.codice_corso
JOIN corso ON tentativi_totali.codice_corso = corso.codice
WHERE corso.nome = 'Logica matematica';

-- Dato un insegnamento, determinare la media dei tentativi effettuati dagli studenti che hanno effettivamente superato la prova
WITH tentativi_per_passare (matricola, num_tentativi) AS (
    SELECT esame.matricola, COUNT(*)
    FROM esame
    JOIN corso ON esame.codice_corso = corso.codice
    WHERE corso.nome = 'Teoria dei segnali'
    GROUP BY esame.matricola
    HAVING MAX(esame.punteggio) >= 18
)
SELECT AVG(num_tentativi) AS media_tentativi
FROM tentativi_per_passare;
