---
document_id: OMW-AIR-BAGRAM-F16C-CAS-PAYLOAD
status: BINDING
document_class: MISSION_EDITOR_PAYLOAD_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram F-16C CAS historical payload working interpretation
  - Bagram F-16C CAS Vanilla-DCS substitution baseline
  - Bagram F-16C outer-wing air-to-air and clean-station configuration
  - Mission Editor payload contract for TPL_AIR_US_BGRM_F16C_CAS_2SHIP
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-EVIDENCE-BAGRAM-F16C-CAS-PAYLOAD-2026-08-01 on docs/bagram-air-operations-manifest
  - earlier proposed four-air-to-air-missile F-16C CAS configuration
  - earlier unqualified proposal of a historically exact GBU-12 and GBU-38 mix
superseded_by:
source_branch: agent/bagram-f16c-cas-payload-main-reconciliation
source_commit: 06ffb7a1d351d85d3afed3ae842b0ce414c9cb0c
validated_in_dcs: false
---

# Bagram F-16C CAS Payload Decision – 13.08.2026

## 1. Status und Evidenzgrenze

Dieses Dokument hält die vom Projektinhaber am 13.08.2026 bestätigte Arbeitsbaseline für das Bagram-F-16C-CAS-Template fest.

Die Entscheidung trennt ausdrücklich:

1. das durch zeitgenössische Bagram-Fotos gestützte historische Sollbild;
2. die tatsächliche Fähigkeit des realen GBU-38-/GBU-54-Loadouts;
3. die funktionsorientierte Ersatzkonfiguration der unmodifizierten DCS-F-16C Block 50.

Im Arbeitsstand ausgewertet wurden insbesondere die bereitgestellten zeitgenössischen Aufnahmen:

```text
110309-F-XA488-095.jpg
110309-F-XA488-120.jpg
110309-F-XA488-141.jpg
110715-F-DE377-002.jpg
```

Die Fotos sind keine offiziellen Load Sheets. Die Identifikation der beiden JDAM-Familienvarianten ist deshalb eine bindende OMW-Arbeitsinterpretation für das Missionsdesign und keine Behauptung, dass jedes reale Flugzeug auf jeder Sortie identisch beladen war.

Noch nicht abgeschlossen sind:

- finale `.miz`-Extraktion und vollständiger CLSID-Audit;
- DCS-Außenmodellprüfung der leeren Stationen 2 und 8;
- DCS-Runtime-Test des KI-Einsatzes von GBU-38 und GBU-12;
- Verifikation der genauen AIM-120-Untervariante und des Targeting-Pod-CLSIDs;
- Take-off-, Rückkehr- und AIRWING-Bestandsprüfung.

Die Entscheidung ist damit eine verbindliche Mission-Editor-Authoring-Baseline, aber keine DCS-Runtime-Acceptance.

## 2. Historisches 2011-Sollbild

Die ausgewerteten Bagram-Aufnahmen stützen als OMW-Arbeitsinterpretation pro Flugzeug:

```text
2 x GBU-38 JDAM
2 x GBU-54 Laser JDAM
2 x 370-gal external fuel tank
2 x AIM-120 on the wingtip stations
Targeting pod
internal M61A1
```

Für die Bombenstationen wird folgende historische Arbeitsinterpretation festgehalten:

```text
Station 3:
  BRU-57
  1 x GBU-38
  1 x GBU-54

Station 7:
  BRU-57
  1 x GBU-38
  1 x GBU-54
```

Die Identifikation beruht auf den sichtbaren JDAM-Familienkörpern und den unterschiedlichen Nasen-/Suchkopfmerkmalen. Ein veröffentlichtes stationsweises Load Sheet liegt für diese konkrete Bildserie nicht vor.

Die reale Fähigkeitsmenge war damit:

```text
4 x GPS/INS-capable 500-lb precision weapon
2 of those weapons additionally laser-capable
2 x moving or relocating target capability through laser guidance
0 weapons requiring laser designation for ordinary fixed-coordinate employment
```

Die GBU-54 ist eine Dual-Mode-Waffe und darf nicht als funktional identisch mit einer reinen GBU-12 dokumentiert werden.

## 3. Außenstationen und Luft-Luft-Bewaffnung

Die Bagram-CAS-Arbeitsbaseline verwendet:

```text
Station 1: AIM-120
Station 2: clean
Station 8: clean
Station 9: AIM-120
```

`Clean` bedeutet für die beabsichtigte Außenkonfiguration:

```text
no AIM-9
no additional AIM-120
no LAU-129 launcher or underwing missile adapter intended on station 2 or 8
```

Die Wingtip-AIM-120 bleiben als fotografisch gestützte und für die F-16 normale Außenkonfiguration erhalten. Daraus wird keine gegnerische Luftbedrohung im COIN-Szenario abgeleitet.

Zusätzliche AIM-9 auf Station 2 und 8 gehören nicht zum OMW-Bagram-Standard-CAS-Loadout. Die ausgewerteten Fotos liefern dafür keinen ausreichenden Nachweis.

Da DCS die gerenderte Außenhardware kontrolliert, muss im finalen Missionsstand visuell geprüft werden, ob leere Stationen 2 und 8 tatsächlich ohne unbeabsichtigten Launcher oder Pylon dargestellt werden.

## 4. DCS-Abbildungsgrenze

Die in OMW verwendete native DCS-F-16C Block 50 kann das historische Sollbild nicht exakt reproduzieren:

```text
GBU-54 is not available on the current OMW DCS F-16C representation.
A mixed GBU-38 and GBU-54 pair on one BRU-57 is therefore unavailable.
A GBU-38 and GBU-12 mixed pair on one BRU-57 is not used as a DCS carriage solution.
GBU-38 uses paired BRU-57 carriage in the selected authoring baseline.
GBU-12 uses paired TER-9A carriage in the selected authoring baseline.
```

Eine gleichzeitig optisch, stationsbezogen und funktional exakte Reproduktion ist deshalb in der unmodifizierten OMW-DCS-Baseline nicht möglich.

## 5. Verbindlicher Vanilla-DCS-Funktionsersatz

Mission-Editor-Authoring-Seed:

```text
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
Mission Editor task: CAS
Payload working name: OMW F-16 CAS Functional GBU-54 Substitute
```

Verbindliche Arbeitsbeladung pro Luftfahrzeug:

```text
Station 1: 1 x AIM-120
Station 2: clean
Station 3: BRU-57 with 2 x GBU-38
Station 4: 370-gal external fuel tank
Station 5R: targeting pod; exact type and CLSID to be audited
Station 6: 370-gal external fuel tank
Station 7: TER-9A with 2 x GBU-12
Station 8: clean
Station 9: 1 x AIM-120
Internal: M61A1
```

Die seitliche Zuordnung `Station 3 = GBU-38` und `Station 7 = GBU-12` ist die aktuelle Authoring-Baseline. Eine Spiegelung wäre keine neue Payloadfamilie, müsste aber im finalen `.miz`-Audit dokumentiert und für beide Flugzeuge des Two-Ship-Seeds identisch umgesetzt werden.

Im Standard-CAS-Loadout werden keine AIM-9 mitgeführt.

Ein ECM-Pod wird durch diese Entscheidung nicht vorausgesetzt. Eine solche Ausstattung benötigt einen separaten Nachweis oder eine eigene Projektentscheidung.

## 6. Zweck und Grenzen des Funktionsersatzes

Der DCS-Ersatz erhält folgende taktische Auswahlmöglichkeit:

```text
2 x GPS/INS weapon for fixed-coordinate targets and adverse visibility
2 x laser-guided weapon for self-, JTAC- or buddy-lased targets
4 x total 500-lb precision weapons
```

Er bildet die reale GBU-54-Flexibilität nicht vollständig ab:

| Fähigkeit | Historische Arbeitsinterpretation | DCS-Ersatz |
|---|---:|---:|
| 500-lb-Präzisionswaffen gesamt | 4 | 4 |
| GPS/INS-fähig | 4 | 2 |
| laserfähig | 2 | 2 |
| Dual-Mode | 2 | 0 |
| ohne Laser einsetzbar | 4 | 2 |
| Laser zwingend erforderlich | 0 | 2 |
| Laseroption gegen bewegliche/verlagernde Ziele | 2 | 2 |

Die GBU-12 ist damit ausschließlich ein funktionaler Ersatz für die Laserfähigkeit der nicht verfügbaren GBU-54. Sie wird nicht als fotografisch bestätigte 2011-Standardwaffe der ausgewerteten Bagram-F-16 dargestellt.

## 7. Nicht gewählte Standardalternativen

### 7.1 Vier Luft-Luft-Lenkwaffen

Nicht als Bagram-CAS-Standard festgelegt:

```text
2 x wingtip AIM-120
2 x AIM-9 on stations 2 and 8
```

Die zusätzlichen Heater sind für die dokumentierte COIN-CAS-Aufgabe nicht erforderlich und durch die ausgewertete Standardload-Evidenz nicht ausreichend gestützt.

### 7.2 Vier GBU-38

```text
4 x GBU-38 on two BRU-57
```

Diese Variante wäre optisch und hinsichtlich der JDAM-Trägerfamilie näher am historischen Bild und würde vier GPS-fähige Waffen erhalten. Sie würde jedoch die Laseroption der realen GBU-54 vollständig verlieren.

Sie ist daher nicht der universelle OMW-CAS-Standard. Sie kann später als Fixed-Coordinate-/Adverse-Weather-Preset betrachtet werden, ohne automatisch ein zweites KI-Template zu rechtfertigen.

### 7.3 GBU-12/GBU-38 als historisch exakt beschreiben

Verworfen. `2 x GBU-38 + 2 x GBU-12` ist ausdrücklich ein DCS-Funktionsersatz und darf nicht als exakte historische Außenlast der fotografierten 2011-Konfiguration beschrieben werden.

## 8. Mission-Editor- und Runtime-Vertrag

Der finale F-16C-CAS-Seed muss mindestens erfüllen:

```text
exactly 2 aircraft in the authoring seed
Late Activation enabled
Uncontrolled disabled
Mission Editor task CAS
both aircraft have identical payloads
stations 2 and 8 empty
no AIM-9 carried
2 x GBU-38 on one BRU-57
2 x GBU-12 on one TER-9A
2 x external fuel tank
2 x wingtip AIM-120
targeting pod installed
```

Die exakten Weapon-, Rack-, Missile-, Tank- und Targeting-Pod-CLSIDs sind aus der final gespeicherten `.miz` zu extrahieren; Mission-Editor-Bezeichnungen allein gelten nicht als Nachweis.

AIRWING und SQUADRON dürfen das Template nur als Payload-/Spawn-Seed verwenden. Die zwei Template-Flugzeuge erhöhen den logischen Bestand nicht.

## 9. Noch erforderliche Acceptance

Vor einer Runtime-Acceptance sind mindestens folgende Punkte nachzuweisen:

```text
final .miz extraction and complete CLSID audit
both aircraft have identical rack and store assignments
station 2 and station 8 render clean without unintended launchers
wingtip missiles render and identify as the intended AIM-120 variant
targeting-pod type and station are confirmed
CAS AUFTRAG selects the F-16C CAS payload
AI can employ GBU-38 against a valid coordinate target
AI can employ GBU-12 with valid laser support
AI does not attempt invalid weapon use against unsupported target types
representative Bagram hot-and-high takeoff succeeds
safe landing and return restore the correct logical inventory
no spontaneous activation of the Late Activation template
no relevant Lua, payload, pylon, parking or tasking error
```
