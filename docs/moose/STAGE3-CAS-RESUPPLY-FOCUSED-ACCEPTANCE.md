---
document_id: OMW-MOOSE-STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - focused Stage 3 AH-64 CAS route and execution acceptance
  - focused Stage 3 CH-47 slingload route acceptance
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

### CAS

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

MOOSE erhält den Ingress über `AUFTRAG:SetMissionIngressCoord()` und den Egress über `AUFTRAG:SetMissionEgressCoord()`. Die CAS-Mission erhält das Honaker-AO-Zentrum als expliziten Orbit-/Working-Point über den `Coordinate`-Parameter von `AUFTRAG:NewCAS`. `SetMissionWaypointRandomization(0)` entfernt die sonst in `RouteToMission()` verwendete zufällige Mission-Waypoint-Abweichung.

`AUFTRAG:SetMissionWaypointCoord()` wird für den AH-64 bewusst nicht verwendet, weil die gepinnte MOOSE-Quelle die Methode als `[NON-AIR]` dokumentiert.

Für diesen Focus-Test erfolgt die Freigabe zur Rückkehr ausschließlich testbedingt 90 Sekunden nach dem ersten real bestätigten AH-64-Waffeneinsatz. Dies ist kein Produktionskriterium.

Ausdrücklich nicht zulässig als CAS-/Gefechtsabschluss:

```text
IncidentParticipants == 0
KNOWN_ATTACKERS_NEUTRALIZED
OPSZONE Defeated allein
Alarmzonen-Ausgang allein
```

`IncidentParticipants` sind höchstens Evidenz/Attribution/Targeting-Historie und keine taktische Gesamtlage.

### CH-47 Air-AMMO

Der Test behält `AUFTRAG:NewCARGOTRANSPORT` als MOOSE-Ausführer für den physischen Slingload bei.

Die gepinnte MOOSE-Quelle legt beim Konstruktor bereits die relevanten Referenzen an:

```text
cargo
cargo groupId
DropZone
DropZone zoneId
```

Der Acceptance-Kontext hält Cargo und DropZone zusätzlich explizit fest und übergibt beim Route-Handoff:

```text
cargo
cargoId = cargo:GetID()
dropZone
zoneId = dropZone.ZoneID
```

Nach physisch bestätigter Aufnahme wird über den öffentlichen MOOSE-Lifecycle `PauseMission()` die laufende CargoTransportation-Aufgabe freigegeben. Erst nach Task-Freigabe wird R500 outbound/return installiert; am Wright-seitigen Routenende wird der CargoTransportation-Task für exakt dasselbe Cargo und dieselbe DropZone erneut angesetzt. Die physische Ablieferung muss bestätigt sein, bevor die Mission als erfolgreich gilt.

## Acceptance-Dateien

```text
mission/tests/stage3-cas-resupply-focused/src/01-stage3-cas-resupply-focused-acceptance.lua
tools/build-stage3-cas-resupply-focused-acceptance-1.ps1
```

Generiertes Bundle:

```text
mission/tests/stage3-cas-resupply-focused/dist/OMW_Stage3_CAS_Resupply_Focused_Acceptance_1.lua
```

## DCS-Acceptance

CAS muss real nachweisen:

```text
AH-64 Start Jalalabad
R500
WEST
expliziter taktischer Ingress
CAS-Ausführung im Honaker-Bereich
realer Waffeneinsatz
Acceptance-Release
erklärter Egress
WEST reverse
R500 reverse
Landung Jalalabad
AIRWING recovery
```

CH-47 muss real nachweisen:

```text
physische Slingload-Aufnahme
MOOSE Task Release
R500 outbound
physische Ablieferung Wright
R500 reverse
Landung Jalalabad
AIRWING recovery
```

`VALIDATED` wird erst nach dokumentiertem realem DCS-Lauf gesetzt.
