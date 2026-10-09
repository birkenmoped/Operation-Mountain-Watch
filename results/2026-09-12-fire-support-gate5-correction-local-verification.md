# Gate 5 correction – owner-local verification and tooling correction

Status: LOCAL_VERIFICATION_EVIDENCE / NOT_DCS_VALIDATED

## Zweck

Dieses Ergebnisdokument hält die reale lokale Verifikation des korrigierten Gate-5-Vertrags, die lokale Tooling-Grenze sowie die anschließende erfolgreiche Erzeugung des Gate-5-Six-Site-Guard-Runtime-Bundles fest.

## Reale lokale Repository-Verifikation

Branch:

```text
agent/fire-support-strategic-resupply-base-gate0
```

Der Projektinhaber führte zunächst einen Fast-Forward-Pull aus:

```text
a4c46074f781c3ee3a2645e30c6264ed97d0367e
->
d5a7ce1cdfb9c8c5e7e94abda159aea5455a82f9
```

Lokal bestätigter HEAD dieses Korrekturstands:

```text
d5a7ce1cdfb9c8c5e7e94abda159aea5455a82f9
```

Der verifizierte Korrektur-Changeset bestand aus genau drei Dateien:

```text
M docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-5-SIX-SITE-ME-CONTRACT.md
M scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua
M tests/mission-demand/test_fire_support_strategic_resupply_gate2.lua
```

## Lokaler Lua-Test – nicht ausführbar

Der angeforderte Befehl

```text
lua tests\mission-demand\run.lua
```

konnte lokal nicht ausgeführt werden. PowerShell meldete:

```text
Die Benennung "lua" wurde nicht als Name eines Cmdlet, einer Funktion,
einer Skriptdatei oder eines ausführbaren Programms erkannt.
```

Daraus folgt ausdrücklich:

```text
LOCAL LUA TEST: NOT RUN
REASON: LUA INTERPRETER NOT AVAILABLE ON OWNER WORKSTATION
THIS IS NOT A TEST FAILURE OF THE GATE-5 CHANGE
```

Zusätzlich zeigte die Ausgabe, dass die anschließend verwendete Prüfung von `$LASTEXITCODE` diesen Fall nicht zuverlässig erkennt: `CommandNotFoundException` entsteht in PowerShell, bevor ein nativer `lua`-Prozess gestartet wird; deshalb ist `$LASTEXITCODE` für genau diesen Fehlerpfad kein belastbarer Nachweis.

Arbeitsregel für Folgeaufträge:

```text
Vor lokalen Testanweisungen muss die bekannte lokale Tooling-Baseline berücksichtigt werden.
Auf diesem Owner-Arbeitsplatz keine direkten lua-/luac-Kommandos verlangen,
solange der Projektinhaber nicht ausdrücklich eine geänderte Tooling-Baseline bestätigt.
Verfügbare versionierte PowerShell-Builder verwenden; Lua-Syntax-/Unit-Tests über die vorhandene CI ausführen,
wenn lokal kein Interpreter vorhanden ist.
Falls ein externer Befehl künftig zwingend lokal benötigt wird, vorher dessen Verfügbarkeit explizit prüfen;
CommandNotFound darf nicht nur über $LASTEXITCODE bewertet werden.
```

## Reale lokale Hashes des korrigierten Stands

```text
scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua
SHA256: B8B113CA5AAE1B23F1A2AF90D4EB7CFCBAAEAE3DE46635339434EF75D7CAB4D7

tests/mission-demand/test_fire_support_strategic_resupply_gate2.lua
SHA256: 860B977E0CA70AC038A5C3D9936A27914158FE8676B9FF4A3DDCEC5242C09942

docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-5-SIX-SITE-ME-CONTRACT.md
SHA256: 963C317EC37C7664C59A462984F1AA8CA6D564712A055FA34866B7AB57D75ECE
```

## CI-Evidenz auf dem korrigierten Head

Für exakt

```text
d5a7ce1cdfb9c8c5e7e94abda159aea5455a82f9
```

waren die automatischen Repository-Prüfungen erfolgreich:

```text
Documentation validation
run 34701334906
PASS

MissionDemand validation
run 34701334907
PASS
```

## Gate-5 Six-Site Guard Runtime – erster lokaler Buildversuch

Der Projektinhaber übernahm den funktionalen Gate-5-Runtime-Stand per Fast-Forward auf:

```text
9ae057f61b02125b86bd72e90f153c047eac2883
```

Der direkte Aufruf des versionierten `.ps1`-Builders wurde von der lokalen Windows-PowerShell-ExecutionPolicy blockiert:

```text
PSSecurityException / UnauthorizedAccess
Die Ausführung von Skripts auf diesem System ist deaktiviert.
```

Der Builder wurde in diesem Versuch nicht gestartet. Das fehlende Bundle war ein Folgeeffekt und kein Lua-/MOOSE-/DCS-Fehler.

Reale lokale Hashes dieses Stands:

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/src/01-six-site-guard-runtime-acceptance.lua
SHA256: 3699B9111ED15C0C93DE4895545CE3276632927E3DCDB1117CEACC7141B62821

tools/build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1
SHA256: 993FC2190A3C659AA608A0A0220D09E7198F2AF0F17F5785795A9B1D04E3CBB9
```

### Tooling-Korrektur

Die lokale ExecutionPolicy wurde nicht dauerhaft verändert. Der Builder wird auf diesem Arbeitsplatz in einem separaten Windows-PowerShell-Prozess mit prozessbezogenem `-ExecutionPolicy Bypass` gestartet.

Verbindliche Arbeitsregel für diesen lokalen Kontext:

```text
- keine dauerhafte Änderung der Windows-PowerShell-ExecutionPolicy;
- versionierte .ps1-Builder bei blockierter direkter Ausführung über
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File <builder> starten;
- Exitcode des gestarteten PowerShell-Prozesses prüfen;
- Bundle-Existenz und SHA-256 erst nach erfolgreichem Builder-Exit prüfen;
- keine Folge-Hashprüfung durchführen, wenn der Builder vorher nicht gestartet bzw. fehlgeschlagen ist.
```

## Gate-5 Six-Site Guard Runtime – erfolgreicher lokaler Build

Der Projektinhaber übernahm anschließend per Fast-Forward den dokumentierten Tooling-Korrekturstand:

```text
9ae057f61b02125b86bd72e90f153c047eac2883
->
4215e4786a6c6b316d8096e48f9026e3f9ac8f93
```

Lokal bestätigter HEAD:

```text
4215e4786a6c6b316d8096e48f9026e3f9ac8f93
```

Der versionierte Builder wurde daraufhin mit einem separaten PowerShell-Prozess und prozessbezogenem ExecutionPolicy-Bypass ausgeführt. Der Build war erfolgreich.

Reale lokale Builder-Ausgabe:

```text
BuilderVersion: FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-1
GitCommit: 4215e4786a6c6b316d8096e48f9026e3f9ac8f93
TestId: FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-1
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Encoding: UTF-8 without BOM
Bundle SHA-256: F4C0BADF01557A38485BB3A5677EF723CA435729173CE8F23401FA90CF6F0518
MIZ mutation: false
```

Die anschließende reale lokale Hashprüfung bestätigte:

```text
Generated bundle:
F4C0BADF01557A38485BB3A5677EF723CA435729173CE8F23401FA90CF6F0518

Runtime source:
3699B9111ED15C0C93DE4895545CE3276632927E3DCDB1117CEACC7141B62821

Builder:
993FC2190A3C659AA608A0A0220D09E7198F2AF0F17F5785795A9B1D04E3CBB9
```

Lokaler Worktree nach dem erfolgreichen Build:

```text
?? mission/tests/fire-support-strategic-resupply-gate4-stage3-regression/dist/
?? mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/dist/
?? mission/tests/stage3-honaker-wright-full-response/dist/
```

Das zusätzliche Gate-5-`dist/`-Verzeichnis ist der erwartete untracked Output des erfolgreichen Builds. Es wurden keine tracked lokalen Änderungen gemeldet.

## Acceptance-Grenze

Diese Evidenz bestätigt jetzt:

```text
- korrekten lokalen Fast-Forward auf den korrigierten Gate-5-Vertrag;
- reale lokale Hashes des korrigierten Vertragsstands;
- CI-PASS für Dokumentation und MissionDemand auf dem korrigierten Head;
- bekannte lokale Tooling-Grenzen korrekt dokumentiert;
- erfolgreichen lokalen Pull auf den Gate-5-Runtime-Stand;
- erfolgreiche lokale Ausführung des versionierten Gate-5-Builders;
- BuilderVersion und GitCommit des erzeugten Bundles;
- gepinnten MOOSE-Commit und Moose.lua-Hash im Build;
- UTF-8 ohne BOM;
- Bundle SHA-256 F4C0BADF01557A38485BB3A5677EF723CA435729173CE8F23401FA90CF6F0518;
- keine MIZ-Mutation;
- unveränderten tracked lokalen Worktree.
```

Sie bestätigt weiterhin noch nicht:

```text
- generische Six-Site-Guard-Runtime in DCS;
- tatsächliche Materialisierung aller sechs Guards;
- tatsächliche Bewegung auf allen sechs Guard-PATHLINEs;
- Patrol-/Pathfinding-Verhalten aller sechs Guard-Routen;
- Runtime-Alarm-/Response-Verhalten aller sechs Sites;
- generische Six-Site-DCS-Acceptance.
```

Der nächste funktionale Schritt ist damit kein weiterer Build-Readback, sondern der echte DCS-Lauf mit exakt dem oben gehashten Bundle und dem dazugehörigen dokumentierten Missionsstand.
