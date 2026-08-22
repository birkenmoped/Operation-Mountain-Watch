# Ground Ammo Rearm Integration – aktueller Stand und TODO

Stand: 22.08.2026

## 1. Arbeitszweig, Autorität und aktueller Repository-Stand

```text
Repository: birkenmoped/Operation-Mountain-Watch
main: f61f7ae9d1c98fc99ac76e8c0e9b196be9784ac4
Arbeitsbranch: agent/ground-ammo-rearm-integration
Branch-Stand vor dieser Statusaktualisierung:
5c5fa0ba7653ef51144ca0223dd7cad0ad36f0a7

Draft PR:
#112 Integrate Ground ammo rearm lifecycle
Status: OPEN / DRAFT / NOT MERGED

Projektphase:
COMPLETE_FOUNDATION_BUILD_PHASE
```

Dieser Branch ist ein Integrations-/Arbeitsstand. Projektweit verbindliche normative Wirkung entsteht erst nach dem Governance-konformen Integrationsweg nach `main`.

Vor relevanter Weiterarbeit mindestens prüfen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

Für diesen Scope zusätzlich insbesondere:

```text
mission/tests/ground-ammo-rearm-integration/README.md
mission/tests/ground-ammo-rearm-integration/ACCEPTANCE-2.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
docs/moose/FIXED-FIRE-SUPPORT-REARM.md
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/ground/OMW_GroundSupportMaterializer.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua
scripts/campaign/OMW_CampaignState.lua
```

## 2. Gesamtziel dieses Arbeitsblocks

Ziel ist ein produktionsfähiger, MOOSE-first lokaler Munitionierungs-Lifecycle für standortgebundene BLUE-Feuerunterstützung, ohne eine zweite Ressourcenautorität zu erzeugen.

```text
fixed fire-support consumer
-> Munition wird durch DCS real verbraucht
-> lokaler Ammo-Support wird über MOOSE WAREHOUSE/BRIGADE/PLATOON materialisiert
-> CampaignState bucht genau ein GROUND_AMMO_PACKAGE
-> ARTY:SetRearmingGroup(...)
-> ARTY:Rearm()
-> DCS führt den tatsächlichen Ground-Rearm nach seinen eigenen Munitions-/Ladesystemregeln aus
-> MOOSE beobachtet FullAmmo / Rearmed
-> Support kehrt physisch zurück
-> WAREHOUSE:AddAsset(...)
-> physische Support-Gruppe verschwindet wieder in den Warehouse-Bestand
```

Strategische Hoheit bleibt ausschließlich beim gemeinsamen `CampaignState`. DCS-/MOOSE-Munitionsstände sind operative Telemetrie und keine zweite strategische Ressourcenquelle.

## 3. Verbindlicher MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendeter MOOSE-first-Pfad:

```text
WAREHOUSE / BRIGADE / PLATOON
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingDistance(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:Rearm()
ARTY Rearm/Rearmed FSM
SCHEDULER für begrenzte Return-Bestätigung
WAREHOUSE:AddAsset(...)
```

## 4. Bereits vorhandene Ground-Foundation – nicht mehr offen

Die strategische Ground-Foundation ist bereits auf `main` integriert. Dazu gehören sechs Ground-Nodes sowie der getestete Ressourcen-, Mission-, Settlement-, Return-/Loss- und Restart-Reconciliation-Pfad.

```text
GROUND_NODE_JALALABAD
GROUND_NODE_FORTRESS
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_HONAKER
GROUND_NODE_BOSTICK
```

Der bestehende Ground-Settlement-Vertrag bleibt unverändert:

```text
confirmed return, including damaged survivor
-> immediate one-time availability credit

confirmed loss
-> permanent loss

open nonterminal Ground commitment at server stop/crash
-> one-time strategic recredit on next startup
-> no physical continuation or respawn
```

Die lokale Fire-Support-Rearm-Integration ergänzt diese Foundation; sie ersetzt sie nicht.

## 5. TM01M – vollständig abgeschlossen

TM01M ist **kein offener Entwicklungs- oder Reconciliation-Punkt mehr**.

Der bereits abgeschlossene Reconciliation-Stand lautet:

```text
TM01M
= HISTORICAL_TEST_FIXTURE
= technische Evidenz für MOOSE-native physische Convoy-Ausführung

bestätigte Evidenz:
- road-aligned Spawn
- PATHLINE-basierte MSR-Führung
- MOOSE GROUP:Route(...)
- parallele physische Convoys
```

TM01M war nie zuständig für:

```text
CampaignState-Ressourcenhoheit
Warehouse Debit/Credit
Settlement
Loss-Reconciliation
Restart-Reconciliation
```

Es ist kein produktiver TM01M-Nachfolger erforderlich.

Der frühere Missionseditor-Punkt ist ebenfalls erledigt:

```text
LOAD_TM01M
-> aus der aktuellen owner-geführten Mission entfernt
-> NICHT mehr offen
```

Die aktuell ausgeführten Testläufe verwenden `OMW_Template_v16.miz`. Die ältere Aussage in `docs/38-mission-editor-master-worklist.md` auf `main`, wonach `LOAD_TM01M` noch zu reconciliieren sei, ist damit veraltet und muss bei der nächsten Dokumentationsreconciliation korrigiert werden.

## 6. Ground-Rearm – bestätigte technische Baselines

### 6.1 Bostick Acceptance 1

Der ursprüngliche Bostick-L118-Vertical-Slice ist als exakter technischer Baseline-PASS geschlossen:

```text
Source/Build commit:
213119ca03a6aeae529d4291b4bbe174ac0995c2

BuilderVersion/TestId:
GROUND-AMMO-REARM-ACCEPTANCE-1

Bundle SHA-256:
94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7

Executed MIZ:
OMW_Template_v15.miz

MIZ SHA-256:
A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4

internal mission SHA-256:
2378F38E9B07365D25ACE38E45A23D87E2CC76F185A062FB2A46CA8EE31C1A53
```

Runtime:

```text
initialAmmo = 300
postFireAmmo = 296
support = CHAP_M1083
GROUND_AMMO_PACKAGE = 52 -> 51
finalAmmo = 302
PASS M1083_REARM_CONFIRMED=true
```

Damit sind für den exakten dokumentierten Bostick-Scope bestätigt:

```text
Ground readiness gate
L118 firing and ammo reduction
M1083 WAREHOUSE self-request/materialization
CampaignState debit
ARTY Rearm/Rearmed
DCS ammunition restoration
```

### 6.2 Generalisierter Fixed-Fire-Support-Pfad

Der Bostick-spezifische Vertical Slice wurde danach auf einen generalisierten lokalen Fixed-Fire-Support-Pfad erweitert:

```text
BOSTICK   -> L118
WRIGHT    -> L118
FORTRESS  -> L118
HONAKER   -> 2B11
```

Wesentliche heute bestätigte Architektur:

```text
WAREHOUSE:SetSpawnZone(local RESUPPLY zone)
-> local materialization
-> CampaignState GROUND_AMMO_PACKAGE debit
-> ARTY RearmingGroup
-> DCS rearm
-> ARTY Rearmed
-> ARTY-owned return
-> bounded return watcher
-> WAREHOUSE:AddAsset(group)
-> physical support removal / asset back in stock
```

Bostick, Wright und Fortress haben diesen vollständigen Lifecycle in DCS wiederholt erfolgreich durchlaufen.

## 7. Reale MOOSE-Einschränkung – muss bestehen bleiben

Während Acceptance 2 wurde ein **echter, unabhängiger Defekt im gepinnten MOOSE-Stand** isoliert:

```text
WAREHOUSE:SetValidateAndRepositionGroundUnits(...)
-> UTILS.ValidateAndRepositionGroundUnits(...)
-> UTILS.GetCenterPoint(units)
-> attempt to call field 'GetCenterPoint' (a nil value)
```

Für die tatsächlich gepinnte `Moose.lua` wurde keine passende Definition von `UTILS.GetCenterPoint` gefunden. Dieser Befund wurde real in DCS reproduziert.

Daraus folgt weiterhin verbindlich für diesen OMW-Scope:

```text
KEEP:
WAREHOUSE:SetSpawnZone(...)
owner-kontrollierte freie RESUPPLY-Zonen

DO NOT USE:
WAREHOUSE:SetValidateAndRepositionGroundUnits(...)

NO:
MOOSE patch/override
native DCS spawn/reposition fallback
```

Diese Korrektur hat **nichts** mit der später falsch interpretierten 2B11-Rearm-Beobachtung zu tun und darf beim Cleanup nicht zurückgebaut werden.

## 8. 2B11 / DCS-Rearm – korrigierte Interpretation

Die früheren Honaker-Läufe wurden zunächst fälschlich als 2B11-/Support-Problem interpretiert, weil nach einem Teilverbrauch von 40 auf 36 Schuss keine sofortige Wiederauffüllung beobachtet wurde.

Diagnose:

```text
2B11 initialAmmo = 40
nach 4 Schuss = 36
Support vorhanden
-> keine sofortige Auffüllung
```

Ein M939 wurde anschließend ausschließlich als diagnostische Variable eingesetzt. Auch mit M939 führte der Teilverbrauch 40 -> 36 nicht zu einer unmittelbaren Auffüllung. Damit war ein M1083-spezifisches Problem nicht belegt.

Der entscheidende Diagnose-Lauf ließ den 2B11-Bestand vollständig verbrauchen und forderte erst danach den Support an:

```text
40 -> 0
HONAKER_AMMO_DEPLETED
HONAKER_REARM_REQUEST_AFTER_EMPTY
0 -> 40
SITE_REARMED
SITE_SUPPORT_RETURNED
SITE_PASS
Aggregate PASS
```

Aktueller Diagnose-Build:

```text
Source commit:
5c5fa0ba7653ef51144ca0223dd7cad0ad36f0a7

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-7

Bundle SHA-256:
1655E4F2F5D4AB69BF4BDAFBD82CE3D8FF0049CD557245336B71C275F21BED3D

Diagnostic support template for Honaker:
TPL_BLUE_GND_SUP_M939
```

Letzte Runtime-Artefakte:

```text
Mission path:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v16.miz

DCS:
2.9.28.26385 MT

dcs(20260822-115128).log
SHA-256:
B3C218B81D5A3C386213E4721F1F1AF12C53DF840C8BB758FE7147E6BAF5FD10

debrief(20260822-115128).log
SHA-256:
0014C8FE4A4E3BD7DE3D3AF0BCB3DC30C30E786470F1EDA951EBD582F1A48FAE
```

Korrekte technische Schlussfolgerung:

```text
- kein 2B11-Rearm-Defekt nachgewiesen
- kein M1083-spezifischer Defekt nachgewiesen
- DCS bestimmt den tatsächlichen Zeitpunkt der Auffüllung abhängig vom internen Munitions-/Ladesystem
- bereitgestellter Ammo-Support bedeutet nicht automatisch sofortige Teilauffüllung
- MOOSE wartet korrekt auf die von DCS beobachtbare FullAmmo-Bedingung
```

Für OMW ist daher **keine 2B11-Sonder-Rearm-Implementierung** erforderlich.

Produktionsrichtung:

```text
HONAKER -> wieder TPL_BLUE_GND_SUP_M1083
```

Der M939-Zweig und die künstliche vollständige Entleerung waren Diagnostik und sind keine Produktionsarchitektur.

## 9. Aktualisierte ursprüngliche TODO-Liste

### TODO 1 – Acceptance-Provenienz schließen

```text
STATUS: COMPLETE
```

Der ursprüngliche Bostick-PASS ist mit Source-, Bundle-, MIZ-, internal-mission-, DCS- und MOOSE-Provenienz geschlossen.

### TODO 2 – MOOSE-Dokumentation auf den realen PASS anheben

```text
STATUS:
COMPLETE für Acceptance 1
UPDATE REQUIRED für die inzwischen hinzugekommenen Acceptance-2-Erkenntnisse
```

Noch nachzuführen sind insbesondere:

```text
- realer SetValidateAndRepositionGroundUnits/GetCenterPoint-Defekt
- bestätigter SetSpawnZone-Pfad
- generalisierter Fixed-Fire-Support-Lifecycle
- Support Return-to-stock
- korrigierte DCS-Rearm-Semantik
- 2B11 40 -> 0 -> 40 Diagnoseergebnis
- keine behauptete 2B11-/M1083-Inkompatibilität
```

### TODO 3 – BostickAmmoRearmService Lifecycle-Hygiene

```text
STATUS: SUBSTANTIALLY COMPLETE / FINAL REVIEW PENDING
```

Auf dem Arbeitsbranch ist der zuvor identifizierte synchrone Materialisierungsfall inzwischen im Source berücksichtigt: Nach `support:Request()` wird geprüft, ob der Materialisierungs-Callback synchron bereits einen echten Rearm-Kontext erzeugt hat, bevor ein `WAITING_FOR_SUPPORT`-Placeholder geschrieben wird.

Zusätzlich existieren inzwischen Ground-Contract-Tests für:

```text
test_bostick_ammo_rearm_service.lua
test_bostick_ammo_support.lua
test_fixed_fire_support_ammo_rearm_service.lua
test_fixed_fire_support_ammo_support.lua
test_ground_ammo_rearm_adapter.lua
test_ground_ammo_rearm_prestarted.lua
```

Vor Branch-Abschluss bleibt eine vollständige Diff-/Contract-Prüfung erforderlich. Auf der lokalen Owner-Maschine steht keine Lua-Runtime zur Verfügung; daraus darf kein lokaler Lua-Test-PASS konstruiert werden.

### TODO 4 – Restart/Replay-Semantik für LOCAL REARM entscheiden

```text
STATUS: OPEN / OWNER DECISION REQUIRED
```

Der allgemeine Ground-Commitment-Restart-Pfad ist bereits akzeptiert. Für eine **lokale Rearm-Transaktion** bleibt jedoch die spezielle Frage offen, was bei Serverende zwischen strategischem `CONSUMED` und dauerhaft bestätigter physischer Rearm-Completion geschieht.

Zu entscheiden bleibt:

```text
A. dauerhafte Rearm-Completion-/Settlement-Metadaten

B. Restart-Compensation für CONSUMED aber nicht dauerhaft abgeschlossene lokale Rearms,
   analog zum bestehenden Ground-Commitment-Reconciliation-Prinzip,
   danach neue Transaction für einen erneuten Rearm

C. Consume erst bei OnAfterRearmed
   -> bisher nicht bevorzugt, weil die Ressource während der physischen Rearm-Phase ungebunden bliebe
```

Diese Entscheidung darf nicht stillschweigend getroffen werden.

### TODO 5 – OP-Verluste und automatische Verstärkung

```text
STATUS: OPEN / SEPARATER FOLGESCOPE
```

Dieser Punkt entstand aus dem beobachteten OP-Personalverlust im frühen Acceptance-Lauf und gehört **nicht** in den Rearm-Adapter.

Offen bleiben:

```text
OP -> verantwortliches COP/FOB -> CampaignState node
Soll-/Mindeststärke je OP
Personnel-/Vehicle-Demand
MissionDemand-Erzeugung
physische MOOSE-Verstärkung
Verlust während des Verstärkungstransports
```

Dieser Scope gehört in die kommende Ground-/MissionDemand-Orchestrierung.

### TODO 6 – Regression und Produktionsintegration

```text
STATUS: IN FINALIZATION
```

Bereits erreicht:

```text
[x] Bostick Acceptance-1 provenance closed
[x] generalisierter Vier-Consumer-Harness
[x] Bostick/Wright/Fortress DCS rearm PASS
[x] CampaignState debit confirmed
[x] local WAREHOUSE support materialization
[x] SetSpawnZone-only fixed-fire-support spawn path
[x] broken pinned-MOOSE reposition path excluded
[x] ARTY-owned support return
[x] WAREHOUSE AddAsset return-to-stock
[x] physical support cleanup
[x] Honaker 2B11 can rearm after DCS reaches the appropriate depleted state
[x] latest combined diagnostic run reaches aggregate PASS
```

Noch erforderlich:

```text
[ ] diagnostischen M939-Zweig zurückbauen
[ ] Honaker wieder auf TPL_BLUE_GND_SUP_M1083 setzen
[ ] künstliche Honaker-40-round-empty-Diagnostik aus dem normalen Produktionsvertrag entfernen
[ ] diagnostische Erkenntnis in der Acceptance-Dokumentation erhalten
[ ] Acceptance-2-Dokument auf den realen Endstand bringen
[ ] MOOSE-Projektdokumentation synchronisieren
[ ] CURRENT-STATUS/TODO synchron halten
[ ] PR #112 Beschreibung auf den realen Stand bringen
[ ] Restart/Replay-Entscheidung für LOCAL REARM treffen
[ ] vollständigen Branch-Diff und verfügbare Contract-/Builder-Gates prüfen
[ ] erst danach Owner-Entscheidung zu Ready/Merge
```

Ein weiterer isolierter DCS-Lauf nur zur Wiederholung bereits bestätigter Mechanik ist nicht vorgesehen. Neue DCS-Läufe sollen nur bei tatsächlich neuer Laufzeitfunktion beziehungsweise als gebündelte Integrations-/Sammelmission erfolgen.

## 10. Was ausdrücklich NICHT mehr auf der TODO-Liste steht

```text
NICHT OFFEN:
- TM01M gegen OMW_Ground_Base reconciliieren
- produktiven TM01M-Nachfolger bauen
- LOAD_TM01M aus der aktuellen MIZ entfernen
- zweiten Ground-CampaignState einführen
- eigenen strategischen Warehouse-Zustand für Ground schaffen
- 2B11 durch andere Waffe ersetzen
- M109-Konvertierung
- 2B11-Rearm per Custom-Lua nachbauen
- MOOSE GetCenterPoint patchen/überschreiben
- weitere M939-vs-M1083-Kompatibilitätsserie durchführen
```

## 11. Dokumentationsschuld auf main

`main` enthält noch ältere Texte, die den inzwischen abgeschlossenen TM01M-Stand nicht abbilden. Insbesondere sind zu reconciliieren:

```text
docs/38-mission-editor-master-worklist.md
- nennt LOAD_TM01M noch als Startup-Schritt
- bezeichnet TM01M-Reconciliation noch als offen
- referenziert noch die ältere v14-Missionsbaseline

docs/40-moose-module-adoption-plan-for-tm01-tm02.md
- enthält auf main noch nicht den abgeschlossenen TM01M-Reconciliation-Stand
```

Die bereits dokumentierte richtige Folgerichtung auf `main` bleibt dagegen bestehen:

```text
MissionDemand / ATO / COMMANDER orchestration
between existing AirOps, AAR and Ground foundations
```

## 12. Nächster großer Projektblock nach Abschluss von PR #112

Nach dem Rearm-Cleanup und der offenen Restart/Replay-Entscheidung ist **nicht TM01M** der nächste Entwicklungsblock.

Der nächste große Integrationsfokus ist die Orchestrierung der bereits vorhandenen Foundations:

```text
MissionDemand
   |
   +-- Ressourcen-/Verfügbarkeitsprüfung über CampaignState
   |
   +-- operative Priorisierung / ATO bzw. Ground-tasking equivalent
   |
   +-- COMMANDER/CHIEF-orchestrierte MOOSE-Ausführung
   |
   +-- AirOps
   +-- AAR
   `-- Ground

physical mission
-> result / loss / return
-> settlement
-> new CampaignState
```

Dazu gehören als Folgefragen unter anderem:

```text
- MissionDemand-Klassen und Priorisierung
- Air ATO / Ground-order tasking
- COMMANDER-/CHIEF-Grenzen
- AAR demand integration
- QRF / OP reinforcement demand
- Ground convoy / infantry / OPSTRANSPORT where appropriate
- Player-first / bounded AI fallback in persistent-server operation
```

Die parallele Draft-Dokumentation in PR #113 zur 24/7-Kampagnenautonomie muss vor konkreter Orchestrierungsimplementierung gegen den dann aktuellen `main`-Stand reconciliiert werden.

## 13. Arbeitsreihenfolge ab jetzt

```text
1. Ground-Rearm-Diagnosecode bereinigen
   - M939 diagnostic entfernen
   - Honaker zurück auf M1083
   - künstliche Empty-Mag-Diagnostik aus Production-Vertrag entfernen
   - echten SetSpawnZone/GetCenterPoint-Fix beibehalten

2. Acceptance-/MOOSE-Dokumentation auf realen Teststand bringen

3. LOCAL-REARM Restart/Replay-Semantik durch Owner entscheiden

4. Branch-Diff / Contract-Gates / Builder prüfen

5. PR #112 finalisieren
   - weiterhin Draft bis ausdrückliche Owner-Freigabe

6. main-Dokumentationsschuld zu TM01M/current MIZ korrigieren

7. MissionDemand / ATO / COMMANDER Orchestration als nächsten großen Integrationsblock beginnen
```

## 14. Test- und Build-Regel

```text
Source Lua
-> offizieller PowerShell-Builder
-> generiertes dist-Bundle
-> Mission Editor DO SCRIPT FILE
-> gespeicherte MIZ
-> MIZ/embedded hash check
-> DCS runtime
-> dcs.log + debrief.log
-> Ergebnisdokumentation
```

Generierte `dist/`-Dateien nicht manuell editieren.

Keine lokalen Lua-/Python-Prüfungen auf der Owner-Entwicklungsmaschine voraussetzen, solange dort keine entsprechende Runtime vorhanden ist.

Weitere DCS-Läufe nur für wirklich neue Runtime-Aussagen oder gebündelte Integrations-/Collection-Acceptance; keine unnötige Wiederholung bereits isolierter und verstandener Mechanismen.

## 15. Merge-Grenze

PR #112 bleibt bis zur ausdrücklichen Projektinhaberfreigabe:

```text
DRAFT
NOT READY
NOT MERGED
```

Vor Ready/Merge mindestens:

```text
- diagnostischer Rückbau abgeschlossen
- Restart/Replay-Entscheidung dokumentiert
- Acceptance-2 auf realen Endstand gebracht
- MOOSE-Dokumentation synchronisiert
- vollständiger Diff geprüft
- verfügbare Builder-/Contract-Gates bestanden
- keine unbeabsichtigte .miz-Mutation
```
