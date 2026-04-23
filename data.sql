-- Inserimento dei dati all'interno della tabella UTENTE
-- Ad ogni utente verrà assegnato un utente_id generato partendo da 1 (admin avrà 1, pluto avrà 2...)
-- INSERT INTO Utente (username, email, nomeCompleto, password) VALUES
('admin', 'admin@email.it', 'Admin User', 'adminpass'),
                                                                 ('pluto', 'pluto@email.it', 'Pluto User', 'plutopass'),
                                                                 ('pippo', 'pippo@email.it', 'Pippo User', 'pippopass'),
                                                                 ('mario', 'mario@email.it', 'Mario Rossi', '1234'),
                                                                 ('gennaro', 'gennaro@email.it', 'Gennaro Esposito', '12');

-- Inserimento dei dati all'interno della tabella BACHECA
-- Usiamo gli utente_id generati sopra (1, 2, 3, 4, 5) per fare i collegamenti
INSERT INTO Bacheca (utente_id, bacheca_titolo, bacheca_descrizione) VALUES
                                                                         (1, 'Università', 'Bacheca universitaria di admin'),   -- ID bacheca generato: 1
                                                                         (1, 'Lavoro', 'Bacheca lavorativa di admin'),         -- ID bacheca generato: 2
                                                                         (1, 'Tempo Libero', 'Bacheca tempo libero di admin'), -- ID bacheca generato: 3
                                                                         (2, 'Università', 'Bacheca universitaria di pluto'),   -- ID bacheca generato: 4
                                                                         (2, 'Lavoro', 'Bacheca lavorativa di pluto'),         -- ID bacheca generato: 5
                                                                         (2, 'Tempo Libero', 'Bacheca tempo libero di pluto'); -- ID bacheca generato: 6

-- Inserimento dei dati all'interno della tabella TASK
-- Usiamo i bacheca_id generati nel passaggio precedente
INSERT INTO Task (bacheca_id, task_titolo, task_descrizione, deadline, stato, colore_background) VALUES
                                                                                                     (1, 'Studiare SQL', 'Ripassare JOIN e trigger', '2025-06-25', FALSE, '66FF33'),          -- ID task generato: 1
                                                                                                     (2, 'Completare progetto', 'Finire progetto per lavoro', '2025-07-01', FALSE, '00CCCC'), -- ID task generato: 2
                                                                                                     (3, 'Prenotare vacanza', 'Controllare voli e hotel', '2025-07-10', TRUE, '23CCFF'),      -- ID task generato: 3
                                                                                                     (4, 'Tesi triennale', 'Scrivere introduzione e metodi', '2025-07-15', FALSE, 'C0C0C0');  -- ID task generato: 4

-- Inserimento dei dati all'interno della tabella LINK
-- Li colleghiamo agli ID dei task appena creati (1, 2, 3, 4)
INSERT INTO Link (task_id, url) VALUES
                                    (1, 'https://moodle.univ.it/sql'),
                                    (3, 'https://www.ryanair.com');

-- Inserimento dei dati all'interno della tabella CONDIVISIONE
-- Associazione tra l'utente (es. admin = 1) e i task
INSERT INTO Condivisione (utente_id, task_id, ruolo, permesso) VALUES
                                                                   (1, 4, 'Ricevente', 'Lettura/Scrittura'),
                                                                   (2, 1, 'Ricevente', 'Lettura'),
                                                                   (3, 2, 'Autore', 'Proprietario');

-- Inserimento dei dati all'interno della tabella CHECKLISTITEM
-- Inserimento dei singoli elementi (item) all'interno delle checklist associate ai task 1 e 3 (es. Task 1 "Studiare SQL" e Task 3 "Prenotare vacanza")
INSERT INTO ChecklistItem (task_id, nome, isCompleted) VALUES
                                                           (1, 'Ripassare le JOIN', TRUE),
                                                           (1, 'Esercizi sui Trigger', FALSE),
                                                           (3, 'Cercare i voli', TRUE),
                                                           (3, 'Prenotare l''hotel', FALSE);

-- Inserimento dei dati all'interno della tabella ALLEGATO
-- Associazione dei file allegati ai relativi task (es. Task 2 'Completare progetto' e Task 4 'Tesi triennale')
-- Attenzione: il path è fittizio, simula a scopo dimostrativo il percorso dove il file verrebbe salvato nel server
INSERT INTO Allegato (task_id, path, mimeType, data_caricamento) VALUES
                                                                     (2, '/uploads/documento_requisiti.pdf', 'application/pdf', '2026-04-20'),
                                                                     (4, '/uploads/bozza_capitolo1.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '2026-04-22'),
                                                                     (4, '/images/grafico_risultati.png', 'image/png', '2026-04-23');