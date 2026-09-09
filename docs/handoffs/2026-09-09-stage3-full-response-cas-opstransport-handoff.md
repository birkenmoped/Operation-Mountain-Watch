---
document_id: OMW-HANDOFF-STAGE3-FULL-RESPONSE-CAS-OPSTRANSPORT-2026-09-09
status: PLANNED
document_class: DEVELOPMENT_STATUS_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local continuation state for Stage 3 Honaker full-response CAS, ARTY, QRF, Guard and Jalalabad CH-47 OPSTRANSPORT acceptance
  - known assistant implementation mistakes and rejected paths
  - tested evidence versus still-pending runtime validation
  - next-chat continuation instructions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
base_branch: agent/fire-support-strategic-resupply-closure
pull_request: 144
supersedes:
  - OMW-HANDOFF-STAGE3-OPSTRANSPORT-SLINGLOAD-CORRECTION-2026-09-07
superseded_by:
---

# Stage 3 – vollständige Übergabe CAS / Honaker Full Response / CH-47 OPSTRANSPORT

## 1. Zweck dieser Übergabe

Diese Datei ist die vollständige Übergabe für die Fortsetzung in einem neuen Chat. Sie dokumentiert den tatsächlichen Branch-Stand, die Owner-Entscheidungen, die durchgeführten DCS-Tests, die wiederholt aufgetretenen Assistentenfehler, die daraus abgeleiteten Korrekturen sowie den aktuell noch ausstehenden Gesamttest.

Wichtig: Diese Übergabe ist branch-lokal. Governance und BINDING-Dokumente auf `main` besitzen weiterhin höhere Autorität. Reale DCS-Beobachtungen gelten nur für den jeweils exakt dokumentierten Branch-/Commit-/Bundle-/Missions-/DCS-/MOOSE-Stand.

## 2. Verbindliche Arbeitsgrundlage

Vor jeder weiteren Arbeit mindestens prüfen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

Zusätzlich für diesen Scope:

```text
docs/moose/STAGE3-CAS-SUPPORT-REQUIREMENT-AND-ENGAGEMENT-DECISION.md
docs/moose/STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION.md
mission/tests/stage3-honaker-wright-full-response/ACCEPTANCE-1.md
mission/tests/stage3-honaker-cas-support/ACCEPTANCE-1.md
scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_HelicopterMissionOwnedCorridor.lua
scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua
scripts/air-operations/OMW_FobAttackCasPatrolClosure.lua
mission/tests/stage3-honaker-wright-full-response/src/01-honaker-wright-full-response-acceptance.lua
mission/tests/stage3-honaker-cas-support/src/01-honaker-cas-support-acceptance.lua
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
```

MOOSE-first bleibt verbindlich. Keine neue Native-DCS- oder Parallelimplementierung ohne dokumentierte MOOSE-Prüfung und ausdrückliche Owner-Freigabe.

## 3. Branch / PR / aktueller Remote-Stand

```text
Repository: birkenmoped/Operation-Mountain-Watch
Branch: agent/fire-support-strategic-resupply-alarm-evidence
Base branch: agent/fire-support-strategic-resupply-closure
PR: #144
PR state: open / draft
```

Letzter vor dieser Übergabedatei bestätigter Remote-HEAD:

```text
263b3f56a3593a542842ecd0f7294ab5aea9839b
```

Diese Übergabedatei selbst erzeugt einen nachfolgenden Commit. Vor lokaler Arbeit deshalb immer zuerst den aktuellen Remote-HEAD prüfen und nicht den oben genannten SHA blind voraussetzen.

## 4. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Dieser Stand war Grundlage der aktuellen Source-Prüfungen und bisherigen DCS-Tests.

## 5. Aktuelle Owner-Entscheidungen

### 5.1 Externe Slingload-Entwicklung ist gestoppt

Bis auf Weiteres gilt:

```text
NO external slingload development
NO AUFTRAG:NewCARGOTRANSPORT target path
NO PauseMission()/TaskDone() slingload handoff
NO re-injected CargoTransportation lifecycle bridge
NO OMW_SlingloadCorridorHandoff as current Stage 3 target path
```

Der aktuelle Air-AMMO-Pfad ist:

```text
Jalalabad
-> CH-47 via AIRWING/SQUADRON/FLIGHTGROUP
-> MOOSE OPSTRANSPORT
-> internal MOOSE STORAGE cargo
-> configured logical OMW_FlightPath outbound
-> Wright delivery / unload
-> OPSTRANSPORT Delivered
-> configured logical OMW_FlightPath reverse
-> Jalalabad landing
-> AIRWING/LEGION recovery
```

CampaignState bleibt alleinige strategische Ressourcenautorität; die MOOSE-STORAGE-Fixture ist nur physischer Acceptance-Nachweis.

### 5.2 CAS ist nicht an Ground-Completion gekoppelt

Folgende Größen besitzen ausdrücklich **keine CAS mission termination authority**:

```text
OPSZONE Defeated
1000-m alarm perimeter clear
attackIncidentClosed
number of living attack-incident participants
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC
raw RED-group count in the 5-NM area
state.casFired
```

Diese Werte dürfen Ground-/Honaker-Status, Diagnose oder Evidenz darstellen, aber einen laufenden CAS-Auftrag nicht automatisch beenden.

Der korrekte CAS-Vertrag lautet:

```text
Honaker local picture
!= CAS own detectedgroups picture
!= C2 allocation / retask authority
```

Normaler Lifecycle:

```text
Honaker detects attack
-> CAS support requirement created
-> C2 allocates CAS
-> AH-64 executes MOOSE PATROLZONE + SetEngageDetected
-> AH-64 maintains its own FLIGHTGROUP detection picture
-> Honaker and CAS status are reconciled independently
-> supported element/control explicitly releases CAS
-> recovery corridor
```

Der Acceptance-Sonderfall für normale Freigabe ist aktuell:

```text
HONAKER_NO_KNOWN_ATTACKERS
+
CAS is ON STATION
+
CAS_NO_CONTACT_REPORTED from FLIGHTGROUP:GetDetectedGroups()
-> SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
```

Wenn CAS noch einen engagement-eligible Kontakt erkennt, bleibt die Unterstützung aktiv. Ein bloßer F10-/Map-RED-Kontakt wird nicht künstlich mit `KnowTarget()` an den AH-64 injiziert.

### 5.3 CH-47 Transitprofil

Für den nächsten Full-Response-Test wurde festgelegt:

```text
CH-47 full-response transit speed: 125 kt
```

Grund: der generische MOOSE-Rotary-Wing-Cruise-Default lag praktisch bei ungefähr 110 kt; für die OMW-CH-47F ist 125 kt als gemeinsamer taktischer Transit mit AH-64 sinnvoller.

Noch offen und ausdrücklich **nicht validiert**:

```text
CH-47 solo/heavylift production transit profile
realistic hot/high internal payload limit Jalalabad <-> Wright
```

Der aktuelle Full-Response-Test transportiert nur eine physische Test-Fixture von 920 kg; das ist keine maximale CH-47F-Nutzlast.

### 5.4 Route smoothing / Lead-Turn

Der aktuelle MOOSE-Wegpunktpfad verwendet bereits Air `TurningPoint` und nicht `FlyOverPoint`.

Für den nächsten Gesamttest wurde ein kleiner MOOSE-naher Adapterpfad vorbereitet:

```text
leadTurnDistanceM = 250 m
public MOOSE COORDINATE:GetIntermediateCoordinate(...)
public MOOSE COORDINATE:HeadingTo(...)
public MOOSE FLIGHTGROUP:AddWaypoint(...)
public MOOSE FLIGHTGROUP:UpdateRoute()
```

Ziel: vor/nach scharfen Pathline-Vertices zusätzliche Turning Points erzeugen, damit DCS nicht erst exakt am Vertex den neuen Kurs setzt.

Das ist nur eine **lead-turn/fly-by approximation** auf Basis öffentlicher MOOSE-APIs, kein eigener DCS-Controller-Pfad.

## 6. Aktueller Full-Response-Zielbuild

Builder:

```text
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
```

Aktueller Zielstand:

```text
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-20
```

Geplante DCS-Bundle-Datei nach lokalem Build:

```text
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

Dieser Build ist **noch nicht lokal gebaut/hash-verifiziert und noch nicht in DCS getestet**, weil die Testmaschine aktuell nicht zur Verfügung steht.

## 7. Was im letzten großen Full-Response-Lauf funktioniert hat

Im realen vorherigen Full-Response-Lauf sah die physische Gesamtkette weitgehend gut aus:

```text
Guard: wirkte
QRF: wirkte
Wright ARTY: wirkte deutlich / mehrere Fire Missions
lokaler M1083-Rearm: wirkte
CH-47 OPSTRANSPORT internal STORAGE: funktionierte
configured FlightPath outbound: physisch geflogen
Wright delivery: funktionierte
configured reverse route: funktionierte
Jalalabad recovery: funktionierte
```

Der Owner beobachtete den CH-47 visuell entlang der Route; die Bilder zeigten den Flug und die Rückkehr bis zur Landung.

Der wesentliche Fehler dieses Full-Response-Laufs lag im CAS-Lifecycle: die AH-64 flogen, griffen aber in diesem Lauf nicht an und wurden zu früh aus dem Auftrag entlassen.

## 8. Reale Full-Response-CAS-Fehlbeobachtung

Im großen Lauf wurde protokolliert:

```text
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC radiusNm=5 alive=4 completionGate=INCIDENT_PARTICIPANTS
```

Gleichzeitig wurden die bekannten Honaker attack-incident participants als neutralisiert betrachtet und der CAS-Auftrag geschlossen.

Wichtig: Der Wert `alive=4` war und ist **nur Diagnose**. Er darf CAS nicht direkt steuern.

Der eigentliche Fehler war die alte Codekopplung:

```text
attackIncident participants == 0
-> attackIncidentClosed
-> closeCasIfReady()
-> CAS Cancel / RTB
```

Dadurch wurde eine temporäre Build-1-17-Acceptance-Vereinfachung fälschlich bis Build 1-19 weitergetragen.

## 9. Fokussierter CAS-Test danach

Um Detection/Engagement vom Full-Response-Lifecycle zu isolieren, wurde ein eigener CAS-only-Test erstellt:

```text
mission/tests/stage3-honaker-cas-support/src/01-honaker-cas-support-acceptance.lua
mission/tests/stage3-honaker-cas-support/ACCEPTANCE-1.md
tools/build-stage3-honaker-cas-support-acceptance-1.ps1
```

Lokal real gebaut und hash-verifiziert wurde:

```text
BuilderVersion: STAGE3-HONAKER-CAS-SUPPORT-ACCEPTANCE-1-1
Git HEAD: 885753d1c28bb61aabfbc16e863b1a3f17669393
Bundle SHA-256: B3CE4BD761C4A2E133B976EA948C8D8BF8ECF4F6D3765396C856AAD9F789F85F
```

Ein unabhängiger `Get-FileHash` ergab denselben SHA-256.

Der unabhängige Altpfad-Check auf:

```text
closeCasIfReady
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC
countRedGroundGroupsInTacticalZone
KnowTarget(
CASENHANCED
```

blieb leer.

### 9.1 Reales DCS-Ergebnis des fokussierten CAS-Tests

Der Owner beobachtete:

```text
beide AH-64 griffen tatsächlich an
beide AH-64 wurden anschließend abgeschossen
```

Damit wurde praktisch bestätigt:

```text
PATROLZONE + SetEngageDetected can produce real AH-64 engagement in this scenario
```

Der fokussierte Test beantwortet jedoch **nicht**, ob die AH-64 im großen Gesamtszenario nach Wegfall der ursprünglichen Honaker-Incident-Participants weitere relevante, von ihnen selbst erkannte Gruppen weiter bekämpfen.

Genau diese Integrationsfrage soll der nächste Full-Response-Build 1-20 beantworten.

## 10. Frühere interne OPSTRANSPORT-Evidenz

Ein fokussierter interner OPSTRANSPORT-Test hatte bereits real gezeigt:

```text
OPSTRANSPORT Delivered
configured reverse route installed after Delivered
MOOSE STORAGE transfer at Wright confirmed
```

Der aktuelle Full-Response-Pfad wurde danach auf denselben internen MOOSE-STORAGE-/OPSTRANSPORT-Mechanismus zurückgeführt.

Die physische Acceptance-Fixture lautet:

```text
Cargo type: ENUMS.Storage.weapons.bombs.Mk_82
Amount: 4
Item weight: 230 kg
Total physical fixture weight: 920 kg
```

Strategisch werden dagegen weiterhin genau:

```text
15 x GROUND_AMMO_PACKAGE
Jalalabad -> Wright
```

über CampaignState bewegt.

Erwarteter strategischer Endbestand nach erfolgreichem Gesamtlauf:

```text
Wright: 30
Jalalabad: 85
```

## 11. Wiederholte Assistentenfehler – ausdrücklich nicht wiederholen

### Fehler 1: MOOSE-first verletzt / externe Slingload-Eigenlogik gebaut

Trotz der verbindlichen MOOSE-first-Regel wurde zu früh eigene/parallel laufende Slingload-Logik entwickelt, anstatt die vorhandenen MOOSE-Transportmechanismen vollständig zu prüfen und zu verwenden.

Folge: zahlreiche unnötige und teure DCS-Läufe.

### Fehler 2: bereits verworfenen `NewCARGOTRANSPORT`-Pfad wieder eingeführt

Der Assistent brachte einen bereits verworfenen Pfad erneut als Zielarchitektur zurück:

```text
AUFTRAG:NewCARGOTRANSPORT()
PauseMission()/TaskDone()
CargoTransportation
OMW_SlingloadCorridorHandoff
```

Das führte erneut zu einem nutzlosen DCS-Test.

Dieser Pfad ist weiterhin gesperrt.

### Fehler 3: MOOSE-Demo falsch als External-Slingload-Beweis interpretiert

`Transport - 051 - COMBINED By All Means` wurde zeitweise zu weit interpretiert. Die Demo bestätigt die OPSTRANSPORT-/Carrier-/Transport-Richtung, beweist aber keine für OMW geeignete externe sichtbare Slingload-Repräsentation.

### Fehler 4: hart codierte konkrete FlightPath-Variante

Zeitweise wurde `OMW_FlightPath_R500` bzw. später der konkret vorgefundene Offset wie eine feste Routenidentität behandelt.

Korrekt ist:

```text
logical identity: OMW_FlightPath
valid configured variants: OMW_FlightPath / OMW_FlightPath_Rnnn / OMW_FlightPath_Lnnn
OMW_FlightPath_WEST: separate CAS segment, not primary candidate
```

Die tatsächlich konfigurierte Variante muss logisch aufgelöst werden; kein R200/R500 darf als Produktionsidentität fest codiert werden.

### Fehler 5: temporäre Build-1-17-CAS-Regel wie Produktionsarchitektur weitergetragen

Für Build 1-17 war temporär akzeptiert worden:

```text
all known Honaker attack-incident participants dead
= Honaker releases requested CAS
```

Diese Regel war ausdrücklich nur eine Acceptance-Vereinfachung.

Der Assistent trug sie dennoch bis Build 1-19 weiter und koppelte CAS direkt an `attackIncidentClosed`.

### Fehler 6: danach fast denselben Fehler erneut mit `TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC` gemacht

Nach dem Full-Response-Fehltest wurde zunächst vorgeschlagen, den 5-NM-RED-Count als neuen CAS-Completion-Gate zu benutzen.

Auch das wäre falsch gewesen:

```text
raw RED count != CAS termination authority
```

Die Owner-Vorgabe war bereits dokumentiert: Ground-Trigger und Ground-Zählungen haben nichts mit dem eigenständigen CAS-Lifecycle zu tun.

### Fehler 7: Testumfang unnötig wiederholt statt isoliert

Nach vielen langen Tests wurde zu häufig wieder ein großer DCS-Test vorgeschlagen, obwohl der Fehler vorher statisch oder fokussiert hätte isoliert werden können.

Daraus folgt für die Fortsetzung:

```text
no new 30-minute DCS run until static/build/hash gates are clean
use focused acceptance when a subsystem can be isolated
use full-response only for actual integration questions
```

### Fehler 8: PowerShell-Prüfbefehl mit unescaped Regex

Ein `Select-String`-Check auf `KnowTarget(` wurde ohne `-SimpleMatch` ausgegeben und scheiterte wegen der offenen Regex-Klammer.

Korrektur: für solche Literalprüfungen `-SimpleMatch` verwenden.

## 12. Aktuell überarbeitete Dokumentation

Besonders wichtig für den neuen Chat:

### CAS-Entscheidung

```text
docs/moose/STAGE3-CAS-SUPPORT-REQUIREMENT-AND-ENGAGEMENT-DECISION.md
```

Dieses Dokument hält die Trennung zwischen Honaker-local-picture, CAS-own-detectedgroups und C2/Release fest und retiret die Build-1-17-Vereinfachung.

### OPSTRANSPORT-/Slingload-Entscheidung

```text
docs/moose/STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION.md
```

Dieses Dokument hält fest, dass externe Slingload-Entwicklung gestoppt ist und der aktuelle Air-AMMO-Pfad MOOSE OPSTRANSPORT + interne STORAGE-Fracht benutzt.

### Full-Response-Acceptance

```text
mission/tests/stage3-honaker-wright-full-response/ACCEPTANCE-1.md
```

Wurde für Build 1-20 aktualisiert. Darin müssen CAS-Release-Trennung, 125-kt-CH-47-Transit und die 250-m-Lead-Turn-Acceptance weiter als `PLANNED`/nicht DCS-validiert erkennbar bleiben.

### Fokus-CAS-Acceptance

```text
mission/tests/stage3-honaker-cas-support/ACCEPTANCE-1.md
```

Dokumentiert den isolierten CAS-Mechanismus und die erforderlichen Telemetrie-/Lifecycle-Marker.

## 13. Aktueller Full-Response-Code – erwartete zentrale CAS-Marker

Der korrigierte große Test soll mindestens liefern:

```text
HONAKER_LOCAL_PICTURE
CAS_ON_STATION
CAS_SENSOR_REPORT
CAS_CONTACT_REPORTED
CAS_NO_CONTACT_REPORTED
CAS_ENGAGE_EVENT
EVENTS.Shot
HONAKER_NO_KNOWN_ATTACKERS
SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
```

Wichtiges erwartetes Verhalten:

```text
ARTY/QRF/Guard neutralisieren ursprüngliche Honaker participants
-> Honaker kann HONAKER_NO_KNOWN_ATTACKERS melden
-> CAS hat aber eigenes detectedgroups-Bild
-> wenn CAS noch relevanten Kontakt erkennt: CAS bleibt aktiv und darf weiter wirken
-> erst nach CAS no-contact + supported-element release: recovery
```

Das ist die zentrale noch offene Integrationsfrage.

## 14. Aktueller CH-47-Transport-/Routingvertrag

Für Build 1-20:

```text
MOOSE OPSTRANSPORT owns loading/transport/unloading/Delivered
OMW_OpsTransportCorridorAdapter owns only additional public FLIGHTGROUP route integration
CampaignState owns strategic resource state
```

Transportprofil für den nächsten Test:

```text
speedKts = 125
leadTurnDistanceM = 250
```

Der Route-Smoothing-Ansatz darf nicht in Native-DCS-Controller-Tasks eskalieren. Der Adapter soll auf öffentlichen MOOSE-`COORDINATE`-/`FLIGHTGROUP`-Methoden bleiben.

## 15. CH-47 interne Nutzlast – noch keine Produktionsentscheidung

Aktueller Test:

```text
920 kg physical STORAGE fixture
```

Das ist **nicht** die maximale interne OMW-Nutzlast.

Aktuell ist in der Jalalabad-SQUADRON-/AIRWING-Foundation keine projektspezifische interne Maximalnutzlast festgelegt.

Noch zu entscheiden/prüfen:

```text
realistic OMW hot/high internal payload contract for Jalalabad <-> Wright
fuel / elevation / temperature / mission reserve assumptions
whether production routing should use separate solo-heavy-lift and escorted-transit profiles
```

Bis dahin keine erfundene Maximalgrenze in Code oder Dokumentation einführen.

## 16. Noch ausstehender Test

Der Owner hat ausdrücklich mitgeteilt:

```text
der nächste Full-Response-Test muss nachgeholt werden;
die Testmaschine steht derzeit nicht zur Verfügung.
```

Daher jetzt **keinen DCS-PASS behaupten** und keinen neuen Runtime-Stand dokumentieren.

Vor dem nächsten realen Gesamttest:

```text
1. aktuellen Remote-HEAD prüfen
2. lokal git pull --ff-only
3. Builder 1-20 ausführen
4. lokalen GitCommit aus Builder-Ausgabe prüfen
5. Builder-SHA-256 mit unabhängigem Get-FileHash vergleichen
6. forbidden legacy checks prüfen
7. required corrected CAS + CH47 profile markers prüfen
8. erst dann DCS-Test freigeben
```

## 17. Erwarteter nächster DCS-Gesamttest

Der nächste Lauf soll gleichzeitig bestätigen:

### Ground / Honaker

```text
Guard materializes and patrols owner-authored path
QRF materializes and engages as applicable
QRF returns and PersonnelLedger settles
Honaker local attack incident closes independently of CAS
```

### CAS

```text
AH-64 launches from Jalalabad
flies configured FlightPath + WEST ingress
PATROLZONE + SetEngageDetected executes
AH-64 engages real contacts
AH-64 own detectedgroups remains active after Honaker local incident closure
if relevant contact remains -> CAS continues
if no contact remains and supported element releases -> CAS recovers
```

Falls beide AH-64 wieder abgeschossen werden, ist das als reale taktische Beobachtung zu dokumentieren; der Test darf deswegen nicht mit erfundener Recovery-Evidence als PASS gewertet werden.

### ARTY / local rearm

```text
Wright L118 fires real missions
physical ammo decreases
M1083 rearm occurs
M1083 returns
strategic reorder trigger reaches 15/30
```

### Strategic Air-AMMO

```text
exactly one RESUPPLY demand
15 x GROUND_AMMO_PACKAGE reserved Jalalabad -> Wright
CH-47 executes OPSTRANSPORT/STORAGE
125-kt route profile is observed/evidenced
lead-turn smoothing can be visually/logically evaluated
Wright delivery succeeds
reverse route succeeds
Jalalabad landing observed
AIRWING/LEGION recovery observed
Wright final 30
Jalalabad final 85
```

## 18. Was ausdrücklich nicht erneut geändert werden soll

Ohne neue konkrete Fehlerevidenz nicht anfassen:

```text
Guard architecture
QRF one-group mixed package architecture
Wright Functional ARTY path
M1083 local rearm service
CampaignState strategic transfer semantics
internal OPSTRANSPORT/STORAGE transport architecture
logical FlightPath name contract
external slingload suspension decision
```

Der nächste Test dient vor allem:

```text
CAS full-response lifecycle integration
+
CH-47 125-kt transit observation
+
lead-turn route-smoothing observation
```

## 19. GitHub / CI-Status vor dieser Übergabe

Für den letzten vor dieser Übergabedatei geprüften Stand liefen erfolgreich:

```text
Documentation validation: PASS
MissionDemand validation: PASS
Stage 3 Honaker Wright full-response Lua syntax: PASS
OMW_OpsTransportCorridorAdapter Lua syntax: PASS
focused Honaker CAS Lua syntax: PASS
MissionDemand contract tests: PASS
```

Ein zwischenzeitlicher CI-Fehler war kein Runtime-Fehler, sondern ein veralteter Testvertrag: `test_focused_cas_resupply_fixture_contract.lua` erwartete noch `OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-1`, nachdem der Adapter auf Schema 2 angehoben worden war. Der Testvertrag wurde auf Schema 2 aktualisiert; danach liefen die CI-Prüfungen wieder erfolgreich.

## 20. Arbeitsregel für den neuen Chat

Der neue Chat soll nicht aus Erinnerung raten, sondern vor Änderungen den aktuellen Branch lesen.

Arbeitsfolge:

```text
Governance
-> aktuelle Fach-/Owner-Entscheidungen
-> aktueller Branch-/PR-Stand
-> tatsächlicher Source
-> gepinnte Moose.lua
-> relevante MOOSE-Dokumentation / Source / Demo
-> kleinste notwendige Änderung
-> Syntax / Tests / Diff / Docs
-> Remote-Commit
-> lokale PowerShell pull/build/hash-Anweisung
-> reale Benutzer-Ausgabe
-> erst danach DCS-Test
```

Kein CODEX. Keine erfundenen Commits, Hashes oder DCS-Ergebnisse. Kein weiterer External-Slingload-Versuch ohne neue ausdrückliche Owner-Entscheidung.
