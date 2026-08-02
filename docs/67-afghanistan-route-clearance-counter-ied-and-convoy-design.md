---
document_id: OMW-CIED-ROUTE-CLEARANCE-CONVOY-DESIGN
status: BINDING
document_class: SOURCE_CRITICAL_MISSION_DESIGN_REFERENCE
authoritative_for:
  - Afghanistan route-clearance mission archetypes
  - C-IED and convoy risk abstractions
  - terrain, season, formation and recovery design factors
  - OMW standard logistics convoy composition
scenario_period: 2010-08-01/2011-12-31
source_branch: main
source_commit: PENDING_COMMIT
validated_in_dcs: false
---

# Afghanistan Route Clearance, Counter-IED and Convoy Mission Design

## 1. Sources

- ISAF *Counter Improvised Explosive Device Smart Book*.
- Center for Army Lessons Learned Handbook 09-33, *Afghanistan Route Clearance Supplement*, May 2009.

The documents are historical training and lessons-learned references. OMW uses them to build mission logic, not as current safety instructions.

## 2. IED functional model

```text
firing_system -> initiator -> main_charge
power_source supports the firing system
```

Historical trigger classes include pressure plate or victim operation, command wire, radio control, timer, vehicle-borne and person-borne devices.

## 3. Indicators

The Smart Book lists unusual vehicle behavior, fresh earth, obstacles intended to slow or canalize traffic, changes in pattern of life, visible or buried wires, trigger markers, unusual shapes, UXO/mines and suspicious objects in potholes, shoulders, tire tracks, culverts, packaging or loads.

```text
INDICATOR_PRESENT != IED_CONFIRMED
NO_VISIBLE_INDICATOR != ROUTE_SAFE
```

## 4. Vulnerable points and route geometry

Risk multipliers include soft sand, sharp turns, streambeds, culverts, bridges, water crossings, steep slopes, choke points and narrow roads. These locations slow, conceal or canalize a formation and shall be represented through infrastructure markers coordinated with document 49.

## 5. Afghanistan environment and season

The CALL source distinguishes northern steppe, southern desert plateau and Hindu Kush terrain. Roads may be unimproved, seasonally displaced, damaged, flooded, washed out or replaced by dry riverbeds. Mountain routes provide concealment and ambush positions; open desert produces different observation and standoff patterns.

- winter can block ground movement;
- spring thaw reopens routes and increases activity;
- summer heat and dust constrain movement;
- autumn may see renewed IED activity before winter preparation.

The source describes lowland IEDs as commonly initiating attacks and sometimes targeting responders, while highland IEDs often shape movement and support ambush. These are tendencies, not deterministic rules.

## 6. Route Clearance Package capabilities

| Capability | Typical platform | OMW role |
|---|---|---|
| detection | Husky/Meerkat, mine roller | lead search and lane proofing |
| interrogation | Buffalo; limited RG-31 arm | investigate suspicious point |
| EOD | EOD team/platform | render-safe and exploitation |
| C2/security | RG-31/MRAP and gun trucks | command, overwatch and 360-degree security |
| recovery | M984 HEMTT, M916/M870 | recover disabled heavy vehicles |
| optical detection | stabilized day/night/thermal camera | standoff observation and information sharing |

Exact DCS substitutes must be declared where source equipment is unavailable.

## 7. Formation principles

Formation varies with route type, surface, emplacement history, indicators, intelligence, width, time constraints and enemy observation. A rigid permanent order creates predictability.

```text
DETECTION -> INTERROGATION -> EOD
SECURITY and C2 distributed across formation
RECOVERY protected but positioned for access
```

Narrow routes may prevent an interrogation vehicle from moving forward. Lane choice and order of march should vary when tactically plausible.

## 8. Suspicious-device state machine

```text
ROUTE_MOVEMENT
  -> SUSPICIOUS_INDICATOR
  -> HALT_AND_LOCAL_CHECK
  -> CONFIRM_OR_DISMISS
  -> CLEAR_AREA
  -> CORDON
  -> CONTROL
  -> EOD_RESPONSE
  -> EXPLOITATION
  -> ROUTE_REOPEN_OR_CLOSED
```

The source describes 5-meter and 20-meter checks, standoff observation, communication, clearing, cordon and control. Real-world distances may be abstracted for gameplay and map scale.

## 9. Attack composition

An IED event may include a primary detonation, secondary device, trigger-man or observer, small-arms/RPG ambush, indirect fire, delayed attack on recovery/EOD and information exploitation.

The Smart Book's METHANE structure supports player reporting: military/callsign, exact location, time/type, hazards, approach and helicopter landing site, casualties and expected response.

## 10. Convoy and Watchguard implications

1. Route risk varies by geometry, recent incidents, pattern of life and season.
2. Immobilization can result from terrain, damage, blockage or tactical halt.
3. Recovery assets need protected access.
4. Watchguard recovery must not teleport a detected or engaged group.
5. An unpacked/visible group remains subject to navigation and stuck detection.
6. Repeated formations, lanes or timing increase RED adaptation.
7. Route clearance creates a temporary confidence window, not permanent safety.

## 11. Verbindliche OMW-Logistikkonvoi-Vorlagen

Der Projektinhaber legt zwei reguläre BLUE-Logistikkonvoi-Vorlagen fest. Beide ersetzen die bisherige HMMWV-basierte Testvorlage `TPL_TEST_BLUE_CONVOY_STANDARD_01` für neue Builds und neue DCS-Abnahmen.

### 11.1 TPL_BLUE_CONVOY_LIGHT_06

| Position | Fahrzeug | Funktion |
|---:|---|---|
| 1 | M-ATV | Lead Security |
| 2 | M1083 | Cargo 1 |
| 3 | MaxxPro | Convoy Commander / C2 |
| 4 | M1083 | Cargo 2 |
| 5 | MaxxPro | Support / Security |
| 6 | M-ATV | Rear Security |

```text
2 x M-ATV
2 x MaxxPro
2 x M1083
6 Fahrzeuge
```

### 11.2 TPL_BLUE_CONVOY_STANDARD_07

| Position | Fahrzeug | Funktion |
|---:|---|---|
| 1 | M-ATV | Lead Security |
| 2 | M1083 | Cargo 1 |
| 3 | MaxxPro | Convoy Commander / C2 |
| 4 | M1083 | Cargo 2 |
| 5 | MaxxPro | Mid-column Security / Support |
| 6 | M1083 | Cargo 3 |
| 7 | M-ATV | Rear Security |

```text
2 x M-ATV
2 x MaxxPro
3 x M1083
7 Fahrzeuge
```

### 11.3 Auswahl- und Laufzeitregel

Reguläre TM01M-Konvois wählen ihre Vorlage unabhängig je Spawn über die MOOSE-Funktion `SPAWN:InitRandomizeTemplate()` aus:

```text
TPL_BLUE_CONVOY_LIGHT_06
TPL_BLUE_CONVOY_STANDARD_07
```

Es wird keine eigene Lua-Zufallsfunktion eingeführt. Beide Mission-Editor-Gruppen müssen vorhanden und `Late Activation` sein. Ein fehlendes Template führt zu `FAIL_CONFIGURATION`.

Die Laufzeitlogik muss deshalb sechs und sieben Fahrzeuge als zulässige Anfangsstärke akzeptieren, die tatsächlich ausgewählte Variante protokollieren und die Ankunftsstärke anhand der real erzeugten Gruppe auswerten. Bei fünf gleichzeitig erzeugten Konvois liegt die unbeschädigte Gesamtstärke abhängig von der Auswahl zwischen 30 und 35 Fahrzeugen.

Für die absolute MOOSE-Spawnpositionierung wird ein Sieben-Slot-Layout berechnet. Beim Light-Template nutzt MOOSE nur die ersten sechs Positionen; der siebte hintere Slot bleibt unbesetzt. Dadurch bleibt die Fahrzeugreihenfolge beider Templates unverändert, ohne eigene Positions- oder Spawnlogik außerhalb von MOOSE einzuführen.

Die alte Gruppe `TPL_TEST_BLUE_CONVOY_STANDARD_01` ist aus der aktuellen Mission-Editor-Vorlagenbibliothek zu entfernen. Neue Laufzeitkonfigurationen dürfen sie nicht mehr referenzieren.

Bereits bestandene Ergebnisberichte der früheren sechs Fahrzeuge umfassenden Testvorlage bleiben als historische Nachweise ihres exakt getesteten Stands erhalten und werden nicht rückwirkend umgeschrieben.

Diese Zusammensetzungen sind bewusste OMW-Missionsdesign- und Spielbarkeitsentscheidungen. Sie werden nicht als Behauptung verstanden, dass jeder reale Konvoi im gesamten Szenariozeitraum exakt eine dieser unveränderlichen Reihenfolgen verwendete. Missionsspezifische Route-Clearance-, EOD-, Recovery-, VIP-, QRF- oder schwerere Versorgungskonvois dürfen eigene, ausdrücklich dokumentierte Templates verwenden.

## 12. Source limits

- The repository stores paraphrased mission-design abstractions, not the FOUO source PDFs.
- Equipment protection values and real procedures are not reproduced as current specifications.
- No content replaces contemporary explosive-safety guidance.
