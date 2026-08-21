---
document_id: OMW-PLAN-TM01-TM02-MOOSE-ADOPTION
status: PLANNED
document_class: IMPLEMENTATION_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - proposed MOOSE adoption order for TM01 and TM02
  - module replacement and verification plan
not_authoritative_for:
  - completed production adoption
  - non-MOOSE exception approval
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: review/tm01-tm02-moose-first
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 40 – MOOSE-Adoptionsplan für TM01 und TM02

## 1. Status und Einordnung

```text
Status: PLANNED
Implementation planning: started
```

Dieses Dokument setzt die Ergebnisse aus Dokument 39 in eine kontrollierte Prüf- und Adoptionsreihenfolge um.

Der vollständige bisherige Plan bleibt unverändert erhalten:

- [`Legacy-Adoptionsplan`](evidence/source-records/legacy-40-moose-module-adoption-plan.md)

## 2. Verbindliche Regel

CampaignState und projektspezifische Fachpolitik bleiben OMW-Verantwortung. MOOSE übernimmt die Laufzeitorchestrierung, wo eine passende Klasse vorhanden und im verwendeten Stand nachgewiesen ist.

Eine technisch notwendige Eigenlogik ist nicht automatisch genehmigt. Produktionsnutzung erfordert die ausdrückliche Projektinhaberfreigabe nach Dokument 00 und 26.

## 3. Vorrangige MOOSE-Prüfziele

- `Functional.Movement`;
- `Core.Pathline`;
- `Core.Astar`;
- `Core.MarkerOps_Base`;
- `Core.Goal`;
- `Core.Message`;
- `Core.SpawnStatic`;
- `Core.Scheduler`;
- `Core.Fsm`;
- `Wrapper.Group`;
- `Ops.ArmyGroup` und `Ops.OpsGroup`;
- MOOSE-`SET_*`-Klassen und Eventhandling.

## 4. Geplante Zuordnung

| Problemklasse | Primärer MOOSE-Kandidat | OMW-Verantwortung |
|---|---|---|
| globale Bewegungsbegrenzung | `MOVEMENT` | Kampagnenpriorität und Freigabepolitik |
| geprüfte Routengeometrie | `PATHLINE` | Segmentdaten und Missionsdesign |
| Netzwerkpfadwahl | `Core.Astar` | Kosten, Eignung und strategische Regeln |
| Meldungen | `MESSAGE` | Inhalt, Sprache und Empfängerpolitik |
| Zeitsteuerung | `SCHEDULER` | fachliche Intervalle und Abbruchbedingungen |
| Zustandsautomaten | `FSM` | Kampagnenzustände und Persistenz |
| Gruppenlebenszyklus | `GROUP` / `OPSGROUP` / `ARMYGROUP` | stabile IDs und strategische Folgen |

## 5. Adoptionskriterien

Ein Modul gilt erst als produktiv übernommen, wenn:

- API und Signatur im gepinnten MOOSE-Stand geprüft sind;
- Abhängigkeiten und Initialisierungsreihenfolge dokumentiert sind;
- ein reproduzierbarer DCS-Test vorliegt;
- Regressionen gegen den bisherigen Teststand geprüft sind;
- verbleibende Eigenlogik separat genehmigt ist;
- CampaignState und MOOSE keine parallele Autorität besitzen.

## 6. TM01M – Reconciliation als historischer Machbarkeitsnachweis

### 6.1 Owner-Klarstellung 2026-08-21

`TM01M` war ein Machbarkeits- und Regressionstest für physische MOOSE-Konvois. Es war nie als strategische Logistik-, CampaignState-, Warehouse- oder Settlement-Schicht gedacht.

Der Projektinhaber entfernt `LOAD_TM01M` bei nächster geeigneter Gelegenheit selbst aus der Missionsdatei. Es wird kein produktiver `TM01M`-Nachfolger nur deshalb eingeführt, weil der Test aus der `.miz` verschwindet.

Damit ist die frühere Annahme verworfen, `TM01M` müsse gegen `OMW_Ground_Base.lua` auf Ressourcen-, Settlement-, Restart- oder Warehouse-Funktionen zerlegt werden.

Verbindliche Abgrenzung:

```text
TM01M
= HISTORICAL_TEST_FIXTURE / technische Convoy-Evidenz

OMW_Ground_Base.lua
= produktive strategische Ground-Integration
  - Ground-Initialbestände
  - Ground-CampaignState-Adapter
  - Settlement / Return / Loss
  - Restart-Reconciliation

TM01M hatte keine Zuständigkeit für:
  - Warenbewegung als strategische Buchung
  - Warehouse Debit/Credit
  - CampaignState-Ressourcenhoheit
  - Settlement
  - Loss-Reconciliation
  - Restart-Reconciliation
```

### 6.2 Tatsächlich bestätigter TM01M-Scope

Die maßgebliche TM01M-Dokumentation auf `feature/tm01m-moose-native-baseline` beschreibt den Test als saubere MOOSE-native physische Convoy-Baseline. Verwendet wurden insbesondere:

```lua
PATHLINE:FindByName(...)
PATHLINE:GetNumberOfPoints()
PATHLINE:GetPoint2DFromIndex(...)

COORDINATE:GetClosestPointToRoad(...)
COORDINATE:GetPathOnRoad(...)

SPAWN:InitSetUnitAbsolutePositions(...)
GROUP:Route(...)
SCHEDULER:New(...)
GROUP:Destroy(false, 60)
```

Die älteren TM01B-/TM01C-Mechanismen für Proxy, Caching, Virtualisierung, Pack/Unpack, Reveal Window, Watchdog, Recovery oder Teleport gehörten ausdrücklich nicht zu TM01M.

### 6.3 DCS-bestätigte technische Erkenntnisse

#### A. Road-aligned Spawn

Der TM01M-PASS vom 26.07.2026 bestätigte für den exakt dokumentierten Stand:

```text
Branch: feature/tm01m-moose-native-baseline
Commit: 0db10501f81c160cd5818088e760af181b33d86d
Configuration: TM01M-moose-native-msr-pathline-1
DCS: 2.9.28.26283
```

Nachgewiesen wurde ein straßengerechter absoluter Spawn aller sechs Fahrzeuge über MOOSE `SPAWN:InitSetUnitAbsolutePositions(...)`, einschließlich korrekter Fahrzeugausrichtung entlang der vorgesehenen Fahrtrichtung.

Der spätere Fünf-Konvoi-PASS bestätigte dieselbe Grundfunktion parallel für:

```text
Branch: feature/tm01m-moose-native-baseline
Commit: da2714af9d312d92913a0b325ca3c2e8e91f8064
Configuration: TM01M-moose-native-five-convoys-1
DCS: 2.9.28.26283
5 Convoys
30 vehicles total
50 km/h
On Road
```

Alle 30 Fahrzeuge wurden visuell korrekt straßengerecht positioniert und ausgerichtet.

#### B. PATHLINE-basierte MSR-Führung

TM01M bestätigte praktisch:

```text
Mission Editor PATHLINE
-> MOOSE PATHLINE readout
-> automatische Vorwärts-/Rückwärtsorientierung
-> Verkettung mehrerer MSR-Segmente
-> Road Connector vom Startknoten zur PATHLINE
-> Road Connector von PATHLINE zum Zielknoten
```

Im Single-Convoy-PASS wurde die vollständige Route von Bagram über `MSR_EAST_E03` und `MSR_EAST_E02` bis Jalalabad gefahren.

Im Fünf-Konvoi-PASS wurden sechs Mission-Editor-PATHLINEs für fünf parallele Konvois erfolgreich verwendet; alle 30 Fahrzeuge erreichten ihre vorgesehenen Zielzonen.

#### C. MOOSE Route Execution

`GROUP:Route(...)` wurde im dokumentierten TM01M-Scope praktisch bestätigt. Die erzeugten Ground-Routen wurden mit `On Road` und den konfigurierten Geschwindigkeiten tatsächlich ausgeführt.

Diese Evidenz bestätigt die konkrete MOOSE-/DCS-Machbarkeit des getesteten Pfades. Sie erzeugt keine allgemeine Freigabe für beliebige Ground-Routen oder andere DCS-/MOOSE-Stände.

### 6.4 Beziehung zur späteren Ground Foundation

Die aus TM01M gewonnene Road-Spawn-Erkenntnis wurde später in der ARMY-Ground-Acceptance 3-2 erneut für den BRIGADE/WAREHOUSE-Pfad genutzt.

Wichtig ist die Trennung:

```text
TM01M
-> erster praktischer Nachweis der road-aligned Spawn-Geometrie
   über MOOSE SPAWN absolute unit positions

Ground Acceptance 3-2
-> spätere Anwendung derselben geometrischen Grundidee
   innerhalb des MOOSE BRIGADE/WAREHOUSE-Materialisierungspfades
```

Acceptance 3-2 ist deshalb der relevantere Nachweis für die heutige Ground-Foundation-Integration. Der TM01M-PASS bleibt zusätzliche technische Evidenz und darf nicht verloren gehen.

### 6.5 Was aus TM01M nicht als Produktionsarchitektur übernommen wird

Nicht aus TM01M abzuleiten oder als eigenes Produktionssystem zu übernehmen sind:

```text
- eigener Ground Mission Controller
- eigener strategischer Convoy-/Logistikzustand
- eigene Warehouse- oder CampaignState-Buchung
- eigene Settlement-/Restart-FSM
- eigener Route Catalog als Parallelarchitektur
- eigene Pathfinding-Engine
- permanenter TM01M Scheduler/Bootstrap
- Testmenüs und Testdiagnostik als Production Runtime
```

Für konkrete produktive Ground-Missionen bleibt MOOSE-first verbindlich. Die TM01M-Erkenntnisse sind dabei geprüfte Baustein-Evidenz, keine Verpflichtung, den historischen Testcode weiterzuführen.

### 6.6 Verbleibende TODOs für diesen Reconciliation-Scope

```text
[x] TM01M als Machbarkeitstest statt Production Runtime eingeordnet
[x] bestätigt: road-aligned Spawn ist praktisch nachgewiesen
[x] bestätigt: PATHLINE-basierte MSR-Führung ist praktisch nachgewiesen
[x] bestätigt: MOOSE GROUP:Route-Ausführung ist praktisch nachgewiesen
[x] bestätigt: TM01M hatte keine strategische Warehouse-/CampaignState-/Settlement-Funktion
[x] kein produktiver TM01M-Nachfolger erforderlich

[ ] docs/moose/PROJECT-CLASS-INDEX.md um den dokumentierten TM01M-Scope ergänzen
[ ] passende Ground-/MOOSE-Themendokumentation mit der Evidenz synchronisieren
[ ] Dokumentationsvalidator ausführen und vollständigen Diff prüfen
[ ] LOAD_TM01M wird vom Projektinhaber aus der `.miz` entfernt
```

Für die Entfernung von `LOAD_TM01M` ist keine neue Lua-Implementierung erforderlich.

### 6.7 Abschlussgrenze

Der TM01M-Reconciliation-Scope ist fachlich abgeschlossen, sobald die bestätigten technischen Erkenntnisse dauerhaft in der aktuellen MOOSE-/Ground-Dokumentation verankert sind.

Danach gilt:

```text
TM01M runtime
-> kann aus der Mission entfernt werden

TM01M evidence
-> bleibt als exakter historischer DCS-Testnachweis erhalten

Production Ground execution
-> wird aus den aktuellen Ground-Foundations und konkreten MOOSE-Missionen entwickelt
```

Der nächste große Integrationsfokus bleibt damit wie in der Projektübergabe vorgesehen bei der Orchestrierung der vorhandenen Foundations, nicht bei einer Weiterentwicklung von TM01M.
