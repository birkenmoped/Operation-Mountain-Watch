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
  - final installation-specific security or return geometry
  - final guard rotation duration
  - final counterattack force-sizing algorithm beyond the approved 50 percent reserve boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
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

Die während Stage 2B gewonnenen, **projektweit für Ground Operations relevanten** Warehouse-/Homezone-/Return-Erkenntnisse sind zusätzlich in folgendem Querschnittsdokument festgehalten:

```text
docs/moose/GROUND-WAREHOUSE-RETURN-HOMEZONE-LIFECYCLE.md
```

## 2. Stage-2B-Zielbild

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
|   -> CampaignState PERSONNEL reservation at origin node
|   -> preserve 50 % defence reserve floor
|   -> origin Ground Warehouse / BRIGADE / PLATOON / ARMYGROUP
|   -> AUFTRAG:NewGROUNDATTACK(real RED group)
|   -> threat clear / relief or MOOSE OutOfAmmo lifecycle
|   -> normal MOOSE return-to-origin lifecycle wherever sufficient
|   -> ARMYGROUP homezone derived from origin LEGION/Warehouse spawnzone
|   -> Returned / original Legion-Warehouse AddAsset
|   -> exactly-once CampaignState settlement against original deployment
|
+-> post-combat resource reevaluation
    -> existing ResourceDemandPolicy
    -> MissionDemand RESUPPLY only if existing PERSONNEL threshold is crossed
    -> existing PERSONNEL physical resupply orchestration remains unchanged
```

Eine explizite `ZON_BLUE_GND_FORTRESS_ACCESS`-Rückkehr ist **kein allgemeiner Bestandteil dieses Vertrags**. Sie ist nur eine mögliche, standortspezifische MOOSE-Konfiguration bzw. Acceptance-Fixture, wenn die native Warehouse-Homezone geometrisch nicht genügt.

## 3. MOOSE-first-Prüfung – Ergebnis

Der tatsächlich gepinnte `Moose.lua` bestätigt die benötigten Framework-Pfade. Die Stage-2B-API-Liste und der Validierungsstatus stehen in:

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
WAREHOUSE default ground spawnzone = 250 m radius around Warehouse object
WAREHOUSE default warehouse zone = 500 m radius around Warehouse object
WAREHOUSE:SetSpawnZone(zone, maxdist) can replace the spawnzone through public API
LEGION assigns opsgroup.homezone = self.spawnzone
OPSGROUP/AUFTRAG ReturnToLegion semantics exist
ARMYGROUP:RTZ uses explicit Zone or self.homezone
ARMYGROUP RTZ uses zone:GetRandomCoordinate() when outside the return zone
ARMYGROUP Returned -> original legion __AddAsset(...)
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
release deployment reservation
-> returned survivors become available again

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
CampaignState reservation at origin
-> origin MOOSE Ground Warehouse / BRIGADE
-> QRF PLATOON
-> ARMYGROUP
-> AUFTRAG:NewGROUNDATTACK(real RED group from OPSZONE scanned group set)
```

Der gepinnte MOOSE-Source erklärt bei `GROUNDATTACK`, dass DCS-Attack-Group/-Unit-Tasks für Ground nicht geeignet sind und MOOSE deshalb den Angreifer in die Nähe des Zielobjekts führt, wo die Gruppe selbständig bekämpft. Genau dieser Framework-Weg wird wiederverwendet.

### Herkunftsregel

Der Einsatzort ändert die Herkunft nicht.

```text
asset from Wright supports Fortress
-> remains Wright-origin asset
-> returns through Wright-origin MOOSE lifecycle
-> is credited to Wright-origin Legion/Warehouse
-> CampaignState settlement uses Wright-origin deployment/node
```

Es darf keine Logik geben, die den angegriffenen oder nächstgelegenen Standort nachträglich als Rückkehr-Warehouse auswählt.

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

## 9. Ground-Return: MOOSE zuerst, ACCESS nur bei Bedarf

Die neue Source-Prüfung korrigiert die bisher zu enge Fortress-Formulierung.

### 9.1 MOOSE-Default

Ein normales Ground-Warehouse besitzt im gepinnten Source standardmäßig:

```text
Warehouse zone:
center = Warehouse object
radius = 500 m

spawnzone:
center = Warehouse object
radius = 250 m
```

Bei der Erzeugung des `ARMYGROUP` setzt `LEGION`:

```text
opsgroup.homezone = self.spawnzone
```

`ARMYGROUP:RTZ()` verwendet:

```text
explicit Zone OR self.homezone
```

und löst innerhalb der Zone `Returned()` aus. Außerhalb der Zone wird ein zufälliger Punkt in der Zone als Wegpunkt verwendet.

### 9.2 Bedeutung für OMW

MOOSE verlangt damit **nicht**, dass die Gruppe bis zum Warehouse-Objekt selbst fährt. Der native 250-m-Kreis kann bereits genügen.

Ob er an einem realen OMW-FOB/COP genügt, ist jedoch eine DCS-/Geometriefrage: `GetRandomCoordinate()` kann innerhalb des 250-m-Kreises einen Punkt hinter HESCOs, Mauern, Gebäuden oder anderen Statics wählen.

Deshalb werden die vorhandenen ACCESS-Zonen vorerst nicht entfernt.

### 9.3 Öffentliche Konfiguration statt eigener Return-Logik

Wenn der MOOSE-Default an einem Standort nicht sauber funktioniert, ist die nächste Prioritätsstufe:

```lua
WAREHOUSE:SetSpawnZone(ZON_BLUE_GND_<ORIGIN>_ACCESS, maxdist)
```

Dann ist die ACCESS-Zone die MOOSE-eigene `spawnzone` und damit automatisch die `homezone` der aus dieser Legion erzeugten Ground-Gruppen.

Wichtig: `SetSpawnZone(...)` beeinflusst auch die Materialisierung. Spawn, Departure und Return müssen gemeinsam getestet werden.

### 9.4 Explizites RTZ ist kein allgemeiner Standard

Der früher akzeptierte Ground-Resupply-Pfad mit

```text
SetReturnToLegion(false)
-> MissionDone
-> explicit ARMYGROUP:RTZ(origin ACCESS)
```

bleibt ein gültiger technischer Präzedenzfall für genau seinen Scope. Er beweist aber nicht, dass jede Ground-Mission explizites RTZ oder eine ACCESS-Zone benötigt.

Für temporäre QRF-/Response-Kräfte soll der normale MOOSE-Return-to-Legion-Lifecycle Vorrang haben, wenn er die Anforderung erfüllt.

## 10. Guard-Rotation und OutOfAmmo

Produktive Rotationsdauer bleibt eine offene Projektentscheidung. Der Framework-Review bestätigt MOOSE-eigene OutOfAmmo-/Return-Konfiguration; deshalb wird kein eigener Ammo-Scheduler implementiert.

Geplanter Produktions-Lifecycle:

```text
ONGUARD
-> rotation condition OR OutOfAmmo OR explicit relief
-> normal MOOSE mission closure
-> ReturnToLegion
-> ARMYGROUP RTZ to origin homezone
-> Returned / original Warehouse
-> CampaignState personnel settlement
-> replacement only from available CampaignState PERSONNEL
```

Nur wenn die origin `homezone` in DCS nicht geeignet ist, wird sie über die öffentliche Warehouse-Spawnzone-Konfiguration auf eine validierte origin-ACCESS-Zone gelegt.

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

## 12. Aktueller Implementierungsstand und notwendige Reconciliation vor DCS

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

Der aktuelle Acceptance-Harness enthält noch die ältere testlokale Kombination:

```text
BRIGADE:SetSpawnZone(Fortress ACCESS, ...)
Guard/QRF AUFTRAG:SetReturnToLegion(false)
explicit ARMYGROUP:RTZ(Fortress ACCESS, ...)
```

Diese Kombination wird **vor dem nächsten DCS-Lauf noch einmal gegen den jetzt dokumentierten MOOSE-Default-/Homezone-Vertrag reconciliert**. Sie darf nicht durch einen DCS-PASS versehentlich zur allgemeinen Ground-Produktionsarchitektur werden.

## 13. Nächste Testreihenfolge

Vor einem vollständigen Stage-2B-PASS sind zwei Fragen getrennt zu behandeln.

### 13.1 Ground-Return-Geometrie

Erste Priorität ist der einfachste native MOOSE-Pfad:

```text
origin Warehouse / BRIGADE
no explicit return-zone override for the return test
normal ReturnToLegion
ARMYGROUP self.homezone = origin Warehouse spawnzone
physical return
Returned
origin Warehouse AddAsset
```

Zu prüfen:

```text
250 m default homezone physically sufficient?
no HESCO/static/building collision?
no visible teleport?
return cleanup visually plausible?
correct origin Legion/Warehouse credit?
```

Wenn dieser Pfad an Fortress nicht genügt, folgt als zweite Stufe:

```text
WAREHOUSE:SetSpawnZone(ZON_BLUE_GND_FORTRESS_ACCESS, validated maxdist)
normal ReturnToLegion
no separate explicit RTZ controller
```

Erst wenn auch diese öffentliche MOOSE-Konfiguration nicht genügt, ist eine zusätzliche Lösung zu prüfen.

### 13.2 Stage-2B Response-Lifecycle

Ein vollständiger Stage-2B-PASS benötigt danach mindestens:

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
Guard/QRF normal return-to-origin lifecycle
Returned / original Warehouse lifecycle
exact-once casualty settlement
post-combat PERSONNEL reorder evaluation
```

## 14. Projektweite Regressionen vor Generalisierung

Da der Ground-Return-Vertrag mehrere bestehende Missionstypen betrifft, muss vor einer produktionsweiten Umstellung zusätzlich geprüft werden:

```text
1. existing Ground SUPPLY convoy accepted explicit-RTZ path remains valid
2. missions intentionally using SetReturnToLegion(false) keep their field-persistence semantics
3. road-aligned Warehouse spawn adapter remains compatible with any SetSpawnZone change
4. origin A -> mission at B -> return to A is proven at least once
5. CampaignState settlement is bound to original deployment/node and is idempotent
6. immobile ARMYGROUP teleport branch remains excluded from observable OMW use
```

## 15. Weiterhin offene Produktionswerte

```text
site-by-site decision: native 250 m homezone or configured ACCESS spawn/homezone
guard rotation duration
counterattack force-sizing below 50 % maximum
maximum simultaneous response groups
optional threat-clear hold/BDA duration before CAS closure
production OPSZONE cadence
production CAS source-selection among multiple valid origins
```

Diese Werte werden nicht aus Acceptance-Konstanten stillschweigend zu Produktionsentscheidungen erhoben.
