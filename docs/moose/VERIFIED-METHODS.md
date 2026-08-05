---
document_id: OMW-MOOSE-VERIFIED-METHODS
status: BINDING
document_class: TECHNICAL_EVIDENCE_REGISTER
owning_policy: OMW-GOV-001
authoritative_for:
  - project method-level MOOSE evidence
  - AIRWING, SQUADRON and WAREHOUSE lifecycle evidence
  - vertical-helicopter option evidence and limitations
  - COMMANDER start and selection sequence
  - source-reviewed WAREHOUSE parking method boundaries
  - documented validation scope and limitations
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - method register without lifecycle timing, vertical-option and COMMANDER details
superseded_by:
source_branch: agent/consolidate-air-ops-lifecycle-governance
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Verifizierte MOOSE-Methoden

## 1. Zweck

Dieses Register führt praktisch geprüfte MOOSE-Aufrufe und den jeweils belegten OMW-Einsatzumfang. Ein Eintrag belegt nur Methode, Version, Teststand und ausdrücklich genannte Wirkung. Er validiert weder die gesamte Klasse noch andere Airbases, Missionen oder MOOSE-Versionen.

Ergänzende Lifecycle-Autorität:

- [`OMW-MOOSE-AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE`](AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md)

Historische Vollfassung:

- [`Legacy-Methodenregister`](../evidence/source-records/legacy-moose-verified-methods.md)

## 2. Gepinnter MOOSE-Stand

```yaml
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
evidence_type: RECONSTRUCTED_FROM_IDENTICAL_ARTIFACT
```

Bei einem anderen `Moose.lua`-Hash ist die Methoden- und Lifecycle-Prüfung zu wiederholen.

## 3. AIRBASE

| Methode | Status | Belegter Umfang |
|---|---|---|
| `AIRBASE:FindByName()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Airbase-Auflösung in Jalalabad, Bagram, Kandahar, Salerno und Tarinkot |
| `AIRBASE:FindByID()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Tarinkot ID 9 |
| `GetName()` / `GetID()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Identitätsprüfung |
| `GetParkingSpotsTable()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Parkingdump und ME-/TerminalID-Kalibrierung |
| `SetParkingSpotBlacklist()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | dokumentierte Referenzknoten; tatsächliche Unitplatzierung bleibt separat |
| `FindFreeParkingSpotForAircraft(group, terminaltype, scanradius, scanunits, scanstatics, scanscenery, verysafe, nspots, parkingdata)` | `SOURCE_REVIEWED` | öffentliche parametrierbare Freiparkroutine; wird von `WAREHOUSE:_FindParkingForAssets()` nicht verwendet |

## 4. SQUADRON und AIRWING-Lifecycle

### 4.1 `SQUADRON:New()`

Status: `VALIDATED_FOR_DOCUMENTED_SCOPE`

Belegt:

- `Ngroups` ist die Anzahl zu registrierender Assetgruppen;
- das SQUADRON-/COHORT-Objekt wird konstruiert;
- positive Runtime-Bestandsprüfung über `squadron.assets` ist zu diesem Zeitpunkt nicht zulässig.

### 4.2 `AIRWING:AddSquadron()`

Status: `VALIDATED_FOR_DOCUMENTED_SCOPE`

Quellcode- und Runtimebefund:

```text
SQUADRON wird in airwing.cohorts eingetragen
AIRWING:AddAssetToSquadron() registriert Ngroups im Warehouse-Stock
automatisches RELOCATECOHORT-Payload wird registriert
Squadron:SetAirwing() wird gesetzt
SQUADRON-FSM wird bei Bedarf gestartet
```

Wichtig:

```text
AddSquadron PASS
=> airwing.stock steigt synchron
!= squadron.assets enthält bereits den späteren Bestand
```

### 4.3 `AIRWING:Start()`

Status: `VALIDATED_FOR_DOCUMENTED_SCOPE`

Tarinkot G7 bestätigte:

```text
vor Start:
  airwing.stock = 5
  squadron.assets = 0/0/0 als erwarteter Deferred-Zustand

nach Start und Initialisierung:
  AIRWING Running
  squadron.assets = 2/2/1
  stock = 5
  missionQueue = 0
  transportQueue = 0
  requestQueue = 0
  opsGroups = 0
```

Die post-start SQUADRON-Bindung erfolgt über den WAREHOUSE-/LEGION-Pfad und `COHORT:AddAsset()`.

### 4.4 Weitere AIRWING-Methoden

| Methode | Status | Grenze |
|---|---|---|
| `AIRWING:New()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion mit Warehouse-Anker |
| `SetAirbase()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | explizite Airbase-Bindung |
| `SetTakeoffCold()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konfigurationszustand; tatsächlicher Kaltstart separat |
| `SetSafeParkingOn()` | `SOURCE_REVIEWED` | setzt im gepinnten `Warehouse.lua` nur `self.safeparking`; das Feld wird im WAREHOUSE-Pfad nicht gelesen und ändert die Parking-Suche nicht |
| `AddSquadron()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Cohort-, Stock- und Relocation-Payload-Registrierung |
| `NewPayload()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Rollen-Payloadregistrierung |
| `GetSquadron()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | SQUADRON-Auflösung nach Registrierung |
| `GetOpsGroups()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Idle-Knoten ohne Runtime-OPSGROUPs |
| `Start()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Grundstart und post-start Assetbindung |

## 5. WAREHOUSE-Parking

Vollständiger Quellenbericht:

- [`OMW-MOOSE-WAREHOUSE-PARKING-OVERRIDE-RESEARCH`](WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md)

| Methode/Feld | Status | Belegter Umfang |
|---|---|---|
| `WAREHOUSE:_FindParkingForAssets(airbase, assets)` | `SOURCE_REVIEWED` | interne Asset-Parkplatzsuche; kein dokumentierter Hook; lokale Werte `25/true/true/false`; `verysafe=false` lokal, aber unbenutzt |
| `WAREHOUSE:SetSafeParkingOn/Off()` | `SOURCE_REVIEWED` | schreibt nur `self.safeparking`; im gepinnten und geprüften aktuellen `Warehouse.lua` existiert kein Leser dieses Feldes |
| `WAREHOUSE:SetAllowSpawnOnClientParking()` | `SOURCE_REVIEWED` | entfernt Client-Templatekoordinaten aus der Hindernisliste; ändert Static-Scan und Überlappungsprüfung nicht; für Tarinkot fachlich gesperrt |
| `WAREHOUSE:SetParkingIDs()` | `SOURCE_REVIEWED` | begrenzt Warehouse-Kandidaten; ändert Scanparameter und Überlappungsprüfung nicht |
| `asset.parkingIDs` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | post-start an SQUADRON-Assets gebunden; umgeht Terminal-/BW-Filter, aber nicht Hindernis-/Überlappungsprüfung |

Die offizielle AIRBASE-Methode mit denselben fünf Parametern ist kein indirekter WAREHOUSE-Setter. Ein Ersatz von `_FindParkingForAssets()` bleibt ein interner Runtime-Override und ist nicht autorisiert.

Dieser Abschnitt ist ein Source-Nachweis, kein DCS-Verhaltensnachweis. Der konkrete Tarinkot-Blocker ist noch nicht durch ausgegebenen Hindernisnamen bestätigt.

## 6. Helikopter-Vertikaloption

### 6.1 `AIRWING:SetOptionPreferVerticalLanding()`

Status: `VALIDATED_CONFIGURATION_AND_SOURCE_PATH`

Belegt:

- Methode ist im gepinnten MOOSE-Stand vorhanden;
- sie setzt `AIRWING.OptionPreferVerticalLanding = true`;
- Tarinkot G7 setzte sie vor `AIRWING:Start()`;
- der Idle-Foundation-Test bestätigte nur den Konfigurationszustand, nicht den Abflug.

### 6.2 Weitergabe im nativen Dispatch

Der geprüfte AIRWING-Quellpfad übergibt bei `FlightOnMission`:

```lua
if self.OptionPreferVerticalLanding then
  FlightGroup:SetOptionPreferVertical()
end
```

`FLIGHTGROUP:SetOptionPreferVertical()` setzt intern:

```lua
self:GetGroup():OptionPreferVerticalLanding()
```

und damit die DCS-AI-Option `AI.Option.Air.id.PREFER_VERTICAL`.

Status der Einzelmethoden:

| Methode | Status | Grenze |
|---|---|---|
| `AIRWING:SetOptionPreferVerticalLanding()` | `VALIDATED_CONFIGURATION_AND_SOURCE_PATH` | vor Start gesetzt; Weitergabepfad quellengeprüft |
| `FLIGHTGROUP:SetOptionPreferVertical()` | `SOURCE_REVIEWED` | tatsächliche Anwendung in G8 noch telemetrisch zu bestätigen |
| `CONTROLLABLE:OptionPreferVerticalLanding()` | `SOURCE_REVIEWED` | DCS-Option bekannt; tatsächlicher Tarinkot-Abflug noch nicht akzeptiert |

Nicht belegt:

- tatsächlicher vertikaler Abflug in Tarinkot;
- Vermeidung jeder Runway-/Taxi-Nutzung für alle Helikoptertypen;
- standalone FLIGHTGROUP- oder Raw-SPAWN-Experimente als Produktionspfad.

Diese Punkte gehören in den isolierten nativen G8-AIRWING-/AUFTRAG-Dispatch.

## 7. COMMANDER

### 7.1 Verbindliche Sequenz

Status: `VALIDATED_FOR_DOCUMENTED_SCOPE` durch Salerno Stage 18.

```lua
local commander = COMMANDER:New(...)
commander:AddAirwing(airwing)
commander:Start()
local canMission = commander:CanMission(mission)
commander:AddMission(mission)
commander:Status()
```

### 7.2 Methodenwirkung

| Methode | Status | Belegter Umfang |
|---|---|---|
| `COMMANDER:New()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | FSM im Ausgangszustand `NotReadyYet` |
| `AddAirwing()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | ruft `AddLegion()` auf und verknüpft AIRWING; startet COMMANDER nicht |
| `Start()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `NotReadyYet -> OnDuty`, startet nötigenfalls LEGIONs und Statuszyklus |
| `CanMission()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Salerno CAS-Eignung |
| `AddMission()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Auftrag in COMMANDER-Queue |
| `Status()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | normaler Auswahlpfad und `CheckMissionQueue()` |

Salerno bestätigte die Kette:

```text
COMMANDER OnDuty
-> CanMission true
-> MissionAssign
-> AIRWING MissionRequest
-> erwartetes AH-64-Asset OpsOnMission
-> AUFTRAG started
```

`COMMANDER:AddAirwing()` ohne `COMMANDER:Start()` ist kein gültiger Dispatchaufbau.

## 8. Wrapper und Hilfsklassen

- `GROUP`, `UNIT`, `STATIC` und `ZONE`: `VALIDATED_FOR_DOCUMENTED_SCOPE` für Objekt- und Templateprüfung;
- `_DATABASE`: `INTERNAL_RESTRICTED`, nur Diagnose und Templateprüfung;
- `SCHEDULER`: `VALIDATED_FOR_DOCUMENTED_SCOPE` für geordnete verzögerte Post-Start-Inspektion.

## 9. Tarinkot G7 – akzeptierter Nachweis

```text
Testdatum: 2026-08-04
DCS: 2.9.28.26385 MT
Branch: agent/tarinkot-object-contract-reconciliation
Commit: add569fb3231a5563d9c89f865cce7bd764bc0bb
BuilderVersion: TKOT-G7-AIRWING-FOUNDATION-3
Bundle SHA-256: 7018f4e388a349f91bc4169e6200226a32c001e3c4afdbd4daf69b538de2dea8
MIZ SHA-256: 86ba08f46c78a94cdf6eb54f7abe85145bdabe2817e7a2a89f2cec34932866bb
DCS log SHA-256: aeacc9fc9270dc033ed49a41eb1b3264880710265386f1d21e0c787a22739e52
Debrief SHA-256: 8a33b90efdf57f92a95ff2b07d0c016555d79776da3b708367f63ef09a284588
```

Ergebnis:

```text
G7 AIRWING/SQUADRON/Payload foundation: PASS
Observer client detected: 1
Observer client blocking: 0
Unexpected mission/spawn: 0
Graveyard: empty
```

Der Endmarker `activePlayerClients=0` ist für diesen Lauf kein gültiger Detektionswert, weil der Harness den Rückgabewert nach protokollierter Erkennung auf null überschrieb. Die Rohmarker `ACTIVE_PLAYER_CLIENT_COUNT=1` bleiben maßgeblich. Künftige Tests müssen `detected`, `allowed` und `blocking` getrennt ausgeben.

## 10. Nicht durch G7 belegt

- nativer AUFTRAG-Dispatch in Tarinkot;
- tatsächlicher vertikaler Helikopterabflug;
- taktische Zielbekämpfung;
- Rückkehr, Landung und Recovery;
- dauerhafte Verlust- und Bestandsbuchung;
- OPSTRANSPORT;
- COMMANDER-Auswahl für Tarinkot;
- Multiplayer- oder Endurance-Acceptance.

## 11. Neue Einträge

Jeder neue Methodeneintrag enthält:

```text
Methode und Signatur
MOOSE-Version und Commit
OMW-Branch und Commit
Mission und Hash
Bundle und Hash
Testbedingung
beobachtetes Ergebnis
Nachweisgrenze
bekannte Einschränkungen
```
