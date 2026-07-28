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

Das verbindliche interne Daten-, Request- und Produktmodell für ATO, ACO, SPINS, JTAR/ASR, Ground Alert, AAR und Laserkoordination steht ergänzend in:

- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md).

Dokument 45 bleibt für Rollen, Führungsbeziehungen und quellenbasierte CAS-Grundsätze autoritativ. Dokument 54 definiert deren versionierte Missionsdaten und Lifecycle-Abbildung.

## 2. Quellenstatus

```yaml
source_series: Who's in Charge? Air C2 and Close Air Support in Afghanistan
source_author: Graveyard of Empires
parts_available: 3/3
source_status: SOURCE_CAPTURE_COMPLETE
primary_source_verification: PARTIAL
```

Zusätzliche Quellen in Dokument 54:

- NATO ATP-3.3.2.1 Edition D Version 1, April 2019: offizielle, aber post-periodische Doktrin;
- NATO ASR Template: modernes Formtemplate;
- Combined Ops ATO/ACO/SPINS Quick Guide: nichtamtliche technische Referenz;
- Graveyard-of-Empires-ATO-/JTAR-/ASR-/Laser-Beiträge: Sekundärdarstellungen, synthetische Beispiele oder Hypothesen.

Die Projektnutzung folgt [`OMW-GOV-SOURCE-USE`](sources/graveyard-of-empires.md). Patreon-Darstellung, identifizierte Originalquelle, unabhängige Recherche und OMW-Projektentscheidung bleiben getrennt.

## 3. Verbindliche Missionsdesign-Grundsätze

- CAS ist ein Führungs-, Koordinations- und Identifikationsprozess, nicht nur Waffenwirkung.
- ASOC, TACP, FAC, AFAC, JTAC, Aircrew und Ground Commander besitzen getrennte Rollen.
- Zielinformationen, Friendly Positions, ziviles Umfeld, ROE, verfügbare Waffen und gewünschter Effekt müssen nachvollziehbar übergeben werden.
- Unklare Autorität oder widersprüchliche Zielinformationen blockieren die Angriffserzeugung.
- Spieler- und KI-Aufträge müssen auf demselben `MissionDemand` beziehungsweise Zielobjekt arbeiten.
- Die No-Strike-List und positive Zielbestätigung sind vor jeder Zielnominierung zu prüfen.
- Ein ATO-/Tasking-Eintrag ersetzt weder Terminal Attack Control noch Waffenfreigabe.
- Preplanned, Immediate und Emergency Requests bleiben getrennte Bedarfstypen.
- Jeder Air Support Request erhält eine stabile Request-ID und bleibt bis zur zugewiesenen Mission nachvollziehbar.
- Ground Alert und Airborne Alert sind endliche, bestandsgebundene Ressourcen.
- CAS kann auch `SUPPRESS`, `DISRUPT`, `FIX`, `DELAY`, `SHOW_OF_FORCE` oder `OBSERVE` statt ausschließlich `DESTROY` verlangen.
- Abbruchgründe werden getrennt nach Target-ID, Friendly Risk, Civilian Risk, Lost Comms, Weather, Weapon/Sensor und Airspace Conflict protokolliert.

## 4. Request- und Execution-Lifecycle

Das gemeinsame interne Objekt lautet:

```text
AIR_SUPPORT_REQUEST
```

Es kann aus einem US-geprägten JTAR-, einem NATO-ASR- oder einem missionsinternen Bedarf entstehen.

Verbindliche Zustände:

```text
DRAFT
SUBMITTED
VALIDATED
PRIORITIZED
APPROVED
TASKED
ON_CALL
DIVERTED
EXECUTING
COMPLETE
DENIED
CANCELLED
ABORTED
```

CAS-Execution wird mindestens in folgenden Phasen abgebildet:

```text
CHECK_IN
SITUATION_UPDATE
GAME_PLAN
CAS_BRIEF
READBACK
CORRELATION
ATTACK_CLEARANCE
ATTACK
ASSESSMENT
CHECK_OUT
```

Die vollständigen Datenfelder und Übergänge stehen in Dokument 54.

## 5. Laser- und Buddy-Lasing-Grenze

Moderne Begriffe wie `TEN SECONDS`, `CAPTURED`, `LASER ON`, `LASING`, `CEASE LASER`, `SHIFT`, `SPOT`, `NEGATIVE LASER`, `DEAD EYE` und `ABORT` können als konfigurierbares DCS-Trainingsprofil genutzt werden.

Dabei gilt:

- moderne 2019–2025-Referenzen werden nicht als exakte 2010/2011-Phraseologie ausgegeben;
- Code, Ziel und Designator müssen vor dem Angriff korreliert sein;
- `CAPTURED` ersetzt keine Angriffserlaubnis;
- `NEGATIVE LASER`, `DEAD EYE` und `ABORT` sperren die darauf angewiesene Waffenwirkung;
- Continuous und Delayed Lasing werden getrennt konfiguriert und getestet.

## 6. Technische Zielarchitektur

Vorrangig zu prüfen und einzusetzen:

- `COMMANDER` und `AIRWING` für Zuweisung und Ausführung;
- `AUFTRAG` für KI-Missionen;
- `PLAYERTASK` für Spieleraufträge;
- `INTEL`, `DETECTION`, `TARGET`, `PLAYERRECCE` und `DESIGNATE` für Aufklärung und Zielentwicklung;
- projektbezogene Adapter nur nach Dokument 26.

Die vollständige technische MOOSE-Einordnung steht in:

- [`ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur`](moose/ISR-FAC-CAS-AAR.md)

Interne Planungsdaten werden in folgende Produkte projiziert:

```text
CampaignState / MissionDemand
        -> AirSupportRequest + AirPlan
        -> MOOSE AUFTRAG / AIRWING / COMMANDER
        -> Spielerbriefing / Kneeboard / F10-Menü
        -> MISREP / BDA / CampaignState-Ergebnis
```

Ein vollständiger generischer USMTF-/ADatP-3-Parser ist nicht freigegeben. Vorrang hat ein begrenztes, validiertes OMW-Schema mit optionalem ATO-ähnlichem Export.

## 7. Noch erforderliche Acceptance

- missionsspezifische C2-Kette und Menüs;
- Spieler-/KI-Übergabe desselben Auftrags;
- Request-zu-Mission-Nachverfolgbarkeit;
- Preplanned-/Immediate-/Emergency-Übergänge;
- Ground-Alert-Start und bestandsgebundene Bereitschaft;
- Zielaktualisierung, Dynamic Retask und Abbruch;
- Funk- und Frequenzmodell;
- Laser-State-Machine und Abort;
- Multiplayer-Synchronisation;
- NSL- und ROE-Blockierung;
- Airspace-Control-Konfliktprüfung;
- reproduzierbare DCS-Tests für FAC/AFAC/JTAC-Verfahren;
- verwendete DCS-, MOOSE-, Mission- und Bundle-Version.
