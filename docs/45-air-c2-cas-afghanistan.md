---
document_id: OMW-C2-AIR-C2-CAS-AFGHANISTAN
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-derived Air C2 and CAS mission-design requirements
  - separation of ASOC, TACP, FAC, AFAC, JTAC and aircrew roles
not_authoritative_for:
  - DCS runtime acceptance
  - mission-specific frequencies or current ORBAT
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - SOURCE_CAPTURE_COMPLETE used as document status
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 45 – Air C2 und Close Air Support in Afghanistan

## 1. Einordnung

Dieses Dokument ist die verbindliche quellenbasierte Designreferenz für Air C2 und CAS in **Operation Mountain Watch**. Es trennt Quellenbefund, Projektableitung und spätere technische Umsetzung.

Der vollständige dreiteilige Quellen- und Auswertungstext bleibt unverändert erhalten:

- [`Legacy-Quellenfassung mit vollständiger Serie`](evidence/source-records/legacy-45-air-c2-cas-afghanistan-source-capture.md)

## 2. Quellenstatus

```yaml
source_series: Who's in Charge? Air C2 and Close Air Support in Afghanistan
source_author: Graveyard of Empires
parts_available: 3/3
source_status: SOURCE_CAPTURE_COMPLETE
primary_source_verification: PARTIAL
```

Die Projektnutzung folgt [`OMW-GOV-SOURCE-USE`](sources/graveyard-of-empires.md). Patreon-Darstellung, identifizierte Originalquelle, unabhängige Recherche und OMW-Projektentscheidung bleiben getrennt.

## 3. Verbindliche Missionsdesign-Grundsätze

- CAS ist ein Führungs-, Koordinations- und Identifikationsprozess, nicht nur Waffenwirkung.
- ASOC, TACP, FAC, AFAC, JTAC, Aircrew und Ground Commander besitzen getrennte Rollen.
- Zielinformationen, Friendly Positions, ziviles Umfeld, ROE, verfügbare Waffen und gewünschter Effekt müssen nachvollziehbar übergeben werden.
- Unklare Autorität oder widersprüchliche Zielinformationen blockieren die Angriffserzeugung.
- Spieler- und KI-Aufträge müssen auf demselben `MissionDemand` beziehungsweise Zielobjekt arbeiten.
- Die No-Strike-List und positive Zielbestätigung sind vor jeder Zielnominierung zu prüfen.

## 4. Technische Zielarchitektur

Vorrangig zu prüfen und einzusetzen:

- `COMMANDER` und `AIRWING` für Zuweisung und Ausführung;
- `AUFTRAG` für KI-Missionen;
- `PLAYERTASK` für Spieleraufträge;
- `INTEL`, `DETECTION`, `TARGET`, `PLAYERRECCE` und `DESIGNATE` für Aufklärung und Zielentwicklung;
- projektbezogene Adapter nur nach Dokument 26.

Die vollständige technische MOOSE-Einordnung steht in:

- [`ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur`](moose/ISR-FAC-CAS-AAR.md)

## 5. Noch erforderliche Acceptance

- missionsspezifische C2-Kette und Menüs;
- Spieler-/KI-Übergabe desselben Auftrags;
- Zielaktualisierung und Abbruch;
- Funk- und Frequenzmodell;
- Multiplayer-Synchronisation;
- NSL- und ROE-Blockierung;
- reproduzierbare DCS-Tests für FAC/AFAC/JTAC-Verfahren.
