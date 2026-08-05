---
document_id: OMW-HIST-STRYKER-KANDAHAR-2009
status: BINDING
document_class: SOURCE_CRITICAL_OPERATIONAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical 5/2 SBCT and 1-17 Infantry operations in Kandahar Province in 2009
  - Stryker battalion organization, mobility, IED exposure and COP-establishment patterns
  - mission-design baselines for Arghandab, Shah Wali Kot and Kandahar approaches
not_authoritative_for:
  - active OMW ORBAT
  - exact 2010-2011 Stryker dispositions
  - DCS vehicle survivability calibration without testing
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/afghanistan-aip-kaia-lop
source_commit: 72fbd7d10181990497c606d2d2c84f29580de996
supersedes: []
superseded_by: []
validated_in_dcs: false
---

# Stryker Brigade Operations in Kandahar, 2009

## 1. Quelle und Zweck

Grundlage ist die offizielle CSI-Studie *Strykers in Afghanistan: 1st Battalion, 17th Infantry Regiment in Kandahar Province, 2009*. Sie behandelt den ersten Afghanistan-Einsatz eines Stryker Brigade Combat Team und die frühen Operationen von 1-17 Infantry.

```text
SOURCE_PERIOD = 2009
SCENARIO_PERIOD = 2010-08-01/2011-12-31
USE = HISTORICAL_BASELINE_AND_DIRECT_PRECURSOR
```

## 2. 5/2 SBCT – Einsatzgliederung

Die 5th Stryker Brigade Combat Team, 2nd Infantry Division, traf im Sommer 2009 in Kandahar ein. Die Quelle beschreibt folgende Dislozierung:

| Verband | Rolle/Raum |
|---|---|
| 2-1 Infantry | RC-South Regional Reserve in Kandahar |
| TF Zabol, darunter 4-23 Infantry und Romanian 280th Battalion | Zabul und südwestliche Verbindungen nach Kandahar |
| 8-1 Cavalry | südlich Kandahar City |
| 1-17 Infantry | Arghandab River Valley und Shah Wali Kot; nördliche Zufahrten |

Strategische Absicht:

- Kandahar City nicht primär mit zusätzlichen US-Kräften besetzen;
- Zufahrten und gegnerische Lines of Communication stören;
- ANSF innerhalb der Stadt stärker nutzen;
- Verbindungen Pakistan–Kandahar–Helmand unter Druck setzen.

## 3. Nominelle SBCT-Struktur

Die Quelle beschreibt ein Stryker Brigade Combat Team mit:

- RSTA Squadron;
- Artillery Battalion;
- Brigade Support Battalion;
- drei Infantry Battalions;
- Brigade HHC;
- Anti-Tank Company;
- Engineer Company;
- Military Intelligence Company;
- Signal Company.

## 4. Stryker-Infanteriebataillon

### 4.1 Rifle Companies

Ein Bataillon verfügte über drei Rifle Companies. Jede Rifle Company hatte:

- 14 Stryker Infantry Carrier Vehicles;
- MGS Platoon;
- 60-mm Mortar Section;
- Sniper Team.

Nominelle ICV-Basis:

```text
3 RIFLE COMPANIES × 14 STRYKER ICV = 42 STRYKER ICV
```

Diese Zahl umfasst nicht automatisch:

- Command Vehicles;
- Mortar Carriers;
- Reconnaissance Vehicles;
- Fire Support Vehicles;
- Engineer Squad Vehicles;
- Medical Evacuation Vehicles;
- ATGM Vehicles;
- NBC Reconnaissance Vehicles;
- Recovery- oder Supportfahrzeuge.

### 4.2 HHC

Die Headquarters and Headquarters Company enthielt:

- Scout Platoon;
- Fire Support Platoon;
- Mortar Platoon mit vier 81-mm-Mörsern;
- Sniper Squad;
- Medical Platoon.

## 5. Fahrzeugfamilie und Fähigkeiten

Dokumentierte Varianten:

| Variante | Rolle |
|---|---|
| M1126 ICV | Infanterietransport und mounted fire support |
| M1127 RV | Aufklärung und Situational Awareness |
| M1128 MGS | 105-mm Direct Fire |
| M1129 MC | 120-mm Mortar |
| M1130 CV | Command and Control |
| M1131 FSV | Fire Support und Target Acquisition |
| M1132 ESV | Engineer, Mine Roller/Plow, MICLIC |
| M1133 MEV | Medical Evacuation |
| M1134 ATGM | TOW |
| M1135 NBC RV | NBC Detection |

Der M1126 transportierte neun Infanteristen und führte je nach Konfiguration M2HB oder Mk 19. Slat Armor sollte RPG-Wirkung reduzieren.

## 6. Operation BUFFALO STAMPEDE

Zweck:

- Sicherung von Wahllokalen;
- schnelle Konzentration in Shah Wali Kot und Arghandab;
- Bekämpfung erkannter Taliban-Sammelräume;
- Demonstration hoher taktischer Mobilität.

Am 18. August 2009 bewegte sich eine Formation von zehn Stryker ICV mit ungefähr 20 mph auf Buyana zu. Die Fahrzeuge bildeten am Ziel eine V-Formation, setzten Mounted Weapons ein und ließen Infanterie absitzen.

Missionsmodell:

```text
INTELLIGENCE_CUE
  -> RAPID_MOUNTED_APPROACH
  -> SUPPORT_BY_FIRE_POSITION
  -> DISMOUNT
  -> CLEAR_COMPOUNDS
  -> REEMBARK_OR_ESTABLISH_SECURITY
```

## 7. Operation OPPORTUNITY HOLD

Nach der Wahl sollte 1-17 Infantry:

- den Gegner westlich des Arghandab River verdrängen;
- Gelände halten;
- zwei Combat Outposts errichten;
- künftige Operationen ermöglichen.

Dies zeigt die zwingende Kette:

```text
CLEAR
  -> SECURE_CONSTRUCTION_SITE
  -> BUILD_COP
  -> OCCUPY_COP
  -> OPEN_SUPPLY_ROUTE
  -> MAINTAIN_FORCE
  -> EXPAND_LOCAL_SECURITY
```

Ein taktischer Clearing-Erfolg ohne COP, Route, Versorgung und Ablösung erzeugt keinen dauerhaften Hold-Effekt.

## 8. Gelände und Beweglichkeit

Wichtige Geländearten:

- Arghandab River Valley;
- Bewässerungskanäle;
- Obstgärten;
- dichte Vegetation;
- Flussquerungen;
- Wadis;
- schmale Wege;
- offener Wüstenraum;
- Highway 1;
- Gebirgspässe in Shah Wali Kot.

```text
ROAD_SPEED_ADVANTAGE != CROSS_COUNTRY_FREEDOM
VEHICLE_MOBILITY != DISMOUNTED_ACCESS
FAST_APPROACH != SAFE_APPROACH
```

Die Fahrzeuge konnten Zeit und Raum verkürzen, blieben aber durch IEDs, Kanalübergänge, weichen Untergrund und enge Vegetation eingeschränkt.

## 9. IED- und Schutzmodell

Die Quelle beschreibt hohe Verluste trotz geschützter Fahrzeuge. Für OMW:

```yaml
vehicle_state:
  mobility_kill:
  weapon_kill:
  crew_casualties:
  passenger_casualties:
  recovery_required:
  route_blocked:
  follow_on_ied_risk:
```

Verbindliche Regeln:

```text
ARMORED != INVULNERABLE
VEHICLE_SURVIVES != CREW_UNINJURED
MOBILITY_KILL != TOTAL_LOSS
RECOVERABLE != IMMEDIATELY_AVAILABLE
IED_STRIKE != SINGLE_EVENT_ONLY
```

## 10. Mounted-/Dismounted-Verhältnis

Stryker-Erfolg beruhte auf der Kombination:

- schneller Annäherung;
- digitaler Lageinformation;
- schweren Bordwaffen;
- hoher Zahl absitzender Infanteristen;
- schneller Verlagerung;
- Fire Support.

Nicht zulässig:

```text
STRYKER_UNIT = VEHICLE_ONLY_FORCE
```

Korrekt:

```text
STRYKER_EFFECT = MOBILITY + PROTECTION + DISMOUNTED_INFANTRY + FIRES + C2
```

## 11. Land Warrior und digitales Lagebild

Key Leaders konnten mit Land Warrior:

- Karten anzeigen;
- Friendly/Enemy Locations markieren;
- Wege markieren;
- Informationen zwischen Führern teilen.

Fahrzeugkommunikation stellte Friendly Positions und Textmeldungen bereit.

Für OMW ist daraus kein allwissendes Blue-Force-Tracking abzuleiten:

```text
DIGITAL_TRACK != PERFECT_LOCATION
MARKER != VERIFIED_CONTACT
DATA_LINK_AVAILABLE != DATA_CURRENT
```

## 12. Logistics und Recovery

Die hohe Beweglichkeit erzeugte gleichzeitig:

- hohen Kraftstoffbedarf;
- Ersatzteilbedarf;
- Reifen- und Fahrwerkbelastung;
- Recovery-Anforderungen;
- Bedarf an Route Security;
- Munitions- und Wasserverbrauch;
- MEDEVAC-Aufkommen.

Empfohlene Zustände:

```yaml
stryker_company:
  total_vehicles:
  mission_ready:
  damaged_recoverable:
  destroyed:
  fuel_state:
  ammunition_state:
  recovery_assets:
  dismounted_strength:
  medical_capacity:
```

## 13. RED-Anpassung

Mögliche gegnerische Gegenmaßnahmen:

- größere IED-Ladungen;
- Ketten von IEDs;
- Kanal- und Brückenfallen;
- Angriff auf Recovery;
- Nutzung enger Vegetation;
- Ausweichen vor Mounted Contact;
- Angriff auf abgesessene Elemente;
- Beobachtung von COP-Bau und Supply Routes.

```text
BLUE_MOBILITY_GAIN
  -> RED_OBSERVATION
  -> ROUTE_PREDICTION
  -> IED_ADAPTATION
  -> RECOVERY_AMBUSH
  -> BLUE_ROUTE_CHANGE
```

## 14. Missionseditor- und MOOSE-Konsequenzen

- Stryker Companies nicht nur als 14 identische ICV modellieren;
- Spezialvarianten und Support getrennt anlegen;
- Mission-ready und Bestand trennen;
- abgesessene Infanterie als Hauptwirkungsträger behandeln;
- Recovery und CASEVAC als echte Missionsketten;
- COP-Aufbau benötigt Engineer, Security und Logistics;
- Straßennetz und Gelände bestimmen Formation und Geschwindigkeit;
- Convoy-Watchguard muss beschädigte, entpackte und angegriffene Gruppen berücksichtigen.

## 15. Querverweise

- `docs/49-msr-routendesign-und-infrastrukturmarker.md`
- `docs/57-kandahar-helmand-enemy-system-and-red-commander-strategy.md`
- `docs/67-afghanistan-route-clearance-counter-ied-and-convoy-design.md`
- `docs/68-kandahar-city-and-dand-operational-environment-2010.md`
- `docs/75-vanguard-of-valor-small-unit-operations-2006-2011.md`
