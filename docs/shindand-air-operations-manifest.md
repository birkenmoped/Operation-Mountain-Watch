---
document_id: OMW-AIR-SHINDAND-MANIFEST
status: BINDING_PROJECT_DECISION
document_class: MISSION_EDITOR_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - Shindand active local air ORBAT
  - Shindand Mission Editor clients templates statics warehouse and initial parking policy
  - Shindand DCS replacement-model decisions
not_authoritative_for:
  - project-wide client limits
  - branch-independent DCS or MOOSE runtime acceptance
  - exact historical readiness on a single satellite date
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - provisional Shindand research ranges
  - provisional Shindand working estimate of 10 AH-64D 6 CH-47 and 6 UH-60
superseded_by:
source_branch: agent/document-shindand-air-operations
source_commit: PENDING_MERGE
validated_in_dcs: false
source_status: SOURCE_AND_PROJECT_DECISION_CAPTURED
validation_status: MISSION_EDITOR_STRUCTURE_ACCEPTED_RUNTIME_PENDING
source_mission: OMW_Template(2).miz
source_mission_sha256: 645f09b21793324a1df4d442fbaeffc0d1a2ee7c97f6453a4c3a97dde82c6e00
source_mission_inner_sha256: 991ca54f076478b47bec2cc7899eb011733e12a1a665af0c4933a982f2a906db
source_runtime_script_sha256: 294e0d69ecb1d647bc67e20083da34a1a121c048fc0e11f8d57405c86b5d584f
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# Shindand Air Operations Manifest

## 1. Zweck und Autorität

Dieses Manifest legt den aktiven US-Army-Aviation-Knoten **Shindand Air Base** für Operation Mountain Watch fest. Es ergänzt [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md) und setzt die gemeinsamen Regeln aus folgenden Dokumenten um:

- [`OMW-GOV-001`](00-project-governance.md);
- [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md);
- [`OMW-AIR-ME-WORKLIST`](20-air-orbat-mission-editor-worklist.md);
- [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md);
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md).

Die Zahlen dieses Dokuments sind verbindliche OMW-Bestands- und Missionseditorentscheidungen. Sie sind keine Behauptung, dass alle ausgewählten Luftfahrzeuge an einem einzelnen historischen Stichtag gleichzeitig sichtbar oder einsatzbereit waren.

## 2. Standort- und Organisationsmodell

```text
Luftoperationsknoten: Shindand Air Base
DCS-Airbase-ID:       14, Runtime-Bestätigung erforderlich
AIRWING:              AW_US_SHINDAND
Warehouse-Anker:      WH_AIR_US_SHINDAND
Kurzcode:              SHND
```

Shindand wird als gemischter Standort behandelt:

- afghanischer Air-Advisor- und Ausbildungsbetrieb;
- Koalitions-, Camp- und regionaler Unterstützungsstandort;
- OMW-seitig ausgewählter US-Army-Aviation-Knoten;
- keine Ableitung zusätzlicher Bestände allein aus 2013er Satellitenbildern.

Für die aktive technische Umsetzung wird keine nicht belegte Company- oder Battalion-Bezeichnung erfunden. Die lokale Struktur bleibt typrein und funktionsbezogen.

## 3. Verbindlicher logischer Kampagnenbestand

| Element | historisches/logisches Muster | OMW-Bestand | lokale technische Rolle |
|---|---|---:|---|
| Attack | AH-64D | 8 | CAS, Attack, Escort, Armed Overwatch |
| Utility und MEDEVAC | UH-60-Familie | 8 | Utility, Air Assault, MEDEVAC Lead/Cover |
| Heavy Lift | CH-47D/F-Familie | 4 | Heavy Lift, Truppen- und Frachttransport |

```text
8 AH-64D
8 UH-60 einschließlich MEDEVAC
4 CH-47
----------------
20 Hubschrauber
```

Der UH-60-MEDEVAC-Anteil ist Bestandteil des gemeinsamen Bestands von acht UH-60. Er erzeugt keinen zusätzlichen Bestand.

## 4. Bestands- und Darstellungsregel

Folgende Ebenen sind strikt getrennt zu führen:

```text
logischer Kampagnenbestand
mission-ready Bestand
Client-Reservierungen
aktive KI-Luftfahrzeuge
sichtbare Statics
virtuelle Reserve
beschädigte Luftfahrzeuge
endgültige Verluste
```

Client-Slots, KI-Templates, aktive KI-Gruppen und Statics dürfen den Bestand nicht mehrfach erhöhen.

Initiale Authoring-Aufteilung der geprüften Mission:

| Muster | Gesamt | Client-Slots | sichtbare Statics | zunächst verbleibend für KI/virtuelle Reserve |
|---|---:|---:|---:|---:|
| AH-64D | 8 | 2 | 4 | 2 |
| UH-60 | 8 | 0 | 4 | 4 |
| CH-47 | 4 | 2 | 1 | 1 |

Diese Tabelle ist die konservative Baseline, solange keine dynamische Static-/Rampenumverteilung implementiert und getestet ist.

## 5. DCS-Abbildungsregel

| logisches Muster | Spieler | KI-Template | Static | Begründung |
|---|---|---|---|---|
| AH-64D | `AH-64D_BLK_II` | `AH-64A` | `AH-64A` | einfaches Vanilla-AI-Modell ohne Longbow-Radar; projektweit bereits verwendetes Ersatzverfahren |
| UH-60-Familie | keine modfreien Clients | `UH-60A` | `UH-60A` | native generische Utility-/MEDEVAC-Abbildung |
| CH-47D/F-Familie | `CH-47Fbl1` | `CH-47D` | `CH-47D` | Spielerabbildung über CH-47F; KI/Static historisch und technisch einfacher über CH-47D |

Die AH-64A-KI- und Static-Objekte bleiben Bestandteil des logischen AH-64D-Bestands. Sie erzeugen keinen separaten AH-64A-Bestand.

### 5.1 Liveries der geprüften Mission

| Bereich | DCS-Typ | Livery | Status |
|---|---|---|---|
| AH-64D Clients | `AH-64D_BLK_II` | `default` | akzeptiert |
| AH-64 KI | `AH-64A` | `standard dirty` | akzeptiert |
| AH-64 Statics | `AH-64A` | `standard` | akzeptiert |
| UH-60 KI/Statics | `UH-60A` | `standard` | akzeptiert |
| CH-47F Clients | `CH-47Fbl1` | `us army dark green` | akzeptiert |
| CH-47 KI/Static | `CH-47D` | `standard` | akzeptiert |

## 6. Spielergruppen

Projektweit gilt:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Basis
maximal 2 Client-Gruppen je Muster und Basis
1 Luftfahrzeug je Client-Gruppe
```

### 6.1 AH-64D

```text
CLIENT_US_SHND_AH64D_01
  CLIENT_US_SHND_AH64D_01_UNIT_01
CLIENT_US_SHND_AH64D_02
  CLIENT_US_SHND_AH64D_02_UNIT_01
```

### 6.2 CH-47F

```text
CLIENT_US_SHND_CH47F_01
  CLIENT_US_SHND_CH47F_01_UNIT_01
CLIENT_US_SHND_CH47F_02
  CLIENT_US_SHND_CH47F_02_UNIT_01
```

### 6.3 UH-60

Die modfreie Kernmission erhält keine UH-60-Clientgruppen. Eine spätere optionale UH-60L-Modintegration benötigt eine eigene Modul-, Bestands- und Multiplayer-Freigabe und darf die projektweite Obergrenze von zwei UH-60-Clients am Standort nicht überschreiten.

### 6.4 Client-Summe

```text
4 Client-Gruppen
4 Client-Units
```

Alle vier Gruppen sind als Cold-Start-Clients mit genau einem Luftfahrzeug angelegt.

## 7. KI-Templates

Alle Templates der geprüften Mission besitzen:

```text
Late Activation = true
Uncontrolled = false
Skill = High
```

Sie sind Authoring-Seeds und kein zusätzlicher Kampagnenbestand.

### 7.1 AH-64D CAS / Attack

```text
TPL_AIR_US_SHND_AH64D_CAS_2SHIP
  TPL_AIR_US_SHND_AH64D_CAS_2SHIP_UNIT_01
  TPL_AIR_US_SHND_AH64D_CAS_2SHIP_UNIT_02
```

- 1 Gruppe / 2 Units;
- tatsächlicher DCS-Typ: `AH-64A`;
- logische Rolle: AH-64D Attack;
- vorgesehene OMW-Rollen: CAS, Attack, Escort und Armed Overwatch;
- kein separates Escort-Template ohne MOOSE-first-Nachweis.

### 7.2 UH-60 Utility

```text
TPL_AIR_US_SHND_UH60_UTILITY_1SHIP
  TPL_AIR_US_SHND_UH60_UTILITY_1SHIP_UNIT_01
```

- 1 Gruppe / 1 Unit;
- DCS-Typ: `UH-60A`;
- Rollen: Utility, Air Assault, Truppen- und interner Frachttransport.

### 7.3 UH-60 MEDEVAC Lead

```text
TPL_AIR_US_SHND_UH60_MEDEVAC_LEAD_1SHIP
  TPL_AIR_US_SHND_UH60_MEDEVAC_LEAD_1SHIP_UNIT_01
```

- 1 Gruppe / 1 Unit;
- DCS-Typ: `UH-60A`;
- Funktion: Landung, Aufnahme und Rücktransport.

### 7.4 UH-60 MEDEVAC Cover

```text
TPL_AIR_US_SHND_UH60_MEDEVAC_COVER_1SHIP
  TPL_AIR_US_SHND_UH60_MEDEVAC_COVER_1SHIP_UNIT_01
```

- 1 Gruppe / 1 Unit;
- DCS-Typ: `UH-60A`;
- Funktion: Sicherung, Orbit und Begleitung.

Lead und Cover bilden ein gemeinsames MEDEVAC-Zweierpaket. Beide greifen auf denselben UH-60-Gesamtbestand zu.

### 7.5 CH-47 Heavy Lift

```text
TPL_AIR_US_SHND_CH47_HEAVYLIFT_1SHIP
  TPL_AIR_US_SHND_CH47_HEAVYLIFT_1SHIP_UNIT_01
```

- 1 Gruppe / 1 Unit;
- DCS-Typ: `CH-47D`;
- Rollen: Heavy Lift, Truppen-, Fracht- und später gegebenenfalls Slingload-Transport;
- kein separates Slingload-Template vor Prüfung von `AUFTRAG`, `OPSTRANSPORT` und MOOSE-Cargofunktionen.

### 7.6 Template-Summe

| Templatebereich | Gruppen | Template-Units |
|---|---:|---:|
| AH-64 CAS 2SHIP | 1 | 2 |
| UH-60 Utility 1SHIP | 1 | 1 |
| UH-60 MEDEVAC Lead 1SHIP | 1 | 1 |
| UH-60 MEDEVAC Cover 1SHIP | 1 | 1 |
| CH-47 Heavy Lift 1SHIP | 1 | 1 |
| **Gesamt** | **5** | **6** |

## 8. Statische Luftfahrzeuge

### 8.1 AH-64

```text
STATIC_AIR_US_SHND_AH64_01
STATIC_AIR_US_SHND_AH64_02
STATIC_AIR_US_SHND_AH64_03
STATIC_AIR_US_SHND_AH64_04
```

```text
DCS-Typ: AH-64A
Livery: standard
Anzahl: 4
```

### 8.2 UH-60

```text
STATIC_AIR_US_SHND_UH60_01
STATIC_AIR_US_SHND_UH60_02
STATIC_AIR_US_SHND_UH60_03
STATIC_AIR_US_SHND_UH60_04
```

```text
DCS-Typ: UH-60A
Livery: standard
Anzahl: 4
```

Die Statics werden nicht in Utility- und MEDEVAC-Bestände getrennt. Eine MEDEVAC-Livery darf nur als visuelle Rollenkennzeichnung verwendet werden und ändert den gemeinsamen Bestand nicht.

### 8.3 CH-47

```text
STATIC_AIR_US_SHND_CH47_01
```

```text
DCS-Typ: CH-47D
Livery: standard
Anzahl: 1
```

### 8.4 Static-Summe

```text
4 AH-64
4 UH-60
1 CH-47
---------
9 Statics
```

Statics sind sichtbare Repräsentationen des inaktiven Bestands. Sie dürfen keine Client-, KI-, Recovery-, Ready-, Hot-Refueling- oder Sicherheitsflächen blockieren.

## 9. Warehouse-Anker

```text
WH_AIR_US_SHINDAND
```

Strukturell beobachtet:

```yaml
object_name: WH_AIR_US_SHINDAND
observed_dcs_object_type: container_40ft
observed_category: Fortifications
coordinate_x: -63332.072378192
coordinate_y: -368169.94400035
purpose: MOOSE AIRWING and Warehouse anchor
```

Der Anker ist ein technisches Missionsobjekt und kein zusätzlicher Luftfahrzeugbestand. Die tatsächliche MOOSE-Auflösung ist noch nicht zur Laufzeit bestätigt.

Das native DCS-Warehouse der Airbase-ID 14 ist in der geprüften Mission nicht als Kampagnenbestand konfiguriert. Die verbindliche Luftfahrzeugbuchführung bleibt Aufgabe von CampaignState, AIRWING und SQUADRON.

## 10. Client-Parking

Die geprüften Clientgruppen verwenden folgende technischen DCS-Parkingwerte:

| Clientgruppe | DCS-Typ | technischer `parking`-Wert | sichtbare ME-Parkingbezeichnung |
|---|---|---:|---:|
| `CLIENT_US_SHND_AH64D_01` | `AH-64D_BLK_II` | 6 | 09 |
| `CLIENT_US_SHND_AH64D_02` | `AH-64D_BLK_II` | 8 | 06 |
| `CLIENT_US_SHND_CH47F_01` | `CH-47Fbl1` | 12 | 40 |
| `CLIENT_US_SHND_CH47F_02` | `CH-47Fbl1` | 28 | 38 |

Vorläufige Client-Blacklist für dynamische KI:

```lua
shindandClientParkingBlacklist = {
  6,
  8,
  12,
  28,
}
```

Die sichtbare Missionseditorbezeichnung darf nicht mit der technischen TerminalID verwechselt werden. Eine vollständige AI-Allowlist und Blacklist benötigt einen Shindand-spezifischen Parking-Diagnoselauf.

## 11. Payload-, Funk- und Callsign-Status

Die Strukturprüfung bestätigt Gruppen, Typen, Liveries, Parking und Templateeigenschaften. Sie ist keine abschließende Payload-, Funk- oder Callsign-Abnahme.

Offen bleiben insbesondere:

- AH-64D-Client-Payload und Munitionsstandard;
- CH-47F-Türbewaffnung;
- MOOSE-Payloadregistrierungen für die KI-SQUADRONs;
- taktische Callsigns;
- Frequenzen und Presets nach dem OMW-TAD-/Color-Net-Modell.

Diese Punkte dürfen den Bestand und die hier festgelegten Objektidentitäten nicht verändern.

## 12. Struktureller Missionsnachweis

Geprüfte Missionsdatei:

```text
OMW_Template(2).miz
SHA-256: 645f09b21793324a1df4d442fbaeffc0d1a2ee7c97f6453a4c3a97dde82c6e00
```

Bestätigter Shindand-Stand:

```text
4 Client-Gruppen / 4 Client-Units
5 KI-Templategruppen / 6 Template-Units
9 Luftfahrzeug-Statics
1 Warehouse-Anker
alle fünf KI-Templates Late Activation
alle fünf KI-Templates Uncontrolled = false
0 Shindand-spezifische Funktionszonen
```

```yaml
structural_validation_status: PASS
runtime_validation_status: NOT_RUN
validated_in_dcs: false
```

Die Prüfung beweist den Missionseditor-Aufbau. Sie beweist noch keine AIRWING-, SQUADRON-, AUFTRAG-, Safe-Parking-, Warehouse- oder Verlustlogik zur Laufzeit.

## 13. Abnahmegrenze

Fachlich abgenommen sind:

- lokaler Gesamtbestand `8/8/4`;
- vier modfreie Clientgruppen;
- fünf KI-Templates;
- neun Statics;
- AH-64A als bewusstes KI-/Static-Ersatzmodell ohne Longbow-Radar;
- UH-60-MEDEVAC als Teil des gemeinsamen UH-60-Bestands;
- CH-47F für Spieler und CH-47D für KI/Statics;
- Warehouse-Ankername;
- die vier bestätigten Client-Parkingwerte.

Noch nicht abgenommen sind:

- DCS-/MOOSE-Laufzeitverhalten;
- finale Parking-Allowlist/Blacklist;
- Payloadregistrierungen;
- AUFTRAG- und OPSTRANSPORT-Ausführung;
- Verlust-, Rückgabe- und Persistenzlogik;
- dynamische Static-/Rampenumverteilung;
- Shindand-spezifische Funktionszonen.
