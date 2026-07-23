# Backend setup (Supabase) — Slice 1: auth + profili

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

## Prossime slice

- **Slice 2**: XP / token / voucher persistenti.
- **Slice 3**: eventi e prenotazioni con sincronizzazione realtime tra dispositivi.
- **Slice 4**: operazioni backoffice e permessi per ruolo (policy RLS dedicate).
