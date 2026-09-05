---
document_id: OMW-MOOSE-STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - focused Stage 3 AH-64 CAS route and execution acceptance
  - focused Stage 3 CH-47 slingload route acceptance
  - rejection and remediation of the 2026-09-05 focused test-fixture failure
  - focused 2026-09-05 DCS evidence for CAS success and CH-47 post-pickup lifecycle failure
  - observation-only diagnosis of the CARGOTRANSPORT PAUSED-to-OVER transition
  - removal of IncidentParticipants as tactical completion evidence in this acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 – Focused CAS + Air-AMMO Resupply Acceptance

## Zweck

Dieser Acceptance-Lauf isoliert die beiden im letzten vollständigen Stage-3-Lauf weiterhin fehlerhaften Luftpfade. Guard, QRF, Artillerie und strategische CampaignState-Abrechnung werden bewusst nicht erneut getestet.

## MOOSE-Basis

Verbindlicher Stand:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Rejected focused run – 2026-09-05

Der erste fokussierte Lauf ist ausdrücklich `REJECTED` und nicht als Verifikation irgendeines Luftpfades verwertbar.

Provenienz:

```text
Git commit:
31fb168b12dd893ed94ba71155a7edf86043e69d

BuilderVersion:
STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-1

Bundle SHA256:
9ABAED9388293DF31A201DE0F2C334BF384F3CCB8B3FB6B3FB9CC2DF938643D4

MizMutation:
false
```

Der reale DCS-Lauf zeigte unmittelbar nach dem Start des Focus-Fixtures:

```text
CAS geometry prepared
CAS mission queued
RESUPPLY FAIL: cargo numeric ID unavailable
READY message was nevertheless emitted
```

Die Ursache lag im Acceptance-Code und nicht in einer nachgewiesenen DCS-Slingload-Einschränkung. Das Fixture verlangte fälschlich:

```lua
if type(state.cargo:GetID()) ~= "number" then
  fail(...)
end
```

Die tatsächlich gepinnte `Moose.lua` dokumentiert `OBJECT:GetID()` als String und verwendet bei `AUFTRAG:NewCARGOTRANSPORT()` den Rückgabewert von `StaticCargo:GetID()` direkt als `CargoTransportation.params.groupId`. Die numerische Typforderung war daher ein erfundener Test-Gate.

Zusätzlich verwendete das Fixture einen einzigen globalen `state.failed`. Dadurch unterdrückte der RESUPPLY-Fehler anschließend auch die unabhängige CAS-Routeninstallation. Das erklärt den im realen Lauf beobachteten direkten AH-64-Flug statt R500/WEST. Der CH-47-Auftrag wurde wegen des vorherigen falschen Gates überhaupt nicht angelegt.

Diese Fehlerklasse ist für das Focus-Fixture jetzt ausdrücklich verboten:

```text
CAS failure      != stop RESUPPLY execution
RESUPPLY failure != stop CAS execution
Acceptance observation != artificial runtime prerequisite
```

## CAS

Der Test verwendet `AUFTRAG:NewCAS`, nicht `AUFTRAG:NewPATROLZONE`.

Die taktische Geometrie wird explizit aus den vorhandenen OMW-Daten abgeleitet:

```text
Jalalabad
-> OMW_FlightPath_R500
-> OMW_FlightPath_WEST
-> tactical ingress = WEST-Ausgang Richtung Honaker
-> CAS working point = Honaker-AO-Zentrum
-> tactical egress = WEST-Ausgang (Acceptance-Variante 1)
-> WEST reverse
-> R500 reverse
-> Jalalabad
```

MOOSE erhält den Ingress über `AUFTRAG:SetMissionIngressCoord()` und den Egress über `AUFTRAG:SetMissionEgressCoord()`. Die CAS-Mission erhält das Honaker-AO-Zentrum als expliziten Working-Point über den `Coordinate`-Parameter von `AUFTRAG:NewCAS`. `SetMissionWaypointRandomization(0)` entfernt die sonst verwendete zufällige Mission-Waypoint-Abweichung.

`AUFTRAG:SetMissionWaypointCoord()` wird für den AH-64 bewusst nicht verwendet, weil die gepinnte MOOSE-Quelle die Methode als `[NON-AIR]` dokumentiert.

Der abgebrochene Focus-Lauf zeigte außerdem eine Regression des Angriffverhaltens: `AUFTRAG:NewCAS()` setzt in der gepinnten MOOSE-Version standardmäßig `ROE=OpenFire`, aber `ROT=EvadeFire`. Der zuvor verwendete CAS-Dispatch-Pfad hatte zusätzlich `SetEngageDetected()` gesetzt; `PATROLZONE` verwendete `PassiveDefense`. Für den Focus-Lauf wird deshalb ausschließlich über öffentliche, in der gepinnten `Moose.lua` verifizierte AUFTRAG-Methoden explizit gesetzt:

```lua
mission:SetEngageDetected(CAS_RADIUS_NM, {"Ground Units"}, casZone, nil)
mission:SetROE(ENUMS.ROE.OpenFire)
mission:SetROT(ENUMS.ROT.PassiveDefense)
```

Für diesen Focus-Test erfolgt die Freigabe zur Rückkehr ausschließlich testbedingt 90 Sekunden nach dem ersten real bestätigten AH-64-Waffeneinsatz. Dies ist kein Produktionskriterium.

Ausdrücklich nicht zulässig als CAS-/Gefechtsabschluss:

```text
IncidentParticipants == 0
KNOWN_ATTACKERS_NEUTRALIZED
OPSZONE Defeated allein
Alarmzonen-Ausgang allein
```

`IncidentParticipants` sind höchstens Evidenz/Attribution/Targeting-Historie und keine taktische Gesamtlage.

## CH-47 Air-AMMO

Der Test behält `AUFTRAG:NewCARGOTRANSPORT` als MOOSE-Ausführer für den physischen Slingload bei.

Die gepinnte MOOSE-Quelle legt beim Konstruktor bereits die relevanten Referenzen an:

```text
cargo
cargo groupId = StaticCargo:GetID()  # MOOSE ID may be string
DropZone
DropZone zoneId
```

Der Acceptance-Kontext hält Cargo und DropZone zusätzlich explizit fest und übergibt beim Route-Handoff:

```text
cargo
cargoId = cargo:GetID()              # string or number; no invented numeric gate
dropZone
zoneId = dropZone.ZoneID
```

Nach physisch bestätigter Aufnahme wird über den öffentlichen MOOSE-Lifecycle `PauseMission()` die laufende CargoTransportation-Aufgabe freigegeben. Erst nach Task-Freigabe wird R500 outbound/return installiert; am Wright-seitigen Routenende wird der CargoTransportation-Task für exakt dasselbe Cargo und dieselbe DropZone erneut angesetzt. Die physische Ablieferung muss bestätigt sein, bevor die Mission als erfolgreich gilt.

## DCS-Lauf 2026-09-05 – Focus 1-2

Provenienz:

```text
Git commit:
b0b862cc0a51e478ef8210dff426727b1cb3071e

BuilderVersion:
STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-2

Bundle SHA256:
BDB15116D7761B621831BC2D7075FA0820DEA186371DED787556723BED9B019B

Mission:
OMW_Template_v21_GroundWorks_RadioPresets_v1.7(2).miz

Mission SHA256:
569A22453588FBE9950BBEC78A29F7002F017AF64BB96C47B75FEC8ED096B900

DCS:
2.9.29.27468 MT

MizMutation:
false
```

### CAS-Ergebnis

Der reale Lauf bestätigte für den fokussierten Acceptance-Pfad:

```text
AH-64 start/dispatch from Jalalabad
R500 outbound
WEST outbound
CAS attack execution in Honaker area
real weapon employment
acceptance-only release after first shot + 90 seconds
WEST reverse
R500 reverse
landing Jalalabad
AIRWING recovery
```

Dieser CAS-Pfad wird für die nächste CH-47-Diagnose **nicht funktional verändert**. Er bleibt Bestandteil des Bundles nur als Regression gegen versehentliche Rückfälle.

### CH-47-Ergebnis

Der reale Lauf bestätigte:

```text
physical slingload pickup
cargo ID and Wright drop-zone ID retained
PauseMission requested through public MOOSE API
active CargoTransportation task released
R500 handoff installed
external slingload remained physically attached after PauseMission/TaskCancel/TaskDone
CH-47 followed R500 outbound
```

Nicht bestätigt wurde die Ablieferung. Stattdessen zeigte der Logablauf nach dem erfolgreichen Route-Handoff:

```text
CARGOTRANSPORT_ENDED_BEFORE_PHYSICAL_DELIVERY
MOOSE CARGOTRANSPORT failed
CARGO_TASK_DONE_WITHOUT_PHYSICAL_DELIVERY
```

Der CH-47 flog anschließend die bereits installierte Rückroute mit weiterhin angehängtem Slingload.

### Präzisierung nach MOOSE-Quellprüfung

Die Aussage `PauseMission() beendet die CARGOTRANSPORT-Mission` ist zu grob und wird nicht als Ursache übernommen. Die gepinnte `Moose.lua` implementiert `PauseMission()` als regulären OPSGROUP-Lifecycle:

```text
mission group status -> PAUSED
current task -> TaskCancel
mission waypoints removed
mission stored as paused mission
```

`TaskDone()` besitzt einen Sonderpfad für `PAUSED` und soll die Mission in diesem Zustand gerade nicht normal abschließen. `AUFTRAG:CheckGroupsDone()` behandelt `PAUSED` nicht als `DONE` oder `CANCELLED`.

Der reale Fehler ist daher enger zu formulieren:

```text
PauseMission requested
-> PAUSED/task release expected
-> R500 route installation succeeds
-> later the AUFTRAG becomes over/done unexpectedly
-> CARGOTRANSPORT Evaluate runs while cargo is not in Wright zone
-> mission fails
```

Offen ist **welcher konkrete MOOSE-Zustandsübergang oder Callback den Übergang von PAUSED zu OVER/DONE auslöst**.

## Focus 1-3 – observation-only lifecycle diagnostics

Der nächste Bundle-Stand verändert den bewährten CAS-Pfad nicht und verändert auch den CH-47-Transportablauf nicht. Er ergänzt ausschließlich Beobachtung.

Verwendet werden öffentliche, in der gepinnten `Moose.lua` nachgewiesene Methoden:

```text
AUFTRAG:GetState()
AUFTRAG:GetGroupStatus(opsgroup)
OPSGROUP:GetMissionCurrent()
OPSGROUP:GetTaskCurrent()
OPSGROUP:PauseMission()
```

Zusätzlich werden für diesen begrenzten Diagnosezweck folgende MOOSE-Interna **nur gelesen und protokolliert**:

```text
flightGroup.currentmission
flightGroup.taskcurrent
flightGroup.pausedmissions
```

Diese Interna sind keine Produktions-API und dürfen keine Routing-, Mission- oder Ressourcenentscheidung steuern.

Zeitpunkte der Snapshots:

```text
BEFORE PauseMission
OnAfterPauseMission
AFTER PauseMission call
OnAfterTaskDone
TASK_RELEASED_BEFORE_ROUTE_INSTALL
BEFORE UpdateRoute
AFTER UpdateRoute
T+1 s after PauseMission
T+2 s after PauseMission
T+3 s after PauseMission
T+5 s after PauseMission
OnAfterMissionDone
DELIVERY_MONITOR_MISSION_IS_OVER
```

Jeder Snapshot protokolliert mindestens:

```text
AUFTRAG FSM state
AUFTRAG group status for the CH-47 FLIGHTGROUP
public current mission identity
public current task presence
internal currentmission
internal taskcurrent
pausedmissions count
whether pausedmissions still contains the target AUFTRAG
```

**Keiner dieser Werte ist ein Gate.** Kein Snapshot pausiert, beendet, repariert, unpausiert oder reroutet die Mission. Ziel des Laufs ist ausschließlich, die erste beobachtbare Zustandsänderung zwischen `PAUSED` und dem späteren `OVER/FAILED` zu identifizieren.

## OPSTRANSPORT-Prüfung

`OPSTRANSPORT` bleibt eine relevante MOOSE-Klasse, wird aber in diesem Schritt nicht blind als Ersatz eingeführt. Die gepinnte Quelle enthält `AddPathTransport()` und Warehouse-Nutzung von `OPSTRANSPORT`; gleichzeitig ist `AUFTRAG:NewOPSTRANSPORT()` im verwendeten Stand auskommentiert und der Helo-Zonentransport verwendet nicht automatisch denselben Path-Mechanismus wie der Airbase-Zweig. Ein Wechsel wäre daher eine separate Architekturentscheidung und nicht Bestandteil der Diagnose.

## Acceptance-Isolation

Das Focus-Fixture besitzt getrennte Zustände für:

```text
fatal/shared setup failure
CAS failure
RESUPPLY failure
```

Nur ein echter gemeinsamer Setup-Fehler darf beide Pfade verhindern. Ein CAS-Fehler darf den CH-47-Pfad nicht abschalten; ein CH-47-Fehler darf die AH-64-Routen-/Angriffsausführung nicht abschalten. `READY` darf nur für tatsächlich angelegte/aktive Teiltests ausgegeben werden.

## Acceptance-Dateien

```text
mission/tests/stage3-cas-resupply-focused/src/01-stage3-cas-resupply-focused-acceptance.lua
scripts/air-operations/OMW_SlingloadCorridorHandoff.lua
tools/build-stage3-cas-resupply-focused-acceptance-1.ps1
tests/mission-demand/test_focused_cas_resupply_fixture_contract.lua
```

Generiertes Bundle:

```text
mission/tests/stage3-cas-resupply-focused/dist/OMW_Stage3_CAS_Resupply_Focused_Acceptance_1.lua
```

## DCS-Acceptance

CAS ist im Focus-1-2-Lauf für den isolierten Pfad praktisch bestätigt, bleibt aber bis zum vollständigen projektkonformen Acceptance-Abschluss nicht als repository-weites `VALIDATED` markiert.

CH-47 muss weiterhin real nachweisen:

```text
CARGOTRANSPORT tatsächlich angelegt
physische Slingload-Aufnahme
MOOSE Task Release
Slingload bleibt physisch erhalten
R500 outbound
physische Ablieferung Wright
R500 reverse
Landung Jalalabad
AIRWING recovery
```

Focus 1-3 ist **kein neuer Funktionsversuch**, sondern ein Diagnose-Lauf mit identischem Transportverhalten plus Lifecycle-Telemetrie. Ein vollständiger Stage-3-Retest bleibt gesperrt, bis die CH-47-Ablieferung verstanden und anschließend funktional nachgewiesen ist.
