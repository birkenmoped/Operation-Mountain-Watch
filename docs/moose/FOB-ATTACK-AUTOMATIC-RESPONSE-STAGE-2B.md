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

Stage 2B erweitert diesen Eingang zu einer vollständigen, aber weiterhin MOOSE-first ausgeführten Reaktion. Der vorhandene MissionDemand- und CampaignState-Vertrag bleibt erhalten; Stage 2B darf keine zweite Ressourcenautorität und keine parallele Spawn-/Routing-/Lifecycle-Welt einführen.

## 2. Zielbild

Ein qualifizierter FOB-/COP-Angriff löst mehrere koordinierte Reaktionen aus:

```text
qualified installation threat
|
+-> CAS_IMMEDIATE
|   -> vorhandener AIRWING / SQUADRON
|   -> MOOSE AUFTRAG CAS
|   -> reale Flight-Materialisierung
|   -> CAS execution
|   -> threat cleared / mission closure
|   -> RTB / physical recovery
|
+-> LOCAL_COUNTERATTACK
|   -> CampaignState personnel availability check
|   -> preserve installation defence reserve
|   -> MOOSE BRIGADE / PLATOON / ARMYGROUP materialization
|   -> MOOSE ground mission against hostile force
|   -> mission end or OutOfAmmo
|   -> RTZ to recovery handoff
|   -> Returned / Warehouse AddAsset
|   -> CampaignState survivor/loss settlement
|
+-> post-combat resource reevaluation
    -> if personnel below existing reorder threshold
    -> existing PERSONNEL RESUPPLY orchestration
```

CAS, lokale Gegenwehr und spätere Versorgung sind damit getrennte Antworten auf denselben strategischen Vorfall. Sie dürfen sich gegenseitig nicht als Ressourcenautorität ersetzen.

## 3. Lokale Selbstverteidigung und 50-Prozent-Grenze

Der Projektinhaber hat für die lokale Gegenangriffskraft folgende Grenze festgelegt:

```text
mindestens 50 % des installationsbezogenen PERSONNEL-Target-/Maximalbestands
bleiben als strategische Verteidigungsreserve gebunden bzw. nicht für den Gegenangriff disponierbar.
```

Daraus folgt:

```text
counterattack commitment
<= available personnel above defence reserve floor
<= 50 % of installation personnel target
```

Die 50-%-Grenze ist ein Maximum, kein Sollwert. Die physische Gegenangriffskraft wird nur in der für den Angriff erforderlichen und im verfügbaren MOOSE-/OMW-Templatebestand darstellbaren Größe materialisiert.

Beispiel Fortress mit aktuellem Target 160:

```text
personnel target: 160
defence reserve floor: 80
maximum simultaneously committed outside the reserve: 80
```

Bereits gebundene Guard-/Sentry-Personen zählen als nicht verfügbare CampaignState-Ressourcen und dürfen nicht erneut disponiert werden.

## 4. Physische lokale Gegenangriffskraft

Die Gegenangriffskraft wird nicht mit einem direkten `SPAWN:`-Shortcut erzeugt. Vorgesehen ist die vorhandene OMW-/MOOSE-Kette:

```text
CampaignState reservation/commitment
-> existing Ground Warehouse / BRIGADE
-> PLATOON / template asset
-> ARMYGROUP
-> MOOSE AUFTRAG suitable for the verified counterattack requirement
```

Die konkrete AUFTRAG-Art wird erst nach der verbindlichen MOOSE-first-Prüfung gegen Dokumentation, gepinnten `Moose.lua` und offizielle Beispiele festgelegt. Keine eigene Targeting- oder Weltobjekt-Scanlogik wird vor dieser Prüfung implementiert.

## 5. Rückkehrvertrag für Guard und Gegenangriff

Die physische Rückkehr darf nicht voraussetzen, dass DCS-Ground-AI bis direkt an ein Warehouse-Gebäude gelangt. Innerhalb von FOBs/COPs können HESCOs, Mauern, Statics, Zelte und andere Objekte den letzten Weg blockieren.

Deshalb gilt für lokale Infanterie der geplante Recovery-Handoff:

```text
mission end / rotation / OutOfAmmo
-> MOOSE RTZ toward installation return/recovery area
-> group reaches validated recovery handoff area
-> physical return considered complete
-> normal MOOSE Returned / Legion-Warehouse AddAsset lifecycle
-> CampaignState settlement
```

Der Recovery-Handoff ist **kein beobachtbares Teleportieren im Einsatzraum**. Er muss an einem pro Installation validierten Punkt beziehungsweise Radius liegen, an dem die Gruppe eindeutig zum FOB/COP zurückgekehrt ist und das anschließende physische Cleanup plausibel bleibt.

Ein nacktes `Destroy()` als strategische Rückgabe ist nicht zulässig. CampaignState darf Rückkehr nur aufgrund des bestätigten MOOSE-Lifecycle übernehmen.

## 6. Guard-Rotation

Der bestehende Fortress-Guard/Sentry-`ONGUARD`-Auftrag ist funktional dauerhaft. Stage 2B ergänzt daher einen endlichen Guard-Lifecycle:

```text
Warehouse
-> Guard materialization
-> ONGUARD
-> rotation condition OR OutOfAmmo OR explicit relief condition
-> mission closure
-> RTZ to recovery handoff
-> Returned / Warehouse
-> CampaignState survivor/loss settlement
-> replacement Guard only from actually available personnel
```

Die endgültige Rotationsdauer wird nicht in diesem Dokument festgelegt. Sie ist vor Produktion als eigene Designkonstante zu entscheiden und zu testen.

## 7. OutOfAmmo

Leergeschossene lokale Infanterie bleibt nicht unbegrenzt als aktive Guard-/Counterattack-Gruppe im Feld.

Geplanter Vertrag:

```text
MOOSE OutOfAmmo
-> disengage / return request
-> RTZ to installation recovery handoff
-> Returned / Warehouse
-> settlement
```

Ob und welche MOOSE-eigene OutOfAmmo-/Retreat-/RTZ-Konfiguration direkt verwendet wird, muss vor Implementierung im gepinnten Source und in den offiziellen Beispielen verifiziert werden. Kein eigener Munitions-Polling-Scheduler wird vor einer nachgewiesenen MOOSE-Lücke eingeführt.

## 8. Verluste und CampaignState

Materialisierte PERSONNEL-Ressourcen werden beim Deployment bereits aus dem verfügbaren CampaignState-Pool gebunden beziehungsweise entnommen. Gefallene Soldaten dürfen deshalb beim Tod nicht ein zweites Mal aus demselben verfügbaren Bestand abgezogen werden.

Settlement-Prinzip:

```text
deployed personnel
-> survivors physically return
-> survivors credited back exactly once
-> non-returning confirmed losses remain unavailable
-> loss audit updated exactly once
```

Nach abgeschlossenem Settlement wird der vorhandene PERSONNEL-Reorder-Vertrag neu bewertet. Für Fortress ist im aktuellen Ground-Stock-Modell die bestehende Schwelle maßgeblich; Stage 2B führt keine neue Resupply-Schwelle ein.

```text
post-combat personnel below existing reorder threshold
-> existing MissionDemand RESUPPLY path
-> existing PERSONNEL transport/orchestration
```

Damit wird kein paralleler Resupply-Mechanismus für Stage 2B entwickelt.

## 9. CAS-Lifecycle und Missionsende

Ein Stage-2B-PASS darf nicht bei `CAS_EXECUTING` enden. Der beobachtete Dauerorbit nach Vernichtung aller Feinde zeigt, dass die vollständige Reaktion zusätzlich eine saubere Missionsbeendigung braucht.

Zielzustand:

```text
CAS_IMMEDIATE demand
-> dispatch
-> flight on mission
-> CAS executing
-> hostile installation threat eliminated
-> CAS mission closure through verified MOOSE lifecycle
-> RTB
-> landing / physical recovery
-> strategic asset lifecycle settlement
```

Ein bloßes Warten bis Fuel-Low/Bingo ist nicht die geplante reguläre Abschlusslogik für einen erfolgreich beseitigten FOB-/COP-Angriff.

Die konkrete MOOSE-native Methode beziehungsweise FSM-Kombination für das missionsbezogene Beenden des CAS-Auftrags wird vor Implementierung erneut gegen Dokumentation, gepinnten Source und offizielle Beispiele geprüft. Eine eigene Target-Clear-/RTB-Parallelsteuerung darf nur nach dokumentierter MOOSE-Lücke und ausdrücklicher Ausnahmefreigabe entstehen.

## 10. CAS-Helikopter-Routing

CAS-Helikopter sollen nicht geometrisch direkt über hohe Gebirgskämme zum Einsatzgebiet fliegen. Für Rotary-Wing-CAS ist die bereits im OMW-Lufttransport eingeführte und getestete Tal-/Korridorführung wiederzuverwenden.

Geplanter Vertrag:

```text
helicopter origin
-> existing validated valley/transit corridor
-> tactical ingress from final corridor anchor
-> CAS area
-> tactical egress
-> approved corridor return
-> home base
```

Stage 2B darf die Talroute nicht als zweite hart codierte Koordinatenkopie duplizieren. Vor Implementierung ist die aktuell maßgebliche Lufttransport-Route im Repository zu identifizieren und als gemeinsame Route-/Corridor-Definition beziehungsweise über den bereits vorhandenen öffentlichen OMW-Pfad wiederzuverwenden.

Diese Anforderung gilt für CAS-Helikopter. Fixed-Wing-CAS erhält daraus nicht automatisch dieselbe Talroute.

## 11. Geplanter Acceptance-Schnitt

Acceptance 2 wird gegenüber dem bisherigen reinen Dispatch-Nachweis erweitert. Der Test muss mindestens folgende operative Teilketten unterscheiden und protokollieren:

```text
A. Threat -> CAS
   demand created
   CAS dispatched
   real FLIGHTGROUP observed
   CAS executing
   threat cleared
   CAS mission closure
   RTB/recovery observed

B. Threat -> local counterattack
   available personnel evaluated
   50 % reserve floor preserved
   response force committed
   real ARMYGROUP materialized
   counterattack mission executed
   mission end or OutOfAmmo return path
   RTZ/recovery handoff
   Returned/Warehouse observed

C. Post-combat settlement
   survivors/losses settled exactly once
   personnel stock reevaluated
   existing PERSONNEL RESUPPLY demand appears if and only if the existing threshold is crossed
```

Ein erster technischer DCS-Slice darf diese Punkte in mehreren reproduzierbaren Acceptance-Läufen aufteilen, wenn ein einzelner Lauf dadurch unnötig lang oder diagnostisch unklar würde. Die fachliche Stage-2B-Abnahme bleibt jedoch erst vollständig, wenn alle drei Teilketten belegt sind.

## 12. Offene, entscheidungspflichtige Werte

Vor produktiver Generalisierung bleiben bewusst offen:

```text
installation-specific recovery handoff position/radius
guard rotation duration
counterattack force-sizing ratio below the 50 % maximum
maximum simultaneous local response groups
CAS threat-clear confirmation/hold time before mission closure
production OPSZONE cadence
production CAS source-selection between multiple valid origins
```

Diese Werte werden nicht stillschweigend aus Acceptance-Konstanten zu Produktionsregeln erhoben.

## 13. MOOSE-first Prüfauftrag vor Implementierung

Vor Stage-2B-Codeänderungen sind mindestens zu prüfen:

```text
AUFTRAG CAS completion / cancel / Done / Success lifecycle
FLIGHTGROUP RTB/recovery lifecycle
AIRWING/SQUADRON mission and asset return lifecycle
ARMYGROUP RTZ / Returned / ReturnToLegion
ARMYGROUP / OPSGROUP OutOfAmmo behavior and supported configuration
suitable AUFTRAG type for local infantry counterattack
existing OMW helicopter valley/transit route implementation
existing PERSONNEL loss/return settlement and RESUPPLY orchestration
```

Jede neue MOOSE-Nutzung wird im Stage-2B-Klassenindex und nach DCS-Bestätigung gegebenenfalls im Master-Index/`VERIFIED-METHODS.md` nachgeführt.
