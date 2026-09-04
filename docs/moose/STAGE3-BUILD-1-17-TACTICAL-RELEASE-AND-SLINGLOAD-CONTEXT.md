---
document_id: OMW-MOOSE-STAGE3-BUILD-1-17-TACTICAL-RELEASE-AND-SLINGLOAD-CONTEXT
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 Build 1-17 remediation rationale
  - Build 1-16 runtime failure diagnosis for Guard/QRF, CAS closure, and CH-47 corridor handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 Build 1-17 – Tactical Release und Slingload-Kontext

## Anlass

Der DCS-Lauf vom 04.09.2026 mit Build 1-16 ist ein reproduzierbarer Fehltest und darf nicht als `VALIDATED` verwendet werden.

Geprüfte Laufzeit-Provenienz:

```text
DCS: 2.9.29.27468 MT
Build: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-16
GitCommit: 4a5b39bccbe80f597632f595a147afaa9ceadb36
Bundle SHA256: 75138CAD6890947139919C6751C28A4E0E4DDD3ECE5A415E8CECB25E377975D2
MizMutation: false
```

Build 1-17 korrigiert ausschließlich die im Lauf nachgewiesenen drei Ursachen. Die strategische Ressourcenhoheit und die bereits genehmigte enge CARGOTRANSPORT-Ausnahme werden nicht erweitert.

## 1. Guard / QRF – zu enger MOOSE-Spawnabstand

Build 1-16 setzte:

```lua
state.brigade:SetSpawnZone(accessZone, 100)
```

Der Runtime-Log meldete wiederholt:

```text
Request denied! Not close enough to spawn zone. Distance = 200 m.
We need to be at least within 100 m range to spawn.
```

Damit war die fehlende Guard-/QRF-Materialisierung kein ungeklärtes Pathfinding-Problem, sondern eine von OMW selbst gesetzte 100-m-Grenze.

Im gepinnten MOOSE-Source ist bestätigt:

```lua
function WAREHOUSE:SetSpawnZone(zone, maxdist)
  self.spawnzone=zone
  self.spawnzonemaxdist=maxdist or 5000
  return self
end
```

`BRIGADE` verwendet diesen WAREHOUSE/LEGION-Lifecycle. Build 1-17 setzt deshalb weiterhin die exakt vorgesehene Mission-Editor-Zone

```text
ZON_BLUE_GND_HONAKER_ACCESS
```

aber ohne künstliche 100-m-Begrenzung:

```lua
state.brigade:SetSpawnZone(accessZone)
```

Damit gilt der öffentliche MOOSE-Default von 5000 m. Warehouse-, CampaignState- und Alarm-Anchor bleiben unverändert.

## 2. CAS – taktisches Ende darf RTB nicht von Shot-Telemetrie abhängig machen

Der Lauf zeigte, dass der bekannte Angriff korrekt beendet wurde:

```text
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC ... completionGate=INCIDENT_PARTICIPANTS
All known Honaker attack participants neutralized; attack incident closed
Honaker response complete; 5-second MOOSE OPSZONE alarm scan stopped
```

Trotzdem blieb der AH-64 im PATROLZONE-Auftrag. Ursache war eine zusätzliche OMW-Bedingung:

```lua
not state.casFired
```

Die Mission wurde also nur geschlossen, wenn zusätzlich das Stage-3-`EVENTS.Shot`-Telemetry-Flag gesetzt war. Diese Telemetrie ist für Acceptance-Evidence nützlich, darf aber nicht über das sichere Missionsende eines real bereits beendeten Angriffes entscheiden.

Build 1-17 trennt deshalb zwei Verantwortlichkeiten:

```text
Tactical completion:
zero living known attack-incident participants
-> AUFTRAG Cancel immediately
-> vorhandene non-mission WEST/R500 recovery waypoints bleiben erhalten

Acceptance evidence:
real EVENTS.Shot remains required for overall PASS
-> blockiert aber nicht mehr die Recovery
```

`OMW_FobAttackCasPatrolClosure.lua` Schema 2 verlangt Execution Evidence nur noch, wenn der jeweilige Adapter explizit `requireExecutionEvidence=true` konfiguriert. Stage 3 setzt für die operative Closure `false`; die Acceptance-Endbedingung prüft `state.casFired` weiterhin separat.

Damit wird keine Waffenwirkung erfunden und kein DCS-Event simuliert. Es wird ausschließlich verhindert, dass fehlende Telemetrie einen leeren PATROLZONE-Auftrag bis Bingo/Fuel weiterlaufen lässt.

## 3. CH-47 – CARGOTRANSPORT-Handoff verlor Drop-Referenzen

Der Lauf bestätigte:

```text
Physical slingload manifest created in ZON_BLUE_LOG_SLG_JALALABAD_01
CH-47 assigned; ... waits for physical slingload pickup
Air-AMMO cargo physically picked up ... corridor routing starts now
AIR-AMMO corridor failed: CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE
```

Damit wurde die Route nach dem Pickup nicht installiert. Der originale MOOSE-CARGOTRANSPORT blieb aktiv und flog deshalb direkt zwischen Pickup und Wright bzw. danach direkt zurück.

Der gepinnte MOOSE-Source bestätigt für

```lua
AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)
```

initial die Felder:

```text
DCStask.params.groupId = StaticCargo:GetID()
DCStask.params.zoneId  = DropZone.ZoneID
DCStask.params.zone    = DropZone
DCStask.params.cargo   = StaticCargo
```

Im späteren Pickup-Lifecycle waren diese Referenzen im getesteten Missionsobjekt nicht mehr zuverlässig verfügbar. OMW besitzt zu diesem Zeitpunkt jedoch bereits die autoritativen Laufzeitobjekte:

```text
state.cargo
ZONE:FindByName(OMW_BLUE_LZ_WRIGHT_01)
```

Build 1-17 übergibt diese beiden Objekte deshalb explizit an den bereits genehmigten Handoff. Der Handoff leitet daraus `cargo:GetID()` und `dropZone.ZoneID` ab und verwendet `mission.DCStask.params` nur noch als Fallback.

Die Ausnahmegrenze bleibt unverändert:

```text
physical external slingload pickup confirmed
-> public FLIGHTGROUP AddWaypoint / AddTaskWaypoint / UpdateRoute
-> one DCS CargoTransportation waypoint task at Wright-side route exit
-> physical delivery confirmed
-> AUFTRAG Success / AIRWING lifecycle
```

Keine Native-DCS-Erweiterung für Spawn, CampaignState, AIRWING, SQUADRON, Teleport oder Controller-Tasking.

## MOOSE-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendete/verifizierte öffentliche Pfade:

```text
WAREHOUSE:SetSpawnZone
AUFTRAG:NewPATROLZONE
AUFTRAG:SetEngageDetected
AUFTRAG:Cancel
FLIGHTGROUP:GetWaypointCurrentUID
FLIGHTGROUP:AddWaypoint
FLIGHTGROUP:AddTaskWaypoint
FLIGHTGROUP:UpdateRoute
AUFTRAG:NewCARGOTRANSPORT
AUFTRAG:Success
```

## Build-1-17-DCS-Gate

Build 1-17 ist vor einem neuen exakten Lauf nur `PLANNED` / `validated_in_dcs:false`.

Zu bestätigen ist:

```text
Guard:
  materialisiert an ZON_BLUE_GND_HONAKER_ACCESS
  folgt anschließend OMW_RTE_BLUE_GUARD_HONAKER_01

QRF:
  materialisiert an ZON_BLUE_GND_HONAKER_ACCESS
  reagiert auf den Angriff
  erhält nach Incident-Ende ReturnToLegion
  Returned settelt PersonnelLedger

CAS:
  Jalalabad -> R500 -> WEST -> AO
  tatsächliche Waffenwirkung
  bei zero living known attack participants sofort PATROLZONE-Cancel
  WEST reverse -> R500 reverse -> Jalalabad
  kein Warten bis Bingo/Fuel

CH-47:
  physischer Slingload-Pickup zuerst
  danach erfolgreicher Handoff mit explicit cargo/drop references
  R500 outbound -> Wright CargoTransportation delivery
  R500 reverse -> Jalalabad
```

Erst nach diesem Lauf darf der Status geändert werden.
