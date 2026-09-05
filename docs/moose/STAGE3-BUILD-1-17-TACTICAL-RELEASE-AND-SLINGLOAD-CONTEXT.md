---
document_id: OMW-MOOSE-STAGE3-BUILD-1-17-TACTICAL-RELEASE-AND-SLINGLOAD-CONTEXT
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 Build 1-17 remediation rationale
  - Build 1-16 runtime failure diagnosis for Guard/QRF, CAS closure, and CH-47 corridor handoff
  - Build 1-17 offline regression contract
  - Stage 3 supported-element, C2, and CAS release-authority separation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 Build 1-17 – Tactical Release, Ground-Materialisierung und Slingload-Kontext

## Anlass

Der DCS-Lauf vom 04.09.2026 mit Build 1-16 ist ein reproduzierbarer Fehltest und darf nicht als `VALIDATED` verwendet werden.

Geprüfte Laufzeit-Provenienz:

```text
DCS: 2.9.29.27468 MT
Build: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-16
GitCommit: 4a5b39bccbe80f597632f595a147afaa9ceadb36
Bundle SHA256: 75138CAD6890947139919C6751C28A4E0E4DDD3ECE5A415E8CECB25E377975D2
Independent SHA256: 75138CAD6890947139919C6751C28A4E0E4DDD3ECE5A415E8CECB25E377975D2
MizMutation: false
```

Build 1-17 korrigiert ausschließlich die im Lauf nachgewiesenen Ursachen. Die strategische Ressourcenhoheit, die owner-approved QRF-Zusammensetzung und die bereits genehmigte enge CARGOTRANSPORT-Ausnahme werden nicht erweitert.

Der vollständige aktuelle Branch-/Handoff-Stand steht zusätzlich in:

```text
docs/handoffs/2026-09-04-stage3-build-1-17-current-state-handoff.md
```

## 1. Build-1-16-Laufzeitergebnis

Gesamtstatus:

```text
FAIL
validated_in_dcs: false
```

Reale Beobachtung des Projektinhabers:

```text
Guard: keine Materialisierung
QRF: keine Materialisierung
CAS: R500/WEST ingress sichtbar; Angriff technisch brauchbar; danach zu langes Loitering,
     verspätetes Fuel-/Bingo-bedingtes RTB, direkter Rückflug statt Recovery-Korridor,
     Jalalabad nicht sicher erreicht
CH-47: Slingload-Transport physisch vorhanden, aber outbound und return direkte Luftlinie
```

Die drei nachgewiesenen OMW-Ursachen werden nachfolgend getrennt behandelt.

## 2. Guard / QRF – zu enger MOOSE-Spawnabstand

Build 1-16 setzte:

```lua
state.brigade:SetSpawnZone(accessZone, 100)
```

Der Runtime-Log meldete wiederholt:

```text
Request denied! Not close enough to spawn zone. Distance = 200 m.
We need to be at least within 100 m range to spawn.
```

Damit war die fehlende Guard-/QRF-Materialisierung kein ungeklärtes Pathfinding-Problem, sondern eine von OMW selbst gesetzte 100-m-Grenze.

Diese 100-m-Grenze war kein Owner-Vertrag. Sie war ein Implementierungsfehler des Assistenten.

Im gepinnten MOOSE-Source ist bestätigt:

```lua
function WAREHOUSE:SetSpawnZone(zone, maxdist)
  self.spawnzone=zone
  self.spawnzonemaxdist=maxdist or 5000
  return self
end
```

`BRIGADE` verwendet diesen WAREHOUSE/LEGION-Lifecycle. Build 1-17 setzt deshalb weiterhin die exakt vorgesehene Mission-Editor-Zone

```text
ZON_BLUE_GND_HONAKER_ACCESS
```

aber ohne künstliche 100-m-Begrenzung:

```lua
state.brigade:SetSpawnZone(accessZone)
```

Damit gilt der öffentliche MOOSE-Default von 5000 m. Warehouse-, CampaignState- und Alarm-Anchor bleiben unverändert. Es wird keine parallele Spawnlogik eingeführt.

### Guard-Vertrag

```text
Template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
PATHLINE: OMW_RTE_BLUE_GUARD_HONAKER_01
Routing: PATHLINE:GetCoordinates -> COORDINATE:WaypointGround
         -> GROUP:TaskFunction / SetTaskWaypoint / Route
Behavior: repeated circuit
```

### QRF-Vertrag

```text
Template: TPL_BLUE_GND_QRF_MIXED_6
Composition: 5 infantry + 1 CHAP_MATV
Representation: one GROUP
Embark/disembark: none
Personnel reservation: 5 GROUND_PERSONNEL
Mission: AUFTRAG:NewONGUARD
Recovery: SetReturnToLegion(true) + Cancel after tactical completion
Settlement: only after physical ARMYGROUP:Returned
```

## 3. CAS – taktisches Ende darf RTB nicht von Shot-Telemetrie abhängig machen

Der Build-1-16-Lauf zeigte, dass der bekannte Angriff intern beendet werden konnte, der AH-64 aber operativ nicht rechtzeitig aus dem PATROLZONE-Auftrag freikam.

Die problematische OMW-Kopplung war:

```text
operative tactical closure
AND
state.casFired acceptance telemetry
```

`EVENTS.Shot` ist ein sinnvoller Acceptance-Nachweis für reale Waffenverwendung. Er darf aber nicht die sichere operative Missionsbeendigung eines bereits taktisch abgeschlossenen Angriffs blockieren.

Build 1-17 trennt deshalb zwei Verantwortlichkeiten:

```text
Tactical completion:
zero living known attack-incident participants
-> Incident schließen
-> AUFTRAG Cancel sofort anfordern
-> vorhandene non-mission WEST/R500 recovery waypoints bleiben erhalten

Acceptance evidence:
real EVENTS.Shot remains required for overall PASS
-> blockiert aber nicht mehr die Recovery
```

`OMW_FobAttackCasPatrolClosure.lua` Schema 2 verlangt Execution Evidence nur noch, wenn der jeweilige Adapter explizit `requireExecutionEvidence=true` konfiguriert.

Stage 3 setzt:

```lua
requireExecutionEvidence=false
```

Die Acceptance-Endbedingung prüft `state.casFired` weiterhin separat. Damit wird keine Waffenwirkung erfunden und kein DCS-Event simuliert.

## 4. Neue CAS-Regression

Datei:

```text
tests/mission-demand/test_fob_attack_cas_patrol_closure.lua
```

Der Test erzeugt ausdrücklich den früher problematischen Zustand:

```text
PATROLZONE active
tacticalComplete = true
executionEvidenceConfirmed = false
requireExecutionEvidence = false
```

Geprüfter Vertrag:

```text
mission Cancel exactly once
closure result = CLOSED
demand status = SUCCESS
executionEvidenceConfirmed=false is recorded, not used as RTB blocker
```

Zusätzlich bleibt ein bewusst evidence-gateter Adapter abgesichert:

```text
requireExecutionEvidence = true
executionEvidenceConfirmed = false
-> EXECUTION_EVIDENCE_REQUIRED
-> no Cancel
-> demand remains ACTIVE
```

Damit kann die operative/telemetrische Kopplung nicht unbemerkt wieder eingeführt werden.

## 5. CH-47 – CARGOTRANSPORT-Handoff verlor Drop-Referenzen

Der reale Build-1-16-Lauf bestätigte:

```text
Physical slingload manifest created in ZON_BLUE_LOG_SLG_JALALABAD_01
CH-47 assigned; corridor injection waits for physical slingload pickup
Air-AMMO cargo physically picked up; corridor routing starts now
AIR-AMMO corridor failed: CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE
```

Damit wurde die Route nach dem Pickup nicht installiert. Der originale MOOSE-CARGOTRANSPORT blieb aktiv und flog deshalb direkt zwischen Pickup und Wright beziehungsweise zurück.

Der gepinnte MOOSE-Source bestätigt für

```lua
AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)
```

zum Konstruktorzeitpunkt:

```text
DCStask.params.groupId = StaticCargo:GetID()
DCStask.params.zoneId  = DropZone.ZoneID
DCStask.params.zone    = DropZone
DCStask.params.cargo   = StaticCargo
```

Der Fehler war die Annahme, dass diese constructor-time Felder im späteren post-pickup Lifecycle weiterhin eine zuverlässige operative Quelle darstellen. Diese Annahme ist durch den realen Lauf widerlegt.

OMW besitzt zu diesem Zeitpunkt jedoch bereits die autoritativen Laufzeitobjekte:

```text
state.cargo
ZONE:FindByName(OMW_BLUE_LZ_WRIGHT_01)
```

Build 1-17 übergibt diese beiden Objekte deshalb nach bestätigtem Pickup explizit an den Handoff:

```lua
{
  cargo = state.cargo,
  dropZone = dropZone,
}
```

Der Handoff leitet daraus ab:

```text
cargoId = cargo:GetID()
zoneId  = dropZone.ZoneID
```

`mission.DCStask.params` bleibt nur Fallback und ist keine zwingende post-pickup Voraussetzung mehr.

## 6. Genehmigte Slingload-Ausnahmegrenze

Die Ausnahmegrenze bleibt unverändert:

```text
MOOSE AUFTRAG:NewCARGOTRANSPORT owns:
  aircraft dispatch
  physical cargo identity
  pickup task
  AIRWING/SQUADRON lifecycle
  mission lifecycle

After confirmed physical pickup only:
  public FLIGHTGROUP GetWaypointCurrentUID/AddWaypoint/AddTaskWaypoint/UpdateRoute
  one DCS CargoTransportation waypoint task at Wright-side route exit

After confirmed physical delivery:
  AUFTRAG:Success()
  normal AIRWING/LEGION lifecycle continues
```

Nicht hinzugefügt werden:

```text
raw Controller:setTask route ownership
coalition.addGroup / coalition.addStaticObject
teleport
custom AIRWING replacement
custom CARGOTRANSPORT replacement
parallel CampaignState ownership
```

## 7. Neue CH-47-Handoff-Regression

Datei:

```text
tests/mission-demand/test_slingload_corridor_handoff.lua
```

Der Test entfernt absichtlich alle constructor-time MOOSE-Cargo-/Drop-Referenzen:

```lua
mission.DCStask = { params = {} }
```

und stellt nur explizite Runtime-Kontextobjekte bereit:

```text
cargo:GetID() = 7001
dropZone.ZoneID = 8002
```

Geprüfter Vertrag:

```text
handoff succeeds
mode = APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF
referenceSource = EXPLICIT_ACCEPTANCE_CONTEXT
outboundWaypointCount = 2
returnWaypointCount = 2
UpdateRoute called exactly once
CargoTransportation task exists
CargoTransportation.params.groupId = 7001
CargoTransportation.params.zoneId = 8002
original cargo corridor not used for this CARGOTRANSPORT path
```

Zusätzlich wird geprüft, dass Nicht-CARGOTRANSPORT-Missionen weiterhin an die ursprüngliche Corridor-Implementierung delegiert werden.

## 8. Regression-Suite

Beide neuen Tests sind in die reguläre Suite aufgenommen:

```text
tests/mission-demand/run.lua
```

Neue Einträge:

```text
test_fob_attack_cas_patrol_closure.lua
test_slingload_corridor_handoff.lua
```

Damit gilt für weitere Entwicklung auf diesem Branch:

```text
bekannter reproduzierbarer Fehlerpfad
-> source/MOOSE review
-> dedicated offline regression
-> CI PASS
-> lokaler Build + unabhängiger Hash
-> erst danach DCS-Lauf
```

## 9. MOOSE-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendete/verifizierte öffentliche Pfade:

```text
WAREHOUSE:SetSpawnZone
PATHLINE:FindByName
PATHLINE:GetCoordinates
COORDINATE:WaypointGround
GROUP:TaskFunction
GROUP:SetTaskWaypoint
GROUP:Route
AUFTRAG:NewONGUARD
AUFTRAG:SetEngageDetected
AUFTRAG:SetReturnToLegion
AUFTRAG:Cancel
AUFTRAG:NewPATROLZONE
FLIGHTGROUP:GetWaypointCurrentUID
FLIGHTGROUP:AddWaypoint
FLIGHTGROUP:AddTaskWaypoint
FLIGHTGROUP:UpdateRoute
AUFTRAG:NewCARGOTRANSPORT
AUFTRAG:Success
```

## 10. Aktueller CI-Stand vor dieser Dokumentationsfortschreibung

Implementierungs-/Regression-HEAD:

```text
b7a3c1bdae45f9460053feee52cab7ffd09ef7f1
```

GitHub Actions auf diesem Stand:

```text
Documentation validation #1547: PASS
MissionDemand validation #335: PASS
```

Spätere reine Dokumentationscommits verändern den Branch-HEAD, aber nicht diesen geprüften Implementierungsstand. Vor dem nächsten lokalen Build ist deshalb der dann aktuelle Remote-HEAD erneut exakt zu erfassen.

## 11. Build-1-17-DCS-Gate

Build 1-17 ist vor einem neuen exakten Lauf nur `PLANNED` / `validated_in_dcs:false`.

Noch ausstehend:

```text
local git pull
exact local HEAD
Build 1-17 builder output
GeneratedUtc
bundle SHA256
independent SHA256
MizMutation result
full DCS runtime acceptance
```

### Guard

```text
materializes through ZON_BLUE_GND_HONAKER_ACCESS
no 100-m rejection
follows OMW_RTE_BLUE_GUARD_HONAKER_01
repeated circuit observable
```

### QRF

```text
TPL_BLUE_GND_QRF_MIXED_6 materializes
5 infantry + 1 CHAP_MATV remain one GROUP
engages incident
receives ReturnToLegion after tactical completion
physically returns
PersonnelLedger settles on ARMYGROUP:Returned
```

### CAS

```text
Jalalabad -> R500 -> WEST -> AO
actual weapon employment
zero living known attack participants -> Honaker releases its current CAS requirement
supported-element release -> immediate PATROLZONE closure
no waiting until Bingo/Fuel
WEST reverse -> R500 reverse -> Jalalabad
no direct RTB shortcut
safe landing / AIRWING recovery
```

### CH-47

```text
physical SlingLoad pickup first
explicit cargo/drop references survive empty/changed mission.DCStask.params state
R500 outbound installed and physically flown
CargoTransportation resumes at Wright-side exit
physical delivery at Wright
R500 reverse physically flown
Jalalabad landing / AIRWING recovery
```

### Performance

```text
no recurrence of severe post-combat/RTB main-thread degradation
no endless patrol/recovery loop
no unnecessary permanent scheduler after completion
```

Erst nach diesem Lauf darf der Status geändert werden.

## 12. Implementierungsfehler, die nicht als Owner-Entscheidung bezeichnet werden dürfen

Für die weitere Historie ausdrücklich festhalten:

```text
1. SetSpawnZone(accessZone, 100) war ein Implementierungsfehler des Assistenten.
2. Die operative CAS-Closure zusätzlich an state.casFired zu koppeln war ein Implementierungsfehler des Assistenten.
3. mission.DCStask.params als dauerhaft verlässliche post-pickup Quelle zu behandeln war ein Implementierungsfehler des Assistenten.
4. Die konkreten Fehlerzustände nicht sofort als Offline-Regressionen festzuschreiben führte zu vermeidbaren wiederholten DCS-Testläufen.
```

Diese Punkte sind für weitere Reviews als Regression-Grenzen zu behandeln.

## 13. Owner-Entscheidung: lokale Honaker-Führung, C2-Lagegrenze und CAS-Release

Der Projektinhaber hat die Zuständigkeiten für den Honaker-Fall präzisiert. Diese Präzisierung ist für den Stage-3-Acceptance-Pfad verbindlich und verhindert eine künstliche zentrale "God's-eye"-Logik.

### 13.1 Guard und QRF gehören vollständig zu Honaker

```text
Honaker installation / local ground command
-> owns Guard employment
-> owns local QRF employment
-> owns Guard/QRF recovery decision within the installation response

C2
-> does NOT decide whether Honaker deploys Guard or QRF
```

Guard und QRF sind lokale Reaktionsmittel der Installation. C2 koordiniert externe Unterstützungsbedarfe, besitzt aber keine direkte Entscheidungsautorität über Honakers lokale Sicherungskräfte.

### 13.2 C2 besitzt kein automatisches taktisches Honaker-Lagebild

C2 darf nicht allein deshalb als informiert gelten, weil ein gemeinsames Lua-Objekt den Incident-Zustand kennt.

```text
C2 tactical knowledge
= reports from Honaker / supported element
OR reports from CAS
OR reports from an actually present ISR / sensor provider

NOT:
internal access to GroundInstallationAttackIncident
-> automatic omniscient C2 knowledge
```

Eine Drohne oder ein anderer real modellierter Sensor kann C2 zusätzliche Lageinformation liefern. Ohne solchen Sensor kennt C2 den aktuellen Feindstatus nur aus Meldungen der beteiligten Kräfte.

### 13.3 Vereinfachter Stage-3-CAS-Release-Vertrag

Für Build 1-17 wird bewusst keine zusätzliche komplexe CAS-/C2-Sensorfusion eingeführt. Der Acceptance-Test verwendet die folgende deterministische Vereinfachung:

```text
Honaker attack incident active
-> Honaker maintains its CAS requirement

zero living known Honaker attack-incident participants
-> Honaker local tactical assessment: NO_KNOWN_ATTACKERS_REMAINING
-> Honaker releases its current CAS requirement
-> PATROLZONE AUFTRAG Cancel
-> WEST reverse
-> R500 reverse
-> Jalalabad recovery
```

`tacticalComplete=true` im `OMW_FobAttackCasPatrolClosure` ist für diesen Pfad daher semantisch eine **Freigabe durch das unterstützte Element** und keine autonome Entscheidung von C2 oder des CAS-Flugs.

Der Closure-Adapter zeichnet diese Grenze jetzt als Ergebnis-Evidenz auf:

```text
releaseAuthority = SUPPORTED_ELEMENT
releaseSource = requesting installation / Honaker
```

Der zugehörige Offline-Test prüft diese Metadaten zusätzlich zur weiterhin erforderlichen genau einmaligen Mission-Cancel-Operation.

### 13.4 Was Build 1-17 bewusst nicht modelliert

Der folgende realistischere Konflikt wird in diesem Build nicht zusätzlich implementiert:

```text
Honaker reports no known attackers
BUT
CAS still has a relevant hostile contact
```

Eine spätere Produktionsausbaustufe kann dafür getrennte Statusreports und eine explizite Entscheidungskette modellieren. Dabei gilt bereits als Designgrenze:

```text
Honaker can maintain or release its support requirement based on its local tactical need.
CAS can report CONTACT / NO CONTACT / UNABLE / WINCHESTER / BINGO / DAMAGE.
C2 can retask or allocate external support based on reports actually received.
CAS seeing an unrelated hostile does not automatically extend the Honaker CAS task.
```

Diese spätere Erweiterung darf nicht erneut die aktuelle Stage-3-Acceptance mit zusätzlichen Completion-Guardrails belasten, bevor die einfache physische Recovery-Kette zuverlässig validiert ist.

### 13.5 CAS unable / fuel / weapons state

Ein CAS-Flug kann aus eigenem Flugzustand melden, dass er nicht weiter unterstützen kann, beispielsweise wegen Fuel/Bingo, fehlender geeigneter Bewaffnung oder Beschädigung. Das ist ein **CAS-Ausführungszustand**, keine Aussage darüber, dass Honakers Bodengefecht beendet ist.

Zielvertrag für die spätere Produktionslogik:

```text
CAS reports unable / Bingo / Winchester / damage
-> report to supported element and controlling agency
-> current aircraft leaves the CAS task
-> planned WEST reverse / R500 reverse recovery remains preferred
-> remaining CAS requirement may cause replacement / retask
```

Build 1-17 validiert weiterhin primär, dass die normale unterstützten-seitige Freigabe nicht bis zu einem DCS-Bingo-/Fuel-RTB verzögert wird.

### 13.6 Selbstschutz ist keine CAS-Zielautorität

Selbstschutz beziehungsweise unmittelbare Gefahr für den CAS-Flug ist von der normalen Honaker-CAS-Zielkette getrennt zu behandeln. Ein Selbstschutzfall darf nicht als allgemeine Autorisierung interpretiert werden, weitere sichtbare RED-Kräfte als Fortsetzung des Honaker-Auftrags zu bekämpfen.

Diese Rollen- und Informationsgrenzen verändern keine MOOSE-API und führen keine Native-DCS-Ausnahme ein. Die physische CAS-Ausführung bleibt MOOSE-first über `AIRWING`, `SQUADRON`, `AUFTRAG:PATROLZONE`, `SetEngageDetected` und die bereits dokumentierte öffentliche FLIGHTGROUP-Recovery-Kette.
