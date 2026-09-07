---
document_id: OMW-MOOSE-STAGE3-ROTARY-VERTICAL-SLINGLOAD-RECONCILIATION
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source diagnosis of the Jalalabad transport-dispatch vertical-takeoff gap
  - Stage 3 Air-AMMO representation target after Focus 1-8
  - Stage 3 FlightPath naming contract for current acceptance work
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

Am 07.09.2026 wurde zusätzlich ein neuer Acceptance-Fehler festgestellt: Ein neu erstellter isolierter Slingload-Test verlangte erneut hart `OMW_FlightPath_R500`, obwohl der bereits vorhandene OMW-FlightPath-Namensvertrag die logische Route `OMW_FlightPath` und eine im Mission Editor konfigurierte Variante wie `_R200`, `_R500` oder `_Lnnn` vorsieht. Die tatsächlich getestete Mission registrierte `OMW_FlightPath_R200`. Der Lauf brach deshalb bereits an der falschen Route-Precondition ab. Dieser Fehler wurde durch ChatGPT in den Acceptance-Code eingeführt und hätte vor dem DCS-Lauf statisch erkannt werden müssen.

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

Die Jalalabad-Foundation verwendet Builder-Version:

```text
JBAD-AIR-OPS-FOUNDATION-ONLY-6
```

Der Builder verlangt statisch:

```text
SetOptionPreferVerticalLanding
SetOptionPreferVertical
VERTICAL_POLICY_APPLIED
```

Der Stage-3-MIZ-Preflight verlangt dieselbe Foundation-Version und den Transport-Propagation-Marker. Dadurch darf ein altes eingebettetes Jalalabad-Bundle diese Korrektur nicht stillschweigend umgehen.

Die lokale Build-Verifikation vom 07.09.2026 hat für Commit `ffb0d91817dc055df22f1f1b435e777140a94593` folgende reale Artefakte bestätigt:

```text
OMW_AirOps_Jalalabad.lua
SHA-256: 9C403BCEEAACC0FA1AA178A5A2CE29C4376BA6E3F56CFC0597807E6D1C76AA70

OMW_Air_AMMO_R500_Slingload_Handoff_Acceptance_1.lua
SHA-256: BFC930D5C958557E7293B108E1952DB25B2F8D35C11AF43BA5A4147104A248A1
```

Diese Hashes belegen nur den damaligen Buildstand. Nach der nachfolgend dokumentierten Route-Namenskorrektur werden neue lokale Hashes benötigt.

## 7. Verbindlicher FlightPath-Namensvertrag für Stage 3

Der bereits vorhandene OMW-Vertrag `OMW_FlightPathNameContract.lua` ist für die aktuelle Acceptance-Arbeit verbindlich anzuwenden.

Die logische Route heißt:

```text
OMW_FlightPath
```

Die im Mission Editor konfigurierte physische Variante darf beispielsweise heißen:

```text
OMW_FlightPath
OMW_FlightPath_R200
OMW_FlightPath_R500
OMW_FlightPath_L200
...
```

Der Suffix ist **Konfiguration**, nicht Teil einer fachlich fest verdrahteten Route-ID. Für Stage 3 gilt daher:

```text
logical route identity = OMW_FlightPath
configured ME variant = exactly one matching OMW_FlightPath / OMW_FlightPath_[RL]nnn
selection = OMW_FlightPathNameContract.SelectFromRegistry(...)
0 matches = explicit preflight/runtime failure
>1 matches = explicit ambiguity failure
exactly 1 match = use that concrete PATHLINE and its configured offset
```

Ein Acceptance-Test darf deshalb **nicht** erneut `OMW_FlightPath_R200`, `OMW_FlightPath_R500` oder einen anderen Offset als zwingenden Missionsnamen hart codieren, wenn die fachliche Anforderung nur die logische Route `OMW_FlightPath` meint.

Der Name `R500` in älteren Test-IDs oder Dateinamen ist historischer Testkontext und darf nicht als aktuelle ME-Routenanforderung interpretiert werden.

## 8. Air-AMMO-Zielpfad

Der fachliche Stage-3-Zielpfad bleibt:

```text
CampaignState Air-AMMO reservation
-> Jalalabad CH-47 SQUADRON
-> AUFTRAG:NewCARGOTRANSPORT
-> physical external slingload cargo
-> vertical departure from helicopter parking
-> configured OMW_FlightPath variant selected from logical OMW_FlightPath
-> Wright-side physical delivery
-> same configured OMW_FlightPath variant reverse
-> Jalalabad landing
-> AIRWING LegionAssetReturned
-> idempotent CampaignState settlement
```

Nicht als endgültige Stage-3-Darstellung gesetzt wird:

```text
OPSTRANSPORT STORAGE-only internal cargo
```

OPSTRANSPORT bleibt für die Funktionen gültig, die seiner Transportdarstellung entsprechen; Focus 1-8 wird nicht nachträglich als Slingload-Test umgedeutet.

## 9. Fehlgeschlagener DCS-Lauf 07.09.2026 – Einordnung

Der DCS-Lauf vom 07.09.2026 ist **kein** Test des Vertical-Takeoff- oder Slingload-Zielverhaltens. Er endete bereits an einer fehlerhaften Acceptance-Precondition:

```text
mission registered: OMW_FlightPath_R200
acceptance required: OMW_FlightPath_R500
result: FAIL missing OMW_FlightPath_R500
```

Bewertung:

```text
cause: assistant-introduced regression against existing FlightPath naming contract
user/mission-editor error: NO
vertical policy tested: NO
physical slingload pickup tested: NO
corridor handoff tested: NO
DCS validation value for target behavior: NONE
```

Die Wiederholung dieses Fehlertyps muss durch statische Prüfung verhindert werden.

## 10. Acceptance-Grenze und Testkosten-Gate

Ein weiterer DCS-Lauf ist erst zulässig, wenn **vorher** alle statisch prüfbaren Voraussetzungen gegen die tatsächlich verwendete `.miz` erfolgreich geprüft wurden. Der Nutzer hat ausdrücklich festgelegt, dass ein DCS-Test etwa 30 Minuten reale Zeit kostet und deshalb vermeidbare Probe-/Fehlläufe nicht akzeptabel sind.

Vor dem nächsten DCS-Lauf sind mindestens zu bestätigen:

```text
exact branch HEAD
current Jalalabad foundation build + independent SHA-256
current isolated slingload build + independent SHA-256
exact embedded foundation hash == local foundation hash
exact embedded acceptance hash == local acceptance hash
exact embedded Moose.lua hash == pinned Moose.lua hash
logical FlightPath contract embedded/available
Mission Editor PATHLINE registry contains exactly one configured OMW_FlightPath variant
selected concrete PATHLINE is reported by preflight
required pickup/drop zones exist
required CH-47 template exists
no acceptance source hardcodes a required _Rnnn/_Lnnn route variant for the logical OMW_FlightPath
```

Ein fehlender, veralteter oder mehrdeutiger statischer Vertrag muss den Preflight **vor DCS** hart abbrechen.

Der nächste reale Slingload-Lauf muss danach mindestens beobachten:

```text
CH-47 spawn
VERTICAL_POLICY_APPLIED log for the real carrier
no taxiway/runway rolling-takeoff sequence
physical external slingload pickup
preflight-selected configured outbound corridor
physical Wright delivery
same configured corridor reverse
physical Jalalabad landing
AIRWING recovery
```

`VALIDATED` ist erst nach diesem realen DCS-Nachweis zulässig.

## 11. Arbeitsabsprachen für diesen Branch

Für weitere lokale Schritte gelten zusätzlich die ausdrücklich bestätigten Arbeitsregeln:

```text
PowerShell-Befehle immer in einem Codeblock ausgeben.
Bei zu ersetzenden oder zu prüfenden Dateien immer den vollständigen lokalen Pfad mit angeben.
Keine DCS-Testaufforderung, solange statisch prüfbare Mission-/Bundle-/Route-Voraussetzungen nicht vollständig preflighted sind.
Keine erfundenen oder angenommenen lokalen Hashes; nur reale Konsolenausgabe ist Folgeschritt-Grundlage.
```

## 12. Status

```text
vertical transport propagation source diagnosis: PASS_SOURCE_REVIEW
MOOSE-first vertical correction: IMPLEMENTED_REMOTE / LOCAL_BUILD_CONFIRMED_AT_FFB0D918
physical external slingload target: RETAINED
FlightPath logical-name contract: OWNER_RECONFIRMED_2026-09-07
hardcoded OMW_FlightPath_R500 in isolated acceptance: DEFECT_CONFIRMED
07.09.2026 DCS run: INVALID_FOR_TARGET_BEHAVIOR / FAILED_PRECONDITION
preflight route-contract coverage: REQUIRES_FIX
DCS vertical-departure validation after correction: PENDING
DCS slingload end-to-end validation after correction: PENDING
production validation: NO
```
