# Ground Ammo Rearm Integration – aktueller Stand und TODO

Stand: 22.08.2026

## 1. Arbeitszweig und Autorität

```text
Repository: birkenmoped/Operation-Mountain-Watch
Arbeitsbranch: agent/ground-ammo-rearm-integration
Branch-Stand vor diesem Dokumentations-Commit:
04674c29061c6a70f54b537598442857448441b6

Projektphase auf main:
COMPLETE_FOUNDATION_BUILD_PHASE
```

Dieser Branch ist ein Integrations-/Arbeitsstand. Projektweit verbindlich bleiben ausschließlich die nach Governance dafür autorisierten Dokumente auf `main`.

Vor jeder relevanten Weiterarbeit mindestens auf `main` prüfen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

Zusätzlich für diesen Scope insbesondere:

```text
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
docs/moose/MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md
mission/tests/ground-ammo-rearm-integration/README.md
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/ground/OMW_BostickAmmoRearmService.lua
scripts/ground/OMW_BostickAmmoSupport.lua
scripts/ground/OMW_GroundSupportMaterializer.lua
scripts/ground/OMW_GroundRoadSpawnAdapter.lua
scripts/campaign/OMW_CampaignState.lua
```

## 2. Ziel des Arbeitsblocks

Ziel ist ein belastbarer lokaler Ground-Rearm-Lifecycle für feste BLUE-Feuerunterstützung am Beispiel Bostick:

```text
fixed L118 battery
-> controlled firing
-> observable ammunition reduction
-> M1083 request/materialization through existing MOOSE Ground lifecycle
-> local CampaignState GROUND_AMMO_PACKAGE CONSUMPTION
-> ARTY:Rearm()
-> native DCS rearm effect
-> ARTY Rearmed/full-ammo confirmation
```

Strategische Hoheit bleibt ausschließlich beim gemeinsamen `CampaignState`. DCS-/MOOSE-Munitionszustände sind operative Telemetrie und keine zweite strategische Ressourcenquelle.

## 3. Verbindlicher MOOSE-Stand für diesen Testscope

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der produktive Fixed-Battery-Pfad ist MOOSE-first:

```text
ARTY
+ explicit SetRearmingGroup(...)
+ ARTY FSM / Rearm / Rearmed
```

`AMMOTRUCK` bleibt für diesen ersten Fixed-Battery-Pfad sekundär, weil der geprüfte Framework-Pfad zusätzliche autonome Dispatcher-/ammo_cargo-Static-Semantik besitzt, die hier nicht benötigt wird.

## 4. Aktuelle Build-/Bundle-Provenienz

### Acceptance-Bundle

```text
Source/Build commit:
213119ca03a6aeae529d4291b4bbe174ac0995c2

BuilderVersion/TestId:
GROUND-AMMO-REARM-ACCEPTANCE-1

Bundle:
mission/tests/ground-ammo-rearm-integration/dist/OMW_Ground_Ammo_Rearm_Acceptance_1.lua

SHA-256:
94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
```

### gemeinsamer Warehouse-/CampaignState-Bundle

```text
Build commit:
7da56fdfb45888e7f88d4ea5c3b0fa691f2b0423

BuilderVersion:
OMW-AIROPS-WAREHOUSE-BASE-3

Bundle:
mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua

SHA-256:
FC0F8F20909DD57E5DEE3AF6414FB56B35D8671D726471DEDB6D6984E590801B
```

Dieser Stand seedet Ground-Initialbestand in denselben autoritativen CampaignState und erzeugt keinen zweiten Ground-Store.

### Ground-Production-Bundle mit echtem DCS-Readiness-Flag

```text
Build commit / Branch-HEAD des getesteten Builders:
04674c29061c6a70f54b537598442857448441b6

BuilderVersion:
OMW-GROUND-PRODUCTION-BASE-3

Bundle:
mission/ground-operations/dist/OMW_Ground_Base.lua

SHA-256:
6DBDE7AA75E34FA6C7A42A7C97B3E407C069806666C60E8D27F8616D647383EE

GroundReadyFailClosed: true
GroundReadyContractMarkersVerified: true
```

BASE-3 verwendet den öffentlichen MOOSE-`USERFLAG`-Pfad. `OMW_GROUND_READY` wird fail-closed auf 0 initialisiert und erst nach erfolgreichem `OMW.Ground.Base.Attach(...)` plus DCS-Userflag-Readback auf 1 gesetzt.

## 5. DCS-Runtime-Ergebnis vom 21.08.2026

DCS:

```text
2.9.28.26385 MT
```

Zurückgemeldete Runtime-Logs:

```text
dcs(20260821-215616).log
SHA-256:
8ECFD3CACC58FF0421E55280D7CE63EFA2A6C1CDA0A09095F7A69E588290DE71

debrief(20260821-215616).log
SHA-256:
B773DDB09401B7E58F4393EEEEDCE858EB98F769E1BE2DE9AB12392B10583A9E
```

Der DCS-Log bestätigt den vollständigen funktionalen Pfad:

```text
initialAmmo = 300
postFireAmmo = 296
support type = CHAP_M1083
GROUND_AMMO_PACKAGE before = 52
after = 51
finalAmmo = 302
PASS M1083_REARM_CONFIRMED=true
```

Damit ist für den tatsächlich gelaufenen Scope praktisch beobachtet:

```text
Ground readiness USERFLAG bridge        PASS
OMW_GROUND_READY Mission-Editor gate    PASS
L118 controlled firing                  PASS
observable ammunition reduction         PASS
M1083 WAREHOUSE self-request            PASS
M1083 materialization                   PASS
CHAP_M1083 operational rearm support    PASS
CampaignState local consumption         PASS
one GROUND_AMMO_PACKAGE debit           PASS
ARTY:Rearm() operational path           PASS
ARTY Rearmed callback                   PASS
full-ammo restoration                   PASS
```

Der Debrief bestätigt zusätzlich `OMW_GROUND_READY=1` als echten Trigger-State.

### Intentionales BLUE-OP-Ziel

Die Acceptance-Zielzone lag absichtlich auf einem BLUE OP, damit die Artillerieeinschläge beobachtbar waren. Im Debrief erscheinen entsprechend zwei BLUE-Infanterieverluste:

```text
Soldier M249
Soldier M4
```

Diese Verluste sind daher keine Testanomalie oder Friendly-Fire-Limitierung, sondern ein bewusst erzeugter physischer Ground-Verlust.

Sie liefern gleichzeitig einen später relevanten Integrationsfall:

```text
OP personnel loss
-> responsible COP/FOB/node strength deficit
-> reinforcement/resupply demand
-> physical replacement movement
-> restored OP strength
```

Dieser nachgelagerte Verstärkungs-Lifecycle wurde in diesem Acceptance-Lauf jedoch NICHT getestet und darf noch nicht als funktionierend dargestellt werden.

## 6. Statusgrenze des Runtime-PASS

Der funktionale Rearm-Pfad hat real `PASS` geliefert. Der Stand wird trotzdem noch NICHT als repository-weite oder vollständige `ACCEPTED_TECHNICAL_BASELINE` erklärt.

Noch fehlende Acceptance-Provenienz:

```text
exact executed MIZ file SHA-256
internal mission SHA-256 / final embedded-resource recheck for the executed artifact
```

Der Debrief nennt als ausgeführten Pfad:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v15.miz
```

Der exakte SHA-256 dieser tatsächlich ausgeführten Datei muss noch vom Projektinhaber real zurückgemeldet beziehungsweise die ausgeführte `.miz` erneut read-only geprüft werden. Vorher bleibt die korrekte Formulierung:

```text
FUNCTIONAL DCS RESULT: PASS
ACCEPTED_TECHNICAL_BASELINE: PENDING PROVENANCE CLOSURE
MERGED_TO_MAIN: false
```

## 7. Aktuelle TODO-Liste

### TODO 1 – Acceptance-Provenienz schließen

**Ziel:** Den vorhandenen Runtime-PASS reproduzierbar an das exakt ausgeführte Missionsartefakt binden.

**Aktueller Stand:** DCS-/Debrief-Logs, Bundle-Hashes, MOOSE-Hash und Runtime-Marker liegen vor. Exakter Hash der tatsächlich ausgeführten `.miz` fehlt noch.

**Noch zu tun:**

```text
1. SHA-256 der tatsächlich ausgeführten OMW_Template_v15.miz real ermitteln.
2. Dieselbe ausgeführte .miz read-only prüfen/hochladen.
3. Embedded hashes erneut bestätigen:
   - Moose.lua
   - OMW_AirOps_Warehouse_Base.lua
   - OMW_Ground_Base.lua
   - OMW_Ground_Ammo_Rearm_Acceptance_1.lua
4. internal mission SHA-256 dokumentieren.
5. Erst danach den exakten Teststand als ACCEPTED_TECHNICAL_BASELINE bewerten.
```

### TODO 2 – MOOSE-Dokumentation auf den realen PASS anheben

**Ziel:** Projekt-MOOSE-Dokumentation mit dem praktisch bestätigten ARTY-/USERFLAG-/WAREHOUSE-Scope synchronisieren.

**Aktueller Stand:** Source-Review ist vorhanden; `ARTY` steht im Projektklassenindex noch nur auf `SOURCE_REVIEWED`. Der Runtime-PASS ist dort und in `VERIFIED-METHODS.md` noch nicht eingetragen.

**Noch zu tun nach Provenienzschluss:**

```text
1. docs/moose/PROJECT-CLASS-INDEX.md aktualisieren.
2. ARTY für exakt den bestätigten Scope auf VALIDATED_FOR_DOCUMENTED_SCOPE anheben.
3. docs/moose/VERIFIED-METHODS.md ergänzen:
   - ARTY:New
   - ARTY:AssignTargetCoord
   - ARTY:GetAmmo
   - ARTY:SetRearmingGroup
   - ARTY:SetRearmingGroupOnRoad
   - ARTY:Rearm
   - OnAfterCeaseFire / OnBeforeRearm / OnAfterRearmed
   - USERFLAG readiness gate where applicable
4. docs/moose/MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md Abschnitt 16.8–16.11 auf Runtime-Befund aktualisieren.
5. CHAP_M1083 von DCS_RUNTIME_OPEN auf den exakt getesteten Bostick-Rearm-Scope anheben.
6. VERIFIED-METHODS nur mit vollständiger Mission-/Bundle-/DCS-/MOOSE-Provenienz aktualisieren.
```

### TODO 3 – BostickAmmoRearmService Lifecycle-Hygiene korrigieren

**Ziel:** Den getesteten Vertical Slice vor Produktionsfreigabe gegen bekannte Source-Risiken absichern.

**Aktueller Stand:** Der Runtime-Pfad funktioniert im Acceptance-Harness. Im Produktionsservice bleiben jedoch bekannte Source-Hygienepunkte offen.

**Noch zu tun:**

```text
1. Synchrones onMaterialized-/pending-Kontext-Overwrite in OMW_BostickAmmoRearmService.lua beheben.
2. Contract-Test ergänzen, der einen synchronen Materialisierungs-Callback abbildet.
3. Bestehende Test-Fakes auf reales MOOSE-FSM-Verhalten korrigieren:
   erfolgreicher FSM-Transition-Handler kann nil liefern; nur false ist explizite Ablehnung.
4. OMW_BostickAmmoSupport.GetConfig() auf spec/platoon-name override prüfen und korrigieren.
5. Lua-/Diff-/Contract-Prüfung erneut durchführen.
```

### TODO 4 – Restart/Replay-Semantik für LOCAL REARM entscheiden

**Ziel:** Verhindern, dass nach Serverrestart eine bereits `CONSUMED` gebuchte lokale Rearm-Transaktion erneut physisch kostenlos rearmen kann.

**Aktueller Stand:** CampaignState `Consume(transactionId)` ist korrekt idempotent und bucht strategisch nur einmal ab. Für einen Neustart zwischen CONSUMED und dauerhaft bestätigter physischer Completion existiert jedoch noch kein belastbarer Produktionsvertrag.

**Owner-Entscheidung erforderlich.** Nicht stillschweigend implementieren.

Zu bewertende Richtungen:

```text
A. dauerhafte Rearm-Completion-/Settlement-Metadaten
B. Restart-Compensation für CONSUMED aber nicht dauerhaft abgeschlossene lokale Rearms,
   analog zum bestehenden Ground-Commitment-Reconciliation-Prinzip,
   danach neue Transaction für erneuten Rearm
C. Consume erst bei OnAfterRearmed
   -> derzeit nicht bevorzugt, weil die strategische Ressource während des physischen Rearm-Vorgangs ungebunden bliebe
```

Vor Implementierung muss der Projektinhaber die gewünschte Semantik festlegen.

### TODO 5 – OP-Verluste und automatische Verstärkung als getrennten Scope definieren

**Ziel:** Physische Verluste an vorgelagerten OPs sollen künftig einen nachvollziehbaren Strength-/Reinforcement-Demand beim zuständigen COP/FOB/Node erzeugen.

**Aktueller Stand:** Im jetzigen Lauf wurden zwei BLUE-Infanterieverluste am absichtlich beschossenen OP real beobachtet. Es wurde KEINE automatische Auffüllung getestet.

**Noch zu entscheiden/klären:**

```text
1. Welche feste Hierarchie gilt OP -> verantwortliches COP/FOB -> CampaignState node?
2. Welche Soll-/Mindeststärke wird pro OP geführt?
3. Werden Personnel und gegebenenfalls Vehicle getrennt demanded?
4. Welcher bestehende MissionDemand-/Ground-Lifecycle soll den Demand aufnehmen?
5. Welche physische MOOSE-Ausführung bringt Verstärkung zum OP?
6. Was geschieht bei erneutem Verlust während des Verstärkungstransports?
```

Dieser Scope darf nicht in den Rearm-Adapter hineingemischt werden.

### TODO 6 – Regression und Produktionsintegration

**Ziel:** Nach Source-Hygiene und Restart-Entscheidung den Rearm-Vertical-Slice als belastbaren Produktionsbaustein integrieren.

**Noch zu tun:**

```text
1. Source-Fixes umsetzen und remote committen.
2. vollständigen Diff prüfen.
3. Ground-Contract-Suite ausführen, soweit Umgebung verfügbar.
4. neue Ground-/Acceptance-Bundles bauen und reale Hashes zurückmelden lassen.
5. kombinierte DCS-Regression statt unnötiger Single-Feature-Missionen verwenden.
6. mindestens prüfen:
   - full-battery rejection leaves stock unchanged
   - no duplicate CampaignState consumption
   - M1083 interruption/loss behavior
   - Rearmed/full-ammo completion
   - restart/replay contract
7. Dokumentation und MOOSE-Verifikationsregister aktualisieren.
8. erst nach dokumentiertem Test und Owner-Freigabe Merge-/Ready-Entscheidung treffen.
```

## 8. Bearbeitungs- und Übergabeanweisungen

### Source-of-truth

```text
Source Lua
-> offizieller PowerShell-Builder
-> generiertes dist-Bundle
-> Mission Editor DO SCRIPT FILE
-> gespeicherte Test-MIZ
-> MIZ/embedded hash check
-> DCS runtime
-> dcs.log + debrief.log
-> Ergebnisdokumentation
```

Generierte `dist/`-Dateien nicht manuell editieren.

`.miz` nicht automatisiert oder strukturell außerhalb des freigegebenen Mission-Editor-Workflows verändern. Mission-Editor-Änderungen nur nach dem geltenden Governance-/Owner-Gate.

Wenn in einem Mission-Editor-Arbeitsschritt mehr als eine Lua-Ressource auszutauschen ist, am Ende der Anweisung immer eine vollständige Austauschliste liefern:

```text
AUSZUTAUSCHEN:
1. <Datei>
   Trigger: <Name>
   Quelle: <vollständiger Repository-Pfad>
   erwarteter SHA-256: <Hash>

NICHT AUSTAUSCHEN:
- <Dateien>

SONSTIGE MIZ-ÄNDERUNGEN:
- <vollständige Liste oder keine>
```

Keine verteilten/impliziten Austauschhinweise voraussetzen.

### GitHub-Workflow

```text
Repository/Governance prüfen
-> Änderung durch ChatGPT erstellen
-> Diff/Syntax/Tests/Doku/MOOSE-First prüfen
-> ChatGPT committed selbst
-> ChatGPT veröffentlicht selbst auf vorgesehenen Remote-Branch
-> erst danach nummerierte PowerShell-Anweisung für lokale Schritte
-> Projektinhaber liefert reale Konsole und reale Hashes zurück
```

Keine lokalen Builds, Hashes oder DCS-Ergebnisse annehmen oder simulieren.

Kein CODEX.

### MOOSE-First

Vor neuer operativer Lua-Logik immer:

```text
passende MOOSE-Dokumentation
-> tatsächlich verwendete Moose.lua
-> Signaturen/Rückgaben/Events/FSMs/Voraussetzungen
-> offizielle MOOSE-Demos/Tests soweit relevant
-> erst danach kleinste notwendige Ergänzung
```

Keine MOOSE-Klasse, Methode, Rückgabe oder DCS-Wirkung erfinden.

### Ressourcenhoheit

```text
CampaignState = strategische Autorität
MOOSE/DCS = operative physische Ausführung/Telemetrie
```

Keine doppelte Ressourcenhoheit zwischen CampaignState, CTLD, MOOSE WAREHOUSE und DCS Warehouses einführen.

## 9. Unmittelbarer nächster Arbeitsschritt

Der nächste Schritt ist NICHT ein weiterer identischer DCS-Rearm-Lauf.

Zuerst wird die Acceptance-Provenienz geschlossen:

```text
Get-FileHash der tatsächlich ausgeführten
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v15.miz
```

Danach wird genau diese `.miz` read-only gegen die vier eingebetteten Runtime-Artefakte geprüft. Erst anschließend werden MOOSE-Register und Acceptance-Status endgültig angehoben und die offenen Produktions-Hygienepunkte bearbeitet.
