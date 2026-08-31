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
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 Acceptance 1 – Honaker -> Wright -> Jalalabad Air-AMMO

## 1. Letzter realer DCS-Lauf: FAIL

Der zuletzt real ausgefuehrte kombinierte Lauf basiert auf dem damaligen Stage-3-Stand um Commit:

```text
40051fa657dd2df22352532e1f5bcdf37d17f846
```

Der Lauf ist ausdruecklich **FAIL** und kein `VALIDATED`-Nachweis.

Beobachtet beziehungsweise durch Log-Evidenz bestaetigt wurden insbesondere:

```text
Honaker OPSZONE radius                  1000 m
Wright ARTY real coordinate fire       yes
Wright physical ammo                   300 -> 288
coordinate fire missions               3 x 4 rounds
OPSZONE Defeated used as stop gate     wrong
AH-64 real weapon employment           yes
AH-64 tactical effect                  insufficient
AH-64 NewCAS orbit                     10000 ft ASL
CAS restricted to alarm zone           wrong
strategic closure                      not demonstrated
```

Die 1000-m-Alarmzone war im Acceptance-Code faelschlich gleichzeitig taktisches Zielbild und Response-Endbedingung. Dadurch konnte `OPSZONE Defeated` ARTY und CAS faktisch beenden, obwohl ausserhalb der Alarmzone weiterhin relevante RED-Kraefte vorhanden waren.

Der Projektinhaber hat anschliessend verbindlich klargestellt und auf `main` dokumentieren lassen:

```text
installation alarm/security zone
= trigger / threat-evidence boundary only
!= tactical battlespace
!= weapons engagement zone
!= fire-support target area
!= CAS engagement area
!= mission-end condition
```

Diese Regel gilt projektweit fuer missionsrelevante BLUE-Installationen und nicht nur fuer Honaker.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Fuer die aktuelle Korrektur source-verifiziert:

```text
OPSZONE Attacked / Defeated / Evaluated
OPSZONE:GetScannedGroupSet()
AUFTRAG / ARTY / AssignTargetCoord
EVENTHANDLER / EVENTS.Shot
FLIGHTGROUP waypoint callbacks
```

Die MOOSE-`OPSZONE` ruft nach einer regulaeren Auswertung `Evaluated` auf. Der OMW-Adapter exponiert diesen vorhandenen MOOSE-FSM-Pfad ab Schema `OMW-FOB-THREAT-OPSZONE-ADAPTER-3` als `onThreatEvaluated(...)` und uebergibt das aktuelle `GetScannedGroupSet()`.

Damit wird kein zweiter Feindscanner eingefuehrt.

## 3. Neue Trennung: Alarmbild und Attack Incident

Der revidierte Honaker-Vertrag verwendet die OPSZONE nur noch fuer unmittelbare Alarm-/Proximity-Evidenz.

```text
RED enters 1000-m alarm perimeter
-> MOOSE OPSZONE Attacked
-> PROXIMITY_INTRUSION evidence
-> ONE Honaker attack incident
```

Bei folgenden MOOSE-OPSZONE-Auswertungen:

```text
OPSZONE Evaluated
-> current RED groups in perimeter
-> add newly observed groups to active attack incident
```

Der Incident behaelt bekannte Angreifergruppen als Teilnehmer. Verlaesst eine bekannte lebende Gruppe spaeter die 1000-m-Zone, bleibt sie taktisch Teil dieses Angriffs.

```text
known attacker leaves alarm perimeter
-> OPSZONE may become Defeated
-> perimeterClear = true
-> attacker remains active incident participant while alive
-> ARTY / QRF / CAS are NOT terminated by perimeter state
```

Die Incident-Closure ist fuer diesen Acceptance-Fall explizit:

```text
no living known attack participant remains
-> Close("KNOWN_ATTACKERS_NEUTRALIZED")
```

Das ist ein Testvertrag fuer den bekannten Stage-3-Angriff und noch keine allgemeine BDA-/Combat-Closure-Architektur fuer alle spaeteren Missionstypen.

## 4. Wright-ARTY: Incident-basierter Live-Retarget-Cycle

Der alte Pfad las immer nur das aktuelle 1000-m-OPSZONE-Set. Das wird fuer die taktische Feuerleitung nicht mehr verwendet.

Neuer Ablauf:

```text
attack incident active
-> choose living known incident participant
-> read current GROUP:GetCoordinate()
-> ARTY:AssignTargetCoord(...)
-> 4-round Fire At Point
-> verify physical ARTY ammo decrease
-> reacquire living incident participants
-> choose next/same moving attacker
-> read fresh coordinate
-> queue next fire mission
-> repeat independently of OPSZONE Defeated
```

Der Adapter `OMW_FobAttackFunctionalArtyDispatchAdapter` bleibt der einzige OMW-Adapter um dieselbe caller-owned MOOSE-`ARTY`-Instanz. Es wird kein zweiter ARTY-Owner und kein paralleler Targetscanner eingefuehrt.

Fuer jede als abgeschlossen gewertete Fire Mission bleibt verbindlich:

```text
OnAfterOpenFire
-> ARTY:GetAmmo(false) baseline
-> real DCS fire
-> OnAfterCeaseFire
-> ARTY:GetAmmo(false) must be lower
```

Ohne reale Ammo-Abnahme kein positiver Fire-Support-Abschluss.

## 5. Rearm und strategische Closure

Der strategische Vertrag bleibt unveraendert:

```text
Wright CampaignState AMMO acceptance precondition: 30 -> 16
one real local MOOSE rearm:                    16 -> 15
reorder threshold:                             15
strategic RESUPPLY Jalalabad -> Wright:        +15
final Wright:                                  30
final Jalalabad:                               85
```

Eine physische Granate entspricht nicht einem strategischen `GROUND_AMMO_PACKAGE`. Genau ein realer lokaler Rearm-Zyklus belastet CampaignState um ein Paket.

## 6. CAS: bestaetigter Fehler und aktuelle MOOSE-first-Korrektur

Der aktuelle Zwischenbranch entkoppelt die taktische Ground-/ARTY-Closure von `OPSZONE Defeated` und korrigiert zusaetzlich die CAS-Lifecycle-Semantik.

Ein einzelnes `EVENTS.Shot` ist jetzt nur noch Ausfuehrungsevidenz:

```text
AH-64 fires
-> ConfirmExecutionEvidence(...)
-> evidence recorded
-> MissionDemand remains ACTIVE
```

Der erste Schuss darf den CAS-Demand nicht mehr erfolgreich abschliessen. Erfolg bleibt an den MOOSE-AUFTRAG-/Closure-Lifecycle gebunden und kann bei `requireExecutionEvidence=true` erst nach vorhandener realer Ausfuehrungsevidenz eintreten.

Der CAS-Adapter unterstuetzt ausserdem source-geprueft:

```text
MissionMode.CAS
MissionMode.CASENHANCED
```

`CASENHANCED` wird direkt ueber die in der gepinnten `Moose.lua` vorhandene Methode erzeugt:

```lua
AUFTRAG:NewCASENHANCED(
  tacticalZone,
  altitudeFtASL,
  speedKts,
  engageRangeNm,
  nil,
  targetTypes
)
```

Damit ist der Framework-Pfad fuer eine von der 1000-m-Alarmzone getrennte taktische CAS-Zone vorbereitet. Das aktuelle Stage-3-Szenario ist noch nicht auf diese Zone umverdrahtet; bis dahin bleibt der bisherige `NewCAS`-Pfad im Acceptance-Harness eine bekannte offene Stelle.

Die konkrete Honaker-Tactical-Zone und die AH-64-Combat-Hoehe muessen als Acceptance-Konfiguration explizit gesetzt und danach in DCS geprueft werden. Sie werden nicht stillschweigend als projektweite Doktrin festgelegt.

## 7. Helicopter-WEST-Hoehenproblem bleibt separat offen

Der Corridor erzeugt fuer `OMW_FlightPath_WEST` weiterhin:

```text
2500 ft AGL
RADIO altitude type
RotaryWing.Column.D70
SetAltitude(2500, true, true) at segment transition
```

Der letzte reale Lauf zeigte trotzdem nach visueller Owner-Beobachtung:

```text
first WEST area -> climb appears correct
later WEST waypoint(s) -> helicopter appears to descend again
```

Damit ist die Route-Konfiguration source-/logseitig belegt, das tatsaechliche DCS-Hoehenhalten aber nicht.

Der naechste Diagnoseausbau soll eventgebunden an MOOSE `PassingWaypoint` reale Flughoehe gegen Terrainhoehe protokollieren:

```text
waypoint UID
pathline/profile
requested AGL
actual MSL
terrain ASL
calculated actual AGL
```

Dafuer sind `FLIGHTGROUP:GetCoordinate()`, `COORDINATE:GetVec3()` und `COORDINATE:GetLandHeight()` im gepinnten MOOSE-Source vorhanden. Es wird kein hochfrequenter Scheduler benoetigt.

## 8. Guard und QRF in diesem Acceptance-Lauf

Die neue projektweite Installationsbaseline sieht fuer Guards bevorzugt owner-authored Patrol Routes und fuer QRF dynamische Infantry-plus-optional-Vehicle-Pakete vor.

Diese beiden qualitativen Erweiterungen werden **noch nicht gleichzeitig in diesen ohnehin fehlerbelasteten Stage-3-Kernlauf eingefuehrt**. Fuer diesen Acceptance-Zwischenschritt bleiben Guard und infantry-only QRF unveraendert, damit die nachgewiesenen Core-Probleme isoliert korrigiert werden koennen.

Spaetere Honaker-Erweiterung:

```text
Guard -> validated owner-authored patrol route
QRF   -> infantry + available MRAP/M-ATV/armed HMMWV package
```

Echtes Auf-/Absitzen bleibt ein eigener `OPSTRANSPORT`-Acceptance-Scope.

## 9. Revidierter End-to-End-Vertrag

```text
RED attack Honaker
-> MOOSE OPSZONE alarm evidence
-> one Honaker attack incident
-> current/new RED in alarm perimeter added as known incident participants
-> Honaker QRF reacts to incident participants
AND
-> Wright live coordinate fire cycle against living incident participants
   -> fresh coordinate
   -> real fire
   -> physical ammo proof
   -> reacquire incident participants
   -> repeat independent of perimeter Defeated
AND
-> Jalalabad AH-64 CAS
   -> separate tactical CAS zone via MOOSE CASENHANCED is prepared but Stage-3 wiring pending
THEN
-> known incident attackers neutralized
-> local M1083 rearm
-> CampaignState 16 -> 15
-> strategic RESUPPLY
-> Jalalabad CH-47 -> Wright
-> Wright 30 / Jalalabad 85
-> physical return lifecycle
```

## 10. PASS-Kriterien fuer den naechsten finalen Lauf

Vor einem neuen **finalen** Stage-3-DCS-Lauf muessen im Source mindestens CAS-Engagement-Area und AH-64-Combat-Profil sowie die WEST-Hoehendiagnose fertig sein.

Der anschliessende DCS-Lauf muss mindestens nachweisen:

1. `OPSZONE Attacked` erzeugt den Honaker-Attack-Incident.
2. Neue RED-Gruppen aus `OPSZONE Evaluated` werden demselben Incident hinzugefuegt.
3. `OPSZONE Defeated` beendet keine laufende ARTY-/CAS-/QRF-Response und ist kein PASS-Gate.
4. Honaker-QRF greift bekannte Incident-Angreifer an.
5. Wright fuehrt mehrere reale `AssignTargetCoord`-Fire Missions mit physischer Ammo-Abnahme aus, solange lebende bekannte Incident-Angreifer vorhanden sind.
6. Eine bekannte RED-Gruppe darf nach Verlassen der 1000-m-Zone weiter als taktisches Ziel bestehen.
7. CAS nutzt nicht die 1000-m-Alarmzone als alleinigen Kampfbereich.
8. AH-64 fuehrt wiederholte wirksame Angriffe im vorgesehenen taktischen Bereich aus; ein einzelner `Shot` ist kein taktischer Gesamt-PASS.
9. WEST-Hoehenprofil wird mit realer AGL-Telemetrie an relevanten Waypoints nachgewiesen.
10. Attack-Incident schliesst erst nach gueltiger eigener taktischer Endbedingung; fuer diesen Test: keine lebenden bekannten Angreifer.
11. Lokaler M1083-Rearm laeuft real und CampaignState erreicht Wright `15`.
12. Genau ein strategischer RESUPPLY-Demand/TRANSFER Jalalabad -> Wright ueber 15 Pakete wird ausgefuehrt.
13. CH-47 liefert physisch, Wright erreicht `30`, Jalalabad `85`.
14. CH-47 kehrt physisch nach Jalalabad zurueck und erst danach erfolgt `LegionAssetReturned`.
15. Kein `VALIDATED` ohne vollstaendige Commit-/MIZ-/Bundle-/MOOSE-/DCS-Provenienz.

## 11. Build-Vertrag

Die Acceptance mutiert keine `.miz`.

Build:

```text
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
```

Output:

```text
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

Aktueller Builder-Zwischenstand:

```text
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-5
```

Der aktuelle Builder weist ausdruecklich darauf hin, dass der Stage-3-Harness den finalen CASENHANCED-Tactical-Zone-Pfad noch nicht nutzt. Dieser Build ist daher **kein Aufruf zum finalen DCS-Acceptance-Lauf**.

## 12. Offene Punkte

```text
wire Stage 3 to CASENHANCED tactical zone separate from 1000-m alarm perimeter
choose/document acceptance-only AH-64 tactical zone geometry and combat altitude
repeated CAS attack / Search-and-Destroy behavior
real WEST waypoint AGL telemetry and resulting correction
DCS validation of incident participant retention after perimeter exit
DCS validation of sustained ARTY retarget cycle
full strategic resupply closure
later Guard patrol route
later mixed infantry/vehicle QRF
```

Bis diese Punkte reproduzierbar nachgewiesen sind, bleibt der Status `PLANNED` und `validated_in_dcs: false`.
