---
document_id: OMW-STAGE-2-FOB-ATTACK-THREAT-OPSZONE
status: VALIDATED_FOR_DOCUMENTED_SCOPE
document_class: MOOSE_ADAPTER_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 MOOSE OPSZONE perimeter-threat qualification adapter design
  - runtime Warehouse-centered security perimeter for BLUE Ground installations
  - RED Ground presence to qualified threat incident boundary
not_authoritative_for:
  - production-wide final security radius policy for every installation
  - CAS aircraft dispatch
  - final attack severity or priority model
  - production OPSZONE scan cadence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-STAGE-2-FOB-ATTACK-HIT-ADAPTER
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
validated_in_dcs: true
---

# Stage 2 – MOOSE OPSZONE Threat Qualification Adapter

## 1. Ziel und validierter Pfad

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
-> hostile RED ground presence while BLUE local-security presence remains
-> OPSZONE Attacked
-> OnAfterAttacked(..., RED)
-> OMW qualified threat incident
```

Dieser exakte Pfad wurde am 2026-08-29 in DCS Acceptance 1 erfolgreich validiert. Ein physischer Treffer auf eine bestimmte BLUE-Gruppe war nicht erforderlich.

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

Die vorhandene Fortress-Sentry stellte im Acceptance-Lauf die reale lokale BLUE-Verteidigung dar und war kein speziell registriertes Hit-Ziel. Der verteidigte `Attacked`-Pfad wurde tatsächlich beobachtet.

## 4. Öffentlicher FSM-Callback

Der gepinnte Source dokumentiert und implementiert:

```lua
OnAfterAttacked(From, Event, To, AttackerCoalition)
```

Der OMW-Adapter überschreibt genau diesen vorgesehenen FSM-Callback auf seiner eigenen OPSZONE-Instanz und delegiert bei `AttackerCoalition == RED` an die Domain-Policy.

Im Acceptance-Lauf führte dieser Callback zu:

```text
QUALIFIED_THREAT count=1
-> DEMAND_RESULT created=true reason=nil
-> PASS activeDemands=1 missionType=CAS_IMMEDIATE
```

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

Der Radius ist als Adapterparameter modelliert. `1000 m` ist für Fortress in diesem Acceptance-Scope validiert; eine spätere installationsbezogene Produktionskonfiguration kann davon abweichen.

## 6. Scan- und Threat-Konfiguration

Acceptance 1 setzte und validierte:

```text
ObjectCategories   = { Object.Category.UNIT }
UnitCategories     = { Unit.Category.GROUND_UNIT }
CaptureThreatlevel = 0
CaptureNunits      = 1 (separate capture semantics)
DrawZone           = false
MarkZone           = false
```

Damit gilt im validierten verteidigten BLUE-Zustand:

```text
Nred > 0 inside security perimeter
+ real BLUE ground presence
+ aggregate RED threat >= 0
-> possible/imminent installation attack alarm
```

## 7. Status-Intervall

`OPSZONE` definiert im gepinnten Source das öffentliche Klassenfeld:

```lua
UpdateSeconds = 120
```

und `onafterStart()` verwendet:

```lua
local EveryUpdateIn = self.UpdateSeconds or 120
```

Acceptance 1 setzte vor `Start()`:

```text
UpdateSeconds = 5
```

Der Lauf bestätigte den Start mit `updateSeconds=5`. Das validiert ausschließlich diesen Acceptance-Weg. Eine Produktionskadenz ist weiterhin nicht entschieden.

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

Bei qualifizierter RED-Bedrohung erzeugt er nur den Incident und delegiert an:

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

Dieser Vertrag wird im CI-Test `tests/mission-demand/test_fob_threat_opszone_adapter.lua` geprüft. Acceptance 1 validierte den ersten realen Threat -> Demand Pfad.

## 10. ACCESS-Grenze

`ZON_BLUE_GND_FORTRESS_ACCESS` bleibt ausschließlich Bestandteil des bestehenden Ground-Materialisierungswegs und wird nicht als Installation geometry wiederverwendet.

## 11. Superseded Hit design

Der vorherige Branch-Slice verlangte:

```text
RED physically hits exact dynamically registered BLUE Sentry
-> MOOSE EVENTS.Hit
-> qualified incident
```

Dieser Weg ist für Stage-2 primary threat qualification superseded. Git history bewahrt den Entwicklungs- und Fehlerpfad.

## 12. DCS-Acceptance-Provenienz

```text
Result: PASS
DCS version: 2.9.29.27278
Tested source commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
BuilderVersion: FOB-ATTACK-THREAT-ACCEPTANCE-1-2
Acceptance Lua: OMW_FOB_Attack_Threat_Acceptance_1.lua
Acceptance bundle SHA-256: 9A3382BF0EE476ED105A5EEF56575C73EBE591AAA00C1C4B1DA7A55F27835650
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 8C8821ABDD412258A1B2ABF18FC9AA8018767E80894B174DAFE982513B3D2B2D
debrief.log SHA-256: 081FE758DAE40933F011CE8156364BAC5EF40C13247150999F7CACE2159FD227
Owner-supplied MIZ artifact: OMW_Template_v20_GroundWorks(10).miz
Owner-supplied MIZ artifact SHA-256: 54E6562A095E771721E417CC8F5AEE0606066EA619E9E72D462E402A6D3EC118
Runtime debrief mission path: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v20_GroundWorks.miz
```

The filename difference between the uploaded MIZ artifact and the runtime debrief path is preserved. The hash belongs to the owner-supplied post-run artifact.

Detailed result:

```text
mission/tests/fob-attack-support-demand/RESULT-1.md
```

## 13. Validierungsgrenze

`VALIDATED_FOR_DOCUMENTED_SCOPE` gilt ausschließlich für die beobachtete Fortress-Komposition. Nicht dadurch validiert sind:

```text
CAS dispatch via AUFTRAG / COMMANDER / AIRWING / SQUADRON
production OPSZONE scan cadence
other installations
arbitrary capture/ownership scenarios
persistent incident lifecycle across restart
```