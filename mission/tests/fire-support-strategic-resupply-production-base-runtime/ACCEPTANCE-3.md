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

Diese Gruppen sind `HISTORICAL_TEST_FIXTURE`-artige Testmittel, keine produktive RED-ORBAT und kein späteres RED-C2-Modell. Die produktive RED-C2 soll feindliche Kräfte dynamisch auswählen, einsetzen und bewegen. Kein BLUE-Produktionsmodul darf von diesen Namen oder ihrer Existenz abhängen.

Für einen reproduzierbaren Direct-Fire-Test sollen alle sechs Fixtures:

- `Late Activation` verwenden;
- im Mission Editor initial `Weapons Hold` erhalten;
- als kleine bewaffnete Ground-Gruppe ausgelegt sein;
- freie Sicht auf den jeweiligen Installations-/Guard-Bereich besitzen;
- so platziert werden, dass nach Freigabe realistische direkte Feuerereignisse gegen BLUE entstehen können;
- keine ARTY-/indirect-fire-Rolle für diesen Acceptance-Lauf übernehmen.

Die genaue Position ist ausschließlich Testgeometrie. Sie ist keine produktive Alarmzonen-, QRF-, ARTY- oder CAS-Geometrie.

## Acceptance-only Alarmzonen

Der Harness erzeugt je Fixture eine MOOSE `ZONE_RADIUS` um die reale Fixture-Koordinate. Diese Zone dient ausschließlich dazu, physische `Shot`/`ShootingStart`/`Hit`-Events einer Site reproduzierbar zuzuordnen.

```text
Acceptance fixture zone != production installation alarm zone
Acceptance fixture zone != tactical battlespace
Acceptance fixture zone != WEZ
Acceptance fixture zone != ARTY/CAS target geometry
```

Insbesondere werden keine `ZON_BLUE_GND_*_ACCESS`, Warehouses oder Guard-PATHLINEs als produktive Alarmanker interpretiert.

## MOOSE-first

Der Test verwendet die im gepinnten MOOSE vorhandenen öffentlichen Pfade:

```text
GROUP:Activate()
CONTROLLABLE:OptionROEHoldFire()
CONTROLLABLE:OptionROEOpenFire()
CONTROLLABLE:OptionAlarmStateRed()
ZONE_RADIUS:New()
EVENTHANDLER + EVENTS.Hit / EVENTS.Shot / EVENTS.ShootingStart
WEAPON wrapper, soweit das reale Event einen Weapon-Pfad liefert
AUFTRAG + BRIGADE + PLATOON + MOOSE recruitment
```

Die tatsächliche MOOSE-`EVENTDATA` stellt `IniUnit`, `IniGroup`, `IniUnitName`, `IniGroupName` und Target-Wrapper bereit. Der Production Alarm-Evidence-Adapter übernimmt die reale hostile `IniUnit:GetCoordinate()`-Position als Evidence-Position, damit die QRF nicht auf erfundene Koordinaten angewiesen ist.

## Ablauf

1. Sechs RED-Fixtures werden aktiviert und sofort in `Weapons Hold` gehalten.
2. Aus ihren realen Koordinaten werden ausschließlich für Acceptance 3 sechs MOOSE-Testzonen erzeugt.
3. Die Production Base wird mit sechs Alarm-Evidence-Sites vorbereitet.
4. `StartAlarmEvidence()` aktiviert die MOOSE-Eventhandler.
5. Sechs lokale BRIGADEs starten mit je Guard- und QRF-Cohort.
6. Alle sechs persistenten Guard-Demands starten.
7. Erst wenn alle sechs Guards mindestens 25 m Bewegung gezeigt haben, werden die RED-Fixtures auf `Open Fire` gesetzt.
8. Der Test wartet auf reale physische Evidence, je einen Installation-Incident und je einen lokalen QRF-Demand.
9. MOOSE muss je Site eine `Ground_APC`-QRF rekrutieren.
10. Jede QRF muss mindestens 25 m Distanz zum gemeldeten Angreifer abbauen.

## PASS-Kriterium

Ein PASS erfordert gleichzeitig:

```text
6/6 Guard mission observed
6/6 Guard alive at Guard-regression threshold
6/6 Guard movement >= 25 m before hostile release
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
