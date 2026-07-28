---
document_id: OMW-HIST-AFGHAN-AIR-WARS-2009-2011
status: BINDING
document_class: SOURCE_CRITICAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical interpretation of Michael Napier's Afghan Air Wars for the OMW scenario period
  - historical airpower basing, mission patterns, capabilities and constraints derived from that source
  - mission-design requirements for ISR, CAS, air assault, AAR, airlift, CSAR and RED adaptation
not_authoritative_for:
  - active OMW air ORBAT or player slots
  - exact runtime inventory or squadron strength
  - DCS or MOOSE technical acceptance
  - target authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghan-air-wars-source-integration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Afghan Air Wars 2009-2011 - quellenkritische Airpower- und Operationsreferenz

## 1. Zweck

Dieses Dokument wertet Michael Napier, *Afghan Air Wars: Soviet, US and NATO Operations, 1979-2021* (Osprey, 2023), für Operation Mountain Watch aus.

Der Schwerpunkt liegt auf:

- dem OMW-Szenariozeitraum August 2010 bis Dezember 2011;
- historischen Basen, Verbänden und Luftfahrzeugrollen;
- Air C2, CAS, ISR, AAR, Airlift, Air Assault, CSAR und MEDEVAC;
- Terrain-, Wetter- und Hot-and-High-Einflüssen;
- gegnerischem Verhalten gegenüber überlegener Luftmacht;
- wiederverwendbaren Missionsmustern.

Die Quelle ist eine umfangreiche Sekundärsynthese. Sie ist für Missionsdesign sehr wertvoll, ersetzt aber keine Primärquelle und keine aktive ORBAT-Entscheidung.

## 2. Quellenklassifikation

```text
SOURCE_CLASS: SECONDARY_SYNTHESIS
SOURCE_VALUE: HIGH
MISSION_DESIGN_VALUE: VERY_HIGH
DIRECT_ORBAT_AUTHORITY: NO
REQUIRES_CROSSCHECK: YES
```

### 2.1 Stärken

- zusammenhängende Chronologie der Luftoperationen;
- zahlreiche konkrete Einsatzvignetten;
- Basen-, Einheiten- und Flugzeugzuordnungen;
- Beschreibung von Sensor-, Kommunikations- und Unterstützungsverbünden;
- Angaben zu Einsatzrhythmus, Bewaffnung, Wetter und Gelände;
- Air Order of Battle für Mitte 2009 als Vorperioden-Snapshot.

### 2.2 Grenzen und erkennbare Fehler

Die Quelle enthält mindestens folgende Punkte, die vor verbindlicher Übernahme gegengeprüft werden müssen:

- an einer Stelle wird die sowjetische Invasion fälschlich mit 1989 statt 1979 angegeben;
- einzelne Typ-, Waffen- oder Einheitenbezeichnungen können fehlerhaft oder verkürzt sein;
- die Air Order of Battle im Anhang ist ein Snapshot Mitte 2009 und keine ORBAT für August 2010 bis Dezember 2011;
- quantitative Angaben sind teils Jahres- oder Theaterwerte und keine gleichzeitig verfügbaren Kräfte;
- strategische Bewertungen des Autors sind Interpretationen und keine Primärquellenfeststellungen.

Verbindliche Regel:

```text
SOURCE_REPORTED != VERIFIED_PROJECT_FACT
HISTORICAL_ORBAT != ACTIVE_OMW_ORBAT
AIRCRAFT_PRESENT != AIRCRAFT_AVAILABLE_FOR_EVERY_MISSION
ANNUAL_SORTIE_TOTAL != SIMULTANEOUS_FORCE_LEVEL
```

## 3. Vorperiodische Air Order of Battle Mitte 2009

Der Anhang nennt folgende in Afghanistan stationierte Verbände und Rollen. Diese Liste dient als Ausgangspunkt für zeitgenaue Recherche, nicht als automatische OMW-Aktivierung.

### 3.1 Bagram

| Verband | Muster/Rolle |
|---|---|
| 421st EFS | F-16 Fighting Falcon |
| VAQ-134 USN | EA-6B Prowler |
| 74th EFS | A-10C Thunderbolt II |
| 41st EECS | EC-130H Compass Call |
| 336th EFS | F-15E Strike Eagle |
| ED 1/33 FAF | Harfang RPAS |

### 3.2 Camp Bastion

| Verband | Muster/Rolle |
|---|---|
| 28 Sqn RAF | Merlin HC3 |
| 662 Sqn AAC | AH-64D Apache |
| HMLA-167 USMC | AH-1W Super Cobra |
| HMLA-169 USMC | AH-1W Super Cobra |

### 3.3 Tarin Kowt

| Verband | Muster/Rolle |
|---|---|
| 301 Sqn RNLAF | AH-64 Apache |

### 3.4 Herat

| Verband | Muster/Rolle |
|---|---|
| 1 Regt Av It Army | CH-47C Chinook |
| 5 Regt Av It Army | A129 Mangusta |
| Esc 803 SpAF | Super Puma |
| 32 Stormo ITAF | MQ-1 Predator |

### 3.5 Jalalabad

| Verband | Muster/Rolle |
|---|---|
| 2-17 Cav US Army | OH-58D Kiowa |
| 1-101 Aviation Regiment | AH-64D Apache |
| 5-101 Aviation Regiment | Black Hawk, in der Quelle als MH-60G bezeichnet |
| 6-101 Aviation Regiment | CH-47 Chinook |

Die Bezeichnung `MH-60G` im Anhang ist besonders prüfbedürftig, weil dieser Typ regulär der USAF zugeordnet wird. Vor Übernahme in ein Manifest ist eine Primärquellenprüfung erforderlich.

### 3.6 Kabul

| Verband | Muster/Rolle |
|---|---|
| Bathelico French Army | EC665 Tiger HAP, EC725 Caracal, AS532 Cougar, SA341/342 Gazelle |

### 3.7 Kandahar

| Verband | Muster/Rolle |
|---|---|
| 1 Sqn RAF | Harrier GR9 |
| 31 Sqn Belgian Air Force | F-16AM |
| 311 Sqn RNLAF | F-16AM |
| EC 2/3 FAF | Mirage 2000D |
| ER 2/33 FAF | Mirage F1CR |
| 430th EECS | E-11A BACN |
| VMA-214 USMC | AV-8B Harrier |
| VMGR-352 USMC | KC-130J |
| HMH-362 USMC | CH-53D |
| HMH-772 USMC | CH-53D |
| 42nd EAS | MQ-9 Reaper |
| 39 Sqn RAF | MQ-9 Reaper |
| Task Force Erebus CAF | CU-170 Heron |

### 3.8 Mazar-e-Sharif

| Verband | Muster/Rolle |
|---|---|
| AG 51 German Air Force | Tornado IDS |
| 6 Stormo Italian Air Force | Tornado IDS |

### 3.9 Außerhalb Afghanistans

Die Quelle nennt unter anderem:

- KC-135 und C-17 in Manas;
- AC-130, U-2, JSTARS und RC-135 in Al Udeid;
- KC-10 und KC-135 in Al Dhafra;
- maritime ISR-Plattformen in Al Minhad und Seeb;
- B-1B in Thumrait;
- trägergestützte F/A-18, EA-18G und E-2.

Für OMW sind diese Standorte als virtuelle oder externe Support Nodes verwendbar. Sie erzeugen keine physische DCS-Basis außerhalb des Kartenumfangs.

## 4. Luftkriegsintensität 2011

Die Quelle beschreibt 2011 als Höhepunkt der Luftoperationen und nennt:

```text
34,514 CAS missions
5,411 weapons employed
57,000 airlift missions
38,000 ISTAR missions
19,500 AAR missions
```

Diese Werte sind nur als Theater- und Jahresindikatoren zu verwenden.

### 4.1 OMW-Interpretation

Sie belegen:

- hohe permanente Nachfrage nach CAS und ISR;
- erheblichen Tankerbedarf;
- eine sehr hohe logistische Abhängigkeit vom Lufttransport;
- die Notwendigkeit, Luftfahrzeuge über Missionszyklen und Verfügbarkeit zu begrenzen;
- dass die Waffenfreigabe trotz vieler CAS-Missionen nicht automatisch erfolgte.

Nicht zulässig:

```text
annual_mission_total -> direct DCS spawn count
annual_weapon_total -> mission weapon quota
```

## 5. ISR als System of Systems

Die Quelle beschreibt eine verteilte Sensorarchitektur:

- U-2S und RQ-4 für strategische Aufklärung;
- RQ-170 für besonders sensible Aufklärung;
- MQ-1, MQ-9, Heron und Harfang für taktische Dauerüberwachung;
- Sentinel R1 und JSTARS für SAR/MTI;
- RC-135 für SIGINT;
- MC-12W Liberty und weitere bemannte Plattformen für direkte taktische Unterstützung;
- Targeting Pods von Kampfflugzeugen als Non-Traditional ISR;
- ROVER für die Bildübertragung an Bodentruppen und JTAC;
- E-11A BACN und weitere Relay-Funktionen zur Überbrückung von Funkschatten.

### 5.1 Verbindliches Informationsmodell

```text
SENSOR_DETECTION
-> OBSERVATION_REPORT
-> SOURCE_CONFIDENCE
-> FUSION_WITH_OTHER_REPORTS
-> TRACK_OR_CONTACT
-> IDENTIFICATION
-> PID_AND_ROE_CHECK
-> TASKING_OR_MONITORING
```

Ein Sensor erzeugt weder automatisch ein bestätigtes Ziel noch eine Waffenfreigabe.

### 5.2 Pattern of Life

Die Quelle betont das Erkennen normaler Tagesmuster und daraus abgeleiteter Abweichungen. Für OMW benötigt jeder relevante Sektor daher mindestens:

```text
normal_activity_pattern
observation_coverage
pattern_confidence
anomaly_score
source_diversity
last_verified_time
```

Ein einzelner ungewöhnlicher Kontakt bleibt eine Anomalie. Erst wiederholte oder aus mehreren Quellen bestätigte Abweichungen erhöhen den Intelligence State.

## 6. RPAS im OMW-Zeitraum

Die Quelle beschreibt MQ-1 und MQ-9 als dauerhaft verfügbare taktische ISR-Plattformen, die zugleich bewaffnet eingesetzt werden konnten.

Für 2011 nennt sie für die RAF:

- fünf MQ-9 Reaper;
- ungefähr 12.000 Flugstunden;
- 111 eingesetzte Waffen.

Zum Vergleich nennt sie für acht Tornado GR4 ungefähr 6.000 Flugstunden und 73 eingesetzte Waffen.

### 6.1 OMW-Regel

RPAS sind weder grundsätzlich unbewaffnet noch grundsätzlich Strike Assets.

```text
RPAS_BASE_ROLE = ISR
RPAS_ARMED_CAPABILITY = OPTIONAL_AND_MISSION_DEPENDENT
WEAPON_RELEASE = PID + ROE + AUTHORIZATION + COLLATERAL_CHECK
```

Für den Missionsgenerator sind mindestens folgende Zustände zu unterscheiden:

- `UNARMED_ISR`;
- `ARMED_ISR_OVERWATCH`;
- `ON_CALL_STRIKE_CAPABLE`;
- `DEDICATED_STRIKE_SUPPORT`.

## 7. Operation Moshtarak als Missionsarchetyp

Die Quelle beschreibt eine kombinierte Luftlandeoperation im Februar 2010 mit ungefähr 50 Hubschraubern:

- kanadische CH-147 Chinook und CH-146 Griffon;
- britische Chinook, Merlin und Sea King;
- US-amerikanische CH-47, CH-53 und UH-60;
- Marine Aircraft Group 40;
- Task Force Pegasus der 82nd Airborne Division.

Vier RAF-Chinook transportierten in etwas mehr als zwei Stunden ungefähr 650 Soldaten in mehreren Chalks.

### 7.1 Unterstützungsverbund

- nächtlicher Tiefflug mit NVG;
- IR-Beleuchtung durch C-130;
- A-10 oder Tornado GR4 mit Targeting Pod über jeder LZ;
- RC-135 Rivet Joint für Echtzeit-SIGINT;
- Attack Helicopter gegen erkannte Mörserstellungen;
- wiederholte Transportzyklen zwischen Bastion und den LZs.

### 7.2 OMW-Missionsstruktur

```text
PHASE 1: ISR_AND_SIGINT_SHAPING
PHASE 2: LZ_SURVEILLANCE_AND_THREAT_ASSESSMENT
PHASE 3: ROUTE_AND_WEATHER_CONFIRMATION
PHASE 4: IR_ILLUMINATION_OR_NVG_INGRESS
PHASE 5: ATTACK_OVERWATCH
PHASE 6: MULTI_CHALK_INSERTION
PHASE 7: LZ_SECURITY_AND_LOCAL_CAS
PHASE 8: FOLLOW_ON_LIFTS_AND_RESUPPLY
PHASE 9: MEDEVAC_AND_QRF_STANDBY
PHASE 10: EXTRACTION_OR_TRANSITION_TO_HOLD
```

### 7.3 Abbruch- und Verzögerungsbedingungen

- LZ nicht positiv identifiziert;
- erhebliche Zivilpräsenz;
- Wetter unter Minimum;
- Verlust des Relay- oder ISR-Bildes;
- erkannte Mörser- oder MANPADS-Bedrohung ohne Suppression;
- unzureichende MEDEVAC- oder QRF-Abdeckung.

## 8. Dynamische CAS- und HVT-Vignette vom 11. November 2010

Die Quelle beschreibt eine Mission nordwestlich von Kandahar mit:

- zwei RAF Tornado GR4;
- MQ-9 Reaper;
- SOF-JTAC;
- CAOC-Unterstützung aus Al Udeid;
- KC-10 zur Verlängerung der Station Time;
- Brimstone, Paveway IV und 27-mm-Kanone;
- Zielübergaben zwischen Fast Jets, RPAS und JTAC;
- abschließendem Hellfire-Einsatz durch den Reaper.

### 8.1 Relevanz

Die Vignette stützt eine dynamische Missionserzeugung, bei der ein Flug als On-Call-CAS startet und sein konkretes Ziel erst im Einsatz erhält.

```text
AIRCRAFT_LAUNCH_ON_CALL
-> CHECK_IN_WITH_C2_OR_JTAC
-> RECEIVE_DYNAMIC_TASKING
-> BUILD_SHARED_TARGET_PICTURE
-> ASSIGN_SHOOTER_AND_SENSOR
-> ROE_AND_PID_CHECK
-> ENGAGE_OR_CONTINUE_TRACKING
-> HANDOVER
```

### 8.2 Shooter-Sensor-Trennung

Das beobachtende Luftfahrzeug muss nicht der Shooter sein. Der Planner darf Rollen anhand von:

- Bewaffnung;
- Station Time;
- Sensorqualität;
- Kollateralschadensrisiko;
- Kommunikationsfähigkeit;
- Anfluggeometrie;
- Treibstoffstatus

neu verteilen.

## 9. Air C2 und Kommunikationsarchitektur

### 9.1 Ebenen

```text
CAOC / THEATER_TASKING
-> REGIONAL_AIR_C2
-> MISSION_COMMANDER_OR_PACKAGE_LEAD
-> JTAC_AFAC_GROUND_FORCE_COMMANDER
-> SHOOTER_SENSOR_RELAY_ASSETS
```

### 9.2 Relay-Abhängigkeit

Gebirge und Täler erzeugen Funkschatten. BACN, Tanker-Relay, AWACS oder andere Relaisplattformen können daher missionskritisch sein.

OMW benötigt mindestens:

```text
communication_path_available
relay_asset_available
voice_net_quality
data_link_quality
terrain_masking_risk
handover_point
lost_comms_procedure
```

Ein Verlust des Relais soll nicht jede Mission sofort abbrechen. Er kann aber:

- das Lagebild verzögern;
- Dynamic Tasking verhindern;
- Waffenfreigaben aufschieben;
- einen Rückfall auf vorher festgelegte Ziele oder sichere Rückkehr erzwingen.

## 10. AAR und Station Time

Die Quelle zeigt AAR als Voraussetzung für lange CAS-, ISR- und Dynamic-Tasking-Missionen.

Für OMW ist Tankerunterstützung kein rein dekoratives Element. Sie beeinflusst:

- verfügbare Station Time;
- Zahl möglicher Zielübergaben;
- Reaktionsfähigkeit auf nachfolgende Notfälle;
- Rückkehrreserven;
- Ausweichflugplatzoptionen.

### 10.1 Planungsparameter

```text
planned_on_station_time
minimum_recovery_fuel
expected_tanker_offload
tanker_window
receiver_compatibility
weather_at_tanker_track
alternate_tanker_or_bingo_plan
```

## 11. Airlift und logistische Abhängigkeit

Die Quelle beschreibt Afghanistan als stark lufttransportabhängig. Große Entfernungen, unzureichende Straßen, IED-Bedrohung und Gebirge begrenzten den Bodentransport.

Airlift-Aufgaben umfassen:

- Personalrotation;
- Munition und Versorgung;
- Versorgung isolierter FOBs;
- taktische Verlegung;
- medizinische Evakuierung;
- dringende Ersatzteile;
- Unterstützung von Clear-Hold-Operationen.

### 11.1 Kampagnenwirkung

```text
AIRLIFT_CAPACITY
-> BASE_SUPPLY_LEVEL
-> SORTIE_GENERATION
-> GROUND_FORCE_READINESS
-> HOLD_STRENGTH
-> MEDEVAC_RESILIENCE
```

Ein ausgefallener Airlift-Knoten darf dadurch mittelbar BLUE-Präsenz, Missionsfrequenz und Hold-Fähigkeit senken.

## 12. CSAR und MEDEVAC

Die Quelle enthält mehrere Rettungsvignetten mit:

- UH-60A Dustoff;
- bewaffnetem UH-60L-Escort;
- HH-60G Pave Hawk;
- Pararescuemen;
- AH-64, A-10, F-15E und F-16 zur Suppression oder Show of Force;
- improvisiertem On-Scene Command;
- Tankerunterstützung;
- mehrmaligen abgebrochenen Landeanflügen unter Feuer.

Für Nordafghanistan nennt sie am 2. April zwei UH-60A Dustoff des 5-158 Aviation Regiment in Kunduz als MEDEVAC-Abdeckung für den gesamten Norden.

### 12.1 OMW-CSAR/MEDEVAC-Archetyp

```text
DISTRESS_OR_CASUALTY_REPORT
-> THREAT_AND_WEATHER_ASSESSMENT
-> LOCATE_AND_AUTHENTICATE
-> ESTABLISH_ON_SCENE_COMMAND
-> SUPPRESS_OR_DECEIVE_THREAT
-> INSERT_RECOVERY_OR_DUSTOFF_ELEMENT
-> EXTRACT
-> TRANSFER_TO_MEDICAL_FACILITY
```

### 12.2 Kein automatischer Rettungsstart

Ein Rettungseinsatz benötigt:

- bekannte oder ausreichend eingegrenzte Position;
- verfügbares Rettungsmittel;
- akzeptables Wetter;
- ausreichende Escort-/Suppression-Fähigkeit;
- geeigneten Übergabeort;
- Abbruchlogik bei zu hoher Bedrohung.

## 13. Afghan Air Force um 2010

Die Quelle nennt für 2010:

```text
18 Mi-17
3 Mi-35
2 An-26
6 An-32
2 L-39
```

Der Schwerpunkt lag in Kabul. Shindand war als Ausbildungsstandort vorgesehen. Die Mi-17 bildete das Rückgrat der AAF.

### 13.1 G222/C-27A-Programm

Die Quelle beschreibt:

- 20 bestellte Maschinen;
- 16 ausgelieferte Maschinen;
- unzureichende Hot-and-High-Leistung;
- geringe Zuverlässigkeit;
- spätere Außerdienststellung und Verschrottung.

Diese Angaben sind historische Kontextwerte und keine automatische OMW-Bestandsfreigabe.

## 14. Terrain, Wetter und Flugplatzbetrieb

### 14.1 Hot and High

Die großen Flugplätze liegen hoch:

- Kabul ungefähr 6.000 ft AMSL;
- Bagram ungefähr 5.000 ft AMSL;
- Shindand ungefähr 4.000 ft AMSL;
- Kandahar etwas über 3.000 ft AMSL.

Hohe Temperaturen verschärfen die Leistungsreduktion.

OMW muss für Hubschrauber und Transportflugzeuge unterscheiden:

```text
THEORETICAL_PAYLOAD
PERFORMANCE_LIMITED_PAYLOAD
MISSION_SAFE_PAYLOAD
```

### 14.2 Staub und FOD

- lose Steine und beschädigte Flächen gefährden Triebwerke und Zellen;
- Staub verstopft Filter und erhöht Verschleiß;
- Brownout erschwert Hubschrauberlandungen;
- unbefestigte oder einfache FOB-Pisten begrenzen Muster und Operationsrate.

### 14.3 Gebirge

- starke lokale Winde und Turbulenz;
- Funkschatten;
- eingeschränkte Sichtlinien;
- höhere Groundspeed bei dünner Luft;
- erschwerte Zielerfassung in Schluchten;
- geringe Ausweichmöglichkeiten.

### 14.4 Green Zones

- dichte Vegetation und hohe Nutzpflanzen;
- stark befestigte Compounds;
- Bewässerungsgräben als gedeckte Bewegungswege;
- extrem kurze Bodensichtweiten;
- sehr geringe Friendly-Enemy-Separation.

Folge:

```text
GREEN_ZONE_CONTACT
-> increased_PID_requirement
-> reduced_air_weapon_options
-> increased_JTAC_dependency
-> increased_small_group_escape_probability
```

### 14.5 Sandsturm

Die Quelle zeigt einen Sandsturm über Camp Bastion und beschreibt Sichtweiten bis etwa 300 m oder weniger. Solche Bedingungen können den Flugbetrieb vollständig stoppen.

## 15. Tarin Kowt

Die Quelle beschreibt Tarin Kowt 2010 als Standort einer sehr langen unbefestigten Piste, die dennoch durch C-130 genutzt wurde.

Für OMW folgt daraus:

- historische C-130-Nutzung ist grundsätzlich plausibel;
- tatsächliche DCS-Tauglichkeit muss mit der aktuellen Afghanistan-Map validiert werden;
- Staub, FOD und Pistenstatus müssen in Missionsplanung und Verfügbarkeit einfließen;
- historische Nutzung ist keine Garantie für jeden C-130-Typ oder jede Beladung.

## 16. RED-Commander-Verhalten gegenüber Luftmacht

Die Quelle stützt folgende Muster:

- lokale Spotter melden BLUE-Fahrzeuge, Truppen und Luftfahrzeuge;
- Hinterhalte werden häufig nachts vorbereitet;
- Beteiligte können sich tagsüber unbewaffnet und unauffällig bewegen;
- Rückzugswege werden vor dem Angriff festgelegt;
- Feuergefechte dauern häufig nur etwa 15 bis 20 Minuten;
- Rückzug erfolgt möglichst vor Eintreffen wirksamer Luftunterstützung;
- kleine, räumlich getrennte Gruppen erschweren Aufklärung und Bekämpfung;
- IEDs können einen Hinterhalt auslösen;
- Green Zones, Gräben, Compounds und Vegetation dienen als gedeckte Wege;
- bei überwältigender BLUE-Präsenz wird das Gelände nicht zwingend gehalten;
- nach Reduzierung oder Abzug von BLUE erfolgt Reinfiltration.

### 16.1 RED-Zielsetzung

```text
PRIMARY: preserve_network_and_specialists
SECONDARY: impose_time_and_resource_costs
TERTIARY: create_psychological_and_political_effect
NOT_PRIMARY: hold_ground_against_overwhelming_airpower
```

### 16.2 Angriffsvoraussetzungen

Ein lokaler Angriff soll bevorzugt stattfinden, wenn:

- ein Rückzugsweg vorbereitet ist;
- eine Beobachterzelle BLUE-Routinen bestätigt hat;
- erwartete CAS-Reaktionszeit länger als das geplante Engagement Window ist;
- Gelände Deckung und Zerstreuung erlaubt;
- kein dauerhaftes ISR-Track besteht;
- Cache oder Safehouse erreichbar ist.

### 16.3 Anpassung bei erwarteter Luftmacht

```text
BLUE_AIRPOWER_EXPECTED
-> shorten_engagement_window
-> increase_force_dispersion
-> reduce_radio_emissions
-> require_prepared_escape_route
-> avoid_repeated_firing_from_same_position
-> withdraw_before_QRF_or_CAS_arrival
```

### 16.4 Lernfähiger RED Commander

Der konsolidierte RED Commander soll sektoral lernen:

```text
estimated_CAS_response_time
estimated_QRF_response_time
common_patrol_routes
frequent_LZs
ISR_coverage_windows
night_activity_risk
tanker_supported_station_time
recent_BLUE_search_patterns
```

Dieses Wissen ist unvollständig und veraltet mit der Zeit. Es darf nicht als allwissendes Lagebild implementiert werden.

## 17. Wiederverwendbare Missionsarchetypen

### 17.1 Persistent ISR

```text
AREA_SELECTION
-> PATTERN_OF_LIFE_COLLECTION
-> ANOMALY_DETECTION
-> MULTI_SOURCE_CONFIRMATION
-> TRACK_HANDOVER
-> TASK_OR_ARCHIVE
```

### 17.2 On-Call CAS

```text
LAUNCH_WITHOUT_FIXED_TARGET
-> CHECK_IN
-> HOLD_OR_PATROL
-> RECEIVE_JTAC_TASK
-> PID_AND_ROE
-> ATTACK_OR_SHOW_OF_FORCE
-> REATTACK_DECISION
-> HANDOVER_OR_RTB
```

### 17.3 Air Assault

Siehe Abschnitt 7. Der Archetyp benötigt ISR, LZ-Overwatch, Transport, Escort, C2, MEDEVAC und Hold-Folgekräfte.

### 17.4 Convoy Overwatch

```text
ROUTE_RECCE
-> CHECK_AMBUSH_AREAS
-> MAINTAIN_AIR_OR_RPAS_OVERWATCH
-> DETECT_TRIGGER_OR_CONTACT
-> SUPPORT_BREAK_CONTACT
-> SEARCH_WITHDRAWAL_ROUTES
```

### 17.5 Isolated Base Resupply

```text
SUPPLY_REQUEST
-> THREAT_AND_WEATHER_CHECK
-> AIRLIFT_ASSIGNMENT
-> ROUTE_OR_APPROACH_PLANNING
-> ESCORT_OR_OVERWATCH
-> DELIVERY
-> RETURN_OR_CASUALTY_EVACUATION
```

### 17.6 CSAR/MEDEVAC

Siehe Abschnitt 12.

## 18. Integration in bestehende OMW-Dokumente

Dieses Dokument ergänzt, ersetzt aber nicht:

- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md);
- [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md);
- [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](45-air-c2-cas-afghanistan.md);
- [`OMW-AAR-ISAF-ACO`](29-isaf-2009-2013-air-to-air-refueling.md);
- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md);
- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md);
- [`OMW-HIST-MONTHLY-COALITION-ORBAT-BASING`](55-monthly-coalition-orbat-and-basing-2010-2011.md);
- [`OMW-RED-INSURGENT-FACTIONS-BEHAVIOR`](56-insurgent-factions-shadow-governance-and-red-commander-behavior.md);
- [`OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM`](57-kandahar-helmand-enemy-system-and-red-commander-strategy.md);
- [`OMW-RED-EASTERN-AFGHANISTAN-NETWORK-OPERATIONS`](58-eastern-afghanistan-network-operations-and-complex-attack-model.md);
- [`OMW-COIN-ASSESSMENT-TRANSITIONS-NONSTATE-SECURITY`](59-campaign-assessment-operational-transitions-and-nonstate-security.md);
- [`OMW-WX-HISTORICAL-BASELINE`](41-historical-weather-baseline-2010-2011.md);
- [`OMW-CSAR-INDEX`](csar/README.md).

## 19. Verbindliche Projektgrenzen

1. Die aktive ORBAT bleibt ausschließlich durch Dokument 19 bestimmt.
2. Der Anhang von Napier wird nicht unmittelbar in AIRWING- oder SQUADRON-Bestände umgesetzt.
3. Historische Waffen oder Plattformen erzeugen keine automatische DCS-Verfügbarkeit.
4. Die Quelle autorisiert keine Ziele und ändert keine NSL-/ROE-Regeln.
5. Der RED Commander bleibt in der Grundversion ein konsolidierter Gegner mit gemeinsamem REDState.
6. Mehrfraktionslogik bleibt zurückgestellt.
7. DCS-, MOOSE- und Mission-Editor-Verhalten muss separat technisch validiert werden.

## 20. Offene Verifikationsaufgaben

- Air-ORBAT Mitte 2009 gegen Primärquellen und monatliche 2010/2011-ORBAT prüfen;
- Jalalabad-Black-Hawk-Eintrag und Typbezeichnung klären;
- 2011-Einsatzstatistiken gegen offizielle NATO-/USAF-Berichte prüfen;
- AAF-Bestand 2010 und G222/C-27A-Programm gegen SIGAR/DoD-Dokumente prüfen;
- Tarin-Kowt-C-130-Nutzung gegen Flugplatz- und Einheitenquellen prüfen;
- Moshtarak-Paket gegen UK MoD, USAF und USMC-Primärberichte prüfen;
- November-2010-CAS-Vignette gegen Ursprungsberichte prüfen;
- CSAR-/MEDEVAC-Vignetten in die CSAR-Quellenmatrix überführen;
- technische Umsetzung erst nach MOOSE-First-Prüfung planen.
