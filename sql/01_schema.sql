CREATE TYPE titolo_enum AS ENUM ('Professore ordinario', 'Professore associato', 'Ricercatore');

CREATE TYPE periodo_enum AS ENUM ('1', '2', '3');

CREATE TYPE giorno_enum AS ENUM ('Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì');

CREATE TYPE fascia_oraria_enum AS ENUM ('1', '2', '3', '4');

CREATE DOMAIN codice_fiscale AS CHAR(16)
    CHECK (VALUE ~ '^[A-Z]{6}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{3}[A-Z]{1}$');

CREATE DOMAIN telefono_dom AS CHAR(10)
    CHECK (VALUE ~ '^[0-9]{10}$');

CREATE DOMAIN anno_accademico AS CHAR(9)
    CHECK (VALUE ~ '^[0-9]{4}/[0-9]{4}$' AND 
           CAST(split_part(VALUE, '/', 2) AS INTEGER) = CAST(split_part(VALUE, '/', 1) AS INTEGER) + 1);

CREATE DOMAIN corso_dom AS CHAR(5)
    CHECK (VALUE ~ '^[0-9]{5}$');

CREATE DOMAIN punteggio AS INTEGER
    CHECK (VALUE >= 0 AND VALUE <= 30);

CREATE TABLE dipartimento (
    codice VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE corso_di_laurea (
    codice VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE docente (
    cf codice_fiscale PRIMARY KEY,
    nome VARCHAR(40) NOT NULL,
    cognome VARCHAR(40) NOT NULL,
    titolo titolo_enum NOT NULL,
    dipartimento VARCHAR(10) NOT NULL,

    FOREIGN KEY (dipartimento) REFERENCES dipartimento(codice) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE studente (
    matricola SERIAL PRIMARY KEY,
    nome VARCHAR(40) NOT NULL,
    cognome VARCHAR(40) NOT NULL,
    telefono telefono_dom,
    aa_immatricolazione anno_accademico NOT NULL,
    corso_di_laurea VARCHAR(10) NOT NULL,
    crediti_acquisiti INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (corso_di_laurea) REFERENCES corso_di_laurea(codice) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE corso (
    codice corso_dom PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    crediti INTEGER NOT NULL,
    descrizione TEXT,

    CONSTRAINT ck_crediti CHECK (crediti > 0)
);

CREATE TABLE edizione (
    codice_corso corso_dom,
    anno_accademico anno_accademico,
    periodo periodo_enum,

    PRIMARY KEY (codice_corso, anno_accademico, periodo),
    FOREIGN KEY (codice_corso) REFERENCES corso(codice) ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT uq_singola_edizione_annuale UNIQUE (codice_corso, anno_accademico)
);

CREATE TABLE lezione (
    codice_corso corso_dom,
    anno_accademico anno_accademico,
    periodo periodo_enum,
    giorno giorno_enum,
    fascia_oraria fascia_oraria_enum,
    aula VARCHAR(20) NOT NULL,

    PRIMARY KEY (codice_corso, anno_accademico, periodo, giorno, fascia_oraria, aula),
    FOREIGN KEY (codice_corso, anno_accademico, periodo) 
        REFERENCES edizione(codice_corso, anno_accademico, periodo) ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT uq_occupazione_aula UNIQUE (anno_accademico, periodo, giorno, fascia_oraria, aula)
);

CREATE TABLE esame (
    matricola INTEGER,
    codice_corso corso_dom,
    data_esame DATE,
    punteggio punteggio,

    PRIMARY KEY (matricola, codice_corso, data_esame),
    FOREIGN KEY (matricola) REFERENCES studente(matricola) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codice_corso) REFERENCES corso(codice) ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT ck_data_esame CHECK (data_esame <= CURRENT_DATE)
);

CREATE TABLE piano_di_studio (
    matricola INTEGER,
    codice_corso corso_dom,

    PRIMARY KEY (matricola, codice_corso),
    FOREIGN KEY (matricola) REFERENCES studente(matricola) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codice_corso) REFERENCES corso(codice) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE prerequisito (
    codice_corso corso_dom,
    codice_prerequisito corso_dom,

    PRIMARY KEY (codice_corso, codice_prerequisito),
    FOREIGN KEY (codice_corso) REFERENCES corso(codice) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codice_prerequisito) REFERENCES corso(codice) ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT ck_prerequisito CHECK (codice_corso <> codice_prerequisito)
);

CREATE TABLE abilitazione_docente_corso (
    cf_docente codice_fiscale,
    codice_corso corso_dom,

    PRIMARY KEY (cf_docente, codice_corso),
    FOREIGN KEY (cf_docente) REFERENCES docente(cf) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codice_corso) REFERENCES corso(codice) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE insegnamento_edizione (
    cf_docente codice_fiscale,
    codice_corso corso_dom,
    anno_accademico anno_accademico,
    periodo periodo_enum,

    PRIMARY KEY (cf_docente, codice_corso, anno_accademico),
    FOREIGN KEY (cf_docente) REFERENCES docente(cf) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (codice_corso, anno_accademico, periodo) 
        REFERENCES edizione(codice_corso, anno_accademico, periodo) ON DELETE CASCADE ON UPDATE CASCADE
);
