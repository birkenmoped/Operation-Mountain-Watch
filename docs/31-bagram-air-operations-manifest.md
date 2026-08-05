---
document_id: OMW-AIR-BAGRAM-MANIFEST
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram historical fighter evidence
  - Bagram active fighter ORBAT
not_authoritative_for:
  - current Mission Editor state
  - player slot policy
  - templates, statics, parking or Warehouse configuration
  - payload baselines
  - DCS or MOOSE runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/28-bagram-air-operations-manifest.md
superseded_by:
source_branch: agent/reconcile-main-documentation-phase1
source_commit: PENDING_MERGE
validated_in_dcs: false
document_class: HISTORICAL_EVIDENCE_AND_ACTIVE_ORBAT
---

# 31 – Bagram Air Operations Manifest

## 1. Dokumentstatus

Dieses Dokument ist ausschließlich verbindlich für die historische Bagram-Fighter-Evidenz und die daraus abgeleitete aktive Fighter-ORBAT. Es enthält keine aktuelle Missionseditor-, Client-, Template-, Static-, Parking-, Warehouse- oder Payload-Baseline.

Projektweite aktive ORBAT- und Clientobergrenzen stehen in [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md). Konkrete technische Umsetzungen benötigen eine eigene, auf `main` vorhandene und im zentralen Dokumentregister geführte Baseline.

## 2. Historische Evidenz Ende 2011

Eine projektseitig ausgewertete Maxar-/Google-Earth-Aufnahme mit Datumsangabe `12/2011` zeigt auf dem östlichen Fighter Apron mindestens:

```text
13 F-15E Strike Eagle
11 F-16 Fighting Falcon
```

Die Aufnahme belegt Mindestpräsenz und Rampbelegung, nicht automatisch den vollständigen administrativen Gesamtbestand. Nicht sichtbar können Flugzeuge im Einsatz, in Wartung, in Hallen, auf anderen Flächen oder temporär verlegt gewesen sein.

### 2.1 F-16-Einheit

```text
121st Expeditionary Fighter Squadron
Lead-Verband: 113th Wing, District of Columbia ANG
historisches Muster: F-16C Block 30
Einsatzzeitraum: 13.10.2011 bis 14.04.2012
```

Das ANG-`Rainbow Deployment` umfasste Flugzeuge und Personal mindestens aus:

- 119th Fighter Squadron – New Jersey ANG;
- 121st Fighter Squadron – District of Columbia ANG;
- 124th Fighter Squadron – Iowa ANG.

Mindestens 13 F-16C Block 30 sind durch Seriennummern beziehungsweise Fotobelege dokumentiert; elf sind auf der Satellitenaufnahme sichtbar.

### 2.2 F-15E-Einheit

```text
335th Expeditionary Fighter Squadron
Muster: F-15E Strike Eagle
Standort: Bagram Airfield
```

Offizielle USAF-/AFCENT-Belege nennen die 335th EFS im November 2011 in Bagram. Sie operierte gemeinsam mit der 121st EFS. Die frühere aktive Zuordnung zur 336th EFS ist für die OMW-Baseline ersetzt; 336th und 494th EFS bleiben historischer Rotationskontext.

### 2.3 Quellenbasis

- U.S. Air Forces Central, `Coalition Forces 70, Taliban 0`, 14.11.2011;
- U.S. Air Force, `Close air support protects coalition forces, kills 70 insurgents`, 14.11.2011;
- 113th Wing, `113th Wing initiates first ANG F-16 deployment to Afghanistan`, 11.10.2011;
- F-16.net, `Bagram AB Deployment 2011-12`;
- projektseitig ausgewertete Maxar-/Google-Earth-Satellitenaufnahme `12/2011`.

## 3. Verbindliche aktive Fighter-ORBAT

```text
AW_US_BAGRAM
├── SQ_US_BGRM_F15E_335_EFS
│   13 F-15E
└── SQ_US_BGRM_F16C_121_EFS
    13 historische F-16C Block 30
    DCS-Abbildung: F-16C Block 50
```

| Squadron | Historischer Nachweis | OMW-Bestand | Bewertung |
|---|---:|---:|---|
| 335th EFS / F-15E | mindestens 13 sichtbar | 13 | konservativer lokaler Bestand |
| 121st EFS / F-16C Block 30 | 13 Seriennummern, 11 sichtbar | 13 | historisch ausreichend belegt |

Die Werte behaupten keine vollständige USAF-TOE. Sie definieren einen konservativen, quellenbasierten Kampagnenbestand.

## 4. DCS-Abbildung der aktiven Fighter-ORBAT

### F-15E

```text
DCS-Spielertyp: F-15E Strike Eagle
Status: THIRD_PARTY_AT_RISK
```

Clientobjekte, Templates und Payloadregistrierungen müssen deaktivierbar bleiben, ohne den AIRWING strukturell neu aufzubauen.

### F-16C

```text
historisches Muster: F-16C Block 30
native DCS-Spielerabbildung: F-16C Block 50
```

Der Block 50 ist ein ausdrücklich gekennzeichneter technischer Ersatz für das historisch belegte Block-30-Muster. Diese Festlegung bestimmt nur die Musterabbildung innerhalb der aktiven Fighter-ORBAT; sie legt keine konkrete Client-, Template- oder Payload-Konfiguration fest.

## 5. Autoritätsgrenze

Verbindlich aus diesem Dokument sind ausschließlich:

- die in Abschnitt 2 dokumentierte historische Evidenz;
- die aktive Fighter-ORBAT aus Abschnitt 3;
- die DCS-Musterabbildung aus Abschnitt 4.

Nicht aus diesem Dokument abzuleiten sind:

- Anzahl, Namen oder Positionen von Client- und KI-Gruppen;
- Missionseditor-Objektbestand und Statics;
- ParkingIDs, White-/Blacklists oder Clientausschlüsse;
- AIRWING-, SQUADRON- oder Warehouse-Konfiguration;
- Payloads und Außenlasten;
- DCS-/MOOSE-Laufzeitverhalten oder technische Acceptance.

Ältere Branchdokumente und nicht auf `main` vorhandene Dateien besitzen für diese Umsetzungsfragen keine Autorität.
