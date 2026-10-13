---
document_id: OMW-FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX
status: BINDING
document_class: IMPLEMENTATION_GUARDRAIL
owning_policy: OMW-GOV-001
authoritative_for:
  - reuse gate before Fire Support / Strategic Resupply implementation changes
  - accepted implementation references for local Ground QRF integration
  - anti-regression rules for Acceptance code
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# Fire Support / Strategic Resupply – Accepted Implementation Matrix

## Reuse-Gate

Vor Änderungen an bereits vorhandenem Verhalten ist verpflichtend zu klären:

```text
1. Existiert das Verhalten bereits?
2. Gibt es DCS-Evidenz / Acceptance?
3. Welche Datei implementiert es?
4. Welche Acceptance belegt es?
5. Welche Semantik ist bindend?
6. Was ist wirklich neu?
7. Welche Implementierung wird wiederverwendet?
8. Welche neue Logik bleibt unvermeidbar?
```

Wenn vorhandene Lösung/Evidenz existiert:

```text
NO REIMPLEMENTATION
NO UNAPPROVED SEMANTIC VARIATION
NO UNAPPROVED ALTERNATE MOOSE MISSION/LIFECYCLE
NO ACCEPTANCE SHORTCUT
```

## Accepted Implementation Matrix

| Bereich | Referenz | Verbindliche Semantik |
|---|---|---|
| Alarm | `ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION.md` | Alarmzone = Detection/Response-Trigger, nicht WEZ/Battlespace/Mission-Ende. |
| QRF Recruitment | Honaker Full-Response + Owner decision 2026-09-13 | `AUFTRAG:NewONGUARD(initial threat coordinate)` bleibt MOOSE-Rekrutierungs-/Materialisierungsanker; kein `GROUNDATTACK`. |
| QRF Target Authority | `OMW_GroundInstallationAttackIncident.lua` | Bekannte Angreifer stammen aus dem autoritativen Incident-Teilnehmerbestand `GetParticipants(true)`; keine zweite World-Scan-Autoritaet. |
| QRF Tactical Area | Honaker Full-Response | 5 NM site-local tactical zone; nur lebende Incident-`UNIT`s innerhalb dieser Zone sind QRF-Ziele. |
| QRF Engagement | Owner decision 2026-09-13 + pinned MOOSE source review | Dieselbe physische `ARMYGROUP` greift das naechste lebende Incident-`UNIT` mit `ARMYGROUP:EngageTarget()` an. MOOSE verfolgt dessen aktuelle Position. |
| QRF Movement | Owner decision 2026-09-13 + pinned MOOSE source review + A4-6 negative evidence | Motorisierte QRF verwendet auf dem Marsch `EngageTarget(..., "On Road")`. Sowohl MissionFactory-Default als auch Composition/Runtime muessen `On Road` erhalten; Runtime darf dies nicht mit `Vee` ueberschreiben. MOOSE besitzt Strassenrouting und finalen Off-Road-Anflug. |
| QRF Retarget | Pinned MOOSE `Disengage` lifecycle | Ziel tot -> MOOSE `Disengage` -> ereignisgetriebene Neuauswahl des naechsten lebenden Incident-Ziels. Kein OMW-Target-Scheduler. |
| QRF Return | Owner decision 2026-09-13 | Wenn kein lebendes autorisiertes Incident-Ziel in der Tactical-Zone verbleibt, wird die QRF-Mission beendet und `SetReturnToLegion(true)` / RTZ / Returned verwendet. Perimeter-Clear oder Incident-Close allein reichen nicht. |
| ACCESS | `ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT.md` | `ZON_BLUE_GND_XXX_ACCESS` ist Materialisierungs-/Departure-/Return-/Handoff-Grenze. |
| Road-aligned materialization | `OMW_GroundRoadSpawnAdapter.lua` | Nur Spawngeometrie wird angepasst; MOOSE besitzt BRIGADE/WAREHOUSE/PLATOON/ARMYGROUP/AUFTRAG. ACCESS validiert den Road-/Materialisierungsanker; einzelne Fahrzeuge der ausgerichteten Formation duerfen ausserhalb ACCESS liegen. |
| Resources | CampaignState / Ground Foundation | CampaignState bleibt strategische Autorität. |

## ARTY-Reuse-Gate – Reconciliation 22.09.2026

| Bereich | Referenz | Verbindliche Semantik |
|---|---|---|
| Functional ARTY fire owner | `OMW_FobAttackFunctionalArtyDispatchAdapter.lua` | Eine bereits laufende MOOSE-`ARTY`-Instanz besitzt die Batterie; Ziele werden ueber `AssignTargetCoord` an genau diese Instanz uebergeben. |
| Local M1083 rearm | `OMW_FixedFireSupportAmmoRearmService.lua` + `OMW_GroundAmmoRearmAdapter.lua` | Dieselbe ARTY-Instanz wird mit `startArty=false` weiterverwendet; `OnBeforeRearm` committed CampaignState consumption, `OnAfterRearmed` completed sie; MOOSE ARTY fuehrt die physische Rueckbewegung des M1083 aus. |
| Accepted evidence | Fixed Fire Support Rearm Acceptance 2-11 | Exakte Provenienz: source/build `d52a47a418fe3a1a996a5b68198b8dc033ff86c4`, bundle `CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B`, mission `388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620`, DCS `2.9.28.26385 MT`. |
| Generic `AUFTRAG:NewARTY` | pinned MOOSE source + `OMW_FireSupStratResupply_ArtyMissionFactory.lua` | Separater OPS mission owner; erzeugt `FireAtPoint` fuer den durch COMMANDER/LEGION rekrutierten OPSGROUP. Keine automatische Gleichwertigkeit mit Functional ARTY/Rearm. |
| COMMANDER handoff gap | pinned MOOSE 2.9.18 / `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54` | Kein oeffentlicher Vertrag nachgewiesen fuer `COMMANDER selects -> existing long-lived ARTY instance takes ownership` ohne parallelen AUFTRAG-Fire-Owner. |
| OPSGROUP rearm alternative | `OPSGROUP:SetRearmOnOutOfAmmo()` | Andere MOOSE-Rearm-Semantik; nicht als Ersatz fuer die akzeptierte M1083/CampaignState-Kette freigegeben. |

Harte ARTY-Regel:

```text
same battery
-> exactly one operational fire-control owner

accepted production candidate:
Functional ARTY owner
-> fire
-> same Functional ARTY owner
-> M1083 rearm

forbidden without explicit owner decision:
Functional ARTY owner
AND
AUFTRAG:NewARTY / OPSGROUP fire mission owner
```

Owner-Entscheidung 22.09.2026: Functional `ARTY` bleibt der einzige Fire-Control-/Rearm-Owner. Die neue Selection/Handoff-Grenze ist als `OMW_FireSupStratResupply_ArtySelectionRuntime.lua` implementiert und bleibt bis zur gezielten DCS-Acceptance `SOURCE_IMPLEMENTED / DCS_PENDING`.

Verbindlicher neuer Vertrag:

```text
C2 qualified ARTY demand
-> AUFTRAG:NewARTY selection descriptor only
-> COMMANDER:CanMission
-> COMMANDER:RecruitAssetsForMission
-> exact MOOSE-selected asset/Legion
-> identity-only mapping to existing Functional ARTY instance
-> ARTY:AssignTargetCoord
-> Functional ARTY fire/rearm lifecycle
-> LEGION.UnRecruitAssets after terminal fire-selection state
```

In diesem Functional-ARTY-Modus ist `COMMANDER:AddMission(selectionMission)` verboten, weil der Selection-`AUFTRAG` sonst zum zweiten Fire-Control-Owner wuerde. Der Identity-Resolver darf keine Batterie vor MOOSE waehlen und kein Ersatz-Recruitment implementieren.

### A10-DCS-Preflight 24.09.2026 – zusaetzliche MOOSE-Warehouse-Grenze

Die Vorbereitung der fokussierten DCS-Acceptance gegen die owner-provided Mission

```text
OMW_Template_v25_GroundWorks_base(1).miz
SHA-256:
8C989DC531D1CCE30EF183F59874A6809B5C11D11932D893CD55ADAC3191D247
```

hat eine weitere, fuer den Selection-only-Vertrag entscheidende MOOSE-Grenze sichtbar gemacht.

Im gepinnten `Moose.lua` gilt fuer `WAREHOUSE:onafterAddAsset(...)` ausdruecklich:

```text
Add a group to the warehouse stock.
If the group is alive, it is destroyed.
```

`BRIGADE:AddPlatoon(...)` ruft fuer das Platoon-Template `BRIGADE:AddAssetToPlatoon(...)` auf; dieser Pfad fuehrt wiederum ueber `WAREHOUSE:AddAsset(...)`. Damit kann eine bereits physisch aktive, von Functional `ARTY` besessene Batterie nicht unveraendert zugleich als neuer BRIGADE/WAREHOUSE-Recruitment-Asset registriert werden. Das wuerde ihre bestehende DCS-Repräsentation zerstoeren und den akzeptierten Functional-ARTY-Lifecycle verletzen.

Die bereitgestellte Mission enthaelt die aktiven Fixed-Fire-Support-Gruppen

```text
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2
```

sowie deren Warehouses und M1083-Resupply-Vertrag, aber keine separate, eindeutig als selection-only ARTY-Descriptor-Asset vorgesehene zweite Template-Ebene.

Daraus folgt fuer A10:

```text
SOURCE_IMPLEMENTED selection bridge
!= DCS-ready composition yet

blocked boundary:
existing physical Functional ARTY battery
<-> MOOSE COMMANDER/LEGION recruitable asset identity
```

Nicht zulaessig ohne neue Owner-Entscheidung:

```text
- aktive Batterie via WAREHOUSE:AddAsset registrieren und dadurch zerstoeren;
- Batterie nach AddAsset heimlich neu spawnen/teleportieren;
- fremdes Dummy-Asset als angeblich identische operative Batterie ausgeben;
- MOOSE-Recruitment durch einen OMW-eigenen Selector ersetzen;
- den akzeptierten Functional-ARTY-/M1083-Lifecycle auf OPSGROUP-Rearm umstellen.
```

Der fokussierte A10-DCS-Lauf bleibt deshalb `BLOCKED_PRE_COMPOSITION`, bis die Owner-Entscheidung fuer die physische/rekrutierbare Provider-Repräsentation getroffen ist. Die Selection-only Source bleibt unveraendert `DCS_PENDING`; aus dem Preflight entsteht kein Runtime-PASS.


## Owner-Entscheidung und Honaker-Reconciliation 13.09.2026

Der historische Honaker-Full-Response-Test hatte bereits den entscheidenden Incident-Vertrag: bekannte lebende Angreifer wurden als Incident-Teilnehmer geführt, nach Entfernung priorisiert und erst nach Neutralisierung der bekannten Angreifer wurde die QRF zur Rueckkehr freigegeben. Die damalige QRF verwendete `NewONGUARD(target:GetCoordinate()) + SetEngageDetected(...)`; sie war noch nicht direkt an das konkrete bewegliche Target gebunden.

Production Base Acceptance 3 zeigte bei Joyce die Grenze von reinem `SetEngageDetected`: Restkraefte hinter Gelaende wurden nicht verlaesslich weiter verfolgt. Ein anschliessender A4-Entwurf mit `PATROLZONE + HuntingPatrol` wurde im realen DCS-Test vom 13.09.2026 verworfen. Beobachtet wurden unnoetige Wege zur alten Einsatzgeometrie und eine im Gelaende gebundene QRF, waehrend RED weiter in Richtung FOB lief. Dieser Lauf ist negative Design-Evidenz, kein PASS.

Der Projektinhaber hat daraufhin den folgenden Vertrag festgelegt:

```text
Incident / QRF demand
        -> ONGUARD(initial threat coordinate)       [MOOSE recruitment/materialization anchor]
        -> same physical ARMYGROUP
        -> nearest living known incident UNIT inside 5-NM tactical zone
        -> ARMYGROUP:EngageTarget(concrete UNIT, speed, "On Road")
        -> road-preferred motorized transit under MOOSE routing
        -> final off-road target approach by MOOSE when required
        -> MOOSE updates pursuit against moving target
        -> target dead -> MOOSE Disengage
        -> reacquire next living incident UNIT
        -> repeat
        -> no living authorized incident target remains
        -> cancel/complete QRF mission
        -> MOOSE ReturnToLegion / RTZ / Returned / Warehouse lifecycle
```

Verbindliche Grenzen:

```text
- kein GROUNDATTACK;
- kein PATROLZONE/HuntingPatrol fuer diesen QRF-Vertrag;
- kein eigener OMW-Scheduler oder Frame-Scan fuer Zielsuche;
- kein eigener OMW-Strassenrouter parallel zu MOOSE;
- motorisierte QRF marschiert road-preferred / On Road, nicht standardmaessig in Vee;
- Runtime/Composition darf den On-Road-Marschvertrag nicht mit Vee ueberschreiben;
- Vee ist eine Gefechtsformation und nicht der Default fuer den gesamten Anmarsch;
- keine Rueckkehr nur wegen Perimeter-Clear oder Incident-Close;
- "keine Targets" bedeutet keine lebenden autorisierten Incident-Ziele in der Tactical-Zone, nicht "nichts detektiert";
- vorhandener GroundInstallationAttackIncident-Teilnehmerbestand ist Zielautoritaet;
- dieselbe bereits materialisierte ARMYGROUP wird weiterverwendet;
- MOOSE EngageTarget/Disengage/ReturnToLegion besitzt physische Verfolgung und Lifecycle;
- ACCESS-/RoadSpawnAdapter-Vertrag bleibt unveraendert;
- DCS-Validierung des direkten Target-Cycles inklusive Road-Preferred-Marsch ist offen.
```

Pinned source review:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

BRIGADE:ArmyOnMission / OnAfterArmyOnMission
ARMYGROUP:EngageTarget(...)
ARMYGROUP:AddWaypoint(...)
ARMYGROUP route update with ENUMS.Formation.Vehicle.OnRoad
ARMYGROUP:OnAfterDisengage
ARMYGROUP:RTZ / Returned
AUFTRAG:NewONGUARD(...)
AUFTRAG:SetReturnToLegion(true)
AUFTRAG:Cancel()
```

Im gepinnten MOOSE-Quellstand akzeptiert `EngageTarget` TARGET/GROUP/UNIT, aktualisiert die Zielkoordinate bei mehr als 100 m Bewegung oder fehlender LOS und disengagiert bei totem/nicht mehr aufloesbarem Ziel. `ARMYGROUP:AddWaypoint` und die Route-Update-Logik behandeln `On Road` als Strassenpraeferenz: MOOSE fuegt Road-Waypoints ein und setzt den eigentlichen Ziel-Waypoint Off Road, wenn das Ziel selbst abseits der Strasse liegt. Damit wird weder eigene OMW-Wegpunktverfolgung noch ein eigener OMW-Strassenrouter implementiert.

## A4-6 Runtime-Override-Regression

Der reale A4-6-Lauf vom 13.09.2026 materialisierte die Joyce-QRF korrekt strassenausgerichtet in ACCESS und liess die RED-Fixture auf ihrer vorhandenen Mission-Editor-Route. Der QRF-Marsch nutzte die Strasse sichtbar trotzdem nicht. Die Log-Evidenz zeigte beim initialen und spaeteren Target-Acquire `formation=Vee`.

Die Ursache lag nicht im gepinnten MOOSE-Road-Routing, sondern im OMW Composition/Runtime-Layer: `OMW_FireSupStratResupply_QrfRuntime.lua` setzte `QRF_ENGAGE_FORMATION = "Vee"` und ueberschrieb damit den bereits auf `On Road` korrigierten MissionFactory-Default. A4-6 hat `EngageTarget(..., "On Road")` daher nicht real getestet.

Korrektur ab QRF Runtime 13:

```text
QrfMissionFactory default = On Road
AND
QrfRuntime explicit formation = On Road
AND
runtime test verifies ARMYGROUP EngageTarget receives On Road
AND
builder/accepted-contract tests forbid a Vee runtime override
```

## Harte ACCESS-Regel

```text
JALALABAD_FENTY -> ZON_BLUE_GND_FENTY_ACCESS
COP_FORTRESS    -> ZON_BLUE_GND_FORTRESS_ACCESS
FOB_JOYCE       -> ZON_BLUE_GND_JOYCE_ACCESS
FOB_WRIGHT      -> ZON_BLUE_GND_WRIGHT_ACCESS
COP_HONAKER     -> ZON_BLUE_GND_HONAKER_ACCESS
FOB_BOSTICK     -> ZON_BLUE_GND_BOSTICK_ACCESS
```

Nicht als QRF-Materialisierungsabhaengigkeit zulaessig:

```text
*_PATROL_TEST_01
Alarm-/Security-Zone
Warehouse-Center
FOB-/COP-Mittelpunkt
taktisches Ziel als Spawnzone
zusaetzliche Mission-Editor-Spawnzone
```

Die initiale physische Incident-Zielkoordinate darf im Composition Root als Road-Forward-Richtungsinformation an den vorhandenen RoadSpawnAdapter weitergereicht werden. Der validierte Road-/Materialisierungsanker muss innerhalb ACCESS liegen. Die ACCESS-Zone ist **keine Bounding-Zone fuer die komplette Fahrzeugformation**. Einzelne Fahrzeuge duerfen nach der road-aligned Aufstellung ausserhalb ACCESS liegen. Eine per-Unit-`IsVec2InZone`-Containment-Regel ist nicht Teil des Owner-Vertrags. Nach der Materialisierung wird die physische QRF nicht zu diesem Positions-Snapshot geschickt, sondern per MOOSE an das konkrete lebende Target gebunden.

## Owner-Klarstellung ACCESS-Containment – 05.10.2026

Der Projektinhaber hat am 05.10.2026 ausdruecklich klargestellt:

~~~text
ACCESS / Spawnzone
= validierter Materialisierungs-/Road-Anker
!= Bounding-Zone fuer alle Fahrzeuge oder Gruppenmitglieder
~~~

Die zuvor im `OMW_GroundRoadSpawnAdapter.lua` enthaltene per-Unit-Pruefung
`accessZone:IsVec2InZone(roadCoordinate:GetVec2())` war eine unbeabsichtigte
zusaetzliche Guardrail-Verschaerfung und **keine Owner-Entscheidung**.

Aktiver Vertrag:

~~~text
ACCESS road anchor resolves and lies inside ACCESS
-> road path and snap validation remain fail-closed
-> road-aligned formation is built with accepted spacing/heading rules
-> individual formation members may extend outside ACCESS
-> MOOSE BRIGADE/WAREHOUSE/PLATOON/ARMYGROUP/AUFTRAG lifecycle remains unchanged
~~~

Die historische Ground Acceptance 3-2 bleibt Evidenz fuer ihren exakt getesteten
4-Fahrzeug-Stand. Die geaenderte Containment-Grenze muss im aktuellen A11/QRF-
Stand erneut in DCS validiert werden.

## Acceptance-Code-Gesetz

Acceptance darf beobachten und physische Teststimuli erzeugen, aber keine Produktsemantik erfinden. Verboten:

```text
movement >= N m -> QRF release/cancel
perimeter clear -> QRF release/cancel
incident close allein -> QRF release/cancel
"nichts detektiert" -> QRF release/cancel
Acceptance-eigene Target-Auswahl fuer die QRF
Acceptance-eigenes ExpireDemand als Ersatz fuer produktive Target-Completion
alternative AUFTRAG type nur fuer bequemeren Test
Acceptance-eigene Resource-/Lifecycle-Authority
Acceptance-eigene QRF-Routensteuerung parallel zu MOOSE
```

Die historische Production Base Acceptance 3 bleibt unveraendert als Evidenz des damaligen ONGUARD-Response-Pfads. Acceptance 4 prueft den neuen direkten Target-Cycle separat.

## Nicht wiederholen – dokumentierte Regressionen

1. QRF-Materialisierung ausserhalb des ACCESS-Vertrags.
2. `GROUNDATTACK` statt Honaker-Recruitment-/Lifecycle-Basis.
3. `>=25 m -> ExpireDemand -> Cancel -> RTZ`; fuehrte zu zu fruehem Umdrehen u.a. bei Fortress/Joyce.
4. Eigene 500/1000/1500/2000-m Road-Sampling-Heuristik.
5. Historische `PATROL_TEST`-Fixtures als aktuelle Acceptance-Voraussetzung.
6. `PATROLZONE + HuntingPatrol` als QRF-Clearance; realer A4-DCS-Lauf zeigte unpassende Einsatzgeometrie/Target-Bindung.
7. Eigene Search-/Sweep-/Target-Scheduler parallel zu MOOSE.
8. `Vee` als Default oder Runtime-Override fuer den gesamten motorisierten QRF-Anmarsch trotz road-aligned ACCESS-Materialisierung.

## Anti-Regression-Gate

`tests/mission-demand/test_fire_support_qrf_accepted_contract.lua` muss mindestens verhindern:

```text
missing ONGUARD recruitment anchor
missing SetReturnToLegion(true)
GROUNDATTACK substitution
PATROLZONE/HuntingPatrol reintroduction
missing direct ARMYGROUP:EngageTarget
missing MOOSE On Road QRF transit in MissionFactory
missing MOOSE On Road QRF transit in Runtime
Vee as default motorized QRF march formation
Vee as Runtime/Composition override
missing Disengage-driven reacquisition
missing authoritative incident GetParticipants(true) target source
missing tactical-zone target filtering
missing target-exhaustion mission completion
missing ACCESS GroundRoadSpawnAdapter integration
reintroduced per-unit/all-members ACCESS containment
PATROL_TEST dependency
movement-distance-driven release
return on perimeter clear alone
return on incident close alone
custom QRF target scheduler
custom QRF road router parallel to MOOSE
```

## Regression-Verfahren

```text
Regression feststellen
-> fruehere Acceptance identifizieren
-> akzeptierte Implementierung pruefen
-> aktuellen Code dagegen diffen
-> Abweichung zuruecknehmen
```

Keine weitere Alternativloesung ohne vorherige Owner-Entscheidung.

Dieses Dokument ist ein Entwicklungs-/Review-Gate, kein DCS-Runtime-PASS.

## Lifecycle-Preservation Gate

Dieses Matrix-Dokument ist vor jeder FSSR-Base-/Reconciliation-Aenderung zusammen mit `ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md` zu pruefen.

Verbindlich:

```text
accepted lifecycle implementation
-> must be reused or shared-extracted
-> Acceptance may only trigger/observe/assert
-> copied lifecycle logic does not inherit acceptance evidence
-> intentional invariant change requires owner approval + scoped DCS revalidation
```

Insbesondere duerfen neue Acceptance-Harnesses keine eigene QRF-Targeting-, CAS-Release-, CAS-RTB-/Recovery-, ARTY-Rearm- oder ReturnToLegion-State-Machine aufbauen, wenn die betreffende Funktion bereits als akzeptierter beziehungsweise bindender Produktionsvertrag existiert.

## CAS lifecycle inheritance record – A9

| Boundary | Inherited implementation / law | Current implementation | Evidence status |
|---|---|---|---|
| outbound/reverse owner route | Stage-2B accepted `OMW_HelicopterFlightPathCorridor` path and current tactical corridor contract | shared `OMW_FireSupStratResupply_CasLifecycleRuntime` directly calls the route modules | old exact-provenance route PASS; A9 composition VALIDATED |
| provider/asset selection | ADR 0008 / MOOSE COMMANDER+LEGION | unchanged MOOSE authority | A9 VALIDATED |
| mission execution gate | MOOSE `AUFTRAG:IsExecuting()` | shared runtime | A9 VALIDATED |
| CAS own picture | Stage-3 binding `FLIGHTGROUP:GetDetectedGroups()` contract | shared runtime | A9 VALIDATED |
| supported-element release | Stage-3 CAS lifecycle law | shared runtime reads authoritative source incident coordinator participants | A9 VALIDATED |
| stable no-contact | Stage-3 30-s rule | shared production runtime scheduler; `nil` detection is not clear | A9 VALIDATED |
| mission closure | public MOOSE `AUFTRAG:Cancel()` via existing CommanderBridge handle | shared runtime | A9 VALIDATED |
| landing / asset return | MOOSE FLIGHTGROUP/LEGION lifecycle | shared runtime observes home landing + exact `LegionAssetReturned` | A9 VALIDATED |
| Acceptance role | preservation law | A9 stimulus/observation/assertion only | static/CI gate PASS; A9 VALIDATED |

A9 must not be built or handed to DCS until the unit/static gates and both repository CI workflows pass on the exact remote HEAD.

### CAS release policy profile boundary

| Boundary | Contract | Status |
|---|---|---|
| General release rule | supported-element status + own qualified CAS report + explicit release authority; concrete policy is profile-dependent | `BINDING` via Stage3 CAS lifecycle law §20 |
| A9 release profile | `SUPPORTED_ELEMENT_STABLE_NO_CONTACT`, `stableNoContactSec=30` | test-profile config; `VALIDATED_IN_A9` |
| Qualification owner | `OMW_FireSupStratResupply_CasReleasePolicy.lua` | `SOURCE_REVIEWED / UNIT_CI_PASS / A9_VALIDATED` |
| Detection owner | MOOSE `FLIGHTGROUP:GetDetectedGroups()` via shared CasLifecycleRuntime | A9 VALIDATED |
| Mission closure | shared `OMW_FobAttackCasPatrolClosure.Request` -> existing CommanderBridge handle -> `AUFTRAG:Cancel()` | A9 VALIDATED |

The 30-second value must not be promoted to a global production invariant by future Base work without a separate owner decision and documented evidence.

### A9 final DCS evidence

Exact validated provenance:

```text
source commit: c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2
Acceptance bundle SHA-256: D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0
DCS: 2.9.29.27468
MOOSE: 2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
result: PASS
```

Validated A9 chain:

```text
MOOSE provider/asset selection
-> selected provider owner profile
-> owner route / tactical corridor
-> mission executing
-> own FLIGHTGROUP detection
-> supported-element clear
-> 30 s A9-profile stable no-contact
-> controlled release
-> reverse owner route
-> home landing Jalalabad
-> exact LegionAssetReturned
-> CAS_LIFECYCLE_COMPLETE
-> PASS
```

Negative regression confirmation: no terminal post-return `CAS_ASSET_LOSS` occurred on corrected source. This validation applies only to the documented A9 Joyce rotary-wing CAS scope.


## ARTY Option A – Owner decision 25.09.2026

Der Projektinhaber hat fuer die in A10 dokumentierte Repräsentationsfrage **Option A** freigegeben:

```text
separate one-to-one MOOSE selection descriptors
-> selection/reservation representation only
-> no second physical battery
-> no second strategic stock
-> exact mapping to one already-existing Functional ARTY owner
```

Implementierter Source-Vertrag:

```text
existing external-support COMMANDER
-> existing site BRIGADE(s)
-> dedicated descriptor PLATOON per fixed battery
-> non-alive Mission-Editor descriptor template
-> COHORT mission capability ARTY
-> COHORT:SetMissionRange(0)
-> COHORT:AddWeaponRange(explicit min/max)
-> COMMANDER:CanMission
-> COMMANDER:RecruitAssetsForMission
-> descriptor asset remains unspawned
-> identity-only resolver verifies exact physical Functional ARTY group
-> Functional ARTY remains sole fire/rearm owner
```

Der vorhandene external-support COMMANDER bleibt die MOOSE-Auswahlautoritaet. Fuer diesen Functional-ARTY-Pfad wird der Selection-AUFTRAG ausschliesslich ueber `CanMission/RecruitAssetsForMission` verwendet und weiterhin nicht mit `AddMission` gequeued.

Harte Descriptor-Regeln:

```text
descriptor template must not be alive at registration
descriptor asset.spawned must remain false
descriptor PLATOON may only advertise ARTY for this contract
descriptor range has no default; explicit min/max is mandatory
physical-group identity must match the mapped ARTY.Controllable:GetName()
no descriptor may be treated as CampaignState stock
no descriptor may be materialized as the firing battery
```

Production-Komponente:

```text
scripts/campaign/OMW_FireSupStratResupply_ArtySelectionDescriptorRegistry.lua
schema OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-DESCRIPTOR-REGISTRY-1
```

Der Source ist erst nach realem A10-Lauf fuer die konkrete Mission/Range-Konfiguration DCS-validiert.

### Option-A Production Base 27 build evidence – 26.09.2026

Owner-local build/hash verification for the exact Option-A source:

```text
source commit:
ee431db16c2fb3f3bf4fa2c33a0da4ff0363ded6

BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-27

builder SHA-256:
8CA05C37D9D51B5AF44A052B91B620D91CB77B997632E0073FC140052BF462A3

bundle SHA-256:
5FEDBA2486CC048D2805615945D0A016EA7939B4920796BCEAF870DAC7FBE4F4

independent owner Get-FileHash:
MATCH / MATCH

CI:
Documentation validation #2315 PASS
MissionDemand validation #1087 PASS
```

Status:

```text
Option-A source/contract/unit/CI/local-build provenance = CLOSED
DCS runtime acceptance = PENDING
remaining pre-DCS inputs = descriptor ME fixtures + explicit artillery range configuration
```

## ARTY Real-Asset Direction – Owner decision 01.10.2026 / source implementation 02.10.2026

Die am 25.09.2026 freigegebene Descriptor-Option ist **vor DCS-Validierung superseded**. Der Projektinhaber erlaubt nun, dass MOOSE die vier realen site-bound ARTY-/Mörsergruppen selbst materialisiert, sofern ihre heutigen Mission-Editor-Stellungen und internen Formationen exakt erhalten bleiben und die Batterien nach der Materialisierung nicht verlegt werden.

Implementierter Source-Pfad:

```text
existing late-activation site-bound ME template
-> PLATOON:New(..., 1, site platoon)
-> existing site BRIGADE:AddPlatoon(...)
-> real WAREHOUSE.Assetitem
-> BRIGADE:LoadBackAssetInPosition(asset.spawngroupname, original template route point)
-> LEGION AssetSpawned
-> real ARMYGROUP / asset.flightgroup
-> COMMANDER CanMission + RecruitAssetsForMission
-> selection-only reservation of the real spawned asset
-> exact asset.flightgroup:GetGroup()
-> existing Functional ARTY owner
-> ARTY:AssignTargetCoord(...)
```

`LoadBackAssetInPosition(...)` wird hier bewusst als kleinster öffentlicher MOOSE-Adapter für die einmalige exakte Initialmaterialisierung verwendet. Der reguläre Warehouse-Self-Request besitzt im gepinnten MOOSE 2.9.18 keinen per-request Spawnpunkt und teilt sich die BRIGADE-Spawnzone mit mobilen QRF-Assets. Ein temporäres globales Umschalten der Site-Spawnzone wäre deshalb ein größeres Interferenzrisiko.

Harte Invarianten:

```text
no descriptor asset
no duplicate physical battery
no COMMANDER:AddMission(selection AUFTRAG)
no ARTY move-into-range
no PATROL/ONGUARD/RELOCATE/RTZ for fixed battery
Functional ARTY remains sole fire/rearm owner
CampaignState remains strategic resource authority
```

Pinned-MOOSE-Range:

```text
L118_Unit    500 .. 17500 m
2B11 mortar  500 .. 7000 m
```

Source: `scripts/campaign/OMW_FireSupStratResupply_ArtyRealAssetRegistry.lua`

Status: `SOURCE_IMPLEMENTED / CI_PENDING / DCS_PENDING`.

### Production Base 28 local build evidence – 02.10.2026

```text
source commit  = 4acd25cfacc10c530e50b336cbb2472f5eb8c360
builder sha256 = E6934463EFE4751EE6AC276D9C247187B39DE79305FB82986C7D44CC79EB04A2
bundle sha256  = 0525D0CA70BA356B3A27FFBCB222EC21346891D5B71252F57551E89FC0612A47
MizMutation    = false
CI docs        = PASS (#2321)
CI mission     = PASS (#1092)
```

Dies ist Build-/Source-Evidenz, keine DCS-Acceptance des neuen RealAssetRegistry-Lifecycles.

### A10 DCS acceptance – 02.10.2026

Production Base A10 hat den neuen Real-Asset-ARTY-Lifecycle unter DCS 2.9.30.28536 MT erfolgreich durchlaufen.

```text
source commit:
4c8793a9b155f85e7a229117725fca55f58987c3

mission SHA-256:
95F28962F15659399051813F426A1401797EA95F931588349F9EAB1523E28232

A10 bundle SHA-256:
FA0CD024F050BA19DECAEE9AB1EF71C35B976346A327D118EFCC59DC249C84C9

MOOSE:
2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Beobachtet: exact-position MOOSE materialization aller vier site-bound Fire-Support-Assets, zwei gleichzeitig geeignete Provider (Wright/Honaker), MOOSE/COMMANDER-Auswahl des realen Wright-Assets, Functional ARTY 300 -> 296, Reservation Release, keine Batteriebewegung, accepted M1083/CampaignState rearm, 301 rounds nach Rearm und M1083 Return-to-Stock.

Status für diesen exakten Stand: `DCS_PASS`.

## A10 inheritance consequence and A11 gate – 02.10.2026

A10 ist fuer seine exakte Provenienz ACCEPTED_TECHNICAL_BASELINE.

| Verhalten | Akzeptierter Produktionspfad | Evidenz | A11-Regel |
|---|---|---|---|
| Fixed ARTY/Mortar representation | RealAssetRegistry -> real PLATOON/BRIGADE/Warehouse asset -> exact startup materialization | A10 PASS | nicht durch Descriptor oder live-group adoption ersetzen |
| Fixed-fire-support selection | COMMANDER CanMission + RecruitAssetsForMission -> real asset reservation | A10 PASS | Harness/Base waehlt keinen Provider |
| Fire control | selected group -> one Functional ARTY owner -> AssignTargetCoord | A10 + Rearm baseline | kein AUFTRAG FireAtPoint second owner |
| Selection release | CeaseFire -> LEGION.UnRecruitAssets | A10 PASS | demand-/asset-korreliert erhalten |
| Fixed emplacement | no movement after materialization/fire/rearm | A10 PASS | keine Move-to-range-Logik |
| M1083 rearm reuse | accepted FixedFireSupportAmmoRearmService | A10 regression PASS | local rearm nicht als Strategic Resupply fehlinterpretieren |
| Concurrent multi-demand orchestration | noch nicht akzeptiert | A11 planned | realer Multi-Site-DCS-Lauf erforderlich |
| Selected 2B11 fire | noch nicht akzeptiert | A11 planned | kein Honaker-Hardcoding |
| Strategic Resupply | Source/Contracts vorhanden, physischer Full-Lifecycle offen | A11 planned after production closure | CampaignState + OPSTRANSPORT/STORAGE + idempotent settlement |

Der Descriptor-only-Pfad bleibt historische Source-Evidenz, ist aber fuer die aktive Fixed-Fire-Support-Production-Composition superseded.


## Post-A10 Source-Reconciliation – 02.10.2026

| Bereich | Aktiver Source-Pfad | Stand | Noch erforderliche DCS-Evidenz |
|---|---|---|---|
| Descriptor-only Fixed ARTY | nicht mehr im Production-Base-Bundle; Source/Test nur historische Evidenz | SUPERSEDED_ACTIVE_COMPOSITION | keine; darf nicht parallel zur RealAssetRegistry zurueckkehren |
| Real L118/2B11 representation | RealAssetRegistry -> PLATOON/BRIGADE/Warehouse Assetitem -> exact LoadBack bootstrap | A10 L118-selected PASS; 2B11 materialized/range-capable | MOOSE-selected 2B11 fire in A11 |
| ARTY multi-demand | demand-scoped SelectionRuntime + MOOSE asset reservations + Functional ARTY | SOURCE_TESTED / CI_PASS | echte gleichzeitige DCS-Provider-Contention |
| CAS multi-demand | demand-scoped lifecycle/release state; selected provider must have owner profile or fail closed | SOURCE_TESTED / CI_PASS | mindestens zwei ueberlappende CAS-Demands mit realer Auswahl/Recovery |
| Strategic Resupply mapping | CampaignState quantity getrennt von explizitem physical STORAGE cargoAmount | SOURCE_TESTED / CI_PASS | reales Resource->STORAGE-Mapping im A11-Run |
| Strategic Resupply in-transit | OPSTRANSPORT StatusUpdate + cargoLoaded + alle assigned carriers ausserhalb pickup | SOURCE_TESTED / CI_PASS | realer MOOSE loading/departure/delivery-or-loss lifecycle |
| Strategic settlement | reserve -> loading -> in-transit -> delivered/lost; partial bleibt unresolved | SOURCE_TESTED / CI_PASS | exactly-once Settlement gegen realen DCS-Lauf |
| Combined provider autonomy | keine site->provider/nearest/preferred/fixed-carrier Auswahl im allgemeinen Base-Pfad | SOURCE_REVIEWED | A11 combined multi-site run |

Keine Zeile dieser Source-Reconciliation erweitert die exakten A9-/A10-DCS-Baselines.
