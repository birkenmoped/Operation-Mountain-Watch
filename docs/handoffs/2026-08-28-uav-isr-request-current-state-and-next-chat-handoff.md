---
document_id: OMW-HANDOFF-UAV-ISR-REQUEST-2026-08-28
status: ACTIVE_TEST_FIX
document_class: CHAT_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - current UAV ISR request branch status
  - observed Acceptance-3 evidence and remaining DCS gates
  - no-takeoff recall turnover exception
not_authoritative_for:
  - production UAV ISR acceptance
  - production resource reconciliation implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/uav-isr-request-orchestration
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# UAV-ISR-Request – aktueller Stand und nächste Schritte

## 1. Geltungsbereich

Diese Übergabe beschreibt den Acceptance-3-Arbeitsstand auf
`agent/uav-isr-request-orchestration`. Sie ist keine Produktionsfreigabe.

```text
BLUE marker: UAV RECON
F10: Command -> ISR Cell
source: Kandahar Main AIRWING -> 361st ERS MQ-9 Squadron
physical execution: MOOSE AIRWING / SQUADRON / AUFTRAG
on-station: AUFTRAG:NewORBIT_CIRCLE
profile: 25,000 ft MSL, 180 kt IAS, 2,700 s after MOOSE Executing
submit radius: 50 km around the requesting client group
```

## 2. Verbindliche Autoritätsaufteilung

Die auf `main` dokumentierte CampaignState–MOOSE-Abgleichregel gilt auch hier:

- **MOOSE** führt das physische Asset, Start, Flug, Rückkehr und Wartung.
- **CampaignState** führt die strategische, persistierbare Zuordnung.
- CampaignState wird erst nach beobachteter physischer MOOSE-Rückgabe
  gutgeschrieben.
- Abweichungen werden geloggt und nicht still durch parallele Zähler korrigiert.

## 3. Beobachteter Fehler und Korrektur

Die Laufzeitlogs zeigen für **ISR-0003**:

```text
14:40:36 MISSION_STARTED
14:40:51 MISSION_RECALL_ORDERED
14:40:56 physische Rückgabe/Despawn
```

Die Screenshots zeigen dieselbe MQ-9 am Boden und nach Recall den leeren
Parkplatz. Es gab keine dem ISR-0003-Vorgang zuordenbare Start-/Landesequenz.
Der bisherige Adapter behandelte jeden MOOSE-Rücklauf gleich. MOOSE setzt bei
der Rückgabe aber auch für ein nie gestartetes Asset die
Wartungszeitmarke. Dadurch erhielt ein Bodenabbruch fälschlich die reguläre
Turnoverzeit.

Die Korrektur verwendet den dokumentierten MOOSE-FSM-Callback
`OnAfterElementTakeoff` und `FLIGHTGROUP:IsAirborne()`. Ein Asset erhält nur
dann die reguläre MOOSE-Turnoverzeit, wenn einer dieser Nachweise einen Start
bestätigt. Beim Bodenabbruch wartet der Adapter zuerst, bis MOOSE den
Rückgabezeitstempel veröffentlicht hat, entfernt ihn dann ausschließlich für
dieses Asset und schreibt erst danach CampaignState gut.

## 4. Dokumentierte Ausnahme

MOOSE-Dokumentation, gepinnter Quellcode und offizielle Beispiele wurden
geprüft. Für das Beibehalten einer konfigurierten Staffelturnoverzeit bei
gleichzeitigem Erlass **für genau ein** nie gestartetes Rückgabeasset gibt es
keine öffentliche MOOSE-API. Die projektinhaberseitig angeforderte,
acceptance-begrenzte Ausnahme ist deshalb:

```text
nach physischer MOOSE-Rückgabe
und ohne bestätigten ElementTakeoff
-> Asset.Treturned nur für dieses Asset entfernen
-> CampaignState-Recovery abschließen
```

Sie ersetzt weder MOOSE-Dispatch noch MOOSE-Rückgabe, erzeugt keine DCS-Gruppe,
ändert keine Staffelkonfiguration und gilt nicht als Produktionswartungspolitik.

## 5. Korrektur: verzögerte strategische Disposition

Der Lauf mit Bundle A3-11 belegt zusätzlich einen separaten Fehler:

```text
16:09:51 ISR-0007 SUBMIT_ACCEPTED
16:09:51 DISPATCH_DEFERRED reason=NO_AVAILABLE_ISR_ASSET
16:15:57 / 16:16:05 vorherige MQ-9 physisch recovered
danach kein erneuter Dispatch-Versuch
```

ISR-0007 war damit nie in MOOSEs AIRWING-Missionswarteschlange. Die
F10-Meldung `queued` bezeichnete nur den lokalen Coordinator-Zustand und war
falsch bzw. unvollständig. A3-12 führt deshalb einen MOOSE-`SCHEDULER` mit
30-Sekunden-Intervall ein: Solange ein Request strategisch `QUEUED` bleibt,
wird die Reservierung erneut versucht. Nach der CampaignState-Gutschrift wird
der AUFTRAG einmal in die bestehende AIRWING übergeben; erst dort steuert MOOSE
die noch laufende Turnoverzeit. Ein noch wartender Request kann über F10
abgebrochen werden.

## 6. Noch notwendiger DCS-Gate

Der aktuelle Build muss drei getrennte Fälle nachweisen:

1. **Strategisch wartender Request:** Während beide MQ-9 aktiv oder in Turnover sind, einen dritten Request absenden. Erwartet: `DISPATCH_RETRY_SCHEDULED`; nach physischer Recovery `DISPATCH_RETRY_ASSIGNED` und anschließend MOOSE-Start erst nach seiner Turnoverzeit.\n2. **Bodenabbruch:** Spawn/Triebwerkstart, Recall vor Taxi/Takeoff, Despawn.
   Erwartet: `MISSION_TURNOVER_WAIVED_NO_TAKEOFF`,
   `takeoffConfirmed=false`, `turnoverWaived=true`,
   `turnoverSeconds=0`, sofortige Verfügbarkeitsmeldung.
3. **Echter Flug:** bestätigter Takeoff, danach Recall/Rückkehr.
   Erwartet: `MISSION_TAKEOFF_CONFIRMED`,
   `takeoffConfirmed=true`, `turnoverWaived=false` und positive
   MOOSE-Turnoverzeit mit Hinweismeldung.

Erst ein Test mit Bundle-Hash, DCS-/Debrief-Log und Screenshots kann diesen
Branch-Stand als technische Baseline bestätigen.
