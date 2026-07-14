# TM01B – Kontrolliertes Konvoi-Caching

## Zweck

TM01B.1 weist nach, dass dieselbe strategische Konvoientität innerhalb einer laufenden Mission kontrolliert zwischen virtueller und physischer Repräsentation wechseln kann.

Der Test baut auf dem akzeptierten TM01A-Stand auf:

- kontrollierter physischer Spawn: bestanden;
- globale Straßenroute Bagram–Jalalabad mit sieben Routenankern und Zielzone: bestanden;
- vollständige Ankunft in Jalalabad: bestanden;
- erhebliche DCS-Umwege zwischen den Ankern: dokumentierte Terrain- und Pathfinding-Einschränkung.

TM01B.1 bleibt ein Techniktest auf der bestehenden Stressroute. Bagram–Jalalabad ist keine reguläre Produktionslogistikroute.

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

## Route und Reveal-Fenster

Route und Sichtbarkeitsfenster sind getrennte Konzepte.

Die globale Route besteht ausschließlich aus:

```text
ZONE_TM01_ROUTE_01
→ ZONE_TM01_ROUTE_02
→ ZONE_TM01_ROUTE_03
→ ZONE_TM01_ROUTE_04
→ ZONE_TM01_ROUTE_05
→ ZONE_TM01_ROUTE_06
→ ZONE_TM01_ROUTE_07
→ ZONE_TM01_TARGET_JALALABAD
```

Die Reveal-Zonen sind reine Fenstergrenzen:

```text
ZONE_TM01_REVEAL_01_ENTRY
ZONE_TM01_REVEAL_01_EXIT
ZONE_TM01_REVEAL_02_ENTRY
ZONE_TM01_REVEAL_02_EXIT
```

Reveal-Zonen dürfen niemals als physische Routenwegpunkte an DCS übergeben werden. Der aktuelle `segmentIndex` bestimmt den ersten noch ausstehenden Punkt der globalen Route. Nach der zweiten Materialisierung muss deshalb nur die verbleibende Route ab `ZONE_TM01_ROUTE_06` zugewiesen werden.

Die exakte Straßenführung zwischen zwei globalen Routenankern bleibt DCS-Pathfinding. Reveal-Fenster müssen auf dem praktisch beobachteten und validierten DCS-Fahrkorridor liegen.

## Stabile Identität

```text
Test-ID:             TM01
Stage-ID:            TM01B
Entity-ID:           TEST.TM01.CONVOY.001
Route-ID:            ROUTE_TM01_BAGRAM_JALALABAD
Template:            TPL_TEST_BLUE_CONVOY_STANDARD_01
```

Konkrete DCS-Gruppennamen sind Laufzeitdaten. Jede neue Materialisierung erhält einen neuen Runtime-Namen, ohne die Entity-ID oder Route-ID zu ändern.

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

`PHYSICAL_READY` ist der kontrollierte Zwischenzustand nach erfolgreicher Materialisierung und vor der getrennten manuellen Routenzuweisung.

Während `DEMATERIALIZING` bleibt die strategische Repräsentation vorläufig `PHYSICAL`, bis die native DCS-Gruppe in einem späteren Simulationsschritt als nicht mehr existent bestätigt wurde. Ein im selben Tick noch lebendig meldender MOOSE-Wrapper darf keinen Fehlerzustand oder permanenten Lock erzeugen.

## Autoritativer In-Memory-Zustand

`CampaignState` ist die einzige autoritative Quelle für die strategische Entität. DCS-Gruppe und MOOSE-Wrapper sind ausschließlich Laufzeitrepräsentationen.

Minimale Domänendaten:

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
  survivingVehicleSlots = { 1, 2, 3, 4, 5, 6 },
  physicalGeneration = 0,
  runtimeGroupName = nil,
}
```

`runtimeGroupName` ist nur während einer physischen Repräsentation autoritativ. Das Leeren dieses Feldes muss als explizite Zustandsänderung erfolgen; ein Lua-Tabelleneintrag mit `nil` allein ist kein übertragbarer Änderungswert.

## Kontrollierte Bedienfolge

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

Alle Übergänge bleiben manuell. Wiederholte oder widersprüchliche Befehle müssen abgewiesen und protokolliert werden, ohne eine zweite physische Gruppe zu erzeugen.

## Globale Routenzuweisung

Bei jeder physischen Generation wird die Reststrecke aus der einen globalen Route geschnitten:

```text
firstRoutePointIndex = segmentIndex + 1
```

Erste Generation bei `segmentIndex = 0`:

```text
ROUTE_01 → ROUTE_02 → ROUTE_03 → ROUTE_04
→ ROUTE_05 → ROUTE_06 → ROUTE_07 → TARGET
```

Zweite Generation bei `segmentIndex = 5`:

```text
ROUTE_06 → ROUTE_07 → TARGET
```

Der Logeintrag `convoy_cached_route_started` muss Startindex, Endindex, ersten Zonennamen, letzten Zonennamen und Wegpunktanzahl ausweisen.

## Zweiphasige Dematerialisierung

Dematerialisierung ist nur zulässig, wenn:

- genau eine zugeordnete physische Gruppe existiert;
- die Gruppe lebt und mindestens ein Fahrzeug enthält;
- die Gruppe vollständig in der konfigurierten Exit-Zone steht;
- die physische Reststrecke bereits zugewiesen wurde;
- kein anderer Übergang läuft;
- Fahrzeugslots, Verluste und logischer Fortschritt in `CampaignState` übernommen wurden.

Ablauf:

```text
1. CampaignState auf DEMATERIALIZING setzen
2. Überlebende Fahrzeugslots und Exit-Segment übernehmen
3. native Bestätigungsprüfung zeitversetzt planen
4. MOOSE Destroy(false) anfordern
5. native DCS-Gruppe über Group.getByName prüfen
6. erst nach bestätigtem Entfernen auf VIRTUAL_MOVING wechseln
```

Der Controller verwendet eine Polling-Frist. Bleibt die native Gruppe bis zum Timeout existent, muss der Zustand auf einen erneut bedienbaren physischen Zustand zurückkehren:

```text
representationState = PHYSICAL
transitionState = IDLE
movementState = PHYSICAL_MOVING
```

Damit darf weder ein verschwundener Convoy dauerhaft als physisch gesperrt bleiben noch ein noch existierender Convoy irrtümlich virtuell werden.

## Virtueller Übergang

Nach bestätigter Dematerialisierung gilt:

```text
REVEAL_01_EXIT
→ manueller virtueller Routenfortschritt
→ REVEAL_02_ENTRY
```

Während `VIRTUAL_MOVING` darf keine DCS-Gruppe existieren. Der Übergang setzt den logischen Routenfortschritt auf den Entry-Segmentindex des nächsten Fensters.

## Abnahmekriterien

TM01B.1 ist bestanden, wenn ein dokumentierter DCS-Lauf Folgendes nachweist:

1. Konfigurationsversion `TM01B-controlled-caching-2` wird geladen.
2. Template, Zielzone, sieben globale Routenanker und vier Reveal-Fenstergrenzen werden validiert.
3. Reveal-Zonen erscheinen in keiner an DCS übergebenen Wegpunktliste.
4. Die erste physische Generation erhält die globale Reststrecke ab `segmentIndex + 1` genau einmal.
5. Die Entity-ID bleibt über alle Übergänge erhalten.
6. Die Gruppe fährt physisch in das erste Exit-Fenster.
7. Dematerialisierung übernimmt Fahrzeugslots, Verluste und Exit-Fortschritt vor dem Destroy-Aufruf.
8. Der Zustand bleibt während der Bestätigungsphase `PHYSICAL / DEMATERIALIZING`.
9. Ein stale MOOSE-Wrapper im Destroy-Tick erzeugt keinen `DEMATERIALIZATION_FAILED`-Lock.
10. Nach nativer Bestätigung verbleibt keine physische Restgruppe und `runtimeGroupName` ist nicht mehr autoritativ.
11. Während `VIRTUAL_MOVING` existiert keine unsichtbar weiterfahrende DCS-Gruppe.
12. Der manuelle virtuelle Übergang erreicht den zweiten Entry-Anker in korrekter Reihenfolge.
13. Die zweite Materialisierung erzeugt genau eine neue physische Gruppe mit neuem Runtime-Namen.
14. Die zweite Generation erhält ausschließlich `ROUTE_06`, `ROUTE_07` und die Zielzone.
15. Ein absichtlich verlorener Fahrzeugslot bleibt bei der zweiten Materialisierung verloren.
16. Wiederholte Befehle erzeugen keine Duplikate.
17. Der Konvoi erreicht die Zielzone nach mindestens einem Cache-Zyklus.
18. `convoy_route_arrived` wird höchstens einmal protokolliert.
19. Kein protokollierter Zustand ist gleichzeitig autoritativ `VIRTUAL` und `PHYSICAL`.

## Erforderliche Nachweise

- getestete `.miz`-Datei;
- gebautes TM01B-Bündel;
- relevanter DCS-Logauszug;
- Ergebnisdatei unter `results/`;
- DCS-Version, MOOSE-Pin, Konfigurationsversion und Build-Zeitpunkt;
- Runtime-Namen beider physischen Generationen;
- protokollierte Route-Slices beider Generationen;
- protokollierte Fahrzeugslots vor und nach dem Cache-Zyklus;
- Bestätigung der nativen Gruppenentfernung;
- Nachweis, dass zwischen den Generationen keine physische Restgruppe existierte.

Statische Lua-Prüfung, Bundle-Build oder Code-Review allein ergeben keinen PASS.
