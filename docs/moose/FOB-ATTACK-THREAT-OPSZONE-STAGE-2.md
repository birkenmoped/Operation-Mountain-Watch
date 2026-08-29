---
document_id: OMW-STAGE-2-FOB-ATTACK-THREAT-OPSZONE
status: PLANNED
document_class: MOOSE_ADAPTER_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 MOOSE OPSZONE perimeter-threat qualification adapter design
  - runtime Warehouse-centered security perimeter for BLUE Ground installations
  - RED Ground presence to qualified threat incident boundary
not_authoritative_for:
  - DCS runtime validation before documented Acceptance 1
  - production-wide final security radius policy for every installation
  - CAS aircraft dispatch
  - final attack severity or priority model
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-STAGE-2-FOB-ATTACK-HIT-ADAPTER
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – MOOSE OPSZONE Threat Qualification Adapter

## 1. Ziel

Der aktive Stage-2-MOOSE-Pfad verbindet den vorhandenen Domain-Vertrag

```text
qualified FOB/COP threat
-> OMW_FobAttackDemandPolicy
-> MissionDemand CAS_IMMEDIATE
```

mit einer MOOSE-eigenen räumlichen Bedrohungsbewertung:

```text
Warehouse coordinate
-> runtime ZONE_RADIUS
-> BLUE OPSZONE
-> hostile RED ground presence
-> OPSZONE Attacked
-> OMW qualified threat incident
```

Ein physischer Treffer auf eine bestimmte BLUE-Gruppe ist nicht mehr erforderlich.

Implementierung:

```text
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
```

## 2. MOOSE-First-Nachweis

Verwendeter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der tatsächlich verwendete `Moose.lua` besitzt den direkten öffentlichen Pfad:

```lua
ZONE_RADIUS:New(name, vec2, radius)
OPSZONE:New(zone, coalition.side.BLUE)
OPSZONE:SetObjectCategories(...)
OPSZONE:SetUnitCategories(...)
OPSZONE:SetCaptureThreatlevel(...)
OPSZONE:SetCaptureNunits(...)
OPSZONE:SetDrawZone(...)
OPSZONE:SetMarkZone(...)
OPSZONE:Start()
OPSZONE:Stop()
```

Die MOOSE-Usage-Dokumentation im gepinnten Source enthält ausdrücklich:

```lua
OPSZONE:New(
  ZONE_RADIUS:New("OpsZoneTwo", mycoordinate:GetVec2(), 5000),
  coalition.side.BLUE
)
```

Damit ist eine zur Laufzeit erzeugte Kreiszone ein nativ unterstützter MOOSE-Weg und benötigt keine Mission-Editor-Security-Zone.

## 3. OPSZONE-Angriffssemantik

Der gepinnte `OPSZONE:EvaluateZone()`-Pfad für eine BLUE-owned Zone ist relevant:

```text
BLUE presence remains in zone
AND Nred > 0
AND RED aggregate threat >= configured threatlevelCapture
-> Attacked(coalition.side.RED)
```

`OPSZONE:IsContested()` bedeutet, dass RED und BLUE gleichzeitig innerhalb der Zone vorhanden sind.

Ohne BLUE-Präsenz greift stattdessen die Capture-Logik. Dort wird zusätzlich `nunitsCapture` geprüft. `SetCaptureNunits(1)` ist deshalb nicht der Trigger für den verteidigten `Attacked`-Pfad; der Adapter setzt den Wert lediglich explizit für die separate Capture-Semantik.

Deshalb ist die vorhandene Fortress-Sentry im Acceptance-Aufbau weiterhin sinnvoll: Sie stellt die reale lokale BLUE-Verteidigung dar, ist aber kein speziell registriertes Hit-Ziel mehr.

## 4. Öffentlicher FSM-Callback

Der gepinnte Source dokumentiert und implementiert:

```lua
OnAfterAttacked(From, Event, To, AttackerCoalition)
```

Der OMW-Adapter überschreibt genau diesen vorgesehenen FSM-Callback auf seiner eigenen OPSZONE-Instanz und delegiert bei `AttackerCoalition == RED` an die Domain-Policy.

Es wird kein `world.addEventHandler`, kein paralleler Präsenzscanner und kein MIST eingesetzt.

## 5. Installationsanker und Radius

Der Adapter bekommt einen bereits aufgelösten MOOSE-`COORDINATE`-Anker. Im Stage-2-Acceptance stammt er aus:

```text
BRIGADE -> LEGION -> WAREHOUSE:GetCoordinate()
```

für:

```text
WH_BLUE_GND_FORTRESS
```

Der Acceptance-Vertrag setzt:

```text
zoneName = OMW_SECURITY_BLUE_GROUND_COP_FORTRESS
radiusM  = 1000
```

Der Radius ist als Adapterparameter modelliert und damit nicht als versteckte universelle MOOSE-Annahme kodiert. `1000 m` ist die aktuelle Stage-2-OMW-Entscheidung für den Fortress-Acceptance-Slice; eine spätere installationsbezogene Produktionskonfiguration kann davon abweichen.

## 6. Scan- und Threat-Konfiguration

Acceptance 1 setzt:

```text
ObjectCategories   = { Object.Category.UNIT }
UnitCategories     = { Unit.Category.GROUND_UNIT }
CaptureThreatlevel = 0
CaptureNunits      = 1 (separate capture semantics)
DrawZone           = false
MarkZone           = false
```

Damit gilt im verteidigten BLUE-Zustand bewusst:

```text
Nred > 0 inside security perimeter
+ real BLUE ground presence
+ aggregate RED threat >= 0
-> possible/imminent installation attack alarm
```

`CaptureThreatlevel = 0` ist hier Absicht, weil der Owner die bloße Sichtung/Anwesenheit feindlicher Kräfte im Sicherheitsraum als ausreichenden Alarmgrund festgelegt hat. MOOSE erlaubt später eine höhere Schwelle, falls unbewaffnete oder anderweitig irrelevante Kräfte ausgefiltert werden sollen.

## 7. Status-Intervall

`OPSZONE` definiert im gepinnten Source das öffentliche Klassenfeld:

```lua
UpdateSeconds = 120
```

und `onafterStart()` verwendet:

```lua
local EveryUpdateIn = self.UpdateSeconds or 120
```

Es existiert im geprüften Stand kein eigener Setter für dieses Feld. Der Acceptance-Adapter darf daher vor `Start()` einen explizit übergebenen Wert setzen.

Für Acceptance 1:

```text
UpdateSeconds = 5
```

Dies ist ausschließlich eine Testkonfiguration, damit der manuelle DCS-Lauf nicht bis zu zwei Minuten auf den nächsten Scan warten muss. Eine Produktionskadenz wird damit nicht festgelegt.

## 8. Adapter-Grenze

Der Adapter besitzt keine strategische Ressourcenhoheit. Er erhält:

```text
missionDemand
registry
policy
anchorCoordinate
installationId
zoneName
priority
radiusM
blueCoalition
redCoalition
```

Bei qualifizierter RED-Bedrohung erzeugt er nur den Incident:

```text
incidentId
installationId
priority
position
reportedTarget.targetKind = INSTALLATION_SECURITY_PERIMETER
reportedTarget.targetName = <runtime zone name>
reportedTarget.radiusM
reportedTarget.evidence = OPSZONE_ATTACKED
reportedTarget.attackerCoalition
```

und delegiert anschließend an:

```lua
OMW_FobAttackDemandPolicy.CreateDemand(...)
```

Die bestehende MissionDemand-Registry bleibt zuständig für Dedupe und Lifecycle.

## 9. Dedupe

Der Adapter führt keinen Timer/Cooldown ein.

Wiederholte qualifizierte Threat-Incidents derselben Installation treffen auf:

```text
CAS_IMMEDIATE|FOB_ATTACK|<installationId>
```

und liefern über MissionDemand `active_duplicate`, solange der erste Demand nonterminal ist.

Dieser Vertrag wird im CI-Test `tests/mission-demand/test_fob_threat_opszone_adapter.lua` geprüft. Der DCS-Acceptance-Lauf muss deshalb keinen künstlichen zweiten Hit oder zweiten Feuerkontakt erzeugen.

## 10. ACCESS-Grenze

`ZON_BLUE_GND_FORTRESS_ACCESS` bleibt ausschließlich Bestandteil des bestehenden Ground-Materialisierungswegs.

Die aktuelle Ground-Baseline definiert ACCESS als operative Materialisierungs-/Departure-/Return-/Handoff-Grenze und ausdrücklich nicht als Installation geometry. Der Security-Perimeter wird deshalb separat und automatisch um den Warehouse-Anker erzeugt.

## 11. Superseded Hit design

Der vorherige Branch-Slice verlangte:

```text
RED physically hits exact dynamically registered BLUE Sentry
-> MOOSE EVENTS.Hit
-> qualified incident
```

Real DCS evidence zeigte zwar Feuerkontakt, aber keinen zuverlässig qualifizierten Treffer auf genau diese Runtime-Gruppe. Fachlich ist der Treffer außerdem zu spät für einen möglichen bevorstehenden Angriff.

Daher ist `OMW_FobAttackHitAdapter.lua` aus dem aktiven Branch-Scope entfernt. Git history bewahrt den Entwicklungs- und Fehlerpfad.

## 12. Offene DCS-Acceptance

Vor `VALIDATED_FOR_DOCUMENTED_SCOPE` ist weiterhin ein realer Lauf erforderlich:

```text
Fortress local-security squad ONGUARD
-> runtime 1000m security ZONE_RADIUS
-> BLUE OPSZONE started
-> real RED ground force inside perimeter
-> OnAfterAttacked(..., RED)
-> one CAS_IMMEDIATE MissionDemand
-> PASS
```

Dabei sind Branch/Commit, BuilderVersion, Bundle-SHA-256, MIZ-Datei/SHA-256, DCS-Version, MOOSE-Commit/SHA-256 und Log-Hashes zu dokumentieren.

CAS-Dispatch über AUFTRAG/COMMANDER/AIRWING/SQUADRON bleibt außerhalb dieses Slices.
