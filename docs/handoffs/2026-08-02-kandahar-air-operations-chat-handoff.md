---
document_id: OMW-HANDOFF-KANDAHAR-AIROPS-2026-08-02
status: WORKING_HANDOFF
document_class: PROJECT_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - continuation context for the Kandahar AirOps work after PR 47
  - accepted versus open Kandahar AIRWING and SQUADRON scope
  - required reading order for a successor ChatGPT conversation
not_authoritative_for:
  - project governance that is already owned by main documentation
  - new implementation decisions
  - runtime acceptance beyond the cited evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
validated_in_dcs: true
handoff_time_local: 2026-08-02T02:25:00+02:00
---

# Kandahar AirOps – Chat-Handover nach PR #47

## 1. Verbindlicher Einstieg für den neuen Chat

Der neue Chat darf nicht ausschließlich aus diesem Handover arbeiten. Vor jeder Änderung sind mindestens folgende Bereiche zu lesen und gegeneinander abzugleichen:

### Auf `main`

```text
docs/00-project-governance.md
docs/README.md
docs/DOCUMENT-REGISTRY.md
docs/SUBPROJECT-REGISTRY.md
docs/26-moose-first-development-policy.md
docs/moose/VERSION-AND-SOURCES.md
```

Diese Dokumente bestimmen Arbeitsweise, Autorität, Branch-Status, Dokumentationspflichten, MOOSE-First und die verwendbare MOOSE-Dokumentation.

### Auf dem Kandahar-Integrations-/Arbeitsstand

```text
mission/air-operations/kandahar/README.md
mission/air-operations/kandahar/results/2026-08-02-normalized-foundation-smoke-v2-pass.md
docs/evidence/kandahar-uav-parking-restriction-decision-2026-08-01.md
mission/tests/kandahar-air-operations/
tools/build-omw-airops-kandahar.ps1
mission/air-operations/kandahar/src/01-kandahar-foundation-start.lua
```

Die Arbeitsweise und alle verbindlichen Absprachen sind aus der Dokumentation zu übernehmen. Dieses Handover ersetzt keine Governance-, MOOSE- oder Acceptance-Dokumentation.

## 2. Repository- und Branch-Stand

Repository:

```text
birkenmoped/Operation-Mountain-Watch
```

Lokaler Projektpfad des Projektinhabers:

```text
P:\DCS-DEV\Operation-Mountain-Watch
```

Default-Branch:

```text
main
```

Wichtiger Hinweis: Der Kandahar-Code aus PR #47 wurde nicht direkt nach `main`, sondern in den damaligen Integrationsbranch gemergt.

```text
PR:            #47
Titel:         Implement and validate Kandahar AIRWING/SQUADRON foundation
Featurebranch: agent/kandahar-airwing-baseline-contract
Zielbranch:    docs/bagram-air-operations-manifest
PR-Head:       dd9ea3f60ecf581b0d0a9e4a3e4ff3f4f94813d3
Merge-Commit:  3fdd9425c86fbbc377da386e3995c2c060068fd1
Status:        closed / merged / not draft
```

Damit gilt:

- `main` bleibt die Autorität für Governance und projektweite Grundsatzentscheidungen.
- `docs/bagram-air-operations-manifest` enthält den gemergten Kandahar-AIRWING-/SQUADRON-Stand aus PR #47.
- `agent/kandahar-airwing-baseline-contract` bleibt als vollständiger Entwicklungs- und Evidenzstand erhalten, ist aber ein bereits gemergter Featurebranch.
- Neue Kandahar-Entwicklung soll nicht stillschweigend als weitere Arbeit auf dem abgeschlossenen PR-Branch erfolgen. Zuerst Branch-Strategie festlegen und einen neuen, klar benannten Branch vom aktuellen Integrationsstand anlegen.

## 3. Abgeschlossener Kandahar-Foundation-Stand

Status:

```text
RUNTIME_ACCEPTED_NO_TASKING_FOUNDATION
```

Normalisierte Produktionsdatei:

```text
mission/air-operations/dist/OMW_AIROPS_KANDAHAR.lua
```

Builder:

```text
tools/build-omw-airops-kandahar.ps1
BuilderVersion: OMW-AIROPS-KANDAHAR-FOUNDATION-2
```

Die Datei enthält absichtlich keine taktischen Aufträge und keine automatische Anforderung von Luftfahrzeugen.

### AIRWINGs

```text
Main:
AW_US_KAF_451_AEW
WH_AIR_US_KANDAHAR
AIRBASE.Afghanistan.Kandahar
runtime airbase ID 7

Heliport:
AW_US_KAF_159_CAB_TF_THUNDER
WH_AIR_US_KANDAHAR_HELI
AIRBASE.Afghanistan.Kandahar_Heliport
runtime airbase ID 15
```

Beide AIRWINGs werden von der Foundation gestartet.

### SQUADRONs

```text
SQ_US_KAF_A10C_74_EFS
SQ_US_KAF_HH60G_26_ERQS
SQ_US_KAF_C130_772_EAS
SQ_US_KAF_MQ1_361_ERS
SQ_US_KAF_MQ9_361_ERS
SQ_US_KAF_AH64_4_227_AVN
SQ_US_KAF_OH58D_7_17_CAV
SQ_US_KAF_CH47_7_101_GSAB
SQ_US_KAF_UH60_7_101_GSAB
```

Verbindliche historische Zuordnung:

```text
AH-64D in Kandahar = TF Guns / 4-227 Attack Aviation
```

Nicht auf `3-101` umdeuten.

### Physischer Bestand

```text
A-10C:   16
HH-60G:   6, technisch über UH-60A
C-130:   12
MQ-1:     4
MQ-9:     2
AH-64D:   8
OH-58D:  16
CH-47:   16
UH-60:   32
----------------
Gesamt: 112 registrierte physische Luftfahrzeuge
```

Zusätzlich:

```text
MC-12: 6 logisch zurückgestellt, keine freigegebene physische DCS-Repräsentation
```

Visuelle Statics dürfen nicht ohne dokumentierte Provenienz als Warehouse-Inventar interpretiert werden.

## 4. Parking- und UAV-Verträge

Runtime-abgenommene Parking-Basis:

```text
Kandahar Main:
total=316
allowed=302
blocked=14

Kandahar Heliport:
total=86
allowed=59
blocked=27

Client reservations=10
classified US aircraft statics=47
```

### Verbindliche G-Apron-Aufteilung für den initialen Spawn

```text
MQ-1: G01-G08
MQ-9: G09-G11
kein Cross-Use
kein unrestricted Main-airfield fallback
```

Kalibrierte TerminalIDs:

```text
G01 -> 189
G02 -> 303
G03 -> 202
G04 -> 224
G05 -> 46
G06 -> 291
G07 -> 129
G08 -> 143
G09 -> 27
G10 -> 54
G11 -> 263
```

Mit den normalen Produktions-Statics verfügbar:

```text
MQ-1:
G01,G04,G05,G06,G07,G08
TerminalIDs 46,129,143,189,224,291
G02/G03 durch MQ-1-Statics blockiert

MQ-9:
G09,G10,G11
TerminalIDs 27,54,263
```

Die gefilterten Listen sind sowohl auf `SQUADRON.parkingIDs` als auch auf die bereits registrierten UAV-Warehouse-Assets synchronisiert. Der kontrollierte initiale Spawn beider UAV-Typen wurde runtime-abgenommen.

## 5. Wichtige offene UAV-Grenze

Der vollständige Rückkehrtest bewies:

- beide UAVs können über MOOSE/AIRWING/AUFTRAG starten, fliegen, nach Kandahar zurückkehren und landen;
- die No-Despawn-Korrektur verhindert den unmittelbaren Despawn nach dem Aufsetzen;
- DCS wählt den endgültigen Parkplatz nach der Landung jedoch nativ und außerhalb der typspezifischen G-Pools;
- beobachtet wurden MQ-9 auf TerminalID 81 und MQ-1 auf TerminalID 157;
- `SQUADRON:SetParkingIDs()` und `asset.parkingIDs` gelten daher als abgenommen für den initialen Spawn, nicht für den finalen Stand nach der Landung.

Aktueller Status:

```text
UAV initial spawn restriction: PASS
UAV final parking restriction: FAIL / technisch offen
Warehouse return after landing: not accepted
```

Keine stille Ersatzlösung akzeptieren, die nur nach der Landung despawnt und auf G01-G11 neu spawnt, wenn die Anforderung weiterhin echtes Taxi-in und finales Parking auf der G-Fläche lautet.

## 6. Finaler normalisierter Smoke-Test

DCS:

```text
DCS 2.9.28.26385
Application revision 266385
Afghanistan terrain revision 7067
```

Abgenommene Marker:

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
[OMW][AirOps.KAF.UAVParkingContract] RESULT: PASS
[OMW][AirOps.KAF.UAVAssetParkingSync] RESULT: PASS
[OMW][AirOps.KAF.Foundation] RESULT: READY
```

Foundation-Ergebnis:

```text
airwings=2
squadrons=9
registeredAirframes=112
deferredMC12=6
mainRunning=true
heliportRunning=true
missionsCreated=0
payloadsRegistered=0
commanderAttached=false
transportCreated=false
directSpawnRequested=false
uavInitialSpawnRestricted=true
uavFinalParkingRestricted=false
```

Der 120,785-Sekunden-Lauf enthielt keinen dynamischen Kandahar-Birth, keine dynamische `SQ_US_KAF`-Gruppe und keinen Graveyard-Eintrag.

## 7. Runtime-API für spätere Module

Spätere Module müssen die vorhandenen Objekte verwenden und dürfen keine doppelten Kandahar-AIRWINGs oder SQUADRONs konstruieren.

```lua
OMW.AirOps.Kandahar.Airwings.Main
OMW.AirOps.Kandahar.Airwings.Heliport
OMW.AirOps.Kandahar.Squadrons
OMW.AirOps.Kandahar.Parking.Main
OMW.AirOps.Kandahar.Parking.Heliport
OMW.AirOps.Kandahar.UAVParking.MQ1
OMW.AirOps.Kandahar.UAVParking.MQ9
OMW.AirOps.Kandahar.Inventory
OMW.AirOps.Kandahar.KnownLimitations
```

## 8. Absichtlich noch nicht enthalten

```text
taktische AUFTRAG-Profile
Payload-Kataloge
OPSTRANSPORT
COMMANDER/CHIEF-Integration
Warehouse stock return/reconciliation nach Landung
persistente Verlust-/Rückgabelogik
MC-12 physical representation
belastbare post-landing UAV stand selection im G-Pool
```

Der nächste fachliche Increment ist in diesem Handover nicht vorentschieden. Der neue Chat soll zuerst Dokumentation, Branchlage und offene Abhängigkeiten prüfen und dann mit dem Projektinhaber genau einen abgegrenzten nächsten Increment festlegen.

## 9. Verbindliche Arbeitsweise für die Fortsetzung

1. MOOSE-First: Vor eigenem Lua-Code zuerst die zur eingebundenen MOOSE-Version passende offizielle Klasse/API prüfen.
2. Keine Objekt-, Unit-, Inventar-, Parking- oder Contract-Namen erfinden.
3. Test- und Produktionslogik strikt trennen.
4. Runtime-Acceptance nur für den exakt getesteten Branch-, Commit-, Mission-, DCS- und MOOSE-Stand behaupten.
5. PRs bleiben Draft und ungemergt, bis der Projektinhaber ausdrücklich Ready-for-Review beziehungsweise Merge freigibt.
6. Entscheidungen und Runtime-Ergebnisse unmittelbar im Repository dokumentieren.
7. Bei Änderungen zuerst Bestandsaufnahme, dann genau ein abgegrenzter Increment.
8. `gh` ist in der bisherigen Umgebung nicht verfügbar; GitHub-Änderungen wurden über den GitHub-Connector durchgeführt.

## 10. Empfohlener Start im neuen Chat

Zuerst den lokalen Stand prüfen:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch
git status --short
git fetch --all --prune
```

Dann die Autorität auf `main` lesen und den Kandahar-Integrationsstand prüfen:

```powershell
git switch main
git pull --ff-only origin main

git switch docs/bagram-air-operations-manifest
git pull --ff-only origin docs/bagram-air-operations-manifest
```

Vor neuer Entwicklung einen neuen Branch vom abgestimmten Integrationsstand anlegen, beispielsweise erst nach Benennung des nächsten Increments:

```text
agent/kandahar-<next-increment>
```

## 11. Kopierbarer Übergabeprompt für einen neuen Chat

```text
Du übernimmst die weitere Arbeit an Operation Mountain Watch – Kandahar AirOps.

Repository: birkenmoped/Operation-Mountain-Watch
Lokaler Pfad: P:\DCS-DEV\Operation-Mountain-Watch

PR #47 wurde erfolgreich gemergt:
- Featurebranch: agent/kandahar-airwing-baseline-contract
- Zielbranch: docs/bagram-air-operations-manifest
- PR-Head: dd9ea3f60ecf581b0d0a9e4a3e4ff3f4f94813d3
- Merge-Commit: 3fdd9425c86fbbc377da386e3995c2c060068fd1

Lies vor jeder Arbeit zwingend die Governance und Dokumentationsautorität auf main sowie die Kandahar-Dokumentation auf dem Integrations-/Arbeitsbranch. Insbesondere:
- docs/00-project-governance.md
- docs/README.md
- docs/26-moose-first-development-policy.md
- docs/moose/VERSION-AND-SOURCES.md
- docs/handoffs/2026-08-02-kandahar-air-operations-chat-handoff.md
- mission/air-operations/kandahar/README.md
- mission/air-operations/kandahar/results/2026-08-02-normalized-foundation-smoke-v2-pass.md
- docs/evidence/kandahar-uav-parking-restriction-decision-2026-08-01.md

Die Arbeitsweise und Absprachen sind aus der Dokumentation zu übernehmen.

Abgenommen sind zwei Kandahar-AIRWINGs, neun SQUADRONs, 112 physische Airframes, sechs deferred MC-12, Main-/Heliport-Safe-Parking sowie die typspezifischen MQ-1-/MQ-9-Initial-Spawn-Pools. OMW_AIROPS_KANDAHAR.lua ist als no-tasking/no-spawn Foundation runtime-abgenommen.

Nicht abgenommen sind insbesondere post-landing UAV final parking im G-Pool, Warehouse return/reconciliation, Payload-Kataloge, taktische AUFTRAG-Profile, OPSTRANSPORT, COMMANDER und persistente Verlustlogik.

Konstruiere keine doppelten AIRWING-/SQUADRON-Objekte. Nutze OMW.AirOps.Kandahar. Vor eigenem Lua-Code ist zwingend zu prüfen, ob MOOSE die Funktion bereits bereitstellt.

Beginne mit einer Bestandsaufnahme der genannten Dokumente und Branches. Nimm noch keine Codeänderung vor, bevor der nächste klar abgegrenzte Kandahar-Increment mit dem Projektinhaber festgelegt wurde.
```
