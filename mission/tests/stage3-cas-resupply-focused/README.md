---
document_id: OMW-STAGE3-CAS-RESUPPLY-FOCUSED-README
status: PLANNED
document_class: TECHNICAL_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - focused Stage 3 CAS and OPSTRANSPORT resupply test scope
  - source-reviewed OPSTRANSPORT STORAGE acceptance observations
  - configurable FlightPath naming contract for the focused acceptance
  - 2026-09-07 rejected Focus-1-6 fixture run
  - 2026-09-07 Focus-1-7 carrier-recruitment blocker and 1-8 correction
not_authoritative_for:
  - DCS runtime validation before the documented acceptance run passes
  - production CampaignState resource accounting
  - final Stage 3 combined acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 CAS + Air-AMMO Resupply – Focused Acceptance

Status: **SOURCE_REVIEWED / DCS pending**

Diese fokussierte Acceptance trennt den bestehenden AH-64-CAS-Pfad vom CH-47-Air-AMMO-Resupply-Pfad. Ein Fehler eines Teilpfads darf die reale MOOSE-Ausführung des anderen Teilpfads nicht unterdrücken.

## Verwendeter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Maßgeblich ist die tatsächlich verwendete `Moose.lua`, nicht allein die Online-Dokumentation.

## FlightPath-Namensvertrag

Die primäre FlightPath-Linie besitzt eine stabile logische Identität und eine veränderbare Konfiguration im Mission-Editor-Namen:

```text
OMW_FlightPath          = logische Route
_R200                   = 200 m rechts
_R500                   = 500 m rechts
_L350                   = 350 m links
```

Der Offset-Suffix ist **nicht** Teil der fachlichen Routenidentität. Eine Änderung von `R500` auf `R200` darf daher weder CAS noch RESUPPLY deaktivieren.

Der korrigierte Acceptance-Pfad verwendet:

```text
logical base: OMW_FlightPath
configured runtime name: genau ein OMW_FlightPath oder OMW_FlightPath_[RL]<meter>
secondary segment: OMW_FlightPath_WEST
```

MOOSE 2.9.18 stellt `PATHLINE:FindByName()` nur für exakte Namen bereit; eine öffentliche Wildcard-/Enumerationsmethode für PATHLINEs wurde im gepinnten Source nicht gefunden. Die Acceptance liest daher einmalig und ausschließlich zur Validierung `_DATABASE.PATHLINES`, um den owner-konfigurierten Namen zu bestimmen. Geometrie und Routing bleiben MOOSE-PATHLINE-basiert. Mehrere passende primäre FlightPaths gelten als Konfigurationsfehler und führen zu einem eindeutigen Ambiguity-Fail.

## Rejected Focus-1-6 – 07.09.2026

Der reale Lauf mit `OMW_Template_v22_GroundWorks.miz` ist **REJECTED_TEST_FIXTURE**. Er beweist keinen Fehler des OPSTRANSPORT-Pfads.

```text
DCS: 2.9.29.27468 MT
Mission: OMW_Template_v22_GroundWorks.miz
Mission SHA256: A06B69A459ADF69AC7047EA7F446DCB1EE5B88F80EE04A45DAB01EA26107088C
DCS log SHA256: 8F933330C9515069C84B846D7DFFD4EA2412D8D38C7F952982765EA64259C25E
Debrief SHA256: 2CBC07B92CB466E7A73171F2A344ABEF92FEF60B98A4A121B5B12E390069C3E5
BuilderVersion under test: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-6
Bundle SHA256: 193801A95EEFD58C0C978C5FEF83097F582D51EF53D93AD8925BAD003E202F40
```

MOOSE registrierte real `OMW_FlightPath_R200` und `OMW_FlightPath_WEST`; der Fixture verlangte fälschlich `OMW_FlightPath_R500`.

Root Cause:

```text
Acceptance treated configurable _Rnnn/_Lnnn suffix as fixed PATHLINE identity.
```

## Focus-1-7 – Route bestätigt, Carrier-Recruitment blockiert

Der Projektinhaber baute den 1-7-Fixture lokal und bestätigte Builder- und unabhängigen Bundle-Hash:

```text
GitCommit: 5fb2f8d26296b71371dd3278df77a7903417911c
BuilderVersion: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-7
Bundle SHA256: B0C8BD2D23D3D5A24DB2F5C90F801ADBF67FF2D10D1D18771F3481AFEDE95A3D
MizMutation: false
```

Der anschließende reale DCS-Lauf bestätigte den korrigierten FlightPath-Vertrag:

```text
configured FlightPath selected: OMW_FlightPath_R200 offset=RIGHT 200m
CAS_GEOMETRY ... path=OMW_FlightPath_R200 -> OMW_FlightPath_WEST
CAS READY ... OMW_FlightPath_R200/WEST
```

Danach scheiterte ausschließlich der RESUPPLY-Armierungsschritt:

```text
[STAGE3 FOCUSED][RESUPPLY FAIL] unable to recruit exactly one Jalalabad CH-47 for OPSTRANSPORT
```

Log-Provenienz dieses Laufs:

```text
DCS log SHA256: F311FFEA4665AB2E6216D3B0CC4BF6DC533957D8E5E9AEC13A4801F4CF1FB774
Debrief SHA256: 1FE99126BEA48B730397AB0A25130BD852A51432927DE8E59B563868369953BB
Mission: OMW_Template_v22_GroundWorks.miz
DCS: 2.9.29.27468 MT
```

Damit gilt für Focus-1-7:

```text
FlightPath R200 discovery/offset: DCS CONFIRMED
CAS route setup: REACHED
CH-47 OPSTRANSPORT runtime: NOT REACHED
Wright STORAGE delivery: NOT TESTED
```

Der Lauf ist **kein** Beweis für einen OPSTRANSPORT-Lifecycle-Fehler; der Fixture brach vorher am eigenen Carrier-Recruitment-Gate ab.

## MOOSE-first Carrier-Recruitment-Review

Der aktuelle Jalalabad-CH-47-Pool ist im realen Log vorhanden:

```text
Squadron: SQ_US_JBAD_CH47_HEAVYLIFT
Asset groups: 8
Aircraft: 8
Type: CH-47Fbl1
Attribute: Air_TransportHelo
Cargo bay max: 8225.41 kg
Payloads: 1
```

Die Acceptance-Fixture benötigt insgesamt nur `920 kg`. Die Distanz Jalalabad -> Wright liegt zudem innerhalb der für Helicopter standardmäßig gesetzten MOOSE-Missionsreichweite. Zusammen mit der im Foundation-Code registrierten `AUFTRAG.Type.OPSTRANSPORT`-Capability sind Kapazität, deklarierte Capability und offensichtliche Reichweite daher nicht als Root Cause belegt.

Der gepinnte Source bestätigt für `LEGION.RecruitCohortAssets(...)`:

```text
_CohortCan(...)
-> cohort:RecruitAssets(...)
-> AIRWING payload selection
-> optimized asset selection
-> asset.isReserved=true
-> Legions[asset.legion.alias]=asset.legion
```

Öffentliche MOOSE-Diagnoseverträge für den neuen Fixture:

```text
COHORT:GetMissionCapability(AUFTRAG.Type.OPSTRANSPORT)
COHORT:CountAssets(true, {AUFTRAG.Type.OPSTRANSPORT})
AIRWING:CountPayloadsInStock({AUFTRAG.Type.OPSTRANSPORT}, UnitType)
LEGION.RecruitCohortAssets(...)
LEGION.UnRecruitAssets(...)
```

Die genaue Ursache des 1-7-One-Shot-Recruitment-Fails bleibt **UNDETERMINED**. Der alte Fehlertext verdichtete Duty-, Capability-, Stock-, Payload- und Recruitment-Resultat zu einer einzigen Meldung und reicht daher nicht für eine belastbare Root-Cause-Aussage.

### Warum nicht einfach AIRWING:AddOpsTransport verwenden?

Das wäre für die aktuelle STORAGE-Fixture kein belegter Ersatz. Im gepinnten MOOSE 2.9.18 ermittelt `LEGION:RecruitAssetsForTransport(Transport)` die zu transportierende Masse ausschließlich aus `Transport:GetCargoOpsGroups(false)`. Sind keine Cargo-OPSGROUPs vorhanden, gibt die Funktion `false` zurück. Der fokussierte Transport enthält jedoch `STORAGE`-Cargo. Deshalb bleibt die direkte öffentliche MOOSE-Rekrutierung mit anschließendem `AIRWING:TransportAssign(...)` für diesen Acceptance-Scope erforderlich.

## Focus-1-8 Korrektur

Der 1-8-Fixture ersetzt das einmalige, diagnostisch blinde Carrier-Gate durch ein **begrenztes MOOSE-native Readiness-/Recruitment-Fenster**:

```text
max attempts: 6
retry interval: 5 s
maximum additional window after first attempt: 25 s
```

Vor jedem Versuch werden mit öffentlichen MOOSE-APIs geloggt:

```text
cohort state
OnDuty
OPSTRANSPORT capability
broad in-stock OPSTRANSPORT asset count
compatible AIRWING payload count for CH-47 unit type
```

Nach `LEGION.RecruitCohortAssets(...)` werden separat geloggt:

```text
recruited boolean
asset count
legion count
expected Jalalabad AIRWING match
```

Ein unerwartet erfolgreiches, aber vertragswidriges Recruitment wird vor dem nächsten Versuch mit `LEGION.UnRecruitAssets(assets)` sauber freigegeben. Es gibt keinen hochfrequenten Scheduler, keinen Frame-Scan, keine native DCS-Rekrutierung und keine parallele Asset-Selektion außerhalb von MOOSE.

## Resupply-Architektur

Der aktuelle Pfad verwendet MOOSE `OPSTRANSPORT` für den Storage-Transport-Lifecycle:

```text
OPSTRANSPORT:New(nil, PickupZone, DeployZone)
-> AddCargoStorage(StorageFrom, StorageTo, CargoType, Amount, ItemWeight)
-> bounded public-MOOSE carrier readiness/recruitment
-> LEGION.RecruitCohortAssets(... AUFTRAG.Type.OPSTRANSPORT ...)
-> OPSTRANSPORT:AddAsset(asset)
-> AIRWING:TransportAssign(transport, legions)
-> MOOSE pickup/loading/transport/unloading/delivery
```

Die frühere Lösung mit `AUFTRAG:NewCARGOTRANSPORT`, `PauseMission()`, nativer `CargoTransportation`-Tasksteuerung und eigenem Delivery-Monitor wird nicht verwendet.

Für den Acceptance-Nachweis bleibt die temporäre MOOSE-STORAGE-Fixture:

```text
Resource: ENUMS.Storage.weapons.bombs.Mk_82
Amount: 4
Item weight: 230 kg
Total: 920 kg
Source: ZON_BLUE_LOG_SLG_JALALABAD_01
Destination: OMW_BLUE_LZ_WRIGHT_01
```

Diese Mk-82-Fixture ist ausschließlich ein reproduzierbarer Storage-Transfer-Test und **keine** produktive OMW-Munitionsbestandsentscheidung. CampaignState bleibt strategische Ressourcenautorität.

## Wright-Feld-LZ und Routing-Adapter

`OPSTRANSPORT:AddPathTransport(...)` ist vorhanden. Im gepinnten MOOSE-Stand wird ein Transportpfad für `FLIGHTGROUP`-Carrier jedoch nur in dem dort implementierten Airbase-Zielpfad übernommen. Wright ist eine normale Feld-LZ-Zone. Deshalb bleibt `scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua` für diesen Zieltyp erforderlich und verwendet ausschließlich öffentliche FLIGHTGROUP-Routing-APIs:

```text
OnAfterTransport
-> GetWaypointCurrentUID()
-> AddWaypoint(... configured FlightPath outbound ...)
-> UpdateRoute()

OnAfterDelivered
-> GetWaypointCurrentUID()
-> AddWaypoint(... configured FlightPath reverse ...)
-> UpdateRoute()
```

Der Adapter besitzt weder Cargo- noch Delivery-State und verwendet keinen nativen DCS-Controller.

## Nächste Acceptance-Beobachtung

Für RESUPPLY:

```text
1. configured FlightPath name/offset logged
2. carrier readiness snapshot(s) logged
3. exact MOOSE recruitment result logged
4. exactly one Jalalabad CH-47 assigned
5. OPSTRANSPORT executing
6. configured FlightPath outbound inserted and physically flown
7. source STORAGE 4 -> 0
8. destination STORAGE 0 -> 4
9. OPSTRANSPORT Delivered
10. configured FlightPath reverse inserted and physically flown
11. physical Jalalabad landing
12. AIRWING LegionAssetReturned after landing
```

Für CAS bleibt unabhängig zu beobachten:

```text
Jalalabad -> configured FlightPath -> WEST -> MOOSE ingress -> CAS -> egress -> WEST reverse -> configured FlightPath reverse -> Jalalabad
```

Die bekannte AH-64-Terrain-/Route-Following-Frage wird durch den Resupply-Umbau nicht als gelöst erklärt und darf den CH-47-Teilpfad nicht blockieren.

## Nächster Build

Die Korrektur ist im Builder als

```text
STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-8
```

gestaged. Ein lokaler 1-8-Build und dessen SHA-256 existieren erst nach der dokumentierten lokalen Verifikation des Projektinhabers.

## Noch nicht validiert

Bis zum nächsten realen DCS-Test gilt insbesondere **nicht** als bestätigt:

- erfolgreicher CH-47-Recruitment-Pfad im 1-8-Fixture;
- tatsächliche CH-47-Bewegung über den konfigurierten FlightPath im OPSTRANSPORT-Pfad;
- tatsächliches Be-/Entladen der Storage-Fixture in DCS;
- Reihenfolge `Delivered -> configured FlightPath reverse -> regulärer AIRWING-RTB`;
- physische Jalalabad-Landung und anschließendes `LegionAssetReturned`;
- CAS-Terrainverhalten des aktuellen Focus-Bundles.

Ein `VALIDATED`- oder `PASS`-Status darf erst nach dokumentiertem DCS-Lauf mit Mission-, Bundle-, Git-, DCS- und MOOSE-Provenienz vergeben werden.
