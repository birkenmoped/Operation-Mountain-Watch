---
document_id: OMW-AIR-PLAYER-SLOT-POLICY
status: BINDING_PROJECT_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - project-wide client aircraft limit
  - one-aircraft client group rule
  - Bagram fighter template exclusions
  - Bagram zone exclusions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/29-player-aircraft-slot-policy.md
  - client limits above two aircraft per type and base
source_branch: docs/bagram-air-operations-manifest
validated_in_dcs: false
---

# 32 – Verbindliche Spielerluftfahrzeug-Obergrenze

## 1. Status und Geltungsbereich

Diese Regel gilt für alle Flugplätze, FARPs und Luftfahrzeugtypen in **Operation Mountain Watch**.

```text
maximale Spielerluftfahrzeuge je Muster und Basis: 2
maximale Clientgruppen je Muster und Basis: 2
Luftfahrzeuge je Clientgruppe: 1
```

Multicrew-Sitze zählen nicht als zusätzliche Luftfahrzeuge.

Die Regel ersetzt ältere allgemeine Planungswerte von vier, vier bis acht oder mehr Spielerluftfahrzeugen je Muster und Basis.

## 2. Abgrenzung

Die Obergrenze betrifft ausschließlich im Missionseditor gesetzte Spieler-/Client-Luftfahrzeuge. Sie verändert nicht automatisch:

- historischen oder strategischen ORBAT-Bestand;
- SQUADRON-Asset-Gruppen;
- maximal aktive KI-Luftfahrzeuge;
- sichtbare Statics;
- virtuelle Reserve;
- Mission-ready Bestand.

Clientgruppen dürfen nicht zugleich als KI-Templates verwendet werden.

## 3. Bagram-Fighter-Anwendung

```text
CLIENT_US_BGRM_F15E_01
CLIENT_US_BGRM_F15E_02
CLIENT_US_BGRM_F16C_01
CLIENT_US_BGRM_F16C_02
```

Nicht anzulegen:

```text
CLIENT_US_BGRM_F15E_03
CLIENT_US_BGRM_F15E_04
CLIENT_US_BGRM_F16C_03
CLIENT_US_BGRM_F16C_04
```

Für Spieler werden zwei kollisionsfreie F-15E- und zwei kollisionsfreie F-16C-Parking-Nodes reserviert. Diese Positionen dürfen weder Statics noch dynamische KI verwenden.

## 4. Verbindliche Bagram-Fighter-Templates

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Nicht anzulegen:

```text
TPL_AIR_US_BGRM_F16C_ARMED_RECON_2SHIP
```

Eine zusätzliche F-16-Rolle kann später über Payloads und AUFTRAG-Zuweisungen auf Grundlage eines vorhandenen Templates geprüft werden. Eine weitere Missionseditorgruppe wird nicht allein für eine mögliche Rolle erzeugt.

## 5. Keine künstlichen Bagram-Funktionszonen

Nicht anzulegen, solange keine konkrete Runtime-Funktion sie benötigt:

```text
ZONE_AIR_US_BGRM_STATIC_F15E
ZONE_AIR_US_BGRM_STATIC_F16C
ZONE_AIR_US_BGRM_F15E_AI_RESERVE
ZONE_AIR_US_BGRM_F16C_AI_RESERVE
ZONE_AIR_US_BGRM_FIGHTER_LOAD
ZONE_AIR_US_BGRM_FIGHTER_RECOVERY
```

Grundsätze:

- Statics werden aus der `.miz` ausgewertet;
- KI-Parking wird über TerminalIDs, Safe Parking und erforderliche Blacklists verwaltet;
- Load-, Recovery-, Staging- und Operationszonen entstehen erst für eine konkrete MOOSE-, AUFTRAG-, OPSTRANSPORT-, CSAR- oder Logistikfunktion.

## 6. Korrigierte Bagram-Fighter-Grundstruktur

```text
4 Fighter-Clientgruppen insgesamt
  2 F-15E
  2 F-16C

3 Fighter-KI-Templates
  2 F-15E-Two-Ship
  1 F-16C-Two-Ship

6 Fighter-Templateflugzeuge
  4 F-15E
  2 F-16C

0 pauschal erforderliche Fighter-Funktionszonen
1 AIRWING
2 Fighter-SQUADRONs
```

Dieses Dokument legt bewusst **keine aktuelle Static-Gesamtzahl** fest. Der tatsächliche Missionseditorstand einschließlich Fighter-, Transport-, Tanker- und Rotary-Wing-Statics wird ausschließlich in `OMW-AIR-BAGRAM-ME-BASELINE` geführt.

Frühere Planwerte von neun F-15E-Statics und sieben F-16C-Statics sind keine aktuelle Arbeitsanweisung.

## 7. Arbeitsanweisung

1. Je zwei Clientpositionen pro Muster setzen.
2. Jede Clientgruppe mit genau einer Unit anlegen.
3. Clientpositionen dauerhaft von Statics und KI freihalten.
4. Zwei F-15E-Two-Ship-Templates für CAS und STRIKE anlegen.
5. Ein F-16C-Two-Ship-Template für CAS anlegen.
6. Kein separates F-16C-Armed-Recon-Template anlegen.
7. Keine rein optischen oder pauschalen Funktionszonen anlegen.
8. Dynamische KI-Reservepositionen anhand der Parking-Geometrie bestimmen.
9. TerminalIDs durch Laufzeitdiagnose dokumentieren.
10. Blacklists nur aus bewusst belegten Nodes ableiten.
11. Die `.miz` direkt auf Clients, Templates, Statics, Warehouse und Parking prüfen.

## 8. Autoritätsregel

Dieses Dokument ist autoritativ für:

- projektweite Clientanzahl;
- Bagram-Fighter-Clientgruppen;
- F-16-Templateausschluss;
- Verzicht auf künstliche Bagram-Funktionszonen.

`OMW-AIR-BAGRAM-ME-BASELINE` ist autoritativ für den tatsächlich gesetzten Missionseditorstand und dessen aktuelle Static-, Parking-, Template- und Warehouse-Daten.
