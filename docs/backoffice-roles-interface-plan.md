# APPecchio - Piano interfacce backoffice

## Obiettivo

Creare un backoffice unico, modulare e basato sui ruoli, capace di servire Comune, Sindaco, supervisori, uffici, esercenti, associazioni e staff evento.

Il principio guida e che ogni utente vede solo cio che puo fare: consultare, modificare, approvare, pubblicare o amministrare.

## Ruoli principali

### Amministratore piattaforma

- Gestisce utenti, ruoli e permessi.
- Configura categorie, organizzazioni, regole gamification e integrazioni.
- Consulta audit log e azioni sensibili.
- Puo intervenire su schede, eventi, voucher, segnalazioni e comunicazioni.

### Supervisore operativo

- Gestisce code operative, approvazioni, segnalazioni e anomalie.
- Approva eventi pubblici proposti da esercenti, associazioni o uffici.
- Coordina notifiche e comunicazioni operative.
- Monitora voucher, check-in e possibili abusi.

### Sindaco

- Consulta cruscotto istituzionale con KPI, criticita e priorita.
- Approva comunicazioni pubbliche sensibili quando previsto.
- Vede andamento segnalazioni, servizi, eventi e territorio.
- Ha accesso a report mensili e vista emergenza.

### Esercente

- Gestisce la propria pagina pubblica in app.
- Aggiorna descrizione, orari, contatti, servizi e foto.
- Modifica menu, listino o catalogo servizi.
- Crea offerte e promozioni.
- Valida voucher e consulta storico riscatti.
- Crea eventi pubblici, di pagina o interni al proprio staff.

### Organizzazione / associazione

- Gestisce pagina organizzazione, membri e gruppi.
- Crea eventi pubblici, assemblee, riunioni interne, turni e inviti.
- Invia comunicazioni mirate ai propri membri.
- Coordina staff e volontari.

### Responsabile ufficio

- Lavora sulle pratiche e segnalazioni della propria area.
- Aggiorna stati, note, documenti e risposte al cittadino.
- Propone comunicazioni o avvisi relativi al proprio servizio.

### Operatore / staff evento

- Usa funzioni rapide e mobili.
- Scansiona QR, valida presenze, aggiorna task assegnati.
- Vede solo eventi, incarichi o segnalazioni assegnate.

### Comunicazione / URP

- Crea news, avvisi, eventi e notifiche push.
- Gestisce bozze, target e programmazione.
- Invia in approvazione i contenuti sensibili.

### DPO / audit

- Consulta log, richieste privacy, esportazioni e consensi.
- Non entra nella gestione editoriale ordinaria.

## Moduli backoffice

### Cruscotto

Ogni ruolo ha una dashboard diversa:

- Sindaco: KPI territorio, comunicazioni da approvare, report e priorita.
- Supervisore: urgenze, segnalazioni, eventi in revisione, anomalie.
- Esercente: visite pagina, menu, voucher, offerte, eventi.
- Organizzazione: eventi, membri, RSVP, comunicazioni interne.
- Admin: utenti, ruoli, configurazioni, audit.

Il cruscotto include anche una sezione **Partecipazione eventi** con:

- RSVP rispetto alla capienza;
- check-in rispetto agli RSVP;
- posti disponibili;
- lista attesa;
- stato automatico: posti disponibili, quasi pieno, sold out, bassa partecipazione.

La vista e filtrata per ruolo: esercenti e organizzazioni vedono i propri eventi, supervisore e admin vedono tutti gli eventi, il Sindaco vede solo aggregati pubblici e istituzionali.

### Pagina organizzazione

Scheda modificabile per esercenti, associazioni ed enti:

- immagine copertina con caricamento file o URL;
- adattamento immagine: riempi area o mostra intera;
- regolazione punto focale orizzontale e verticale;
- nome;
- categoria;
- descrizione breve;
- descrizione estesa;
- indirizzo e posizione;
- telefono, email, sito e social;
- orari ordinari;
- aperture straordinarie;
- servizi disponibili;
- anteprima mobile.

Le modifiche semplici possono essere pubblicate subito. Le modifiche sensibili possono richiedere revisione.

### Foto e media

- Copertina principale.
- Galleria.
- Riordino immagini.
- Stato approvazione.
- Anteprima scheda.

### Menu, listino o catalogo

Per ristoranti e bar:

- categorie menu;
- piatti;
- descrizioni;
- prezzi;
- allergeni;
- etichette;
- disponibilita;
- foto piatto.

Per negozi, servizi o strutture:

- catalogo prodotti;
- servizi;
- prezzi o preventivo;
- disponibilita;
- note operative.

### Eventi con visibilita

Ogni evento deve avere una visibilita esplicita.

Tipi di visibilita:

- **Pubblico**: visibile a tutti, calendario e mappa se approvato.
- **Pagina organizzazione**: visibile solo nella scheda dell'attivita o organizzazione.
- **Solo membri**: visibile agli utenti collegati all'organizzazione.
- **Gruppo specifico**: direttivo, staff, volontari, dipendenti, ufficio.
- **Su invito**: visibile solo agli invitati.
- **Interno Comune**: visibile a ruoli comunali autorizzati.
- **Consiglio / Giunta**: distingue appuntamento pubblico e materiali interni.

Ogni evento conserva anche:

- organizzazione proprietaria;
- descrizione;
- destinatari;
- RSVP o prenotazione;
- canali di uscita;
- stato editoriale;
- note di revisione.

Esempi:

- Ristorante: cena degustazione pubblica.
- Ristorante: briefing staff visibile solo ai dipendenti.
- Associazione: assemblea soci visibile ai membri.
- Pro Loco: riunione direttivo visibile al gruppo direttivo.
- Comune: consiglio comunale pubblico con note preparatorie interne.
- Uffici: riunione tecnica interna.

Stati evento:

- bozza;
- in revisione;
- correzioni richieste;
- pubblicato;
- pubblicato interno;
- riservato;
- annullato;
- concluso.

Regola di approvazione:

- eventi interni, solo membri, gruppo specifico o su invito: pubblicazione immediata verso il perimetro corretto;
- eventi pubblici, calendario generale, mappa o home: revisione supervisore/URP;
- eventi istituzionali sensibili: possibile approvazione Sindaco o segreteria;
- evento Consiglio/Giunta: separare parte pubblica, allegati pubblici e note interne.

### Voucher e gamification

- Validazione voucher.
- Storico riscatti.
- Regole convenzione.
- Stato voucher.
- Anomalie e doppie validazioni.
- Ticket problema voucher.

### Segnalazioni

- Coda nuove segnalazioni.
- Priorita.
- Area competente.
- Assegnazione a ufficio o operatore.
- Stato lavorazione.
- Risposta al cittadino.
- Vista KPI per Sindaco e supervisore.

### Comunicazioni

- News.
- Avvisi.
- Notifiche push.
- Comunicazioni interne.
- Target: tutti, cittadini, turisti, organizzazione, gruppo, ruoli comunali.
- Flusso bozza, revisione, approvazione, pubblicazione.

### Membri e gruppi

Ogni organizzazione puo avere:

- proprietario;
- editor pagina;
- editor eventi;
- membro;
- staff evento;
- gruppo direttivo;
- ospite invitato.

I gruppi determinano la visibilita di eventi e comunicazioni.

Gruppi minimi:

- staff attivita;
- fornitori;
- soci;
- direttivo;
- volontari;
- staff evento;
- ufficio comunale;
- giunta;
- consiglio;
- invitati temporanei.

## Regole di pubblicazione

- Modifiche a menu, prezzi, disponibilita e orari: pubblicazione rapida.
- Eventi interni: pubblicazione immediata verso il gruppo corretto.
- Eventi pubblici in calendario generale, home o mappa: revisione supervisore/URP.
- Comunicazioni pubbliche sensibili: approvazione Sindaco o segreteria quando previsto.
- Modifiche a nome, categoria o identita dell'organizzazione: revisione amministratore.

## MVP consigliato

1. Shell backoffice con selettore ruolo e contesto.
2. Dashboard per Esercente, Organizzazione, Supervisore, Sindaco e Admin.
3. Editor pagina organizzazione con anteprima mobile.
4. Menu/listino per esercenti.
5. Eventi con visibilita.
6. Voucher e storico riscatti.
7. Segnalazioni e approvazioni supervisore.
8. Matrice permessi.

## Prototipo corrente

Il primo mockup navigabile si trova in:

- `mockup/backoffice.html`
- `mockup/backoffice.css`
- `mockup/backoffice.js`

Il prototipo e statico, usa dati demo e `localStorage` per simulare modifiche, menu, eventi e voucher.
