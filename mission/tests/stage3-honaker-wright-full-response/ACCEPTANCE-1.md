---
document_id: OMW-TEST-STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 combined Honaker attack, local response, Wright fire support, local rearm and strategic Air-AMMO closure acceptance contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 Acceptance 1 – Honaker -> Wright -> Jalalabad Air-AMMO

## 1. Status

Dieser Acceptance-Test bleibt **PLANNED / nicht DCS-validiert**.

Der reale Build-`1-10`-Lauf vom 31.08./01.09.2026 war `FAIL`. Die aktuelle Evidenz liegt in:

```text
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-09-01-CAS-QRF-RESUPPLY.md
```

Die vorherige Build-`1-8`-Evidenz bleibt historisch erhalten in:

```text
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-08-31-EXECUTION-GAPS.md
```

Der nach Build `1-10` durchgeführte MOOSE-Source-Audit liegt in:

```text
docs/moose/STAGE3-CAS-GUARD-QRF-ROUTING-AUDIT.md
```

Der nächste Builderstand ist jetzt als **Build `1-11`** vorbereitet. Er enthält die nach dem `1-10`-FAIL freigegebenen Korrekturen, ist aber noch nicht lokal gebaut und nicht in DCS getestet. Deshalb bleibt `validated_in_dcs: false`.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Für Build `1-11` source-geprüft und direkt verwendet:

```text
OPSZONE Attacked / Defeated / Evaluated
OPSZONE:GetScannedGroupSet()
AUFTRAG:NewONGUARD(...)
AUFTRAG:SetEngageDetected(...)
AUFTRAG:AssignCohort(...)
AUFTRAG:NewPATROLZONE(...)
AUFTRAG:AssignSquadrons(...)
AUFTRAG:NewCARGOTRANSPORT(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG mission-owned waypoint lifecycle / missionUID
OPSGROUP / FLIGHTGROUP mission pause/unpause lifecycle
FLIGHTGROUP:AddWaypoint(...)
CONTROLLABLE:PatrolRoute()
ARTY:New / AssignTargetCoord / GetAmmo / Rearm lifecycle
EVENTHANDLER / EVENTS.Shot
COORDINATE:GetLandHeight()
UTILS.MetersToFeet(...)
```

## 3. Alarm und Attack Incident

Die 1000-m-OPSZONE ist ausschließlich Alarm-/Evidence-Grenze:

```text
RED enters 1000-m alarm perimeter
-> OPSZONE Attacked
-> PROXIMITY_INTRUSION
-> one Honaker attack incident
```

Weitere `OPSZONE Evaluated`-Zyklen ergänzen neu erkannte RED-Gruppen als Incident-Teilnehmer. Ein späteres `OPSZONE Defeated` setzt nur `perimeterClear=true`; lebende bekannte Angreifer bleiben Incident-Teilnehmer und dürfen weiterhin durch QRF, ARTY und CAS bekämpft werden.

Acceptance-Closure:

```text
no living known attack participant remains
-> Close("KNOWN_ATTACKERS_NEUTRALIZED")
```

Diese Alarm-/Incident-Trennung ist im bisherigen DCS-Testpfad nachgewiesen und wird nicht erneut als offene Architekturfrage behandelt.

## 4. QRF – Build 1-11

Build `1-10` hatte den Single-Target-`GROUNDATTACK` bereits durch den MOOSE-eigenen fortlaufenden Engagementpfad ersetzt:

```text
AUFTRAG:NewONGUARD(initial incident participant coordinate)
-> SetEngageDetected(5 NM, {"Ground Units"}, QRF tactical zone)
```

Build `1-11` bringt zusätzlich die Zusammensetzung auf die bindende Phase-1-Baseline:

```text
1 x TPL_BLUE_GND_INF_RIFLE_SQUAD_9
+
1 x TPL_BLUE_GND_QRF_MIXED_4
-> one logical QRF response package
```

Beide Teilgruppen erhalten einen eigenen `ONGUARD + SetEngageDetected`-Auftrag gegen dieselbe Incident-/Tactical-Area-Sicht. Damit MOOSE nicht aus dem gesamten BRIGADE-Pool rekrutiert, ist jeder Auftrag ausdrücklich an den zuständigen `PLATOON` gebunden:

```lua
mission:AssignCohort(platoon)
```

Damit gilt für den Acceptance-Pfad:

```text
INFANTRY mission -> PLT_BLUE_GND_HONAKER_STAGE3_QRF_INF only
VEHICLE mission  -> PLT_BLUE_GND_HONAKER_STAGE3_QRF_VEHICLE only
```

Es wird kein eigener Target-Scanner eingeführt. `ArmyOnMission` beider Teilgruppen ist PASS-Voraussetzung; tatsächliches `EngageTarget` bleibt Telemetrie, weil ARTY oder CAS die Angreifer vorher neutralisieren können.

## 5. Guard – owner-authored PatrolRoute

Build `1-10` verwendete eine stationäre `ONGUARD`-Mission und testete damit die bindende Guard-Baseline nicht.

Build `1-11` verwendet stattdessen die vorhandene owner-authored Mission-Editor-Gruppe:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01
```

und startet die wiederholte Patrouille mit dem gepinnten MOOSE-Weg:

```lua
state.guardGroup:PatrolRoute()
```

Der nächste DCS-Lauf muss bestätigen, dass diese konkrete Afghanistan-Route ohne Festlaufen abgefahren wird. Bis dahin ist die Guard-Route nicht `VALIDATED`.

## 6. Wright ARTY und lokaler M1083-Rearm

Der reale Build-`1-10`-Lauf hat folgenden Pfad bereits nachgewiesen:

```text
Wright ARTY real fire / retarget
-> physical ammo decrease
-> local M1083 request
-> M1083 materialization
-> MOOSE ARTY rearm
-> CampaignState Wright 16 -> 15
-> M1083 return to Warehouse stock
-> reorder threshold 15 / 30 reached
```

Dieser Pfad bleibt unverändert Bestandteil des End-to-End-Tests.

## 7. Strategischer Air-AMMO-Resupply und Dedupe

Build `1-10` brach nach Erreichen des Reorder-Schwellwerts mit `RESUPPLY dedupe failed` ab. Source-Review zeigte einen Acceptance-Vergleichsfehler: `MissionDemand.Registry:Create()` liefert bei `active_duplicate` eine Deep Copy des vorhandenen Demands zurück.

Build `1-11` prüft deshalb ausschließlich semantische Identität:

```text
duplicate.id == demand.id
duplicate.dedupeKey == demand.dedupeKey
created == false
reason == active_duplicate
```

Der fehlerhafte Lua-Tabellenidentitätsvergleich ist entfernt.

Danach soll der vorhandene MOOSE-Pfad erstmals im kombinierten Test erreicht werden:

```text
reserve 15 GROUND_AMMO_PACKAGE at Jalalabad
-> physical ammo_cargo slingload
-> AUFTRAG:NewCARGOTRANSPORT
-> AssignSquadrons({SQ_US_JBAD_CH47_HEAVYLIFT})
-> CH-47 pickup
-> owner-authored corridor
-> Wright delivery
-> Jalalabad return / AIRWING asset recovery
```

Erwarteter Endbestand:

```text
Wright:     30
Jalalabad:  85
```

Der CH-47-/CARGOTRANSPORT-Pfad war in Build `1-10` nicht erreicht worden und bleibt im Gesamtverbund DCS-pending.

## 8. CAS – PATROLZONE + SetEngageDetected statt CASENHANCED

Build `1-10` hat die AH-64D-Allokation an `NewCASENHANCED` nachgewiesen, aber das resultierende taktische Profil war unbrauchbar: instabile Höhenführung, kein belastbarer Waffeneinsatz, Route-/Lifecycle-Oszillation und CFIT-/Nahbereichsrisiko.

Der Source-Audit ergab außerdem, dass `CASENHANCED`/`SetEngageDetected` für den tatsächlichen Engagementpfad auf generisches `FLIGHTGROUP:EngageTarget(group)` bzw. DCS `TaskAttackGroup` hinausläuft; ein Apache-spezifisches Hellfire-/Standoff-Profil wird dadurch nicht garantiert.

Für die gewünschte **CAS-Bereitschaft im Einsatzraum** verwendet Build `1-11` daher das offizielle MOOSE-Muster:

```lua
local mission = AUFTRAG:NewPATROLZONE(zone, speedKts, altitudeFtAsl)
mission:SetEngageDetected(rangeNm, { "Ground Units" }, zone, nil)
```

Der Jalalabad-AH-64D-SQUADRON-/Payload-Pfad enthält dafür zusätzlich `AUFTRAG.Type.PATROLZONE` als Capability.

`PATROLZONE + SetEngageDetected` wird als Bereitschafts-/Loiter-Mission bewertet. Ob die daraus entstehenden DCS-Angriffsaufgaben mit der AH-64D taktisch ausreichend funktionieren, muss der nächste DCS-Lauf zeigen. Ein positives Ergebnis wird nicht aus dem Source-Review abgeleitet.

## 9. CAS Mission-Lifecycle und owner-authored Corridor

Der gepinnte MOOSE-Lifecycle pausiert eine aktuelle Mission während `EngageTarget`, entfernt mission-owned Waypoints und baut die Missionsroute beim Unpause/MissionStart wieder auf.

Build `1-11` ordnet den OMW-Corridor deshalb neu:

```text
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
-> native MOOSE mission lifecycle anchors

owner-authored PATHLINE geometry
-> only small OMW adapter
-> every injected FLIGHTGROUP waypoint gets missionUID = mission.auftragsnummer
-> MOOSE removes it during PauseMission
-> adapter rebinds after MOOSE route rebuild
```

Der Adapter ist:

```text
scripts/air-operations/OMW_HelicopterMissionOwnedCorridor.lua
Schema: OMW-HELICOPTER-MISSION-OWNED-CORRIDOR-2
```

Er ersetzt weder AUFTRAG noch Mission-Pause/Resume noch RTB-Logik. Die DCS-Verifikation muss zeigen, dass nach einem Engage/Disengage kein direkter unbeabsichtigter RTB-/Honaker-Oszillationspfad mehr entsteht.

## 10. Helicopter FlightPath – Höhen- und Offset-Vertrag

### 10.1 Höhensteuerung

Build `1-10` kombinierte RADIO-Waypoint-Höhen mit zusätzlichen `FLIGHTGROUP:SetAltitude(..., Keep=true, RadarAlt=true)`-Profilwechseln. Diese Doppelsteuerung hat im realen DCS-Lauf keine stabile 2500-ft-AGL-Führung erzeugt.

Build `1-11` entfernt deshalb den Stage-3-`SetAltitude()`-Override. Die CAS-Höhenführung wird auf genau einen Pfad reduziert:

```text
MOOSE PATROLZONE mission altitude
+
MOOSE FLIGHTGROUP:AddWaypoint altitude for the owner-authored corridor
```

Die corridor waypoints werden bei Hubschraubern durch den gepinnten MOOSE-Stand als `RADIO` angelegt. Es gibt keinen zusätzlichen persistenten Stage-3-`SetAltitude()`-Befehl.

Der nächste DCS-Lauf muss die tatsächliche AGL-/ASL-Telemetrie verifizieren. Die Syntax-/Einheitenprüfung ist kein DCS-PASS.

### 10.2 owner-approved segmentbezogene Offsets

Der Projektinhaber hat die segmentbezogene Offset-Metadatenlösung ausdrücklich freigegeben.

Verbindlicher OMW-Namensvertrag für diesen Adapter:

```text
_R<number> am Namensende = rechts in Metern relativ zur Flugrichtung
_L<number> am Namensende = links in Metern relativ zur Flugrichtung
kein Suffix              = 0 m / Centerline
```

Beispiele:

```text
OMW_FlightPath_R500      -> +500 m rechts
OMW_FlightPath_WEST      -> 0 m / Centerline
OMW_FlightPath_EAST_L250 -> -250 m / links
```

Die MOOSE-Prüfung hat keine native PATHLINE-Namensmetadatenfunktion ergeben. Daher ist der kleine Parser/Offset-Adapter als genehmigte OMW-Erweiterung zulässig.

Für Stage 3 ist vor dem DCS-Lauf erforderlich:

```text
Mission Editor:
OMW_FlightPath -> OMW_FlightPath_R500
OMW_FlightPath_WEST bleibt unverändert
```

Die `.miz` wird durch den Builder nicht mutiert.

## 11. Build-1-11-Preflight

```text
Alarm -> Incident                         previously DCS proven
Incident -> ARTY demand                  previously DCS proven
ARTY real fire / retarget                previously DCS proven
OPSZONE Defeated decoupling              previously DCS proven

Guard owner-authored PatrolRoute         implemented / DCS pending

QRF ONGUARD + SetEngageDetected          source-reviewed / prior ArmyOnMission evidence
QRF infantry + vehicle package           implemented / DCS pending
QRF per-role AssignCohort binding        implemented / source gate enabled

Incident -> CAS demand                   previously DCS proven
PATROLZONE + SetEngageDetected CAS        implemented / DCS pending
AH64 PATROLZONE capability               implemented / DCS pending
native mission ingress/egress            implemented / DCS pending
missionUID-owned corridor rebind         implemented / DCS pending
single altitude-control path             implemented / DCS pending
_R/_L/no-suffix offset contract          owner-approved + implemented / DCS pending
AH64 weapon employment                   DCS pending

ARTY depletion -> M1083 request          previously DCS proven
M1083 materialization                    previously DCS proven
ARTY real Rearmed                        previously DCS proven
CampaignState 16 -> 15                   previously DCS proven
M1083 return                             previously DCS proven

15 -> RESUPPLY threshold                 previously DCS proven
RESUPPLY semantic dedupe gate            corrected / DCS pending
CH47 CARGOTRANSPORT                      combined-path DCS pending
cargo pickup/delivery/return             combined-path DCS pending
```

## 12. PASS-Kriterien

Gesamt-PASS bleibt erst erreicht, wenn im selben dokumentierten DCS-Lauf mindestens nachgewiesen ist:

```text
1. Honaker alarm / attack incident created.
2. Alarm perimeter clear does not terminate response.
3. Guard patrols OMW_RTE_BLUE_GUARD_HONAKER_01 without becoming stuck.
4. QRF materializes as one infantry GROUP plus one suitable vehicle GROUP.
5. Each QRF mission is recruited from its explicitly assigned PLATOON and both reach ArmyOnMission.
6. QRF can continue detected-target engagement without single-target binding.
7. All known attack-incident participants are neutralized.
8. Wright ARTY fires real coordinate missions with physical ammo decrease.
9. M1083 physically materializes and MOOSE ARTY real rearm completes.
10. CampaignState Wright AMMO changes exactly 16 -> 15 from that rearm.
11. Exactly one strategic RESUPPLY remains after semantic dedupe validation.
12. Jalalabad CH-47 and physical slingload are allocated, picked up and delivered.
13. Wright finishes at 30 and Jalalabad at 85.
14. CH-47 returns physically to Jalalabad and AIRWING recovers the asset.
15. Jalalabad AH-64D is physically allocated to PATROLZONE + SetEngageDetected readiness.
16. Native MOOSE ingress/egress plus mission-owned owner-authored corridor survive EngageTarget pause/resume without route oscillation.
17. Requested corridor altitude profile remains terrain-safe and tactically usable in real DCS telemetry.
18. AH-64D achieves real correlated weapon employment without suicidal close-range/CFIT behavior.
19. CAS MissionDemand reaches SUCCESS only after attack-incident tactical completion plus real execution evidence and explicit MOOSE mission closure.
20. No Lua/MOOSE runtime error invalidates the chain.
```

Bis dahin bleibt `validated_in_dcs: false`.
