# Jalalabad Air Operations – MOOSE-first code review

Stand: 2026-07-25  
Review-Basis: Branch `feature/jalalabad-airwing-phase1-functional-tests`, Commit `522ea5e5924ff6e338ac8de91eba8806667e7415`, BuilderVersion `JBAD-AIR-OPS-PHASE1-9`  
Geltungsbereich: `mission/tests/jalalabad-air-operations/src/*.lua` und der zugehörige Bundle-Builder  
Status: Review abgeschlossen; Refactoring und erneute DCS-Abnahme ausstehend

## 1. Management Summary

Der Jalalabad-AirOps-Stand verwendet MOOSE als Laufzeitfundament, enthält aber inzwischen eine sehr große projektspezifische Steuerungs- und Testschicht.

Die zentrale Antwort lautet:

```text
MOOSE-Quellcode im Jalalabad-Bundle:                 0 Zeilen
projektspezifischer Lua-Quellcode im Bundle:     4.712 Zeilen
Anteil projektspezifischer Bundle-Quellcode:       100,0 %
```

Diese Aussage bedeutet nicht, dass MOOSE ungenutzt wäre. Der gesamte Code ruft MOOSE-Klassen und -Methoden auf. MOOSE selbst wird jedoch separat geladen und nicht in diesen 4.712 Zeilen mitgeführt. Jede Lua-Zeile in `src/` ist daher Eigenentwicklung, Integrationscode, Konfiguration, Validierung oder Testlogik des Projekts.

Eine funktionale Grobklassifizierung der 4.712 Bruttozeilen ergibt:

```text
Grundaufbau, Konfiguration, SQUADRON-/AIRWING-Assembly,
Parking- und Templatevalidierung, Diagnose:
  1.400 Zeilen = 29,7 %

projektspezifische Phase-1-Steuerung, Observer,
Testcontroller, Lifecycle-Korrekturen, Safety,
Telemetrie und auftragsspezifische Overrides:
  3.312 Zeilen = 70,3 %
```

Die Zählung umfasst Kommentare und Leerzeilen und ist deshalb eine Brutto-LOC-Betrachtung. Sie ist für die Architekturverteilung belastbar, aber keine token- oder AST-genaue Funktionsmessung.

Das Review-Ergebnis ist eindeutig:

```text
Ja, es wurden Eigenentwicklungen implementiert, obwohl MOOSE
für wesentliche Teile bereits öffentliche Funktionen, FSMs,
Callbacks, Conditions und Bestandsabfragen bereitstellt.
```

Nicht jede Eigenentwicklung ist unnötig. Paketvertrag, ORBAT-Regeln, projektspezifische Parking-Sicherheit, exakte DCS-Abnahmekriterien, Terrainprüfung und Testberichte sind legitime Projektschichten. Zu viel Eigenlogik befindet sich jedoch in Bereichen, die MOOSE selbst verwalten sollte: Missionszustände, Success/Failure, Asset- und Queue-Zählung, Cargo-Lifecycle, FLIGHTGROUP-Zustände und Eventzuordnung.

## 2. Review-Methode

Geprüft wurden:

- alle 26 Lua-Quelldateien des Jalalabad-AirOps-Bundles;
- die Builder-Reihenfolge;
- die Trennung zwischen Grundknoten und Phase-1-Testharness;
- direkte Zugriffe auf MOOSE-interne Tabellen;
- selbst gebaute Zustands- und Lifecycle-Logik;
- vorhandene öffentliche MOOSE-Alternativen;
- die zuletzt hinzugefügte UH-60-Transportkorrektur;
- die dokumentierten DCS-Fehlläufe und deren Ursachen.

Verglichen wurde insbesondere mit den öffentlichen MOOSE-Modulen:

```text
AIRWING / LEGION
SQUADRON / COHORT
AUFTRAG
FLIGHTGROUP / OPSGROUP
OPSTRANSPORT
Core.Event / EVENTDATA
Core.Fsm
GROUP / UNIT / AIRBASE / ZONE / COORDINATE
SCHEDULER
```

## 3. LOC-Inventar

| Bereich | Dateien | Bruttozeilen | Anteil |
|---|---:|---:|---:|
| Grundknoten, Diagnose, Verträge und Assembly | `01` bis einschließlich beider `10`-Dateien | 1.400 | 29,7 % |
| Phase-1-Manifest, Observer, Factory, Controller und Korrekturschichten | `11` bis `20` | 3.312 | 70,3 % |
| Gesamt | 26 Lua-Dateien | 4.712 | 100,0 % |

Einzelne große Eigenentwicklungsblöcke:

```text
14-phase1-test-controller.lua                     554 Zeilen
20-phase1-uh60-transport-lifecycle.lua            463 Zeilen
17-phase1-operational-safety.lua                  442 Zeilen
18-phase1-readiness-and-recon-telemetry.lua       423 Zeilen
12-phase1-runtime-observer.lua                    413 Zeilen
19-phase1-oh58-formation-recovery-counting.lua    268 Zeilen
13-phase1-mission-factory.lua                     246 Zeilen
14a-phase1-lifecycle-corrections.lua              186 Zeilen
```

Allein diese acht Dateien enthalten 2.995 Zeilen und damit rund 63,6 % des gesamten Jalalabad-Lua-Quellstands.

## 4. Positive Befunde

### 4.1 MOOSE ist weiterhin das operative Fundament

Der Code verwendet die vorgesehenen Kernklassen:

```text
AIRWING
SQUADRON
AUFTRAG
FLIGHTGROUP/OPSGROUP
WAREHOUSE/Storage-Anbindung
COMMANDER
SCHEDULER
MOOSE-Wrapper für GROUP, UNIT, STATIC, AIRBASE und ZONE
```

Die dynamischen Luftfahrzeuge werden nicht über eigene DCS-Spawnlogik erzeugt. Bestand, SQUADRON-Zuordnung, Payloads und Auftragsübergabe bleiben grundsätzlich MOOSE-basiert.

### 4.2 Der zentrale Paketvertrag ist legitime Eigenentwicklung

Die Unterscheidung zwischen:

```text
InventoryAircraft
AssetGroups
Grouping
RequiredGroups
RequiredAircraft
RuntimeUnitSuffixes
```

ist projektspezifische Fachlogik. MOOSE kennt diese Operation-Mountain-Watch-ORBAT-Entscheidungen nicht. Die zentrale Vertragsprüfung ist deshalb sinnvoll und notwendig.

### 4.3 Parking- und Ramp-Schutz ist projektspezifisch

Die Regeln zu:

- Client-Parkpositionen;
- absichtlich durch Statics belegten Terminals;
- typbezogenen dynamischen Pools;
- Mindestabstand zu sichtbaren Statics;
- exakter Jalalabad-Ramp-Darstellung;

sind missionsspezifische Sicherheitsregeln. MOOSE stellt Bausteine wie Safe Parking und Parking-Tabellen bereit, kennt aber nicht die gewünschte Ramp-Darstellung und die deklarierte Static-Belegung dieses Projekts.

### 4.4 Terrain- und Routensicherheitsprüfung ist grundsätzlich legitim

MOOSE bietet Koordinaten-, Höhen-, Wegpunkt- und Routingfunktionen. Eine projektspezifische Vorprüfung eines vollständigen Afghanistan-Flugkorridors ist dennoch sinnvoll, weil das operationelle Akzeptanzkriterium über eine reine MOOSE-Auftragserzeugung hinausgeht.

Die früheren frei gewählten harten Distanz- und Höhengrenzen waren jedoch nicht legitim als physikalische Blocker. Solche Werte bleiben Telemetrie oder Warnungen, bis sie durch DCS-Messung oder ein dokumentiertes Leistungsmodell belegt sind.

### 4.5 Ein deterministischer Testharness ist legitim

MOOSE kann einen Auftrag ausführen, aber es kennt nicht automatisch die projektspezifische Abnahmedefinition:

```text
genaue Zahl physischer Gruppen
genaue Zahl Einheiten
genaue Runtime-Namen
keine Client- oder Static-Kollision
bestimmter Hin- und Rückkorridor
vollständige Inventarfreigabe
kein fremder Spawn
kein operationell unsinniges Verhalten
```

Ein Testharness ist daher gerechtfertigt. Er darf jedoch MOOSE nicht als zweite parallele Missionsengine nachbauen.

## 5. Kritische Review-Befunde

## CR-01 – Die effektive Wahrheit hängt weiterhin von der Bundle-Reihenfolge ab

**Schweregrad: kritisch**

Die Dateien:

```text
14a-phase1-lifecycle-corrections.lua
14b-phase1-sequence-finalization.lua
17-phase1-operational-safety.lua
18-phase1-readiness-and-recon-telemetry.lua
19-phase1-oh58-formation-recovery-counting.lua
20-phase1-uh60-transport-lifecycle.lua
```

speichern bestehende Funktionen und ersetzen sie anschließend:

```lua
local previousFunction = object.Function
function object:Function(...)
  ...
  return previousFunction(self, ...)
end
```

Damit hängt das Verhalten nicht nur von der fachlichen Konfiguration, sondern von der Reihenfolge im PowerShell-Builder ab. Eine spätere Datei kann ältere Logik teilweise neutralisieren, ohne dass eine statische Vertragsprüfung dies erkennt.

Dies widerspricht direkt der inzwischen dokumentierten Regel, keine weitere Architekturkorrektur als späte Override-Schicht hinzuzufügen.

**Verbindliche Maßnahme:**

Keine Datei `21` als nächste Korrekturschicht. Vor weiteren Funktionsausbauten müssen Observer, Factory, Controller und auftragsspezifische Lifecycle-Adapter konsolidiert werden.

## CR-02 – Der eigene Controller dupliziert MOOSE-AUFTRAG- und FSM-Funktionalität

**Schweregrad: kritisch**

`14-phase1-test-controller.lua` führt eine eigene Missionszustandsmaschine mit unter anderem folgenden Zuständen und Kriterien:

```text
QUEUED
REQUESTED
SCHEDULED
STARTED
EXECUTING
DONE
SUCCESS
FAILED
CANCELLED
PendingFailure
HardFailure
MissionTerminal
ReleaseStablePolls
```

MOOSE stellt bereits bereit:

```text
AUFTRAG-Zustände und OnAfter...-Callbacks
AUFTRAG:AddConditionStart
AUFTRAG:AddConditionPush
AUFTRAG:AddConditionSuccess
AUFTRAG:AddConditionFailure
Core.Fsm
FLIGHTGROUP-Missions- und Task-Callbacks
```

Der eigene Controller wurde nicht nur Beobachter, sondern zweite Autorität für Success, Failure und Terminalzustände. Genau daraus entstanden die bisherigen Konflikte:

- CH-47 physisch erfolgreich, aber Controller-Fail;
- native Terminalzustände wurden nachträglich normalisiert;
- UH-60 konnte nativ `SUCCESS` oder `DONE` erreichen, obwohl der physische Transport nicht beendet war;
- stale Pending-Kriterien blieben erhalten.

**Verbindliche Maßnahme:**

MOOSE/AUFTRAG muss die operative Missionsautorität bleiben. Projektspezifische physische Bedingungen werden über native `AddConditionSuccess` und `AddConditionFailure` eingebunden. Der Testharness beobachtet und bewertet das Ergebnis, darf aber nicht nachträglich eine parallele Terminalsemantik erzeugen.

## CR-03 – Direkte Zugriffe auf interne MOOSE-Datenstrukturen

**Schweregrad: hoch**

Der aktuelle Stand greift unter anderem direkt zu auf:

```text
squadron.assets
cfg.Airwing.missionqueue
mission.groupdata
opsgroup.groupname
opsgroup.group
_DATABASE.Templates.Groups
```

Diese Felder sind keine stabile projektspezifische API. Änderungen innerhalb von MOOSE können den Code brechen, obwohl die öffentlichen Methoden kompatibel bleiben.

Öffentliche Alternativen existieren teilweise bereits:

```text
AIRWING:CountAssets(...)
AIRWING:CountAssetsOnMission(...)
AIRWING:CountMissionsInQueue(...)
AUFTRAG:GetOpsGroups()
GROUP:GetTemplate()
GROUP:GetTemplateRoutePoints()
FLIGHTGROUP-/OPSGROUP-Getter
```

**Verbindliche Maßnahme:**

Direkte interne Tabellenzugriffe werden verboten, sofern keine schriftlich dokumentierte und gegen den gepinnten MOOSE-Commit geprüfte Ausnahme existiert.

## CR-04 – Globaler Eventhandler und Namensrekonstruktion duplizieren Objekt-Lifecycle

**Schweregrad: hoch**

`12-phase1-runtime-observer.lua` verwendet einen globalen `EVENTHANDLER` und rekonstruiert die Zugehörigkeit aus Gruppenpräfixen und Einheitensuffixen.

Das war als Schutz gegen die frühere Type-only-Zuordnung nachvollziehbar. Nach Zuweisung eines konkreten FLIGHTGROUP-/OPSGROUP-Objekts ist diese Architektur jedoch unnötig breit.

MOOSE stellt objektbezogene Events und Lifecycle-Callbacks bereit. FLIGHTGROUP überwacht Start, Flugzustand, Landung, Ankunft, Fuel, Cargo und Missionen. Core.Event kann Ereignisse an konkrete MOOSE-Objekte dispatchen.

**Verbindliche Maßnahme:**

- globale Beobachtung nur bis zur eindeutigen Objektzuordnung;
- anschließend konkrete FLIGHTGROUP-/OPSGROUP-Referenzen speichern;
- Lifecycle über Objektcallbacks erfassen;
- Namensprüfung nur noch als zusätzliche Testinvariante, nicht als primärer Objekt-Locator.

## CR-05 – Asset- und Queue-Zählung wurden selbst nachgebaut

**Schweregrad: hoch**

Der Testcontroller zählt:

- Einträge in `squadron.assets`;
- Flags wie `requested`, `spawned`, `isReserved`;
- Einträge in `cfg.Airwing.missionqueue`;
- eigene Stable-Polls zur Inventarfreigabe.

MOOSE stellt öffentliche AIRWING-/LEGION-Abfragen für Assets, Assets on mission und Missionsqueue bereit.

**Verbindliche Maßnahme:**

Die Baseline-, Busy-, Queue- und Release-Prüfung wird auf öffentliche MOOSE-Abfragen umgestellt. Polling bleibt nur als Watchdog und Abnahme-Telemetrie bestehen.

## CR-06 – Die UH-60-Korrektur nutzt endlich native Cargo-Callbacks, baut aber erneut eine parallele Transport-FSM

**Schweregrad: hoch**

Positiv ist die Nutzung von:

```text
OnAfterLoadingDone
OnAfterUnloaded
OnAfterUnloadingDone
```

Dies sind MOOSE-Lifecycle-Ereignisse und deutlich besser als die frühere Heuristik „Infanterie verschwunden = aufgenommen“.

Problematisch ist jedoch, dass `20-phase1-uh60-transport-lifecycle.lua` zusätzlich eine eigene Transportzustandsmaschine mit zahlreichen Booleans pflegt und Factory, Observer sowie Controller erneut monkey-patcht.

Die Datei umfasst 463 Zeilen und ist damit fast so groß wie der gesamte ursprüngliche Phase-1-Controller.

**Verbindliche Maßnahme:**

Die Transportbedingungen gehören direkt an den erzeugten AUFTRAG und den konkreten FLIGHTGROUP. Ein separater Adapter darf die MOOSE-Callbacks in projektspezifische Abnahmeereignisse übersetzen, aber nicht Factory, Observer und Controller in einer Datei ersetzen.

## CR-07 – `LoadingDone` ist allein kein ausreichender Boarding-Nachweis

**Schweregrad: hoch**

MOOSE beschreibt `LoadingDone` als Zustand, in dem der Carrier alle **möglichen** Cargoobjekte an der Pickup-Zone geladen hat. Das kann je nach Ausgangszustand auch ohne das erwartete konkrete Truppenobjekt auftreten.

Der aktuelle Code setzt bei `OnAfterLoadingDone` unmittelbar:

```text
TroopsPickedUpObserved = true
```

Die spätere Zielprüfung ist strenger, aber der Pickup-Status selbst ist noch nicht an die Identität der erwarteten Cargo-Gruppe gebunden.

**Verbindliche Maßnahme:**

Pickup muss zusätzlich belegen:

```text
erwartetes Cargo-OPSGROUP-Objekt
IsLoaded(expectedCarrier) oder gleichwertiger öffentlicher MOOSE-Zustand
erwartete Cargo-Identität
Pickup-Landung in der Load-Zone
```

## CR-08 – Finaler Despawn wird zu früh scharfgeschaltet

**Schweregrad: hoch**

Der aktuelle UH-60-Code ruft `SetDespawnAfterLanding()` bereits in `OnAfterUnloadingDone` auf.

Zu diesem Zeitpunkt ist noch nicht zwingend bewiesen:

- dass die Landung in der korrekten Dropoff-Zone erfolgte;
- dass die erwartete Cargo-Gruppe entladen wurde;
- dass die Truppen lebend in der Zielzone stehen;
- dass das physische Ziel vollständig bestätigt wurde.

Bei einem Entladen am falschen Ort könnte deshalb der finale Despawn bereits aktiviert sein.

**Verbindliche Maßnahme:**

Finaler Despawn darf erst nach vollständiger `strictObjectiveReady`-Prüfung aktiviert werden. Erst danach folgt RTB.

## CR-09 – Basisidentität wird teilweise als String rekonstruiert

**Schweregrad: mittel bis hoch**

Die neue UH-60-Erkennung ist wesentlich besser als der frühere 5-km-Radius. Sie versucht jedoch mehrere EventData-Felder und vergleicht Namen als Strings.

MOOSE EVENTDATA stellt bei Landungen das Place-Objekt bereit. Eine Objekt-/ID-basierte Prüfung gegen `cfg.Airbase` ist robuster als normalisierte Textnamen.

**Verbindliche Maßnahme:**

Airbaseobjekt oder eindeutige Airbase-ID vergleichen. Stringvergleich nur als Diagnosefallback, nicht als primäre Abnahme.

## CR-10 – Callback-Attachment besitzt ein Zeitfenster für verpasste Ereignisse

**Schweregrad: mittel bis hoch**

Die UH-60-Datei sucht den FLIGHTGROUP nach Missionszuständen wiederholt und hängt Callbacks anschließend dynamisch an. Zwischen Spawn, FLIGHTGROUP-Erzeugung und Callback-Attachment besteht ein Race Window.

Bei kurzer Distanz oder beschleunigter Simulation könnten frühe Zustandswechsel stattfinden, bevor die Callbacks angebracht sind.

**Verbindliche Maßnahme:**

Callbacks beim frühestmöglichen nativen MOOSE-Zuweisungs-/Spawnereignis registrieren. Die Registrierung muss einmalig, objektbezogen und vor dem ersten Pickup-Vorgang nachweisbar sein.

## CR-11 – `_DATABASE` wird trotz öffentlicher GROUP-Methoden verwendet

**Schweregrad: mittel**

Template- und Routenprüfungen lesen direkt aus `_DATABASE.Templates.Groups`.

MOOSE stellt unter anderem bereit:

```text
GROUP:GetTemplate()
GROUP:GetTemplateRoutePoints()
GROUP:GetUnits()
GROUP:GetTypeName()
```

**Verbindliche Maßnahme:**

Öffentliche Wrappermethoden verwenden. `_DATABASE` nur für nachweislich nicht öffentlich verfügbare Daten und nur als dokumentierte Ausnahme.

## CR-12 – Direct-DCS-Ausgaben und eigene Hilfsfunktionen sind inkonsistent

**Schweregrad: niedrig bis mittel**

Der Code verwendet gemischt:

```text
env.info
trigger.action.outTextForCoalition
timer.scheduleFunction
MOOSE SCHEDULER
MOOSE Wrapper
```

Das ist nicht zwingend falsch, erhöht aber die Zahl eigener Adapter und unterschiedlicher Fehlerpfade.

**Verbindliche Maßnahme:**

Für neue Produktionslogik bevorzugt:

```text
MOOSE BASE-Logging
MESSAGE/MENU-Klassen
SCHEDULER
MOOSE Wrapper und FSM
```

Native DCS-Aufrufe bleiben nur, wenn MOOSE keine passende Abstraktion besitzt oder wenn ein reproduzierbarer MOOSE-Fehler dokumentiert ist.

## 6. Welche Eigenentwicklungen durch MOOSE ersetzbar sind

| Eigenentwicklung | Derzeitige Funktion | Vorhandene MOOSE-Mittel | Review-Urteil |
|---|---|---|---|
| eigener Mission-State-Controller | QUEUED bis SUCCESS/FAILED plus Terminalnormalisierung | AUFTRAG FSM, OnAfter-Callbacks, `AddConditionSuccess/Failure/Start/Push`, Core.Fsm | weitgehend ersetzbar |
| direkte Assettabellen-Auswertung | total/available/busy/requested/spawned/reserved | `AIRWING:CountAssets`, `CountAssetsOnMission`, öffentliche LEGION-Abfragen | ersetzbar |
| direkte Missionqueue-Auswertung | Queue-Länge und Freigabe | `AIRWING:CountMissionsInQueue` | ersetzbar |
| globaler Eventhandler nach Spawn | Start, Takeoff, Land, Dead über Namen | FLIGHTGROUP-/OPSGROUP-Callbacks und objektbezogene Core.Event-Subscriptions | weitgehend ersetzbar |
| Cargo-Heuristik | Pickup/Dropoff aus Gruppenexistenz und Zone | OPSGROUP/FLIGHTGROUP `LoadingDone`, `Unloaded`, `UnloadingDone`, `IsLoaded`, Cargoabfragen | ersetzbar; Korrektur begonnen |
| selbst gebaute Terminalnormalisierung | physisches Ziel übersteuert MOOSE-Zustand | AUFTRAG Success-/Failure-Conditions | ersetzbar |
| `_DATABASE`-Templatezugriff | Units, Livery, Route | `GROUP:GetTemplate`, `GetTemplateRoutePoints`, Wrappermethoden | überwiegend ersetzbar |
| eigene Airbase-Radius-RTB-Erkennung | Landung/RTB | EVENTDATA Place, AIRBASE-Objekt, FLIGHTGROUP Landed/Arrived | ersetzbar |
| manuelle Fuel-Telemetrieplanung | Fuelwerte je Phase | GROUP/UNIT/FLIGHTGROUP Fuelgetter und Events | mit MOOSE abbildbar |
| eigene F10-Testausgabe | Status und Startbefehle | MENU- und MESSAGE-Klassen | technisch ersetzbar, aber geringe Priorität |

## 7. Welche Eigenentwicklungen beibehalten werden sollen

Die folgenden Bereiche sind fachlich projektspezifisch und sollen nicht aus Prinzip entfernt werden:

- zentraler Paketvertrag und ORBAT-Arithmetik;
- Zuordnung der konkreten Jalalabad-Templates, Statics, Clients und Zonen;
- Projektregeln für sichtbare Ramp-Darstellung und virtuelle Reserve;
- deklarierte Static-Parking-Reservierungen;
- exakte Testakzeptanz und Regression-Checklisten;
- DCS-Laufzeitbeweis und Resultatdokumentation;
- projektspezifische sichere Hin- und Rückkorridore;
- Terrainprofilanalyse, sofern keine beliebigen Blockwerte verwendet werden;
- Schutz vor fremden Client- und nicht zum Test gehörenden Gruppen;
- package-spezifische Mehrgruppenkoordination für späteres MEDEVAC;
- persistente Kampagnenverluste und projektbezogene Lagerlogik.

Diese Logik soll jedoch auf öffentlichen MOOSE-Objekten und -Events aufbauen und nicht deren interne Tabellen oder FSMs ersetzen.

## 8. Quantitative Antwort ohne Scheingenauigkeit

### 8.1 Quellcode-Eigentum

```text
100,0 % der 4.712 Lua-Bruttozeilen sind Projekteigenentwicklung.
```

MOOSE wird als externes Framework aufgerufen; sein Quellcode ist nicht Teil dieser Zahl.

### 8.2 Architekturfunktion

```text
29,7 % Grundaufbau/Integration/Validierung
70,3 % eigene Phase-1-Orchestrierung und Teststeuerung
```

### 8.3 Vermeidbare Eigenentwicklung

Eine exakte Prozentzahl „durch MOOSE ersetzbar“ wäre ohne zeilenweise AST-Klassifizierung unseriös. Das Review weist jedoch nach, dass wesentliche Teile der größten Dateien in ersetzbaren Bereichen liegen:

```text
12 runtime observer
14 test controller
14a lifecycle corrections
14b sequence finalization
20 UH-60 transport lifecycle
Teile von 17 operational safety
Teile von 18 readiness/telemetry
Teile von 19 OH-58 recovery/counting
```

Damit ist nicht nur ein Randbereich betroffen, sondern der überwiegende Teil der 70,3-%-Orchestrierungsschicht.

## 9. Verbindlicher Refactoring-Plan

### Stufe R1 – Keine weiteren Override-Schichten

- keine neue Datei `21` zur Laufzeitkorrektur;
- aktuelle PHASE1-9 ausschließlich für den angekündigten UH-60-Retest verwenden;
- bei neuem Fehler nicht erneut monkey-patchen;
- Fehler dokumentieren und in die Konsolidierung übernehmen.

### Stufe R2 – Öffentliche MOOSE-Abfragen

Ersetzen:

```text
squadron.assets
cfg.Airwing.missionqueue
mission.groupdata
opsgroup.groupname/opsgroup.group
_DATABASE-Zugriffe, soweit öffentliche Wrapper existieren
```

### Stufe R3 – AUFTRAG als einzige Missionsautorität

- Success/Failure als native AUFTRAG-Conditions;
- keine nachträgliche Statusnormalisierung;
- physische Zielbedingungen werden vor Missionsstart am AUFTRAG registriert;
- Testharness liest das Ergebnis nur aus.

### Stufe R4 – Objektbezogener Lifecycle

- konkrete FLIGHTGROUP-/OPSGROUP-Referenzen speichern;
- Start, Takeoff, Loading, Unloading, Landung, Verlust und RTB über native Objektcallbacks;
- globale Events nur als Pre-Assignment-Diagnose und Fremdspawnwächter.

### Stufe R5 – Controller auf Testharness reduzieren

Der Controller behält nur:

```text
Testauswahl
Baselineprüfung
Timeout-Watchdog
projektspezifische Invarianten
Ergebnisprotokoll
Sequenzsteuerung
```

Er verwaltet nicht mehr parallel den operativen Missionszustand.

### Stufe R6 – Konsolidierung

Zielstruktur:

```text
manifest/contracts
node assembly
public MOOSE adapters
one mission factory
one acceptance observer
small per-mission acceptance specifications
F10 test interface
```

Die Dateien `14a`, `14b`, `17`, `18`, `19` und `20` dürfen langfristig keine kaskadierende Override-Kette bleiben.

## 10. Sofortige Abnahmebedingungen für PHASE1-9

Der nächste UH-60-Test ist weiterhin erforderlich, weil die neue Implementierung noch nicht in DCS validiert ist.

Besonders zu prüfen:

- Callback-Registrierung vor Pickup;
- Pickup-Landung ohne Despawn;
- tatsächliches Laden der erwarteten Truppengruppe;
- zweiter Start nach Pickup;
- Dropoff-Landung;
- Entladen der richtigen Cargo-Gruppe;
- kein Scharfschalten des finalen Despawns bei falschem Dropoff;
- Rückstart;
- Landung am tatsächlichen Jalalabad-Airbaseobjekt;
- Freigabe genau einer UH-60-Assetgruppe;
- keine native Terminalmeldung vor bestätigtem physischem Ziel.

## 11. Verbindliche Schlussfolgerung

Der aktuelle Stand ist MOOSE-basiert, aber nicht ausreichend MOOSE-first.

MOOSE wird für Spawn, SQUADRON, AIRWING, AUFTRAG und FLIGHTGROUP verwendet. Darüber wurde jedoch eine zweite, sehr umfangreiche Eigensteuerung gebaut. Diese Eigensteuerung hat mehrere Fehler nicht verhindert, sondern selbst erzeugt oder verschärft.

Für die weitere Entwicklung gilt deshalb:

```text
MOOSE führt den Auftrag und besitzt den Lifecycle.
Operation Mountain Watch definiert Vertrag, Ziel, Sicherheitsregeln
und Abnahmebedingungen.
Der Testharness beobachtet; er ersetzt MOOSE nicht.
```
