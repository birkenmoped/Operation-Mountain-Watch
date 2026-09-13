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
+ 6x site-specific alarm/security/threat-zone intrusion
+ 6x MOOSE OPSZONE / proximity qualification
+ 6x PROXIMITY_INTRUSION
+ 6x authoritative installation incident
+ 6x exactly one initial local QRF demand
+ 6x MOOSE-recruited local QRF
+ 6x physical QRF execution
+ optional direct-fire / hit evidence refresh without duplicate demand
```

Die konkrete Alarmzonen-Geometrie darf je Installation variieren. Die alten Stage-3-Testkreise dürfen nicht stillschweigend auf alle sechs Standorte generalisiert werden. Vor dem nächsten Acceptance-3-Build ist deshalb die aktuelle Mission-Editor-/Baseline-Evidenz für die sechs standortbezogenen Alarmzonen zu prüfen. Fehlende Geometrie muss vom Projektinhaber festgelegt werden; sie darf nicht aus Warehouse, ACCESS oder Guard-PATHLINE geraten werden.

## MOOSE-first

Der korrigierte Hauptpfad verwendet die bereits vorhandene MOOSE-first-Architektur:

```text
MOOSE OPSZONE
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

## PASS-Kriterium – neu zu finalisieren

Das endgültige PASS-Kriterium wird nach Prüfung beziehungsweise Festlegung der sechs autoritativen Alarmzonen-Geometrien finalisiert. Mindestens muss es nachweisen:

```text
6/6 Guards regression condition satisfied
6/6 qualified proximity intrusions observed
6/6 authoritative installation incidents observed
6/6 exactly one initial QRF demand
6/6 local QRF mission observed
no duplicate QRF demand from evidence refresh
```

QRF-Bewegung und weitere physische Ausführungskriterien werden nur mit belastbarer, standortbezogener Testgeometrie festgelegt.

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
six-site alarm acceptance: OPEN
next action: recover/verify authoritative site alarm-zone geometry before rebuilding Acceptance 3
```
