# TM01B – Kontrolliertes Konvoi-Caching

## Zweck

TM01B.1 weist nach, dass dieselbe strategische Konvoientität innerhalb einer laufenden Mission kontrolliert zwischen virtueller und physischer Repräsentation wechseln kann.

Der Test baut auf dem akzeptierten TM01A-Stand auf:

- kontrollierter physischer Spawn: bestanden;
- kontrollierte Straßenroute Bagram–Jalalabad: bestanden;
- vollständige Ankunft in Jalalabad: bestanden;
- DCS wählte eine erhebliche, aber gültige Umwegroute: dokumentierte Terrain- und Pathfinding-Einschränkung.

TM01B.1 ist ein Techniktest auf der bestehenden Stressroute. Er macht Bagram–Jalalabad nicht zu einer regulären Produktionslogistikroute.

## Testgrenze

TM01B.1 verwendet einen flüchtigen `CampaignState` im Arbeitsspeicher. Der Zustand darf bei Missionsende verloren gehen.

Nicht Bestandteil dieser Stufe sind:

- Snapshot- oder Dateipersistenz;
- Wiederherstellung nach Missions- oder Serverneustart;
- Cargo-Manifeste und Warehouse-Buchungen;
- Feindkontakte, Hinterhalte oder IEDs;
- automatische Spielerentfernungs-, Sichtlinien- oder Sensorprüfung;
- automatische Materialisierung oder Dematerialisierung;
- automatische Routenneuberechnung;
- Teleport-, Recovery- oder Unstuck-Logik;
- mehrere gleichzeitige Konvois.

## Stabile Identität

```text
Test-ID:             TM01
Stage-ID:            TM01B
Entity-ID:           TEST.TM01.CONVOY.001
Route-ID:            ROUTE_TM01_BAGRAM_JALALABAD
Template:            TPL_TEST_BLUE_CONVOY_STANDARD_01
```

Konkrete DCS-Gruppennamen sind Laufzeitdaten. Eine nach der Materialisierung neu erzeugte Gruppe darf und soll einen anderen Runtime-Namen erhalten.

## Zustandsmodell

```text
NOT_STARTED
→ MATERIALIZING
→ PHYSICAL_READY
→ PHYSICAL_MOVING
→ DEMATERIALIZING
→ VIRTUAL_MOVING
→ MATERIALIZING
→ PHYSICAL_READY
→ PHYSICAL_MOVING
→ ARRIVED
```

`PHYSICAL_READY` ist der kontrollierte Zwischenzustand nach erfolgreicher Materialisierung und vor dem getrennten manuellen Routenstart.

Fehlerzustände:

```text
MATERIALIZATION_FAILED
DEMATERIALIZATION_FAILED
ROUTE_FAILED
DESTROYED
```

`CampaignState` ist während des Tests die einzige autoritative Quelle für die strategische Entität. Eine Entität darf nie gleichzeitig `VIRTUAL` und `PHYSICAL` sein.

## Minimale In-Memory-Domänendaten

```lua
{
  entityId = "TEST.TM01.CONVOY.001",
  representationState = "VIRTUAL",
  transitionState = "IDLE",
  movementState = "NOT_STARTED",
  routeId = "ROUTE_TM01_BAGRAM_JALALABAD",
  currentSectionIndex = 1,
  segmentIndex = 0,
  segmentProgress = 0,
  routeDistanceMeters = 0,
  configuredSpeedKph = 30,
  effectiveSpeedKph = 23,
  lastMovementUpdateCampaignTime = 0,
  survivingVehicleSlots = { 1, 2, 3, 4, 5, 6 },
  physicalGeneration = 0,
  runtimeGroupName = nil,
}
```

`runtimeGroupName` darf nur als flüchtige Zuordnung der aktuell physischen Repräsentation verwendet werden. Er ist nicht die Identität der Entität.

## Mission-Editor-Objekte

TM01A-Pflichtobjekte bleiben bestehen.

Zusätzlich benötigt TM01B:

```text
ZONE_TM01_REVEAL_01_ENTRY
ZONE_TM01_REVEAL_01_EXIT
ZONE_TM01_REVEAL_02_ENTRY
ZONE_TM01_REVEAL_02_EXIT
```

Alle vier Zonen sind Pflichtobjekte und werden beim Bootstrap geprüft. Sie müssen auf praktisch befahrbaren Straßenabschnitten liegen. Entry-Zonen dienen als validierte Materialisierungsanker, Exit-Zonen als kontrollierte Dematerialisierungsbereiche.

## Kontrollierte Bedienfolge

Die erste Implementierung verwendet ausschließlich diese manuellen F10-Befehle:

```text
Show status
Validate configuration
Materialize convoy
Start physical route
Dematerialize convoy
Show status
Advance virtual convoy
Show status
Materialize convoy
Start physical route
Show status
```

Der aktuell im `CampaignState` ausgewählte Reveal-Abschnitt bestimmt, welche Entry-Zone, Exit-Zone und Teilroute verwendet werden. Es gibt keine getrennten Materialisierungsbefehle je Reveal-Abschnitt.

Die Befehle dürfen nur in zulässigen Zuständen ausgeführt werden. Wiederholte oder widersprüchliche Befehle müssen ohne zweite physische Instanz abgewiesen und protokolliert werden.

## Dematerialisierung

Dematerialisierung ist in TM01B.1 nur zulässig, wenn:

- genau eine zugeordnete physische Gruppe existiert;
- die Gruppe lebt;
- mindestens ein Fahrzeug lebt;
- die Gruppe vollständig in der konfigurierten Exit-Zone steht;
- der physische Teilroutenbefehl bereits zugewiesen wurde;
- kein anderer Übergang läuft;
- Fahrzeugslots, Verluste, Route und logischer Fortschritt erfolgreich in den In-Memory-Zustand übernommen wurden.

Erst nach erfolgreicher Zustandsübernahme wird die DCS-Gruppe ohne künstliches Verlustereignis entfernt.

Nach dem Entfernen muss bestätigt werden:

- die vorherige DCS-Gruppe existiert nicht mehr;
- `representationState = "VIRTUAL"`;
- kein Runtime-Gruppenname ist autoritativ;
- genau dieselbe Entity-ID bleibt erhalten.

## Virtueller Übergang

TM01B.1 darf den virtuellen Übergang zwischen den Reveal-Abschnitten manuell auslösen. Diese Stufe prüft noch keinen Scheduler und keine automatische zeitbasierte Bewegung.

Der Übergang muss dennoch als explizite Domänenänderung protokolliert werden:

```text
REVEAL_01_EXIT
→ virtueller Routenfortschritt
→ REVEAL_02_ENTRY
```

Es darf keine unsichtbar weiterfahrende DCS-Gruppe existieren.

## Materialisierung

Materialisierung ist nur zulässig, wenn:

- die Entität ausschließlich virtuell ist;
- keine zugeordnete lebende DCS-Gruppe existiert;
- der ausgewählte Entry-Anker vollständig aufgelöst wurde;
- die erhaltenen Fahrzeugslots bekannt sind;
- der vorherige physische Übergang abgeschlossen ist.

Nach der Materialisierung muss bestätigt werden:

- genau eine neue physische Gruppe existiert;
- die neue Gruppe besitzt einen neuen Runtime-Namen;
- Entity-ID und Route sind unverändert;
- nur erhaltene Fahrzeugslots sind vorhanden;
- `representationState = "PHYSICAL"`;
- `movementState = "PHYSICAL_READY"`;
- der physische Generationszähler wurde genau einmal erhöht.

Die Teilroute wird erst durch den getrennten Befehl `Start physical route` genau einmal der aktuellen physischen Generation zugewiesen.

## Abnahmekriterien

TM01B.1 ist bestanden, wenn ein dokumentierter DCS-Lauf Folgendes nachweist:

1. Die Konfiguration einschließlich der vier Reveal-Zonen wird erfolgreich validiert.
2. Die Entity-ID `TEST.TM01.CONVOY.001` bleibt über alle Übergänge erhalten.
3. Die erste Materialisierung erzeugt genau eine physische Gruppe im Zustand `PHYSICAL_READY`.
4. Der erste Routenbefehl wird dieser physischen Generation genau einmal zugewiesen.
5. Die Gruppe fährt physisch bis in die erste Exit-Zone.
6. Dematerialisierung übernimmt Fahrzeugslots, Verluste und logischen Routenfortschritt vor dem Entfernen der Gruppe.
7. Nach der Dematerialisierung verbleibt keine physische Restgruppe.
8. Während `VIRTUAL_MOVING` existiert keine unsichtbar weiterfahrende DCS-Gruppe.
9. Der manuelle virtuelle Übergang erreicht den zweiten Entry-Anker in korrekter Reihenfolge.
10. Die zweite Materialisierung erzeugt genau eine neue physische Gruppe mit neuem Runtime-Namen und Zustand `PHYSICAL_READY`.
11. Ein vor der ersten Dematerialisierung absichtlich verlorener Fahrzeugslot bleibt bei der zweiten Materialisierung verloren.
12. Die Reststrecke wird der zweiten physischen Generation genau einmal zugewiesen.
13. Wiederholte Materialisierungs-, Dematerialisierungs- oder Routenbefehle erzeugen keine Duplikate.
14. Kein protokollierter Zustand ist gleichzeitig `VIRTUAL` und `PHYSICAL`.
15. Der Konvoi erreicht nach mindestens einem Cache-Zyklus die konfigurierte Zielzone.
16. `convoy_route_arrived` wird auch nach dem Cache-Zyklus höchstens einmal protokolliert.

## Erforderliche Nachweise

Für eine Acceptance sind erforderlich:

- die getestete `.miz`-Datei;
- das gebaute TM01B-Bündel;
- der relevante DCS-Logauszug;
- eine Ergebnisdatei unter `results/`;
- DCS-Version, MOOSE-Pin, Konfigurationsversion und Build-Zeitpunkt;
- Runtime-Namen beider physischer Generationen;
- protokollierte Fahrzeugslots vor und nach dem Cache-Zyklus;
- Nachweis, dass zwischen den Generationen keine physische Restgruppe existierte.

Statische Lua-Prüfung, Bundle-Build oder Code-Review allein ergeben keinen PASS.