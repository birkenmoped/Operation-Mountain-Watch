# Ground Ammo Rearm Integration – aktueller Stand und TODO

Stand: 22.08.2026

## 1. Arbeitszweig und Autorität

```text
Repository: birkenmoped/Operation-Mountain-Watch
Arbeitsbranch: agent/ground-ammo-rearm-integration
Acceptance-provenance parent/status commit before documentation reconciliation:
f74d29ce3e0de0b0fc6d4e5d829e0bdfaddb9be3

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
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der Fixed-Battery-Pfad ist MOOSE-first:

```text
ARTY
+ explicit SetRearmingGroup(...)
+ ARTY FSM / Rearm / Rearmed
```

`AMMOTRUCK` bleibt für diesen ersten Fixed-Battery-Pfad sekundär und weiterhin nur `SOURCE_REVIEWED`; es wurde im Acceptance-Lauf nicht ausgeführt.

## 4. Build-/Bundle-Provenienz

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

### Ground-Production-Bundle

```text
Build commit / getesteter Source-Stand:
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

## 5. DCS-Runtime-Ergebnis

DCS:

```text
2.9.28.26385 MT
```

Runtime-Logs:

```text
dcs(20260821-215616).log
SHA-256:
8ECFD3CACC58FF0421E55280D7CE63EFA2A6C1CDA0A09095F7A69E588290DE71

debrief(20260821-215616).log
SHA-256:
B773DDB09401B7E58F4393EEEEDCE858EB98F769E1BE2DE9AB12392B10583A9E
```

Der DCS-Log bestätigt:

```text
initialAmmo = 300
postFireAmmo = 296
support type = CHAP_M1083
GROUND_AMMO_PACKAGE before = 52
after = 51
finalAmmo = 302
PASS M1083_REARM_CONFIRMED=true
```

Praktisch beobachtet:

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

Die Acceptance-Zielzone lag absichtlich auf einem BLUE OP. Im Debrief erscheinen deshalb zwei BLUE-Infanterieverluste:

```text
Soldier M249
Soldier M4
```

Diese Verluste sind keine Testanomalie. Der daraus ableitbare spätere Scope bleibt getrennt:

```text
OP personnel loss
-> responsible COP/FOB/node strength deficit
-> reinforcement/resupply demand
-> physical replacement movement
-> restored OP strength
```

Dieser Verstärkungs-Lifecycle wurde nicht getestet.

## 6. Geschlossene Acceptance-Provenienz

Der funktionale Runtime-PASS ist inzwischen vollständig an die tatsächlich ausgeführte Mission gebunden.

```text
Executed mission path:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v15.miz

MIZ SHA-256:
A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4

internal mission SHA-256:
2378F38E9B07365D25ACE38E45A23D87E2CC76F185A062FB2A46CA8EE31C1A53
```

Read-only Embedded-Resource-Recheck der tatsächlich ausgeführten MIZ:

```text
Moose.lua
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
MATCH

OMW_AirOps_Warehouse_Base.lua
FC0F8F20909DD57E5DEE3AF6414FB56B35D8671D726471DEDB6D6984E590801B
MATCH

OMW_Ground_Base.lua
6DBDE7AA75E34FA6C7A42A7C97B3E407C069806666C60E8D27F8616D647383EE
MATCH

OMW_Ground_Ammo_Rearm_Acceptance_1.lua
94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
MATCH
```

Status für exakt diesen Branch-/Source-/Bundle-/MIZ-/DCS-/MOOSE-Scope:

```text
FUNCTIONAL DCS RESULT:
PASS

ACCEPTED_TECHNICAL_BASELINE:
YES — EXACT DOCUMENTED SCOPE ONLY

MERGED_TO_MAIN:
false
```

Die technische Acceptance erzeugt keine repository-weite normative Wirkung und validiert keine nicht getesteten Folgepfade.

## 7. TODO-Status

### TODO 1 – Acceptance-Provenienz schließen

```text
STATUS: COMPLETE
```

Abgeschlossen:

```text
- realer SHA-256 der ausgeführten OMW_Template_v15.miz
- internal mission SHA-256
- embedded Moose.lua recheck
- embedded OMW_AirOps_Warehouse_Base.lua recheck
- embedded OMW_Ground_Base.lua recheck
- embedded OMW_Ground_Ammo_Rearm_Acceptance_1.lua recheck
- alle vier Runtime-Artefakte MATCH
```

### TODO 2 – MOOSE-Dokumentation auf den realen PASS anheben

```text
STATUS: COMPLETE ON WORKING BRANCH
```

Aktualisiert:

```text
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
docs/moose/MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md
mission/tests/ground-ammo-rearm-integration/README.md
```

Dokumentierte Grenze:

```text
ARTY = VALIDATED_FOR_DOCUMENTED_SCOPE for exact Bostick acceptance
USERFLAG = Ground readiness scope added
CHAP_M1083 = validated only as operational rearm support in exact Bostick L118/ARTY RearmingGroup scope
AMMOTRUCK = remains SOURCE_REVIEWED
```

### TODO 3 – BostickAmmoRearmService Lifecycle-Hygiene korrigieren

**Ziel:** Den getesteten Vertical Slice vor Produktionsfreigabe gegen bekannte Source-Risiken absichern.

Noch zu tun:

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

Aktueller Stand: CampaignState `Consume(transactionId)` ist idempotent und bucht strategisch nur einmal ab. Für einen Neustart zwischen `CONSUMED` und dauerhaft bestätigter physischer Completion existiert noch kein belastbarer Produktionsvertrag.

**Owner-Entscheidung erforderlich. Nicht stillschweigend implementieren.**

Zu bewertende Richtungen:

```text
A. dauerhafte Rearm-Completion-/Settlement-Metadaten
B. Restart-Compensation für CONSUMED aber nicht dauerhaft abgeschlossene lokale Rearms,
   analog zum bestehenden Ground-Commitment-Reconciliation-Prinzip,
   danach neue Transaction für erneuten Rearm
C. Consume erst bei OnAfterRearmed
   -> derzeit nicht bevorzugt, weil die strategische Ressource während des physischen Rearm-Vorgangs ungebunden bliebe
```

### TODO 5 – OP-Verluste und automatische Verstärkung als getrennten Scope definieren

Noch zu entscheiden/klären:

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

Nach Source-Hygiene und Restart-Entscheidung:

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

Der nächste Arbeitsschritt ist jetzt **TODO 3 – BostickAmmoRearmService Lifecycle-Hygiene**.

Vor Source-Änderungen werden die betroffenen Dateien sowie die tatsächlich verwendeten MOOSE-FSM-Rückgabesemantiken erneut gegen den gepinnten Source geprüft. Es wird keine neue Native-DCS- oder MOOSE-Parallelimplementierung eingeführt.

Die Restart-/Replay-Semantik aus TODO 4 bleibt ausdrücklich owner-gated und wird in TODO 3 nicht stillschweigend vorweggenommen.
