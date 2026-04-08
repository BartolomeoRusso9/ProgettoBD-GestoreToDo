# Gestore ToDo - Progetto Basi di Dati

**Database Relazionale in PostgreSQL per la gestione di task personali e condivisi.**

Questo progetto è stato sviluppato per l'esame di Basi di Dati (Corso di Laurea in Informatica) presso l'Università degli Studi di Napoli Federico II. L'obiettivo principale è la progettazione concettuale, logica e fisica di un sistema informativo, composto da una base di dati relazionale, per supportare la gestione delle attività (ToDo), ispirato al software Trello. 

L'intero strato di persistenza e le logiche di automazione dei dati sono implementati in PostgreSQL.

## Funzionalità e Modellazione dei Dati

* **Gestione Utenti:** Archiviazione delle credenziali con l'utente che entra nel sistema specificando login e password, le quali devono essere univoche.
* **Organizzazione in Bacheche:** Strutturazione dei task in tre bacheche predefinite (Università, Lavoro e Tempo Libero), all'interno delle quali i ToDo sono ordinati secondo un ordine modificabile dall'utente.
* **Struttura ToDo:** Ogni task prevede la memorizzazione di informazioni come titolo, data di scadenza, URL, descrizione, immagine e un colore di sfondo mostrato nell'interfaccia. È possibile impostare il task come completato oppure non completato.
* **Condivisione Multi-Utente:** Implementazione di logiche per cui un ToDo può contenere una lista di altri utenti con cui è condiviso; il task comparirà nelle rispettive bacheche di tutti gli utenti coinvolti. L'autore può gestire (aggiungere o eliminare) queste condivisioni.
* **Automazioni e Check-list:** All'interno del ToDo è possibile mantenere una CheckList di sotto-attività. Grazie alla logica attiva implementata nel DB (Trigger/Funzioni), quando tutte le attività della CheckList sono completate, il ToDo viene automaticamente settato come completato.
* **Interrogazioni Ottimizzate:** Il database è progettato per fornire elenchi di ToDo in scadenza odierna o entro un giorno specificato, consentire la ricerca per nome o titolo e identificare i task scaduti per evidenziarne il nome in rosso.

## Fasi del Progetto e Documentazione

La documentazione del progetto segue il ciclo di vita standard della progettazione di basi di dati:

1. **Progettazione Concettuale:** Realizzazione del Class Diagram UML, successiva ristrutturazione del diagramma e analisi delle chiavi, delle ridondanze e degli attributi.
2. **Progettazione Logica:** Traduzione nel relativo schema logico relazionale, con evidenza delle chiavi primarie (PK) e chiavi esterne (FK).
3. **Progettazione Fisica (SQL):** Stesura del codice DDL per la creazione delle tabelle e implementazione di vincoli, procedure, funzioni e trigger.

## Tecnologie Utilizzate
* **RDBMS:** PostgreSQL
* **Progettazione:** UML (Class Diagram Relazionale)
* **Linguaggio:** SQL / PL/pgSQL
