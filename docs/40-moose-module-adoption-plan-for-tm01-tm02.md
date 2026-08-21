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

## 6. TODO – TM01M gegen Ground Production Base reconciliieren

### 6.1 Ziel

`TM01M` soll nur noch die Ground-Laufzeitfunktion behalten, die nach Einführung der produktiven `OMW_Ground_Base.lua` tatsächlich noch benötigt wird. Doppelte Zuständigkeiten für CampaignState, Ressourcen, Settlement, Restart-Reconciliation oder Ground-Lifecycle dürfen nicht bestehen bleiben.

Der Zielzustand ist:

```text
CampaignState / Warehouse Production Base
  -> einzige strategische Ressourcenautorität

OMW_Ground_Base.lua
  -> Ground-Initialbestände
  -> Ground-CampaignState-Adapter
  -> Settlement / Return / Loss
  -> Restart-Reconciliation

TM01M oder Nachfolger
  -> nur noch notwendige physische Convoy-Ausführung
  -> Spawn-Platzierung / Marschordnung, soweit weiterhin benötigt
  -> Routing / Movement, soweit MOOSE dafür keinen bereits geeigneteren produktiven Pfad stellt
  -> Watchguard nur soweit nach MOOSE-Prüfung weiterhin erforderlich
  -> keine parallele Ressourcenhoheit
```

Wenn nach der Reconciliation keine eigenständige produktive Aufgabe für `TM01M` verbleibt, wird `LOAD_TM01M` aus dem produktiven Startup entfernt, statt das Modul künstlich weiterzuführen.

### 6.2 Aktueller Stand

Aktuelle Repository- und Missionsbaseline:

```text
main: 4bc42557d64b089db7c697ec2bd9579d3efe6a8e
Mission: OMW_Template_v14_ground_test(8).miz
```

Dokument 38 führt derzeit folgende relevante Startup-Reihenfolge:

```text
T+1  LOAD_AIROPS_WAREHOUSE_BASE
T+2  LOAD_GROUND_BASE
     Bedingung: OMW_WAREHOUSE_READY == 1
T+6  LOAD_TM01M
     derzeit ohne dokumentierten Ground-Ready-Gate
```

Die produktive Ground Base ist auf `main` vorhanden. Ihr dokumentierter Scope umfasst strategische Ground-Bestände, CampaignState-Adapter, Settlement und Restart-Reconciliation. Sie enthält ausdrücklich keine neue MOOSE-/DCS-Spawn-, Routing-, Warehouse- oder Schedulerlogik.

Der ältere TM01-Review beschreibt als TM01-Funktionsfelder unter anderem:

- Convoy-Spawn und Routenausführung;
- Pack/Unpack beziehungsweise Repräsentationswechsel;
- CampaignState-Abbildung;
- Player-/Representation-Interest;
- Watchguard und Stuck-Recovery;
- Scheduler, Events, Sets und Group-Wrapper.

PR #22 / Branch `feature/tm01m-moose-native-baseline` bleibt laut Unterprojektregister ein offener Draft mit branchgebundenen Ein- und Fünf-Convoy-PASS-Nachweisen. Dieser Stand ist Evidenz für die bevorzugte MOOSE-native Convoy-Richtung, aber keine aktuelle `main`-Produktionsautorität.

Damit ist aktuell **nicht** ausreichend geklärt, welcher konkrete Teil des in der v14-MIZ geladenen `TM01M` nach den inzwischen gemergten Ground-Acceptances noch produktiv erforderlich ist.

### 6.3 Zu erledigende Schritte

#### Schritt 1 – Exakten TM01M-Ist-Stand sichern

- [ ] Exakte `TM01M.lua` aus der aktuell verwendeten v14-MIZ beziehungsweise aus ihrer nachweisbaren Source erfassen.
- [ ] SHA-256 der tatsächlich geladenen Datei bestimmen.
- [ ] Herkunft, Branch und Commit dokumentieren; nichts aus älteren TM01-Branches stillschweigend als identisch annehmen.
- [ ] PR #22 und dessen aktuellen Branch-Head nur als historische/branchgebundene Evidenz danebenstellen.
- [ ] Aktuell geladenen `Moose.lua`-Commit und SHA-256 für die spätere API-Prüfung festhalten.

**Ergebnis:** Es gibt genau einen nachweisbaren TM01M-Codebestand, gegen den reconciliert wird.

#### Schritt 2 – Funktionsinventar des real geladenen TM01M erstellen

Jede Funktion des geladenen Moduls einer Kategorie zuordnen:

```text
A  strategische Ressourcen / CampaignState
B  Settlement / Return / Loss / Restart
C  physischer Spawn / Road-Aligned Placement
D  Route / Movement / Mission Assignment
E  Watchguard / Stuck Recovery
F  Representation / Pack-Unpack / Interest
G  Scheduler / Events / Messaging / Marker
H  reine Diagnose / Testfunktion
```

Für jede Funktion dokumentieren:

- [ ] fachlicher Zweck;
- [ ] aufgerufene MOOSE-Klasse/-Methode;
- [ ] Native-DCS- oder eigene Hilfslogik;
- [ ] gelesener/geänderter CampaignState;
- [ ] erzeugte/entfernte DCS-Gruppen;
- [ ] Abhängigkeit von Mission-Editor-Templates/Zonen;
- [ ] heutiger Aufrufer und Startup-Abhängigkeit.

**Ergebnis:** Keine Funktionsentscheidung erfolgt allein aufgrund des Dateinamens oder früherer Testbeschreibungen.

#### Schritt 3 – Gegen die heutige Ground Production Base abgleichen

Für jede TM01M-Funktion entscheiden:

- [ ] `ALREADY_OWNED_BY_GROUND_BASE` – aus TM01M entfernen/nicht mehr produktiv verwenden;
- [ ] `MOOSE_DIRECT` – durch vorhandene MOOSE-Funktion abbilden;
- [ ] `MOOSE_ADAPTER` – kleiner OMW-Adapter um MOOSE bleibt erforderlich;
- [ ] `PROJECT_DOMAIN` – echte OMW-Fachlogik, die außerhalb MOOSE bleiben muss;
- [ ] `HISTORICAL_TEST_ONLY` – nicht in Produktion übernehmen;
- [ ] `UNRESOLVED` – erst nach weiterer MOOSE-/DCS-Prüfung entscheidbar.

Insbesondere sind als bereits durch die Ground-Foundation besetzt zu behandeln:

```text
strategische Resource Authority
Return-/Loss-Settlement
beschädigte Rückkehrer -> sofort verfügbar
permanenter Verlust
Restart-Reconciliation offener Aufträge
keine physische Missionsfortsetzung/Respawns nach Serverende
```

**Ergebnis:** Es existiert nur noch eine Zuständigkeit je Ground-Lifecycle-Funktion.

#### Schritt 4 – MOOSE-First-Prüfung für die verbleibenden physischen Funktionen

Vor neuer oder weitergeführter Eigenlogik verbindlich prüfen:

1. passende MOOSE-Dokumentation;
2. tatsächlich verwendete `Moose.lua`;
3. Signaturen, Events, FSMs, Voraussetzungen und Rückgaben;
4. offizielle MOOSE-Demos/Tests, soweit vorhanden.

Mindestens gegen den realen Bedarf prüfen:

```text
ARMYGROUP / OPSGROUP / GROUP
AUFTRAG
MOVEMENT
PATHLINE
Core.Astar
SCHEDULER
FSM
SET_* und Eventhandling
OPSTRANSPORT, falls Infantry-/Transportaufgaben betroffen sind
```

`docs/moose/PROJECT-CLASS-INDEX.md` und gegebenenfalls `VERIFIED-METHODS.md` sind im selben Änderungsscope zu aktualisieren, sobald eine neue MOOSE-Nutzung festgelegt wird.

**Ergebnis:** Eigene TM01M-Mechanik bleibt nur dort bestehen, wo die konkrete MOOSE-Lücke nachgewiesen ist.

#### Schritt 5 – Zielvertrag für Convoys festlegen

Der produktive Convoy-Pfad muss mindestens eindeutig festlegen:

- [ ] wer Ressourcen vor Dispatch reserviert/debitiert;
- [ ] wer das physische Template auswählt;
- [ ] wer die straßenorientierte Spawn-Platzierung ausführt;
- [ ] wer `ARMYGROUP`/`AUFTRAG` erzeugt beziehungsweise übernimmt;
- [ ] wer Route und Rückkehr anstößt;
- [ ] wer Schäden/Verluste meldet;
- [ ] wer Settlement ausführt;
- [ ] wer die physische Gruppe nach abgeschlossenem Return entfernt;
- [ ] wie ein Serverende während eines offenen Auftrags behandelt wird.

Verbindlich bleibt:

```text
TM01M darf CampaignState nicht parallel zu OMW_Ground_Base verwalten.
```

#### Schritt 6 – Startup-Vertrag bereinigen

`LOAD_TM01M` darf nicht lediglich aufgrund von `TIME MORE (6)` als produktiv bereit angenommen werden.

Zu entscheiden und umzusetzen ist eine der beiden sauberen Varianten:

```text
Variante A
OMW_GROUND_READY erfolgreich
  -> TM01M/Nachfolger initialisieren

Variante B
TM01M wird nicht mehr separat benötigt
  -> LOAD_TM01M vollständig aus der Produktions-MIZ entfernen
```

Falls ein Ready-Gate technisch über Lua statt über einen DCS User Flag erfolgt, muss das fail-closed Verhalten dokumentiert und statisch geprüft werden. Kein zusätzliches globales Ready-System ohne Notwendigkeit einführen.

#### Schritt 7 – Kleinste notwendige Implementierung

Erst nach Abschluss der Schritte 1–6:

- [ ] redundante TM01M-Teile entfernen oder isolieren;
- [ ] verbleibende Convoy-Ausführung an `OMW_Ground_Base` anbinden;
- [ ] existierende, bereits genehmigte Road-Aligned-Spawn-Ausnahme nur dann weiterverwenden, wenn sie für denselben nachgewiesenen Zweck weiterhin erforderlich ist;
- [ ] keine zweite Settlement-/Ressourcenlogik aufbauen;
- [ ] bestehende Mission-Editor-Templates verwenden statt Duplikate per Lua zu erzeugen;
- [ ] Logging mit stabilen Entity-/Node-IDs beibehalten.

#### Schritt 8 – Statische Prüfung und Dokumentation

Vor DCS:

- [ ] Lua-Syntax prüfen;
- [ ] `git diff --check`;
- [ ] vollständigen Diff gegen `main` prüfen;
- [ ] Builder/Bundle deterministisch bauen und SHA-256 erfassen;
- [ ] Dokumentation 38, 39 und 40 gegen den neuen Stand abgleichen;
- [ ] Ground-Production-Dokument aktualisieren, falls sich sein Load-/Ready-Vertrag ändert;
- [ ] MOOSE-Projektdokumentation aktualisieren, falls Klassen/Methoden neu produktiv genutzt werden;
- [ ] klar markieren, was nur in DCS verifiziert werden kann.

#### Schritt 9 – Nur gebündelter DCS-Integrationstest

Für diesen Scope keine neuen Einzelabnahmen. Falls Runtime-Verhalten geändert wird, erfolgt genau ein gebündelter Ground-Integrations-/Sammeltest mit mehreren gleichzeitig beobachtbaren Fällen.

Mindestens gemeinsam prüfen:

```text
- Startup Warehouse -> Ground Base -> Convoy Runtime
- mehrere Ground-Nodes parallel
- erfolgreicher Dispatch und Return
- Teilverlust einer Gruppe
- beschädigte Rückkehr ohne Reparaturtimer
- kein Doppelspawn / keine doppelte Ressourcenbuchung
- korrekte physische Entfernung nach Settlement
- mindestens ein offener Auftrag beim kontrollierten Missionsende/Restart,
  falls Restart-Verhalten durch den Reconciliation-Scope berührt wird
```

Pathfinding, Spawn-Platzierung und Watchguard gelten nur für den exakt getesteten Missions-/DCS-/MOOSE-Stand als validiert.

### 6.4 Abschlusskriterien

Die Reconciliation ist abgeschlossen, wenn alle folgenden Punkte erfüllt sind:

```text
[ ] real geladenes TM01M eindeutig identifiziert und gehasht
[ ] jede TM01M-Funktion klassifiziert
[ ] keine doppelte CampaignState-/Settlement-Autorität
[ ] MOOSE-First-Prüfung für alle verbleibenden Runtime-Funktionen dokumentiert
[ ] produktiver Startup-Vertrag eindeutig
[ ] kleinste notwendige Lua-Änderung umgesetzt
[ ] statische Prüfungen und Builder/Hash erfolgreich
[ ] erforderliche Dokumentation aktualisiert
[ ] falls Runtime geändert: gebündelter DCS-Integrationstest bestanden
[ ] Projektinhaberfreigabe für erforderliche Nicht-MOOSE-Ausnahmen dokumentiert
[ ] LOAD_TM01M entweder sauber integriert oder aus der Produktions-MIZ entfernt
```

### 6.5 Nächster unmittelbarer Arbeitsschritt

```text
Nicht programmieren.
Zuerst den tatsächlich in OMW_Template_v14_ground_test(8).miz geladenen
TM01M-Codebestand sichern, hashen und Funktion für Funktion gegen
OMW_Ground_Base sowie den aktuellen MOOSE-Stand inventarisieren.
```

Erst dieses Inventar entscheidet, ob `TM01M` reduziert, ersetzt oder vollständig aus dem produktiven Startup entfernt wird.
