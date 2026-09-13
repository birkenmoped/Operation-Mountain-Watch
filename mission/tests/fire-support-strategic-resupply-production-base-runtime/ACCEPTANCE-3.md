---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - corrected six-site installation-alarm acceptance contract
  - six-site proximity-evidence to incident to local-QRF acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Production Base Acceptance 3 – Six-Site Installation Alarm + QRF

## Statuskorrektur nach den ersten zwei DCS-Diagnoseläufen

Die zuerst gebaute Acceptance-3-Fassung korrelierte physische `Shot`/`ShootingStart`/`Hit`-Events nur dann mit einer Site, wenn das BLUE-Ziel zur tatsächlich rekrutierten lokalen Guard-Gruppe gehörte. Diese Guard-only-Korrelation ist als Zielmodell verworfen.

Sie widerspricht der verbindlichen Projektentscheidung, nach der die standortbezogene Alarm-/Security-/Threat-Zone der **Installation** gehört und `PROXIMITY_INTRUSION` ein eigenständiger gültiger Alarmtrigger ist. Direct Fire, Indirect Fire und confirmed Hit bleiben zusätzliche Evidence-Kanäle und dürfen denselben Incident erzeugen oder refreshen, sind aber nicht die alleinige Installationsdetektion.

Die ersten beiden DCS-Läufe werden ausschließlich als Diagnoseevidenz behalten. Sie sind kein Acceptance-PASS und keine produktive Alarmbaseline.

## Verbindliche Alarmsemantik

```text
site-specific installation alarm/security/threat zone
-> hostile proximity / penetration
-> PROXIMITY_INTRUSION
-> authoritative installation attack incident
-> exactly one initial local QRF demand
-> MOOSE recruitment / execution

parallel valid evidence:
DIRECT_FIRE_ATTACK
INDIRECT_FIRE_ATTACK
CONFIRMED_HIT_ATTACK
OTHER_CONFIRMED_ATTACK
-> same incident / refresh
-> no duplicate initial QRF demand
```

Die Alarmzone ist nur Detection-/Response-Triggergrenze. Sie ist nicht taktischer Gefechtsraum, WEZ, Fire-Support-Zielgebiet, CAS-Zone oder Mission-End-Bedingung. `OPSZONE:Defeated` beziehungsweise das Verlassen oder Freikämpfen der Zone beendet laufende Incidents oder Support-Aufträge nicht automatisch.

`ACCESS`, Warehouse-Position und Guard-PATHLINE sind keine Alarmgeometrie.

## Vom Projektinhaber festgelegte Six-Site-Alarmgeometrie

Für Acceptance 3 und die daraus abzuleitende Produktionskonfiguration gilt die folgende ausdrücklich festgelegte Geometrie. Es werden **keine zusätzlichen Mission-Editor-Trigger-/Alarmzonen** angelegt. Die Alarmperimeter werden zur Laufzeit über den vorhandenen MOOSE-first-Pfad `anchor coordinate -> ZONE_RADIUS -> OPSZONE` erzeugt.

Für Fortress, Joyce, Wright, Honaker und Bostick ist das jeweils bereits vorhandene MOOSE-Warehouse der Standortmittelpunkt. Jalalabad ist eine ausdrückliche Ausnahme: Dort wird **nicht** das Warehouse von FOB Fenty als Mittelpunkt verwendet, sondern der bestehende Missionsanker `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT`.

| Site | Alarmanker | Radius ft | Radius m |
|---|---|---:|---:|
| `JALALABAD_FENTY` | `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT` | 6000 | 1828.8 |
| `COP_FORTRESS` | `WH_BLUE_GND_FORTRESS` | 5000 | 1524.0 |
| `FOB_JOYCE` | `WH_BLUE_GND_JOYCE` | 9000 | 2743.2 |
| `FOB_WRIGHT` | `WH_BLUE_GND_WRIGHT` | 4000 | 1219.2 |
| `COP_HONAKER` | `WH_BLUE_GND_HONAKER` | 9000 | 2743.2 |
| `FOB_BOSTICK` | `WH_BLUE_GND_BOSTICK` | 5000 | 1524.0 |

Umrechnung: `1 ft = 0.3048 m` exakt.

Die fünf Warehouse-Anker dienen hier ausschließlich als stabile geografische Mittelpunkte der Alarmperimeter. Daraus entsteht **keine** zusätzliche Ressourcen- oder Alarmhoheit des Warehouses. Die Jalalabad-Ausnahme bildet bewusst den gesamten Flughafen-/Installationskontext statt nur FOB Fenty ab.

Vor dem nächsten Acceptance-3-Build ist technisch zu verifizieren, als welcher tatsächlich vorhandene MOOSE-/DCS-Wrapper beziehungsweise Mission-Editor-Objekttyp `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT` im aktuellen Missionsstand aufgelöst werden muss. Diese Auflösung darf nicht geraten werden. Für die fünf Warehouse-Anker ist ebenfalls der vorhandene öffentliche MOOSE-Koordinatenpfad der bereits existierenden Warehouse-/BRIGADE-Objekte zu verwenden; keine parallele native DCS-Ankerlogik wird eingeführt.

## Diagnose aus den ersten zwei Läufen

Die Guard-Regression lief an allen sechs Standorten an. Die Auswahl der Standorte, an denen ein Incident und anschließend eine QRF entstand, wechselte zwischen den Läufen. Unter anderem wurden im ersten Lauf Wright und Fortress, im zweiten Lauf unter anderem Joyce und Wright mit Incident/QRF beobachtet.

Dieses wechselnde Muster ist mit der Guard-only Event-Korrelation erklärbar: Je nachdem, welches BLUE-Ziel eine RED-Testgruppe zuerst bekämpfte, konnte der Acceptance-Filter ein reales Kampfereignis akzeptieren oder verwerfen.

Der Harness enthält **keine globale QRF-Obergrenze**. Pro Site wird eine eigene BRIGADE mit eigenem QRF-PLATOON aufgebaut. Mehrere QRFs wurden gleichzeitig beobachtet. Eine standortübergreifende `maxQrf`- oder gemeinsame Acceptance-QRF-Pool-Regel existiert nicht.

Bei Joyce wurde zusätzlich beobachtet, dass die RED-Testfixture so nahe an das lokale MOOSE-Warehouse kam, dass dessen eigene `under attack`-/Capture-Mechanik ausgelöst wurde. Diese Fixture-Positionierung testet einen unerwünschten Nebeneffekt und ist nicht Bestandteil des Alarm-Acceptance-Ziels.

Für Bostick beobachtete der Projektinhaber, dass lokale Artillerie die RED-Testbedrohung offenbar per Direct Fire neutralisierte, bevor eine QRF sichtbar wurde. Das wird als visuelle Diagnosehypothese festgehalten und noch nicht als vollständig log-korrelierter technischer Nachweis behandelt. Es zeigt zusätzlich, dass ein Test nicht davon ausgehen darf, dass jede RED-Fixture zwingend lange genug lebt oder zuerst den Guard bekämpft.

## RED-Testfixtures

Die sechs late-activated Gruppen bleiben reine Testfixtures:

```text
BadGuys_A3_FENTY
BadGuys_A3_FORTRESS
BadGuys_A3_JOYCE
BadGuys_A3_WRIGHT
BadGuys_A3_HONAKER
BadGuys_A3_BOSTICK
```

Sie sind keine produktive RED-ORBAT und kein späteres RED-C2-Modell. Die produktive RED-C2 soll feindliche Kräfte dynamisch auswählen, einsetzen und bewegen. Kein BLUE-Produktionsmodul darf von diesen Namen, Positionen oder ihrer Existenz abhängen.

## Korrigierter Acceptance-3-Zielaufbau

Acceptance 3 soll weiterhin möglichst alles in einem einzigen Six-Site-DCS-Lauf bündeln:

```text
6x Guard regression
+ 6x owner-defined runtime alarm/security/threat-zone intrusion
+ 6x MOOSE OPSZONE / proximity qualification
+ 6x PROXIMITY_INTRUSION
+ 6x authoritative installation incident
+ 6x exactly one initial local QRF demand
+ 6x MOOSE-recruited local QRF
+ 6x physical QRF execution
+ optional direct-fire / hit evidence refresh without duplicate demand
```

Die oben festgelegten standortbezogenen Alarmradien und Anker sind für diesen Acceptance-Scope die maßgebliche Geometrie. `ACCESS`, Guard-PATHLINE oder andere Testgeometrien dürfen nicht ersatzweise als Alarmgrenze verwendet werden.

## MOOSE-first

Der korrigierte Hauptpfad verwendet die bereits vorhandene MOOSE-first-Architektur:

```text
MOOSE ZONE_RADIUS
-> MOOSE OPSZONE
-> OMW_FobThreatOpsZoneAdapter
-> OMW_FireSupStratResupply_PerimeterBridge
-> PROXIMITY_INTRUSION
-> OMW_FireSupStratResupply_InstallationIncidentRuntime
-> OMW_GroundInstallationAttackIncident
-> OMW_FireSupStratResupply_InstallationIncidentBridge
-> Base
-> local QRF demand
-> MOOSE AUFTRAG / LEGION / BRIGADE recruitment
```

Physische `EVENTHANDLER`-/`WEAPON`-Evidence bleibt als zusätzliche Multi-Evidence-Quelle zulässig, ersetzt aber nicht die Proximity-/Triggerzonen-Erkennung.

## PASS-Kriterium

Der nächste Acceptance-3-Build muss mindestens nachweisen:

```text
6/6 Guards regression condition satisfied
6/6 owner-defined runtime alarm perimeters started
6/6 qualified proximity intrusions observed
6/6 authoritative installation incidents observed
6/6 exactly one initial QRF demand
6/6 local QRF mission observed
no duplicate QRF demand from evidence refresh
```

QRF-Bewegung und weitere physische Ausführungskriterien dürfen nur so festgelegt werden, dass die Testfixtures nicht unbeabsichtigt die MOOSE-Warehouse-Capture-Mechanik oder andere nicht zum Acceptance-Ziel gehörende Standortmechanismen provozieren.

## Noch nicht bewiesen

Ein späterer PASS validiert nicht automatisch:

- ARTY- oder CAS-Eskalation;
- Ground-/Air-Resupply;
- CampaignState Transport Settlement;
- produktive RED-C2;
- generische Mission-End-/Incident-Close-Logik.

## Aktueller Entscheidungsstand

```text
old Guard-only Acceptance-3 correlation: REJECTED
first two DCS runs: diagnostic evidence only
six-site alarm center/radius geometry: OWNER-DEFINED
additional Mission Editor alarm/trigger zones: NOT REQUIRED
Jalalabad center: OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT, not WH_BLUE_GND_FENTY
next action: verify Jalalabad anchor wrapper/type, wire owner-defined perimeters into the existing MOOSE OPSZONE path, rebuild Acceptance 3
```
