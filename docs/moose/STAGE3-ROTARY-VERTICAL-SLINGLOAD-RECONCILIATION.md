---
document_id: OMW-MOOSE-STAGE3-ROTARY-VERTICAL-SLINGLOAD-RECONCILIATION
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source diagnosis of the Jalalabad transport-dispatch vertical-takeoff gap
  - Stage 3 Air-AMMO representation target after Focus 1-8
  - next static and DCS acceptance boundary for CH-47 Air-AMMO
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 – Rotary Vertical / Slingload Reconciliation

## 1. Anlass

Der letzte Focus-Lauf hat erstmals den Jalalabad-CH-47-Transport über den konfigurierten Hubschrauberkorridor bis Wright und zurück grundsätzlich ausführbar gezeigt. Gleichzeitig wurden zwei fachlich relevante Abweichungen beobachtet:

```text
1. CH-47 taxiierte zur Runway und führte einen Rolling Takeoff aus.
2. Der Focus-1-8-Resupply verwendete OPSTRANSPORT STORAGE-Transport und damit keine sichtbare externe Slingload-Fracht.
```

Beide Punkte sind getrennt zu behandeln. Dieses Dokument erklärt weder den Rolling Takeoff noch den Slingload-Zielpfad als bereits korrigiert oder DCS-validiert.

## 2. Verbindliche Quellenlage

Projektweit gilt weiterhin:

```text
MOOSE first
CampaignState = strategische Ressourcenautorität
MOOSE = physische DCS-Ausführung / Lifecycle
```

Die bindende Logistikarchitektur auf `main` führt getrennt:

```text
HELICOPTER_INTERNAL
HELICOPTER_SLING
```

Kein Transportverfahren ersetzt automatisch das andere.

Für Stage 3 besteht zusätzlich die dokumentierte Owner-Freigabe für den engen externen Slingload-Korridorpfad:

```text
physical external CH-47 slingload
AND
owner-authored pickup-to-Wright route
```

Der vorhandene Pfad verwendet deshalb weiterhin:

```text
AUFTRAG:NewCARGOTRANSPORT
physical cargo object
physical slingload pickup
approved pickup-to-drop corridor handoff
physical delivery at Wright
AIRWING recovery
```

Focus 1-8 mit `OPSTRANSPORT:AddCargoStorage(...)` bleibt ein wertvoller MOOSE-Lifecycle-/Recruitment-Nachweis, ist aber nicht die endgültige physische Air-AMMO-Darstellung.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 4. Vertikalstart – Source-Diagnose

Die bindende AirOps-Lifecycle-Baseline verwendet vor `AIRWING:Start()`:

```lua
airwing:SetOptionPreferVerticalLanding()
```

Im gepinnten Source setzt diese Methode nur das AIRWING-Flag:

```text
self.OptionPreferVerticalLanding = true
```

Die normale Mission-Dispatch-Kette propagiert dieses Flag in:

```text
LEGION:onafterOpsOnMission(...)
-> AIRWING:FlightOnMission(...)
-> AIRWING:onafterFlightOnMission(...)
-> FLIGHTGROUP:SetOptionPreferVertical()
-> CONTROLLABLE:OptionPreferVerticalLanding()
-> AI.Option.Air.id.PREFER_VERTICAL = true
```

Für einen `Transport-*`-Request zeigt `LEGION:onafterAssetSpawned(...)` im selben gepinnten Source jedoch einen separaten Pfad:

```text
_CreateFlightGroup(asset)
asset.flightgroup = flightgroup
...
assignment contains "Transport-"
-> GetTransportByID(uid)
-> flightgroup:AddOpsTransport(transport)
```

Dieser Transport-Zweig ruft dort **nicht** `__OpsOnMission(...)` auf. Damit wird für den OPSTRANSPORT-Carrier der normale `FlightOnMission`-Propagation-Pfad der AIRWING-Vertikaloption nicht erreicht.

Das ist der source-seitig nachgewiesene Unterschied zwischen Mission- und Transport-Dispatch. Der beobachtete Rolling Takeoff ist damit konsistent; die tatsächliche Wirkung der Korrektur bleibt DCS-pflichtig.

## 5. MOOSE-first Korrektur

Es wird kein Native-DCS-Controller-Override eingeführt.

Die Korrektur verwendet ausschließlich den öffentlichen MOOSE-FSM-Erweiterungspunkt `OnAfterAssetSpawned` und die öffentliche FLIGHTGROUP-Methode `SetOptionPreferVertical()`.

Nach dem internen `onafterAssetSpawned` ist `asset.flightgroup` bereits erzeugt. Die Jalalabad-Foundation setzt deshalb für jeden aus diesem ausschließlich rotary-wing AIRWING gespawnten FLIGHTGROUP erneut die bereits auf AIRWING-Ebene gewählte Policy:

```lua
function airwing:OnAfterAssetSpawned(From, Event, To, group, asset, request)
  local flightGroup = asset and asset.flightgroup or nil
  if flightGroup then
    flightGroup:SetOptionPreferVertical()
  end
end
```

Damit gilt:

```text
normal AUFTRAG mission dispatch:
AIRWING native FlightOnMission propagation

OPSTRANSPORT transport dispatch:
AIRWING OnAfterAssetSpawned -> FLIGHTGROUP:SetOptionPreferVertical()
```

Es werden keine MOOSE-Interna verändert und kein DCS-Task ersetzt.

## 6. Foundation- und Preflight-Guard

Die Jalalabad-Foundation wird auf Builder-Version

```text
JBAD-AIR-OPS-FOUNDATION-ONLY-6
```

gehoben.

Der Builder verlangt jetzt statisch:

```text
SetOptionPreferVerticalLanding
SetOptionPreferVertical
VERTICAL_POLICY_APPLIED
```

Der Stage-3-MIZ-Preflight verlangt dieselbe Foundation-Version und den Transport-Propagation-Marker. Dadurch darf ein altes eingebettetes Jalalabad-Bundle diese Korrektur nicht stillschweigend umgehen.

## 7. Air-AMMO-Zielpfad

Der fachliche Stage-3-Zielpfad bleibt:

```text
CampaignState Air-AMMO reservation
-> Jalalabad CH-47 SQUADRON
-> AUFTRAG:NewCARGOTRANSPORT
-> physical external slingload cargo
-> vertical departure from helicopter parking
-> configured OMW_FlightPath_Rnnn
-> Wright-side physical delivery
-> configured OMW_FlightPath_Rnnn reverse
-> Jalalabad landing
-> AIRWING LegionAssetReturned
-> idempotent CampaignState settlement
```

Nicht als endgültige Stage-3-Darstellung gesetzt wird:

```text
OPSTRANSPORT STORAGE-only internal cargo
```

OPSTRANSPORT bleibt für die Funktionen gültig, die seiner Transportdarstellung entsprechen; Focus 1-8 wird nicht nachträglich als Slingload-Test umgedeutet.

## 8. Acceptance-Grenze

Vor dem nächsten DCS-Lauf sind lokal mindestens zu bestätigen:

```text
exact branch HEAD
JBAD-AIR-OPS-FOUNDATION-ONLY-6 build
independent foundation SHA-256
SetOptionPreferVerticalLanding present
SetOptionPreferVertical present
VERTICAL_POLICY_APPLIED present
```

Danach muss die tatsächlich verwendete `.miz` erneut mit dem aktuellen Foundation-Bundle gespeichert und read-only gegen ihren eingebetteten Stand geprüft werden.

Der nächste Slingload-Lauf muss anschließend mindestens beobachten:

```text
CH-47 spawn
VERTICAL_POLICY_APPLIED log for the real carrier
no taxiway/runway rolling-takeoff sequence
physical external slingload pickup
configured outbound corridor
physical Wright delivery
configured reverse corridor
physical Jalalabad landing
AIRWING recovery
```

`VALIDATED` ist erst nach diesem realen DCS-Nachweis zulässig.

## 9. Status

```text
vertical transport propagation source diagnosis: PASS_SOURCE_REVIEW
MOOSE-first correction: IMPLEMENTED_REMOTE / LOCAL_BUILD_PENDING
physical external slingload target: RETAINED
Focus 1-8 STORAGE transport: DIAGNOSTIC_ONLY_FOR_RECRUITMENT_AND_OPSTRANSPORT_LIFECYCLE
DCS vertical-departure validation after correction: PENDING
DCS slingload end-to-end validation after correction: PENDING
production validation: NO
```
