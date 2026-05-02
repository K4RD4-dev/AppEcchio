# Piano funzionale e tecnico: Area Gamification

## 1) Obiettivo
Creare una struttura gamification che permetta agli utenti di:
- guadagnare **token** tramite attività che aprono opportunità economiche o campagne locali;
- accumulare **Experience / XP** in un saldo personale nell'app;
- sbloccare livelli, medaglie e sconti al raggiungimento di soglie XP;
- utilizzare gli sconti nei locali convenzionati presenti in app;
- validare la presenza agli eventi tramite QR code e scansione da parte di un incaricato.

## 2) User story principali
1. **Utente**: partecipo a un evento e voglio ottenere automaticamente token e XP.
2. **Utente**: vedo saldo token, XP accumulati, storico movimenti e prossima soglia premio.
3. **Utente**: raggiungo una soglia XP e ricevo un voucher sconto spendibile nei locali aderenti.
4. **Incaricato evento**: scansiono QR utente per verificare presenza e autorizzare accredito token/XP.
5. **Locale**: verifico validità voucher sconto e lo riscatto una sola volta.
6. **Admin**: definisco regole token/XP, soglie, campagne temporanee e prevenzione frodi.

## 3) Modello token/XP e regole business

### 3.1 Fonti token e XP
- **Token**: maturano come credito/opportunità economica nel wallet e possono alimentare campagne, convenzioni o meccaniche di guadagno locale.
- **Experience / XP**: maturano come progressione reputazionale e sbloccano livelli, medaglie e premi.
- **Prenotazione confermata**: +X XP e una quota token configurabile.
- **Partecipazione evento verificata**: +Y XP e una quota token configurabile.
- **Attività speciali/campagne** (es. settimana del turismo): moltiplicatori o bonus fissi separati per token e XP.

### 3.2 Regole fondamentali
- Token e XP si accreditano con eventi transazionali tracciati (ledger), non con aggiornamento “diretto” dei saldi.
- Ogni accredito deve essere **idempotente** (stesso evento non genera doppio accredito).
- Ogni movimento ha causale, timestamp, riferimento entità (evento/prenotazione), delta token, delta XP e stato (pending/confirmed/reversed).
- Possibilità di storno in caso di annullamento evento o errore di validazione.

### 3.3 Soglie XP e premi
- Configurazione da backoffice di soglie (esempio):
  - 500 XP → 5% sconto
  - 1000 XP → 10% sconto
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
- Se valido: registra check-in + genera evento di accredito token e XP.

### 4.2 Anti-frode minima
- Token QR firmato e con scadenza breve (es. 60–120 secondi).
- Binding evento-sessione (QR usabile solo nell'evento corretto).
- Prevenzione doppio check-in (vincolo univoco utente+evento).
- Audit log scansioni (chi ha scansionato, quando, esito).

## 5) Architettura logica (moduli)
1. **Gamification Engine**
   - calcolo token e XP;
   - applicazione regole;
   - idempotenza e storni.
2. **Wallet gamification**
   - saldo token e saldo XP;
   - ledger movimenti;
   - storico utente.
3. **Voucher & Rewards**
   - emissione sconti a soglia XP;
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
- `gamification_wallets` (1:1 con user)
  - `id`, `user_id`, `token_balance`, `experience_points`, `updated_at`
- `gamification_ledger_entries`
  - `id`, `user_id`, `source_type`, `source_id`, `token_delta`, `experience_delta`, `status`, `idempotency_key`, `created_at`
- `reward_tiers`
  - `id`, `threshold_xp`, `reward_type`, `reward_value`, `active`
- `reward_vouchers`
  - `id`, `user_id`, `tier_id`, `code`, `status`, `expires_at`, `redeemed_at`, `merchant_id`
- `event_checkins`
  - `id`, `event_id`, `user_id`, `staff_user_id`, `checked_in_at`, `scan_result`

## 7) API principali (bozza)
- `POST /v1/checkins/scan` → valida QR e registra check-in.
- `GET /v1/users/me/progress` → token, XP + progress verso prossima soglia premio.
- `GET /v1/users/me/progress/ledger` → storico movimenti token/XP.
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
- Numero medio token e XP guadagnati per utente.
- Tasso conversione XP → voucher.
- Redemption voucher per locale.
- Tentativi di frode bloccati (doppia scansione/token invalidi).

## 10) Piano di rilascio in fasi

### Fase 1 — MVP (4-6 settimane)
- Wallet token/XP + ledger.
- Regole base su prenotazioni e presenza evento.
- QR check-in staff con anti-doppio check-in.
- Soglie statiche e voucher base.

### Fase 2 — Hardening (2-4 settimane)
- Anti-frode avanzata (device fingerprint, anomaly detection basilare).
- Campagne token/XP temporanee.
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
- Un check-in valido produce un solo accredito token/XP verificabile a ledger.
- I saldi utente riflettono la somma movimenti confermati.
- Al raggiungimento soglia XP viene emesso voucher corretto e tracciato.
- Un voucher non può essere riscattato più di una volta.
- Operazioni tracciate in audit log con riferimenti chiari.
