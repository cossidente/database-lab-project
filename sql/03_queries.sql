-- Restituisce l'insegnamento più ricorrente nei piani di studio (inclusi eventuali pari merito)
WITH conteggi_insegnamenti AS (
    SELECT i.nome, COUNT(*) AS frequenza
    FROM piano_di_studio pds
    JOIN insegnamento i ON pds.codice_insegnamento = i.codice
    GROUP BY i.codice, i.nome
)
SELECT nome, frequenza
FROM conteggi_insegnamenti
WHERE frequenza = (SELECT MAX(frequenza) FROM conteggi_insegnamenti);


-- Dato nome e cognome di un professore, un anno accademico e un periodo didattico restituire il suo calendario settimanale delle lezioni (insegnamento, giorno, fascia oraria, aula)
SELECT insegnamento.nome, lezione.giorno, lezione.fascia_oraria, lezione.aula
FROM lezione
JOIN insegnamento ON lezione.codice_insegnamento = insegnamento.codice
JOIN insegnamento_edizione ON lezione.codice_insegnamento = insegnamento_edizione.codice_insegnamento 
    AND lezione.anno_accademico = insegnamento_edizione.anno_accademico 
    AND lezione.periodo = insegnamento_edizione.periodo
JOIN docente ON insegnamento_edizione.cf_docente = docente.cf
WHERE docente.nome = 'Maria' 
    AND docente.cognome = 'Gozzi' 
    AND lezione.anno_accademico = '2024/2025' 
    AND lezione.periodo = '2';


-- Per ciascun insegnamento, calcolare la percentuale di prove superate rispetto ai tentativi totali
WITH tentativi_totali AS (
    SELECT codice_insegnamento, COUNT(*) AS totali
    FROM esame
    GROUP BY codice_insegnamento
), 
tentativi_superati AS (
    SELECT codice_insegnamento, COUNT(*) AS superati
    FROM esame
    WHERE punteggio >= 18
    GROUP BY codice_insegnamento
)
SELECT 
    i.nome, 
    (COALESCE(ts.superati, 0) * 100.0 / NULLIF(tt.totali, 0)) AS percentuale_superamento
FROM insegnamento i
LEFT JOIN tentativi_totali tt ON i.codice = tt.codice_insegnamento
LEFT JOIN tentativi_superati ts ON i.codice = ts.codice_insegnamento
ORDER BY percentuale_superamento DESC;


-- Dato un insegnamento, determinare la media dei tentativi effettuati dagli studenti che hanno effettivamente superato la prova
WITH tentativi_per_passare (matricola, num_tentativi) AS (
    SELECT esame.matricola, COUNT(*)
    FROM esame
    JOIN insegnamento ON esame.codice_insegnamento = insegnamento.codice
    WHERE insegnamento.nome = 'Teoria dei segnali'
    GROUP BY esame.matricola
    HAVING MAX(esame.punteggio) >= 18
)
SELECT AVG(num_tentativi) AS media_tentativi
FROM tentativi_per_passare;


-- Dato uno studente, si vuole gestire l'eliminazione di tutti i suoi dati in seguito ad una rinuncia agli studi
BEGIN;
-- Necessario per ON DELETE RESTRICT di matricola su esame
DELETE FROM esame
WHERE matricola = 15;

-- Rimozione del piano di studi gestita in automatico
DELETE FROM studente
WHERE matricola = 15;
COMMIT;


-- Dato un professore e l'anno accademico, si vuole gestire la sostituzione delle sue cattedre
UPDATE insegnamento_edizione
SET cf_docente = 'BNNGDI98L11M104F'
WHERE insegnamento_edizione.cf_docente = 'SDDGLM43R23E271L'
  AND insegnamento_edizione.anno_accademico = '2025/2026'
  AND EXISTS (
      -- Verifica abilitazione nuovo docente
      SELECT 1 
      FROM abilitazione_docente_insegnamento
      WHERE abilitazione_docente_insegnamento.cf_docente = 'BNNGDI98L11M104F' 
        AND abilitazione_docente_insegnamento.codice_insegnamento = insegnamento_edizione.codice_insegnamento
  );