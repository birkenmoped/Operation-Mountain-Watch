---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - six-site physical installation-alarm evidence acceptance fixture contract
  - six-site physical evidence to incident to local-QRF acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Production Base Acceptance 3 – Six-Site Physical Alarm Evidence + QRF

## Ziel

Acceptance 3 bündelt die nächste DCS-Prüfung in einem Lauf. Alle sechs Ground-Installationen erhalten jeweils eine separate RED-Testfixture. Der Lauf soll gleichzeitig nachweisen:

```text
6x bestehende Guard-Regression
+ 6x reale DCS/MOOSE Kampfereignisse
+ 6x GroundInstallationAlarmEvidenceAdapter
+ 6x autoritativer Installation-Incident
+ 6x genau ein initialer lokaler QRF-Demand
+ 6x MOOSE-rekrutierte Ground_APC-QRF
+ 6x physische QRF-Bewegung zum gemeldeten Angreifer
```

ARTY, CAS, Resupply und produktive RED-C2 sind nicht Bestandteil dieses Laufs.

## Testfixture-Vertrag der `.miz`

Zusätzlich zu den bereits vorhandenen Foundation-Objekten werden ausschließlich für Acceptance 3 sechs late-activated RED-Gruppen angelegt:

```text
BadGuys_A3_FENTY
BadGuys_A3_FORTRESS
BadGuys_A3_JOYCE
BadGuys_A3_WRIGHT
BadGuys_A3_HONAKER
BadGuys_A3_BOSTICK
```

Diese Gruppen sind ausschließlich Testmittel. Sie sind keine produktive RED-ORBAT und kein späteres RED-C2-Modell. Die produktive RED-C2 soll feindliche Kräfte dynamisch auswählen, einsetzen und bewegen. Kein BLUE-Produktionsmodul darf von diesen Namen oder ihrer Existenz abhängen.

Für einen reproduzierbaren Direct-Fire-Test sollen alle sechs Fixtures:

- `Late Activation` verwenden;
- als kleine bewaffnete Ground-Gruppe ausgelegt sein;
- freie Sicht auf den jeweiligen Installations-/Guard-Bereich besitzen;
- so platziert werden, dass nach Aktivierung reale direkte Feuerereignisse gegen BLUE entstehen können;
- keine ARTY-/indirect-fire-Rolle für diesen Acceptance-Lauf übernehmen.

Die genaue Position ist ausschließlich Testgeometrie. Sie ist keine produktive Alarmzonen-, QRF-, ARTY- oder CAS-Geometrie.

## Acceptance-only Testzonen

Für eine deterministische Zuordnung der realen DCS/MOOSE-Events zu genau einer Site werden zusätzlich sechs Mission-Editor-Triggerzonen angelegt:

```text
ZON_TEST_A3_FENTY_ALARM
ZON_TEST_A3_FORTRESS_ALARM
ZON_TEST_A3_JOYCE_ALARM
ZON_TEST_A3_WRIGHT_ALARM
ZON_TEST_A3_HONAKER_ALARM
ZON_TEST_A3_BOSTICK_ALARM
```

Jede Zone wird ausschließlich für Acceptance 3 um den Bereich gelegt, in dem die jeweilige BLUE-Installation/Guard-Einheiten vom zugehörigen `BadGuys_A3_*`-Fixture bekämpft werden können. Die Zone soll groß genug sein, um die vorgesehenen BLUE-Ziele der jeweiligen Fixture zu enthalten, aber nicht bis zu einer anderen der sechs Installationen reichen.

Diese sechs `ZON_TEST_A3_*`-Objekte sind ausdrücklich **keine** produktiven Alarmzonen. Sie dienen nur der Testkorrelation.

```text
ZON_TEST_A3_* != production installation alarm zone
ZON_TEST_A3_* != tactical battlespace
ZON_TEST_A3_* != WEZ
ZON_TEST_A3_* != ARTY/CAS target geometry
```

Insbesondere werden keine `ZON_BLUE_GND_*_ACCESS`, Warehouses oder Guard-PATHLINEs als Alarmanker interpretiert.

## MOOSE-first

Der Test verwendet die im gepinnten MOOSE vorhandenen öffentlichen Pfade:

```text
GROUP:Activate()
ZONE:FindByName()
EVENTHANDLER + EVENTS.Hit / EVENTS.Shot / EVENTS.ShootingStart
WEAPON wrapper, soweit das reale Event einen Weapon-Pfad liefert
AUFTRAG + BRIGADE + PLATOON + MOOSE recruitment
```

Die tatsächliche MOOSE-`EVENTDATA` stellt `IniUnit`, `IniGroup`, `IniUnitName`, `IniGroupName` und Target-Wrapper bereit. Der Production Alarm-Evidence-Adapter übernimmt die reale hostile `IniUnit:GetCoordinate()`-Position als Evidence-Position, damit die QRF nicht auf erfundene Koordinaten angewiesen ist.

## Ablauf

1. Die Production Base wird mit den sechs `ZON_TEST_A3_*`-Testzonen als Alarm-Evidence-Sites vorbereitet.
2. `StartAlarmEvidence()` aktiviert die MOOSE-Eventhandler, bevor eine RED-Fixture aktiviert wird.
3. Sechs lokale BRIGADEs starten mit je Guard- und QRF-Cohort.
4. Alle sechs persistenten Guard-Demands starten.
5. Danach aktiviert der Harness die sechs late-activated `BadGuys_A3_*`-Fixtures.
6. Reale physische `Shot`/`ShootingStart`/`Hit`-Evidence muss je Site einen Installation-Incident erzeugen.
7. Pro Incident darf genau ein initialer lokaler QRF-Demand entstehen.
8. MOOSE muss je Site eine `Ground_APC`-QRF rekrutieren.
9. Jede QRF muss mindestens 25 m Distanz zur real gemeldeten Angreiferposition abbauen.
10. Parallel bleibt die bekannte Six-Site-Guard-Bewegung >=25 m Teil des gemeinsamen Regression-PASS.

## PASS-Kriterium

Ein PASS erfordert gleichzeitig:

```text
6/6 Guard mission observed
6/6 Guard alive at evaluation
6/6 Guard movement >= 25 m
6/6 physical alarm-evidence incidents observed
6/6 incidents contain exactly one initial response demand
6/6 QRF mission observed
6/6 QRF attribute = Ground_APC
6/6 QRF alive at evaluation
6/6 QRF target-distance progress >= 25 m
```

Kein Evidence-Objekt wird durch den Harness direkt mit `ReportInstallationEvidence()` eingespeist. Das unterscheidet Acceptance 3 von Acceptance 2.

## Noch nicht bewiesen

Ein PASS validiert nicht:

- produktive sechs-site Alarmzonen-Geometrie;
- ARTY- oder CAS-Eskalation;
- Ground-/Air-Resupply;
- CampaignState Transport Settlement;
- produktive RED-C2;
- generische Mission-End-/Incident-Close-Logik.
