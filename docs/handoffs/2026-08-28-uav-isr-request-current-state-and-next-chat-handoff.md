---
document_id: OMW-HANDOFF-UAV-ISR-REQUEST-2026-08-28
status: ACTIVE_A3_13_DCS_VALIDATION_REQUIRED
document_class: CHAT_HANDOFF
owning_policy: OMW-GOV-001
source_branch: agent/uav-isr-request-orchestration
validated_in_dcs: false
---

# UAV-ISR-Request – aktueller Stand und nächste Schritte

## Kurzstatus

A3-13 ersetzt A3-12. Der verworfene lokale 30-Sekunden-Retry ist aus dem
aktiven Laufzeitpfad und den Tests entfernt. A3-13 ist nun ein DCS-Testkandidat,
aber noch **nicht DCS-validiert** und nicht produktionsfreigegeben.

## Implementierter Ablauf

```text
Spielerauftrag
  -> AUFTRAG:NewORBIT_CIRCLE
  -> AIRWING:AddMission
  -> MOOSE AIRWING queue / Assetwahl / Turnover
  -> MOOSE Started
  -> CampaignState Reserve + Consume
  -> MOOSE physische Rückkehr
  -> CampaignState Credit
```

CampaignState kann die MOOSE-Queue nicht mehr vorab blockieren. Schlägt die
strategische Buchung beim bereits bestätigten MOOSE-Start fehl, wird der
physische Auftrag über MOOSE zurückgerufen, als
`RECONCILIATION_REQUIRED` protokolliert und weiterer ISR-Dispatch gesperrt.

## Ursache des vorherigen Fehlers

ISR-0007 wurde im A3-11-Lauf lokal als angenommen geführt, aber vor
`AIRWING:AddMission` wegen CampaignState-Verfügbarkeit abgewiesen. Daher war
er nie in MOOSEs Missionswarteschlange und konnte nach Rückkehr/Turnover nicht
starten. A3-12 hat das mit einer lokalen Wiederholung überdeckt; das war ein
MOOSE-first-Verstoß. A3-13 beseitigt genau diese Reihenfolge.

## Testpflicht

1. Mindestens drei Aufträge nacheinander; einer muss auf MOOSE-Asset/Turnover
   warten und danach ohne erneute F10-Eingabe starten.
2. Bodenabbruch vor Takeoff: physischer Despawn, sichtbare sofortige
   Verfügbarkeit nur im dokumentierten Acceptance-Ausnahmefall.
3. Echter Flug: Start, Kreisorbit, Return und Turnover-Hinweis.
4. CampaignState/MOOSE-Differenz: sichtbare Sperre und MOOSE-Rückkehr.
5. Jede Beobachtung mit Request-ID aus Bildschirm und DCS-Log korrelieren.

## Wichtige Grenzen

- Die direkte Behandlung von `Asset.Treturned` bleibt eine nicht öffentliche,
  eng begrenzte Acceptance-Ausnahme und keine Produktionslösung.
- A3-13 gleicht aktuell den profilbasierten strategischen Bestand gegen
  MOOSE-physische Ausführung ab; eine stabile Einzelasset-Persistenz ist vor
  Produktion noch zu entwerfen.
- Eine erfolgreiche Build-Prüfsumme ist kein DCS-PASS.

Das vollständige Fehler- und Entscheidungsprotokoll:
`docs/handoffs/2026-08-28-uav-isr-request-error-and-decision-register.md`.
