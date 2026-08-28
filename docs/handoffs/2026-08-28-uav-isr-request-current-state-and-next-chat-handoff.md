---
document_id: OMW-HANDOFF-UAV-ISR-REQUEST-2026-08-28
status: DRAFT
document_class: CHAT_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - current UAV ISR request branch status
  - observed Acceptance-3 evidence and remaining DCS gates
  - next development sequence for this branch
not_authoritative_for:
  - production UAV ISR acceptance
  - production resource reconciliation implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/uav-isr-request-orchestration
source_commit: 8b03c10b5566a7423c197d5604ba606a51d900e5
validated_in_dcs: false
supersedes:
superseded_by:
---

# UAV-ISR-Request – aktueller Stand und nächste Schritte

## 1. Geltungsbereich

Diese Übergabe beschreibt ausschließlich den veröffentlichten Arbeitsstand des
Branches `agent/uav-isr-request-orchestration` nach Übernahme des aktuellen
`main`-Stands. Sie ersetzt keine Produktionsfreigabe und keine
DCS-Acceptance für den aktuellen Branch-HEAD.

Die maßgebliche Entwicklungsplanung bleibt:

```text
docs/91-uav-isr-request-orchestration.md
status: DRAFT
```

Die Acceptance-3-Arbeitsanweisung liegt hier:

```text
mission/tests/uav-isr-request/ACCEPTANCE-3.md
```

## 2. Übernommene projektweite Regel

Der Branch enthält den Main-Commit:

```text
424553f817380becc976a8c23221c6b0c5433bff
docs(governance): define CampaignState MOOSE reconciliation
```

Damit gilt auch für UAV-ISR verbindlich Abschnitt 5.1 aus:

```text
docs/00-project-governance.md
CampaignState–MOOSE-Autorität und Ressourcenabgleich
```

Er trennt strategische Persistenz und physische MOOSE-Ausführung, verlangt
stabile Ressourcen-IDs statt bloßer Zähler und verbietet eine stille
Bestandskorrektur bei ungeklärter Abweichung.

## 3. Implementierter Acceptance-3-Umfang

Acceptance 3 bleibt bewusst ein isolierter Kandahar-Test und ist keine
Produktions-UAV-Orchestrierung.

```text
BLUE marker: UAV RECON
F10: Command -> ISR Cell
source: Kandahar Main AIRWING -> 361st ERS MQ-9 Squadron
physical execution: MOOSE AIRWING / SQUADRON / AUFTRAG
on-station: AUFTRAG:NewORBIT_CIRCLE
profile: 25,000 ft MSL, 180 kt IAS, 2,700 s after MOOSE Executing
submit radius: 50 km around the requesting client group
```

Die explizite SQUADRON-Bindung ist erforderlich. Ein generischer MOOSE-ORBIT
kann sonst jede orbitfähige Staffel wählen; dies war die Ursache der früheren
A-10-Fehlzuweisung.

Nicht enthalten sind unter anderem:

- mehrere Recon-Pools und Basen;
- Bagram- oder andere MQ-1-/MQ-9-Quellen;
- Produktionsterrain, Holding- oder Wetterpolicy;
- ISR-Sensor-, Radar-, Laser- oder Zielmeldelogik;
- eine produktive Verlust-, Wartungs-, Reparatur- oder Restart-Reconciliation.

## 4. Beobachtete DCS-Ergebnisse

Die folgenden Ergebnisse wurden während der Acceptance-3-Arbeit in DCS
beobachtet. Sie sind Laufzeitbeobachtungen, aber noch keine vollständige
`ACCEPTED_TECHNICAL_BASELINE` für den aktuellen Branch-HEAD.

| Beobachtung | Ergebnis |
|---|---|
| Marker- und ISR-Cell-Menü | nach Menü-Scope-Korrektur sichtbar und nutzbar |
| Falsche A-10-Dispositon | durch explizite Kandahar-MQ-9-SQUADRON-Bindung beseitigt |
| Physischer MQ-9-Start | beobachtet |
| Orbitform | Racetrack durch Kreis-Orbit ersetzt; Kreisflug am Marker beobachtet |
| Eigentümer-Recall | in queued, ground, airborne und on-station als Request-Lifecycle ergänzt |
| Physische Rückkehr | MOOSE meldete Rückkehr erst nach tatsächlicher Recovery; AIRWING darf danach die DCS-Gruppe zurücknehmen/despawnen |
| Fehler ISR-0004 | MOOSE hatte die MQ-9 korrekt wieder verfügbar, CampaignState blieb wegen permanentem `Consume` fälschlich leer; weiterer Start wurde blockiert |

Aus den vorliegenden Laufzeitlogs ist für die vorherige A3-7-Testiteration
belegt, dass Requests `ISR-0002` und `ISR-0003` nacheinander
`MISSION_STARTED`, `MISSION_RECALL_ORDERED`, `MISSION_RETURNING`,
`MISSION_TASK_DONE` und `MISSION_RECOVERED` erreichten. Der anschließende
neue Request wurde jedoch nicht disponiert, weil die Acceptance-lokale
CampaignState-Zahl nach zwei Starts auf null stand.

## 5. Korrektur für den konkret beobachteten Fehler

Commit:

```text
e7a72592cfcf082408960c9c6576dbc341fa38d8
Restore UAV availability after physical recovery
```

ändert den Acceptance-Adapter wie folgt:

```text
physical MOOSE recovery
  -> RecoverAfterPhysicalRecovery(requestId)
  -> idempotent CreditResourceOnce(
       creditId = ISR-UAV-RECOVERY:<requestId>)
  -> MISSION_RECOVERED ... resourceRestored=true
  -> coordinator marks request completed
```

Die Gutschrift erfolgt nur nach beobachteter physischer Recovery, nicht beim
Recall, nicht bei `AUFTRAG:Done` und nicht beim bloßen Rückkehrbefehl.

Dies ist eine gezielte Reparatur der Acceptance-3-Zählung. Sie ist **kein**
Nachweis einer fertigen produktiven Ressourcenbuchhaltung und darf nicht als
Vorbild für einen dauerhaften `Consume`-/späteren Credit-Pfad ohne
assetgenaue Zustandsmaschine übernommen werden.

## 6. Teststand des aktuellen HEAD

Der aktuelle Branch-HEAD benötigt noch den lokalen A3-8-Build und den
folgenden DCS-Gate-Test:

1. Eine MQ-9-Anforderung bis zu `MISSION_RECOVERED ... resourceRestored=true`
   durchführen.
2. Erst danach eine neue gültige Markeranforderung derselben Gruppe abgeben.
3. Nachweisen, dass der neue Request `MISSION_QUEUED` und
   `MISSION_STARTED` erreicht und erneut eine MQ-9 startet.
4. Bundle-Hash, DCS-/Debrief-Logauszüge und Screenshots dem Testnachweis
   zuordnen.

Ohne diesen Lauf ist nicht belegt, dass der Commit `e7a7259` den ISR-0004-
Fehler in DCS tatsächlich behebt. Für diesen Commit liegt zudem derzeit kein
GitHub-Actions-Workflow-Run vor; die vorhandenen Lua-Unit-Tests sind
Quelltests, kein DCS-Nachweis.

## 7. Verbindliche Folgearbeit nach dem A3-8-Gate

Erst wenn Abschnitt 6 bestanden ist:

1. Die Acceptance-lokale Zahl durch eine assetgenaue CampaignState-
   Zustandsrepräsentation ersetzen.
2. Je strategischer Ressourcen-ID die Zustände `available`, `reserved`,
   `deployed`, `returning`, `maintenance` und `lost` modellieren.
3. MOOSE-Lifecycle-Ereignisse idempotent in CampaignState übernehmen.
4. Einen Abgleich bei Start, physischem Start, Recovery, Verlust und
   Server-/Missionsneustart implementieren.
5. Ungeklärte MOOSE-/CampaignState-Abweichungen sperren und diagnostizieren;
   nicht automatisch inventarisieren oder als Verlust buchen.
6. Erst danach mehrere explizit gewählte Recon-Herkunftspools (zum Beispiel
   Kandahar und Bagram) ergänzen.

Die produktive Implementierung muss die in `docs/00-project-governance.md`,
Abschnitt 5.1, vorgeschriebenen Mindestnachweise erbringen.

## 8. Lokaler nächster Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch-uav-isr-request
git pull --ff-only
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-uav-isr-request-acceptance-3.ps1
Get-FileHash .\mission\tests\uav-isr-request\dist\OMW_UAV_ISR_Request_Acceptance_3.lua -Algorithm SHA256
```

Erwartet wird:

```text
BuilderVersion: OMW-UAV-ISR-REQUEST-ACCEPTANCE-3-8
```

Die MIZ selbst wird durch den Builder nicht verändert. Das erzeugte Lua-Bundle
ersetzt im bestehenden einzelnen MOOSE-nachgelagerten Trigger die vorherige
Acceptance-3-Datei. Danach ist ein vollständiger Missionsneustart erforderlich.
