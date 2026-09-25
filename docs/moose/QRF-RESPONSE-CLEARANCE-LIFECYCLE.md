---
document_id: OMW-MOOSE-QRF-RESPONSE-CLEARANCE-LIFECYCLE
status: BINDING
document_class: MOOSE_INTEGRATION_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-approved local Ground QRF target-engagement lifecycle
  - MOOSE API/source evidence for direct QRF target pursuit and return
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# QRF Direct Target Engagement Lifecycle

## Entscheidung

Der Projektinhaber hat am 13.09.2026 nach Abgleich mit dem historischen Honaker-Full-Response-Test den lokalen Ground-QRF-Vertrag praezisiert.

`AUFTRAG:NewONGUARD(initial threat coordinate)` bleibt der MOOSE-Rekrutierungs-/Materialisierungsanker. Nach `BRIGADE:ArmyOnMission` wird dieselbe physische `ARMYGROUP` jedoch unmittelbar an das naechste konkrete lebende Incident-`UNIT` innerhalb der site-local 5-NM-Tactical-Zone gebunden:

```text
installation attack
-> QRF demand
-> ACCESS materialization
-> ONGUARD recruitment anchor
-> same ARMYGROUP
-> nearest living known incident UNIT
-> ARMYGROUP:EngageTarget(UNIT)
-> MOOSE tracks moving target
-> target dead -> Disengage
-> acquire next living incident UNIT
-> repeat
-> no living authorized incident UNIT remains
-> mission Cancel/completion
-> MOOSE ReturnToLegion / RTZ / Returned / Warehouse
```

Der vorherige `PATROLZONE + HuntingPatrol`-Entwurf ist fuer diesen QRF-Vertrag verworfen. Im realen Joyce-A4-Lauf fuhr die QRF nach unpassender/veralteter Einsatzgeometrie und blieb im Gelaende gebunden, waehrend RED weiter Richtung FOB lief. Dies ist negative DCS-Evidenz und kein PASS.

## Honaker-Reconciliation

Der historische Honaker-Test enthielt bereits die wesentlichen fachlichen Regeln:

```text
known attack participants
-> living participants prioritized by distance
-> QRF remains committed while known attackers live
-> known attackers neutralized
-> ReturnToLegion recovery
```

Damals wurde fuer die QRF `NewONGUARD(target:GetCoordinate()) + SetEngageDetected(...)` verwendet; das konkrete bewegliche Target war noch nicht direkt gebunden. Die aktuelle Aenderung schliesst genau diese Luecke und veraendert weder ACCESS noch Warehouse-/CampaignState-Autoritaet.

## MOOSE-First-Nachweis

Gepruefter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Gepruefte MOOSE-Mechanismen:

```text
BRIGADE:ArmyOnMission / OnAfterArmyOnMission
ARMYGROUP:EngageTarget(Target, Speed, Formation)
ARMYGROUP:OnAfterDisengage
ARMYGROUP:RTZ / Returned
AUFTRAG:NewONGUARD(...)
AUFTRAG:SetReturnToLegion(true)
AUFTRAG:Cancel()
```

`EngageTarget` akzeptiert unter anderem `UNIT`, speichert das Target als MOOSE `TARGET`, schaltet ROE/Alarm fuer das Engagement und setzt einen Engagement-Waypoint. `_UpdateEngageTarget()` liest die aktuelle Target-Position erneut ein und aktualisiert den Wegpunkt, wenn sich das Ziel mehr als 100 m bewegt hat oder keine LOS besteht. Ist das Target tot beziehungsweise nicht mehr aufloesbar, folgt `Disengage`.

OMW nutzt diesen vorhandenen MOOSE-Pfad und implementiert weder eigene Moving-Target-Waypoints noch einen Target-Scheduler.

## Zielautoritaet

Die Zielmenge stammt ausschliesslich aus dem bereits vorhandenen Installation-Attack-Incident:

```text
OMW_GroundInstallationAttackIncident:GetParticipants(true)
-> living incident GROUPs
-> living UNITs dieser GROUPs
-> aktuelle UNIT-Koordinate innerhalb site-local 5-NM tactical zone
-> naechstes UNIT relativ zur aktuellen QRF-Position
```

Der Incident-Coordinator wird ueber `OMW_FireSupStratResupply_InstallationIncidentBridge.lua` in den Base-Incident-Kontext weitergereicht. Bei Incident-Updates bleibt dieselbe Coordinator-Instanz erhalten und fuehrt ihren Teilnehmerbestand fort.

Dies ist keine neue Detection- oder World-Scan-Autoritaet.

## Ereignisgesteuerter Target-Cycle

Sobald MOOSE die QRF ueber `BRIGADE:ArmyOnMission` als physische `ARMYGROUP` bereitstellt, startet die direkte Zielbindung. Nach MOOSE `Disengage` wird erneut aus dem lebenden Incident-Teilnehmerbestand gewaehlt.

```text
ArmyOnMission
-> acquire nearest valid UNIT
-> EngageTarget
-> MOOSE pursuit
-> Disengage because target dead
-> acquire next UNIT
```

Es gibt keinen OMW-Scheduler fuer diese Kette.

Wenn keine lebende autorisierte Incident-Unit in der Tactical-Zone mehr vorhanden ist, ist der taktische QRF-Auftrag erfuellt. Die AUFTRAG-Mission wird beendet/abgebrochen und `SetReturnToLegion(true)` laesst MOOSE den bestehenden RTZ-/Returned-/Warehouse-Lifecycle ausfuehren.

## Abgrenzung der Return Authority

Zulaessige automatische Completion:

```text
zero living authorized incident UNITs inside the site-local tactical zone
```

Nicht gleichbedeutend damit und allein nicht ausreichend:

```text
perimeter clear
incident close
no DCS/MOOSE detection
elapsed timer
movement >= N m
```

Eine externe ausdrueckliche C2-Freigabe darf weiterhin den Demand-Lifecycle abbrechen; Acceptance 4 verwendet sie jedoch nicht als Ersatz fuer die produktive Target-Completion.

## Unveraenderte Verträge

```text
CampaignState = strategische Ressourcenautoritaet
MOOSE = operative Mission-/Gruppen-/Lifecycle-Autoritaet
QRF materialization/home = site-local ACCESS-Zone
Road alignment = OMW_GroundRoadSpawnAdapter.lua
initial physical incident coordinate = nur Road-Forward-Richtung fuer Materialisierung
kein PATROL_TEST
kein GROUNDATTACK
kein PATROLZONE/HuntingPatrol fuer QRF target execution
kein zusaetzlicher Mission-Editor-Bereich
```

## Status

```text
Owner decision: APPROVED
Honaker reconciliation: COMPLETE
MOOSE pinned-source review: SOURCE_REVIEWED
PATROLZONE/HuntingPatrol QRF design: DCS_REJECTED
Direct EngageTarget target cycle: STAGED
Acceptance 4: STAGED
DCS runtime validation: OPEN
```
