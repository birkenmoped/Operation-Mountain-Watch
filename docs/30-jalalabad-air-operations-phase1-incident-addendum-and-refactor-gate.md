# Jalalabad Air Operations – Phase-1-Incident-Addendum und MOOSE-Refactoring-Gate

Stand: 2026-07-25  
Bezug: `docs/28-jalalabad-air-operations-development-incident-log.md`  
Code Review: `docs/29-jalalabad-air-operations-moose-code-review.md`  
Status: verbindliche Ergänzung

## INC-028 – UH-60 wird an der Pickup-Landung despawnt

### DCS-Befund

Der UH-60-TROOPTRANSPORT-Lauf führte nur folgenden Teilablauf aus:

```text
Spawn Jalalabad
Engine Start
Takeoff Jalalabad
Flug zum Pickup-LZ
Landung am Pickup-LZ
Despawn der UH-60
```

Nicht ausgeführt wurden:

```text
nachgewiesene Aufnahme der Infanterie
zweiter Start vom Pickup-LZ
Flug zum Dropoff-LZ
Landung am Dropoff-LZ
Entladen der Infanterie
Start vom Dropoff-LZ
RTB Jalalabad
finale Basislandung
```

Der Lauf ist `DCS FAIL`.

Vollständiger Resultatbericht:

```text
mission/tests/jalalabad-air-operations/results/
2026-07-25-jalalabad-phase1-uh60-intermediate-landing-despawn-fail.md
```

### Root Cause 1 – falsche SQUADRON-Despawnregel

Die UH-60-SQUADRON verwendete:

```lua
squadron:SetDespawnAfterLanding(true)
```

Diese Einstellung ist für Transport- und MEDEVAC-Flüge mit operationellen Zwischenlandungen ungeeignet. Die erste Landung am Pickup-LZ wurde zum Despawn-Auslöser.

Korrektur in PHASE1-9:

```lua
squadron:SetDespawnAfterLanding(false)
```

Der finale Despawn soll erst nach vollständigem und nachgewiesenem Entladen für die spätere RTB-Landung aktiviert werden.

### Root Cause 2 – falsche Pickup-Heuristik

Die alte Eigenlogik interpretierte das Verschwinden oder Verlassen der Pickup-Zone durch die Infanterie als Boarding-Nachweis.

Diese Annahme ist falsch. Eine MOOSE-Cargorepräsentation kann während des Ladeprozesses deaktiviert, versteckt oder intern umgehängt werden. Daraus folgt noch nicht, dass der richtige Carrier die richtige Truppengruppe aufgenommen hat.

Korrektur in PHASE1-9:

```text
MOOSE OnAfterLoadingDone
MOOSE OnAfterUnloaded
MOOSE OnAfterUnloadingDone
```

Zusätzlicher Review-Befund:

`LoadingDone` allein beweist nur, dass der Carrier alle möglichen Cargoobjekte geladen hat. In einer konsolidierten Version muss zusätzlich die Identität der erwarteten Cargo-Gruppe und ihr geladener Zustand geprüft werden.

### Root Cause 3 – Außenlandung wurde als Jalalabad-Landung gezählt

Der generische Observer verwendete einen großen Radius um den Airbase-Referenzpunkt. Das Pickup-LZ lag innerhalb dieses Radius. Dadurch wurde die Außenlandung fälschlich als finale Basislandung und RTB gezählt.

Korrektur in PHASE1-9:

Für `UH60_TROOP` wird die breite Radiusklassifizierung nicht verwendet. Eine finale Basislandung muss aus dem DCS-/MOOSE-Landeereignis dem tatsächlichen Jalalabad-Airbaseobjekt zugeordnet sein.

Zusätzlicher Review-Befund:

Objekt- oder ID-Vergleich ist verbindlich robuster als ein normalisierter Stringvergleich des Airbasenamens.

### Root Cause 4 – nativer Terminalstatus vor physischem Auftragserfolg

MOOSE konnte den Transportauftrag `DONE` oder `SUCCESS` melden, obwohl Pickup, Dropoff und RTB nicht vollständig nachgewiesen waren.

PHASE1-9 behandelt einen Terminalstatus vor dem strikten Transportziel als harten Fehler.

Langfristige Korrektur:

Die physische Erfolgs- und Fehlerdefinition wird als native AUFTRAG-Condition registriert. Der Projektcontroller darf nicht als zweite parallele Terminalautorität auftreten.

## INC-029 – Zu viel eigene Lifecycle- und Testengine oberhalb von MOOSE

### Befund

Der Jalalabad-Lua-Quellstand umfasst 4.712 Bruttozeilen. MOOSE selbst ist nicht in das Bundle eingebettet. Daher sind 100,0 % dieser Zeilen Projekteigenentwicklung beziehungsweise Integrations-, Konfigurations-, Diagnose- oder Testcode.

Funktionale Grobaufteilung:

```text
1.400 Zeilen / 29,7 %
Grundaufbau, Assembly, Konfiguration, Diagnose und Validatoren

3.312 Zeilen / 70,3 %
Phase-1-Observer, Factory, Controller, Lifecycle-Korrekturen,
Safety, Telemetrie und auftragsspezifische Override-Schichten
```

### Fehlentwicklung

Der Testharness wurde schrittweise zu einer zweiten Missions- und Lifecycle-Engine ausgebaut.

Er verwaltet unter anderem selbst:

```text
Missionstates
Success/Failure/Terminalnormalisierung
Asset-Busy- und Releasezustände
Missionqueue
Spawn-/Takeoff-/Landing-Zuordnung
Cargo-Pickup und Dropoff
RTB-Erkennung
Timeouts und Stable Polls
```

MOOSE stellt für wesentliche Teile bereits öffentliche APIs, FSMs, Events und Conditions bereit.

### Folgen

- Type-only- und Namenszuordnungsfehler;
- Konflikte zwischen physischem Ziel und AUFTRAG-Terminalstatus;
- stale Pending-Zustände;
- falsche Inventarzählung;
- globale Testblockierung;
- kaskadierende Override-Dateien;
- fragile direkte Zugriffe auf interne MOOSE-Tabellen;
- zunehmende Fehleranfälligkeit bei jeder weiteren Korrekturschicht.

### Verbindliche Trennung

```text
MOOSE:
  operative Mission
  Assets
  Queue
  FLIGHTGROUP-/OPSGROUP-Lifecycle
  Cargo-Lifecycle
  Missions-FSM
  Success-/Failure-Conditions

Operation Mountain Watch:
  ORBAT und Paketvertrag
  konkrete Templates/Zonen/Parkingregeln
  projektspezifische Zieldefinition
  Sicherheits- und Realismuskriterien
  Acceptance Harness
  Persistenz und Kampagnenregeln
```

## Refactoring-Gate R0 – Sofort wirksam

Vor jeder weiteren Datei oder Funktionsstufe muss geprüft werden:

- [ ] Gibt es eine öffentliche MOOSE-Methode für diese Aufgabe?
- [ ] Wurde die Methode gegen den gepinnten MOOSE-Stand geprüft?
- [ ] Wird eine vorhandene MOOSE-FSM oder ein Callback dupliziert?
- [ ] Greift der Code auf interne Tabellen oder Felder zu?
- [ ] Erzeugt die Änderung eine weitere Override-Schicht?
- [ ] Verändert ein Lifecycle-Fix unbeabsichtigt Paketvertrag oder Formation?
- [ ] Ist Eigenentwicklung fachliche OMW-Logik oder nur Ersatz für MOOSE?

Ein ungeprüftes „MOOSE kann das vermutlich nicht“ ist keine Begründung für Eigenentwicklung.

## Refactoring-Gate R1 – Verbot neuer Korrekturschichten

Bis zur Konsolidierung sind nicht zulässig:

```text
21-phase1-*.lua als weiterer Monkey Patch
neue Wrapper um Factory.Create
neue Wrapper um Controller.OnMissionState
neue Wrapper um Observer.OnEvent...
neue parallele Terminalzustände
weitere direkte Zugriffe auf MOOSE-Interna
```

Ein neuer DCS-Fehler wird dokumentiert und in die geplante Konsolidierung aufgenommen. Er wird nicht durch eine weitere späte Datei kaschiert.

## Refactoring-Gate R2 – Öffentliche MOOSE-API statt interner Tabellen

Zu entfernen oder zu begründen:

```text
squadron.assets
cfg.Airwing.missionqueue
mission.groupdata
opsgroup.groupname
opsgroup.group
_DATABASE.Templates.Groups
```

Vorrangige öffentliche Alternativen:

```text
AIRWING:CountAssets
AIRWING:CountAssetsOnMission
AIRWING:CountMissionsInQueue
AUFTRAG:GetOpsGroups
GROUP:GetTemplate
GROUP:GetTemplateRoutePoints
FLIGHTGROUP-/OPSGROUP-Getter und Zustandsmethoden
```

## Refactoring-Gate R3 – AUFTRAG bleibt Terminalautorität

- [ ] Success-Bedingungen über `AUFTRAG:AddConditionSuccess`.
- [ ] Failure-Bedingungen über `AUFTRAG:AddConditionFailure`.
- [ ] Start-/Push-Bedingungen über native AUFTRAG-Conditions.
- [ ] keine nachträgliche Umdeutung eines nativen Terminalstatus;
- [ ] Acceptance Harness protokolliert, ersetzt aber nicht die AUFTRAG-FSM.

## Refactoring-Gate R4 – Objektbezogene Ereignisse

- [ ] konkretes FLIGHTGROUP-/OPSGROUP-Objekt nach Zuweisung speichern;
- [ ] Lifecycle-Callbacks direkt an diesem Objekt;
- [ ] globale Events nur für Pre-Assignment und Fremdspawn-Erkennung;
- [ ] Namenskontrakt bleibt Invariante, nicht primäre Objektverwaltung;
- [ ] Airbase-Landung über Place-Objekt/ID;
- [ ] Cargo-Pickup über konkretes Cargoobjekt und geladenen Zustand.

## Refactoring-Gate R5 – UH-60-spezifische Bedingungen

Für den aktuellen PHASE1-9-Retest müssen mindestens folgende Ereignisse chronologisch nachgewiesen werden:

```text
CARRIER_CALLBACKS_ATTACHED
DEPART_BASE
PICKUP_LANDING_OBSERVED
LOADING_DONE
DEPART_PICKUP
DROPOFF_LANDING_OBSERVED
CARGO_UNLOADED
UNLOADING_DONE
PHYSICAL_OBJECTIVE_CONFIRMED
DEPART_DROPOFF
LAND_AT_JALALABAD_EXACT
ASSET_RELEASED
```

Zusätzliche Review-Anforderungen für die Konsolidierung:

- [ ] `LoadingDone` bezieht sich auf die erwartete Truppengruppe;
- [ ] erwartete Cargo war nachweislich im erwarteten Carrier geladen;
- [ ] `Unloaded` enthält die erwartete Cargo-Identität;
- [ ] finaler Despawn wird erst nach vollständig bestätigtem Ziel aktiviert;
- [ ] Callback-Attachment erfolgt vor dem ersten möglichen Ladeereignis;
- [ ] falsches Dropoff führt nicht zum Despawn bei der nächsten Landung.

## Freigabestatus

```text
Grundknoten Jalalabad:                  ACCEPTED
Phase-1-Paketvertrag:                  IMPLEMENTED
PHASE1-9 UH-60-Korrektur:              IMPLEMENTED
PHASE1-9 UH-60-DCS-Abnahme:            PENDING
MOOSE-first Code Review:               COMPLETE
MOOSE-first Refactoring:               REQUIRED
weitere Flugplätze:                    BLOCKED
Dynamische Spieleranforderungen:       BLOCKED
vollständiges MEDEVAC-Paket:           BLOCKED
```

## Schlussregel

Die Entwicklung darf nicht weiter durch eine wachsende Reihe nachgelagerter Korrekturdateien stabilisiert werden.

Der nächste strukturelle Schritt nach dem angekündigten PHASE1-9-Retest ist eine Konsolidierung auf öffentliche MOOSE-APIs. Das Ergebnis muss weniger Eigenzustand, weniger Polling, weniger Namensrekonstruktion und genau eine operative Missionsautorität besitzen.
