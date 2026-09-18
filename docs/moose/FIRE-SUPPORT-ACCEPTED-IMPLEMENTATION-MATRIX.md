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
| Road-aligned materialization | `OMW_GroundRoadSpawnAdapter.lua` | Nur Spawngeometrie wird angepasst; MOOSE besitzt BRIGADE/WAREHOUSE/PLATOON/ARMYGROUP/AUFTRAG. |
| Resources | CampaignState / Ground Foundation | CampaignState bleibt strategische Autorität. |

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

Die initiale physische Incident-Zielkoordinate darf im Composition Root als Road-Forward-Richtungsinformation an den vorhandenen RoadSpawnAdapter weitergereicht werden. Die tatsaechliche Materialisierung muss vollstaendig innerhalb ACCESS bleiben. Nach der Materialisierung wird die physische QRF nicht zu diesem Positions-Snapshot geschickt, sondern per MOOSE an das konkrete lebende Target gebunden.

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
