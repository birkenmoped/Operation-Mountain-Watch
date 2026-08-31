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

Dieser Acceptance-Test ist weiterhin **PLANNED / nicht DCS-validiert**. Der letzte reale Build-`1-8`-Lauf vom 31.08.2026 war `FAIL`. Die dazugehörige Evidenz liegt in:

```text
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-08-31-EXECUTION-GAPS.md
```

Der nächste Teststand ist Builder `STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-10`. Die Änderungen nach dem realen FAIL sind bis zu einem neuen DCS-Lauf ausschließlich `SOURCE_REVIEWED` / statisch geprüft und **nicht `VALIDATED`**.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Für diesen Stand source-geprüft und direkt verwendet:

```text
OPSZONE Attacked / Defeated / Evaluated
OPSZONE:GetScannedGroupSet()
AUFTRAG:NewONGUARD(...)
AUFTRAG:SetEngageDetected(...)
AUFTRAG:NewCASENHANCED(...)
AUFTRAG:AssignSquadrons(...)
AUFTRAG:NewCARGOTRANSPORT(...)
ARTY:New / AssignTargetCoord / GetAmmo / Rearm lifecycle
EVENTHANDLER / EVENTS.Shot
FLIGHTGROUP waypoint callbacks
COORDINATE:GetLandHeight()
OPSGROUP:GetCoordinate(...)
UTILS.MetersToFeet(...)
```

MOOSE verwendet selbst im strategischen Dispatcher `ONGUARD` beziehungsweise `PATROLZONE` zusammen mit `SetEngageDetected(...)`, um erkannte Ziele fortlaufend zu bekämpfen. Der Stage-3-QRF-Pfad nutzt deshalb keinen eigenen Search-and-Destroy-Scanner.

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

## 4. QRF – dynamische MOOSE-Bodenbekämpfung

Build `1-8` verwendete pro QRF-Gruppe `AUFTRAG:NewGROUNDATTACK(Target)`. Dieser Auftrag war an genau ein RED-Zielobjekt gekoppelt. Bei gleichzeitigem ARTY-/CAS-Einsatz konnte dieses Ziel sterben, bevor die QRF taktischen Kontakt erreichte.

Build `1-10` verwendet deshalb den MOOSE-eigenen Detection-/Engagement-Pfad:

```text
QRF materializes through Honaker BRIGADE/PLATOON
-> AUFTRAG:NewONGUARD(initial incident participant coordinate)
-> SetEngageDetected(5 NM, {"Ground Units"}, QRF tactical zone)
-> MOOSE detection remains active
-> detected RED A may be engaged
-> if A is destroyed, detected RED B can still be engaged
```

Acceptance-only QRF-Konfiguration dieses Teststands:

```text
QRF tactical zone radius:       5 NM around Honaker
QRF detected-target range:      5 NM
QRF mission capability:         AUFTRAG.Type.ONGUARD
```

Die 5-NM-QRF-Zone ist **keine projektweite QRF-Doktrin** und ersetzt nicht die 1000-m-Alarmzone. Sie dient in diesem kombinierten Test ausschließlich als begrenzter taktischer Einsatzraum.

Für den Gesamt-PASS wird die physische `ArmyOnMission`-Materialisierung der QRF verlangt. `EngageTarget` wird zusätzlich protokolliert, ist aber kein zwingender PASS-Gate: ARTY oder CAS dürfen die Angreifer bereits neutralisiert haben, bevor die QRF schießt. Die Incident-Neutralisierung bleibt separat zwingend.

## 5. Wright ARTY und lokaler M1083-Rearm

ARTY bleibt incident-basiert:

```text
living known incident participant
-> fresh GROUP coordinate
-> 4-round coordinate fire mission
-> physical ARTY ammo decrease required
-> reacquire living participants
-> repeat independently of OPSZONE Defeated
```

Strategische Testvorbedingung:

```text
Wright GROUND_AMMO_PACKAGE: 30 -> 16
```

Nach dem realen `1-8`-FAIL wurde die lokale M1083-Materialisierung korrigiert. Der dedizierte Wright-Support-`BRIGADE` wird nun **nach** vollständiger PLATOON-/Materializer-Registrierung gestartet, bevor später ein Self-Request erfolgen kann:

```text
register materializer / PLATOON
-> BRIGADE:Start()
-> ARTY depletion
-> M1083 self-request
-> physical M1083 materialization
-> MOOSE ARTY Rearm
```

Die CampaignState-Abbuchung erfolgt weiterhin erst am realen MOOSE-Rearm-Lifecycle:

```text
MOOSE OnBeforeRearm accepted
-> CampaignState Consume 1 package
-> Wright 16 -> 15

MOOSE OnAfterRearmed
-> CompleteConsumption
```

Kein M1083 / kein real akzeptierter Rearm -> keine strategische Abbuchung -> kein strategischer RESUPPLY.

## 6. Strategischer Air-AMMO-Resupply

Nach real bestätigtem lokalem Rearm:

```text
Wright 15 / 30
-> reorder threshold reached
-> exactly one MissionDemand RESUPPLY
-> reserve 15 GROUND_AMMO_PACKAGE at Jalalabad
-> physical ammo_cargo slingload
-> AUFTRAG:NewCARGOTRANSPORT
-> AssignSquadrons({SQ_US_JBAD_CH47_HEAVYLIFT})
-> CH-47 pickup
-> OMW_FlightPath outbound
-> physical delivery at Wright
-> OMW_FlightPath return
-> Jalalabad landing / AIRWING asset return
```

Erwarteter Endbestand:

```text
Wright:     30
Jalalabad:  85
```

## 7. CASENHANCED – Capability und explizite Squadron-Bindung

Acceptance-Konfiguration:

```text
CAS tactical area:              5 NM around Honaker
AH-64 combat height:            Honaker terrain + 2500 ft
MOOSE mission:                  AUFTRAG:NewCASENHANCED
Detected-target range:          5 NM
Selected squadron:              SQ_US_JBAD_AH64D_B_1_10_AVN
```

Der reale Build-`1-8`-Lauf erzeugte und queue-te einen CASENHANCED-AUFTRAG, aber der damals geladene Jalalabad-Bootstrap bot für die AH-64-SQUADRON und deren Payload nur `AUFTRAG.Type.CAS`. Deshalb konnte AIRWING keinen passenden CASENHANCED-Pool zuweisen.

Der aktuelle Jalalabad-Bootstrap registriert jetzt sowohl Squadron als auch Payload für:

```lua
{
  AUFTRAG.Type.CAS,
  AUFTRAG.Type.CASENHANCED,
}
```

Zusätzlich bindet Stage 3 den CAS-Auftrag explizit über die source-geprüfte MOOSE-API:

```lua
mission:AssignSquadrons({ state.ah64d })
```

Damit ist die gewünschte Organisationsauswahl nicht mehr nur indirektes AIRWING-Payload-Matching.

Wichtig: Der Jalalabad-AirOps-Bootstrap ist **nicht** Bestandteil des Stage-3-Einzelbundles. Für den nächsten DCS-Test müssen daher beide generierten Lua-Dateien neu gebaut und in der Mission aktualisiert werden:

```text
mission/tests/jalalabad-air-operations/dist/OMW_AirOps_Jalalabad.lua
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

Ein `EVENTS.Shot` ist nur Ausführungsevidenz. MissionDemand wird erst nach MOOSE-AUFTRAG-Erfolg plus vorhandener Shot-Evidenz erfolgreich abgeschlossen.

## 8. Helicopter FlightPath

CAS nutzt weiterhin:

```text
OMW_FlightPath       -> 500 ft AGL
OMW_FlightPath_WEST  -> 2500 ft AGL, RADIO, Keep=true, RotaryWing.Column.D70
```

`OnAfterPassingWaypoint` protokolliert eventgebunden:

```text
pathline
requested AGL
actual AGL
actual ASL
terrain height
```

Kein Frame-Scan und kein hochfrequenter Zusatzscheduler.

Der Air-AMMO-CH-47 nutzt `OMW_FlightPath` für Hin- und Rückweg.

## 9. Guard-Grenze dieses Laufs

Die projektweite Guard-Baseline bevorzugt owner-authored Patrol Routes. In der aktuellen Mission existiert unter anderem:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01
```

Diese Guard-Patrol-Qualitätsverbesserung wird **nicht zusätzlich in Build 1-10 aufgenommen**, damit der nächste Lauf ausschließlich die nach dem `1-8`-FAIL identifizierten Integrationsgrenzen CAS, QRF und Rearm/Resupply prüft. Der bestehende Guard-Pfad bleibt für diesen Kernlauf unverändert; die Route wird nach erfolgreichem Stage-3-Kernabschluss integriert.

## 10. Preflight-Matrix vor dem nächsten DCS-Lauf

```text
Alarm -> Incident                         MOOSE/source + vorhandener DCS-PASS
Incident -> ARTY demand                  vorhandener DCS-PASS
ARTY real fire / retarget                vorhandener DCS-PASS
OPSZONE Defeated decoupling              vorhandener DCS-PASS

Incident -> QRF                          vorhandener Request-/Spawn-Nachweis
QRF mission type                         NewONGUARD source-reviewed
QRF continuing detection                 SetEngageDetected source-reviewed
QRF physical deployment                  DCS pending

Incident -> CAS demand                   vorhandener DCS-PASS
CASENHANCED construction/queue           vorhandener DCS-PASS
AH64 Squadron capability CASENHANCED     static checked
AH64 Payload capability CASENHANCED      static checked
AH64 explicit AssignSquadrons            source-reviewed + contract test
AH64 physical allocation/start           DCS pending

ARTY depletion -> M1083 request          vorhandener DCS-PASS
M1083 materializer registered            static checked
M1083 dedicated BRIGADE started          static checked + contract test
M1083 materialization                    DCS pending
ARTY real Rearmed                        DCS pending
CampaignState 16 -> 15                   coupled to Rearm evidence; DCS pending

15 -> one RESUPPLY demand                existing policy/logic path
CH47 CARGOTRANSPORT capability           static checked
CH47 AssignSquadrons                     source-reviewed / existing accepted pattern
cargo pickup/delivery/return             DCS pending in this combined scope
```

## 11. PASS-Kriterien

Gesamt-PASS erst wenn im selben dokumentierten DCS-Lauf mindestens nachgewiesen ist:

```text
1. Honaker alarm / attack incident created.
2. Alarm perimeter clear does not terminate response.
3. QRF physically reaches ArmyOnMission under ONGUARD + SetEngageDetected.
4. All known attack-incident participants are neutralized.
5. Wright ARTY fires real coordinate missions with physical ammo decrease.
6. M1083 physically materializes and MOOSE ARTY real rearm completes.
7. CampaignState Wright AMMO changes exactly 16 -> 15 from that rearm.
8. Exactly one strategic RESUPPLY is created.
9. Jalalabad CH-47 and physical slingload are allocated, picked up and delivered.
10. Wright finishes at 30 and Jalalabad at 85.
11. CH-47 returns physically to Jalalabad and AIRWING recovers the asset.
12. Jalalabad AH-64D is physically allocated to CASENHANCED, flies the route and employs a weapon.
13. CAS MissionDemand reaches SUCCESS only after MOOSE mission success plus weapon evidence.
14. No Lua/MOOSE runtime error invalidates the chain.
```

Bis dahin bleibt `validated_in_dcs: false`.
