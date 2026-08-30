---
document_id: OMW-STAGE-2B-FOB-ATTACK-AUTOMATIC-RESPONSE
status: BINDING
document_class: MOOSE_INTEGRATION_DESIGN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2B automatic response design for threatened BLUE FOB/COP installations
  - Fortress accepted threat-to-CAS and local Ground-response composition
  - CAS completion and Ground return authority boundaries
not_authoritative_for:
  - production-wide QRF force-size doctrine
  - production CAS source-selection policy beyond current configured source
  - perfect DCS Ground-AI pathfinding through arbitrary installation geometry
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
validated_in_dcs: true
---

# Stage 2B – automatische Reaktion eines angegriffenen FOB/COP

## Verbindlicher Architekturpfad

```text
BLUE installation security
-> MOOSE OPSZONE Attacked(RED)
-> CAS_IMMEDIATE MissionDemand
-> configured AIRWING/SQUADRON CAS dispatch
-> local Guard/QRF response
-> OPSZONE Defeated(RED)
-> CAS mission closure and recovery
-> Ground native ReturnToLegion / origin recovery
-> CampaignState settlement
```

CampaignState bleibt strategische Ressourcenautorität; MOOSE führt die physische Runtime aus.

## Guard

Normalzustand:

```text
AUFTRAG:NewONGUARD(...)
```

Bei erkannter Ground-Bedrohung:

```text
AUFTRAG:SetEngageDetected(..., {"Ground Units"})
-> native ARMYGROUP EngageTarget lifecycle
```

Der Guard ist damit kein passiver Endzustand bei erkanntem Feind. Es wird kein eigener DCS Attack-Task implementiert.

## QRF

QRF-Gruppen verwenden:

```text
AUFTRAG:NewGROUNDATTACK(Target, Speed, Formation)
```

Die disponierte Anzahl wird durch reale Bedrohung, verfügbare Assets, CampaignState-Reserve und Konfigurationslimit begrenzt. Ziele werden deterministisch nearest-first mit stabilem Namens-Tie-break zugeordnet. Eine feste Ein-QRF-Sperre ist nicht Teil der Architektur.

## CAS

Der aktuelle Fortress-Acceptance-Pfad nutzt den vorhandenen Jalalabad-AH-64D-Pool. Rotary-wing CAS verwendet den owner-authored `OMW_FlightPath` für Hin- und Rückweg. Die Corridor-Installation erfolgt erst nach verfügbarer MOOSE-Missionsroute; Mission-Waypoint-UID ist erforderlich, Egress-UID optional.

## Rückkehr

Ground-Ressourcen bleiben an ihren Ursprung gebunden. Zielort oder bedrohte Installation bestimmen **nicht** das Rückkehr-Warehouse.

```text
origin Legion/Warehouse
-> normal ReturnToLegion
-> origin homezone/spawnzone
-> Returned
-> origin Warehouse AddAsset
-> CampaignState settlement for original deployment
```

Der akzeptierte Fortress-QRF-Pfad benötigt kein `SetReturnToLegion(false)`, kein explizites OMW-RTZ und keinen Spawnzone-Override.

## DCS-Acceptance

Stage 2B wurde am 30.08.2026 im exakt dokumentierten Fortress-Scope durch den Projektinhaber als PASS akzeptiert. Provenienz und Einschränkungen stehen in:

```text
mission/tests/fob-attack-support-demand/RESULT-2.md
docs/handoffs/2026-08-30-fob-attack-support-demand-ready-for-review.md
```

Bekannte Grenze: Ein abschließender Guard-`Returned`-Nachweis fehlte vor Missionsende; der Owner akzeptierte den beobachteten Guard/HESCO-Restbefund ausdrücklich als nicht blockierende DCS-Ground-AI-Einschränkung für Stage 2B.