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

Build `1-10` hat mehrere zuvor offene Integrationsgrenzen real nachgewiesen, aber gleichzeitig neue bzw. zuvor verdeckte Fehler sichtbar gemacht. Es gibt deshalb aktuell **noch keinen freigegebenen nächsten Builderstand**.

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
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
OPSGROUP / FLIGHTGROUP mission pause/unpause lifecycle
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:SetAltitude(...)
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

## 4. QRF – Engagementmechanismus und Zusammensetzung

Build `1-10` ersetzte den vorherigen Single-Target-`GROUNDATTACK` durch:

```text
QRF materializes through Honaker BRIGADE/PLATOON
-> AUFTRAG:NewONGUARD(initial incident participant coordinate)
-> SetEngageDetected(5 NM, {"Ground Units"}, QRF tactical zone)
```

Dieser MOOSE-eigene Detection-/Engagementmechanismus bleibt grundsätzlich der bevorzugte Pfad. Die gepinnte MOOSE-Strategielogik verwendet selbst `ONGUARD` beziehungsweise `PATROLZONE` zusammen mit `SetEngageDetected(...)` für fortlaufende Bodenbekämpfung.

Der reale Build-`1-10`-Lauf erreichte `ArmyOnMission`, aber der Testcode enthielt ausschließlich Infanterie-Assets. Das widerspricht der bindenden main-Baseline für Phase-1-QRF:

```text
one infantry GROUP
+ optional independent suitable vehicle GROUP if available
-> one logical QRF response package
```

Vor dem nächsten Acceptance-Lauf muss deshalb die QRF-Zusammensetzung baseline-konform sein. Es wird **kein** eigener Target-Scanner eingeführt.

## 5. Guard – bindende Patrol-Route

Build `1-10` verwendete für die Guard:

```lua
AUFTRAG:NewONGUARD(state.guardCoord)
```

und damit **nicht** die vorhandene owner-authored Mission-Editor-Route:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01
```

Der Projektinhaber beobachtete eine Infanteriegruppe, die sich im FOB festlief. Dieser Lauf kann daher keine Guard-Patrol-Qualität validieren.

Die bindende main-Baseline verlangt aktive Guard-Patrouille auf einer owner-authored, validierten Route. MOOSE-first-Kandidat ist der im gepinnten Stand vorhandene `CONTROLLABLE:PatrolRoute()`-/GROUP-Wrapper-Pfad.

Vor dem nächsten Gesamt-Acceptance muss die Guard auf diesen baseline-konformen Pfad gebracht und separat auf Route/Pathfinding geprüft werden.

## 6. Wright ARTY und lokaler M1083-Rearm

Der reale Build-`1-10`-Lauf hat den zuvor offenen lokalen Rearm-Pfad nachgewiesen:

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

Dieser Pfad bleibt Bestandteil des End-to-End-Tests, ist aber nicht erneut als ungelöste Architekturentwicklung zu behandeln.

## 7. Strategischer Air-AMMO-Resupply

Nach real bestätigtem lokalem Rearm erreichte Build `1-10` korrekt:

```text
Wright 15 / 30
-> reorder threshold reached
-> RESUPPLY demand creation path entered
```

Der Lauf brach danach mit:

```text
RESUPPLY dedupe failed
```

ab.

Source-Review zeigt: Das ist ein Acceptance-Vergleichsfehler. `MissionDemand.Registry:Create()` gibt für `active_duplicate` eine Deep Copy des vorhandenen Demands zurück. Stage 3 prüfte fälschlich Lua-Tabellenidentität:

```lua
if duplicate ~= demand then ... end
```

Der nächste Stand muss stattdessen semantische Identität prüfen:

```text
same demand id
same dedupeKey
created == false
reason == active_duplicate
```

Erst danach kann der bereits vorgesehene MOOSE-Pfad weiterlaufen:

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

Der CH-47-/CARGOTRANSPORT-Pfad selbst ist durch den Build-`1-10`-Abbruch **nicht als FAIL nachgewiesen**, weil er nicht erreicht wurde.

Erwarteter Endbestand bleibt:

```text
Wright:     30
Jalalabad:  85
```

## 8. CASENHANCED – Allocation nachgewiesen, taktisches Profil FAIL

Build `1-10` hat erstmals die reale AH-64D-Zuweisung an den CASENHANCED-Auftrag nachgewiesen:

```text
CAS tactical area:              5 NM around Honaker
MOOSE mission:                  AUFTRAG:NewCASENHANCED
Detected-target range:          5 NM
Selected squadron:              SQ_US_JBAD_AH64D_B_1_10_AVN
Squadron skill:                 HIGH
Squadron/payload capability:    CAS + CASENHANCED
```

Damit ist die frühere Capability-/Allocation-Lücke geschlossen.

Der reale taktische Ablauf war jedoch `FAIL`:

- WEST-Höhenprofil überschoss die angeforderten 2500 ft AGL massiv;
- AH-64D kreisten ohne wirksamen Waffeneinsatz;
- zeitweise direkter Flug Richtung Jalalabad statt owner-authored Rückroute;
- anschließende Umkehr zurück Richtung Honaker;
- Lead-CFIT nach extrem steilem Sink-/Sturzflug;
- zweiter AH-64 zu tief/zu nah am Gegner und unter Infanteriefeuer;
- kein belastbares Apache-Standoff-Profil.

Der MOOSE-Audit zeigt außerdem:

```text
CASENHANCED / SetEngageDetected
-> MOOSE wählt eine erkannte qualifizierte GROUP
-> FLIGHTGROUP:EngageTarget(group)
-> generischer DCS TaskAttackGroup
-> keine Apache-spezifischen Weapon-/Direction-/Standoff-Parameter in diesem Pfad
```

Ein Wechsel von Skill oder bloßer ROE-Wertänderung ist daher **nicht** als primäre Fehlerbehebung freigegeben.

## 9. CAS Mission-Lifecycle und Corridor

Die gepinnte `FLIGHTGROUP:EngageTarget()`-Logik pausiert die aktuelle Mission:

```text
EngageTarget
-> PauseMission
-> remove MOOSE mission-owned waypoints
-> execute Engage_Target
-> task done / Disengage
-> _CheckGroupDone
-> UnpauseMission
-> MissionStart / route rebuild
```

Der aktuelle OMW-Corridor fügt dagegen zusätzliche Hin-/Rückweg-Waypoints als normale FLIGHTGROUP-Waypoints ein und markiert sie nicht mit der MOOSE-`missionUID`.

Damit sind diese OMW-Waypoints nicht lifecycle-gekoppelt an Pause/Unpause der CAS-Mission. Dieser Pfad ist vor dem nächsten Lauf neu zu ordnen.

MOOSE bietet nativ:

```lua
mission:SetMissionIngressCoord(...)
mission:SetMissionEgressCoord(...)
```

Der Egress ist laut Source/Dokumentation ausdrücklich die Koordinate, zu der die Gruppe **nach Missionsabschluss** fliegt. Dieser native Lifecycle muss vor weiterer eigener Return-Route-Logik genutzt bzw. geprüft werden.

## 10. Helicopter FlightPath – Höhen- und Offset-Grenzen

### 10.1 Höhensteuerung

Für den tatsächlich verwendeten FLIGHTGROUP-/OPSGROUP-Pfad gilt:

```text
FLIGHTGROUP:AddWaypoint altitude = feet
FLIGHTGROUP:SetAltitude altitude  = feet
```

Es gibt keinen Source-Nachweis für eine additive `2500 + 2500 + ...`-Interpretation je Wegpunkt. `FLIGHTGROUP:AddWaypoint` konvertiert den übergebenen feet-Wert einmal nach Metern und setzt für Hubschrauber im gepinnten Source `RADIO`.

Build `1-10` steuerte WEST aber doppelt:

```text
RADIO waypoint altitude 2500 ft
+
SetAltitude(2500, Keep=true, RadarAlt=true)
```

Der reale DCS-Lauf zeigte, dass damit die beabsichtigte AGL-Höhe nicht gehalten wurde. Vor dem nächsten Lauf muss es eine klar definierte, isolierte Höhenführungsquelle geben.

### 10.2 lateraler Offset

Der aktuelle Corridor-Adapter verwendet einen globalen 500-m-Rechtsoffset auch für `OMW_FlightPath_WEST`. Für das enge WEST-Tal ist dies nicht zulässig.

Zu prüfender owner-authored Namensvertrag:

```text
OMW_FlightPath_R500      -> 500 m rechts
OMW_FlightPath_WEST      -> 0 m / Centerline
OMW_FlightPath_EAST_L250 -> 250 m links
```

Regel:

```text
_R<number> am Namensende = rechts in Metern
_L<number> am Namensende = links in Metern
kein Suffix              = 0 m
```

Die bisher geprüften MOOSE-PATHLINE-/FLIGHTGROUP-/AUFTRAG-APIs besitzen keine solche automatische Namensmetadateninterpretation. Eine kleine OMW-Metadatenadaption bleibt bis zur vollständigen MOOSE-first-Prüfung und expliziten Projektentscheidung nur Kandidat, nicht freigegebene Implementierung.

## 11. Preflight-Matrix nach realem Build 1-10

```text
Alarm -> Incident                         DCS proven in existing path
Incident -> ARTY demand                  DCS proven
ARTY real fire / retarget                DCS proven
OPSZONE Defeated decoupling              DCS proven

Incident -> QRF                          DCS proven
QRF ONGUARD + SetEngageDetected          source-reviewed + ArmyOnMission proven
QRF infantry-only composition            FAIL versus binding main baseline
QRF vehicle augmentation                 pending implementation/acceptance

Guard ONGUARD at FOB                     executed but not desired baseline
Guard owner-authored PatrolRoute         pending

Incident -> CAS demand                   DCS proven
CASENHANCED construction/queue           DCS proven
AH64 capability / explicit squadron      DCS allocation proven
AH64 physical start / ingress            DCS proven
AH64 WEST altitude                       FAIL
AH64 detected-target attack profile      FAIL
AH64 mission pause/resume/RTB behavior   FAIL / lifecycle audit required
AH64 weapon employment                   not successfully proven for acceptance

ARTY depletion -> M1083 request          DCS proven
M1083 materialization                    DCS proven
ARTY real Rearmed                        DCS proven
CampaignState 16 -> 15                   DCS proven
M1083 return                             DCS proven

15 -> RESUPPLY threshold                 DCS proven
RESUPPLY dedupe acceptance gate          FAIL due test-code identity comparison
CH47 CARGOTRANSPORT                      not reached in build 1-10
cargo pickup/delivery/return             pending in combined scope
```

## 12. PASS-Kriterien

Gesamt-PASS bleibt erst erreicht, wenn im selben dokumentierten DCS-Lauf mindestens nachgewiesen ist:

```text
1. Honaker alarm / attack incident created.
2. Alarm perimeter clear does not terminate response.
3. Guard patrols its owner-authored validated route without becoming stuck.
4. QRF materializes as baseline-conformant logical response package: infantry plus suitable vehicle when available.
5. QRF reaches ArmyOnMission and can continue detected-target engagement without single-target binding.
6. All known attack-incident participants are neutralized.
7. Wright ARTY fires real coordinate missions with physical ammo decrease.
8. M1083 physically materializes and MOOSE ARTY real rearm completes.
9. CampaignState Wright AMMO changes exactly 16 -> 15 from that rearm.
10. Exactly one strategic RESUPPLY is created after semantic dedupe validation.
11. Jalalabad CH-47 and physical slingload are allocated, picked up and delivered.
12. Wright finishes at 30 and Jalalabad at 85.
13. CH-47 returns physically to Jalalabad and AIRWING recovers the asset.
14. Jalalabad AH-64D is physically allocated and uses a MOOSE-first CAS execution profile that remains terrain-safe and tactically usable.
15. AH-64D route lifecycle does not perform unexplained RTB/target-area oscillation.
16. AH-64D achieves real, correlated weapon employment without suicidal close-range/CFIT behavior.
17. CAS MissionDemand reaches SUCCESS only after valid MOOSE mission completion plus execution evidence.
18. No Lua/MOOSE runtime error invalidates the chain.
```

Bis dahin bleibt `validated_in_dcs: false`.
