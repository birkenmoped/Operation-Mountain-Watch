---
document_id: OMW-AIR-SALERNO-MANIFEST
status: BINDING_PROJECT_DECISION
document_class: MISSION_EDITOR_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - FOB Salerno active local air ORBAT
  - FOB Salerno Mission Editor clients templates statics warehouse and parking policy
  - Task Force Tigershark organizational representation in Operation Mountain Watch
not_authoritative_for:
  - project-wide client limits
  - branch-independent DCS runtime acceptance
  - exact historical maintenance or mission-ready rates on a single satellite date
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Khost Salerno research ranges of 12-16 AH-64D 4-8 OH-58D 2-4 UH-60 and 0-2 CH-47
  - provisional Salerno 6 AH-64D 6 OH-58D 8 UH-60 and 6 CH-47 working estimate
superseded_by:
source_branch: agent/document-salerno-air-operations
source_commit: PENDING_MERGE
validated_in_dcs: false
source_status: SOURCE_AND_PROJECT_DECISION_CAPTURED
validation_status: MISSION_EDITOR_IMPLEMENTATION_PENDING
---

# 51 – FOB Salerno Air Operations Manifest

## 1. Zweck und Autorität

Dieses Manifest legt den aktiven Luftoperationsknoten **FOB Salerno** für Operation Mountain Watch fest. Es ergänzt [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md) um die lokale Task-Force-Tigershark-Baseline und setzt die allgemeinen Regeln aus folgenden Dokumenten um:

- [`OMW-GOV-001`](00-project-governance.md);
- [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md);
- [`OMW-AIR-ME-WORKLIST`](20-air-orbat-mission-editor-worklist.md);
- [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md);
- [`OMW-AIR-MANIFEST-NAMING`](52-air-operations-manifest-naming-standard.md).

Die Zahlen dieses Dokuments sind verbindliche OMW-Bestands- und Missionseditorentscheidungen. Sie sind keine Behauptung, dass jede Maschine auf jeder historischen Aufnahme gleichzeitig sichtbar oder einsatzbereit war.

## 2. Standort- und Organisationsmodell

```text
Luftoperationsknoten: FOB Salerno
DCS-Flugplatzbezug:   Khost Airfield
AIRWING:              AW_US_SALERNO
Warehouse-Anker:      WH_AIR_US_SALERNO
Kurzcode:              SAL
Führungsverband:       Task Force Tigershark
Lead Formation:        1st Battalion, 10th Aviation Regiment
Higher Formation:      10th Combat Aviation Brigade / 10th Mountain Division
```

FOB Salerno erhält einen eigenen Army-Aviation-`AIRWING`. Khost Airfield erhält durch dieses Dokument **keinen zweiten parallelen US-AIRWING**. Ein eigener Khost-Knoten wird nur angelegt, wenn später eine dauerhaft getrennte lokale Luftkomponente belegt und ausdrücklich beschlossen wird.

## 3. Verbindlicher logischer Kampagnenbestand

| Element | Historisches Muster | OMW-Bestand | Identifizierte Einheit |
|---|---|---:|---|
| Attack Company | AH-64D | 8 | genaue Company-Bezeichnung noch offen |
| Cavalry Troop | OH-58D | 8 | Troop B, 6th Squadron, 6th Cavalry Regiment „Bounty Hunter“ |
| Assault Company | UH-60L | 7 | genaue Company-/Battalion-Bezeichnung noch offen |
| MEDEVAC Detachment | UH-60 | 3 | Company C, 5th Battalion, 159th Aviation Regiment „Cowboy Dustoff“ |
| Medium Lift Company | CH-47D | 8 | genaue Company-/Battalion-Bezeichnung noch offen |

```text
8 AH-64D
8 OH-58D
7 UH-60L Assault
3 UH-60 MEDEVAC
8 CH-47D
----------------
34 Hubschrauber nach Einzelkomponenten
```

Die ausgewertete Beschreibung des damaligen Task-Force-Kommandeurs nennt dieselben Einzelkomponenten, aber eine Gesamtzahl von **33 Hubschraubern**. Die Komponentensumme ergibt **34**. Dieser Widerspruch bleibt ausdrücklich erhalten:

```yaml
source_reported_total: 33
component_sum_total: 34
discrepancy_status: UNRESOLVED
```

Es wird kein Einzelbestand ohne neue belastbare Evidenz künstlich um eine Maschine reduziert.

## 4. Historische Satellitenevidenz

### 4.1 Aufnahme vom 21. Juni 2011

Projektseitig ausgewertete Google-Earth-/Maxar-Aufnahme:

| Muster / Bereich | Sichtbar |
|---|---:|
| AH-64D Attack-Reihe | 5 |
| OH-58D Cavalry-Reihe | 5 |
| UH-60L Assault-Reihe | 3 |
| gesonderter UH-60-MEDEVAC-Bereich | 3 |
| CH-47D Heavy-Lift-Bereich | 4 |
| **Gesamt** | **20** |

```yaml
satellite_visible_2011_06_21:
  AH-64D: 5
  OH-58D: 5
  UH-60L_ASSAULT: 3
  UH-60_MEDEVAC: 3
  CH-47D: 4
```

„Nicht sichtbar“ bedeutet ausschließlich, dass ein Luftfahrzeug auf dieser Aufnahme nicht identifiziert wurde. Daraus wird keine bestimmte Aussage über Einsatz, Wartung, Hallenunterbringung oder Außenstationierung abgeleitet.

### 4.2 Vergleichsaufnahme vom März 2010

Die Aufnahme liegt vor dem verbindlichen Kampagnenbeginn, ist aber als Rampen- und Kapazitätsnachweis relevant:

```yaml
satellite_visible_2010_03:
  AH-64: 5
  OH-58: 8
  UH-60: 3
  CH-47_REGULAR_PARKING: 4
  CH-47_MAINTENANCE_AREA: 1
```

Sie bestätigt insbesondere acht nutzbare OH-58-Positionen, eine getrennte UH-60-Abstellung, Heavy-Lift-Pads und eine zusätzliche CH-47-Wartungsfläche.

### 4.3 OH-58D-Verlust vom 5. Juni 2011

Für den 5. Juni 2011 ist ein OH-58D-Verlust von Task Force Tigershark dokumentiert. Für den 21. Juni 2011 ist daher ein lokaler Istbestand von sieben OH-58D plausibel, sofern bis dahin kein Ersatz eingetroffen war. Der Ersatzstatus ist unbekannt.

Operation Mountain Watch verwendet dennoch den nominalen Ausgangsbestand von acht OH-58D. Der historische Verlust wird nicht vorab in die Start-ORBAT eingerechnet, sondern kann später durch die permanente Verlustlogik entstehen.

## 5. DCS-Abbildungsregel

| Historisches Muster | Player | KI-Template | Static |
|---|---|---|---|
| AH-64D | AH-64D-Spielermodul | native DCS-AH-64-Variante; Typname zu validieren | native DCS-AH-64-Variante |
| OH-58D | OH-58D-Spielermodul | OH-58D | OH-58D |
| UH-60L Assault | optionaler UH-60L-Mod | UH-60A | UH-60A |
| UH-60 MEDEVAC | keine eigenen modfreien Clients | UH-60A | UH-60A |
| CH-47D | CH-47F-Spielermodul | CH-47D | CH-47D |

Community-Mods bleiben optional und dürfen die modfreie Kernmission nicht unbrauchbar machen. Bewusste Ersatzdarstellungen werden in Namen, Metadaten und Dokumentation getrennt ausgewiesen.

## 6. Player-Gruppen

Projektweit gilt:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Basis
maximal 2 Client-Gruppen je Muster und Basis
1 Luftfahrzeug je Client-Gruppe
```

### 6.1 Modfreie Pflichtgruppen

#### AH-64D

```text
CLIENT_US_SAL_AH64D_01
  CLIENT_US_SAL_AH64D_01_UNIT_01
CLIENT_US_SAL_AH64D_02
  CLIENT_US_SAL_AH64D_02_UNIT_01
```

#### OH-58D

```text
CLIENT_US_SAL_OH58D_01
  CLIENT_US_SAL_OH58D_01_UNIT_01
CLIENT_US_SAL_OH58D_02
  CLIENT_US_SAL_OH58D_02_UNIT_01
```

#### CH-47F

```text
CLIENT_US_SAL_CH47F_01
  CLIENT_US_SAL_CH47F_01_UNIT_01
CLIENT_US_SAL_CH47F_02
  CLIENT_US_SAL_CH47F_02_UNIT_01
```

Modfreie Summe:

```text
6 Client-Gruppen
6 Spielerluftfahrzeuge
```

### 6.2 Optionale UH-60L-Modgruppen

```text
CLIENT_US_SAL_UH60L_01
  CLIENT_US_SAL_UH60L_01_UNIT_01
CLIENT_US_SAL_UH60L_02
  CLIENT_US_SAL_UH60L_02_UNIT_01
```

Für die Kernmission sind nur `0` oder `2` UH-60L-Client-Gruppen zulässig. Es werden nicht zusätzlich getrennte Assault- und MEDEVAC-Clientserien angelegt. Beide Rollen teilen dieselbe Obergrenze von zwei UH-60-Clients am Standort.

## 7. KI-Templates

Alle Templates werden als `Late Activation`, `Uncontrolled = false` und zunächst mit Skill `High` angelegt. Sie sind Authoring-Seeds und kein zusätzlicher logischer Bestand.

### 7.1 AH-64D CAS / Attack

```text
TPL_AIR_US_SAL_AH64D_CAS_2SHIP
  TPL_AIR_US_SAL_AH64D_CAS_2SHIP_UNIT_01
  TPL_AIR_US_SAL_AH64D_CAS_2SHIP_UNIT_02
```

- 1 Gruppe / 2 Flugzeuge;
- DCS-Haupttask: `CAS`;
- vorgesehene OMW-Rollen: CAS, Attack, Escort und bewaffnetes Overwatch;
- kein separates Escort-Template vor MOOSE-First-Nachweis eines technischen Bedarfs.

### 7.2 OH-58D RECON / FAC(A)

```text
TPL_AIR_US_SAL_OH58D_RECON_2SHIP
  TPL_AIR_US_SAL_OH58D_RECON_2SHIP_UNIT_01
  TPL_AIR_US_SAL_OH58D_RECON_2SHIP_UNIT_02
```

- 1 Gruppe / 2 Flugzeuge;
- DCS-Haupttask: `AFAC`;
- vorgesehene OMW-Rollen: RECON, FAC(A), Armed Reconnaissance und Escort;
- kein separates Escort-Template vor MOOSE-First-Nachweis eines technischen Bedarfs.

### 7.3 UH-60 Assault

```text
TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP
  TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP_UNIT_01
  TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP_UNIT_02
```

- 1 Gruppe / 2 Flugzeuge;
- DCS-Typ: `UH-60A`;
- DCS-Haupttask: `Transport`;
- vorgesehene OMW-Rollen: Air Assault, Utility und taktischer Transport.

### 7.4 UH-60 MEDEVAC

```text
TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP
  TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP_UNIT_01
```

- 1 Gruppe / 1 Flugzeug;
- DCS-Typ: `UH-60A`;
- DCS-Haupttask: `Transport`;
- der spätere MEDEVAC-Koordinator reserviert zwei Single-Ship-Assets als Lead und Cover;
- getrennte Lead-/Cover-Templates werden nur bei nachgewiesenem technischen Unterschied benötigt.

### 7.5 CH-47 Transport

```text
TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP
  TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP_UNIT_01
```

- 1 Gruppe / 1 Flugzeug;
- DCS-Typ: `CH-47D`;
- DCS-Haupttask: `Transport`;
- vorgesehene OMW-Rollen: Truppentransport, Fracht und Slingload;
- kein separates Slingload-Template vor Prüfung von `AUFTRAG`, `OPSTRANSPORT` und MOOSE-Cargofunktionen.

### 7.6 Template-Summe

| Templatebereich | Gruppen | Template-Units |
|---|---:|---:|
| AH-64D | 1 | 2 |
| OH-58D | 1 | 2 |
| UH-60 Assault | 1 | 2 |
| UH-60 MEDEVAC | 1 | 1 |
| CH-47 | 1 | 1 |
| **Gesamt** | **5** | **8** |

## 8. Statische Rampenbaseline

Die historische Juni-2011-Aufnahme mit 20 sichtbaren Maschinen wird als Evidenz bewahrt. Für die erste operative Missionseditorbaseline werden jedoch Client- und KI-Positionen vorrangig freigehalten.

### 8.1 AH-64

```text
STATIC_AIR_US_SAL_AH64_01
STATIC_AIR_US_SAL_AH64_02
STATIC_AIR_US_SAL_AH64_03
```

```text
3 Statics + 2 Clientpositionen + 2 KI-Positionen = 7 reguläre Attack-Positionen
```

### 8.2 OH-58D

```text
STATIC_AIR_US_SAL_OH58D_01
STATIC_AIR_US_SAL_OH58D_02
STATIC_AIR_US_SAL_OH58D_03
STATIC_AIR_US_SAL_OH58D_04
```

```text
4 Statics + 2 Clientpositionen + 2 KI-Positionen = 8 Scout-Positionen
```

### 8.3 UH-60 Assault

```text
STATIC_AIR_US_SAL_UH60_ASSAULT_01
STATIC_AIR_US_SAL_UH60_ASSAULT_02
STATIC_AIR_US_SAL_UH60_ASSAULT_03
```

```text
3 Statics + 2 optionale Clientpositionen + 2 KI-Positionen = 7 Assault-Positionen
```

Ohne UH-60L-Mod bleiben die beiden Clientpositionen als freie Betriebsreserve erhalten.

### 8.4 UH-60 MEDEVAC

```text
STATIC_AIR_US_SAL_UH60_MEDEVAC_01
```

```text
1 Static + 2 MEDEVAC-Ready-/KI-Positionen = 3 gesonderte MEDEVAC-Positionen
```

### 8.5 CH-47

```text
STATIC_AIR_US_SAL_CH47_01
STATIC_AIR_US_SAL_CH47_02
STATIC_AIR_US_SAL_CH47_03
STATIC_AIR_US_SAL_CH47_04
```

Zusätzlich werden zwei Client- und zwei KI-Positionen freigehalten. Weitere Heavy-Lift-Pads dienen Transit, Umstellung, Wartung oder zeitweiligen Detachments.

### 8.6 Static-Summe

| Bereich | Statics |
|---|---:|
| AH-64 | 3 |
| OH-58D | 4 |
| UH-60 Assault | 3 |
| UH-60 MEDEVAC | 1 |
| CH-47 | 4 |
| **Gesamt** | **15** |

Diese 15 Statics sind Teil des logischen Bestands und kein zusätzlicher Bestand.

## 9. Parking- und Flächenpolitik

```yaml
parking_policy:
  ah64_attack_row:
    nominal_capacity: 7
    use: AH-64D
  uh60_assault_row:
    nominal_capacity: 7
    use: UH-60L_ASSAULT
  oh58_row:
    nominal_capacity: 8
    use: OH-58D
  uh60_medevac_section:
    nominal_capacity: 3
    use: UH-60_MEDEVAC
  ch47_heavy_lift_area:
    nominal_capacity: AT_LEAST_8
    use: CH-47D
  aligned_central_gaps:
    classification: RESERVED_NO_PARKING
  probable_hot_refueling_positions:
    classification: TRANSIENT_ONLY
  ch47_maintenance_area:
    classification: MAINTENANCE_TRANSIENT
  unidentified_western_area:
    classification: UNCLASSIFIED_NO_PERMANENT_ASSIGNMENT
```

Verbindliche Platzierungsreihenfolge:

1. Clientpositionen reservieren;
2. dynamische KI-Start-, Ready- und Recovery-Positionen freihalten;
3. zentrale Sicherheits-/Zufahrtslücken nicht belegen;
4. Statics auf verbleibenden historischen Rampständen verteilen;
5. Hot-Refueling-Flächen nicht als Dauerparkplätze verwenden;
6. unbekannte Flächen bis zur Funktionsklärung nicht fest zuweisen;
7. belegte Parking-Nodes per DCS-/MOOSE-Diagnose erfassen und für dynamische KI sperren.

## 10. MOOSE-Struktur

```text
AW_US_SALERNO
├── SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK
├── SQ_US_SAL_OH58D_B_6_6_CAV
├── SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT
├── SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN
└── SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT

WH_AIR_US_SALERNO
```

Vorgesehene spätere SQUADRON-Abbildung:

| SQUADRON | Logischer Bestand | Templategröße | geplante MOOSE-Assetgruppen |
|---|---:|---:|---:|
| AH-64D Attack | 8 | 2 | 4 |
| OH-58D Cavalry | 8 | 2 | 4 |
| UH-60 Assault | 7 | 2 | 3 Gruppen für 6 plus 1 getrennte logische Reserve |
| UH-60 MEDEVAC | 3 | 1 | 3 |
| CH-47 Medium Lift | 8 | 1 | 8 |

`SQUADRON:New(..., Ngroups, ...)` zählt Gruppen und nicht einzelne Flugzeuge. Die ungerade Assault-Stärke darf daher nicht versehentlich als acht physische Luftfahrzeuge registriert werden.

## 11. Missionseditor-Gesamtumfang

### Modfreie Basismission

```text
6 Client-Gruppen / 6 Client-Units
5 KI-Templategruppen / 8 Template-Units
15 Static-Objekte
-----------------------------------
29 Luftfahrzeugobjekte im Missionseditor
```

### Mit optionalem UH-60L-Mod

```text
8 Client-Gruppen / 8 Client-Units
5 KI-Templategruppen / 8 Template-Units
15 Static-Objekte
-----------------------------------
31 Luftfahrzeugobjekte im Missionseditor
```

## 12. Nicht anzulegen

```text
keine zusätzlichen AH-64-Escort-Templates ohne technischen Nachweis
keine zusätzlichen OH-58-Escort-Templates ohne technischen Nachweis
kein separates CH-47-Slingload-Template ohne MOOSE-First-Nachweis
keine vier getrennten UH-60-Clientgruppen für Assault und MEDEVAC
keine 20 permanenten Statics bei gleichzeitig reservierten Client-/KI-Pads
keine Statics in den zentralen Sicherheits-/Zufahrtslücken
keine Dauerabstellung auf den wahrscheinlichen Hot-Refueling-Flächen
kein zweiter Khost-AIRWING ohne separate dauerhafte Einheitenentscheidung
```

## 13. Offene technische Arbeit und Acceptance

Vor produktiver Aktivierung sind mindestens erforderlich:

- tatsächlichen DCS-Airbase-Namen und Airbase-ID von Khost bestätigen;
- DCS-Typnamen aller Client-, KI- und Static-Varianten inventarisieren;
- Warehouse-Anker im Missionseditor setzen und mit MOOSE erkennen;
- Parking-/Helipad-IDs und geometrische Eignung protokollieren;
- alle fünf Templates auf `Late Activation` prüfen;
- Safe Parking und Blacklists validieren;
- Rotor-, Kollisions-, Start- und Rückkehrabstände testen;
- `SetOptionPreferVertical()` für alle gebundenen Hubschraubergruppen versionsbezogen prüfen;
- MOOSE-First-Prüfung für CAS, RECON/FAC(A), Escort, MEDEVAC, Transport, Cargo und Slingload durchführen;
- Client-, Static-, KI- und logische Bestände gegen Doppelzählung prüfen;
- reproduzierbaren DCS-Test mit Branch-, Commit-, Mission-, Bundle-, DCS- und MOOSE-Nachweis erstellen.

Dieses Dokument ist eine verbindliche fachliche und Missionseditor-Baseline, aber noch keine DCS-Laufzeit-Acceptance.