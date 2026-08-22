---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-FAIL-3
status: TEST_RESULT
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact observed DCS result of Stage-1A Ground AMMO RESUPPLY protected-convoy runtime attempt 3 on 2026-08-22
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground AMMO RESUPPLY Acceptance 1 – Lauf 3 – FAIL am Return-Timing

## 1. Provenienz

```text
TestId: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
Mission path from debrief: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v18.miz
MIZ SHA-256 for this post-save revision: NOT CAPTURED / NOT CLAIMED
DCS: 2.9.28.26385
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Ground production bundle expected from prior verified v18 baseline: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
Acceptance build Git HEAD: 0c082407c6d35f094037ecdf118f84c29bacf2bc
Acceptance builder: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-4
Owner-built Acceptance bundle SHA-256: 3B42E2D3B302B489BBB567B2DC4AD6DEA393C0867ECE73C8107F856A1E016854
Repository documentation HEAD pulled before Mission Editor work: 130ca3f8a459fba780b8447989325472211c3606
```

Hinweis zur MIZ-Provenienz: Der Lauf wurde laut `debrief.log` aus `OMW_Template_v18.miz` gestartet. Für diese nach dem Acceptance-Ressourcenaustausch gespeicherte Revision wurde vor dem Lauf kein neuer MIZ-/internal-mission-Hash ermittelt. Deshalb wird kein exakter MIZ-Hash behauptet. Das Runtime-Verhalten bestätigt jedoch den geschützten `TPL_BLUE_CONVOY_LIGHT_06`-Pfad und die getrennte Return-Timeout-Logik des Builds `1-4`.

Owner returned:

```text
dcs(20260822-175844).log
debrief(20260822-175844).log
```

## 2. Ergebnis

```text
Classification: FAIL
Physical template TPL_BLUE_CONVOY_LIGHT_06: PASS
Protected six-vehicle materialization: PASS
AMMOSUPPLY outbound execution: PASS
Honaker destination-zone proof: PASS
CampaignState DELIVERED: PASS
MissionDemand SUCCESS: PASS
RTZ FSM accepted: PASS
Physical departure from Honaker after RTZ: FAIL / not observed
Returned event: FAIL / not reached
Warehouse AddAsset: FAIL / not reached
Final roundtrip PASS: NO
```

Owner visual observation:

```text
The complete convoy remained at the Honaker resupply location and did not begin the return trip.
```

## 3. Relevante Runtime-Marker

```text
17:56:12.192 DELIVERY_CONFIRMED ... destination=GROUND_NODE_HONAKER quantity=20 ... demandStatus=SUCCESS
17:56:12.329 MISSION_DONE deliveryCommitted=true
17:56:12.576 RETURN_RTZ_ACTIVE
17:56:12.576 RETURN_RTZ_ISSUED ... zone=ZON_BLUE_GND_JOYCE_ACCESS formation=OnRoad
17:56:13.110 AUFTRAG ... Mission 3 [Ammo Supply] success!
17:56:53.062 FAIL reason=RETURN_TIMEOUT seconds=1800 returnedCount=0 addAssetCount=0
```

Die stark verkürzte Differenz zwischen Wall-clock-Logzeit und `seconds=1800` entsteht durch die beschleunigte Missionszeit und ändert die Acceptance-Aussage nicht: der Return-Timeout wurde vollständig erreicht.

## 4. Root-Cause-Reconciliation mit bereits erfolgreicher OMW-Acceptance

Der aktuelle Harness löste RTZ nur zwei Sekunden nach `MissionDone` aus:

```text
MissionDone
-> 2 s delay
-> ARMYGROUP:RTZ(...)
```

Der tatsächliche DCS-Log zeigt, dass die AUFTRAG-Abschlussauswertung **nach** dem bereits akzeptierten RTZ noch lief:

```text
RTZ issued:      17:56:12.576
AUFTRAG success: 17:56:13.110
```

Damit liegt eine Lifecycle-Überlappung zwischen dem neuen RTZ-Wegpunkt und dem noch abschließenden AMMOSUPPLY-/AUFTRAG-Pfad vor.

Die auf `main` bereits DCS-bestandene ARMY-Ground Acceptance 4 hatte genau dieses frühere Zwei-Sekunden-Risiko dokumentiert und verwendet deshalb:

```text
RETURN_SETTLEMENT_DELAY_SEC = 30
MissionDone
-> wait 30 s
-> public ARMYGROUP:RTZ(existing ACCESS zone, OnRoad)
-> Returned
-> LEGION __AddAsset(10,...)
```

Acceptance 4-2 bestätigte diesen mobilen öffentlichen RTZ-/Returned-/Warehouse-Handoff-Pfad in DCS 2.9.28.26385. Acceptance 6 bestätigte zusätzlich denselben Return-Lifecycle bei Teilverlust/Beschädigung.

## 5. AMMOSUPPLY-Entladefrage

Für den gepinnten Stage-1A-Pfad wurde kein separater automatischer Entlade-Timer gefunden, der den Convoy vor RTZ absichtlich am Ziel festhält. `AUFTRAG:NewAMMOSUPPLY(...)` bleibt nach Zielerreichen eine stationäre Supply-Mission, bis der Mission-Lifecycle beendet wird. Die OMW-Delivery-Buchung erfolgt bewusst bereits am fail-closed `OnAfterMissionExecute + IsInZone(destination)`-Gate.

Der aktuelle Fehler wird deshalb nicht als notwendige Entladezeit klassifiziert, sondern als zu frühe RTZ-Auslösung relativ zur noch laufenden AUFTRAG-Abschlussauswertung.

## 6. Korrektur

Kleinste MOOSE-first-Korrektur:

```text
retain TPL_BLUE_CONVOY_LIGHT_06
retain AUFTRAG:NewAMMOSUPPLY(destinationZone)
retain CampaignState delivery settlement
retain SetReturnToLegion(false)
retain public ARMYGROUP:RTZ(originZone, OnRoad)
retain 1800 s phase-specific return timeout
retain 12 s post-Returned AddAsset verification delay
change only MissionDone -> RTZ issue delay from 2 s to 30 s
```

Kein Despawn/Respawn am Ziel, kein neuer Return-Convoy, kein eigener Router und keine neue Nicht-MOOSE-Ausnahme werden eingeführt.

## 7. Nächster Gate

```text
update acceptance source with RETURN_ISSUE_DELAY_SEC = 30
bump builder provenance
rebuild bundle locally
record real hashes
owner replaces only Acceptance DO SCRIPT FILE resource in a new Mission Editor save
static preflight
rerun DCS
```

Erwarteter Return-Pfad:

```text
DELIVERY_CONFIRMED
-> MISSION_DONE
-> 30 s settlement window
-> RETURN_RTZ_ACTIVE / RETURN_RTZ_ISSUED
-> physical departure from Honaker
-> RETURNED_HANDOFF
-> WAREHOUSE_ADD_ASSET
-> PASS
```
