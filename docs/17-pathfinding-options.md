---
document_id: OMW-ARCH-PATHFINDING-OPTIONS
status: PLANNED
document_class: TECHNICAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned distinction between DCS road paths and MOOSE A-star graph routing
  - routing option evaluation criteria
not_authoritative_for:
  - production routing acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - ungoverned custom routing cost example
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 17 – Pathfinding-Optionen

## 1. Zweck

MOOSE stellt unterschiedliche Routingverfahren bereit, die getrennt bewertet werden:

1. detaillierte Pfade auf dem DCS-Straßen- oder Schienennetz;
2. generisches A*-Pathfinding über einen projektseitig bereitgestellten Knoten- oder Segmentgraphen.

Der vollständige frühere technische Entwurf bleibt erhalten:

- [`Legacy-Pathfinding-Optionen`](evidence/source-records/legacy-17-pathfinding-options.md)

## 2. DCS-Straßenpfad

Für bekannte Start- und Zielkoordinaten wird vorrangig `COORDINATE:GetPathOnRoad()` geprüft. Ein zurückgegebener Pfad garantiert keine fehlerfreie DCS-AI-Fahrt und muss praktisch validiert werden.

Geeignet für:

- physische Konvois und QRF;
- detaillierte Segmentgeometrie;
- virtuelle Bewegung entlang bekannter Straßen;
- alternative Verbindungen zwischen bekannten Knoten.

## 3. MOOSE A*

`Core.Astar` wird für die Auswahl zwischen mehreren strategischen Knoten, Segmenten oder Geländeoptionen geprüft.

Es kann unter anderem berücksichtigen:

- Distanz und Oberflächentyp;
- Straßenverbindung;
- Gelände- und Steigungseignung;
- Risiko, Checkpoints und Aufklärung;
- Blockaden, Tageszeit und Wetter;
- Transportart und Kapazität.

A* erzeugt keine semantische Ortsdatenbank und ersetzt nicht die detaillierte DCS-Straßenpolylinie.

## 4. MOOSE-First- und Kostenregel

Vor eigener Implementierung werden Quellcode, Signaturen, Demos und Verhalten des gepinnten MOOSE-Stands geprüft.

Eine projektspezifische Kostenfunktion oder ein eigener Graph-Algorithmus benötigt:

- dokumentierte MOOSE-Lücke;
- kleinstmöglichen Ergänzungsumfang;
- ausdrückliche Projektinhaberfreigabe;
- reproduzierbaren DCS-Test.

## 5. Performance und Acceptance

- kein hochauflösendes Raster über große Kartenteile in der Produktionsmission;
- begrenzte, fachlich definierte Knoten und Kanten;
- Pfade und Kosten möglichst vorberechnen oder cachen;
- DCS-Befahrbarkeit, Stuck-Verhalten und Alternativen je Segment testen;
- Karten-, DCS-, MOOSE- und OMW-Version dokumentieren.
