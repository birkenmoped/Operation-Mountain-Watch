---
document_id: OMW-HANDOFF-UAV-ISR-REQUEST-2026-08-28
status: ACTIVE_TEST_FIX
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
source_commit: f40dcab5fbb21f6400aeab3819db9c60a4897ed4
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
| ISR-0004, A3-7 | CampaignState blieb nach `Consume` fälschlich leer; weiterer Start wurde vor MOOSE blockiert |
| ISR-0004, A3-8 | CampaignState wurde nach physischer Recovery korrekt gutgeschrieben und der Auftrag bei MOOSE eingereiht, aber beide MQ-9 befanden sich in der MOOSE-Staffelwartung |

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

Der A3-8-DCS-Lauf widerlegt die Annahme, dass die Gutschrift allein den
Folgeflug freigibt:

- `ISR-0002` wurde physisch recovered und um 14:39:44 mit
  `resourceRestored=true` gutgeschrieben.
- `ISR-0003` nutzte die zweite MQ-9, wurde um 14:40:56 ebenfalls recovered
  und gutgeschrieben.
- `ISR-0004` wurde um 14:41:10 angenommen und von MOOSE als
  `MISSION_QUEUED` eingereiht, aber bis zum Testende um 14:45:15 nicht
  gestartet.

Die Ursache ist im Kandahar-Foundation-Code und in der gepinnten MOOSE-Quelle
verifiziert: jede Staffel erhielt `SetTurnoverTime(20, 40)`. Das bedeutet
20 Minuten reguläre Wartung nach Rückkehr plus 40 Minuten je Schadenspunkt,
nicht ein zufälliges Intervall von 20 bis 40 Minuten. In diesem Lauf waren
beide MQ-9 deshalb für den unmittelbar folgenden Auftrag bei MOOSE noch nicht
disponierbar. Der früheste normale Wiederstart wäre erst nach der jeweiligen
MOOSE-Wartungszeit möglich gewesen.

A3-9 ist deshalb als **Acceptance-spezifische** Korrektur vorbereitet:
nachdem Kandahar läuft, setzt es ausschließlich
`Kandahar.Squadrons.MQ9:SetTurnoverTime(0, 0)`. Damit bleibt die
produktionsweite Kandahar-Konfiguration unverändert, aber im schnellen
Acceptance-Kreislauf stimmen die zwei vorhandenen Verfügbarkeitsaussagen nach
physischer Recovery überein: MOOSE und die Acceptance-lokale
CampaignState-Gutschrift sind beide sofort bereit.

Verbleibender DCS-Gate-Test für A3-9:

1. Zwei MQ-9-Anforderungen nacheinander starten und jeweils vollständig
   physisch recovern lassen.
2. Nach dem zweiten `MISSION_RECOVERED ... resourceRestored=true`
   `ISR-0004` anfordern.
3. Nachweisen, dass `ISR-0004` nicht nur `MISSION_QUEUED`, sondern auch
   zeitnah `MISSION_STARTED` erreicht.
4. Bundle-Hash, DCS-/Debrief-Logauszüge und Screenshots dem Testnachweis
   zuordnen.

Der Test belegt nur die A3-9-Annahme ohne Turnover; er ist kein Nachweis einer
produktiven Wartungs-, Reparatur- oder Ressourcen-Reconciliation.

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
BuilderVersion: OMW-UAV-ISR-REQUEST-ACCEPTANCE-3-9
```

Die MIZ selbst wird durch den Builder nicht verändert. Das erzeugte Lua-Bundle
ersetzt im bestehenden einzelnen MOOSE-nachgelagerten Trigger die vorherige
Acceptance-3-Datei. Danach ist ein vollständiger Missionsneustart erforderlich.
