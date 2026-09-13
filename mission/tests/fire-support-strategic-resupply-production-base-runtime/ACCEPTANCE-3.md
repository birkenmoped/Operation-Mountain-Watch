---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3
status: STAGED
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
source_commit: PENDING_LOCAL_BUILD
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

`ACCESS`, Warehouse-Grenzen und Guard-PATHLINE sind keine Alarmgeometrie. Die Warehouse-Koordinate wird an fünf Sites ausschließlich als stabiler Mittelpunkt verwendet.

## Vom Projektinhaber festgelegte Six-Site-Alarmgeometrie

Für Acceptance 3 und die daraus abzuleitende Produktionskonfiguration gilt die folgende ausdrücklich festgelegte Geometrie. Es werden **keine zusätzlichen Mission-Editor-Trigger-/Alarmzonen** angelegt.

Für Fortress, Joyce, Wright, Honaker und Bostick ist das jeweils bereits vorhandene MOOSE-Warehouse der Standortmittelpunkt. Daraus wird zur Laufzeit `MOOSE ZONE_RADIUS -> MOOSE OPSZONE` erzeugt. Jalalabad ist eine ausdrückliche Ausnahme: Dort wird **nicht** das Warehouse von FOB Fenty als Mittelpunkt verwendet, sondern die bereits vorhandene Missionszone `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT` direkt als MOOSE-Zone an `OPSZONE` übergeben.

| Site | Alarmanker | Radius ft | Radius m |
|---|---|---:|---:|
| `JALALABAD_FENTY` | `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT` | 6000 | 1828.8 |
| `COP_FORTRESS` | `WH_BLUE_GND_FORTRESS` | 5000 | 1524.0 |
| `FOB_JOYCE` | `WH_BLUE_GND_JOYCE` | 9000 | 2743.2 |
| `FOB_WRIGHT` | `WH_BLUE_GND_WRIGHT` | 4000 | 1219.2 |
| `COP_HONAKER` | `WH_BLUE_GND_HONAKER` | 9000 | 2743.2 |
| `FOB_BOSTICK` | `WH_BLUE_GND_BOSTICK` | 5000 | 1524.0 |

Umrechnung: `1 ft = 0.3048 m` exakt.

Die fünf Warehouse-Anker dienen ausschließlich als stabile geografische Mittelpunkte der Alarmperimeter. Daraus entsteht **keine** zusätzliche Ressourcen- oder Alarmhoheit des Warehouses. Die Jalalabad-Ausnahme bildet bewusst den gesamten Flughafen-/Installationskontext statt nur FOB Fenty ab.

Diese Geometrie liegt nun zusätzlich im produktiven `OMW_FireSupStratResupply_SiteRegistry`-Vertrag. Die Laufzeitauflösung bleibt MOOSE-first und wird nicht durch native DCS-Suche dupliziert.

## Verifikation des Jalalabad-Ankers und der MOOSE-Pfade

Die vom Projektinhaber bereitgestellte Missionskopie `OMW_Template_v24_GroundWorks_base(5).miz` wurde read-only geprüft. SHA-256 der hier tatsächlich geprüften Upload-Datei:

```text
4633EF44FF662A0426A8F4ADBB7A535F22F2CEC45559271EF8692C9CB4FC0289
```

Dieser Hash ist **nur Artefaktprovenienz der hochgeladenen Inspektionskopie**, kein lokaler Build-/Acceptance-Hash und kein DCS-PASS.

In dieser `.miz` ist `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT` als vorhandene kreisförmige Mission-Editor-Zone mit `radius=1828.8 m` vorhanden. Damit entspricht die existierende Jalalabad-Zone exakt den festgelegten 6000 ft.

Im tatsächlich gepinnten `Moose.lua` wurden die für den korrigierten Pfad verwendeten öffentlichen Methoden geprüft:

```text
ZONE:FindByName(name)
ZONE_BASE:GetCoordinate()
WAREHOUSE:GetCoordinate()
CONTROLLABLE:RouteGroundTo(ToCoordinate, Speed, Formation, DelaySeconds, ...)
COORDINATE:GetIntermediateCoordinate(ToCoordinate, Fraction)
```

`BRIGADE` erbt den WAREHOUSE-/LEGION-Pfad und stellt damit für die fünf Warehouse-basierten Sites die öffentliche Warehouse-Koordinate bereit. Die vorhandene Jalalabad-Zone wird per `ZONE:FindByName(...)` aufgelöst und direkt als Security-Zone an den bestehenden `OPSZONE`-Adapter weitergereicht. Es wird keine zweite Jalalabad-`ZONE_RADIUS` darüber erzeugt.

## RED-Testfixtures und physische Intrusion

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

Die aktuelle `.miz` positioniert nicht alle sechs Fixtures bereits innerhalb der nun festgelegten Alarmradien. Der Acceptance-Harness teleportiert oder respawnt sie deshalb **nicht**. Nach erfolgreicher Six-Guard-Regression aktiviert er die vorhandenen Fixtures und routet sie physisch mit der öffentlichen MOOSE-`CONTROLLABLE:RouteGroundTo(...)`-Methode auf einen Punkt bei 65 % des jeweiligen Alarmradius. Der Zielpunkt wird mit `COORDINATE:GetIntermediateCoordinate(...)` auf der Linie vom Alarmmittelpunkt zur tatsächlichen Fixture-Startkoordinate gebildet.

Damit bleibt die Prüfkette beobachtbar:

```text
late-activated RED fixture
-> physical MOOSE ground route
-> owner-defined installation perimeter penetration
-> MOOSE OPSZONE qualification
-> PROXIMITY_INTRUSION
-> installation incident
-> local QRF
```

Die Fixture-Route ist Acceptance-Logik, keine produktive RED-C2-Implementierung.

## Diagnose aus den ersten zwei Läufen

Die Guard-Regression lief an allen sechs Standorten an. Die Auswahl der Standorte, an denen ein Incident und anschließend eine QRF entstand, wechselte zwischen den Läufen. Unter anderem wurden im ersten Lauf Wright und Fortress, im zweiten Lauf unter anderem Joyce und Wright mit Incident/QRF beobachtet.

Dieses wechselnde Muster ist mit der verworfenen Guard-only Event-Korrelation erklärbar: Je nachdem, welches BLUE-Ziel eine RED-Testgruppe zuerst bekämpfte, konnte der Acceptance-Filter ein reales Kampfereignis akzeptieren oder verwerfen.

Der Harness enthält **keine globale QRF-Obergrenze**. Pro Site wird eine eigene BRIGADE mit eigenem QRF-PLATOON aufgebaut. Mehrere QRFs wurden gleichzeitig beobachtet. Eine standortübergreifende `maxQrf`- oder gemeinsame Acceptance-QRF-Pool-Regel existiert nicht.

Bei Joyce wurde zusätzlich beobachtet, dass die RED-Testfixture so nahe an das lokale MOOSE-Warehouse kam, dass dessen eigene `under attack`-/Capture-Mechanik ausgelöst wurde. Die korrigierte Acceptance routet nicht zum Warehouse-Zentrum, sondern nur auf 65 % des Alarmradius auf der vorhandenen Radiallinie. Ob damit alle lokalen Ground-AI-/Warehouse-Nebeneffekte vermieden werden, ist ausschließlich im realen DCS-Lauf zu bewerten.

Für Bostick beobachtete der Projektinhaber, dass lokale Artillerie die RED-Testbedrohung offenbar per Direct Fire neutralisierte, bevor eine QRF sichtbar wurde. Das bleibt eine Diagnosehypothese; der neue Lauf muss zeigen, ob das Fixture lange genug für die geforderte Proximity-/QRF-Kette lebt.

## Korrigierter Acceptance-3-Zielaufbau

Acceptance 3 bündelt weiterhin möglichst alles in einem einzigen Six-Site-DCS-Lauf:

```text
6x Guard regression
+ 6x owner-defined installation alarm/security/threat perimeters started
+ 6x physical RED fixture intrusion attempts
+ 6x MOOSE OPSZONE / proximity qualification
+ 6x PROXIMITY_INTRUSION evidence observed
+ 6x authoritative installation incident
+ 6x exactly one initial local QRF demand
+ 6x MOOSE-recruited local QRF
+ 6x physical QRF execution
```

Direct-Fire-/Hit-Evidence bleibt ein zusätzlicher Multi-Evidence-Kanal, ist aber nicht Voraussetzung dieses korrigierten Proximity-Hauptlaufs. Der bereits validierte Incident-Refresh-Vertrag darf dabei nicht regressieren; Acceptance 3 erzeugt jedoch keine künstliche direkte Evidence-Injektion.

## MOOSE-first

Der korrigierte Hauptpfad verwendet die bereits vorhandene MOOSE-first-Architektur:

```text
Fortress/Joyce/Wright/Honaker/Bostick:
MOOSE WAREHOUSE/BRIGADE:GetCoordinate()
-> MOOSE ZONE_RADIUS
-> MOOSE OPSZONE

Jalalabad:
MOOSE ZONE:FindByName("OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT")
-> existing MOOSE zone
-> MOOSE OPSZONE

both:
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

Physische `EVENTHANDLER`-/`WEAPON`-Evidence bleibt als zusätzliche Multi-Evidence-Quelle zulässig, ersetzt aber nicht die Proximity-/Installationszonenerkennung.

## PASS-Kriterium

Der Acceptance-3-Lauf muss mindestens nachweisen:

```text
6/6 Guards regression condition satisfied
6/6 owner-defined MOOSE alarm perimeters started
6/6 PROXIMITY_INTRUSION evidence observed
6/6 authoritative installation incidents observed
6/6 exactly one initial QRF demand
6/6 local Ground_APC QRF mission observed
6/6 local QRF physical progress >=25 m toward the incident coordinate
```

Ein Build allein ist kein PASS. `VALIDATED` beziehungsweise `ACCEPTED_TECHNICAL_BASELINE` darf erst nach dem dokumentierten realen DCS-Lauf und dessen exakter Provenienz vergeben werden.

## Noch nicht bewiesen

Ein späterer PASS validiert nicht automatisch:

- ARTY- oder CAS-Eskalation;
- Ground-/Air-Resupply;
- CampaignState Transport Settlement;
- produktive RED-C2;
- generische Mission-End-/Incident-Close-Logik;
- Direct-/Indirect-Fire- oder Hit-Evidence im selben A3-Lauf.

## Aktueller Stand

```text
old Guard-only Acceptance-3 correlation: REJECTED
first two DCS runs: diagnostic evidence only
six-site alarm center/radius geometry: OWNER-DEFINED
additional Mission Editor alarm/trigger zones: NOT REQUIRED
Jalalabad zone: existing OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT, 6000 ft
five other centers: existing MOOSE Warehouse/BRIGADE coordinates
corrected perimeter/QRF harness: STAGED
local build/hash verification: PENDING
real DCS Acceptance-3 run: PENDING
```
