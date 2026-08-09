---
document_id: OMW-TEST-TKOT-AIR-OPS-STATUS-FREEZE-2026-08-05
status: FROZEN_SNAPSHOT
document_class: TEST_RESULT_AND_DECISION_RECORD
owning_policy: OMW-GOV-001
snapshot_time_local: 2026-08-05T11:52:00+02:00
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit_before_snapshot: 0a533fcd7ccec6b71f9d44db675e95cef2eda06b
pull_request: 53
pull_request_state: DRAFT_OPEN_UNMERGED
authoritative_for:
  - complete Tarinkot AirOps working-state snapshot through the second G8 DCS run
  - chronological record of accepted results, failed attempts, corrections and owner decisions
  - current technical block in MOOSE WAREHOUSE parking selection
  - frozen next-action boundary
not_authoritative_for:
  - a successful G8 vertical departure
  - final production parking compatibility
  - COMMANDER, OPSTRANSPORT, recovery, persistence or campaign-state acceptance
  - merge or Ready-for-Review approval
validated_in_dcs: partial
supersedes: []
superseded_by:
  - OMW-TEST-TKOT-G8-MOOSE-PARKING-OVERRIDE-RESEARCH-2026-08-05 for current-next-action authority
---

# Vollständiger Status-Freeze: Tarinkot Air Operations bis zum G8-Parking-Block

## 1. Zweck dieses Dokuments

Dieses Dokument friert den vollständigen Arbeitsstand des Tarinkot-AirOps-Strangs zum 5. August 2026, 11:52 Uhr Ortszeit ein. Es hält nicht nur die erfolgreichen Ergebnisse fest, sondern ausdrücklich auch:

- Fehlversuche;
- falsche Annahmen;
- unzureichende Testgrenzen;
- fehlerhafte Schlussfolgerungen;
- korrigierte Aussagen;
- Eigentümerentscheidungen;
- verworfene Lösungswege;
- bereits ausgeführte Git-, CI-, Builder-, Mission-Editor- und DCS-Schritte;
- noch offene technische Fragen;
- die exakte Grenze, ab der keine weitere Änderung oder kein weiterer DCS-Lauf ohne neue Entscheidung erfolgen darf.

Der Snapshot ist absichtlich umfassend. Er soll verhindern, dass bei einer späteren Wiederaufnahme bekannte Fehler erneut gemacht, akzeptierte Fakten neu diskutiert oder verworfene Annahmen unbemerkt wieder eingeführt werden.

## 2. Governance und eingefrorene Arbeitsgrenze

### 2.1 Eigentümerhoheit

Der Projektinhaber entscheidet:

- ob ein PR gemergt wird;
- ob ein PR von Draft auf Ready for Review gesetzt wird;
- wie die `.miz`-Datei benannt wird;
- wann ein weiterer DCS-Lauf zulässig ist;
- welche visuelle Platzierung akzeptiert wird;
- ob ein projektspezifischer MOOSE-Eingriff zulässig ist.

Verbindliche Korrektur aus dem Verlauf:

```text
Der Dateiname der MIZ ist kein technischer Gate-Nachweis.
Er wird nicht vorgeschrieben und nicht als Versions- oder Zwischenstandsbezeichnung interpretiert.
```

Die frühere Forderung, eine bestimmte MIZ-Bezeichnung zu verwenden oder anhand des Debrief-Pfads auf eine falsche Mission zu schließen, war unzulässig und ist verworfen.

### 2.2 Aktueller PR-Zustand

```yaml
PR: 53
state: OPEN
mode: DRAFT
merged: false
mergeable: true
base: main
head: agent/tarinkot-object-contract-reconciliation
head_before_snapshot: 0a533fcd7ccec6b71f9d44db675e95cef2eda06b
```

PR #53 darf ohne ausdrückliche Eigentümerfreigabe weder gemergt noch auf Ready for Review gesetzt werden.

### 2.3 Freeze-Regel

Ab diesem Snapshot gilt:

```text
Keine weitere MIZ-Mutation.
Kein weiterer DCS-Lauf.
Keine Änderung der Parking-Pools.
Kein Patch oder Override einer MOOSE-internen Funktion.
Keine Änderung an Revetment-Statics.
Keine Umstellung auf Airstart.
Keine Lockerung von Client-Slot-Schutzregeln.
```

Zulässig bleibt ausschließlich Recherche und Dokumentation zur offenen Frage, ob MOOSE für die lokalen Parameter von `_FindParkingForAssets()` einen dokumentierten oder praktisch etablierten Override-/Hook-Pfad besitzt.

## 3. Zentrale Projektkonsolidierung

### 3.1 Anlass

Vor weiteren langen DCS-Läufen wurde eine zentrale Konsolidierung verlangt, weil mehrere Fehler aus fehlender oder verteilter Lifecycle-Dokumentation entstanden waren. Die Konsolidierung sollte insbesondere verbindlich festhalten:

1. AIRWING-/SQUADRON-/WAREHOUSE-Lifecycle-Matrix;
2. Pre-Start- und Post-Start-Prüfregeln;
3. MIZ-Save-/Transfer-/Hash-Invaliderung;
4. Observer-Client-Policy;
5. `SetOptionPreferVerticalLanding()` und COMMANDER-Startreihenfolge;
6. einen kanonischen Test-Mission-Build-/Transfer-/Validation-Workflow;
7. Test-Governance unter `mission/tests/`;
8. einen gemeinsamen statischen Guard;
9. zentrale Registry-/MOOSE-Dokumentationspflege;
10. Sperre weiterer langer DCS-Läufe bis zur Konsolidierung.

### 3.2 PR #55

Zentrale Konsolidierungsbranch:

```text
agent/consolidate-air-ops-lifecycle-governance
```

PR:

```text
#55
```

Der Eigentümer erteilte ausdrücklich die Merge-Freigabe. PR #55 wurde anschließend in `main` gemergt.

```text
Merge-Commit:
cf1b5ff138c6cb5e59e0070f7ba8aef4cfb3823a
```

Zentrale Inhalte auf `main`:

```text
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/moose/AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md
mission/tests/GOVERNANCE.md
tools/Test-AirOpsLifecycleGuards.ps1
```

Zusätzlich aktualisiert:

```text
docs/DOCUMENT-REGISTRY.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/README.md
docs/moose/VERIFIED-METHODS.md
```

### 3.3 Synchronisierung des Tarinkot-Branches

Der lokale Tarinkot-Branch lag nach dem Merge von PR #55 hinter `main`. Der Eigentümer führte aus:

```powershell
git fetch origin
git switch agent/tarinkot-object-contract-reconciliation
git pull --ff-only
git merge --no-ff origin/main
```

Erwartete Konflikte traten ein:

```text
docs/DOCUMENT-REGISTRY.md
tools/Test-AirOpsLifecycleGuards.ps1
```

Beide Konflikte wurden zugunsten der zentralen `main`-Version aufgelöst:

```powershell
git checkout --theirs -- docs/DOCUMENT-REGISTRY.md
git checkout --theirs -- tools/Test-AirOpsLifecycleGuards.ps1
git add docs/DOCUMENT-REGISTRY.md
git add tools/Test-AirOpsLifecycleGuards.ps1
```

Merge-Commit:

```text
3c55cedcb2f1aa571a5bb715114199ab2b1c6a57
```

Push erfolgreich. `dist/` blieb korrekt untracked:

```text
?? mission/tests/tarinkot-air-operations/dist/
```

## 4. Akzeptierter Tarinkot-Objektvertrag

### 4.1 AIRWING und SQUADRONs

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

### 4.2 Bestand

```yaml
AH64D: 14
UH60: 6
CH47: 2
OH58D: 0
```

### 4.3 Airbase und Warehouse

```yaml
runtime_airbase_name: Tarinkot
dcs_airbase_id: 9
warehouse: WH_AIR_US_TARINKOT
```

### 4.4 Client-Ausschlüsse

```yaml
client_terminal_ids:
  - 20
  - 8
  - 3
```

Diese Plätze dürfen nicht Bestandteil eines KI-Parking-Pools sein.

## 5. G5 – Read-only-Diagnostik

G5 diente ausschließlich der Strukturprüfung ohne Mutation.

Bestätigt:

```text
Airbase: Tarinkot / ID 9
Parkingnodes: 33
Warehouse: WH_AIR_US_TARINKOT
Clients: 3/3
AI-Seeds: 3/3
Statics: 12/12
Namensduplikate: 0
Mutationen: 0
```

G5 bestätigte die Mission-Editor-Namen und den technischen Objektbestand. G5 bewies weder produktive Parking-Pools noch AIRWING-Dispatch.

## 6. G6 – Parking-Kalibrierung und Platzierung

### 6.1 G6A – zu breiter Scope

Der erste Kandidatenscan verwendete einen zu breiten `HelicopterUsable`-Scope. Dadurch wurden Type-104-/General-Apron-Positionen einbezogen, die technisch als Hubschrauberpositionen erscheinen konnten, aber nicht der gewünschten Tarinkot-Hubschrauberplatte entsprachen.

Einstufung:

```text
PASS_DCS_SCOPE_TOO_BROAD_FOR_PRODUCTIVE_LISTS
```

Lehre:

```text
Eine technisch benutzbare Parkingposition ist nicht automatisch eine fachlich oder visuell geeignete Produktionsposition.
```

### 6.2 G6A2 – Mission-Editor-/MOOSE-Mapping

Alle relevanten Mission-Editor-Parkingpositionen wurden auf MOOSE-TerminalIDs gemappt.

```text
RESULT G6A2_ME_PARKING_MAP
status=PASS_MAP
anchors=30
mapped=30
rejected=0
ambiguous=0
duplicates=0
parkingCount=33
clientReferences=3
```

### 6.3 Erster kombinierter G6B-Lauf

Der erste kombinierte Platzierungslauf war technisch lauffähig, platzierte die Luftfahrzeuge aber auf dem falschen Vorfeld.

Eigentümerurteil:

```text
FAIL_VISUAL_WRONG_APRON
```

Die verwendeten Type-104/OpenBig-Positionen sind verworfen.

### 6.4 Finaler G6B-Lauf

Der finale Lauf verwendete Type-40-/HelicopterOnly-Positionen.

```text
RESULT G6B_HELICOPTER_APRON_COMBINED
status=PASS_RUNTIME_PLACEMENT
expectedGroups=7
groupsFound=7
expectedUnits=8
unitsFound=8
placementFailures=0
familyFailures=0
spawnCalls=7
expectedTerminalType=HelicopterOnly
```

Der Eigentümer akzeptierte die visuelle Platzierung.

Akzeptierte Pools:

```yaml
AH64:
  ME: [C04-H, C18-H]
  TerminalIDs: [21, 4]
UH60:
  ME: [C14-H, C12-H, C11-H]
  TerminalIDs: [30, 27, 23]
CH47:
  ME: [C08-H, C09-H, C10-H]
  TerminalIDs: [32, 29, 10]
```

### 6.5 Spätere Scope-Korrektur

G6B verwendete einen direkten SPAWN-/Placement-Pfad. Daraus wurde zunächst zu weitreichend abgeleitet, die Plätze seien damit auch für den produktiven AIRWING-/WAREHOUSE-Dispatch geeignet.

Diese Schlussfolgerung ist falsch.

Korrekte Aussage:

```text
G6B beweist direkte DCS-/SPAWN-Platzierbarkeit und visuelle Eignung.
G6B beweist nicht die Akzeptanz durch WAREHOUSE:_FindParkingForAssets().
```

## 7. G7 – AIRWING-/SQUADRON-/Payload-Foundation

### 7.1 Akzeptierte Artefaktkette

```text
Source commit:
add569fb3231a5563d9c89f865cce7bd764bc0bb

BuilderVersion:
TKOT-G7-AIRWING-FOUNDATION-3

Bundle SHA-256:
7018f4e388a349f91bc4169e6200226a32c001e3c4afdbd4daf69b538de2dea8

MIZ SHA-256:
86ba08f46c78a94cdf6eb54f7abe85145bdabe2817e7a2a89f2cec34932866bb

Internal mission SHA-256:
babaaee09f38ecbacb0c564b1686e20ee5b18ccf9b8abd920f32952d4a8f54a8

Embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

DCS log SHA-256:
aeacc9fc9270dc033ed49a41eb1b3264880710265386f1d21e0c787a22739e52

Debrief SHA-256:
8a33b90efdf57f92a95ff2b07d0c016555d79776da3b708367f63ef09a284588
```

DCS:

```text
2.9.28.26385 MT
```

MOOSE:

```text
2.9.18
```

### 7.2 Ergebnis

```text
RESULT G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION
status=PASS
violations=0
airwingRunning=true
squadrons=3
registeredGroups=5
registeredAircraft=7
stock=5
rolePayloads=3
totalPayloads=6
parkingPools=3
parkingIDs=8
missionQueue=0
transportQueue=0
requestQueue=0
opsGroups=0
safeParking=true
verticalPolicy=true
takeoffCold=true
commanderCreated=0
auftragCreated=0
opsTransportCreated=0
deliberateSpawns=0
```

### 7.3 Lifecycle-Erkenntnis

Pre-Start:

```text
Warehouse-Stock: 2 -> 4 -> 5
squadron.assets: 0/0/0
```

Die leeren `squadron.assets` waren kein Fehler, sondern der erwartete Deferred-Zustand.

Post-Start:

```text
AH64 squadron.assets: 2
UH60 squadron.assets: 2
CH47 squadron.assets: 1
AIRWING: Running
```

Verbindliche Lifecycle-Regel:

```text
AIRWING:AddSquadron()
  -> registriert Warehouse-Stock

AIRWING:Start() plus Initialisierung
  -> bindet Assets an COHORT/SQUADRON
  -> erst danach ist squadron.assets positiv zu prüfen
```

### 7.4 Vertikaloption

Akzeptierte Reihenfolge:

```lua
airwing:SetTakeoffCold()
airwing:SetSafeParkingOn()
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

G7 beweist nur, dass die AIRWING-Option vor Start gesetzt wurde. G7 beweist keine tatsächliche Weitergabe an eine erzeugte FLIGHTGROUP und keinen vertikalen Abflug.

### 7.5 Observer-Client-Telemetriefehler

Der Lauf erkannte korrekt:

```text
Client unit: CLIENT_US_TKOT_AH64D_01_UNIT_01
Player: Neues Rufz.
observerClientsDetected=1
observerClientsAllowed=1
observerClientsBlocking=0
```

Das alte Endmarkerfeld:

```text
activePlayerClients=0
```

war falsch. Der Builder-Footer überschrieb den zuvor korrekt ermittelten Rückgabewert. Der Fehler betraf die Ergebnisdarstellung, nicht die G7-Funktion.

Einstufung:

```text
PASS_DCS_WITH_TELEMETRY_FIELD_CORRECTION
```

### 7.6 Builder v4 und Guard

Builder-Version 4 korrigierte den Harness ohne neuen langen DCS-Lauf:

```text
TKOT-G7-AIRWING-FOUNDATION-4
```

Korrekturen:

- Pre-Start-Prüfung ausschließlich auf Warehouse-Stock;
- Post-Start-Prüfung von `squadron.assets` und Parking-Vererbung;
- Vertikaloption zwingend vor `AIRWING:Start()`;
- getrennte Observer-Werte detected/allowed/blocking;
- keine Maskierung des Observer-Zählwerts;
- Verbot von COMMANDER, AUFTRAG, OPSTRANSPORT und SPAWN im Foundation-Scope.

Der gemeinsame Guard bestand CI.

## 8. Main-Synchronisierung und G8-Vorbereitung

Nach Merge von PR #55 und Synchronisierung des Tarinkot-Branches wurde G8 implementiert.

Neue Dateien:

```text
.github/workflows/tarinkot-g8-static-validation.yml
mission/tests/tarinkot-air-operations/expected/g8-uh60-native-vertical-departure-acceptance.md
mission/tests/tarinkot-air-operations/results/2026-08-05-main-lifecycle-sync-and-g8-static-pass.md
mission/tests/tarinkot-air-operations/src/08-tarinkot-g8-uh60-native-vertical-dispatch.lua
tools/build-tarinkot-air-operations-g8-uh60-vertical-dispatch.ps1
```

Branch-Head nach G8-Vorbereitung:

```text
0a533fcd7ccec6b71f9d44db675e95cef2eda06b
```

CI:

```text
Documentation validation: SUCCESS
Run 30956742026

Tarinkot G7 static validation: SUCCESS
Run 30956742033

Tarinkot G8 static validation: SUCCESS
Run 30956742044
```

G8-Buildervertrag:

```text
BuilderVersion: TKOT-G8-UH60-VERTICAL-DISPATCH-1
EmbeddedFoundation: TKOT-G7-AIRWING-FOUNDATION-4
MissionType: AUFTRAG.Type.LANDATCOORDINATE
Squadron: SQ_US_TKOT_UH60_TF_ATTACK
RequiredAssets: 1
DestinationZone: ZONE_AIR_US_TKOT_ROTARY_STAGING
GroundDisplacementThresholdM: 75
OperationalMissions: 1
Commander: 0
OpsTransport: 0
RawSpawn: 0
StandaloneFlightGroup: 0
SyntheticZones: 0
OwnerVisualConfirmation: required
```

## 9. Lokaler G8-Build

Der Eigentümer aktualisierte den Branch und führte den Builder aus.

Lokaler G7-Bundlehash:

```text
6726412c69a9f116149020b6d3367369c012e5ff089db52ce3cb4bc0dd5da65e
```

Lokaler G8-Bundlehash:

```text
281ae2e78f1d7f166e05553ca598c59b319a9b44f71d24f9c979f7feb3876831
```

Der Hash wurde unabhängig mit `Get-FileHash` bestätigt.

`dist/` blieb korrekt untracked.

## 10. Triggerzone und korrigierte MIZ-Aussage

### 10.1 Zweck der Zone

G8 verwendet:

```lua
AUFTRAG:NewLANDATCOORDINATE(...)
```

Dafür benötigt der Test eine reale Zielkoordinate. Diese wird über die Mission-Editor-Zone bezogen:

```text
ZONE_AIR_US_TKOT_ROTARY_STAGING
```

Die Zone ist nicht erforderlich für:

- AIRWING-Erzeugung;
- SQUADRON-Erzeugung;
- Parking-Pools;
- `SetOptionPreferVerticalLanding()`;
- die MIZ-Dateibenennung.

Sie ist ausschließlich der reproduzierbare Zielpunkt des LANDATCOORDINATE-Auftrags.

### 10.2 Erste G8-Ausführung ohne Zone

Die richtige G8-Lua wurde geladen, G7 bestand, G8 blockierte aber vor Auftragserzeugung:

```text
status=BLOCKED
reason=MISSING_MISSION_EDITOR_ZONE_ZONE_AIR_US_TKOT_ROTARY_STAGING
missionAdded=false
flightOnMission=false
optionPreferVertical=false
unit=none
```

Kein UH-60 wurde angefordert, gespawnt oder bewegt.

### 10.3 Fehlerhafte Interpretation des MIZ-Pfads

Aus dem Debrief-Pfad wurde zunächst geschlossen, es sei eine falsche Mission gestartet worden, weil der Dateiname nicht einer vorgeschlagenen Zwischenstufenbezeichnung entsprach.

Diese Schlussfolgerung war falsch.

Korrektur durch den Eigentümer:

```text
Die Benennung der MIZ bestimmt ausschließlich der Eigentümer.
Die MIZ soll keine aktuelle Zwischenstufe im Dateinamen darstellen.
Die MIZ-Dateibenennung ist nicht zu prüfen.
Einzig die richtige Lua und der tatsächliche interne Objektvertrag sind relevant.
```

Diese Festlegung ist verbindlich.

## 11. Zweiter G8-DCS-Lauf – Zone vorhanden, Parking blockiert

### 11.1 Geladene Implementierung

```text
BuilderVersion: TKOT-G8-UH60-VERTICAL-DISPATCH-1
GitCommit: 0a533fcd7ccec6b71f9d44db675e95cef2eda06b
```

G7 bestand erneut.

### 11.2 Auftragserzeugung

Die Zone wurde gefunden. Der Auftrag wurde erzeugt und der AIRWING-Queue hinzugefügt.

```text
MISSION_ADDED
type=Land at Coordinate
squadron=SQ_US_TKOT_UH60_TF_ATTACK
requiredAssets=1
verticalPolicy=true
```

Der MOOSE-Pfad erreichte damit die produktionsrelevante Request-Phase.

### 11.3 Blockierung

MOOSE meldete wiederholt:

```text
No free parking spot for asset
SQ_US_TKOT_UH60_TF_ATTACK_AID-95-1
```

und:

```text
Request denied!
Not enough free parking spots for all requested assets at the moment.
```

Folgen:

```text
FLIGHT_ON_MISSION: nein
UH-60 gespawnt: nein
FLIGHTGROUP erzeugt: nein
SetOptionPreferVertical an FLIGHTGROUP übergeben: nein
Abflug: nein
```

Debrief:

```text
graveyard = {}
```

Einstufung:

```text
G8: BLOCKED_DCS_MOOSE_PARKING_OBSTACLE_CONFLICT
```

Der Lauf ist kein G8-PASS und kein Vertikalstartnachweis.

## 12. Warum direkter SPAWN und WAREHOUSE unterschiedliche Ergebnisse liefern

### 12.1 Direkter G6B-Pfad

Der G6B-Pfad platzierte eine Gruppe gezielt auf einer angegebenen TerminalID. Dieser Test prüfte vor allem, ob DCS die Einheit dort erzeugen kann und ob die visuelle Position akzeptiert wird.

### 12.2 AIRWING-/WAREHOUSE-Pfad

Der produktive G8-Pfad verarbeitet einen dynamischen Ressourcenrequest. Vor dem Spawn ruft MOOSE intern:

```lua
WAREHOUSE:_FindParkingForAssets(airbase, assets)
```

auf.

Die eingebundene MOOSE-Version 2.9.18 enthält lokal festgelegte Werte:

```lua
local scanradius = 25
local scanunits = true
local scanstatics = true
local scanscenery = false
local verysafe = false
```

Zusätzlich wird eine geometrische Überlappungsprüfung durchgeführt:

```lua
local safedist = (l1 / 2 + l2 / 2) * 1.05
local safe = dist > safedist
```

Damit prüft der WAREHOUSE-Pfad nicht nur DCS-`Free`, Terminaltyp und ParkingID, sondern auch:

- Clients;
- Units;
- Statics;
- Objektgrößen;
- Sicherheitsabstand;
- Parking-Whitelist/-Blacklist;
- Anzahl gleichzeitig benötigter Plätze.

Explizit zugewiesene `asset.parkingIDs` begrenzen den Kandidatenpool, umgehen die Hindernisprüfung aber nicht.

## 13. Vermutete aktuelle Parking-Blocker

Für die UH-60-Pools:

```yaml
TerminalIDs: [30, 27, 23]
```

wurden in der Nähe `Revetment_x4`-Statics festgestellt. Ermittelte Nähewerte:

```text
Terminal 30: etwa 11,6 m und 12,4 m
Terminal 27: etwa 10,9 m und 14,2 m
Terminal 23: etwa 10,9 m
```

Diese Statics liegen im 25-Meter-Scanradius und sind die derzeit wahrscheinlichste Ursache der MOOSE-Ablehnung.

Wichtig:

```text
Dies ist eine stark gestützte Diagnose, aber noch kein instrumentierter MOOSE-Debugnachweis mit ausgegebenem obstacle.name pro abgelehntem Platz.
```

Der nächste Test darf deshalb nicht nur erneut denselben Request ausführen. Vorher muss die Ursache entweder durch dokumentierten Override-/Hook-Nachweis oder durch gezielte Parking-Diagnostik eindeutig bestätigt werden.

## 14. Bisher geprüfte öffentliche Einflussmöglichkeiten

### 14.1 ParkingIDs

Wirkung:

```text
Begrenzen erlaubte Kandidaten.
```

Keine Wirkung:

```text
Umgehen nicht die Unit-/Static-/Client-/Overlap-Prüfung.
```

### 14.2 AIRBASE-Parking-White-/Blacklist

Wirkung:

```text
Filtert TerminalIDs.
```

Keine Wirkung:

```text
Hebt die Hindernisprüfung nicht auf.
```

### 14.3 `WAREHOUSE:SetAllowSpawnOnClientParking()`

Wirkung:

```text
Erlaubt grundsätzlich das Verwenden von Client-Parkingpositionen.
```

Bewertung:

```text
Für das Revetment-Problem nicht relevant.
Verletzt zudem die gewünschte Trennung von Client- und KI-Pools.
```

### 14.4 `WAREHOUSE:SetSafeParkingOn()` / `Off()`

Der produktive AIRWING verwendet `SetSafeParkingOn()`.

Bisherige Source-Prüfung zeigt keine ausreichende Grundlage für die Annahme, dass `SetSafeParkingOff()` die lokale Static-/Overlap-Prüfung von `_FindParkingForAssets()` abschaltet.

Daher gilt:

```text
Nicht als Lösung akzeptiert.
Nicht testweise umschalten, solange die genaue interne Wirkung nicht vollständig belegt ist.
```

### 14.5 Airstart

Airstart umgeht Parkingbedarf, zerstört aber den Testzweck des vertikalen Bodenstarts.

```text
Technisch möglich, fachlich unzulässig für G8.
```

## 15. Offene zentrale Recherchefrage

Der Eigentümer hat ausdrücklich angeordnet, alle für MOOSE zuständigen Quellen einschließlich DCS-Forum zu prüfen, ob die lokalen Werte:

```lua
scanradius
scanunits
scanstatics
scanscenery
verysafe
```

trotz fehlender offensichtlicher öffentlicher Setter überschrieben, beeinflusst oder über einen Hook ersetzt werden können.

Zu prüfen sind mindestens:

1. offizielle MOOSE-Klassendokumentation passend zur eingebundenen Version/Branch;
2. MOOSE-Source der exakt eingebundenen Version `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`;
3. aktueller MOOSE-Develop-Source zur Feststellung späterer API-Erweiterungen;
4. MOOSE-Demo- und Testmissionen;
5. MOOSE-GitHub-Issues und Pull Requests;
6. MOOSE-Discord-/Forumreferenzen, soweit öffentlich auffindbar;
7. Eagle-Dynamics-/DCS-Forum;
8. bekannte Lua-Techniken zur Methodenersetzung nur als technische Möglichkeit, klar getrennt von offiziell unterstützter API.

Die Recherche muss unterscheiden zwischen:

```text
offiziell dokumentierter Konfiguration
öffentlich verwendeter, aber interner Methode
Runtime-Monkey-Patch / Method Override
Änderung der Moose.lua
Änderung der Mission-Editor-Geometrie
```

Bis diese Recherche abgeschlossen und dokumentiert ist, darf nicht behauptet werden, es gebe definitiv keinen Override-Pfad.

## 16. Verworfen oder derzeit gesperrt

```text
MIZ-Dateinamen als Gate verwenden
unveränderten G8-Lauf wiederholen
SetSafeParkingOff ohne belegte Wirkung einsetzen
SetAllowSpawnOnClientParking als Revetment-Lösung einsetzen
Airstart als G8-Ersatz verwenden
Raw-SPAWN als Produktionsnachweis verwenden
direkten SPAWN-PASS mit WAREHOUSE-Dispatchfähigkeit gleichsetzen
MOOSE-internen Patch ohne vorherige Framework-/Dokumentationsprüfung einführen
Revetments vorschnell verschieben oder löschen
akzeptierte visuelle Pools ohne Eigentümerentscheidung ersetzen
```

## 17. Aktueller Gate-Stand

```yaml
G0_provenance: PASS_BRANCH
G1_ORBAT_and_evidence: PASS_BRANCH
G2_object_contract: OWNER_ACCEPTED_BRANCH
G3_mission_editor: PARTIAL_FUNCTION_ZONES
G4_MOOSE_source_review: PASS_FOR_LIFECYCLE_BUT_PARKING_OVERRIDE_RESEARCH_OPEN
G5_read_only_diagnostics: PASS_DCS
G6A_geometric_dataset: PASS_DCS_SCOPE_TOO_BROAD_FOR_PRODUCTIVE_LISTS
G6A2_ME_MOOSE_mapping: PASS_DCS
G6B_first_combined_run: FAIL_VISUAL_WRONG_APRON
G6B_final_free_spots: PASS_DCS_OWNER_VISUAL_ACCEPTED_DIRECT_SPAWN_ONLY
G7_airwing_squadron_payload: PASS_DCS_WITH_TELEMETRY_FIELD_CORRECTION
G7_lifecycle_guard_correction: PASS_STATIC_CI
central_lifecycle_consolidation: PASS_MAIN
Tarinkot_main_sync: PASS
G8_static_implementation: PASS_STATIC_CI
G8_first_runtime_attempt: BLOCKED_MISSING_TARGET_ZONE
G8_second_runtime_attempt: BLOCKED_MOOSE_WAREHOUSE_PARKING_OBSTACLE_CONFLICT
G8_vertical_departure: NOT_PROVEN
G9_commander: BLOCKED_BY_G8
G10_lifecycle_results_handoff: NOT_STARTED
```

## 18. Exakter Wiederaufnahme-Punkt

Die Arbeit wird nicht mit einem weiteren DCS-Lauf fortgesetzt.

Der nächste zulässige Arbeitsschritt ist ausschließlich:

```text
Vollständige Recherche und Dokumentation der Überschreibbarkeit beziehungsweise Beeinflussbarkeit der lokalen `_FindParkingForAssets()`-Parameter in MOOSE, einschließlich offizieller Dokumentation, Source, Demos, Issues/PRs und DCS-Forum.
```

Erst danach ist eine neue Entscheidung zulässig zwischen:

```text
A: offiziell unterstützte Konfiguration verwenden
B: vorhandenen MOOSE-Hook/Override verwenden
C: eng begrenzten und dokumentierten Runtime-Override entwickeln
D: Mission-Editor-Geometrie anpassen
E: andere nach WAREHOUSE-Kriterien freie ParkingIDs auswählen
```

Keine dieser Varianten ist mit diesem Snapshot bereits freigegeben.

## 19. Zusammenfassende Festlegung

```text
G7 ist akzeptierte technische Foundation.
G8 hat den nativen AIRWING-/AUFTRAG-Pfad bis zur WAREHOUSE-Parkingselektion erreicht.
Die Zielzone funktioniert.
Der UH-60 wurde nicht gespawnt.
Ein vertikaler Abflug wurde nicht nachgewiesen.
Die akzeptierten G6B-Pools sind visuell und direkt-spawnseitig akzeptiert, aber für WAREHOUSE noch nicht validiert.
Die wahrscheinlichsten Blocker sind nahe Revetment-Statics.
Ob die internen Parking-Scanparameter unterstützt überschrieben werden können, ist offen und muss umfassend recherchiert werden.
Der gesamte technische Stand ist hiermit eingefroren.
```
