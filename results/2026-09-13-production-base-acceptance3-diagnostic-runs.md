---
document_id: OMW-FSSR-PRODUCTION-BASE-ACCEPTANCE-3-DIAGNOSTIC-RUNS
status: HISTORICAL_TEST_FIXTURE
document_class: ACCEPTANCE_DIAGNOSTIC_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - diagnosis of the first two Production Base Acceptance 3 DCS runs
  - rejection of Guard-only event correlation for installation alarm acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Acceptance 3 – Diagnose der ersten zwei DCS-Läufe

## Getesteter Artefaktstand

```text
Git commit: e5773c9956fadfeb9b95684d9aafaee3e519885a
Production bundle SHA-256: 10345F95F1BEAA9EE170D4E188176C91F102DE0550119E990EBCDEC535BC507E
Acceptance bundle SHA-256: 85188B19EEB71ADFA793DDB9D69B73B55C49143FC0CA4E5373C42241FC1A902E
DCS: 2.9.29.27468
MOOSE: 2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Die Mission war eine Arbeitskopie von `OMW_Template_v24_GroundWorks_base.miz` mit sechs late-activated `BadGuys_A3_*`-Gruppen. Für diese Diagnose wurde kein Acceptance-tauglicher Missionshash festgeschrieben. Die Läufe sind deshalb ausdrücklich kein `ACCEPTED_TECHNICAL_BASELINE`.

## Ergebnis

Die sechs Guards liefen an. Incidents und QRFs entstanden jedoch nur an wechselnden Teilmengen der Standorte. Im ersten Lauf wurden unter anderem Wright und Fortress mit QRF beobachtet; im zweiten Lauf unter anderem Joyce und Wright. Mehrere QRFs konnten gleichzeitig existieren.

Der Acceptance-Harness enthält keine globale QRF-Obergrenze. Er baut pro Standort eine eigene BRIGADE mit einem eigenen QRF-PLATOON auf. Das wechselnde Muster ist daher nicht durch eine globale `maxQrf`-Regel erklärbar.

## Gefundener Testdesignfehler

Die erste Acceptance-3-Fassung ordnete physische Kampfereignisse nur dann einer Site zu, wenn das BLUE-Ziel exakt zum lokalen Guard gehörte:

```lua
targetInAlarmZone=function(target)
  return targetBelongsToGuard(d.id,target)
end
```

Dadurch konnte realer Kampf gegen andere BLUE-Kräfte oder Installationselemente ohne Incident bleiben. Diese Guard-only-Korrelation ist als Zielmodell verworfen.

Verbindlich bleibt die bereits beschlossene Installationssemantik:

```text
hostile penetration of site-specific alarm/security/threat zone
-> PROXIMITY_INTRUSION
-> installation attack incident
-> response orchestration
```

Direct Fire, Indirect Fire und confirmed Hit sind zusätzliche Evidence-Kanäle und dürfen denselben Incident erzeugen oder refreshen. Sie ersetzen die standortbezogene Proximity-Erkennung nicht.

## Joyce

Bei Joyce meldete die lokale MOOSE-BRIGADE/Warehouse-Schicht `We are under attack!`. Im ersten Lauf konnte die RED-Testfixture außerdem so nahe an das Warehouse gelangen, dass dessen Capture-Mechanik ausgelöst wurde. Diese Fixture-Positionierung ist für Acceptance 3 unerwünscht und kein Bestandteil des Alarmtests.

## Bostick

Der Projektinhaber beobachtete im zweiten Lauf, dass lokale Artillerie die RED-Bedrohung offenbar per Direct Fire neutralisierte, bevor eine QRF sichtbar wurde. Diese Beobachtung wird als visuelle Diagnosehypothese dokumentiert und nicht als bereits vollständig log-korrelierter technischer Nachweis gewertet.

Sie unterstreicht, dass fehlende sichtbare QRF nicht automatisch einen QRF-Systemfehler bedeutet: Eine Bedrohung kann bereits lokal beseitigt worden sein. Alarmdetektion und spätere Response-Disposition sind getrennt zu bewerten.

## Testfixtures

`BadGuys_A3_FENTY`, `BadGuys_A3_FORTRESS`, `BadGuys_A3_JOYCE`, `BadGuys_A3_WRIGHT`, `BadGuys_A3_HONAKER` und `BadGuys_A3_BOSTICK` bleiben reine Testfixtures. Sie sind weder produktive RED-ORBAT noch produktive RED-C2. Die spätere RED-C2 soll Gegner dynamisch einsetzen und bewegen.

## Konsequenz

Der bisherige Acceptance-3-Harness darf nicht erneut als Zielmodell verwendet werden. Der nächste Aufbau muss den vorhandenen MOOSE-first-Pfad verwenden:

```text
site-specific alarm zone
-> MOOSE OPSZONE
-> PerimeterBridge
-> PROXIMITY_INTRUSION
-> InstallationIncidentRuntime
-> one authoritative incident
-> exactly one initial local QRF demand
-> MOOSE recruitment / execution
```

Weitere physische Evidence darf denselben Incident refreshen, ohne einen zweiten initialen QRF-Demand zu erzeugen.

`ACCESS`, Warehouse-Position und Guard-PATHLINE sind keine Alarmgeometrie. Alte Stage-3-Testgeometrien dürfen nicht stillschweigend auf alle sechs Standorte generalisiert werden. Vor dem nächsten Build müssen die autoritativen standortbezogenen Alarmzonen aus der aktuellen Mission-Editor-/Baseline-Evidenz wiederhergestellt oder vom Projektinhaber festgelegt werden.
