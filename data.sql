-- Inserimento dei dati all'interno della tabella UTENTE
-- Ad ogni utente verrà assegnato un utente_id generato partendo da 1 (admin avrà 1, pluto avrà 2...)
-- Il trigger_crea_bacheche creerà automaticamente le 3 bacheche per ogni utente inserito
INSERT INTO Utente (username, email, nome_completo, password) VALUES
    ('admin',   'admin@email.it',   'Admin User',        'adminpass'),
    ('pluto',   'pluto@email.it',   'Pluto User',        'plutopass'),
    ('pippo',   'pippo@email.it',   'Pippo User',        'pippopass'),
    ('mario',   'mario@email.it',   'Mario Rossi',       '123456789'),
    ('gennaro', 'gennaro@email.it', 'Gennaro Esposito',  '1234pass');

-- Inserimento dei dati all'interno della tabella BACHECA
-- Dato che il trigger_crea_bacheche genera automaticamente le bacheche dopo ogni INSERT in Utente, 
-- non è necessario inserirle manualmente
-- I bacheca_id risultanti saranno:
--   admin   (1): Università=1,  Lavoro=2,  Tempo Libero=3
--   pluto   (2): Università=4,  Lavoro=5,  Tempo Libero=6
--   pippo   (3): Università=7,  Lavoro=8,  Tempo Libero=9
--   mario   (4): Università=10, Lavoro=11, Tempo Libero=12
--   gennaro (5): Università=13, Lavoro=14, Tempo Libero=15

-- Inserimento dei dati all'interno della tabella TASK
-- Usiamo i bacheca_id generati automaticamente dal trigger (admin: 1=Università, 2=Lavoro, 3=Tempo Libero)
INSERT INTO Task (bacheca_id, task_titolo, task_descrizione, data_scadenza, stato, colore_background) VALUES
    (1, 'Studiare SQL',        'Ripassare JOIN e trigger',       '2026-06-25', FALSE, '#66FF33'),
    (2, 'Completare progetto', 'Finire progetto per lavoro',     '2026-07-01', FALSE, '#00CCCC'),
    (3, 'Prenotare vacanza',   'Controllare voli e hotel',       '2026-07-10', TRUE,  '#23CCFF'),
    (1, 'Tesi triennale',      'Scrivere introduzione e metodi', '2026-07-15', FALSE, '#C0C0C0');
-- Task IDs risultanti: 1, 2, 3, 4

-- Inserimento dei dati all'interno della tabella LINK
-- Li colleghiamo agli ID dei task appena creati (1, 2, 3, 4)
INSERT INTO Link (task_id, url) VALUES
    (1, 'http://moodle.univ.it/sql'),
    (3, 'https://www.ryanair.com');

-- Inserimento dei dati all'interno della tabella ALLEGATO
-- Associazione dei file allegati ai relativi task (Task 2 'Completare progetto' e Task 4 'Tesi triennale')
-- Attenzione: il path è fittizio, simula a scopo dimostrativo il percorso dove il file verrebbe salvato nel server
INSERT INTO Allegato (task_id, path, mime_type, data_caricamento) VALUES
    (2, '/uploads/documento_requisiti.pdf', 'application/pdf',    '2026-04-20'),
    (4, '/uploads/bozza_capitolo1.docx',    'application/msword', '2026-04-22'),
    (4, '/images/grafico_risultati.png',    'image/png',          '2026-04-23');

-- Inserimento dei dati all'interno della tabella CHECKLISTITEM
-- Inserimento dei singoli elementi (item) all'interno delle checklist associate ai task 1 e 3
-- (es. Task 1 "Studiare SQL" e Task 3 "Prenotare vacanza")
-- Il trigger_checklist_completamento aggiornerà automaticamente Task.stato se tutti gli item sono spuntati
INSERT INTO ChecklistItem (task_id, nome, is_completed) VALUES
    (1, 'Ripassare le JOIN',    TRUE),
    (1, 'Esercizi sui Trigger', FALSE),
    (3, 'Cercare i voli',       TRUE),
    (3, 'Prenotare l''hotel',   FALSE);

-- Inserimento dei dati all'interno della tabella CONDIVISIONE
-- Ogni task deve avere esattamente un utente con permesso Proprietario (vincolo trigger_proprietario_unico).
-- Tutte le task create sopra appartengono ad admin (bacheca_id 1, 2, 3 → utente_id 1).
-- Prima si inserisce admin come Autore/Proprietario su ogni sua task, poi le condivisioni con altri utenti.
INSERT INTO Condivisione (utente_id, task_id, ruolo, permesso) VALUES
    (1, 1, 'Autore', 'Proprietario'),   -- admin è proprietario di "Studiare SQL"
    (1, 2, 'Autore', 'Proprietario'),   -- admin è proprietario di "Completare progetto"
    (1, 3, 'Autore', 'Proprietario'),   -- admin è proprietario di "Prenotare vacanza"
    (1, 4, 'Autore', 'Proprietario');   -- admin è proprietario di "Tesi triennale"

-- Condivisioni con altri utenti
INSERT INTO Condivisione (utente_id, task_id, ruolo, permesso) VALUES
    (2, 1, 'Ricevente', 'Lettura'),           -- pluto può leggere "Studiare SQL"
    (3, 2, 'Ricevente', 'Lettura/Scrittura'); -- pippo può modificare "Completare progetto"
