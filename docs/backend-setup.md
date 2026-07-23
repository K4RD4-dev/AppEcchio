# Backend setup (Supabase) — Slice 1 (auth + profili) · Slice 2 (gamification)

Questa guida attiva il backend reale. Finché le variabili non sono impostate,
l'app resta in **modalità demo** (dati in memoria) e continua a funzionare come
il mockup pubblico.

## 1. Crea il progetto Supabase

1. Vai su https://supabase.com → **New project** (piano Free).
2. Scegli una password per il database e una region europea (es. `eu-central`).
3. A creazione avvenuta, apri **Project Settings → API** e annota:
   - **Project URL** → `SUPABASE_URL`
   - **anon public key** → `SUPABASE_ANON_KEY` (è pubblica: può stare nel client)

## 2. Crea lo schema

1. Apri **SQL Editor** nel dashboard.
2. Incolla il contenuto di [`supabase/migrations/0001_init.sql`](../supabase/migrations/0001_init.sql) ed esegui.
   Crea: `profiles` (con trigger di creazione automatica al signup), gamification,
   voucher, eventi, prenotazioni, organizzazioni, esercenti, sentieri — tutte con
   Row Level Security attiva.

## 3. Configura l'autenticazione

In **Authentication → Providers → Email**:
- Per provare velocemente, **disattiva "Confirm email"** (così il primo accesso
  crea subito l'account senza dover cliccare un link). Riattivalo prima del
  lancio pubblico.

## 4. Avvia l'app col backend

### In locale (Mac)
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

### Build web / deploy (GitHub Pages)
Le chiavi vanno passate al workflow come **GitHub Secrets**:
1. Repo → **Settings → Secrets and variables → Actions → New repository secret**
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
2. Il workflow le inietta nella build (vedi `.github/workflows/deploy-web.yml`).

## Come si comporta l'app

- **Senza** variabili → login demo, nessuna connessione a Supabase.
- **Con** variabili → login/registrazione reali; il profilo (nome, ruolo,
  impostazioni) viene letto da `profiles`. Al primo accesso l'account viene
  creato con il ruolo selezionato nel menu a tendina.

## Slice 2 — gamification persistente (già implementata)

Dopo il login backend, l'app **idrata** XP, token, ledger e voucher dell'utente
dalle tabelle `gamification_state`, `reward_ledger`, `vouchers`. Da quel momento:

- ogni guadagno di XP/token (check-in evento, prenotazione) aggiorna
  `gamification_state` e aggiunge una riga in `reward_ledger`;
- i voucher sbloccati automaticamente vengono salvati in `vouchers`;
- l'uso di un voucher aggiorna il suo stato a `usato`.

Al **primo accesso** di un utente reale la gamification parte da **0 XP / 0 token**
(i valori 360/36 sono solo dati demo). Riaprendo l'app o accedendo da un altro
dispositivo, i progressi vengono ricaricati dal backend → **stato sincronizzato**.

## Prossime slice

- **Slice 3**: eventi e prenotazioni con sincronizzazione realtime tra dispositivi.
- **Slice 4**: operazioni backoffice e permessi per ruolo (policy RLS dedicate).
