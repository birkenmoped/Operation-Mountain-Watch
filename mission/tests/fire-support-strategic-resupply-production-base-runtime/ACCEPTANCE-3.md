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

Acceptance 3 bündelt in einem DCS-Lauf:

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

Ausschließlich für Acceptance 3 werden sechs late-activated RED-Gruppen angelegt:

```text
BadGuys_A3_FENTY
BadGuys_A3_FORTRESS
BadGuys_A3_JOYCE
BadGuys_A3_WRIGHT
BadGuys_A3_HONAKER
BadGuys_A3_BOSTICK
```

Diese Gruppen sind reine Testfixtures. Sie sind keine produktive RED-ORBAT und kein späteres RED-C2-Modell. Die produktive RED-C2 soll feindliche Kräfte dynamisch auswählen, einsetzen und bewegen. Kein BLUE-Produktionsmodul darf von diesen Namen oder ihrer Existenz abhängen.

Für einen reproduzierbaren Direct-Fire-Test sollen alle sechs Fixtures:

- `Late Activation` verwenden;
- als kleine bewaffnete Ground-Gruppe ausgelegt sein;
- freie Sicht auf den lokalen BLUE-Guard-Bereich besitzen;
- nahe genug stehen, dass nach Aktivierung reale direkte Feuerereignisse gegen den lokalen Guard entstehen können;
- keine ARTY-/indirect-fire-Rolle für diesen Acceptance-Lauf übernehmen.

Die genaue Position ist ausschließlich Testgeometrie und keine produktive Alarmzonen-, QRF-, ARTY- oder CAS-Geometrie.

**Zusätzliche Mission-Editor-Testzonen sind nicht erforderlich.** Die Acceptance korreliert ein physisches MOOSE-Event ausschließlich dann mit einer Site, wenn dessen BLUE-Ziel zur tatsächlich von MOOSE für diese Site rekrutierten Guard-Gruppe gehört. Damit wird weder eine produktive Alarmzone erfunden noch `ACCESS`, Warehouse oder Guard-PATHLINE als Alarmgeometrie missbraucht.

## MOOSE-first

Der Test verwendet die öffentlichen MOOSE-Pfade `GROUP:Activate()`, `EVENTHANDLER`, `EVENTS.Hit`, `EVENTS.Shot`, `EVENTS.ShootingStart`, den `WEAPON`-Wrapper sowie `AUFTRAG`, `BRIGADE`, `PLATOON` und MOOSE-Recruitment.

Die tatsächliche MOOSE-`EVENTDATA` stellt `IniUnit`, `IniGroup`, `IniUnitName`, `IniGroupName` und Target-Wrapper bereit. `OMW_GroundInstallationAlarmEvidenceAdapter` Schema 3 übernimmt die reale hostile `IniUnit:GetCoordinate()`-Position als Evidence-Position. Die QRF erhält damit die reale Angreiferposition und keine erfundene Zielkoordinate.

Die Acceptance-spezifische `targetInAlarmZone`-Funktion dient nur zur Zuordnung eines physischen Events zum bereits rekrutierten lokalen Guard. Sie ist kein produktiver Detection- oder Alarmzonen-Ersatz.

## Ablauf

1. Production Base und sechs lokale BRIGADEs werden vorbereitet; je Site existiert ein Guard- und QRF-Cohort.
2. `StartAlarmEvidence()` aktiviert die MOOSE-Eventhandler, während alle `BadGuys_A3_*` noch late-activated sind.
3. Alle sechs persistenten Guard-Demands starten.
4. Der Harness wartet, bis **alle sechs Guards jeweils mindestens 25 m Bewegung** erreicht haben, und merkt diesen Guard-Regression-PASS siteweise vor.
5. Erst danach aktiviert der Harness alle sechs `BadGuys_A3_*`-Fixtures gleichzeitig.
6. Reale physische `Shot`/`ShootingStart`/`Hit`-Evidence gegen den jeweiligen lokalen Guard muss je Site einen Installation-Incident erzeugen.
7. Pro Incident darf genau ein initialer lokaler QRF-Demand entstehen.
8. MOOSE muss je Site eine `Ground_APC`-QRF rekrutieren.
9. Jede QRF muss mindestens 25 m Distanz zur real gemeldeten Angreiferposition abbauen.

Die RED-Fixtures werden bewusst erst nach dem Guard-Regressionskriterium aktiviert. So werden Guard-Regression und physische Kampfreaktion in einem einzigen DCS-Lauf geprüft, ohne dass frühes RED-Feuer den Guard-Nachweis verfälscht.

## PASS-Kriterium

```text
6/6 Guards hatten vor RED-Aktivierung >= 25 m Bewegung
6/6 physical alarm-evidence incidents observed
6/6 incidents contain exactly one initial response demand
6/6 QRF mission observed
6/6 QRF attribute = Ground_APC
6/6 QRF alive at QRF evaluation
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
