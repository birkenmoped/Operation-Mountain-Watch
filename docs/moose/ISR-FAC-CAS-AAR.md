---
document_id: OMW-MOOSE-ISR-FAC-CAS-AAR
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MOOSE-based ISR, contact, FAC/JTAC, CAS, strike, BDA and AAR integration
  - separation of sensing, decision, tasking, designation and effects
not_authoritative_for:
  - DCS runtime acceptance
  - active ORBAT or mission-specific ROE
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - PLANNED used only as prose status without governance metadata
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur

## 1. Status

```text
PLANNED – noch nicht als vollständige Laufzeitkette in DCS akzeptiert
```

Der vollständige frühere Architekturentwurf mit Klassenmatrix bleibt erhalten:

- [`Legacy-ISR-/FAC-/CAS-/AAR-Architektur`](../evidence/source-records/legacy-moose-isr-fac-cas-aar.md)

Fachliche Grundlage:

- [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](../45-air-c2-cas-afghanistan.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL`](../48-afghanistan-no-strike-list.md)
- [`OMW-MOOSE-FOG-OF-WAR-RECCE`](FOG-OF-WAR-RECCE.md)

## 2. Funktionsschichten

```text
Sensor und Beobachtung
→ Kontakt-/Intelligence-Modell
→ Zielentwicklung und Entscheidung
→ Spieler- oder KI-Auftrag
→ Markierung / Koordinatenübergabe
→ Wirkung
→ Battle Damage Assessment
→ CampaignState-Folge
```

Kein einzelner FAC-, FACA-, CAS- oder AUFTRAG-Typ bildet automatisch die gesamte Kette ab.

## 3. Vorrangige MOOSE-Bausteine

- `INTEL`, `DETECTION` und Sets für Kontakte und Lagebild;
- `TARGET` für standardisierte Zielobjekte;
- `PLAYERRECCE` für Spieleraufklärung;
- `DESIGNATE` für Laser, Rauch, IR und Koordinatenübergabe;
- `PLAYERTASK` für Spieleraufträge;
- `AUFTRAG` für KI-Missionen;
- `COMMANDER`, `AIRWING`, `SQUADRON` und `FLIGHTGROUP` für Assetauswahl und Ausführung;
- Tanker-/AAR-Funktionen gemäß gepinntem MOOSE-Stand.

## 4. Verbindliche Architekturgrenzen

- Sensor, Entscheidung und Shooter besitzen getrennte Zustände.
- Spieler und KI arbeiten auf demselben Kontakt-, Ziel- und MissionDemand-Objekt.
- Unzureichende Identifikation, NSL-Konflikt oder fehlende Autorität blockieren Tasking beziehungsweise Wirkung.
- Zielbewegung und neue Koordinaten lösen eine erneute Targeting-Prüfung aus.
- BDA verändert CampaignState erst nach validierter Wirkung.
- Bewaffnete UAVs dürfen Aufklärung und Wirkung nur nach expliziter Rollen- und Freigabeentscheidung verbinden.

## 5. Acceptance-Bedarf

- Kontaktentstehung, Trackverlust und Wiedererkennung;
- Spieler-Recon und KI-ISR;
- FAC/JTAC/AFAC-Markierung und Übergabe;
- Spieler-/KI-Tasking ohne Doppelauftrag;
- CAS, Strike und bewaffnete UAV-Ausführung;
- NSL-, ROE- und C2-Abbruch;
- BDA und CampaignState-Rückmeldung;
- AAR-Orbits, Tankerzuweisung und Funk/TACAN;
- Multiplayer-, Persistenz- und Missionsneustarttests.
