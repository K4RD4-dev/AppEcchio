# Piano funzionale e tecnico: Area Gamification

## 1) Obiettivo
Creare una struttura gamification che permetta agli utenti di:
- guadagnare punti tramite attività (prenotazioni, eventi, partecipazione);
- accumulare punti in un saldo personale nell'app;
- sbloccare sconti al raggiungimento di soglie punti;
- utilizzare gli sconti nei locali convenzionati presenti in app;
- validare la presenza agli eventi tramite QR code e scansione da parte di un incaricato.

## 2) User story principali
1. **Utente**: partecipo a un evento e voglio ottenere automaticamente i punti nel mio saldo.
2. **Utente**: vedo saldo punti, storico movimenti e prossima soglia sconto.
3. **Utente**: raggiungo una soglia e ricevo un voucher sconto spendibile nei locali aderenti.
4. **Incaricato evento**: scansiono QR utente per verificare presenza e autorizzare accredito punti.
5. **Locale**: verifico validità voucher sconto e lo riscatto una sola volta.
6. **Admin**: definisco regole punti, soglie, campagne temporanee e prevenzione frodi.

## 3) Modello punti e regole business

### 3.1 Fonti di guadagno punti
- **Prenotazione confermata**: +X punti.
- **Partecipazione evento verificata**: +Y punti.
- **Attività speciali/campagne** (es. settimana del turismo): moltiplicatori o bonus fissi.

### 3.2 Regole fondamentali
- I punti si accreditano con eventi transazionali tracciati (ledger), non con aggiornamento “diretto” del saldo.
- Ogni accredito deve essere **idempotente** (stesso evento non genera doppio accredito).
- Ogni movimento ha causale, timestamp, riferimento entità (evento/prenotazione), stato (pending/confirmed/reversed).
- Possibilità di storno in caso di annullamento evento o errore di validazione.

### 3.3 Soglie e sconti
- Configurazione da backoffice di soglie (esempio):
  - 500 punti → 5% sconto
  - 1000 punti → 10% sconto
- Lo sconto è emesso come **voucher digitale** con:
  - codice univoco;
  - validità temporale;
  - locale/i abilitati;
  - regole di uso (singolo utilizzo, eventuale spesa minima).

## 4) Flusso QR per verifica presenza

### 4.1 Principio
- Ogni utente genera un QR dinamico (token breve durata) nella schermata “Il mio QR”.
- L'incaricato usa app staff per scansionare.
- Backend valida token, verifica iscrizione all'evento e ruolo dello staff.
- Se valido: registra check-in + genera evento di accredito punti.

### 4.2 Anti-frode minima
- Token QR firmato e con scadenza breve (es. 60–120 secondi).
- Binding evento-sessione (QR usabile solo nell'evento corretto).
- Prevenzione doppio check-in (vincolo univoco utente+evento).
- Audit log scansioni (chi ha scansionato, quando, esito).

## 5) Architettura logica (moduli)
1. **Gamification Engine**
   - calcolo punti;
   - applicazione regole;
   - idempotenza e storni.
2. **Wallet punti**
   - saldo corrente;
   - ledger movimenti;
   - storico utente.
3. **Voucher & Rewards**
   - emissione sconti a soglia;
   - validazione e redemption presso locali.
4. **Check-in Service (QR)**
   - generazione token QR;
   - verifica scansione;
   - creazione evento presenza.
5. **Admin Console**
   - configurazione regole;
   - monitoraggio KPI;
   - gestione anomalie/frodi.

## 6) Data model (MVP)
- `users`
- `events`
- `bookings`
- `point_wallets` (1:1 con user)
- `point_ledger_entries`
  - `id`, `user_id`, `source_type`, `source_id`, `points`, `status`, `idempotency_key`, `created_at`
- `reward_tiers`
  - `id`, `threshold_points`, `reward_type`, `reward_value`, `active`
- `reward_vouchers`
  - `id`, `user_id`, `tier_id`, `code`, `status`, `expires_at`, `redeemed_at`, `merchant_id`
- `event_checkins`
  - `id`, `event_id`, `user_id`, `staff_user_id`, `checked_in_at`, `scan_result`

## 7) API principali (bozza)
- `POST /v1/checkins/scan` → valida QR e registra check-in.
- `GET /v1/users/me/points` → saldo + progress verso prossima soglia.
- `GET /v1/users/me/points/ledger` → storico movimenti.
- `GET /v1/users/me/vouchers` → voucher attivi/scaduti/usati.
- `POST /v1/vouchers/{code}/redeem` → riscatto voucher da locale abilitato.
- `POST /v1/admin/reward-tiers` / `PATCH ...` → gestione soglie.

## 8) Sicurezza, privacy e conformità
- Minimizzazione dati personali nei token QR.
- Crittografia in transito e a riposo.
- Rate limiting su endpoint scansione.
- Controlli RBAC: solo staff autorizzato può effettuare check-in.
- Conservazione audit log secondo policy privacy.

## 9) KPI da monitorare
- Utenti attivi gamification / mese.
- Numero medio punti guadagnati per utente.
- Tasso conversione punti → voucher.
- Redemption voucher per locale.
- Tentativi di frode bloccati (doppia scansione/token invalidi).

## 10) Piano di rilascio in fasi

### Fase 1 — MVP (4-6 settimane)
- Wallet punti + ledger.
- Regole base su prenotazioni e presenza evento.
- QR check-in staff con anti-doppio check-in.
- Soglie statiche e voucher base.

### Fase 2 — Hardening (2-4 settimane)
- Anti-frode avanzata (device fingerprint, anomaly detection basilare).
- Campagne punti temporanee.
- Dashboard KPI per admin e locali.

### Fase 3 — Evoluzione
- Personalizzazione reward per segmento utenti.
- Partnership territoriali multi-locale.
- Gamification social (badge, classifiche, missioni).

## 11) Backlog iniziale (epiche)
1. **EPIC-01 Wallet & Ledger**
2. **EPIC-02 QR Check-in & Presenza**
3. **EPIC-03 Reward Tiers & Voucher**
4. **EPIC-04 Merchant Redemption**
5. **EPIC-05 Admin Rules & Monitoring**
6. **EPIC-06 Security & Anti-fraud**

## 12) Criteri di accettazione MVP
- Un check-in valido produce un solo accredito punti verificabile a ledger.
- Il saldo utente riflette la somma movimenti confermati.
- Al raggiungimento soglia viene emesso voucher corretto e tracciato.
- Un voucher non può essere riscattato più di una volta.
- Operazioni tracciate in audit log con riferimenti chiari.
