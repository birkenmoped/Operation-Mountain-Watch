---
document_id: OMW-MOOSE-STAGE3-CAS-GUARD-QRF-ROUTING-AUDIT
status: SOURCE_REVIEWED
document_class: MOOSE_TECHNICAL_AUDIT
owning_policy: OMW-GOV-001
authoritative_for:
  - source review of Stage 3 CASENHANCED, FLIGHTGROUP routing, Guard patrol and QRF engagement behavior against pinned MOOSE 2.9.18
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# MOOSE Source Audit – Stage 3 CAS / Guard / QRF / Helicopter Routing

## 1. Zweck und Quellenhierarchie

Dieser Audit wurde nach dem realen Stage-3-Build-`1-10`-FAIL vom 31.08./01.09.2026 erstellt. Er trennt:

```text
OMW-Anforderung / bindende Projektentscheidung
-> OMW-Lua-Iststand
-> tatsächlich gepinnte Moose.lua
-> MOOSE Online-Dokumentation
-> offizielle MOOSE-Beispielmissionen
-> reale DCS-Beobachtung
```

Maßgeblicher MOOSE-Runtime-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Bei Abweichungen zwischen generierter Online-Dokumentation und diesem Source gilt gemäß Projektregel die gepinnte `Moose.lua`.

Offizielle externe Vergleichsquellen dieses Audits:

```text
MOOSE_DOCS_DEVELOP / Ops.Auftrag
MOOSE_DOCS / Ops.FlightGroup / Ops.OpsGroup / Wrapper.Controllable
FlightControl-Master/MOOSE_MISSIONS develop
  Ops/Auftrag/Airforce/Auftrag - 017 - CAS
  Ops/Auftrag/Airforce/Auftrag - 100 - CAS Enhanced
```

## 2. Kurzfazit

Der Audit bestätigt mehrere voneinander unabhängige Probleme im aktuellen Stage-3-Stand:

```text
A. CASENHANCED ist kein Apache-spezifischer Standoff-Controller.
B. MOOSE wählt im EngageDetected-Pfad selbst jeweils eine erkannte Ziel-GROUP aus.
C. Für FLIGHTGROUP wird daraus ein generischer DCS AttackGroup-Task ohne Weapon-/Attack-Profile-Parameter.
D. EngageTarget pausiert die laufende AUFTRAG-Mission und entfernt deren MOOSE-Missionswegpunkte.
E. Nach Ende des Engage_Target-Tasks wird die pausierte Mission über den normalen OPSGROUP-Lifecycle wieder gestartet.
F. OMW fügt eigene Corridor-Waypoints ein, die nicht als missionUID-Waypoints gekennzeichnet sind und daher diesen Pause/Resume-Lifecycle nicht sauber teilen.
G. OMW nutzt zusätzlich gleichzeitig RADIO-Waypoint-Höhen und SetAltitude(Keep=true,RadarAlt=true); DCS hielt die beabsichtigte WEST-Höhe nicht.
H. OMW setzt aktuell einen globalen 500-m-Rechtsoffset auch auf WEST; MOOSE bietet in den geprüften APIs keine PATHLINE-Namensmetadaten für segmentbezogene Offsets.
I. Guard und QRF entsprechen im Build 1-10 nicht der bindenden main-Baseline: Guard keine owner-authored PatrolRoute, QRF nur Infantry.
J. Der RESUPPLY-Abbruch ist ein OMW-Acceptance-Vergleichsfehler, kein nachgewiesener MOOSE-CARGOTRANSPORT-Fehler.
```

Keiner dieser Befunde macht den Lauf `VALIDATED`; der reale Lauf bleibt `FAIL`.

## 3. CASENHANCED – was MOOSE tatsächlich macht

### 3.1 Konstruktor

Gepinnte `Moose.lua` und aktuelle Develop-Online-Dokumentation stimmen für die Signatur überein:

```lua
AUFTRAG:NewCASENHANCED(
  CasZone,
  Altitude,
  Speed,
  RangeMax,
  NoEngageZoneSet,
  TargetTypes
)
```

Semantik:

```text
CasZone       = CAS-Einsatzraum
Altitude      = feet ASL
Speed         = knots
RangeMax      = max detected-target engagement range in NM
NoEngageZones = auszuschließende Bereiche
TargetTypes   = DCS attributes, z. B. Ground Units
```

Der Konstruktor aktiviert intern `SetEngageDetected(...)`, setzt für die Mission `ROE=OpenFire` und für FLIGHTGROUP `ROT=EvadeFire`.

Damit waren im realen Lauf weder ein niedriger Squadron-Skill noch eine fehlende grundsätzliche Feuerfreigabe die primäre Ursache. Der Jalalabad-Bootstrap setzt die AH-64-SQUADRON bereits auf `AI.Skill.HIGH`.

### 3.2 Detection und Zielauswahl

`AUFTRAG:SetEngageDetected(...)` überträgt beim Mission-Execute die Einstellungen auf die zugewiesene OPSGROUP/FLIGHTGROUP-Instanz.

Die gepinnte `Moose.lua` führt anschließend regelmäßig eine eigene Detected-Group-Auswahl aus. `_GetDetectedTarget()`:

```text
-> iteriert die von der Gruppe erkannte GROUP-Menge
-> prüft Entfernung
-> prüft TargetTypes
-> prüft Engage-/No-Engage-Zonen
-> wählt die nächstgelegene qualifizierte erkannte GROUP
```

Das ist wichtig für die beobachtete Situational Awareness:

```text
MOOSE detected set
-> MOOSE wählt eine konkrete GROUP
-> FLIGHTGROUP:EngageTarget(selectedGroup)
-> DCS erhält einen konkreten AttackGroup-Task
```

Es ist **nicht** belegt, dass DCS einen vollständigen MOOSE-Target-Set-Kontext erhält und daraus eigenständig eine taktisch optimale Apache-Zielpriorisierung ableitet.

### 3.3 FLIGHTGROUP EngageTarget – generischer DCS-Angriff

Für ein GROUP-Ziel erzeugt die gepinnte `FLIGHTGROUP:onafterEngageTarget(...)`:

```lua
self:GetGroup():TaskAttackGroup(
  Target,
  nil,
  nil,
  nil,
  nil,
  nil,
  nil,
  true
)
```

Die optionalen DCS-Angriffsparameter für Weapon/Expend/AttackQty/Direction/Altitude usw. werden in diesem Pfad **nicht** gesetzt.

Folge:

```text
CASENHANCED + EngageDetected
= MOOSE Detection + MOOSE Target Selection + generischer DCS AttackGroup
!= Apache-spezifische Hellfire-Standoff-Taktik
```

Die offizielle MOOSE-Beispielmission `Auftrag - 100 - CAS Enhanced` beschreibt CAS Enhanced genau als automatische Bekämpfung erkannter Ziele mit Filterung nach Entfernung, TargetTypes und Engage-/No-Engage-Zonen. Sie enthält keine Apache-spezifische Waffenreichweiten-, Schusspositions- oder Angriffsrichtungssteuerung. Das Beispiel verwendet im aktuellen Develop-Repository sogar explizit `FLIGHTGROUP:SetEngageDetectedOn(...)` zusammen mit einer `AUFTRAG:NewPATROLZONE(...)`-Mission, nicht einen spezialisierten Hubschrauber-Angriffscontroller.

Damit ist das im DCS-Lauf beobachtete problematische Nahkampfprofil durch MOOSE CASENHANCED **nicht gelöst**. Eine eigene Standoff-Implementierung ist daraus aber noch nicht automatisch freigegeben; zuerst müssen sämtliche vorhandenen MOOSE-Angriffsparameter/-Missionen und mögliche DCS-Task-Optionen im gepinnten Stand vollständig auf einen framework-eigenen Weg geprüft werden.

## 4. EngageTarget unterbricht die aktuelle Mission

Die gepinnte `FLIGHTGROUP:onafterEngageTarget(...)` tut nach Erzeugung des `Engage_Target`-Tasks ausdrücklich:

```text
backup current ROE
-> switch ROE OpenFire
-> GetMissionCurrent()
-> PauseMission()
-> TaskExecute(Engage_Target)
```

`OPSGROUP:onafterPauseMission(...)`:

```text
mission group status -> PAUSED
-> current mission task cancel
-> _RemoveMissionWaypoints(Mission)
-> mission id in pausedmissions queue
```

Nach Ende des `Engage_Target`-Tasks:

```text
TaskDone(Engage_Target)
-> Disengage()
-> _CheckGroupDone()
-> if remaining missions are paused:
     UnpauseMission()
-> MissionStart(paused mission)
-> RouteToMission rebuilt
```

Das ist eine zentrale Erklärung dafür, warum `CASENHANCED` nicht als eine unveränderte statische Flugroute betrachtet werden darf: automatische Zielbekämpfung kann die laufende Missionsroute bewusst pausieren und anschließend neu aufbauen.

## 5. OMW Corridor versus MOOSE Mission-Lifecycle

Der aktuelle `OMW_HelicopterFlightPathCorridor` wurde aus einem Transportkorridor abgeleitet und verändert die FLIGHTGROUP-Waypointliste nach der MOOSE-Missionsplanung.

### 5.1 aktuelle OMW-Struktur

```text
outbound owner-authored corridor
-> vor missionUid einfügen
-> MOOSE mission waypoint
-> komplette OMW returnRoute direkt nach missionUid einfügen
```

Die OMW-eigenen Corridor-Waypoints werden mit `FLIGHTGROUP:AddWaypoint(...)` erzeugt, aber nicht mit:

```lua
waypoint.missionUID = mission.auftragsnummer
```

markiert.

MOOSE setzt diese Kennzeichnung dagegen für seine selbst erzeugten Mission-, Ingress- und Egress-Waypoints. `_RemoveMissionWaypoints(Mission)` entfernt nur solche missionUID-gebundenen Wegpunkte.

Damit entsteht bei `CASENHANCED -> EngageTarget -> PauseMission()` eine problematische Mischroute:

```text
MOOSE mission-related waypoints
-> werden beim Pause entfernt

OMW corridor/return waypoints
-> bleiben als unabhängige normale Wegpunkte bestehen

UnpauseMission
-> MOOSE baut Mission/Ingress/Egress neu in die weiterhin vorhandene OMW-Route ein
```

Das ist ein **konkreter Integrationsfehler-Kandidat** für die beobachtete unstabile Befehlskette. Er beweist allein noch nicht jede einzelne im DCS-Lauf beobachtete Fluglinie, erklärt aber, warum der aktuelle Corridor-Adapter nicht als lifecycle-sicher gelten darf.

### 5.2 direkter Flug Richtung Jalalabad

Der Projektinhaber beobachtete zeitweise eine direkte Luftlinie Richtung Heimat, nicht die owner-authored WEST-/Hauptroute. Deshalb bleibt folgende Unterscheidung bindend:

```text
direkter Flug Richtung Jalalabad
!= geometrisch die definierte OMW returnRoute
```

Die gepinnte FLIGHTGROUP-Logik kann bei einem tatsächlich beendeten Auftrag und fehlenden weiteren Tasks/Missions `RTB(destbase/homebase)` auslösen. Ebenso kann ein pausierter EngageDetected-Auftrag anschließend wieder `UnpauseMission -> MissionStart` auslösen. Ob im konkreten Lauf zwischen diesen Zuständen tatsächlich ein RTB ausgelöst wurde, muss anhand der vorhandenen DCS/MOOSE-Logsequenz mit den entsprechenden FSM-Meldungen korreliert werden; aus der reinen Flugbahn wird das nicht erfunden.

## 6. Native MOOSE Ingress/Egress-Unterstützung

Die gepinnte `Moose.lua` und die Develop-Onlinedokumentation bieten:

```lua
mission:SetMissionIngressCoord(coordinate, altitudeFt, speedKts)
mission:SetMissionEgressCoord(coordinate, altitudeFt, speedKts)
```

`SetMissionEgressCoord` bedeutet ausdrücklich: Koordinate, zu der die zugewiesene Gruppe **nach Abschluss der Mission** fliegt.

`OPSGROUP:RouteToMission()` erzeugt einen solchen Egress-Waypoint selbst, markiert ihn mit der Mission-ID und speichert seine UID als mission-owned egress waypoint. `MissionDone` wird bei konfiguriertem Egress erst nach Passieren dieses Waypoints ausgelöst.

Der aktuelle OMW-CAS-Pfad nutzt diese native MOOSE-Egress-Semantik nicht. Er fügt stattdessen eine vollständige Return-Route selbst direkt hinter `missionUid` ein.

MOOSE-first-Folgerung:

```text
Vor weiterer eigener CAS-Rückweglogik
-> native Ingress/Egress-Semantik einsetzen/prüfen
-> erst danach nur die nicht von MOOSE abgedeckte Valley-Corridor-Geometrie adaptieren
```

Ein einzelner MOOSE-Egress-Waypoint löst noch nicht automatisch die komplette owner-authored Talroute. Er liefert aber den korrekten Mission-Lifecycle-Anker, an den ein kleiner Corridor-Adapter gegebenenfalls anschließen muss.

## 7. Höhensteuerung – feet/meters und AGL/ASL

### 7.1 kein additiver 2500-ft-Fehler im OMW-Code

Für den verwendeten `FLIGHTGROUP`-/`OPSGROUP`-Pfad gilt in gepinnter Source und Online-Dokumentation:

```text
FLIGHTGROUP:AddWaypoint(... Altitude ...)
Altitude unit = feet

OPSGROUP/FLIGHTGROUP:SetAltitude(Altitude, Keep, RadarAlt)
Altitude unit = feet
```

Die gepinnte `FLIGHTGROUP:AddWaypoint()`-Implementierung konvertiert den übergebenen feet-Wert genau einmal mit `UTILS.FeetToMeters()` in den DCS-Waypoint. Für Hubschrauber wird der Waypoint intern als `RADIO`/AGL angelegt.

Es gibt damit im geprüften OMW-Aufrufpfad **keine** Source-Evidenz für:

```text
2500 ft am WP1
+ 2500 ft am WP2
+ 2500 ft am WP3
...
```

oder für eine direkte Übergabe von 2500 Metern statt 2500 feet.

Wichtig zur Verwechslungsgefahr: `Wrapper.GROUP:SetAltitude()` ist eine andere API und dokumentiert Meter. OMW ruft hier aber `FLIGHTGROUP/OPSGROUP:SetAltitude()` auf, dessen Einheit feet ist. Diese APIs dürfen künftig nicht vermischt dokumentiert werden.

### 7.2 dokumentierte versus tatsächliche Altitude-Type-Semantik

Die Online-Dokumentation von `FLIGHTGROUP:AddWaypoint` beschreibt die `Altitude` allgemein als feet ASL/barometric. Die tatsächlich gepinnte Implementierung setzt für `self.isHelo` jedoch:

```text
WaypointAltType.RADIO
```

und ist damit für den verwendeten Runtime-Stand spezifischer als die generische Dokumentationsbeschreibung. Für OMW gilt deshalb der gepinnte Source.

### 7.3 aktueller OMW-Doppelmechanismus

Stage 3 setzt für WEST gleichzeitig:

```text
jedem eingefügten Hubschrauber-Waypoint:
  altitude = 2500 ft
  alt type = RADIO durch FLIGHTGROUP:AddWaypoint

zusätzlich beim Profilübergang:
  FLIGHTGROUP:SetAltitude(2500, Keep=true, RadarAlt=true)
```

Der reale DCS-Lauf zeigte, dass diese Kombination **keine stabile 2500-ft-AGL-Führung** erzeugte. Die gemessene Höhe stieg auf weit über 6000/7000 ft AGL.

Damit gilt:

```text
Syntax/Einheiten source-seitig plausibel
!= DCS-Verhalten validiert
```

Vor der nächsten Integration muss die Höhenführung isoliert werden. Es ist nicht zulässig, einfach einen anderen Zahlenwert einzusetzen und erneut zu hoffen.

## 8. PATHLINE-Offset

### 8.1 Iststand

`OMW_HelicopterFlightPathCorridor.ResolveSequence()` verwendet derzeit einen globalen:

```text
offsetRightM = 500 m default
```

und verschiebt damit die gesamte zusammengesetzte Centerline. Folglich wird auch `OMW_FlightPath_WEST` um 500 m versetzt.

Für den Rückweg wird die umgekehrte Centerline erneut relativ zur Flugrichtung rechts versetzt, wodurch bei breiten Tälern getrennte Hin-/Rückspuren entstehen.

Für WEST wurde vom Projektinhaber festgelegt, dass das Tal dafür zu eng ist und WEST auf der Centerline bleiben soll.

### 8.2 vorgeschlagene owner-authored Namensmetadaten

Zu dokumentierender Zielvertrag:

```text
OMW_FlightPath_R500
  -> 500 m rechts relativ zur Flugrichtung

OMW_FlightPath_WEST
  -> 0 m, Centerline

OMW_FlightPath_EAST_L250
  -> 250 m links relativ zur Flugrichtung
```

Parser-Regel:

```text
End-Suffix _R<number> = rechts in Metern
End-Suffix _L<number> = links in Metern
kein Suffix            = 0 m
```

Die geprüften MOOSE-PATHLINE-/FLIGHTGROUP-/AUFTRAG-APIs und die offiziellen CAS/CAS-Enhanced-Beispiele zeigen **keine** eingebaute Konvention, die solche PATHLINE-Namenssuffixe automatisch als segmentbezogene laterale Offsets interpretiert.

Damit ist dieser kleine Metadatenparser nach aktuellem Review ein plausibler OMW-Adapterkandidat, **aber noch keine Implementierungsfreigabe**. Er ist erst dann zulässig, wenn die MOOSE-Prüfung für alternative native Offset-/routingbezogene Funktionen abgeschlossen und die projektinhaberseitige Ausnahme/Adapterentscheidung dokumentiert ist.

## 9. Guard – bindende main-Baseline versus Stage 3

Die bindende Projektentscheidung auf `main` fordert:

```text
Guard
-> aktive Patrouille
-> bevorzugt owner-authored Mission Editor route
-> wiederholter MOOSE route patrol circuit
-> Afghanistan: validierte Route vor freier Patrol-Zone
```

MOOSE-first-Kandidat der bindenden Baseline ist `CONTROLLABLE:PatrolRoute()` / GROUP-Wrapper.

Die gepinnte `Moose.lua` besitzt `PatrolRoute()` und baut dafür aus der vorhandenen Gruppenroute eine wiederholte Patrol-Route.

Build `1-10` tut dagegen:

```lua
AUFTRAG:NewONGUARD(state.guardCoord)
```

und nutzt die vorhandene `OMW_RTE_BLUE_GUARD_HONAKER_01` nicht.

Bewertung:

```text
Stage-3 Guard = fachlich nicht baseline-konform
```

Die im DCS-Lauf beobachtete im FOB festlaufende Guard-Infanterie ist daher kein Nachweis eines fehlerhaften owner-authored PatrolRoute-Modells; dieses wurde in Build `1-10` überhaupt nicht getestet.

## 10. QRF – bindende main-Baseline versus Stage 3

Die bindende main-Entscheidung hat `infantry-only QRF` als projektweite Baseline ausdrücklich verworfen.

Phase 1 fordert:

```text
1 infantry GROUP
+ optional independent suitable vehicle GROUP if available
-> one logical QRF response package
-> same attack incident
-> coordinated tasking / target picture
```

Build `1-10` erstellt dagegen nur:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

für QRF-PLATOON/Assets.

Bewertung:

```text
QRF ONGUARD + SetEngageDetected
= MOOSE-first als Engagementmechanismus plausibel und source-belegt

QRF composition in build 1-10
= nicht baseline-konform
```

Die gepinnte MOOSE-Strategielogik verwendet selbst `ONGUARD` bzw. `PATROLZONE` zusammen mit `SetEngageDetected(...)` für fortlaufende Bodenbekämpfung. Dieser Teil muss daher nicht durch einen eigenen `find next target`-Scheduler ersetzt werden.

## 11. RESUPPLY-Dedupe

Dieser Audit bestätigt den bereits dokumentierten Acceptance-Fehler:

```text
MissionDemand.Registry:Create(active duplicate)
-> deep copy of existing demand
-> created=false
-> reason="active_duplicate"
```

Stage 3 vergleicht jedoch:

```lua
duplicate ~= demand
```

und damit Lua-Tabellenidentität statt semantischer Demand-Identität.

Korrekturziel:

```text
same stable demand id
same dedupeKey
created == false
reason == active_duplicate
```

Der bestehende MOOSE `CARGOTRANSPORT`-Pfad wird wegen dieses Fehlers nicht als gescheitert gewertet; er wurde im Lauf durch das Acceptance-Gate nicht erreicht.

## 12. Abgleichmatrix

| Thema | OMW 1-10 | gepinnte Moose.lua | Online-Doku | offizielles Beispiel | Bewertung |
|---|---|---|---|---|---|
| CASENHANCED | `NewCASENHANCED` | vorhanden, EngageDetected, OpenFire, EvadeFire | vorhanden | CAS Enhanced demonstriert detected-target filtering | API korrekt verwendet, aber kein Apache-Standoff-Profil |
| Target selection | 5 NM / Ground Units | MOOSE wählt nächstgelegene erkannte qualifizierte GROUP | SetEngageDetected dokumentiert | CAS Enhanced auto-engage | Lagebild ist MOOSE-selected target tasking, nicht vollständige autonome DCS-Suche |
| Attack task | indirekt via CASENHANCED | `TaskAttackGroup(... nil ..., true)` | generische Engage-APIs | keine weapon-specific Konfiguration | Standoff nicht garantiert |
| Engage lifecycle | nicht berücksichtigt | PauseMission -> Engage_Target -> UnpauseMission | Mission/FSM APIs vorhanden | Beispiel verändert Route nicht zusätzlich | OMW Corridor lifecycle-unsicher |
| Egress | eigene Return-Waypoints | native `SetMissionEgressCoord` vorhanden | ausdrücklich nach mission finished | kein CAS-Route-Beispiel | native Semantik zuerst nutzen/prüfen |
| Waypoint altitude | 500/2500 ft | AddWaypoint feet; helo RADIO | feet, generisch ASL beschrieben | keine passende helo-alt demo | kein additiver Einheitenfehler, aber DCS FAIL |
| SetAltitude | feet | OPSGROUP feet + RadarAlt | feet | keine passende CAS demo | OMW Doppelsteuerung nicht validiert |
| Segment offset | global 500 m | keine PATHLINE suffix semantics | keine gefunden | keine gefunden | kleiner Adapterkandidat, Freigabe ausstehend |
| Guard | ONGUARD am anchor | PatrolRoute vorhanden | PatrolRoute dokumentiert | allgemeine MOOSE route patterns | verletzt main baseline |
| QRF composition | infantry-only | Framework kann getrennte assets/cohorts | n/a | n/a | verletzt main baseline |
| QRF engage | ONGUARD + SetEngageDetected | Framework nutzt Kombination selbst | APIs dokumentiert | Framework-Pattern vorhanden | MOOSE-first beibehalten |

## 13. Noch offene Source-/Runtime-Fragen

Vor Codeänderungen bleiben folgende Punkte offen:

```text
1. Welcher native MOOSE-Auftrag / welche Kombination liefert für AH-64 das beste
   standoff-orientierte Verhalten, ohne eigene Ziel-/Waffensteuerung nachzubauen?

2. Kann der CAS-Einsatz besser als PATROLZONE + SetEngageDetectedOn oder andere
   vorhandene MOOSE-Kombination aufgebaut werden, wie es das offizielle CAS-Enhanced-
   Beispiel demonstriert, statt NewCASENHANCED plus nachträglicher Route-Mutation?

3. Wie wird der owner-authored Valley-Corridor lifecycle-sicher an native
   MissionIngress/MissionEgress-Mechanismen gekoppelt?

4. Welche einzelne Höhenführungsquelle soll für Hubschrauber verwendet werden,
   damit RADIO-Waypoints und SetAltitude nicht gegeneinander arbeiten?

5. Wie wird die bindende Guard-Route OMW_RTE_BLUE_GUARD_HONAKER_01 sauber als
   MOOSE PatrolRoute umgesetzt und in DCS validiert?

6. Welches am Standort verfügbare Fahrzeugtemplate ist gemäß aktueller Ground-/ORBAT-
   Baseline der Phase-1-QRF zuzuordnen?
```

## 14. Entscheidungsgrenze

Dieser Audit autorisiert **keine** neue Eigenimplementierung von:

```text
Apache target selection
weapon selection
Hellfire standoff logic
custom search-and-destroy scheduler
custom RTB FSM
custom flight controller
```

Zulässige nächste Schritte sind ausschließlich:

```text
MOOSE direkt konfigurieren/kombinieren
-> native mission ingress/egress und patrol mechanisms nutzen
-> bestehenden kleinen Corridor-Adapter reduzieren/korrigieren
-> nur nach expliziter Projektfreigabe fehlende Metadatenadaption ergänzen
```

Alle daraus entstehenden Änderungen bleiben bis zu einem realen DCS-Test `SOURCE_REVIEWED`, nicht `VALIDATED`.
