# Rollout checklist

## Fase 1 — MVP
- [ ] Migrazioni DB eseguite in staging.
- [ ] Endpoint check-in disponibili con auth staff.
- [ ] Ledger idempotente verificato con test di doppia richiesta.
- [ ] Saldo token e saldo XP coerenti con somma movimenti confermati.
- [ ] Emissione voucher a soglia XP testata.
- [ ] Redemption singolo utilizzo testata.

## Fase 2 — Hardening
- [ ] Rate limit su scansioni e redemption.
- [ ] Alert su anomalie (scan invalidi ripetuti).
- [ ] Dashboard KPI base per admin.
- [ ] Procedure storno token/XP documentate.

## Fase 3 — Evoluzione
- [ ] Campagne token/XP temporanee configurabili.
- [ ] Partnership multi-locale attive.
- [ ] Badge/classifiche in sperimentazione A/B.
