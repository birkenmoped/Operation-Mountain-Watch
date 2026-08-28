---
document_id: OMW-HANDOFF-UAV-ISR-REQUEST-2026-08-28
status: ACTIVE_ARCHITECTURE_REWORK_REQUIRED
document_class: CHAT_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - current UAV ISR request branch status
  - rejected orchestration paths
  - required next investigation
not_authoritative_for:
  - production UAV ISR acceptance
  - approval of A3-12 retry logic
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/uav-isr-request-orchestration
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# UAV-ISR-Request – aktueller Stand und nächste Schritte

## Kurzstatus

Der Branch ist **nicht bereit für einen weiteren DCS-Abnahmetest**. A3-12
enthält einen lokalen Retry-/Scheduler-Pfad, der nachweislich eine parallele
Admission-Queue zu MOOSE AIRWING baut. Er ist verworfen.

Der vollständige Verlauf einschließlich aller bekannten Fehler, beobachteten
Folgen, Unsicherheiten, betroffenen Commits und Pflichtschritte steht in:

```text
docs/handoffs/2026-08-28-uav-isr-request-error-and-decision-register.md
```

## Beobachtete Ursache des letzten nicht gestarteten Auftrags

Im A3-11-Lauf wurde ISR-0007 lokal als angenommen geführt, aber wegen einer
vorangestellten CampaignState-Reservierung nie an `AIRWING:AddMission`
übergeben:

```text
16:09:51 ISR-0007 SUBMIT_ACCEPTED
16:09:51 DISPATCH_DEFERRED reason=NO_AVAILABLE_ISR_ASSET
16:15:57 / 16:16:05 vorherige MQ-9 physisch recovered
danach kein MISSION_STARTED für ISR-0007
```

Die nachträgliche lokale Wiederholung alle 30 Sekunden ist keine korrekte
Lösung. MOOSE muss die physische Missionswarteschlange führen.

## Aktuelle, nicht mehr geltende Anweisungen

Alle früheren Aussagen in diesem Branch, die behaupten, A3-12 oder ein
aktuelles Bundle löse das Warteschlangenproblem, sind durch dieses Dokument
und das Fehlerregister ersetzt. Nutzer sollen A3-12 nicht als Lösung
bauen oder testen.

## Nächste Implementierungs-Gates

1. MOOSE-first-Recherche für AIRWING-Missionswarteschlange,
   AUFTRAG-Zustandsautomat und öffentliche Lifecycle-Callbacks abschließen.
2. Den exakten, öffentlichen Zeitpunkt bestimmen, an dem CampaignState den
   MOOSE-physisch geplanten Auftrag strategisch abgleicht.
3. Bei CampaignState/MOOSE-Differenz ein dokumentiertes, fail-closed Verhalten
   entwerfen – ohne lokale Ressourcenwarteschlange und ohne Polling als Ersatz.
4. Architektur, Ausnahmebedarf und Testmatrix vom Projektinhaber freigeben
   lassen.
5. Erst danach A3-12 durch einen nachvollziehbaren Korrekturcommit entfernen
   oder ersetzen und einen neuen Build erzeugen.

## Acceptance-only Bodenrückruf

Die direkte Behandlung von `Asset.Treturned` ist keine öffentliche
MOOSE-API. Sie bleibt eine nicht produktiv freigegebene, eng begrenzte
Acceptance-Ausnahme. Die Recherche ist im Fehlerregister verzeichnet; sie
legitimiert nicht den direkten Zugriff und ersetzt keine Freigabe.

## Bereits beobachtete, aber nicht ausreichend abgeschlossene Bereiche

- F10-/Marker- und Abbruchablauf: teilweise korrigiert, weiterhin als
  Zustandsmatrix nachzuweisen.
- Racetrack zu Kreisorbit: fachlich korrigiert, nur im konkreten
  Acceptance-Profil.
- `RETURNING` nach Rückkehr: Callback ergänzt, Gesamtarchitektur noch offen.
- Bodenrückruf: beobachtet, aber noch ohne vollständige, korrelierte
  MOOSE-Lifecycle-Abnahme.
- Ressourcen-/Queue-Abgleich: offen und aktuell der Blocker.
