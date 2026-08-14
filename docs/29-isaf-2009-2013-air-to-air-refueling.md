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
not_authoritative_for:
  - historical operational ACO authenticity
  - undocumented DCS behavior outside the recorded acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier AAR planning without consolidated runtime evidence and operational source-domain decisions
superseded_by:
source_branch: main
source_commit: 413b26377c0175abffde72aad03ea55f1d3e80d3
validated_in_dcs: partial
---

# 29 – ISAF 2009–2013: Air-to-Air Refuelling und OMW-AAR-Baseline

## 1. Einordnung

Dieses Dokument ist die verbindliche AAR-Planungs- und Designreferenz für **Operation Mountain Watch**. Es verbindet:

- die ursprüngliche ACO-/AAR-Quellenaufnahme;
- die für OMW korrigierte 2011-AIP-kompatible Geometrie;
- den geprüften MOOSE-/DCS-Runtimepfad;
- die aktuellen Eigentümerentscheidungen zu Kern-AAR-Areas, FAST/SLOW-Rollen und External Origins;
- die noch offenen produktiven Integrationsaufgaben.

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

### 5.1 Höhenprofil für Ingress und Egress

Für die produktive Umsetzung ist kein bodennaher, terrain-following Tankertransit vorgesehen.

Verbindliches Prinzip:

```text
External Gate
-> möglichst hoher, kraftstoffeffizienter Transit oberhalb des relevanten Geländes
-> rechtzeitig vor der Area auf die festgelegte Trackhöhe sinken
-> AAR-Racetrack
-> bei realem Low-Fuel/Bingo-Kriterium Egress einleiten
-> wieder auf die hohe Transit-/Egresshöhe steigen
-> External Gate
-> kontrollierter Off-map-Handoff
```

Damit wird das Hochgebirge nicht durch einen separaten niedrigen Ingress-Korridor gelöst, sondern durch ausreichend hohe Transitführung mit angemessener vertikaler Reserve. Exakte Transit-Flugflächen werden nicht pauschal festgeschrieben; sie müssen zum gewählten Entry-Korridor, zur Geländehöhe und zum jeweiligen AIP-Höhenband passen.

## 6. MOOSE-First-Runtimepfad

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-reviewed und praktisch verwendete Pfade umfassen insbesondere:

- `AUFTRAG:NewTANKER(...)`
- `AUFTRAG:SetRadio(...)`
- `AUFTRAG:SetTACAN(...)`
- `AUFTRAG:SetMissionEgressCoord(...)`
- `AIRWING:AddMission(...)`
- `AIRWING:GetTankerForFlight(...)`
- `FLIGHTGROUP:Refuel(...)`
- `FLIGHTGROUP:GetFuelMin()`
- `FLIGHTGROUP:SetFuelLowThreshold(...)`
- `FLIGHTGROUP:SetFuelLowRTB(false)`
- `COORDINATE:Get2DDistance(...)`
- `COORDINATE:Get3DDistance(...)`
- `OPSGROUP:Despawn(...)`

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

Der COMMANDER darf die strategische Rollenentscheidung nicht stillschweigend ersetzen. Die Steuerung erfolgt oberhalb des nativen Near-Tanker-Verhaltens durch Area-/Profilwahl und räumliche Trennung. Für `NELSON FAST` und `PATTY SLOW` ist die geografische Trennung gerade deshalb gewollt.

Ein weiterer isolierter Tankerauswahl-Test ist nicht erforderlich. Die erste produktive MissionDemand-/COMMANDER-Integration muss jedoch normal verifiziert werden; dies ist Integrationsprüfung, kein weiterer allgemeiner AAR-Mechaniktest.

## 7. FuelLow, Bingo und Egress

Die Acceptance-Harnesses verwendeten absichtlich beschleunigte FuelLow-Schwellen, zuletzt 99 %, um Egress und Off-map-Handoff in vertretbarer Testzeit auszulösen. Diese Schwellen sind **Testlogik und nicht produktiv**.

Für den produktiven Betrieb gilt:

1. keine 99-%- oder sonstige künstlich beschleunigte FuelLow-Schaltung;
2. MOOSE bleibt für die Fuel-Zustandserkennung zuständig;
3. `FLIGHTGROUP:SetFuelLowRTB(false)` verhindert den ungeeigneten direkten Standard-RTB zu einer DCS-Homebase;
4. das MOOSE-`FuelLow`-Event löst den projektspezifischen Wechsel `TANKER -> EGRESS` aus;
5. die produktive Low-Fuel-Schwelle ist eine reale Reserveentscheidung für Track-Abbruch, Egress und Off-map-Heimflug und darf nicht aus dem Acceptance-Harness übernommen werden;
6. nach Egress-Gate-Eintritt erfolgt der kontrollierte physische Off-map-Handoff.

Der gepinnte `FLIGHTGROUP` setzt ohne Override standardmäßig eine Low-Fuel-Schwelle von 25 % und aktiviert standardmäßig Low-Fuel-RTB. Für externe OMW-Tanker muss deshalb mindestens der RTB-Automatismus ausdrücklich deaktiviert werden. Ob 25 % als produktive OMW-Schwelle genügt oder eine origin-/area-spezifische Reserve erforderlich ist, wird analytisch aus Transit-/Reservebedarf festgelegt, nicht durch einen weiteren beschleunigten DCS-Test.

## 8. Runtime-Acceptance – belegter Stand

Acceptance-2 bis Acceptance-6 haben den Tankerpfad schrittweise belastbar gemacht. Acceptance-3 bleibt historisches Fehlerfixture; Acceptance-4/5 korrigierten TACAN, Heading, Receiver-Range und Egress; Acceptance-6 kombinierte den verbleibenden Mechaniknachweis.

### 8.1 Acceptance-6 Provenienz

```text
Testdatum: 2026-08-14
Branch: agent/aar-rc-east-runtime-scope
Source/Builder commit: 29dbcd377603405292a2f37a682d6f6b5b19dcf8
BuilderVersion/TestId: AAR-KC135-RUNTIME-ACCEPTANCE-6
Source SHA-256: 18ebd74e9c8c4d992367cf78146043bd5bc40e2b0d138f04767c22d3d88b0843
Builder SHA-256: 77b7ac3276cf509bc8beee590c68ab78c2fdd251aa4e43eafdcc769329c95ff1
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

- fünf KC-135 gleichzeitig als ausdrückliche Stress-Test-Ausnahme;
- alle fünf Tankermissionen `EXECUTING`;
- SLOW/FAST im selben Bereich mit exakt 3.000 ft Staffelung;
- A-10C Boom-AAR;
- F-15E Boom-AAR;
- F-16C Boom-AAR;
- plausible positive Fuel-Zunahme der Receiver;
- 60-s-Post-Refuel-Dwell;
- FuelLow -> Cancel -> Egress -> <=10 NM Gate -> Off-map-Handoff;
- Y-Band-TACAN-Pfad aus den vorherigen Acceptance-Läufen;
- Owner-Sichtbeobachtung bestätigte die tatsächlichen Betankungsvorgänge der Jets.

Nicht als Erfolg zu werten:

- C-130J-AAR. Die C-130J war eine falsche Receiver-Annahme und ist aus der AAR-Receiver-Matrix zu entfernen.
- die F-15E-Proximity-Inferenz auf einen bestimmten FAST-Donor. Der Receiver wurde betankt, aber die räumliche Nachmessung lieferte keine belastbare Donor-ID. Das bestätigt die oben dokumentierte Framework-Grenze.

Die fünf gleichzeitigen Tanker ändern die produktive Support-Concurrency nicht:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

## 9. Was nicht erneut getestet werden muss

Für den gepinnten DCS-/MOOSE-Stand ist kein weiterer isolierter Test erforderlich für:

- KC-135 Spawn/Heading/Transit;
- Racetrack und `EXECUTING`;
- Funk/TACAN-Grundpfad;
- Boom-AAR mit A-10C, F-15E und F-16C;
- FAST/SLOW-Geschwindigkeitsunterschied;
- 3.000-ft-Same-area-Staffelung;
- Five-tanker-Stressverhalten;
- FuelLow/Cancel/Egress/Off-map-Handoff als Mechanik.

Neue Tests werden nur dann erforderlich, wenn produktive Integrationslogik, MOOSE/DCS-Version, Mission-Template oder relevante Lifecycle-Annahmen geändert werden.

## 10. Verbleibende To-do-Liste bis zur produktiven AAR-Integration

### Ziel A – produktive Area-/Profilsteuerung

**Ziel:** MissionDemand bestimmt nachvollziehbar Area und FAST/SLOW-Profil; COMMANDER/AIRWING führen den Auftrag aus, ohne die strategische Rollenentscheidung zu übernehmen.

**Aktueller Stand:** MOOSE kann kompatible Tanker finden, entscheidet aber bei gleichem Refuelling-System nur nach Distanz und kennt keine OMW-FAST/SLOW-Klasse.

**Noch zu tun:**

1. MissionDemand-Felder für AAR-Bedarf, Receiver-Klasse und Operationsraum festlegen.
2. Mapping auf `LISA/MOE/MILHOUSE/KRUSTY/PATTY/NELSON` implementieren.
3. Tanker-AUFTRAG nur für die gewählte Area/Profil-Kombination erzeugen.
4. Receiver auf den passenden Refuel-Waypoint routen.
5. normale Integrationsverifikation beim ersten produktiven Einsatz; kein eigener Acceptance-7-Mechaniktest.

### Ziel B – produktiver FuelLow-/Egress-Vertrag

**Ziel:** Tanker bleiben bis zur realen planungsseitigen Low-Fuel-/Bingo-Reserve auf Station und gehen dann kontrolliert in Egress.

**Aktueller Stand:** MOOSE stellt `GetFuelMin`, `FuelLow`, `SetFuelLowThreshold` und `SetFuelLowRTB` bereit; die 99-%-Acceptance-Schwelle war ausschließlich Testbeschleunigung.

**Noch zu tun:**

1. alle beschleunigten Acceptance-Schwellen aus produktivem Code fernhalten;
2. für externe Tanker `SetFuelLowRTB(false)` setzen;
3. origin-/area-spezifischen Reservebedarf analytisch bestimmen;
4. daraus die produktive `SetFuelLowThreshold(...)`-Schwelle ableiten;
5. `OnAfterFuelLow`/FuelLow-Callback für `Cancel -> Egress -> Gate -> Off-map-Handoff` verwenden;
6. CampaignState-/Off-map-Recovery-Abrechnung anbinden.

### Ziel C – High-Transit-Höhenprofil

**Ziel:** Tanker fliegen Gate↔Area möglichst hoch und kraftstoffeffizient, mit ausreichendem Abstand zum afghanischen Hochgebirge, und wechseln nur für die AAR-Phase auf Trackhöhe.

**Aktueller Stand:** AIP-Entry-/Airway-Höhenbänder sind erfasst; die sechs Core-Areas und ihre Source Domains sind festgelegt.

**Noch zu tun:**

1. pro Source-Domain/Entry die zulässige hohe Transit-Flugfläche bestimmen;
2. ausreichend vertikale Terrain-Reserve dokumentieren;
3. Sinkpunkt zur Trackhöhe und Steigpunkt nach Egress festlegen;
4. diese Werte in die produktive Tanker-Missionskonfiguration übernehmen.

Dies ist Planungs-/Implementierungsarbeit, kein zusätzlicher allgemeiner AAR-Funktionstest.

## 11. Architekturgrenze CampaignState

`CampaignState` bleibt strategische Autorität für Verfügbarkeit und Ressourcen. DCS-/MOOSE-Tanker sind temporäre physische Repräsentationen.

```text
CampaignState / MissionDemand
-> AAR-Bedarf
-> Area + Profil + Source Domain
-> MOOSE AIRWING/AUFTRAG materialisiert Tanker
-> Tanker arbeitet bis FuelLow/Bingo-Reserve
-> Egress / Off-map-Handoff
-> CampaignState-/Recovery-Abrechnung
```

MOOSE Warehouse, DCS Warehouse und Tanker-Fuelzustand dürfen keine parallele strategische Ressourcenhoheit aufbauen.
