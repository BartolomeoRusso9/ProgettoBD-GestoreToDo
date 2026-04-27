-- Inserimento dei dati all'interno della tabella UTENTE
-- Ad ogni utente verrà assegnato un utente_id generato partendo da 1 (admin avrà 1, pluto avrà 2...)
INSERT INTO Utente (username, email, nome_completo, password) VALUES
                                                                  ('admin', 'admin@email.it', 'Admin User', 'adminpass'),
                                                                  ('pluto', 'pluto@email.it', 'Pluto User', 'plutopass'),
                                                                  ('pippo', 'pippo@email.it', 'Pippo User', 'pippopass'),
                                                                  ('mario', 'mario@email.it', 'Mario Rossi', '123456789'),
                                                                  ('gennaro', 'gennaro@email.it', 'Gennaro Esposito', '1234pass');

-- Inserimento dei dati all'interno della tabella BACHECA
-- Usiamo gli utente_id generati sopra (1, 2, 3, 4, 5) per fare i collegamenti
INSERT INTO Bacheca (bacheca_titolo, bacheca_descrizione, utente_id) VALUES
                                                                         ('Università', 'Bacheca universitaria di admin', 1),
                                                                         ('Lavoro', 'Bacheca lavorativa di admin', 1),
                                                                         ('Tempo Libero', 'Bacheca tempo libero di admin', 1),
                                                                         ('Università', 'Bacheca universitaria di pluto', 2),
                                                                         ('Lavoro', 'Bacheca lavorativa di pluto', 2),
                                                                         ('Tempo Libero', 'Bacheca tempo libero di pluto', 2);

-- Inserimento dei dati all'interno della tabella TASK
-- Usiamo i bacheca_id generati nel passaggio precedente
INSERT INTO Task (bacheca_id, task_titolo, task_descrizione, data_scadenza, stato, colore_background) VALUES
                                                                                                          (1, 'Studiare SQL', 'Ripassare JOIN e trigger', '2026-06-25', FALSE, '#66FF33'),
                                                                                                          (2, 'Completare progetto', 'Finire progetto per lavoro', '2026-07-01', FALSE, '#00CCCC'),
                                                                                                          (3, 'Prenotare vacanza', 'Controllare voli e hotel', '2026-07-10', TRUE, '#23CCFF'),
                                                                                                          (1, 'Tesi triennale', 'Scrivere introduzione e metodi', '2026-07-15', FALSE, '#C0C0C0');

-- Inserimento dei dati all'interno della tabella LINK
-- Li colleghiamo agli ID dei task appena creati (1, 2, 3, 4)
INSERT INTO Link (task_id, url) VALUES
                                    (1, 'http://moodle.univ.it/sql'),
                                    (3, 'https://www.ryanair.com');

-- Inserimento dei dati all'interno della tabella ALLEGATO
-- Associazione dei file allegati ai relativi task (es. Task 2 'Completare progetto' e Task 4 'Tesi triennale')
-- Attenzione: il path è fittizio, simula a scopo dimostrativo il percorso dove il file verrebbe salvato nel server
INSERT INTO Allegato (task_id, path, mime_type, data_caricamento) VALUES
                                                                      (2, '/uploads/documento_requisiti.pdf', 'application/pdf', '2026-04-20'),
                                                                      (4, '/uploads/bozza_capitolo1.docx', 'application/msword', '2026-04-22'),
                                                                      (4, '/images/grafico_risultati.png', 'image/png', '2026-04-23');

-- Inserimento dei dati all'interno della tabella CHECKLISTITEM
-- Inserimento dei singoli elementi (item) all'interno delle checklist associate ai task 1 e 3 (es. Task 1 "Studiare SQL" e Task 3 "Prenotare vacanza")
INSERT INTO ChecklistItem (task_id, nome, is_completed) VALUES
                                                            (1, 'Ripassare le JOIN', TRUE),
                                                            (1, 'Esercizi sui Trigger', FALSE),
                                                            (3, 'Cercare i voli', TRUE),
                                                            (3, 'Prenotare l''hotel', FALSE);

-- Inserimento dei dati all'interno della tabella CONDIVISIONE
-- Associazione tra l'utente (es. admin = 1) e i task
INSERT INTO Condivisione (utente_id, task_id, ruolo, permesso) VALUES
                                                                   (1, 4, 'Ricevente', 'Lettura/Scrittura'),
                                                                   (2, 1, 'Ricevente', 'Lettura'),
                                                                   (3, 2, 'Autore', 'Proprietario');
