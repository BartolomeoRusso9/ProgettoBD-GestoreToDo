# Gestore ToDo - Progetto Basi di Dati
![Type](https://img.shields.io/badge/type-University%20Project-orange)

**Database Relazionale in PostgreSQL per la gestione di task personali e condivise.**

Progetto universitario di gruppo sviluppato per il corso di Basi di Dati CdL Triennale in Informatica — Università degli Studi di Napoli Federico II. L'obiettivo principale è la progettazione concettuale, logica e fisica di un sistema informativo, composto da una base di dati relazionale, per supportare la gestione delle attività (ToDo), ispirato al software Trello.

L'intero strato di persistenza e le logiche di automazione dei dati sono implementati in PostgreSQL.

## Funzionalità principali e Modellazione dei Dati

* **Gestione Utenti e credenziali**
    * Registrazione degli utenti con credenziali univoche.
    * Verifica del formato dell'indirizzo email e regole di sicurezza per le password.
* **Organizzazione in Bacheche**
    * Strutturazione delle task in tre bacheche predefinite (Università, Lavoro e Tempo Libero), all'interno delle quali i ToDo sono ordinati secondo un ordine modificabile dall'utente.
    * Rigoroso limite di una bacheca per ambito assegnata a ciascun utente.
* **Struttura ToDo**
    * Ogni task prevede la memorizzazione di informazioni come titolo, data di scadenza, URL, descrizione, immagine e un colore di sfondo mostrato nell'interfaccia. È possibile impostare la task come completata oppure non completata.
* **Condivisione Multi-Utente**
    * Implementazione di logiche per cui un ToDo può contenere una lista di altri utenti con cui è condiviso; la task comparirà nelle rispettive bacheche di tutti gli utenti coinvolti. L'autore può gestire (aggiungere o eliminare) queste condivisioni.
* **Automazioni e Check-list**
    * All'interno del ToDo è possibile mantenere una CheckList di sotto-attività. Grazie alla logica attiva implementata nel DB (Trigger/Funzioni), quando tutte le attività della CheckList sono completate, il ToDo viene automaticamente settato come completato.
* **Interrogazioni Ottimizzate**
    * Il database è progettato per fornire elenchi di ToDo in scadenza odierna o entro un giorno specificato, consentire la ricerca per nome o titolo e identificare le task scadute per evidenziarne il nome in rosso.

## Fasi del Progetto e Documentazione

La documentazione del progetto segue il ciclo di vita standard della progettazione di basi di dati:

1. **Progettazione Concettuale:** Realizzazione del Class Diagram UML, successiva ristrutturazione del diagramma e analisi delle chiavi, delle ridondanze e degli attributi.
2. **Progettazione Logica:** Traduzione nel relativo schema logico relazionale, con evidenza delle chiavi primarie (PK) e chiavi esterne (FK).
3. **Progettazione Fisica (SQL):** Stesura del codice DDL per la creazione delle tabelle e implementazione di vincoli, procedure, funzioni e trigger.

## Dettagli tecnici
* **DBMS:** PostgreSQL
* **Modellazione:** Diagrammi delle classi UML per il design concettuale.
* **Costrutti SQL Avanzati:**
    * Vincoli `CHECK` per formati email (Regex), URL, stringhe esadecimali per i colori e validità delle date.
    * Tipi `ENUM` per limitare i domini di ruoli, permessi e titoli delle bacheche.
    * Vincoli `UNIQUE` per evitare duplicazioni.
* **Politiche di Integrità Referenziale:** Utilizzo estensivo di `ON DELETE CASCADE` e `ON UPDATE CASCADE` sulle chiavi esterne per la pulizia automatica delle dipendenze.

## Struttura della Repository e Documentazione
* [`schema.sql`](./schema.sql): Script DDL per la definizione dello schema relazionale, la creazione delle tabelle, tipi ENUM, vincoli, funzioni e trigger.
* [`data.sql`](./data.sql): Script DML per il popolamento del database con una serie di dati fittizi utili per testare le query e le automazioni.
* [`BDD_Documentazione.pdf`](./Documentazione/BDD_Documentazione.pdf): Documentazione accademica completa in italiano (circa 27 pagine) contenente il Class Diagram UML, l'analisi delle scelte progettuali, lo schema logico, i dizionari dei dati e l'intera progettazione fisica (codice SQL dei vincoli e trigger)

## Contesto Accademico
* **Corso:** Basi di Dati
* **Corso di Laurea:** Triennale in Informatica
* **Università:** Università degli Studi di Napoli Federico II
* **Tipologia:** Progetto di gruppo

## Autori
* **Gabriella Scaraglia — N86005338**
* **Bartolomeo Russo — N86005210**
* **Sabrina Oliva — N86004167**

Ogni membro del team ha contribuito a vari aspetti della progettazione concettuale, dell'implementazione logica e dello sviluppo del codice SQL.
