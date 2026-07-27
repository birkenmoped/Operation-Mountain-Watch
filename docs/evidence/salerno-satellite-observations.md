---
document_id: OMW-EVIDENCE-SALERNO-SATELLITE-OBSERVATIONS
status: BINDING
document_class: EVIDENCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - project-recorded visual observations from supplied FOB Salerno satellite images
not_authoritative_for:
  - complete administrative aircraft strength
  - exact unit identity from silhouette alone
  - aircraft mission-ready status
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/document-salerno-air-operations
source_commit: PENDING_MERGE
validated_in_dcs: false
source_status: USER_SUPPLIED_IMAGE_REVIEWED
validation_status: VISUALLY_CONFIRMED_BY_PROJECT_OWNER
---

# FOB Salerno – dokumentierte Satellitenbeobachtungen

## 1. Zweck

Dieses Evidenzdokument trennt die auf den vom Projektinhaber bereitgestellten Satellitenbildern beobachteten Luftfahrzeuge von der daraus abgeleiteten aktiven OMW-ORBAT in [`OMW-AIR-SALERNO-MANIFEST`](../51-salerno-air-operations-manifest.md).

Die Beobachtungen sind Momentaufnahmen. Sie belegen sichtbare Mindestpräsenz und Rampennutzung, nicht automatisch vollständige Sollstärke, Wartungsstatus, Einsatzbereitschaft oder genaue Einheitszugehörigkeit.

## 2. Aufnahme vom 21. Juni 2011

Vom Projektinhaber bestätigtes Aufnahmedatum:

```text
21.06.2011
```

Beobachtete Luftfahrzeuge:

| Bereich | Muster | Sichtbar |
|---|---|---:|
| obere östliche Reihe | AH-64 | 5 |
| mittlere östliche Reihe | UH-60 / Black Hawk | 3 |
| untere östliche Reihe links | OH-58 | 5 |
| untere östliche Reihe rechts | UH-60 / Black Hawk | 3 |
| westliche Heavy-Lift-Fläche | CH-47 | 4 |
| **Gesamt** |  | **20** |

Projektseitige Funktionszuordnung:

```yaml
AH-64D_ATTACK: 5
OH-58D_CAVALRY: 5
UH-60L_ASSAULT: 3
UH-60_MEDEVAC: 3
CH-47D_MEDIUM_LIFT: 4
```

Die Trennung der sechs sichtbaren Black Hawks in drei Assault- und drei MEDEVAC-Maschinen ist eine kombinierte Ableitung aus Rampenanordnung und dokumentierter Task-Force-Komponentenstärke. Die Satellitensilhouetten allein beweisen die organisatorische Zuordnung nicht.

## 3. Vergleichsaufnahme vom März 2010

Die Aufnahme liegt außerhalb des verbindlichen OMW-Kampagnenbeginns, ist aber als Rampen- und Kapazitätsevidenz relevant.

Beobachtete Luftfahrzeuge:

| Bereich | Muster | Sichtbar |
|---|---|---:|
| östliche Attack-Reihe | AH-64 | 5 |
| östliche Black-Hawk-Reihe | UH-60 / Black Hawk | 3 |
| östliche Scout-Reihe | OH-58 | 8 |
| westliche Heavy-Lift-Fläche | CH-47 | 4 |
| Wartungs-/Arbeitsfläche | CH-47 | 1 |
| **Gesamt** |  | **21** |

Die Aufnahme stützt insbesondere:

- acht nutzbare OH-58-Positionen;
- eine getrennte Black-Hawk-Reihe;
- mindestens acht Heavy-Lift-Positionen;
- eine zusätzliche CH-47-Wartungs-/Arbeitsfläche;
- die dauerhaft freigehaltene zentrale Achse innerhalb der östlichen Rampenreihen.

## 4. Rampen- und Flächenbeobachtungen

| Bereich | Projektbewertung |
|---|---|
| ausgerichtete mittlere Freiflächen in den östlichen Reihen | `RESERVED_NO_PARKING`; konkrete Schutz-/Zufahrtsfunktion nicht abschließend identifiziert |
| vier Flächen südlich der CH-47-Abstellung | wahrscheinlich Refueling/Hot Refueling; `TRANSIENT_ONLY` |
| zusätzliche Fläche am Heavy-Lift-Bereich | Wartung/Arbeitsfläche; keine reguläre Dauerabstellung |
| westlich gelegene unklare Fläche ohne beobachtete Luftfahrzeuge | `UNCLASSIFIED_NO_PERMANENT_ASSIGNMENT` |

## 5. Interpretationsgrenzen

Aus den Bildern darf nicht ohne weitere Evidenz abgeleitet werden:

- vollständiger administrativer Bestand;
- Zahl gleichzeitig einsatzbereiter Maschinen;
- Zahl der Maschinen im Einsatz oder in Wartung;
- genaue Untereinheit jeder sichtbaren Silhouette;
- dauerhafte Nutzung jeder freien Betonfläche;
- automatische Gleichsetzung freier Pads mit zusätzlichem lokalen Bestand.

Die verbindliche OMW-Bestandsentscheidung steht ausschließlich im Salerno-Manifest.