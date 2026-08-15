---
document_id: OMW-AAR-ISAF-ACO
status: BINDING_PROJECT_DECISION
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW AAR-area and ACO mission-design reference for Afghanistan 2009-2013
  - source-derived tanker-area geometry and planning constraints
  - OMW 2011-compatible corrected AAR production-planning geometry
  - OMW operational AAR core-area roles and source-domain decisions
  - current production-facing FAST/SLOW and external-origin rules
  - OMW off-map KC-135 strategic design stock
  - AAR production integration status and remaining work
not_authoritative_for:
  - historical operational ACO authenticity
  - undocumented DCS behavior outside the recorded acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier AAR planning without consolidated runtime evidence and operational source-domain decisions
superseded_by:
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# 29 – ISAF 2009–2013: Air-to-Air Refuelling und OMW-AAR-Baseline

## 1. Einordnung

Dieses Dokument ist die verbindliche AAR-Planungs- und Designreferenz für **Operation Mountain Watch**. Es verbindet:

- die ursprüngliche ACO-/AAR-Quellenaufnahme;
- die für OMW korrigierte 2011-AIP-kompatible Geometrie;
- den geprüften MOOSE-/DCS-Runtimepfad;
- die aktuellen Eigentümerentscheidungen zu Kern-AAR-Areas, FAST/SLOW-Rollen und External Origins;
- die strategischen Off-map-KC-135-Designbestände;
- den aktuellen Stand der produktiven AAR-Integration und die noch offenen Arbeiten.

Der vollständige frühere Quellen-, Tabellen-, KMZ- und CombatFlite-Auswertungstext bleibt erhalten:

- [`Legacy-AAR-/ACO-Quellenfassung`](evidence/source-records/legacy-29-isaf-aar-aco-source-capture.md)

Ergänzende fachliche Grundlagen:

- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md)
- [`OMW-AIR-AFGHANISTAN-AIP-2008`](72-afghanistan-aip-2008-airspace-aerodromes-and-flight-procedures.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md)

## 2. Quellenstatus und Evidenzgrenzen

```yaml
source_author: Graveyard of Empires
patreon_parts_available: 3/3
pdf_table: evaluated
kmz_geometry: extracted
combatflite_cf: technically_evaluated
source_status: SOURCE_CAPTURE_COMPLETE
```

Die Graveyard-of-Empires-Daten bleiben Quellenreferenz für Benennung, Höhenblöcke, Netze, TACAN und das grundsätzliche Lagebild. Die daraus extrahierte Geometrie ist jedoch nicht die produktive OMW-Geometrie, sobald sie mit dem für OMW maßgeblichen 2011er AIP-Luftraum kollidiert.

AIP-Reporting-Points und Airways belegen die veröffentlichte Airspace-Struktur. Sie beweisen nicht, dass eine konkrete historische KC-135-Sortie exakt diesen zivilen Airway flog. Ebenso sind die OMW-Tanker-Callsigns Projektzuweisungen und keine historischen Sortie-Behauptungen.

## 3. Verbindliche OMW-Geometrie

Am 14.08.2026 entschied der Projektinhaber, konfliktbehaftete Source-Tracks so zu korrigieren, dass die geplante Refuelling-Linie außerhalb der maßgeblichen 2011-Airways sowie relevanter Class-C-/Class-D-Lufträume liegt.

Verbindlich:

1. alle 19 Areas bleiben als Geometrien erhalten;
2. die 35-NM-Grundform bleibt soweit möglich erhalten;
3. die produktive Geometrie steht in:
   - `data/air-operations/aar/omw-2011-aar-areas.csv`
   - `data/air-operations/aar/omw-2011-aar-areas.geojson`;
4. die ursprünglichen `isaf-2009-2013-*`-Daten bleiben Source-Evidence;
5. die drei LA/HAAR-Areas bleiben deaktiviert, solange kein genehmigter passender Tanker-/Mod-Pfad existiert.

```yaml
geometry_status: OMW_2011_AIP_CORRECTED
historical_claim: false
```

## 4. Aktuelles operatives AAR-Kernnetz

Die produktive Kernstruktur wird auf sechs Areas konzentriert. Die übrigen HA-Areas bleiben strategische Reserve-/Alternativgeometrien.

| Region | Area | Rolle | Receiver-Profil | Primäre Source Domain |
|---|---|---|---|---|
| WEST | `LISA` | RC-West / Shindand | FLEX | `MANAS` |
| CENTRAL | `MOE` | Swing / Reserve / Central Support | FLEX | `MANAS` |
| SOUTH-CENTRAL | `MILHOUSE` | A-10 Recovery / Kandahar Return | SLOW | `AL_UDEID` |
| SOUTHEAST | `KRUSTY` | A-10 Recovery East / Paktika / Sharana / Southeast | SLOW | `AL_UDEID` |
| EAST | `PATTY` | primärer A-10-/RC-East-Support | SLOW | `MANAS` |
| NORTHEAST | `NELSON` | primärer Fast-Jet-Support | FAST | `MANAS` |

Maschinenlesbare Fassung:

- `data/air-operations/aar/omw-2011-aar-operational-core.csv`

### 4.1 FAST/SLOW

Verbindliche Rollenentscheidung:

```text
NELSON -> FAST -> F-15E / F-16C
PATTY  -> SLOW -> A-10C
MILHOUSE -> SLOW -> A-10 Recovery / Kandahar Return
KRUSTY   -> SLOW -> A-10 Recovery East / Southeast
MOE      -> FLEX / Swing
LISA     -> FLEX / RC-West
```

Für zwei unabhängige Tanker im selben AAR-Gebiet gilt weiterhin:

```text
SLOW unten
FAST oben
mindestens 3,000 ft vertikale Tanker-zu-Tanker-Staffelung
```

Die Acceptance-6-Konfiguration `FL220 / 220 KIAS` SLOW und `FL250 / 300 KIAS` FAST war ein erfolgreicher technischer Same-area-Test, wird aber nicht pauschal auf jede Area übertragen. Die endgültige Trackhöhe bleibt innerhalb des jeweiligen veröffentlichten Blocks area-spezifisch.

### 4.2 Produktive Station-Identitäten

| Area | Station-Callsign | Radio | TACAN |
|---|---|---:|---|
| `NELSON` | `Texaco 1-1` | 384.400 AM | 47Y `NEL` |
| `PATTY` | `Texaco 2-1` | 237.300 AM | 48Y `PAT` |
| `LISA` | `Texaco 3-1` | 235.900 AM | 50Y `LIS` |
| `MOE` | `Texaco 4-1` | 243.400 AM | 52Y `MOE` |
| `KRUSTY` | `Arco 2-1` | 258.300 AM | 42Y `KRU` |
| `MILHOUSE` | `Shell 2-1` | 272.600 AM | 58Y `MIL` |

Der aktuelle Produktionscontroller trennt **physische Tankeridentität im Transit** von der **operativen Station-Identität**. Jeder materialisierte Tanker erhält zunächst einen reservierten Transit-Rufnamen aus den Nummern 5–9 und eine eindeutige Link-16-STN-Basis. Funk und TACAN sind dabei ausgeschaltet.

Erst beim Erreichen des Track-Entry-Radius wird die Station-Identität über die source-geprüften MOOSE-Pfade `OPSGROUP:SwitchCallsign(...)`, `SwitchRadio(...)` und `SwitchTACAN(...)` aktiviert. Vor Egress wird sie über `TurnOffRadio()`, `TurnOffTACAN()` und Rückschaltung auf den Transit-Rufnamen wieder entfernt. Damit besitzt während des geplanten Handover-Fensters nur der aktuelle Station Owner die veröffentlichte Station-Identität.

Diese neue Identity-Handover-Logik ist **source-reviewed und implementiert, aber noch nicht in DCS validiert**. Die ältere Integration-3 bestätigt nur den vorherigen area-spezifischen Callsign-Pfad.

## 5. External Origins und Transit

Eigentümerentscheidung:

```text
SOUTH / AL UDEID:
- MILHOUSE
- KRUSTY

NORTH / MANAS:
- LISA
- MOE
- PATTY
- NELSON
```

Die frühere Annahme, fast alle aktiven Tanker über einen einzigen südlichen Gatepunkt zu führen, ist verworfen. Die AIP zeigt mehrere veröffentlichte Kabul-FIR-Entry-/Exit-Punkte aus Pakistan, Tajikistan, Uzbekistan und Turkmenistan.

Planungsdaten:

- `data/air-operations/aar/omw-2011-aar-origin-comparison.csv`
- `data/air-operations/aar/omw-2011-aar-entry-gate-analysis.csv`

Wichtig: Die Distanzanalyse ist ein Planungswerkzeug. Die aktuelle Source-Domain-Entscheidung des Projektinhabers hat Vorrang vor einer rein geometrischen Minimaldistanz.

### 5.1 Externe Gates und High-Transit-Profile

Produktiv verwendet:

```text
MANAS gate:
N38.83163 E70.95271

AL_UDEID gate:
N28.90264890 E64.61166667

MANAS_WEST_HIGH:
ingress FL340
egress  FL330

MANAS_EAST_HIGH:
ingress FL330
egress  FL340

AL_UDEID_NORTH_HIGH:
ingress FL330
egress  FL340
```

Verbindliches Prinzip:

```text
External Gate
-> hoher, kraftstoffeffizienter Transit
-> Sinkflug auf area-spezifische Trackhöhe
-> AAR-Racetrack
-> realer FuelLow/Bingo-Punkt
-> Egress
-> hoher Rücktransit
-> External Gate
-> kontrollierter Off-map-Handoff
```

### 5.2 Strategische Off-map-KC-135-Designbestände

Der Projektinhaber hat am 15.08.2026 folgende **OMW-Designbestände** festgelegt:

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40
```

Diese Werte sind **keine Behauptung einer historisch exakt zugewiesenen Flugzeugstärke**. Die exakte historische Assigned Strength ist nicht belegt. Die Werte sind bewusst plausible, spielbare OMW-Kompositbestände.

Für `MANAS` liegen mehrere vom Projektinhaber ausgewertete Google-Earth-Satelliten-Snapshots vor:

```text
06/2010: 11 sichtbare KC-135
03/2011: 13 sichtbare KC-135
07/2011:  9 sichtbare KC-135
07/2012:  8 sichtbare KC-135
```

Der sichtbare Ramp-Bestand ist eine Momentaufnahme und bildet nicht gleichzeitig fliegende, gewartete, rotierende oder außerhalb des Bildausschnitts befindliche Maschinen ab. `16` ist deshalb eine plausible OMW-Designstärke oberhalb des direkt sichtbaren Maximums von 13.

Für `AL_UDEID` liegen folgende ausgewertete Snapshots vor:

```text
07/2010: ca. 27 sichtbare KC-135
08/2011: ca. 33 sichtbare KC-135
```

Zusätzlich sind auf den Bildern weitere große Spezial-/Tanker-ähnliche Muster sichtbar, deren genaue Rolle aus der Satellitendraufsicht nicht sicher bestimmt wird und die deshalb nicht in den KC-135-Zählwert eingehen. `40` ist als strategischer OMW-Designbestand angesichts des beobachteten Ramp-Bestands und des regionalen Großknotencharakters plausibel.

### 5.3 Keine künstliche MOOSE-Airbase für Off-map-Pools

`MANAS` und `AL_UDEID` liegen außerhalb der DCS-Afghanistan-Karte und besitzen dort keine nutzbare DCS-Airbase. Daher werden für diese strategischen Pools **keine künstlichen DCS-Airbases, MOOSE-WAREHOUSE-Instanzen oder AIRWINGs** erzeugt.

Verbindliche Abstraktion:

```text
CampaignState Off-map count pool
-> OMW AAR CampaignState adapter
-> MOOSE SPAWN at external gate
-> FLIGHTGROUP
-> AUFTRAG
-> mission / relief lifecycle
-> external gate / confirmed off-map handoff
-> CampaignState exact-once recredit
```

Der aktuelle strategische Vertrag ist bewusst **count-basiert**. Es gibt keine per-tail Aircraft-Entität, kein strategisches Template-Inventar und keinen regulären Turnaround-Timer. Materialisierung verbraucht genau eine `AIRCRAFT_KC135`; nur ein bestätigter Off-map-Handoff schreibt genau eine Einheit zurück. Ohne bestätigten Handoff erfolgt keine Recreditierung.

MOOSE bleibt für den physischen Tanker-Lifecycle zuständig. CampaignState bleibt alleinige strategische Ressourcenautorität.

## 6. MOOSE-First-Runtimepfad

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-reviewed und im aktuellen Produktionscontroller verwendete Pfade umfassen insbesondere:

- `AUFTRAG:NewTANKER(...)`
- `AUFTRAG:SetMissionIngressCoord(...)`
- `AUFTRAG:SetMissionEgressCoord(...)`
- `AUFTRAG:Cancel()`
- `SPAWN:InitCallSign(...)`
- `SPAWN:InitSTN(...)`
- `GROUP:GetCallsign()`
- `GROUP:GetFuelMin()`
- `FLIGHTGROUP:GetFuelMin()`
- `FLIGHTGROUP:SetFuelLowThreshold(...)`
- `FLIGHTGROUP:SetFuelLowRTB(false)`
- `OPSGROUP:SwitchCallsign(...)`
- `OPSGROUP:SwitchRadio(...)`
- `OPSGROUP:TurnOffRadio()`
- `OPSGROUP:SwitchTACAN(...)`
- `OPSGROUP:TurnOffTACAN()`
- `COORDINATE:Get2DDistance(...)`
- `COORDINATE:Get3DDistance(...)`
- `OPSGROUP:Despawn(...)`

Die stationbezogenen `Switch*`-/`TurnOff*`-Pfade sind im gepinnten `Moose.lua` source-reviewed. Ihr neuer produktiver Einsatz für Transit-/Station-Identity-Handover besitzt noch keinen DCS-Nachweis und darf bis dahin nicht als `VALIDATED` bezeichnet werden.

### 6.1 Tankerauswahl – wichtige Framework-Grenze

Der gepinnte MOOSE-Quellstand wählt in `AIRWING:GetTankerForFlight(flightgroup)` unter kompatiblen Tankern nach Refuelling-System und anschließend nach 2D-Distanz. Eine OMW-spezifische FAST/SLOW-Klasse wird dort nicht ausgewertet.

`FLIGHTGROUP:Refuel(Coordinate)` routet den Receiver zu einem Refuel-Waypoint und erzeugt anschließend `TaskRefueling()`. Der Pfad bindet keine konkrete Tanker-ID; DCS refuelt am nächstgelegenen kompatiblen Tanker.

Daraus folgt für OMW:

```text
MissionDemand / OMW-Planung
-> passende AAR-Area wählen
-> FAST/SLOW-Profil bestimmen
-> benötigten Tanker in dieser Area materialisieren
-> Receiver zum passenden Refuel-Waypoint schicken
```

Der COMMANDER darf die strategische Rollenentscheidung nicht stillschweigend ersetzen. Die Steuerung erfolgt oberhalb des nativen Near-Tanker-Verhaltens durch Area-/Profilwahl und räumliche Trennung.

### 6.2 Relief-Lifecycle

Der aktuelle Controller nutzt keine eigene Tankerflugmechanik, sondern koordiniert MOOSE-Primitiven als kleine Station-Orchestrierungsschicht:

```text
ACTIVE
-> 3 h nominal station cycle
-> RELIEF_INBOUND queued early enough for approximately 5 min ETA at handover
-> outgoing station identity removed + AUFTRAG Cancel/Egress
-> relief reaches track-entry radius
-> relief receives station identity
-> actual takeover time starts the next 3 h cycle
```

Pro Station sind höchstens ein `ACTIVE` und ein `RELIEF_INBOUND` vorgesehen. `FuelLow` fungiert als Fallback: ein bereits geplanter Relief wird weiterverwendet; andernfalls wird genau ein Emergency Relief angefordert. Ein zweiter paralleler Relief derselben Station wird nicht erzeugt.

Diese Relief-/Handover-Orchestrierung ist implementiert und MOOSE-first source-reviewed, aber noch nicht im DCS-Lauf bestätigt.

## 7. FuelLow, Initial Fuel, Bingo und Egress

Produktive Initial-Fuel- und FuelLow-Werte:

| Area | Source | Initial Fuel | FuelLow |
|---|---|---:|---:|
| `LISA` | MANAS | 96 % | 24 % |
| `MOE` | MANAS | 96 % | 22 % |
| `MILHOUSE` | AL_UDEID | 90 % | 27 % |
| `KRUSTY` | AL_UDEID | 90 % | 27 % |
| `PATTY` | MANAS | 96 % | 21 % |
| `NELSON` | MANAS | 96 % | 20 % |

Für den produktiven Betrieb gilt:

1. keine künstlich beschleunigten Acceptance-FuelLow-Schwellen;
2. `FLIGHTGROUP:SetFuelLowRTB(false)` verhindert den ungeeigneten Standard-RTB zu einer DCS-Homebase;
3. die area-spezifische `SetFuelLowThreshold(...)`-Schwelle löst den projektspezifischen Egress-/Relief-Lifecycle aus;
4. `FuelLow -> ensure one relief -> Cancel -> Egress -> External Gate -> Off-map-Handoff` bleibt der produktive Ablauf;
5. verbleibender Onboard-Fuel wird nicht als eigene strategische Ressourcenhoheit geführt;
6. CampaignState führt ausschließlich die count-basierte strategische KC-135-Verfügbarkeit; bestätigter Handoff recreditiert exakt einmal.

## 8. Runtime-Acceptance – belegter Stand

Acceptance-2 bis Acceptance-6 haben den Tankermechanikpfad schrittweise belastbar gemacht.

### 8.1 Acceptance-6 Provenienz

```text
Testdatum: 2026-08-14
Branch: agent/aar-rc-east-runtime-scope
Source/Builder commit: 29dbcd377603405292a2f37a682d6f6b5b19dcf8
BuilderVersion/TestId: AAR-KC135-RUNTIME-ACCEPTANCE-6
Bundle SHA-256: 354433730acd0fc1eee4a3fe817cfaa870a054f3374dfab85f9814edfd29b091
Mission: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: 39da8370753e3ece055f0fd9f9dcc5dbeed2aa2eebe4540756931944f200963b
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: 8463b2ba50c53403002db2645fd0a3870e9e2d4a357c823f59df8ccb0f4eb58b
debrief.log SHA-256: 5741958a9812d3148a62e37b5a9f36d5692e9c35a6ac6e8c47b214b826843800
```

Belegt für diesen exakten Stand:

- fünf KC-135 gleichzeitig als Stress-Test-Ausnahme;
- alle fünf Tankermissionen `EXECUTING`;
- SLOW/FAST im selben Bereich mit 3.000 ft Staffelung;
- Boom-AAR mit A-10C, F-15E und F-16C;
- plausible positive Fuel-Zunahme der Receiver;
- FuelLow -> Cancel -> Egress -> <=10 NM Gate -> Off-map-Handoff;
- Y-Band-TACAN-Grundpfad.

### 8.2 Production Integration-3 / 3R1

Aktiver Branch:

```text
agent/aar-runtime-finalization
```

Owner-run Integration-3 auf Commit:

```text
4a6bef1c8a5b8f67606762e10c516610f970e491
```

Praktisch beobachtet:

- alle sechs MissionDemand-Mappings/Submissions;
- alle sechs area-spezifischen Templates;
- korrekte operative Callsigns in DCS/Controller-Logs;
- alle vier erforderlichen Same-source-Abstände mit 60.0 s;
- parallele Materialisierung aus MANAS und AL_UDEID.

Integration-3 enthielt zwei Harness-only False-Negatives:

- Callsign-Vergleich `Texaco21` gegen formatierte MOOSE/DCS-Rückgabe `Texaco2-1`;
- unmittelbarer `GROUP:GetFuelMin()`-Read konnte vor plausibler Unit-Initialisierung Sentinel `65535` liefern.

Der korrigierte Harness `AAR-PRODUCTION-INTEGRATION-3R1` normalisiert Callsign-Trenner und verschiebt die Fuel-Prüfung bis zu einem plausiblen `0..1`-Wert. Der Projektinhaber hat entschieden, **keinen weiteren DCS-Lauf allein wegen dieser Harness-Korrekturen durchzuführen**.

Früher lokal verifizierter 3R1-Buildstand:

```text
Git commit: 65be64ed9f8f3b8cd38e2e4493d08892c0d01822
BuilderVersion/TestId: AAR-PRODUCTION-INTEGRATION-3R1
ControllerSHA256: a937b67874dded3bb31ffcb4e7ea60d186ffde21f1e43bcccac4cf43f9e2da97
TestSourceSHA256: 2b5b195ef4b32dac12a4158b4f1e9aee23c18d85c847e480b3637f93e47a7b5d
BundleSHA256: 4a5cb783bc592557d7b6dfb9cec5751a1762c04eb1d9d1bbad427feb67d81b54
BuilderSHA256: BAD7395D1720ACAB9A8BD414ED57B8FEBBCDFB47B301BB92D76230C3064C77BC
CallsignNormalization: true
DeferredFuelRead: true
ArtificialFuelLow: false
FullTrackArrivalRequired: false
MizMutation: false
```

### 8.3 Owner-lokaler CampaignState-Source-Checkpoint

Am 15.08.2026 wurde nach Pull des Commits `7c244d49f5070b490784c2659be51f5c1739bb55` der neue CampaignState-Stock-/Adapter-Stand lokal geprüft. Das ist **kein DCS-Acceptance-Lauf**, sondern ein realer Source-/Build-/Hash-Nachweis.

```text
Git commit: 7c244d49f5070b490784c2659be51f5c1739bb55
BuilderVersion/TestId: AAR-PRODUCTION-INTEGRATION-3R1
ControllerSHA256: 0CFE2F12F5584606EA55E605D2CDC2D4F46FA458EAC2806406F1F5A0C4AE5D89
TestSourceSHA256: 2b5b195ef4b32dac12a4158b4f1e9aee23c18d85c847e480b3637f93e47a7b5d
BundleSHA256: 279CE58F94BBBA5AACFA2B3DEF2688E4DF9966CBD163C9393D14FEAE2DC85266
CampaignStateAdapterSHA256: B35D9630B17C7A8C0D9ADA2332C98BE064A5AD091479ABAB3537D1F786F43771
AARStrategicStockSHA256: 577D946520F2FC75B21E7920921F756AA6D979925CC11E8EFF1B16543A34986D
AirOpsCampaignStateInitializerSHA256: 6FF1BF960F655A477DF84E5887B21715696A34B2B8E9CD74D49FEAA62B659C92
CampaignStateDocSHA256: 606DECF6E6B47A851A189D6BD8A55C2A54067D6935C57A64FB1AFD3ECB077050
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die geprüften AAR-CampaignState-Dateien waren unverändert zu `HEAD`; der bestehende 3R1-Builder lief erfolgreich. `git status --short` enthielt nur untracked generierte/testbezogene Artefakte und keine getrackte Source-Abweichung.

## 9. Was nicht erneut getestet werden muss

Für den gepinnten DCS-/MOOSE-Stand ist kein weiterer isolierter Test erforderlich für:

- KC-135 Spawn/Heading/Transit als Grundmechanik;
- Racetrack und `EXECUTING`;
- Funk/TACAN-Grundpfad;
- Boom-AAR mit A-10C, F-15E und F-16C;
- FAST/SLOW-Geschwindigkeitsunterschied;
- 3.000-ft-Same-area-Staffelung;
- Five-tanker-Stressverhalten;
- FuelLow/Cancel/Egress/Off-map-Handoff als Grundmechanik;
- Integration-3R1-Harness-Korrekturen allein.

Noch **nicht** durch diese früheren Läufe bestätigt sind insbesondere der 3-h-Relief-Zyklus, die neue Transit-/Station-Identity-Umschaltung und die CampaignState-Consume-/Recredit-Kopplung.

## 10. Aktuelle To-do-Liste bis zum produktiven Abschluss

### Ziel A – Area-/Profilsteuerung und produktiver Tanker-Lifecycle

**Implementiert:**

- Mapping auf `LISA/MOE/MILHOUSE/KRUSTY/PATTY/NELSON`;
- sechs area-spezifische Mission-Editor-Templates;
- High-Transit-Profile und Source-Gates;
- Source-domain Spawnspacing 60 s;
- produktive Initial-Fuel- und FuelLow-Werte;
- nominaler 3-h-Station-Cycle;
- maximal ein `ACTIVE` plus ein `RELIEF_INBOUND` je Station;
- FuelLow-Fallback ohne doppelten Relief;
- Transit-/Station-Identity-Trennung über öffentliche MOOSE-Methoden.

**Noch zu tun:**

1. MissionDemand-Ende/Cancel in die Stationslogik integrieren, damit nach beendetem Bedarf keine endlose Relief-Kette weiterläuft;
2. finalen Receiver-Refuel-Waypoint-/MissionDemand-Anschluss in die übergeordnete Produktionssteuerung integrieren;
3. neue Relief-/Identity-Logik erst nach genehmigtem DCS-Lauf als praktisch bestätigt einstufen.

### Ziel B – CampaignState-Off-map-KC-135-Ressourcenvertrag

**Implementiert und owner-lokal source/build-verifiziert:**

```text
OFFMAP_MANAS    AIRCRAFT_KC135 = 16 count
OFFMAP_AL_UDEID AIRCRAFT_KC135 = 40 count
```

- keine künstliche DCS-Airbase;
- kein MOOSE WAREHOUSE für die Off-map-Pools;
- kein AIRWING für MANAS/AL_UDEID;
- Initializer-Schema v3 akzeptiert die beiden logischen Off-map-Knoten und mehrere zusätzliche Stockmodule;
- `OMW_AAR_CampaignStateAdapter.lua` bindet die Controller-Grenze `CanMaterialize`, `OnMaterialized`, `OnHandoff`;
- Materialisierung reserviert und konsumiert exakt eine KC-135-count-Ressource;
- bestätigter Handoff recreditiert exakt einmal über eine runtime-stabile Credit-ID;
- kein bestätigter Handoff bedeutet keine Recreditierung.

### Ziel C – Verlust, Abbruch und Persistenz

Der count-basierte Vertrag besitzt bewusst **keinen regulären Turnaround** und keine per-tail Aircraft-Recovery-Semantik. Die vorhandene Forced-Landing-Recovery bleibt davon getrennt.

**Noch zu tun:**

1. explizite Aircraft-Loss-Klassifikation/Logging ergänzen, ohne den fail-safe Grundsatz `no confirmed handoff -> no recredit` aufzuweichen;
2. Mission abort mit erfolgreichem Off-map-Handoff als normale Rückkehr behandeln; ohne Handoff keine automatische Rückbuchung;
3. Snapshot/Restore-Reconciliation definieren und prüfen, insbesondere für Saves während noch physische Tanker in der Luft sind;
4. sicherstellen, dass Runtime-/Credit-IDs nach Restore keine doppelte Recreditierung erlauben.

### Ziel D – Concurrency

Produktiv bleibt unabhängig vom strategischen Gesamtbestand:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Der strategische Pool `16/40` ist **kein Spawnlimit** und keine zweite operative Concurrency-Autorität. Die übergeordnete Produktionssteuerung muss die vorhandenen Limits weiter durchsetzen.

### Ziel E – nächste DCS-Integration

Kein weiterer Lauf für 3R1.

Ein neuer DCS-Lauf benötigt gemäß Governance die ausdrückliche Eigentümerfreigabe. Sobald der produktive Scope dafür vollständig ist, muss er mindestens prüfen:

1. verfügbare Off-map-count-Ressource wird korrekt erkannt;
2. Materialisierung reduziert die strategische Verfügbarkeit genau einmal;
3. 3-h-Relief-/Handover-Pfad erzeugt maximal einen Relief und wechselt die Station-Identität kontrolliert;
4. operative Concurrency bleibt eingehalten;
5. erfolgreicher Off-map-Handoff recreditiert genau eine KC-135;
6. kein bestätigter Handoff erzeugt keine unzulässige Recreditierung;
7. MANAS und AL_UDEID bleiben voneinander unabhängige Pools;
8. Multiplayer/Persistenz-Reconciliation, soweit im Teststand aktiviert.

### Ziel F – Dokumentation und Main-Integration

Vor Abschluss müssen mindestens konsistent aktualisiert sein:

- dieses Dokument `docs/29-isaf-2009-2013-air-to-air-refueling.md`;
- `docs/04-campaign-state.md` für Off-map-Pools und count-basierte Tanker-Verfügbarkeit;
- `docs/moose/PROJECT-CLASS-INDEX.md` für neu verwendete/relevante MOOSE-Pfade;
- `docs/moose/ISR-FAC-CAS-AAR.md`;
- `docs/moose/VERIFIED-METHODS.md` erst für neue Methoden, die tatsächlich im DCS-Lauf bestätigt wurden;
- `mission/tests/aar-production-integration/README.md` vor dem nächsten Acceptance-Stand;
- `docs/DOCUMENT-REGISTRY.md` und `docs/SUBPROJECT-REGISTRY.md`, soweit Status/PR/Abhängigkeiten betroffen sind.

Branch-Arbeit bleibt auf:

```text
agent/aar-runtime-finalization
PR #101
```

Die branch-spezifischen Inhalte werden **nicht durch einen parallelen Direkt-Commit auf `main` dupliziert**. Nach produktiver Integration und dokumentierter Acceptance wird PR #101 nach `main` integriert; anschließend wird `source_commit: PENDING_MERGE` durch den realen Integrations-Commit ersetzt und die Main-Register-/Dokumentationsreconciliation durchgeführt. Damit liegt derselbe fachliche Stand ohne divergierende Doppelpflege sowohl im Branch-Verlauf als auch auf `main` vor.

## 11. Architekturgrenze CampaignState

`CampaignState` bleibt strategische Autorität für Verfügbarkeit und Ressourcen. DCS-/MOOSE-Tanker sind temporäre physische Repräsentationen.

```text
CampaignState Off-map count pool / MissionDemand
-> AAR-Bedarf
-> Area + Profil + Source Domain
-> strategic adapter checks availability
-> MOOSE SPAWN / FLIGHTGROUP / AUFTRAG materializes tanker
-> CampaignState consumes 1 AIRCRAFT_KC135
-> Tanker / Relief arbeitet bis planned handover oder FuelLow
-> Egress / External Gate / confirmed Off-map-Handoff
-> CampaignState exact-once credit of 1 AIRCRAFT_KC135
-> erneut strategisch verfügbar
```

MOOSE Warehouse, AIRWING, DCS Warehouse und Tanker-Fuelzustand dürfen keine parallele strategische Ressourcenhoheit für die Off-map-KC-135-Pools aufbauen.
