---
document_id: OMW-STAGE-2B-FOB-ATTACK-AUTOMATIC-RESPONSE
status: PLANNED
document_class: MOOSE_INTEGRATION_DESIGN
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2B automatic response design for threatened BLUE FOB/COP installations
  - CAS dispatch and completion requirements
  - local infantry counterattack resource boundary
  - guard and counterattack return/recovery lifecycle
  - post-combat personnel settlement and resupply reevaluation
not_authoritative_for:
  - production-wide CAS source-selection policy
  - final installation-specific security or recovery radii
  - final guard rotation duration
  - final counterattack force-sizing algorithm beyond the approved 50 percent reserve boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2B – automatische Reaktion eines angegriffenen FOB/COP

## 1. Ausgangspunkt

Stage 2A ist für Fortress im dokumentierten Scope in DCS bestätigt:

```text
RED ground presence inside runtime security perimeter
-> MOOSE OPSZONE Attacked(RED)
-> qualified installation threat
-> MissionDemand CAS_IMMEDIATE
```

Stage 2B erweitert diesen Eingang zu einer vollständigen MOOSE-first-Reaktion. CampaignState bleibt alleinige strategische Ressourcenautorität; MOOSE führt die physischen AIRWING-/SQUADRON-/FLIGHTGROUP- und BRIGADE-/PLATOON-/ARMYGROUP-Lifecycles aus.

## 2. Implementiertes Stage-2B-Zielbild

```text
qualified installation threat
|
+-> CAS_IMMEDIATE
|   -> existing Jalalabad AIRWING / AH-64D SQUADRON
|   -> AUFTRAG:NewCAS
|   -> shared OMW_FlightPath valley corridor
|   -> CAS execution
|   -> OPSZONE Defeated(RED)
|   -> AUFTRAG:Cancel
|   -> FLIGHTGROUP RTB / Landed / Arrived
|
+-> local infantry response
|   -> CampaignState PERSONNEL reservation
|   -> preserve 50 % defence reserve floor
|   -> Ground Warehouse / BRIGADE / PLATOON / ARMYGROUP
|   -> AUFTRAG:NewGROUNDATTACK(real RED group)
|   -> threat clear / relief or MOOSE OutOfAmmo lifecycle
|   -> explicit ARMYGROUP:RTZ to installation ACCESS return handoff
|   -> Returned / Warehouse AddAsset
|   -> exactly-once personnel settlement
|
+-> post-combat resource reevaluation
    -> existing ResourceDemandPolicy
    -> MissionDemand RESUPPLY only if existing PERSONNEL threshold is crossed
    -> existing PERSONNEL physical resupply orchestration remains unchanged
```

## 3. MOOSE-first-Prüfung – Ergebnis

Der tatsächlich gepinnte `Moose.lua` bestätigt die benötigten Framework-Pfade. Die vollständige API-Liste und der Validierungsstatus stehen in:

```text
docs/moose/PROJECT-CLASS-INDEX-STAGE-2-ACCEPTANCE-2.md
```

Wesentliche Ergebnisse:

```text
OPSZONE Attacked -> Defeated -> Guarded
AUFTRAG:NewCAS is orbit-based and does not auto-finish when current targets disappear
AUFTRAG:Cancel exists
FLIGHTGROUP can RTB after mission/task completion
AUFTRAG:NewGROUNDATTACK exists for ground groups
ARMYGROUP:RTZ / Returned / Warehouse AddAsset exists
MOOSE owns OutOfAmmo lifecycle; no OMW ammo poller required
PATHLINE + FLIGHTGROUP waypoint APIs support the already validated OMW_FlightPath corridor
```

Für `GROUNDATTACK` wurde in der offiziellen MOOSE-Missionssammlung kein belastbarer Demo-Nachweis gefunden. Deshalb wird kein Demo-Nachweis behauptet; der gepinnte Source ist für die API-/Semantikprüfung maßgeblich.

## 4. Lokale Selbstverteidigung und 50-Prozent-Grenze

Bindende Stage-2B-Grenze:

```text
at least 50 % of installation PERSONNEL target/max
must remain unavailable for counterattack commitment
```

Für Fortress:

```text
PERSONNEL target: 160
defence reserve floor: 80
maximum total personnel outside that reserve: 80
```

Die 50-%-Grenze ist ein Maximum, kein Sollwert. Acceptance 2 verwendet je eine 9-Personen-Gruppe für Guard und QRF; damit werden nur 18 Personen gleichzeitig gebunden.

## 5. Korrigierter PERSONNEL-Deployment-Vertrag

Die strategische Semantik ist ausdrücklich **Reservation während des Einsatzes**, nicht sofortiger permanenter Verbrauch.

```text
before deployment:
quantity = strategic personnel strength
reserved = already deployed/committed personnel
available = quantity - reserved

on deployment:
ReserveResource(quantity)
-> strategic quantity unchanged
-> reserved increases
-> available decreases

on physical return:
Cancel(deployment reservation)
-> survivors become available again

confirmed casualties:
separate exact-once CONSUMPTION
-> strategic quantity decreases only by confirmed casualties
```

Damit wird ein Soldat nicht beim Deployment und später beim Tod doppelt abgezogen. Der Stage-2A-Acceptance-Harness hatte seine neun Personen testlokal als Consumption behandelt; diese konkrete Harness-Technik ist **keine** Produktionsbaseline und wird in Stage 2B korrigiert.

Implementierter Adapter:

```text
scripts/ground/OMW_GroundPersonnelDeploymentLedger.lua
```

## 6. Lokaler Gegenangriff

Die Stage-2B-QRF nutzt keinen direkten `SPAWN:`-Shortcut und keine eigene Ground-Attack-Task-Implementierung:

```text
CampaignState reservation
-> existing MOOSE Ground Warehouse / BRIGADE
-> QRF PLATOON
-> ARMYGROUP
-> AUFTRAG:NewGROUNDATTACK(real RED group from OPSZONE scanned group set)
```

Der gepinnte MOOSE-Source erklärt bei `GROUNDATTACK`, dass DCS-Attack-Group/-Unit-Tasks für Ground nicht geeignet sind und MOOSE deshalb den Angreifer in die Nähe des Zielobjekts führt, wo die Gruppe selbständig bekämpft. Genau dieser Framework-Weg wird wiederverwendet.

## 7. Threat clear und CAS-Abschluss

`AUFTRAG:NewCAS` baut auf einer Orbit-Mission auf. Daher ist ein Dauerorbit nach Vernichtung aller aktuellen Gegner erklärbar und kein geeigneter regulärer OMW-Abschluss.

Stage 2B verwendet stattdessen:

```text
BLUE-owned OPSZONE
+ BLUE local security remains
+ RED disappears
-> OPSZONE Defeated(RED)
-> onThreatCleared
-> CAS AUFTRAG:Cancel()
-> FLIGHTGROUP mission/task lifecycle becomes done
-> RTB
-> Landed
-> Arrived / AIRWING recovery
```

Es wird kein separater OMW-Präsenzscanner eingeführt.

## 8. AH-64-Talrouting

Die bereits in der PERSONNEL-Air-Resupply-Acceptance verwendete owner-authored Mission-Editor-PATHLINE ist identifiziert:

```text
OMW_FlightPath
```

Der dort bereits DCS-erprobte Korridorvertrag lautet:

```text
centerline: owner-authored OMW_FlightPath
outbound: 500 m directional right offset
return: reversed centerline + 500 m directional right offset
altitude: 500 ft AGL
```

Stage 2B hat diese Logik in einen gemeinsamen kleinen Adapter extrahiert:

```text
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
```

Der CAS-Adapter kopiert keine Tal-Koordinaten. Fixed-Wing-CAS erhält daraus keine automatische Korridorpflicht.

## 9. Guard-/QRF-Rückkehr und Recovery-Handoff

Die Gruppe muss nicht bis an das Warehouse-Gebäude pathfinden. Für Fortress Acceptance 2 wird der bereits bestehende operative Handoff verwendet:

```text
ZON_BLUE_GND_FORTRESS_ACCESS
```

Seine Bedeutung bleibt strikt:

```text
materialization / departure / return / recovery handoff
```

und ausdrücklich **nicht**:

```text
security perimeter
```

Rückkehr:

```text
mission end / explicit relief / OutOfAmmo path
-> AUFTRAG end/cancel as applicable
-> delayed ARMYGROUP:RTZ(ZON_BLUE_GND_FORTRESS_ACCESS, OffRoad)
-> physical approach/entry
-> Returned
-> MOOSE Warehouse AddAsset
-> CampaignState settlement
```

Das folgt dem bereits in Ground-Resupply akzeptierten expliziten RTZ-/Returned-Präzedenzfall. Kein nacktes `Destroy()` gilt als Rückkehr.

## 10. Guard-Rotation und OutOfAmmo

Produktive Rotationsdauer bleibt eine offene Projektentscheidung. Acceptance 2 prüft zunächst die **explizite Relief-Rückkehr nach Threat clear** für den Guard. Der Framework-Review bestätigt zusätzlich MOOSE-eigene OutOfAmmo-/Return-Konfiguration; deshalb wird kein eigener Ammo-Scheduler implementiert.

Spätere Produktionsrotation:

```text
ONGUARD
-> rotation condition OR OutOfAmmo OR explicit relief
-> mission closure
-> RTZ recovery handoff
-> Returned/Warehouse
-> personnel settlement
-> replacement only from available CampaignState PERSONNEL
```

## 11. Post-combat Reorder und RESUPPLY

Nach Settlement wird ausschließlich die vorhandene ResourceDemandPolicy verwendet. Für Fortress bleibt die bestehende PERSONNEL-Regel maßgeblich:

```text
target = 160
reorder = 128
comparison = strict BELOW
```

Stage 2B führt keinen neuen Threshold ein.

Da Guard + QRF im Acceptance-Lauf zusammen nur 18 Personen binden, können aus einem vollen Bestand von 160 selbst bei Totalverlust nur 142 verbleiben. Der normale End-to-End-Lauf kann deshalb die 128er-Schwelle nicht sinnvoll erzwingen. Die Abnahme wird getrennt:

```text
DCS Acceptance 2:
prove real post-combat reevaluation against current CampaignState

Lua contract test:
prove available=127 -> RESUPPLY MissionDemand
prove available=128 -> no demand under strict BELOW

existing accepted PERSONNEL resupply acceptance:
remains physical transport baseline
```

## 12. Aktueller Implementierungsstand

Implementiert und remote veröffentlicht:

```text
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua                  schema v2
scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua      schema v2
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua     schema v1
scripts/ground/OMW_GroundPersonnelDeploymentLedger.lua          schema v1
scripts/campaign/OMW_ResourceDemandCoordinator.lua              schema v1
mission/tests/fob-attack-support-demand/src/02-fob-attack-cas-dispatch-acceptance-2.lua
tools/build-fob-attack-cas-dispatch-acceptance-2.ps1            builder v2-2
```

MissionDemand contract CI hat nach den Stage-2B-Erweiterungen einen erfolgreichen Lauf erreicht. Das ist statische/Lua-Vertragsprüfung; DCS-Runtime-Verhalten bleibt `PENDING_DCS`.

## 13. DCS-Abnahmegrenze

Ein PASS benötigt mindestens:

```text
real Guard ONGUARD
OPSZONE Attacked(RED)
exactly one CAS_IMMEDIATE
real Jalalabad AH-64 FLIGHTGROUP
OMW_FlightPath corridor installed
CAS executing
real QRF ARMYGROUP + GROUNDATTACK
OPSZONE Defeated(RED)
CAS closure requested
CAS RTB
CAS Landed
CAS Arrived
Guard/QRF RTZ
Returned / Warehouse lifecycle
exact-once casualty settlement
post-combat PERSONNEL reorder evaluation
```

Erst danach darf der neue Stage-2B-Lifecycle als DCS-validiert dokumentiert werden.

## 14. Weiterhin offene Produktionswerte

```text
final installation-specific recovery geometry beyond current ACCESS handoff
guard rotation duration
counterattack force-sizing below 50 % maximum
maximum simultaneous response groups
optional threat-clear hold/BDA duration before CAS closure
production OPSZONE cadence
production CAS source-selection among multiple valid origins
```

Diese Werte werden nicht aus Acceptance-Konstanten stillschweigend zu Produktionsentscheidungen erhoben.
