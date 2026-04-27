CREATE TABLE Utente(
                       utente_id     SERIAL          PRIMARY KEY,
                       username      varchar(30)     NOT NULL,
                       email         varchar(30)     NOT NULL,
                       nome_completo varchar(30),
                       password      varchar(20)     NOT NULL,

                       CONSTRAINT credenziali_univoche UNIQUE(username, email),

                       CONSTRAINT check_email_format
                           CHECK (email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(it|com)$'),

                       CONSTRAINT check_minLength_password CHECK (LENGTH(password) >= 8)
);

CREATE TYPE TitoloBacheca AS ENUM ('Università', 'Lavoro', 'Tempo Libero');

CREATE TABLE Bacheca(
                        bacheca_id           SERIAL         PRIMARY KEY,
                        bacheca_titolo       TitoloBacheca  NOT NULL,
                        bacheca_descrizione  varchar(200),
                        utente_id            integer        NOT NULL,

                        CONSTRAINT fk_utente FOREIGN KEY (utente_id)
                            REFERENCES Utente(utente_id)
                            ON DELETE CASCADE
);

CREATE TABLE Task(
                     task_id           SERIAL         PRIMARY KEY,
                     task_titolo       varchar(200),
                     task_descrizione  varchar(200),
                     data_creazione    date           NOT NULL DEFAULT CURRENT_DATE,
                     data_scadenza     date,
                     stato             boolean        NOT NULL DEFAULT FALSE,
                     colore_background varchar(20)    NOT NULL DEFAULT '#FFFFFF',
                     bacheca_id        integer        NOT NULL,

                     CONSTRAINT fk_bacheca FOREIGN KEY (bacheca_id)
                         REFERENCES Bacheca(bacheca_id)
                         ON UPDATE CASCADE
                         ON DELETE CASCADE,

                     CONSTRAINT check_deadline_valida_
                         CHECK (data_scadenza >= data_creazione),

                     CONSTRAINT check_hex_format
                         CHECK (colore_background ~ '^#[0-9a-fA-F]{6}$')
);

CREATE TABLE Link(
                     link_id   SERIAL         PRIMARY KEY,
                     url       varchar(200),
                     task_id   integer        NOT NULL,

                     CONSTRAINT fk_task FOREIGN KEY (task_id)
                         REFERENCES Task(task_id)
                         ON DELETE CASCADE,

                     CONSTRAINT check_url_format
                         CHECK (url ~* '^https?://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(/.*)?$')
);

CREATE TABLE Allegato(
                         allegato_id       SERIAL        PRIMARY KEY,
                         path              varchar(200),
                         mime_type         varchar(40),
                         data_caricamento  date,
                         task_id           integer       NOT NULL,

                         CONSTRAINT fk_task FOREIGN KEY (task_id)
                             REFERENCES Task(task_id)
                             ON DELETE CASCADE,

                         CONSTRAINT check_data_caricamento_valida
                             CHECK (CURRENT_DATE >= data_caricamento)
);

CREATE TABLE ChecklistItem(
                              checklistItem_id  SERIAL        PRIMARY KEY,
                              nome              varchar(30),
                              is_completed      boolean       NOT NULL DEFAULT FALSE,
                              task_id           integer       NOT NULL,

                              CONSTRAINT fk_task FOREIGN KEY (task_id)
                                  REFERENCES Task(task_id)
                                  ON DELETE CASCADE
);

CREATE TYPE Ruolo AS ENUM ('Autore', 'Ricevente');

CREATE TYPE Permesso AS ENUM ('Proprietario', 'Lettura/Scrittura', 'Lettura');

CREATE TABLE Condivisione(
                             ruolo     Ruolo      NOT NULL,
                             permesso  Permesso   NOT NULL,
                             utente_id integer    NOT NULL,
                             task_id   integer    NOT NULL,
                             CONSTRAINT pk_condivisione PRIMARY KEY (utente_id, task_id),

                             CONSTRAINT fk_utente FOREIGN KEY (utente_id)
                                 REFERENCES Utente(utente_id)
                                 ON UPDATE CASCADE
                                 ON DELETE CASCADE,

                             CONSTRAINT fk_task FOREIGN KEY (task_id)
                                 REFERENCES Task(task_id)
                                 ON UPDATE CASCADE
                                 ON DELETE CASCADE
);

-- Crea le 3 bacheche di default per ogni nuovo utente
CREATE OR REPLACE FUNCTION crea_bacheche_default()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Bacheca (bacheca_titolo, bacheca_descrizione, utente_id)
    VALUES
       ('Università', NULL, NEW.utente_id),
       ('Lavoro', NULL, NEW.utente_id),
       ('Tempo Libero', NULL, NEW.utente_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_crea_bacheche
    AFTER INSERT ON Utente
    FOR EACH ROW
EXECUTE FUNCTION crea_bacheche_default();

-- funzione per settare il task completato se la checklist è tutta spuntata
CREATE OR REPLACE FUNCTION controlla_completamento_task()
    RETURNS TRIGGER AS $$
DECLARE
    totale_item INTEGER;
    item_completati INTEGER;
BEGIN
    SELECT COUNT(*) INTO totale_item FROM ChecklistItem WHERE task_id = NEW.task_id;

    SELECT COUNT(*) INTO item_completati
    FROM ChecklistItem
    WHERE task_id = NEW.task_id AND is_completed = TRUE;

    -- Se il numero di item totali e quello degli item completati combaciano, il task è completato
    IF totale_item > 0 AND totale_item = item_completati THEN
       UPDATE Task SET stato = TRUE WHERE task_id = NEW.task_id;
    ELSE
       -- se tolgo la spunta torna a false
       UPDATE Task SET stato = FALSE WHERE task_id = NEW.task_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_checklist_completamento
    AFTER INSERT OR UPDATE OF is_completed ON ChecklistItem
    FOR EACH ROW
EXECUTE FUNCTION controlla_completamento_task();

-- Impedisce di condividere un task con il proprietario della bacheca in cui si trova (se ruolo = Ricevente)
CREATE OR REPLACE FUNCTION previeni_autocondivisione()
    RETURNS TRIGGER AS $$
DECLARE
    autore_id INTEGER;
BEGIN
    -- Trova chi è il proprietario della bacheca in cui sta il task
    SELECT b.utente_id INTO autore_id
    FROM Task t
             JOIN Bacheca b ON t.bacheca_id = b.bacheca_id
    WHERE t.task_id = NEW.task_id;

    -- Se l'utente è il proprietario, bloccalo solo se si tenta di inserirlo come 'Ricevente'
    IF NEW.utente_id = autore_id AND NEW.ruolo = 'Ricevente' THEN
        RAISE EXCEPTION 'Operazione non valida: non è possibile condividere un task con il suo stesso proprietario.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_previeni_autocondivisione
    BEFORE INSERT OR UPDATE ON Condivisione
    FOR EACH ROW
EXECUTE FUNCTION previeni_autocondivisione();

-- Restituisce i task in scadenza entro una data specificata (o solo oggi se non specificata)
CREATE OR REPLACE FUNCTION task_in_scadenza(
-- p_utente_id: utente di cui cercare i task
    p_utente_id INTEGER,
-- p_fino_a: data limite (default = oggi)
    p_fino_a    DATE DEFAULT CURRENT_DATE
)
    RETURNS TABLE (
    task_id  INTEGER,
    task_titolo  VARCHAR(200),
    data_scadenza  DATE,
    bacheca_titolo  TitoloBacheca,
    stato  BOOLEAN
               ) AS $$
BEGIN
    RETURN QUERY
       SELECT
          t.task_id,
          t.task_titolo,
          t.data_scadenza,
          b.bacheca_titolo,
          t.stato
       FROM Task t
              JOIN Bacheca b ON t.bacheca_id = b.bacheca_id
       WHERE b.utente_id = p_utente_id
        and t.data_scadenza <= p_fino_a
        and t.data_scadenza IS NOT NULL
       ORDER BY t.data_scadenza;
END;
$$ LANGUAGE plpgsql;

-- Ricerca task per titolo (anche incompleto) appartenenti a un utente specifico
CREATE OR REPLACE FUNCTION cerca_task_per_titolo(
--  p_utente_id: utente di cui cercare i task
    p_utente_id INTEGER,
--  p_keyword: stringa da cercare nel titolo
    p_keyword   VARCHAR
)
    RETURNS TABLE (
    task_id  INTEGER,
    task_titolo  VARCHAR(200),
    data_scadenza  DATE,
    bacheca_titolo  TitoloBacheca,
    stato  BOOLEAN
               ) AS $$
BEGIN
    RETURN QUERY
       SELECT
          t.task_id,
          t.task_titolo,
          t.data_scadenza,
          b.bacheca_titolo,
          t.stato
       FROM Task t
              join Bacheca b ON t.bacheca_id = b.bacheca_id
       WHERE b.utente_id = p_utente_id
       -- ILIKE utilizzato per rendere la ricerca case-insensitive
        and t.task_titolo ILIKE '%' || p_keyword || '%'
       order by b.bacheca_titolo, t.task_titolo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_proprietario_unico()
    RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.permesso = 'Proprietario' AND EXISTS (
       SELECT 1
       FROM Condivisione
       WHERE task_id = NEW.task_id
        AND permesso = 'Proprietario'
        AND utente_id != NEW.utente_id
    )) THEN
       RAISE EXCEPTION 'ERRORE: La task di ID % ha già un proprietario assegnato!', NEW.task_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_proprietario_unico
    BEFORE INSERT OR UPDATE ON Condivisione
    FOR EACH ROW
EXECUTE FUNCTION check_proprietario_unico();

CREATE OR REPLACE FUNCTION check_limite_bacheche()
    RETURNS TRIGGER AS $$
DECLARE
    conteggio_tipo INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO conteggio_tipo
    FROM Bacheca
    WHERE utente_id = NEW.utente_id
     AND bacheca_titolo = NEW.bacheca_titolo;

    IF conteggio_tipo >= 1 THEN
       RAISE EXCEPTION 'ERRORE: L''utente di ID % possiede già una bacheca di tipo "%"! Massimo consentito: 1 per tipo di Bacheca.',
          NEW.utente_id, NEW.bacheca_titolo;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_limite_bacheche
    BEFORE INSERT ON Bacheca
    FOR EACH ROW
EXECUTE FUNCTION check_limite_bacheche();

-- verifica se il permesso impostato per quel determinato utente
CREATE OR REPLACE FUNCTION verifica_permesso(
    p_utente_id       INTEGER,
    p_task_id         INTEGER,
    p_permesso_minimo Permesso
) RETURNS BOOLEAN AS $$
DECLARE
    permesso_utente Permesso;
BEGIN
    SELECT permesso INTO permesso_utente
    FROM Condivisione
    WHERE utente_id = p_utente_id AND task_id = p_task_id;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF p_permesso_minimo = 'Lettura' THEN
        RETURN TRUE;
    ELSIF p_permesso_minimo = 'Lettura/Scrittura' THEN
        RETURN permesso_utente IN ('Proprietario', 'Lettura/Scrittura');
    ELSIF p_permesso_minimo = 'Proprietario' THEN
        RETURN permesso_utente = 'Proprietario';
    END IF;

    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- registra un nuovo utente
CREATE OR REPLACE PROCEDURE registra_utente(
    p_username     VARCHAR(30),
    p_email        VARCHAR(30),
    p_nome_completo VARCHAR(30),
    p_password     VARCHAR(20)
) AS $$
BEGIN
    INSERT INTO Utente (username, email, nome_completo, password)
    VALUES (p_username, p_email, p_nome_completo, p_password);
END;
$$ LANGUAGE plpgsql;

-- Crea un nuovo task nella bacheca specificata
-- identificata tramite utente_id e titolo
CREATE OR REPLACE PROCEDURE crea_task(
    p_utente_id        INTEGER,
    p_bacheca_titolo   TitoloBacheca,
    p_task_titolo      VARCHAR(200),
    p_task_descrizione VARCHAR(200) DEFAULT NULL,
    p_data_scadenza    DATE         DEFAULT NULL,
    p_colore_background VARCHAR(20) DEFAULT '#FFFFFF'
) AS $$
DECLARE
    v_bacheca_id INTEGER;
    v_task_id    INTEGER;
BEGIN
    -- Recupera la bacheca dell'utente con il titolo specificato
    SELECT bacheca_id INTO v_bacheca_id
    FROM Bacheca
    WHERE utente_id = p_utente_id AND bacheca_titolo = p_bacheca_titolo;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Bacheca "%" non trovata per l''utente %.',
            p_bacheca_titolo, p_utente_id;
    END IF;

    -- Inserisce il task e recupera l'ID generato
    INSERT INTO Task (task_titolo, task_descrizione, data_scadenza,
                      colore_background, bacheca_id)
    VALUES (p_task_titolo, p_task_descrizione, p_data_scadenza,
            p_colore_background, v_bacheca_id)
    RETURNING task_id INTO v_task_id;

-- Inserisce automaticamente il creatore come Proprietario in Condivisione
    INSERT INTO Condivisione (ruolo, permesso, utente_id, task_id)
    VALUES ('Autore', 'Proprietario', p_utente_id, v_task_id);
END;
$$ LANGUAGE plpgsql;

-- Sposta un task in un'altra bacheca
-- verificando che la bacheca di destinazione
-- sia dello stesso utente proprietario
CREATE OR REPLACE PROCEDURE sposta_task(
    p_utente_id      INTEGER,
    p_task_id        INTEGER,
    p_bacheca_titolo TitoloBacheca
) AS $$
DECLARE
    v_bacheca_id INTEGER;
BEGIN
    IF NOT verifica_permesso(p_utente_id, p_task_id, 'Proprietario') THEN
        RAISE EXCEPTION 'Permesso insufficiente: solo il proprietario può spostare il task.';
    END IF;

    -- Recupera la bacheca di destinazione del proprietario
    SELECT bacheca_id INTO v_bacheca_id
    FROM Bacheca
    WHERE utente_id = p_utente_id AND bacheca_titolo = p_bacheca_titolo;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Bacheca "%" non trovata per l''utente %.',
            p_bacheca_titolo, p_utente_id;
    END IF;

    UPDATE Task SET bacheca_id = v_bacheca_id WHERE task_id = p_task_id;
END;
$$ LANGUAGE plpgsql;

-- Elimina un task
-- Le CASCADE eliminano in automatico:
-- Link, Allegato, ChecklistItem e Condivisione
CREATE OR REPLACE PROCEDURE elimina_task(
    p_utente_id INTEGER,
    p_task_id   INTEGER
) AS $$
BEGIN
    IF NOT verifica_permesso(p_utente_id, p_task_id, 'Proprietario') THEN
        RAISE EXCEPTION 'Permesso insufficiente: solo il proprietario può eliminare il task.';
    END IF;

    DELETE FROM Task WHERE task_id = p_task_id;
END;
$$ LANGUAGE plpgsql;

-- Cambia manualmente lo stato di un task
-- check del permesso dell'utente
-- richiede permesso -> Lettura/Scrittura
CREATE OR REPLACE PROCEDURE cambia_stato_task(
    p_utente_id INTEGER,
    p_task_id   INTEGER,
    p_stato     BOOLEAN
) AS $$
BEGIN
    IF NOT verifica_permesso(p_utente_id, p_task_id, 'Lettura/Scrittura') THEN
        RAISE EXCEPTION 'Permesso insufficiente per modificare lo stato del task.';
    END IF;

    UPDATE Task SET stato = p_stato WHERE task_id = p_task_id;
END;
$$ LANGUAGE plpgsql;

-- Aggiunge una condivisione su un task
-- richiede permesso -> proprietario
CREATE OR REPLACE PROCEDURE aggiungi_condivisione(
    p_proprietario_id INTEGER,
    p_task_id         INTEGER,
    p_utente_id       INTEGER,
    p_permesso        Permesso
) AS $$
BEGIN
    IF NOT verifica_permesso(p_proprietario_id, p_task_id, 'Proprietario') THEN
        RAISE EXCEPTION 'Permesso insufficiente: solo il proprietario può aggiungere condivisioni.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Utente WHERE utente_id = p_utente_id) THEN
        RAISE EXCEPTION 'Utente % non trovato.', p_utente_id;
    END IF;

    INSERT INTO Condivisione (ruolo, permesso, utente_id, task_id)
    VALUES ('Ricevente', p_permesso, p_utente_id, p_task_id);
END;
$$ LANGUAGE plpgsql;

-- Rimuove una condivisione da un task
-- richiede permesso -> proprietario
CREATE OR REPLACE PROCEDURE rimuovi_condivisione(
    p_proprietario_id INTEGER,
    p_task_id         INTEGER,
    p_utente_id       INTEGER
) AS $$
BEGIN
    IF NOT verifica_permesso(p_proprietario_id, p_task_id, 'Proprietario') THEN
        RAISE EXCEPTION 'Permesso insufficiente: solo il proprietario può rimuovere condivisioni.';
    END IF;

    IF p_utente_id = p_proprietario_id THEN
        RAISE EXCEPTION 'Non è possibile rimuovere il proprietario dalla condivisione.';
    END IF;

    DELETE FROM Condivisione
    WHERE task_id = p_task_id AND utente_id = p_utente_id;
END;
$$ LANGUAGE plpgsql;

-- Restituisce tutti i task visibili a un utente
-- in una bacheca specifica (propri e condivisi)
CREATE OR REPLACE FUNCTION vedi_task_bacheca(
    p_utente_id      INTEGER,
    p_bacheca_titolo TitoloBacheca
)
    RETURNS TABLE (
                      task_id           INTEGER,
                      task_titolo       VARCHAR(200),
                      task_descrizione  VARCHAR(200),
                      data_scadenza     DATE,
                      stato             BOOLEAN,
                      colore_background VARCHAR(20),
                      permesso          Permesso
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            t.task_id,
            t.task_titolo,
            t.task_descrizione,
            t.data_scadenza,
            t.stato,
            t.colore_background,
            c.permesso
        FROM Task t
                 JOIN Bacheca b  ON t.bacheca_id = b.bacheca_id
                 JOIN Condivisione c ON t.task_id = c.task_id
        WHERE c.utente_id = p_utente_id
          AND b.bacheca_titolo = p_bacheca_titolo
        ORDER BY t.data_scadenza NULLS LAST;
END;
$$ LANGUAGE plpgsql;