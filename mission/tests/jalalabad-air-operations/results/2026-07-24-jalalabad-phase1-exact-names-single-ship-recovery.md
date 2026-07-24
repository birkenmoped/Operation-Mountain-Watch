# Jalalabad Phase 1 – exakte Runtime-Namen und Single-Ship-Recovery

## Status

```text
Repository-Fix: IMPLEMENTED
BuilderVersion: JBAD-AIR-OPS-PHASE1-3
Lua-Syntaxprüfung der korrigierten Quellen: PASS
MIZ-Archivprüfung: PASS
DCS-Laufzeitvalidierung: PENDING
```

## Nachgewiesene Fehler des vorherigen Laufs

1. Eine OH-58D-Client-/Testgruppe wurde ausschließlich aufgrund des passenden DCS-Typs als erwartete AIRWING-Missionsgruppe registriert.
2. Die echte OH-58D-AIRWING-Gruppe wurde anschließend als unerwarteter Spawn behandelt und sofort abgebrochen.
3. AH-64D Lead und Wingman waren eine gemeinsame DCS-Gruppe. Nur der Lead landete; der Wingman kreiste weiter, weil die gemeinsame Recovery nicht abgeschlossen werden konnte.
4. `SetDespawnAfterLanding(true)` fehlte.
5. Ein gemeinsamer Gesamt-Timeout umfasste Auftrag, RTB, Landung und Assetfreigabe und war damit für eine vollständige Recovery ungeeignet.

## Umgesetzte Korrekturen

- keine type-only-Zuordnung mehr;
- exakte Runtime-Gruppenpräfixe `<SQUADRON>_AID-`;
- exakter Single-Ship-Einheitenname `<GRUPPENNAME>-01`;
- feste Ausschlusslisten für Client-, Player-, Template- und Testgruppen;
- OH-58D und AH-64D als zwei unabhängige Single-Ship-Gruppen pro logischem Two-Ship;
- `SetDespawnAfterLanding(true)` bei allen vier SQUADRONs;
- getrennte Spawn-, Ausführungs-, Recovery- und Freigabezeiten;
- Bestandsmodell auf `24/8/8/8` Single-Ship-Assetgruppen umgestellt;
- Gesamtsequenz-Abnahme auf die neuen Bestände angepasst.

## Nächste DCS-Validierung

```text
1. OH58D_RECON einzeln
2. Mission neu starten und dcs.log auswerten
3. AH64D_CAS einzeln
4. Mission neu starten und dcs.log auswerten
5. erst danach Gesamtablauf
```

Erwartet wird, dass beide Luftfahrzeuge getrennte MOOSE-Gruppennamen erhalten, unabhängig landen und nach dem jeweiligen Land-Ereignis despawnen.
