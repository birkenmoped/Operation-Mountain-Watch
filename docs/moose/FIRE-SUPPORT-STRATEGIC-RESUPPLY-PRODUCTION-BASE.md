---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - generic Fire Support / Strategic Resupply production package boundary
  - production builder composition contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
---

# Fire Support / Strategic Resupply – Production Base

Status: SOURCE_REVIEWED / NICHT DCS-VALIDIERT

## Zweck

Der Builder

```text
tools/build-fire-support-strategic-resupply-production-base.ps1
```

erzeugt erstmals ein einzelnes, im DCS-Missionsskript ladbares Basispaket fuer die generische Fire-Support-/Strategic-Resupply-Architektur:

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
```

Das Paket ist ein **Composition Package**, keine fertige missionsspezifische Konfiguration. Es buendelt die bereits vorhandenen und getrennt getesteten Domain-, MOOSE- und Adapterbausteine, legt aber keine fehlenden Missionsparameter stillschweigend fest.

## Exportierter Vertrag

Nach dem Laden stellt das Bundle bereit:

```text
OMW.FireSupStratResupply
OMW.FireSupStratResupply.New(spec)
OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED = 1
```

`New(spec)` verdrahtet automatisch die im Bundle enthaltenen Module sowie standardmaessig:

```text
SiteRegistry
SupportProfiles
IdContract
```

Missionsspezifische Laufzeitobjekte bleiben Eingaben des Aufrufers, insbesondere BRIGADE-Instanzen, Guard-PATHLINE-/Template-Aufloesung, QRF-Zielkoordinaten, konkrete Perimeter, COMMANDER-Objekte, ARTY-/CAS-Geometrie, CampaignState-/Resource-Store und Transportresolver.

## Gebuendelte Funktionsbereiche

Das Production Base Bundle enthaelt die generische Verdrahtung fuer:

- persistente Guard-Demands und MOOSE-Guard-Lifecycle;
- die eng freigegebene Guard-PATHLINE-Materialisierungsausnahme;
- lokalen QRF-Dispatch ueber MOOSE;
- den autoritativen Installation-Attack-Incident-Pfad;
- optionale MOOSE-OPSZONE-Perimeter;
- optionale externe ARTY-/CAS-Eskalation ueber COMMANDER;
- strategische Resource-Shortage-Auswertung ohne eigene Ressourcenhoheit;
- Ground-/Air-Resupply ueber MOOSE OPSTRANSPORT/STORAGE;
- bestaetigungsgebundenes, idempotentes CampaignState-Settlement.

## Autoritaetsgrenzen

Der Builder aendert die bindende Ressourcen- und Missionsautoritaet nicht:

```text
CampaignState/store
= strategische Persistenz und Ressourcenhoheit

MOOSE organisation / AUFTRAG / COMMANDER / BRIGADE / WAREHOUSE / OPSTRANSPORT
= operative Auswahl, Rekrutierung und physischer Lifecycle

OMW FireSupStratResupply Base
= Demand-/Incident-Koordination und Adapterverdrahtung
```

Das Bundle nimmt **keine operative Asset-Vorauswahl** fuer MOOSE vor.

## Missionsgeometrie bleibt injiziert

Der Builder erfindet insbesondere nicht:

```text
Alarmradien
Installationsanker
QRF-Zielkoordinaten
ARTY-Ziele
CAS-Zonen/-Geometrie
Resupply-Routen oder Transportzonen
```

Diese Werte muessen aus den zustaendigen Mission-Editor-/Fachbaselines stammen und werden in die Runtime injiziert.

## ACCESS-Zonen

`ZON_BLUE_GND_*_ACCESS` verbleiben absichtlich im `SiteRegistry`, weil sie zum Convoy-/Access-Vertrag gehoeren koennen. Der Builder prueft jedoch separat, dass die gebuendelten Guard- und Perimeter-Implementierungen keine solchen Zonennamen referenzieren.

Damit gilt weiterhin strikt:

```text
ACCESS = Convoy/Access
ACCESS != Guard
ACCESS != Alarmperimeter
ACCESS != Incidentqualifikation
```

## Incident- und Perimetervertrag

Das Bundle verwendet den bereits reconcilierten Pfad:

```text
MOOSE OPSZONE / weitere Installation-Evidence
-> OMW_GroundInstallationAttackIncident
-> OMW_FireSupStratResupply_InstallationIncidentBridge
-> OMW_FireSupStratResupply_Base
-> initial lokale QRF
```

Ein Clear bzw. `OPSZONE:Defeated` ist kein Mission-Ende und schliesst den Installation-Incident nicht automatisch. ARTY/CAS bleiben explizite C2-Eskalation.

## Guard-Materialisierung

Die produktive Ausnahme bleibt auf den bereits vom Projektinhaber freigegebenen engen Scope begrenzt: exakte Guard-Einheitengeometrie am ersten Segment der owner-authored Guard-PATHLINE unmittelbar vor der MOOSE-Warehouse-Materialisierung. Rekrutierung, Assetwahl, PLATOON-/ARMYGROUP-/AUFTRAG-Lifecycle bleiben bei MOOSE.

Diese Ausnahme wird durch das Production Base Bundle weder auf QRF noch auf ARTY, CAS, Convoys oder Resupply erweitert.

## Build-Schutz

Der Builder:

- prueft alle erforderlichen Quelldateien und deren `SchemaVersion`-Vertrag;
- prueft zentrale Runtime-/Materialisierungs-/Incident-/Resupply-Marker;
- verbietet MIST, `MissionScripting.lua`-Manipulation und `os.execute` im gebuendelten Source;
- prueft Guard-/Perimeter-Source separat auf verbotene `ZON_BLUE_GND_*_ACCESS`-Kopplung;
- schreibt UTF-8 ohne BOM;
- veraendert keine `.miz`;
- schreibt Git-Commit, Builder-Version sowie Builder- und Bundle-SHA-256 in die Build-Ausgabe.

## Verifikationsstatus

Der Source- und Packaging-Vertrag ist auf dem Branch implementiert. Die reale lokale Builder-Ausgabe einschliesslich SHA-256 muss vom Projektinhaber erzeugt und zurueckgemeldet werden. Erst danach kann ein konkretes Bundle eindeutig referenziert werden.

Eine DCS-Validierung dieses vollstaendigen Production Base Bundles ist noch **nicht** erfolgt. Bestehende DCS-PASS-Ergebnisse einzelner Teilpfade, insbesondere der Gate-5-Guard-Baseline und historischer Stage-3-Szenarien, werden nicht auf das neue Gesamtbundle verallgemeinert.
