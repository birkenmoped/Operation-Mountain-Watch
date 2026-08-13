---
document_id: OMW-AIR-BAGRAM-F15E-CAS-STRIKE-PAYLOAD
status: BINDING
document_class: MISSION_EDITOR_PAYLOAD_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram F-15E CAS Mission Editor authoring payload
  - Bagram F-15E STRIKE Mission Editor authoring payload
  - Bagram F-15E shared air-to-air, tank and LANTIRN authoring equipment
  - Mission Editor task contract for TPL_AIR_US_BGRM_F15E_CAS_2SHIP
  - Mission Editor task contract for TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-EVIDENCE-BAGRAM-F15E-PAYLOAD-2026-08-01 on docs/bagram-air-operations-manifest
  - earlier F-15E CAS authoring seed with AGM-65K and four air-to-air missiles
  - earlier F-15E STRIKE authoring seed with Mk-82AIR mass load
superseded_by:
source_branch: agent/bagram-f15e-payload-main-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Bagram F-15E CAS-/STRIKE-Payloadentscheidung – 13.08.2026

## 1. Status und Evidenzgrenze

Dieses Dokument hält die vom Projektinhaber festgelegte Mission-Editor-Authoring-Baseline für die beiden Bagram-F-15E-Seeds fest.

Die beiden Seeds gehören zur selben logischen `SQ_US_BGRM_F15E_335_EFS`. Sie sind unterschiedliche Rollen-/Payload-Seeds derselben Staffel und erzeugen keinen zusätzlichen Flugzeugbestand.

Die Entscheidung ist gegen den aktuellen `main`-Stand reconciled. Bereits auf `main` technisch bestätigt sind:

- zwei F-15E-Role-Payload-Registrierungen innerhalb des insgesamt sieben Payloads umfassenden Bagram-Foundation-Vertrags;
- die exakten DCS/MOOSE-STORAGE-Mappings für `GBU-31(V)1/B` und `GBU-31(V)3/B`;
- der reale STORAGE-Abgang von jeweils zwei GBU-31(V)1/B und zwei GBU-31(V)3/B beim materialisierten F-15E-STRIKE-Two-Ship im dokumentierten Acceptance-Lauf vom 13.08.2026.

Noch nicht abgeschlossen sind:

- Audit der final gespeicherten aktuellen `.miz` für sämtliche Pylon-/Rack-/Pod-CLSIDs;
- vollständiger CAS-Seed-Audit der gespeicherten GBU-38-/GBU-54-Belegung;
- DCS-Acceptance der taktischen CAS- und STRIKE-Ausführung;
- Hot-and-high-Start-, Rückkehr- und AIRWING-Bestandsprüfung mit der finalen Missionsdatei;
- verbindliche Zünderbaseline. Zünderauswahl und Verzögerungen werden erst nach Audit der tatsächlich gespeicherten `.miz` dokumentiert.

Damit gilt die Payloadentscheidung als verbindliche Authoring-Baseline. `validated_in_dcs: partial` bezieht sich ausschließlich auf die bereits dokumentierten Foundation- und Store-Korrelationen, nicht auf die vollständige taktische Mission.

## 2. Gemeinsame F-15E-Ausstattung

Für beide Seeds gilt pro Luftfahrzeug:

```text
1 x AIM-120C
1 x AIM-9
2 x F-15E external fuel tank
1 x AN/AAQ-13 LANTIRN navigation pod
1 x AN/AAQ-14 LANTIRN targeting pod
internal M61A1 retained
```

Die Luft-Luft-Bewaffnung ist eine minimale Eventualbewaffnung. Aus ihr wird keine Taliban-Luftbedrohung abgeleitet.

Die aktuelle Warehouse-/Resource-Baseline auf `main` führt `AIM-120C`, AIM-9, F-15E external tanks sowie AAQ-13/AAQ-14 als die entsprechenden operativen beziehungsweise strategischen Store-/Equipment-IDs. Die genaue physische CLSID-Belegung beider Seeds wird dennoch erst aus der final gespeicherten `.miz` abgenommen.

## 3. CAS-Seed

Mission-Editor-Seed:

```text
Template: TPL_AIR_US_BGRM_F15E_CAS_2SHIP
Mission Editor task: CAS
Payload working name: OMW Standard CAS
```

Verbindliche Authoring-Beladung pro Luftfahrzeug:

```text
3 x GBU-38 JDAM
3 x GBU-54(V)1/B Laser JDAM
1 x AIM-120C
1 x AIM-9
2 x F-15E external fuel tank
1 x AN/AAQ-13 LANTIRN navigation pod
1 x AN/AAQ-14 LANTIRN targeting pod
internal M61A1
```

Die `3 + 3`-Mischung ist eine OMW-Missionsdesignentscheidung für einen flexiblen 500-lb-Präzisionsmix. Sie wird nicht als Behauptung dokumentiert, dass jede reale Bagram-F-15E jede CAS-Sortie exakt mit dieser Stückzahl flog.

Für DCS ist die Kombination zugleich eine saubere symmetrische CFT-Belegung. Eine zuvor diskutierte GBU-12-/GBU-38-Mischung wird nicht als Standard verwendet, weil die verfügbaren F-15E-CFT-Authoring-Optionen keine entsprechende symmetrische Drei-zu-Drei-Konfiguration mit GBU-12 bereitstellen.

## 4. STRIKE-Seed

Mission-Editor-Seed:

```text
Template: TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
Mission Editor task: Ground Attack / Bodenangriff
MOOSE mission type: AUFTRAG.Type.STRIKE
Payload working name: OMW Standard STRIKE
```

Verbindliche Authoring-Beladung pro Luftfahrzeug:

```text
1 x GBU-31(V)1/B
1 x GBU-31(V)3/B
1 x AIM-120C
1 x AIM-9
2 x F-15E external fuel tank
1 x AN/AAQ-13 LANTIRN navigation pod
1 x AN/AAQ-14 LANTIRN targeting pod
internal M61A1
```

Der Two-Ship führt damit insgesamt:

```text
2 x GBU-31(V)1/B
2 x GBU-31(V)3/B
```

Der Mix trennt einen schweren General-Purpose-JDAM-Anteil und einen Penetrator-JDAM-Anteil für einen vorbereiteten Strike-Zielkomplex. Die Auswahl bleibt den projektweiten Targeting-, ROE- und No-Strike-Regeln untergeordnet und ist nicht als Default gegen gewöhnliche Gebäude in bewohntem Gebiet zu verstehen.

Der Acceptance-Lauf vom 13.08.2026 hat für den materialisierten Two-Ship genau die folgenden STORAGE-Abgänge beobachtet:

```text
weapons.bombs.GBU_31       100 -> 98  delta -2
weapons.bombs.GBU_31_V_3B  100 -> 98  delta -2
```

Damit ist die `1 + 1`-Beladung je Luftfahrzeug für den exakt dokumentierten Teststand materiell korreliert. Der Lauf validiert dadurch nicht automatisch Zielwahl, Waffenwirkung oder taktische STRIKE-Ausführung.

## 5. MOOSE-Task-Zuordnung

Für den tatsächlich gepinnten MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

ist im verwendeten `Moose.lua` festgelegt:

```text
AUFTRAG.Type.CAS
-> ENUMS.MissionTask.CAS

AUFTRAG.Type.STRIKE
-> ENUMS.MissionTask.GROUNDATTACK
-> DCS/ME Ground Attack / Bodenangriff
```

`Pinpoint Strike / Präzisionsangriff` ist ein separater DCS-Mission-Task und nicht die von `AUFTRAG.Type.STRIKE` verwendete Zuordnung dieses MOOSE-Stands.

Folglich bleibt der STRIKE-Seed im Mission Editor auf:

```text
Bodenangriff / Ground Attack
```

## 6. Bereits bestätigte Resource-/STORAGE-Zuordnung

Für den aktuellen Warehouse-/Resource-Foundation-Stand gelten unter anderem:

```text
AMMUNITION_AIM120   -> weapons.missiles.AIM_120C
AMMUNITION_AIM9     -> weapons.missiles.AIM_9
AMMUNITION_GBU38    -> weapons.bombs.GBU_38
AMMUNITION_GBU54    -> weapons.bombs.GBU_54_V_1B
AMMUNITION_GBU31_V1 -> weapons.bombs.GBU_31
AMMUNITION_GBU31_V3 -> weapons.bombs.GBU_31_V_3B
EQUIPMENT_AAQ13     -> F-15E AAQ-13 LANTIRN equipment mapping
EQUIPMENT_AAQ14     -> F-15E AAQ-14 LANTIRN equipment mapping
```

Die Resource-IDs und strategischen Bestandsregeln bleiben ausschließlich in der Warehouse-/Resource-Foundation autoritativ. Dieses Dokument definiert keine zweite Ressourcenhoheit.

## 7. Noch erforderliche `.miz`- und DCS-Acceptance

Vor einer vollständigen Payload-/Taktik-Acceptance sind mindestens nachzuweisen:

```text
final saved .miz extraction
both aircraft in each two-ship have identical intended payloads
exact rack/store/pod CLSIDs
CAS seed contains 3 x GBU-38 + 3 x GBU-54 per aircraft
STRIKE seed contains 1 x GBU-31(V)1/B + 1 x GBU-31(V)3/B per aircraft
STRIKE Mission Editor task is Ground Attack / Bodenangriff
CAS AUFTRAG selects the CAS role payload
STRIKE AUFTRAG selects the STRIKE role payload
representative Bagram hot-and-high takeoff succeeds
AI employs only valid stores against the intended target class
safe return restores the correct logical AIRWING inventory
no spontaneous activation of Late Activation authoring seeds
no relevant Lua, payload, pylon, parking or tasking error
```

Zündereinstellungen werden bewusst nicht als verbindlich aufgeführt, bevor sie aus dem final gespeicherten Mission-Editor-Stand extrahiert und bewertet wurden.
