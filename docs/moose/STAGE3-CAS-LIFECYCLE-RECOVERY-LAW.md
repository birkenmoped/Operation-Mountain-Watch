---
document_id: OMW-MOOSE-STAGE3-CAS-LIFECYCLE-RECOVERY-LAW
status: BINDING
document_class: TECHNICAL_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local normative CAS request, allocation, execution, release and recovery lifecycle
  - separation of CampaignState, supported element/C2 and MOOSE AIRWING/WAREHOUSE authority
  - mandatory CAS route, release and physical-recovery invariants
  - Stage-3 CAS regression prevention and acceptance evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local assumptions that target destruction, ground incident closure, raw RED counts, fuel state or a MOOSE mission cancellation are a successful CAS completion
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 – Gesetz für CAS-Lifecycle und physische Recovery

## 1. Verbindlichkeit und Geltungsbereich

Dieses Dokument ist die verbindliche branch-lokale Norm für jeden Stage-3-CAS-Auftrag. Bis zu einem Merge nach `main` besitzt es keine repository-weite Wirkung; innerhalb dieses Branches darf kein CAS-Code, Bundle, Test oder Folgehand-off davon abweichen.

Es ergänzt, ohne zu ersetzen:

- [CAS Support Requirement and Engagement Decision](STAGE3-CAS-SUPPORT-REQUIREMENT-AND-ENGAGEMENT-DECISION.md);
- [CAS Tactical Corridor Decision](STAGE3-CAS-TACTICAL-CORRIDOR-DECISION.md);
- [Testmissionen bauen, übertragen und validieren](../22-test-mission-build-transfer-and-validation-workflow.md).

## 2. Unveränderliche Autoritätsgrenzen

| Ebene | Verbindliche Aufgabe | Darf nicht |
|---|---|---|
| Unterstütztes Element, z. B. Honaker | Lokales Lagebild; CAS-Bedarf erzeugen und halten; normale CAS-Freigabe aussprechen | MOOSE-DCS-Detektion der AH-64 ersetzen oder einen Luftweg erfinden |
| C2 | Bedarf priorisieren, eine passende verfügbare Herkunftsressource wählen und retasken; 5-NM-Feuerbeobachtung für QRF/ARTY führen | lokale Honaker-Incident-Daten als CAS-Ende behandeln |
| CampaignState | Strategische Ressourcen-ID, Herkunft, Reservierung, Status und idempotente Übernahme bestätigter physischer Ereignisse | paralleler physischer Flugzeugbestand oder Freigabe vor bestätigter Rückkehr |
| MOOSE | AIRWING/WAREHOUSE-/LEGION-Asset ausführen, `AUFTRAG`, `FLIGHTGROUP`, PATROLZONE, Detection, Route, Landung und Rückgabe verwalten | taktische Route, Freigabeautorität oder strategischen Ressourcenbesitz selbst erfinden |

DCS-Gruppen sind nur die temporäre physische Repräsentation der von MOOSE verwalteten Asset-Instanz.

## 3. Regulärer Ablauf

```text
CAS_REQUIRED
-> C2_ALLOCATED
-> AIRWING_ASSET_RECRUITED
-> AUFTRAG_ASSIGNED
-> LAUNCHED
-> ROUTE_TO_AO
-> CAS_ON_STATION
-> CAS_CONTACT_REPORTED | CAS_NO_CONTACT_PENDING
-> CAS_NO_CONTACT_REPORTED (stable >= 30 s)
-> SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
-> RECOVERING_ON_OWNER_REVERSE_ROUTE
-> HOME_AIRBASE_LANDED
-> LEGION_ASSET_RETURNED
-> CAS_COMPLETE
```

`CAS_COMPLETE` tritt ausschließlich nach der physischen Landung am zugewiesenen Heimatflugplatz **und** der MOOSE-`AIRWING:OnAfterLegionAssetReturned`-Rückgabe ein. Ein `AUFTRAG:Cancel()`, `Done`, ein Return-Befehl oder der Beginn eines Rückflugs ist keine Rückgabe in den Warehouse-/AIRWING-Bestand.

## 4. Bedarf, Allokation und Start

1. Honaker erzeugt einen CAS-Bedarf, wenn seine eigene lokale Lage externe Luftunterstützung verlangt.
2. C2 allokiert eine freie, ausdrücklich gebundene Herkunftsressource. Im aktuellen Full-Response-Szenario ist dies eine Jalalabad-AH-64D-Ressource.
3. MOOSE `AIRWING` rekrutiert die zugehörige Asset-/LEGION-Repräsentation aus seinem AIRWING-/Warehouse-Bestand und startet den zugewiesenen Auftrag.
4. Der Auftrag ist `AUFTRAG:NewPATROLZONE(...)` mit `SetEngageDetected(...)`. Die konkrete Allokation bestimmt das Profil; im Honaker-Full-Response-Test beträgt die AH-64-Transitgeschwindigkeit 125 kt.

Kein globaler, ungebundener AIRWING-Pool darf eine andere strategische Herkunft wählen.

## 5. Routengesetz

Die Owner-Routen sind die alleinige Quelle der Transitgeometrie:

```text
Heimatflugplatz
-> konfigurierte OMW_FlightPath-Variante
-> WEST
-> dynamischer CAS_INGRESS
-> PATROLZONE-AO
-> dynamischer CAS_EGRESS
-> WEST reverse
-> konfigurierte OMW_FlightPath-Variante reverse
-> Heimatflugplatz
```

Für **jede** Allokation gilt:

- `CAS_INGRESS` wird aus der tatsächlich gewählten Anflugroute im 3–4-NM-Band vor der AO abgeleitet.
- `CAS_EGRESS` wird aus der tatsächlichen Rückroute im 3–4-NM-Band nach der AO abgeleitet.
- Beide sind dynamische Routenpunkte, keine statischen Mission-Editor-Marker, PATHLINE-Endpunkte, Resolver-Endpunkte oder zufälligen MOOSE-Punkte.
- `CAS_MISSION_POINT` ist nur der dynamische AO-Anker von `PATROLZONE`; er ist keine erfundene Battle Position.
- MOOSE erhält diese drei Einzelknoten über `SetMissionIngressCoord`, `SetMissionWaypointCoord` und `SetMissionEgressCoord`. Die vollständigen Owner-Segmente werden ausschließlich mit öffentlichen `FLIGHTGROUP:AddWaypoint`-/`UpdateRoute`-Methoden installiert und über `OnAfterUpdateRoute` bestätigt.

Eine direkte Rückkehr zum Heimatflugplatz, ein Abkürzen durch Luftlinie oder ein UID-/Gebirgseinstieg außerhalb der abgeleiteten Owner-Route ist ein Regression-FAIL.

## 6. Auftrag in der AO

MOOSE führt `PATROLZONE + SetEngageDetected` aus. Das maßgebliche Luftlagebild kommt ausschließlich aus:

```lua
state.casFlight:GetDetectedGroups()
```

Ein gültiger Kontakt ist eine erkannte, lebende rote Bodengruppe innerhalb der konfigurierten CAS-Zone und des Engagement-Umfangs. Sichtbarkeit auf der F10-Karte, ein OPSZONE-Scan, Incident-Teilnehmer oder eine globale RED-Liste sind kein Ersatz. `KnowTarget()` und vergleichbare allwissende Zielinjektion sind verboten.

Sobald CAS physisch on station ist, sperrt C2 nur **neue** ARTY-Feuermissionen. Laufende Feueraufträge werden nicht künstlich abgebrochen.

## 7. Einzige normale Freigabe

Die reguläre Freigabe erfordert gleichzeitig:

```text
Honaker: HONAKER_NO_KNOWN_ATTACKERS
AND
AH-64: physically ON STATION
AND
AH-64 own FLIGHTGROUP:GetDetectedGroups(): no engagement-eligible contact
AND
the own no-contact picture remained stable for >= 30 seconds
```

Erst dann darf das unterstützte Element auslösen:

```text
SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
```

Danach darf MOOSE den PATROLZONE-Auftrag kontrolliert schließen und ausschließlich über die installierte Reverse-Route recovern.

Die folgenden Werte besitzen ausdrücklich **keine** CAS-Termination-Authority:

```text
OPSZONE Defeated
attackIncidentClosed
zero incident participants
raw RED count
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC
C2_FIRE_OBSERVATION
state.casFired
AUFTRAG completion/cancellation alone
```

Solange die Freigabe nicht vorliegt und kein dokumentierter Unable-to-Continue-Abbruch eingetreten ist, bleibt der CAS-Auftrag aktiv; ein Verharren bis Bingo ist jedoch kein akzeptierter Normalabschluss.

## 8. Abbruch, Verlust und Rückführung

Bingo/FuelLow, Winchester, Battle Damage, Emergency oder Verlust sind gesonderte Abbruch-/Verlustpfade. Sie erzeugen niemals künstliche `CAS_COMPLETE`-, Landungs- oder Warehouse-Rückgabe-Evidenz.

Ein Abbruch darf erst dann als kontrollierte Rückkehr gelten, wenn eine separate C2-Entscheidung, die installierte Reverse-Route, die physische Landung und die MOOSE-Asset-Rückgabe nachgewiesen sind. Andernfalls bleibt er `FAIL`, `PARTIAL` oder `NOT_RUN` gemäß Ergebnisbericht.

## 9. Pflicht-Evidenz und Regression-Gates

Vor einem DCS-Lauf müssen Source und Bundle mindestens ausgeben beziehungsweise prüfen:

```text
C2 allocation and bound origin pool
AIRWING asset recruitment
CAS_ROUTE_GATES_DERIVED
CAS_GEOMETRY_CONFIGURED
CAS_CORRIDOR_INSTALLED or explicit OnAfterUpdateRoute readiness
CAS_ON_STATION
CAS_SENSOR_REPORT from FLIGHTGROUP:GetDetectedGroups()
CAS_NO_CONTACT_REPORTED
SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
home-airbase landing
AIRWING/LEGION asset returned
```

Der reale DCS-Nachweis muss die vollständige Hashkette sowie die sichtbare Route und die physische Rückgabe belegen. Bis zu diesem Nachweis ist der Vertrag geplant/source-geprüft, nicht DCS-validiert.


## 10. Konkreter Implementierungsvertrag

Die folgende Tabelle beschreibt den tatsächlichen Source-Pfad des aktuellen
Stage-3-Full-Response-Tests. Sie ist kein DCS-Laufzeitnachweis.

| Phase | OMW-/Adapterteil | MOOSE-Schnittstelle | Ergebnis |
|---|---|---|---|
| Bedarf | CAS-Demand-Policy und `MissionDemand`-Registry | keine physische MOOSE-Aktion | eindeutiger CAS-Demand mit Herkunfts-/Assignee-Kontext |
| Allokation | CAS-Dispatch-Adapter, explizit gebundene AH-64D-SQUADRON | `AIRWING`, `SQUADRON`, `AUFTRAG` | AIRWING soll nur die vorgewählte Jalalabad-Ressource ausführen |
| Arbeitsraum | Full-Response-Integration | `ZONE_RADIUS` | 5-NM-PATROLZONE um die konkrete AO |
| Missionsauftrag | CAS-Dispatch-Adapter | `AUFTRAG:NewPATROLZONE`, `SetEngageDetected` | MOOSE owns tasking, detection activation and engagement FSM |
| Routenableitung | vorhandener `HelicopterCorridor.ResolveSequence` plus `FlightPathNameContract` | `PATHLINE`-Koordinaten | logische `OMW_FlightPath`-Variante und `WEST` werden aufgelöst; keine feste R500-/Lnnn-Produktionsidentität |
| Route gates | `OMW_HelicopterCasTacticalCorridor.PlanRouteGated` | `COORDINATE:Get2DDistance`, `HeadingTo` | dynamischer Ingress und Egress aus den Owner-Routen |
| MOOSE-Missionsknoten | `ConfigureMission` | `SetMissionIngressCoord`, `SetMissionWaypointCoord`, `SetMissionEgressCoord` | genau drei dynamische Einzelknoten; AO-Anker ist keine BP |
| volle Route | `Bind` | `GetGroupWaypointIndex`, `GetGroupEgressWaypointUID`, `AddWaypoint`, `UpdateRoute` | Owner-Transitsegmente werden in die MOOSE-Flugroute eingesetzt |
| Readiness | `Bind` | `FLIGHTGROUP:OnAfterUpdateRoute` | kein Einfügen, bevor MOOSE die Missions-UIDs erzeugt hat |
| Einsatzlage | Full-Response-Integration | `FLIGHTGROUP:GetDetectedGroups`, `OnAfterEngageTarget`, `EVENTS.Shot` | eigene Detektion, Engagement- und Waffenevidenz bleiben getrennt |
| Recovery | CAS-Patrol-Closure-Adapter | Mission closure, `OnAfterLanded`, `AIRWING:OnAfterLegionAssetReturned` | kontrollierter Rückflug, Landung und erst danach Asset-Rückgabe |

## 11. Exakter Routenadaptervertrag

Der einzige neue CAS-spezifische Adapter ist:

```text
scripts/air-operations/OMW_HelicopterCasTacticalCorridor.lua
schema: OMW-HELICOPTER-CAS-TACTICAL-CORRIDOR-1
```

Er hat genau drei öffentliche Aufgaben.

### 11.1 `PlanRouteGated(spec)`

Eingabe:

```text
outboundRoute
returnRoute
destinationCoordinate
routeGateDistanceNm: 3–4 NM
transitAltitudeFtAgl
missionAltitudeFtAgl
speedKts
allocationId
Honaker-/WEST-Evidenzreferenzen
```

Der Adapter wählt aus jeder bereits aufgelösten Owner-Route den Routenpunkt,
dessen radialer 2D-Abstand zur AO dem gewünschten Gate-Abstand am nächsten
liegt. Der beste Punkt muss innerhalb einer zusätzlichen NM Toleranz liegen.
Andernfalls wird kein Ersatzpunkt erfunden; der Adapter schlägt fehl.

Er erzeugt:

```text
ingress         = ausgewählter outbound-Routenpunkt
missionPoint    = destinationCoordinate als PATROLZONE_DYNAMIC_AO_ANCHOR_NOT_BP
egress          = ausgewählter return-Routenpunkt
outboundTransit = Owner-Routenpunkte vor ingress
returnTransit   = Owner-Routenpunkte nach egress
tacticalIngress = {}
tacticalEgress  = {}
```

Leere taktische Segmente sind Absicht: Die bestehende Owner-Route ist der
taktische Korridor. Dieser Adapter fügt weder eine heuristisch erfundene
Terrain-Masking-Strecke noch eine Battle Position ein.

### 11.2 `ConfigureMission(mission, geometry)`

Diese Funktion validiert zuerst die Geometrie: Allocation-ID, 3–4-NM-Band,
räumlich verschiedene Knoten, Höhe, Geschwindigkeit, Achse und
Evidenzreferenzen. Danach setzt sie ausschließlich:

```lua
mission:SetMissionIngressCoord(...)
mission:SetMissionWaypointCoord(...)
mission:SetMissionEgressCoord(...)
```

Die Methoden sind MOOSE-Missionshaken, keine Terrain- oder
PATROLZONE-Planungsfunktion.

### 11.3 `Bind(flightGroup, mission, geometry)`

`Bind` wartet, bis MOOSE die Mission- und Egress-UID der konkreten
`FLIGHTGROUP` bereitgestellt hat. Erst dann fügt er Transitpunkte mit
`FLIGHTGROUP:AddWaypoint` vor dem MOOSE-Ingress beziehungsweise nach dem
MOOSE-Egress ein und ruft `UpdateRoute()` auf.

Ist die Route noch nicht bereit, wird nur der öffentliche Callback
`OnAfterUpdateRoute` verwendet. Ein zeitgesteuertes wiederholtes
`UpdateRoute`, ein eigener Scheduler oder ein nativer DCS-Controller-Task
sind ausdrücklich ausgeschlossen.

## 12. Exakter Sensor- und Releasevertrag

`CAS_ON_STATION` entsteht erst, wenn die physische
`FLIGHTGROUP:GetCoordinate()` innerhalb der CAS-`ZONE_RADIUS` liegt.

Danach filtert die Full-Response-Integration das Ergebnis von:

```lua
state.casFlight:GetDetectedGroups()
```

auf lebende rote Bodengruppen innerhalb der PATROLZONE und des konfigurierten
Engagement-Umfangs. Jeder relevante Kontakt setzt die No-Contact-Qualifikation
zurück. `OnAfterEngageTarget` tut dies ebenfalls. `EVENTS.Shot` bestätigt
Waffeneinsatz, beendet aber keinen Auftrag.

Der No-Contact-Zeitstempel wird nur nach physischem On-Station gesetzt. Nach
30 Sekunden ohne relevanten eigenen Kontakt entsteht
`CAS_NO_CONTACT_REPORTED`. Die Full-Response-Integration ruft erst
zusammen mit `HONAKER_NO_KNOWN_ATTACKERS` die
`CasPatrolClosure.Complete(...)`-Schließung auf.

Die Schließung setzt `casRecoveryRequested`. Nur dann werden die folgenden
MOOSE-Ereignisse als reguläre Recovery-Evidenz gewertet:

```text
FLIGHTGROUP:OnAfterLanded am AIRWING-Heimatflugplatz
AIRWING:OnAfterLegionAssetReturned für exakt state.casFlight
```

## 13. Verbindliche Nichtsubstitutionen

Folgende Vereinfachungen sind unabhängig von ihrem beobachteten Erfolg
verboten:

```text
PATHLINE-Anfang/Ende als Ingress oder Egress
statischer Mission-Editor-Marker
zufälliger oder von MOOSE berechneter Ersatzpunkt
direkter Heimflug nach Zerstörung der ursprünglichen Incident-Gruppe
direkter Heimflug wegen leerem C2-/OPSZONE-Scan
allwissende Zielzuführung mit KnowTarget()
nativer DCS-Controller-Task für CAS-Routing
Timer-only Route-Readiness
AUFTRAG-Cancel = Warehouse-Rückgabe
FuelLow/Bingo-RTB = reguläre CAS-Completion
```

## 14. Offene Source-Befunde vor dem nächsten DCS-Lauf

Die folgenden Befunde sind statisch im aktuellen Source festgestellt. Sie sind
nicht als DCS-Laufzeitfehler behauptet, aber vor dem nächsten langen
Full-Response-Lauf zu korrigieren oder gezielt nachzuweisen.

1. `logCorridorProfiles()` erwartet die historische, nach Richtung
   geschachtelte Profilstruktur. Der neue CAS-Adapter liefert eine flache
   Liste. Damit sind die gewünschten detaillierten `CAS_ROUTE_PROFILE`-Logs
   voraussichtlich nicht vollständig. Die Routeninstallation selbst wird davon
   nicht geändert; die Regressions-Evidenz ist jedoch unzureichend.

2. Beim letzten `returnTransit`-Routenpunkt wird die Achse aktuell gegen
   denselben Punkt berechnet. Das ändert nicht die eingesetzte Koordinate,
   kann aber eine ungültige `axisDeg`-Telemetrie erzeugen. Der Adapter muss
   für den letzten Punkt eine gültige vorherige oder definierte Folgeachse
   verwenden.

3. Der Lua-Kopfkommentar des Adapters nennt noch taktische
   Ingress-/Egress-Segmente und eine BP. Das widerspricht diesem Gesetz und
   muss beim nächsten Adapter-Commit auf den tatsächlichen
   Owner-Route-Gate-/AO-Anker-Vertrag bereinigt werden.

Keiner dieser Befunde berechtigt zu einer Rückkehr zu statischen Markern,
einer BP-Heuristik oder einem nicht-MOOSE-Routingpfad.

## 15. Abnahmegrenze

Statischer Build, Syntax oder Builder-Hash bestätigen nur Source-Identität und
Guard-Erfüllung. Sie beweisen nicht:

```text
physisch geflogene Route
korrekte Transitgeschwindigkeit
kein UID-Gebirgseinstieg
tatsächliche eigene Detektion
kontrollierten Egress vor FuelLow
Landung
AIRWING-/LEGION-Rückgabe
```

Diese Punkte bleiben bis zu einem vollständigen MIZ-/Bundle-Preflight und
einem dokumentierten DCS-Lauf `NOT_RUN`.
