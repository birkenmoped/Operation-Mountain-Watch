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
  - AAR runtime method evidence for the exact documented acceptance provenance
  - AWACS routing lifecycle method evidence for the exact documented Acceptance-1 provenance
  - documented validation scope and limitations
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - method register without lifecycle timing, vertical-option and COMMANDER details
superseded_by:
source_branch: agent/kandahar-foundation-july-2011-rebuild
source_commit: GIT_HISTORY
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
| `AIRBASE:FindByName()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Airbase-Auflösung in Jalalabad, Bagram, Kandahar, Salerno, Tarinkot und Shindand Heliport |
| `AIRBASE:FindByID()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Tarinkot ID 9 |
| `GetName()` / `GetID()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Identitätsprüfung; Kandahar Main ID 7, Kandahar Heliport ID 15 und Shindand Heliport ID 14 bestätigt |
| `GetParkingSpotsTable()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Parkingdump und ME-/TerminalID-Kalibrierung; Kandahar Main 296/296 und Kandahar Heliport 80/80 exakte `.miz parking == TerminalID`-Matches im Lauf vom 12.08.2026; Shindand Heliport 42 Runtime-Spots, 38 akzeptierte ME-Zuordnungen |
| `SetParkingSpotBlacklist()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | dokumentierte Referenzknoten; tatsächliche Unitplatzierung bleibt separat |
| `FindFreeParkingSpotForAircraft(group, terminaltype, scanradius, scanunits, scanstatics, scanscenery, verysafe, nspots, parkingdata)` | `SOURCE_REVIEWED` | öffentliche parametrierbare Freiparkroutine; wird von `WAREHOUSE:_FindParkingForAssets()` nicht verwendet |

### 3.1 Kandahar ME-Parkplatz zu `TerminalID`

Der Lauf `AIRBORNE-AMMO-PARKING-CORRELATION-3` bestätigte für die exakt getestete Kandahar-Missionslinie die vollständige Korrelation zwischen Mission-Editor-Kennung, dem in der `.miz` gespeicherten numerischen `unit.parking` und der von `AIRBASE:GetParkingSpotsTable()` gelieferten MOOSE-`TerminalID`.

```text
Testdatum: 2026-08-12
Branch: agent/airborne-ammo-parking-correlation
Source commit: 5ad6d2c535c2e6796a677fd18975be794533ab8b
BuilderVersion: AIRBORNE-AMMO-PARKING-CORRELATION-3
Bundle SHA-256: cb650dd8bab448de39eb1a26f4bc856964f375600df51a5587fcf02c521a65fd
MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: 8f345af681276bc8634128b023873be4473df459deb2f6f9b230f3cbd901c84d
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: a0473859853a2786c188b3cf3c3095e570806c20b6cb49216e9befe0ac6df7b8
debrief.log SHA-256: 5b083460b339b78aa6d8d1754e60c81d10c3f7e84f56f9f74eedece6fc31eca3
```

Runtime:

```text
Kandahar Main:     296 / 296 exact matches, 0 failures
Kandahar Heliport:  80 /  80 exact matches, 0 failures
Total:             376 / 376 exact matches
```

Für diesen Stand ist damit praktisch belegt:

```text
ME parking_id -> .miz unit.parking -> MOOSE TerminalID
.miz unit.parking == MOOSE TerminalID
```

Die vollständige 376-Zeilen-Zuordnung steht in [`docs/data/kandahar-me-parking-to-moose-terminalid.csv`](../data/kandahar-me-parking-to-moose-terminalid.csv). Dieser Nachweis ist airbase-, MIZ-, DCS- und MOOSE-gebunden und wird nicht pauschal auf andere Basen oder Versionen übertragen.

Bekannte Datenanomalie ohne Mapping-Auswirkung: Der AAF05-Marker hieß im getesteten Missionsstand `KANDAHAR_AAF05KANDAHAR_AAF01`; die Korrelation blieb mit ME-ID `AAF05`, `.miz parking=29` und `TerminalID=29` eindeutig.

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

Kandahar bestätigte zusätzlich den Foundation-Start zweier paralleler AIRWING-Domänen auf zwei nativen Airbases. Beide AIRWINGs erreichten im dokumentierten Lauf `Running`; vor Start waren 32 Warehouse-Assetgruppen auf Kandahar Main und 44 auf Kandahar Heliport registriert.

Shindand bestätigte zusätzlich einen einzelnen Heliport-AIRWING mit drei SQUADRONs und 16 Assetgruppen für 20 logische Luftfahrzeuge. Alle drei SQUADRONs hatten nach Start die erwartete Assetanzahl und die erwarteten `asset.parkingIDs`.

Die post-start SQUADRON-Bindung erfolgt über den WAREHOUSE-/LEGION-Pfad und `COHORT:AddAsset()`.

### 4.4 Weitere AIRWING-Methoden

| Methode | Status | Grenze |
|---|---|---|
| `AIRWING:New()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion mit Warehouse-Anker; Kandahar duale Main-/Heliport-Konstruktion und Shindand Heliport bestätigt |
| `SetAirbase()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | explizite Airbase-Bindung; Kandahar Main/Heliport getrennt und Shindand Heliport bestätigt |
| `SetTakeoffCold()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Shindand final bestätigte Cold-Takeoff-Konfiguration und anschließenden Engine-Start/Abflug für AH-64D, UH-60 und CH-47 |
| `SetSafeParkingOn()` | `SOURCE_REVIEWED` | setzt im gepinnten `Warehouse.lua` nur `self.safeparking`; das Feld wird im WAREHOUSE-Pfad nicht gelesen und ändert die Parking-Suche nicht |
| `AddSquadron()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Cohort-, Stock- und Relocation-Payload-Registrierung; Kandahar 9 SQUADRONs / 76 Assetgruppen, Shindand 3 SQUADRONs / 16 Assetgruppen bestätigt |
| `NewPayload()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Rollen-Payloadregistrierung; Kandahar acht Rollenpayloads bestätigt, Shindand drei Rollenpayloads bestätigt |
| `GetSquadron()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | SQUADRON-Auflösung nach Registrierung |
| `GetOpsGroups()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Idle-Knoten ohne Runtime-OPSGROUPs |
| `Start()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Grundstart und post-start Assetbindung; Kandahar beide AIRWINGs und Shindand AIRWING Running |
| `AddMission()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Shindand final bestätigte direkten nativen AIRWING/AUFTRAG-Dispatch ohne COMMANDER für AH-64 CAS sowie UH-60/CH-47 LANDATCOORDINATE bis Missionserfolg |

## 5. WAREHOUSE-Parking

Vollständiger Quellenbericht:

- [`OMW-MOOSE-WAREHOUSE-PARKING-OVERRIDE-RESEARCH`](WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md)

| Methode/Feld | Status | Belegter Umfang |
|---|---|---|
| `WAREHOUSE:_FindParkingForAssets(airbase, assets)` | `SOURCE_REVIEWED` | interne Asset-Parkplatzsuche; kein dokumentierter Hook; lokale Werte `25/true/true/false`; `verysafe=false` lokal, aber unbenutzt |
| `WAREHOUSE:SetSafeParkingOn/Off()` | `SOURCE_REVIEWED` | schreibt nur `self.safeparking`; im gepinnten und geprüften aktuellen `Warehouse.lua` existiert kein Leser dieses Feldes |
| `WAREHOUSE:SetAllowSpawnOnClientParking()` | `SOURCE_REVIEWED` | entfernt Client-Templatekoordinaten aus der Hindernisliste; ändert Static-Scan und Überlappungsprüfung nicht; für Tarinkot fachlich gesperrt |
| `WAREHOUSE:SetParkingIDs()` | `SOURCE_REVIEWED` | begrenzt Warehouse-Kandidaten; ändert Scanparameter und Überlappungsprüfung nicht |
| `SQUADRON:SetParkingIDs()` | `VALIDATED_CONFIGURATION_ONLY` | setzt `cohort.parkingIDs`; Shindand Foundation bestätigte Übernahme nach `asset.parkingIDs`, aber G2 widerlegte physische Parking-Compliance als garantierte Wirkung |
| `asset.parkingIDs` | `VALIDATED_CONFIGURATION_ONLY` | post-start an SQUADRON-Assets gebunden; Source-Pfad prüft diese IDs in `_FindParkingForAssets()`, trotzdem wurde Shindand AH-64 G2 tatsächlich bei TerminalID 41 statt im AH-64-Pool `21,3,34,15` beobachtet |

### 5.1 Shindand G2 Runtime-Grenze

Testdatum 2026-08-10, DCS 2.9.28.26385 MT, Branch `agent/shindand-heliport-parking-diagnostic`, Source/Builder-Commit `27e3877efdc1f76997b00593218e0d6390313ba5`, BuilderVersion `SHND-G2-AH64-DISPATCH-3`.

Runtime:

```text
SQUADRON_POSTSTART AH-64 parkingIDs=21,3,34,15 parkingSync=true
FLIGHT_ON_MISSION group=SQ_US_SHND_AH64D_ATTACK_AID-197
unitType=AH-64D_BLK_II
state=Parking
nearest TerminalID=41
distanceM=1.667
parkingAllowed=false
```

`TerminalID 41` gehört im owner-defined Shindand-Vertrag zum UH-60-Pool. Damit ist für diesen exakten DCS-/MOOSE-/MIZ-Stand belegt:

```text
asset.parkingIDs configuration PASS
!= physical spawn parking compliance PASS
```

Der Quellcode von `WAREHOUSE:_FindParkingForAssets()` prüft `asset.parkingIDs` über `_CheckParkingAsset()`. Der Runtime-Widerspruch ist daher als Framework-/DCS-Verhaltensgrenze zu behandeln und nicht durch Annahmen zu überdecken.

Ein Ersatz von `_FindParkingForAssets()`, ein Native-DCS-Spawn oder eine andere Parallelimplementierung bleibt nach MOOSE-First nicht autorisiert, solange der Projektinhaber keine entsprechende Ausnahme freigibt.

Die offizielle AIRBASE-Methode mit denselben fünf Parametern ist kein indirekter WAREHOUSE-Setter.

## 6. Helikopter-Vertikaloption

### 6.1 `AIRWING:SetOptionPreferVerticalLanding()`

Status: `VALIDATED_FOR_DOCUMENTED_SCOPE`

Belegt:

- Methode ist im gepinnten MOOSE-Stand vorhanden;
- sie setzt `AIRWING.OptionPreferVerticalLanding = true`;
- Tarinkot G7 und Shindand Foundation setzten sie vor `AIRWING:Start()`;
- der AIRWING-Quellpfad propagiert die Option bei `FlightOnMission` an die zugewiesene FLIGHTGROUP;
- der finale Shindand-Lauf bestätigte die Propagation für AH-64D, UH-60 und CH-47;
- der Projektinhaber beobachtete UH-60 und CH-47 mit vertical takeoff; die AH-64D rollten zur Heli-Runway und starteten von dort.

Die Option ist damit nicht als Garantie für einen senkrechten Start jedes Helikoptertyps zu interpretieren.

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
| `AIRWING:SetOptionPreferVerticalLanding()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | vor Start gesetzt; Propagation und Shindand-Abflugverhalten dokumentiert |
| `FLIGHTGROUP:SetOptionPreferVertical()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Shindand final bestätigte `OptionPreferVertical=true` an allen drei zugewiesenen FLIGHTGROUPs; physisches Ergebnis typabhängig |
| `CONTROLLABLE:OptionPreferVerticalLanding()` | `SOURCE_REVIEWED_WITH_RUNTIME_CORRELATION` | DCS-Option im Quellpfad bestätigt; UH-60/CH-47 vertical, AH-64D rolling departure; keine universelle Verhaltensgarantie |

Nicht belegt:

- Vermeidung jeder Runway-/Taxi-Nutzung für alle Helikoptertypen;
- standalone FLIGHTGROUP- oder Raw-SPAWN-Experimente als Produktionspfad.

### 6.3 G8C-HOVER-APIs

Für den noch ungetesteten G8C-Vergleich wurden im gepinnten Quellstand geprüft:

| Methode | Status | Einsatzgrenze |
|---|---|---|
| `AUFTRAG:NewHOVER(Coordinate, Altitude, Time, Speed, MissionAlt)` | `SOURCE_REVIEWED` | Rotary-Auftrag; G8C nutzt nur Coordinate, Altitude und Time |
| `SQUADRON:AddMissionCapability()` | `SOURCE_REVIEWED` | registriert `AUFTRAG.Type.HOVER` je Test-Squadron |
| `AIRWING:AddPayloadCapability()` | `SOURCE_REVIEWED` | registriert `AUFTRAG.Type.HOVER` je bestehendem Rollenpayload |

Der G8C-Code verwendet keine MOOSE-Interna und keine Mutation von `mission.DCStask`. Die Methoden bleiben bis zum dokumentierten DCS-Lauf `SOURCE_REVIEWED`.

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

Shindand bestätigt unabhängig davon, dass isolierte Testaufträge direkt über `AIRWING:AddMission()` ohne COMMANDER bis zur Zuweisung und Missionserfüllung gelangen können. Das ist kein Ersatz für eine spätere produktive COMMANDER-Architektur.

## 8. Wrapper und Hilfsklassen

- `GROUP`, `UNIT`, `STATIC` und `ZONE`: `VALIDATED_FOR_DOCUMENTED_SCOPE` für Objekt- und Templateprüfung;
- `_DATABASE`: `INTERNAL_RESTRICTED`, nur Diagnose und Templateprüfung;
- `SCHEDULER`: `VALIDATED_FOR_DOCUMENTED_SCOPE` für geordnete verzögerte Post-Start-Inspektion und den finalen Shindand-Kombinationstest.

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

## 11. Shindand AIRWING/SQUADRON Foundation

### 11.1 Foundation-Initialisierung

```text
Testdatum: 2026-08-10
DCS: 2.9.28.26385 MT
Foundation source commit: d24c9d92470192dcee8467f3b24ed31548edd3a3
BuilderVersion: SHND-AIR-OPS-FOUNDATION-1
Bundle SHA-256: a7bd8a28ba9e72db2505a4237b6b5ea21465eba1ef09693cf6e6d461f8c6e2ea
```

Bestätigt: AIRWING Running, drei SQUADRONs, 16 Assetgruppen / 20 logische Luftfahrzeuge, post-start Assetzahlen und `asset.parkingIDs`-Synchronität.

### 11.2 Historische Parking-Grenze

Der G2-Lauf bestätigte den direkten AIRWING/AUFTRAG-Pfad bis zum physischen AH-64-Spawn, aber nicht die physische typgebundene Parking-Compliance. Die späteren Parking-Diagnosen bleiben historische Testfixtures und kein offenes Foundation-Gate.

```text
G2 Source/Builder commit: 27e3877efdc1f76997b00593218e0d6390313ba5
BuilderVersion: SHND-G2-AH64-DISPATCH-3
Bundle SHA-256: 787cd3a54cacf7b3a4349bf8554d4124d778fe02607e680dc143474c24d0653f
Observed AH-64 nearest TerminalID: 41
Owner-defined AH-64 pool: 21,3,34,15
physical type-specific parking: FAIL
```

### 11.3 Finaler kombinierter Foundation-PASS

```text
Testdatum: 2026-08-10
DCS: 2.9.28.26385 MT
Source commit: 584ed674e1d3f642a22c96398c2ebc97b9efcb61
BuilderVersion: SHND-FINAL-FOUNDATION-ACCEPTANCE-1
Bundle SHA-256: 8202dfd353a854ea0a1ce7db3fcadb5bb716ae757b6ac41181dadb2cf7ecba7c
DCS log SHA-256: 53d65dba5e5dc426558e430bace12403648ed16b5917fbbda1bf1629e912d250
Debrief SHA-256: 153247efccc18c9a050b9d309ab0c3eed9f3fb15363774fc995a63e55c54ee87
```

Praktisch bestätigt:

| Methode / Pfad | Status | Belegter Shindand-Umfang |
|---|---|---|
| `AUFTRAG:NewCAS(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AH-64D CAS-Mission zugewiesen, gestartet und erfolgreich beendet |
| `AUFTRAG:NewLANDATCOORDINATE(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | UH-60- und CH-47-Missionen zugewiesen und von MOOSE erfolgreich beendet; physische Außenlandung nicht beobachtet |
| `AUFTRAG:AssignSquadrons(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AH-64D, UH-60 und CH-47 jeweils dem vorgesehenen Shindand-SQUADRON zugewiesen |
| `AIRWING:AddMission(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | direkter MOOSE-Dispatch aller drei Testmissionen ohne COMMANDER |
| `AIRWING:SetTakeoffCold()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | alle drei zugewiesenen Flights cold konfiguriert; Engine-Start und Abflug beobachtet |
| `AIRWING:SetOptionPreferVerticalLanding()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | an alle drei FLIGHTGROUPs propagiert; UH-60/CH-47 vertical, AH-64D rolling departure |
| `FLIGHTGROUP:IsTakeoffCold()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | im `FlightOnMission`-Pfad für alle drei Testflights true |
| `FLIGHTGROUP:SetOptionPreferVertical()` / `OptionPreferVertical` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Propagation für alle drei Testflights bestätigt |

Runtime-Ergebnis:

```text
AH-64D: CAS success; rolling/taxi departure accepted
UH-60: LANDATCOORDINATE success; vertical takeoff observed
CH-47: LANDATCOORDINATE success; vertical takeoff observed
```

Der AH-64-CAS-Erfolg trat rund 1,5 Sekunden nach dem Harness-Timeout ein und wurde vom Projektinhaber als Harness-Grenzfall akzeptiert.

Nicht validiert:

```text
physical type-specific parking enforcement
physical off-field landing of UH-60 or CH-47
transport loading/unloading semantics
OPSTRANSPORT
COMMANDER for Shindand
CSAR/MEDEVAC specialization
CampaignState integration
persistence
```

## 12. AAR Production Final Acceptance 5

### 12.1 Provenienz

```text
Testdatum: 2026-08-15
Branch: agent/aar-runtime-finalization
Acceptance commit: 5e7dbec37f53155f39c63c25590cf6b4e35814ca
Builder/Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-5
Mission: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: c9e3978a4bbb35ebbfe5ae362021b5f8870129d6c8b06b58147424dde71a94e3
Bundle SHA-256: f33b0a5a6212d9a1103dfa2e0ab677777142ca771a2f5007a3ab1c7fee594cbf
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: 3c4b5b74f91b9d94e272a1f02f1df839bbe6b3a2362fa03338916e4fc8b4a060
debrief.log SHA-256: ba78783fce55d045735e76e9ddab4e23a2237fa93eabf90fed56bd58770873a0
Result: PASS
```

### 12.2 Praktisch bestätigte MOOSE-Methoden und Pfade

| Methode / Pfad | Status | Belegter AAR-Umfang |
|---|---|---|
| `AUFTRAG:NewTANKER(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | produktive KC-135-Missionen für vier STANDARD- und zwei RESERVE-Tracks materialisiert und bis zum Track-Lifecycle geführt |
| `AUFTRAG:SetMissionIngressCoord(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | natürliche FIR-Ingress-Passage über EGPAN, DAVER und PINAX im dokumentierten Acceptance-Lauf |
| `AUFTRAG:SetMissionEgressCoord(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | outgoing Tanker passierten den vorgesehenen FIR-Egress-Fix vor dem External Handoff |
| `AUFTRAG:Cancel()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Scheduled Relief: Cancel/Egress erst bei realer Relief-Übernahme; FuelLow: Immediate-Egress-Pfad blieb getrennt und funktionierte |
| `FLIGHTGROUP:AddWaypoint(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Weiterführung nach FIR-Egress zum getrennten External-Handoff-Punkt vor Recredit/Despawn |
| `FLIGHTGROUP:FuelLow()` / FuelLow-FSM-Pfad | `VALIDATED_FOR_DOCUMENTED_SCOPE` | NELSON FuelLow löste sofortigen Station-Release/Egress und genau einen natürlichen Replacement-Lifecycle aus |
| `UNIT:GetSTN()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | MOOSE-gemanagte STN wurde nach Materialisierung gelesen; OMW setzte keine eigene `SPAWN:InitSTN()`-Parallellogik |
| `UNIT:Explode(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | gezielte PATTY-Testverlustinjektion; realer FLIGHTGROUP Dead/OnAfterDead-Pfad, kein Recredit, Loss-Audit und natürlicher Ersatz wurden bestätigt |

### 12.3 Belegte Koordinationssemantik

Der Lauf bestätigte zusätzlich die projektspezifische Koordination um die MOOSE-Lifecycle-Methoden:

```text
Scheduled Relief ETA <= 5 min
-> nur handover armed
-> outgoing bleibt ACTIVE und behält Radio/TACAN
-> relief bleibt inbound

reale Track-Ankunft / enge Handover-Geometrie
-> relief wird Station Owner
-> Radio/TACAN wechseln
-> outgoing AUFTRAG:Cancel() / Egress
```

Der Harness protokollierte ausdrücklich:

```text
SCHEDULED_RELIEF_ARMED_HOLD_PASS area=MILHOUSE outgoingStillActive=true reliefStillInbound=true
SINGLE_SCHEDULED_RELIEF_PASS area=MILHOUSE armedHold=true naturalTrackHandover=true
RESULT PASS
```

FuelLow ist davon bewusst getrennt und bleibt Immediate Egress. Der Acceptance-Lauf bestätigte außerdem vier STANDARD-Tracks, zwei demand-gesteuerte RESERVE-Tracks, mindestens 60 s Same-source-Spacing, natürliche EGPAN/DAVER/PINAX-Transits, External Handoff, Reserve-Shutdown, Loss/Replacement und CampaignState exact-once Accounting.

Grenze: Die Validierung gilt ausschließlich für den oben dokumentierten Branch-/Commit-/Mission-/Bundle-/DCS-/MOOSE-Stand. Lower-/Upper-Airway-Routing war nicht Teil dieses Tests.

## Addendum 2026-08-19 – Ground Acceptance 3-2

~~~text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
OMW source: mission/tests/army-ground-foundation/src/03-army-ground-acceptance-3.lua
Tested commit: 9b4997bf024efe0fab18b4d18552117cd8eeee21
Bundle SHA-256: 1f3879c1245483ba69cb8a5cc76ea1af4f46cdd01d7c9778440f2a2c6d08ef00
Mission: OMW_Template_v13_ground_test(10).miz
DCS: 2.9.28.26385 MT
Result: PASS / owner visual acceptance
~~~

| Methode/Pfad | Status | Bestätigter Scope und Grenze |
|---|---|---|
| `WAREHOUSE:SetSpawnZone(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | sechs Ground-Hosts mit ACCESS-Zone; Fenty-Host wurde im Mission Editor so positioniert, dass die MOOSE-Host–Zone-Distanzgrenze erfüllt ist |
| `WAREHOUSE:_SpawnAssetGroundNaval(...)` + `_SpawnAssetPrepareTemplate(...)` + `_DATABASE:Spawn(template)` | `VALIDATED_FOR_DOCUMENTED_SCOPE / INTERNAL_RESTRICTED` | ausschließlich die freigegebene per-BRIGADE Acceptance-3-2-Ausnahme; road-aligned 4-Unit Spawn, 74 m Marschraum, Road-Snap <= 4 m; keine allgemeine öffentliche API oder Produktionsfreigabe |
| `BRIGADE:New`, `BRIGADE:AddPlatoon`, `PLATOON:New`, `COHORT:AddMissionCapability`, `COHORT:CountAssets` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | parallele sechs-Domain-Auswahl und genau eine Materialisierung pro Site |
| `AUFTRAG:NewARMOREDGUARD`, `SetMissionSpeed`, `SetReturnToLegion(false)`, `__Cancel(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | On-Road 27 kt -> MissionDone physical stay -> same ARMYGROUP Vee 8 kt -> stable halt, sechs Sites |

## Addendum 2026-08-19 – Acceptance 4 source review

| Methode/Pfad | Status | Grenze |
|---|---|---|
| `ARMYGROUP:RTZ(Zone, ENUMS.Formation.Vehicle.OnRoad)` | `SOURCE_REVIEWED / DCS_PENDING` | mobiler Group-Pfad fügt einen temporären Ground-Waypoint in die bestehende Fenty-ACCESS-Zone ein; die Zielkoordinate ist innerhalb dieser Zone zufällig |
| `ARMYGROUP:onafterReturned -> LEGION:__AddAsset(10, group, 1)` | `SOURCE_REVIEWED / DCS_PENDING` | Rückgabe an das bestehende operative Warehouse nach zehn Sekunden; kein CampaignState-Settlement |
| `WAREHOUSE:onafterAddAsset` für bekannte, lebende Gruppe | `SOURCE_REVIEWED / DCS_PENDING` | stellt den Assetbestand wieder her und despawnt/stoppt die physische OPSGROUP; Sichtbarkeit muss in DCS am Owner-Handoff-Marker geprüft werden |

## Addendum 2026-08-19 – Acceptance-4-2 Ground-return runtime evidence

| Methode / Callback | Status | Exakt bestätigter Umfang |
|---|---|---|
| ARMYGROUP:RTZ(Zone, ENUMS.Formation.Vehicle.OnRoad) | VALIDATED_FOR_DOCUMENTED_SCOPE | Mobiler Fenty-ARMYGROUP fährt über den öffentlichen RTZ-Pfad zur bestehenden ZON_BLUE_GND_FENTY_ACCESS; kein immobiler Teleportpfad verwendet. |
| ARMYGROUP:OnAfterRTZ(...) | VALIDATED_FOR_DOCUMENTED_SCOPE | RTZ-Auslösung, Zielzone und OnRoad-Formation im Acceptance-4-2-Harness protokolliert; FSM wechselte zu Returning. |
| ARMYGROUP:OnAfterReturned(...) | VALIDATED_FOR_DOCUMENTED_SCOPE | Nach Ankunft wurde genau ein Returned-Handoff bestätigt. |
| LEGION:__AddAsset(10, group, 1) / Warehouse AddAsset | VALIDATED_FOR_DOCUMENTED_SCOPE | Ein Rückgabe-Handoff stellte den operativen Warehouse-Assetbestand wieder her und entfernte anschließend die temporäre physische DCS-Gruppe. Keine strategische CampaignState-Buchung. |

Provenienz und Einschränkungen: [Acceptance 4 runtime evidence](../../mission/tests/army-ground-foundation/results/2026-08-19-acceptance-4-runtime.md). Gültig nur für MOOSE commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54, die zitierte Mission und den mobilen Fenty-Scope.


## Addendum 2026-08-20 – ARMY Ground Acceptance 6

Der folgende Runtime-Nachweis ist auf den exakten Ground-Return-Scope beschränkt:

~~~text
Source commit: c03af3bdf33c83d2fee5477f90f1479df1ec52d3
Builder/Test-ID: ARMY-GROUND-ACCEPTANCE-6-1
Bundle SHA-256: 17d0e5f534f67ca41088e3303e7f8ab9af346a6c8a637c987e4047eb99fc55da
MIZ SHA-256: 7b10b96cd1fbebef7831ccf633e1f57c34b8a318238b38865606fd47dfeb59db
MOOSE commit/SHA: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54 / e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS: 2.9.28.26385 MT
Result: PASS / owner visual acceptance without anomalies
~~~

| Methode | Status | Belegter Umfang |
|---|---|---|
| GROUP:GetSize() | VALIDATED_FOR_DOCUMENTED_SCOPE | Nach test-only UNIT:Destroy(false) bestätigte die aktuelle Gruppenstärke exakt drei Rückkehrer in Joyce und Wright. |
| GROUP:GetUnits() | VALIDATED_FOR_DOCUMENTED_SCOPE | Deterministische Auswahl der test-only Verlust- bzw. Schadensunit im dokumentierten Vier-M-ATV-A6-Scope. |
| UNIT:Destroy(false) | VALIDATED_FOR_DOCUMENTED_SCOPE | Ein M-ATV je Joyce/Wright wurde nach MissionDone als Verlust entfernt; keine Rückkehr- oder CampaignState-Gutschrift für die entfernte Unit. |
| UNIT:SetLife(50) | VALIDATED_FOR_DOCUMENTED_SCOPE | Ein Wright-Rückkehrer erhielt Life 4 -> 2 und erreichte dennoch den regulären RTZ-/Warehouse-Handoff. |
| ARMYGROUP:RTZ(existing site ACCESS zone, OnRoad) | VALIDATED_FOR_DOCUMENTED_SCOPE | Drei parallele mobile Rückgaben zu ihren jeweiligen ACCESS-Zonen; anschließend Returned -> Warehouse AddAsset -> controlled physical group removal. |

Der Nachweis führt keine Wartungs-/Reparaturzustände ein. Ein zurückgekehrtes, auch beschädigtes Fahrzeug wird sofort als verfügbar gutgeschrieben; nicht zurückgekehrte Units werden nicht gutgeschrieben.

## Addendum 2026-08-22 – Ground Ammo Rearm Acceptance 1

Der folgende Methodenstatus gilt ausschließlich für die nachgewiesene Bostick-Acceptance-Provenienz:

```text
Branch: agent/ground-ammo-rearm-integration
Acceptance source/build commit: 213119ca03a6aeae529d4291b4bbe174ac0995c2
Ground BASE-3 source/build commit: 04674c29061c6a70f54b537598442857448441b6
Warehouse BASE-3 build commit: 7da56fdfb45888e7f88d4ea5c3b0fa691f2b0423
Builder/Test-ID: GROUND-AMMO-REARM-ACCEPTANCE-1
DCS: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Executed MIZ: OMW_Template_v15.miz
MIZ SHA-256: A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4
internal mission SHA-256: 2378F38E9B07365D25ACE38E45A23D87E2CC76F185A062FB2A46CA8EE31C1A53
Acceptance bundle SHA-256: 94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
Ground BASE-3 bundle SHA-256: 6DBDE7AA75E34FA6C7A42A7C97B3E407C069806666C60E8D27F8616D647383EE
Warehouse BASE-3 bundle SHA-256: FC0F8F20909DD57E5DEE3AF6414FB56B35D8671D726471DEDB6D6984E590801B
dcs.log SHA-256: 8ECFD3CACC58FF0421E55280D7CE63EFA2A6C1CDA0A09095F7A69E588290DE71
debrief.log SHA-256: B773DDB09401B7E58F4393EEEEDCE858EB98F769E1BE2DE9AB12392B10583A9E
Result: PASS
```

| Methode / Callback | Status | Exakt bestätigter Umfang |
|---|---|---|
| `ARTY:New(group, alias)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Eine laufende ARTY-Instanz verwaltete die feste Bostick-L118-Batterie im Acceptance-Harness. |
| `ARTY:AssignTargetCoord(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Vier-Schuss-Testziel wurde zugewiesen; beobachteter Munitionsstand fiel `300 -> 296`. |
| `ARTY:GetAmmo(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Munitionsstände `300`, `296` und nach Rearm `302` wurden im dokumentierten Harness ausgewertet. |
| `ARTY:SetRearmingGroup(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Materialisierte `CHAP_M1083`-Gruppe wurde explizit als RearmingGroup an die Bostick-ARTY-Instanz gebunden. |
| `ARTY:SetRearmingGroupOnRoad(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Der dokumentierte Rearm-Pfad verwendete die On-Road-Konfiguration der RearmingGroup. |
| `ARTY:Rearm()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Rearm-FSM wurde nach lokaler CampaignState-Reservation ausgelöst und führte bis `Rearmed`/Vollrearm. |
| `ARTY OnAfterCeaseFire` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Acceptance-Harness verwendete den CeaseFire-Kopplungspunkt nach dem kontrollierten Feuer. |
| `ARTY OnBeforeRearm` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Genau an diesem nach internem ARTY-Precheck liegenden Hook wurde die reservierte lokale `GROUND_AMMO_PACKAGE`-Transaktion verbraucht; Bestand `52 -> 51`. |
| `ARTY OnAfterRearmed` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Operative Completion wurde empfangen; Harness bestätigte `PASS M1083_REARM_CONFIRMED=true` und finalAmmo `302`. |
| `USERFLAG:New(...)` / `Set(...)` / `Get()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Ground BASE-3 setzte `OMW_GROUND_READY` fail-closed und bestätigte per Readback `1`; der Mission-Editor-Trigger startete den Acceptance-Harness auf genau diesem DCS-Userflag. |

Scope-Grenzen:

```text
CHAP_M1083 operational ammo-support capability
= VALIDATED only for this Bostick L118 / ARTY explicit RearmingGroup path

AMMOTRUCK
= still SOURCE_REVIEWED; not exercised in this run

not validated here:
- full-battery rejection
- M1083 loss/interruption
- restart/replay settlement
- general CHAP_M1083 behavior outside this exact battery/MIZ/MOOSE scope
- other ARTY batteries or MOOSE versions
```

## Addendum 2026-08-23 – AWACS Acceptance 1 routing lifecycle

### Provenienz

```text
Branch:                   agent/awacs-external-lifecycle-foundation
Tested source commit:     bde8a6e8d006b7c8d744b739510b08aa9812d48b
Mission:                  OMW_Template_v19(8).miz
Mission SHA-256:          d788af36535d3acd1866d15ffb5d354b2c44b5f8ee40d4baf6fd1d97b7c0f8a5
DCS:                      2.9.28.26385 MT
MOOSE release:            2.9.18
MOOSE commit:             73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:        e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Embedded Warehouse SHA:   01a9ca70988198ecbd76f4d1cab4304261f2cc56911584b44741c0d49c7b146c
Embedded AWACS bundle SHA:639841a552343f4d0f7180f657a4a0b3141fb0b9af3ed6f1d9915ec955444fc2
Controller source SHA:    6ed1c54465764b5745f1071a59439f29dc08a93d1875492d25ff5ba889bd13bd
dcs.log SHA-256:          593d02d455db0cae04cfd0e7651671d3af1d76ab430ff3232da7b19dac391c2f
debrief.log SHA-256:      32df4af4943f5ca3d2a98dde61e452054b5183fd21fa9f6b78750894ec106eb7
Result:                    PASS for routing lifecycle scope
```

### Praktisch bestätigte Methoden und Pfade

| Methode / Pfad | Status | Exakt bestätigter AWACS-Umfang |
|---|---|---|
| `SPAWN:InitCallSign(...)` / `InitHeading(...)` / `InitSpeedKnots(...)` / `SpawnFromCoordinate(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `OMW_C2_E3A_WIZARD` materialisierte am externen Pakistan-Punkt als `Wizard1-1`; der Controller protokollierte den vorgesehenen External-Spawn-/ROSIE-Abstand und 357.300 MHz-Kontext. |
| `FLIGHTGROUP:New(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Die materialisierte E-3-Gruppe wurde als FLIGHTGROUP durch den vollständigen dokumentierten Routing-Lifecycle geführt. |
| `FLIGHTGROUP:AddWaypoint(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | ROSIE inbound, 30-NM-Late-Approach und nach FIR-Egress der getrennte External-Handoff-Waypoint wurden im erfolgreichen Lauf erreicht beziehungsweise ausgelöst. |
| `FLIGHTGROUP/OPSGROUP PassingWaypoint` / `OnAfterPassingWaypoint(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | ROSIE inbound und der Late-Approach-Waypoint wurden in korrekter Reihenfolge erkannt; Late Approach fügte erst danach den AWACS-Auftrag hinzu. |
| `FLIGHTGROUP:AddMission(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | `AUFTRAG:NewAWACS(...)` wurde nach Late Approach an die E-3 übergeben; anschließend wurde `ON_STATION area=APOC` erreicht. |
| `AUFTRAG:NewAWACS(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | MOOSE-AWACS-Auftrag wurde auf APOC im E-3-Lifecycle gestartet; MOOSE meldete beim kontrollierten Egress `Mission 3 [AWACS] success!`. |
| `AUFTRAG:SetMissionAltitude(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Teil des erfolgreich ausgeführten AWACS-Auftrags; die tatsächliche durchgehende FL320-Einhaltung bleibt noch gesondert telemetrisch zu prüfen. |
| `AUFTRAG:SetMissionEgressCoord(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Egress auf ROSIE / FL340 / 300 kt wurde angeordnet; ROSIE outbound wurde vor External Handoff bestätigt. |
| `AUFTRAG:Cancel()` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Kontrollierter Acceptance-Egress führte aus APOC in den vorgesehenen ROSIE-Outbound-/External-Handoff-Pfad. |
| `OPSGROUP/FLIGHTGROUP:Despawn(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Despawn erfolgte erst nach `FIR_EGRESS_PASSED` und Erreichen des externen Handoff-Bereichs; der Controller meldete `DESPAWN_AND_RECREDIT`. |

### Grenzen

Nicht durch Acceptance 1 belegt:

```text
continuous altitude/speed compliance
actual APOC 017T / 30-NM racetrack geometry
player-side WIZARD / 357.300 MHz service usability
fuel calibration
six-hour station cycle
scheduled relief / physical handover
loss settlement
restart reconciliation
FLIGHTGROUP:Refuel(...) or tanker-selection policy
```

`FLIGHTGROUP:Refuel(...)` bleibt für AWACS `SOURCE_REVIEWED / DCS_PENDING`; aus dem Acceptance-1-PASS darf keine automatische nearest-tanker-Policy abgeleitet werden.

Vollständige Runtime-Evidenz: [`AWACS Acceptance 1`](../../mission/tests/awacs-external-lifecycle/ACCEPTANCE.md) und [`Routing Lifecycle Runtime Evidence`](../../mission/tests/awacs-external-lifecycle/results/2026-08-23-routing-lifecycle-acceptance-1.md).
