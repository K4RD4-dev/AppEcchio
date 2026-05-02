# Flussi operativi

## 1. Accumulo token e XP da check-in evento
1. L'utente apre “Il mio QR” e ottiene token breve durata firmato.
2. Lo staff scansiona tramite app incaricati.
3. Backend verifica: firma token, scadenza, autorizzazione staff, iscrizione evento, unicità check-in.
4. Se valido, salva `event_checkins` con `scan_result=valid`.
5. Pubblica evento dominio `EVENT_CHECKIN_CONFIRMED`.
6. Gamification Engine crea ledger entry con `token_delta`, `experience_delta` e `idempotency_key=checkin:{eventId}:{userId}`.
7. Wallet projector aggiorna saldo token e saldo XP.

## 2. Emissione voucher a soglia XP
1. A ogni ledger confermato, il motore ricalcola soglia raggiunta.
2. Se gli XP superano una soglia non ancora premiata, emette voucher.
3. Crea record `reward_vouchers` con `status=issued` e `expires_at`.
4. Notifica utente in app.

## 3. Redemption voucher presso locale
1. Operatore locale inserisce/scansiona codice voucher.
2. Backend valida stato, scadenza, locale abilitato.
3. Se valido: imposta `status=redeemed`, `redeemed_at=NOW()`.
4. Registra audit log e risposta positiva.

## 4. Gestione errori/frode
- Token scaduto => `token_invalid`.
- Utente già check-in => `already_checked_in`.
- Staff non autorizzato => `not_authorized`.
- Tentativi ripetuti oltre soglia => rate-limit e audit.
