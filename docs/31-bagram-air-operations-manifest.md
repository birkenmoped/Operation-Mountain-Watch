---
document_id: OMW-AIR-BAGRAM-MANIFEST
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram historical fighter evidence
  - Bagram active fighter ORBAT
  - Bagram implementation intent
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/28-bagram-air-operations-manifest.md
superseded_by_for_current_me_state:
  - OMW-AIR-BAGRAM-ME-BASELINE
source_branch: docs/bagram-air-operations-manifest
validated_in_dcs: false
---

# 31 – Bagram Air Operations Manifest

## 1. Dokumentstatus

Die historische Fighter-ORBAT ist bestätigt. Der konkrete Missionseditorstand wird getrennt in `OMW-AIR-BAGRAM-ME-BASELINE` geführt.

Dieses Dokument enthält keine konkurrierenden älteren Arbeitsanweisungen mehr. Für Clientzahlen, tatsächlich gesetzte Templates, Statics, Parkpositionen und Warehouse-Objekte gelten:

- `OMW-AIR-PLAYER-SLOT-POLICY`;
- `OMW-AIR-BAGRAM-ME-BASELINE`.

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

## 4. DCS-Abbildung

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

Der Block 50 ist ein ausdrücklich gekennzeichneter technischer Ersatz. Die Abweichung bleibt in Mission, Dokumentation und Payload-Auswahl sichtbar.

### 4.1 F-16C-CAS-Payloadgrenze

Die verbindliche Payload-Arbeitsentscheidung ist dokumentiert in:

```text
docs/evidence/bagram-f16c-cas-payload-decision-2026-08-01.md
```

Historisches 2011-Sollbild als projektseitige Arbeitsinterpretation:

```text
2 x GBU-38
2 x GBU-54
2 x Wingtip-AIM-120
Station 2 und 8 clean
keine AIM-9 im Standard-CAS-Loadout
```

Die native DCS-F-16C bildet die GBU-54 nicht ab und erlaubt damit keine exakte Reproduktion des historischen Dual-Mode-Loadouts. Die verbindliche Vanilla-DCS-Funktionsannäherung lautet:

```text
2 x GBU-38 auf BRU-57
2 x GBU-12 auf TER-9A
2 x Wingtip-AIM-120
Station 2 und 8 clean
```

Diese Konfiguration erhält vier 500-lb-Präzisionswaffen sowie GPS- und Laserangriffsmöglichkeiten. Sie ist ausdrücklich kein historisch exaktes Außenlastbild: Nur zwei statt vier Waffen bleiben GPS/INS-fähig, und die GBU-12 besitzt nicht die Dual-Mode-Flexibilität der GBU-54.

## 5. Verbindliche Clientregel

```text
maximal 2 Client-Luftfahrzeuge je Muster und Basis
maximal 2 Clientgruppen je Muster und Basis
1 Luftfahrzeug je Clientgruppe
```

Für den Fighter-Knoten:

```text
CLIENT_US_BGRM_F15E_01
CLIENT_US_BGRM_F15E_02
CLIENT_US_BGRM_F16C_01
CLIENT_US_BGRM_F16C_02
```

Frühere Gruppen `_03` und `_04` werden nicht angelegt.

## 6. KI-Template-Grundsatz

Verbindliche Fighter-Templates:

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Nicht anzulegen:

```text
TPL_AIR_US_BGRM_F16C_ARMED_RECON_2SHIP
```

Weitere F-16-Rollen werden bei Bedarf über geeignete Payloads und AUFTRAG-Zuweisungen geprüft. Ein zusätzliches Missionseditor-Template wird nicht vorsorglich erzeugt.

Alle Templates sind Authoring-Seeds und kein zusätzlicher Kampagnenbestand.

## 7. SQUADRON-Bestandsmodell

Bei 13 Flugzeugen darf MOOSE nicht unbeabsichtigt einen vierzehnten Airframe erzeugen.

Bevorzugte Modellierung:

```text
12 Flugzeuge / 6 Two-Ship-Asset-Gruppen
+ 1 separat geführte logische Reserve
```

Alternativ dürfen 13 Single-Ship-Asset-Gruppen geprüft werden, wenn AUFTRAG die Paketbildung zuverlässig übernimmt. Die konkrete Wahl benötigt einen MOOSE-First-Test.

## 8. Statics und aktueller Missionseditorstand

Frühere Planwerte von neun F-15E- und sieben F-16-Statics sind keine aktuelle Arbeitsanweisung mehr.

Der tatsächlich gesetzte Stand ist in `OMW-AIR-BAGRAM-ME-BASELINE` dokumentiert. Dort gelten derzeit unter anderem:

```text
6 F-15E-Statics
7 F-16-Statics
weitere Transport-, Tanker- und Rotary-Wing-Statics
```

Statics sind sichtbare Repräsentationen des logischen Bestands. Sie werden nicht zusätzlich zum AIRWING-Bestand gezählt.

## 9. Zonen und Parking

Nicht allein zur optischen Gruppierung oder Zählung anzulegen:

```text
ZONE_AIR_US_BGRM_STATIC_F15E
ZONE_AIR_US_BGRM_STATIC_F16C
ZONE_AIR_US_BGRM_F15E_AI_RESERVE
ZONE_AIR_US_BGRM_F16C_AI_RESERVE
ZONE_AIR_US_BGRM_FIGHTER_LOAD
ZONE_AIR_US_BGRM_FIGHTER_RECOVERY
```

Zonen werden erst erstellt, wenn eine konkrete MOOSE-, AUFTRAG-, OPSTRANSPORT-, CSAR- oder Logistikfunktion sie benötigt.

Parking-Regeln:

- Clientpositionen bleiben dauerhaft frei von Statics und dynamischer KI;
- TerminalIDs werden durch DCS-/MOOSE-Laufzeitdiagnose erfasst;
- absichtlich durch Statics belegte Nodes werden als Blacklist-Kandidaten dokumentiert;
- Safe Parking ist zu aktivieren und zu validieren.

## 10. Warehouse und Architektur

```text
AW_US_BAGRAM
├── SQ_US_BGRM_F15E_335_EFS
└── SQ_US_BGRM_F16C_121_EFS

WH_AIR_US_BAGRAM
```

Transport-, Rescue- und Army-Aviation-Komponenten werden als Erweiterung desselben Bagram-Knotens geführt. Sie dürfen die Fighter-Bestände nicht doppelt zählen.

## 11. Autoritätsregel

- Dieses Dokument: historische Fighter-Evidenz und aktive Fighter-ORBAT.
- `OMW-AIR-PLAYER-SLOT-POLICY`: projektweite Clientobergrenze und Template-/Zonenkorrekturen.
- `OMW-AIR-BAGRAM-ME-BASELINE`: tatsächlich gesetzter Missionseditorstand.
- `OMW-EVIDENCE-BAGRAM-F16C-CAS-PAYLOAD-2026-08-01`: historisches F-16C-CAS-Sollbild, DCS-Grenzen und verbindlicher funktionaler Ersatz.

Bei einem Widerspruch zu älteren Bagram-Planwerten gelten die beiden letztgenannten Baselines für die konkrete Umsetzung.
