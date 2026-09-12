---
document_id: OMW-FIRE-SUPPORT-GATE5-GUARD-PRODUCTION-MATERIALIZER-ACCEPTANCE-3
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5 DCS regression of the productive Guard PATHLINE materialization adapter
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: 33c900bea65b53159f8ebed5690a0a5139af164f
validated_in_dcs: true
dcs_version: 2.9.29.27468
bundle_sha256: 1DA151FB71A631C13A151E23A0C25DBD788E282E060C480BC07DAE1B98C61E02
materializer_sha256: 6FA28519564377ADF40175F9F1DFC1607B2ED693DF30AD6DD57AF92ED4B7D4E2
acceptance_source_sha256: A562A4B9379F91E962C538FBD7B3825701C1C78EE0AD881F7EC7C49EAE175410
---

# Gate 5 - Guard Production Materializer Acceptance 3

## Ergebnis

Acceptance 3 ist fuer den festgelegten Gate-5-Scope **PASS**.

Der Owner-local Builder-5-Lauf wurde auf Commit

```text
33c900bea65b53159f8ebed5690a0a5139af164f
```

erzeugt. Die real lokal ermittelten Artefakt-Hashes sind im Frontmatter dokumentiert. `MIZ mutation: false` wurde im Build ausgegeben.

Der anschliessende reale DCS-Lauf auf DCS `2.9.29.27468` bestaetigte fuer alle sechs Sites:

```text
- produktives OMW_GuardPathlineMaterializationAdapter.lua verwendet;
- Guard PATHLINE-ausgerichtet materialisiert;
- Guard alive;
- Route gestartet;
- Spawnabstand 2.00 m;
- mindestens 25 m Bewegung beobachtet;
- kein Guard-ACCESS-Zonen-Vertrag eingefuehrt.
```

Die Testtelemetrie endete mit:

```text
[GATE 5][PASS] 6/6 Guards production materializer >=25 m movement observed
```

Am PASS-Checkpoint wurden unter anderem folgende Bewegungen protokolliert:

```text
JALALABAD_FENTY   206.8 m
COP_FORTRESS      203.9 m
FOB_JOYCE         215.5 m
FOB_WRIGHT        259.5 m
COP_HONAKER       185.1 m
FOB_BOSTICK        36.8 m
```

## Produktive Ausnahmegrenze

Die Owner-Freigabe bleibt eng begrenzt auf die exakte Guard-Materialisierung ueber den privaten MOOSE-WAREHOUSE-Spawn-Schritt:

```text
Guard asset
-> normaler MOOSE BRIGADE / WAREHOUSE Lifecycle
-> direkt vor Ground-Asset-Materialisierung exakte Unit-Positionen/Headings
   auf erstem Guard-PATHLINE-Segment setzen
-> normaler MOOSE PLATOON / ARMYGROUP / AUFTRAG Lifecycle
```

Nicht freigegeben sind insbesondere eigene Asset-Selektion, eigene Queue/Retry-Queue, Ersatz des MOOSE-Recruitments oder die Wiederverwendung dieser privaten Materialisierungsstelle fuer Convoy/QRF/ARTY/CAS/Resupply ohne neue Owner-Freigabe.

`ZON_BLUE_GND_*_ACCESS` bleibt ausschliesslich Convoy-/Zufahrtskontext und ist kein Guard-Spawn-, Guard-Routen- oder Guard-Acceptance-Vertrag.

## Owner-Entscheidung zur Patrol-Wiederholung

Im realen DCS-Lauf wurde zusaetzlich beobachtet:

```text
FOB_WRIGHT:
  Guard schien die Patrouille wiederholt weiterzufahren.

Andere Sites:
  nach der ersten Runde bzw. am Routenende teilweise sichtbare Pause.
```

Der Projektinhaber hat am 12.09.2026 ausdruecklich entschieden, dieses Verhalten fuer den aktuellen Gate-5-/Foundation-Scope als **PASS** zu akzeptieren, damit die allgemeine `fire-support-strategic-resupply` Base weiter fertiggestellt werden kann.

Die bestehende Routing-Implementierung bleibt deshalb unveraendert. Der zwischenzeitlich vorbereitete separate PATHLINE-Patrol-Adapter wird nicht Bestandteil dieser Baseline.

## Spaeteres TODO - MOOSE-native Patrol-Verfeinerung

Nach Fertigstellung der grundlegenden `fire-support-strategic-resupply` Base ist gesondert zu pruefen, ob die Guard-Patrouille auf einen noch staerker MOOSE-nativen Wiederholungsweg umgestellt werden soll, insbesondere:

```text
- CONTROLLABLE:PatrolRoute() / Template-Waypoint-Vertrag;
- erforderliche Abbildung der owner-authored Guard-PATHLINE auf den von MOOSE erwarteten Template-Route-Vertrag;
- Verhalten an geschlossenen Mission-Editor-Line-Drawings;
- DCS-Ground-AI-Verhalten nach mehreren Patrol-Zyklen.
```

Dieses TODO ist **kein Gate-5-Blocker** und darf nicht stillschweigend in die aktuelle Base-Foundation zurueckgezogen werden. Eine spaetere Aenderung benoetigt erneut Source-Pruefung des gepinnten MOOSE-Stands und DCS-Regression.

## Statusgrenze

```text
OWNER-LOCAL BUILD: PASS
DCS ACCEPTANCE-3: PASS
PRODUCTIVE GUARD MATERIALIZER: VALIDATED fuer diesen Scope
CONTINUOUS MULTI-CYCLE PATROL REFINEMENT: DEFERRED TODO
GATE 5: ACCEPTED
```
