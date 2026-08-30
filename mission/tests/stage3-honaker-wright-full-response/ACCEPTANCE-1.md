---
document_id: OMW-TEST-STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 combined Honaker attack, local response, Wright fire support, local rearm and strategic Air-AMMO closure acceptance contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-closure
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 Acceptance 1 – Honaker -> Wright -> Jalalabad Air-AMMO

## 1. Aktueller Zwischenstand 2026-08-30

Der zuletzt beobachtete kombinierte Lauf ist ausdrücklich **kein PASS**. Er hat drei getrennte Laufzeitprobleme offengelegt:

```text
CAS route / altitude profile       FAIL
CAS tactical effectiveness        FAIL
ARTY sustained fire support        FAIL
strategic closure                  therefore not accepted
```

Beobachtung des Projektinhabers im letzten Lauf:

- Wright L118 griff diesmal physisch ein, sichtbar jedoch nur mit einer Feueraufgabe von insgesamt vier Schuss.
- Eine fortlaufende Feuerleitung mit neuen Zielkoordinaten beziehungsweise Zielwechseln auf weiterhin aktive RED-Gruppen war nicht erkennbar.
- Der AH-64-Lead stieg beim ersten Punkt von `OMW_FlightPath_WEST` auf die neue Höhe, sank danach aber wieder ab.
- Der zweite AH-64 erreichte die Kampfzone nicht; die Formation `Column.D70` allein verhinderte keine problematische Geländeannäherung.
- Der Lead-AH-64 zeigte nur geringe Wirkung; beobachtet wurden höchstens ein kurzer ungelenkter Raketenangriff und Bordkanoneneinsatz, während ein großer Teil der RED-Infanterie weiter aktiv blieb.
- Damit ist weder die bisherige CAS-Effektivität noch der bisherige Fire-Support-Abschluss akzeptiert.

Diese Beobachtungen sind Zwischenbefunde des aktuellen Tests. `validated_in_dcs` bleibt `false`; der Branch darf nicht als technische Stage-3-Baseline gemerged werden.

## 2. MOOSE-First-Quellenbefund für die Höhenkorrektur

Der gepinnte MOOSE-Stand bleibt:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Die Quellprüfung trennt zwei MOOSE-Höhenmechanismen:

```text
FLIGHTGROUP:AddWaypoint(..., Altitude, ...)
-> erzeugt bei Helikoptern RADIO-Waypoints
-> allein im letzten DCS-Lauf nicht ausreichend, um 2500 ft AGL über WEST stabil zu halten

OPSGROUP:SetAltitude(Altitude, Keep, RadarAlt)
-> von FLIGHTGROUP geerbt
-> RadarAlt=true => RADIO / radar altitude
-> Keep=true => Controller soll die Höhe beim Passieren weiterer Waypoints halten
```

Die korrigierte Corridor-Version verwendet deshalb für profilierte Segmente zusätzlich den öffentlichen MOOSE-Pfad:

```lua
flightGroup:SetAltitude(2500, true, true)
```

Bedeutung im WEST-Vertrag:

```text
Altitude = 2500 ft
Keep = true
RadarAlt = true
=> 2500 ft AGL, nicht MSL/ASL
```

Der Höhenwechsel wird bereits am letzten vorhergehenden Hauptkorridor-Waypoint ausgelöst, damit der Steigflug vor dem ersten WEST-Punkt beginnt. Alle eingefügten WEST-Waypoints tragen weiterhin das 2500-ft-AGL-/`RADIO`-Profil. Beim Übergang zur eigentlichen CAS-Mission wird der dauerhafte Corridor-Hold wieder freigegeben.

Für den Rückflug wird am Mission-Waypoint erneut WEST `2500 ft AGL` mit `Keep=true` aktiviert; beim Rückwechsel auf `OMW_FlightPath` erfolgt der nächste Segmentwechsel.

`RotaryWing.Column.D70` bleibt als gewünschte Formation gesetzt. Sie ist jedoch **keine Terrain-Clearance-Garantie** für den Wingman und wird deshalb nicht mehr als solcher Nachweis behandelt.

## 3. Wichtige Korrektur: CAS-Missionshöhe ist ASL

Die MOOSE-Quellprüfung von `AUFTRAG:NewCAS()` / `AUFTRAG:NewORBIT()` zeigt, dass der dortige Altitude-Parameter in Fuß **above sea level (ASL)** angegeben wird.

Damit gilt aktuell ausdrücklich:

```text
OMW_FlightPath                 500 ft AGL corridor profile
OMW_FlightPath_WEST           2500 ft AGL corridor profile
AUFTRAG:NewCAS altitude       10000 ft ASL orbit/mission parameter
```

Die bisherige Bezeichnung `10000 ft combat altitude` ohne ASL/AGL-Kennzeichnung war zu ungenau. Der Acceptance-Code bezeichnet den Wert nun explizit als `CAS_ORBIT_ALTITUDE_FT_ASL`.

Eine neue konkrete CAS-Kampfzonenhöhe **AGL** wird nicht stillschweigend erfunden. Falls für die Kampfzone selbst ein verbindliches AGL-Profil benötigt wird, ist das eine eigene Projektentscheidung und anschließend MOOSE-first umzusetzen.

## 4. Korrigierte Wright-ARTY-Feuerleitung

Der vorangegangene Acceptance-Code bildete nur einen Snapshot ab:

```text
OPSZONE einmal lesen
-> bis zu 3 RED-Gruppen auswählen
-> deren Koordinaten einmal lesen
-> alle Koordinaten vorab einreihen
```

Das ist für sich bewegende Angreifer unzureichend. Der neue Vertrag nutzt weiterhin ausschließlich das bereits vorhandene MOOSE-`OPSZONE`-Lagebild und baut **keinen zweiten Scanner**.

Neuer Ablauf:

```text
OPSZONE Attacked
-> 15 s bestehendes Lagebild aufbauen lassen
-> aktuell relevante RED-Gruppe wählen
-> aktuelle GROUP:GetCoordinate()
-> ARTY:AssignTargetCoord(...)
-> 4-round DCS Fire At Point
-> physische Ammo-Abnahme bestätigen
-> bestehende OPSZONE erneut auswerten
-> nächste aktuell lebende RED-Gruppe wählen
   oder dieselbe bewegte Gruppe mit neuer Koordinate erneut bekämpfen
-> neue aktuelle Koordinate
-> nächste Fire Mission
-> fortsetzen, solange RED-Bedrohung und gültige Ziele vorhanden sind
```

Der Adapter `OMW_FobAttackFunctionalArtyDispatchAdapter` unterstützt dafür nun `QueueTarget(demandId, targetGroup)`. Jeder neue Auftrag erhält eine eindeutige ARTY-Zielkennung, während die Quellgruppe und ihre beim Auftrag frisch gelesene Koordinate als Metadaten erhalten bleiben.

Die Erweiterung findet ereignisgebunden nach `OnAfterCeaseFire` und bestätigter physischer Ammo-Abnahme statt. Es gibt keinen neuen hochfrequenten Target-Scanner.

## 5. Physical-Fire-Gate und Rearm

Für **jede** abgeschlossene Fire Mission bleibt verbindlich:

```text
OnAfterOpenFire
-> ARTY:GetAmmo(false) baseline
-> reale DCS-Schüsse
-> OnAfterCeaseFire
-> ARTY:GetAmmo(false) muss kleiner sein
```

Bleibt der Bestand unverändert, ist der Fire-Support-Demand `FAILED` und es wird kein erfolgreicher Rearm-Folgepfad behauptet.

Der lokale M1083-Rearm wird erst nach Abschluss des aktuellen Live-Fire-Cycles angefordert. Der strategische Vertrag bleibt unverändert:

```text
Wright CampaignState AMMO acceptance precondition: 30 -> 16
real MOOSE rearm:                            16 -> 15
reorder threshold:                           15
strategic RESUPPLY Jalalabad -> Wright:      +15
final Wright:                                30
final Jalalabad:                             85
```

Eine physische Granate entspricht weiterhin **nicht** einem strategischen `GROUND_AMMO_PACKAGE`. Genau ein realer MOOSE-Rearm-Zyklus belastet CampaignState um ein Paket.

## 6. CAS-Wirkungs-Gate

Ein einzelnes AH-64-`EVENTS.Shot` bleibt nützliche Ausführungsevidenz, ist aber nach dem letzten Lauf **kein ausreichender Gesamt-PASS mehr**.

Der kombinierte Acceptance-Lauf verlangt jetzt zusätzlich:

```text
MOOSE OPSZONE
-> OnAfterDefeated for RED
-> state.threatCleared = true
```

Damit kann der Lauf nicht mehr PASS melden, wenn ein Apache einmal feuert, aber ein großer Teil der angreifenden RED-Kräfte weiter aktiv bleibt.

Die taktische CAS-Ausführung selbst bleibt nach diesem Zwischenstand offen. `AUFTRAG:NewCAS()` plus `SetEngageDetected()` wird nicht als endgültig ausreichend erklärt. Eine weitere MOOSE-first-Prüfung konkreterer Angriffsmuster wie STRAFING/weitere AUFTRAG-Kombinationen ist zulässig, aber noch nicht als implementiert oder DCS-validiert dokumentiert.

## 7. Route-Telemetrie für den nächsten Lauf

Der korrigierte Corridor schreibt für jeden eingefügten Waypoint in das DCS-Log:

```text
CAS_ROUTE_PROFILE
 direction=<outbound|returnRoute>
 index=<n>
 uid=<uid>
 pathline=<OMW_FlightPath|OMW_FlightPath_WEST>
 altitudeFtAgl=<500|2500>
 altType=RADIO
```

Zusätzlich werden Controller-Übergänge protokolliert:

```text
CAS_ROUTE_TRANSITION
 uid=<uid>
 pathline=<...>
 altitudeFtAgl=<...>
 keep=<true|false>
 formation=<...>
```

Damit kann der nächste DCS-Lauf unterscheiden zwischen:

```text
falscher erzeugter Route
vs.
korrekt erzeugtem RADIO/AGL-Profil, das später von DCS/MOOSE anders geflogen wird
```

## 8. Revidierter End-to-End-Vertrag

```text
RED attack Honaker
-> MOOSE OPSZONE Attacked
-> Honaker Guard + QRF
AND
-> Wright live coordinate fire cycle
   -> current OPSZONE target
   -> current coordinate
   -> real fire
   -> reacquire
   -> corrected/new fire mission
   -> repeat while threat remains
AND
-> Jalalabad AH-64 CAS
   -> OMW_FlightPath
   -> WEST held at 2500 ft AGL / Column.D70
   -> real weapon employment
   -> RED threat must actually clear
THEN
-> Wright local M1083 rearm
-> CampaignState 16 -> 15
-> strategic RESUPPLY
-> Jalalabad CH-47 -> Wright
-> Wright 30 / Jalalabad 85
-> physical return lifecycle
```

## 9. PASS-Kriterien für den nächsten Lauf

1. `OPSZONE Attacked` wird real ausgelöst.
2. Honaker-QRF materialisiert und greift RED an.
3. CAS-Route wird über `OMW_FlightPath -> OMW_FlightPath_WEST` installiert.
4. WEST wird durchgehend als `2500 ft AGL` / `RADIO` profiliert und der MOOSE-Controller erhält `SetAltitude(2500,true,true)` am Segmentübergang.
5. Beide AH-64 müssen die beabsichtigte Talroute ohne Terrainverlust bewältigen; `Column.D70` allein gilt nicht als Nachweis.
6. AH-64 führt real Waffen ein; ein einzelner Shot allein reicht aber nicht für den Gesamt-PASS.
7. Wright führt mindestens eine reale `AssignTargetCoord`-Fire Mission mit physischer Ammo-Abnahme aus.
8. Nach jeder abgeschlossenen Fire Mission wird das bestehende OPSZONE-Lagebild neu gelesen und gegebenenfalls eine weitere Fire Mission mit frischer Koordinate eingereiht.
9. MOOSE `OPSZONE Defeated RED` muss die Bedrohung tatsächlich als beendet bestätigen.
10. Erst danach darf die kombinierte Response-Seite als taktisch abgeschlossen gelten.
11. Der lokale M1083-Rearm läuft real und CampaignState erreicht Wright `15`.
12. Genau ein strategischer RESUPPLY-Demand und TRANSFER Jalalabad -> Wright über 15 Pakete wird ausgeführt.
13. CH-47 liefert physisch, Wright erreicht `30`, Jalalabad `85`.
14. CH-47 kehrt physisch nach Jalalabad zurück und erst danach erfolgt `LegionAssetReturned`.
15. Kein `VALIDATED` ohne vollständige DCS-/MIZ-/Bundle-/MOOSE-Provenienz.

## 10. Mission-Editor- und Build-Vertrag

Die Acceptance mutiert keine `.miz`. Das generierte Bundle wird nach MOOSE, Ground Base und Jalalabad AirOps geladen.

Build:

```text
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
```

Output:

```text
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

Der Builder `STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-4` muss die gepinnte MOOSE-Provenienz, den aktuellen Git-Commit, die Source-Hashes und den finalen Bundle-SHA256 ausgeben.

## 11. Offene Punkte

Nicht als gelöst oder validiert behaupten:

- DCS-Nachweis, dass `SetAltitude(..., Keep=true, RadarAlt=true)` WEST tatsächlich durchgehend auf `2500 ft AGL` hält.
- DCS-Nachweis, dass beide AH-64 in Column die Talroute terrain-sicher fliegen.
- endgültige CAS-Taktik und sinnvolle Stand-off-/Waffenwirkung gegen große Infanteriebedrohung.
- eine gegebenenfalls gewünschte explizite CAS-Kampfzonenhöhe AGL.
- DCS-Nachweis, dass der neue live-retarget ARTY-Cycle mehrere bewegte Ziele nacheinander sinnvoll bekämpft.
- vollständige strategische Closure nach dem revidierten Response-Lauf.

Bis diese Punkte reproduzierbar nachgewiesen sind, bleibt der Status `PLANNED` und `validated_in_dcs: false`.
