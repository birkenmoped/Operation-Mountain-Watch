# Gate 5 correction – owner-local verification and tooling correction

Status: LOCAL_VERIFICATION_EVIDENCE / NOT_DCS_VALIDATED

## Zweck

Dieses Ergebnisdokument hält die reale lokale Verifikation des korrigierten Gate-5-Vertrags fest und dokumentiert zugleich einen weiteren vermeidbaren Fehler im Arbeitsablauf: Dem Projektinhaber wurde erneut ein lokaler `lua`-Test aufgetragen, obwohl auf diesem Windows-Arbeitsplatz kein Lua-Interpreter installiert beziehungsweise verfügbar ist.

Die fehlende lokale Lua-Runtime ist **kein Fehler der Gate-5-Änderung**. Der Test wurde lokal nicht ausgeführt. Die zugehörigen GitHub-Actions-Prüfungen auf exakt dem korrigierten Remote-Head waren dagegen erfolgreich.

## Reale lokale Repository-Verifikation

Branch:

```text
agent/fire-support-strategic-resupply-base-gate0
```

Der Projektinhaber führte einen Fast-Forward-Pull aus:

```text
a4c46074f781c3ee3a2645e30c6264ed97d0367e
->
d5a7ce1cdfb9c8c5e7e94abda159aea5455a82f9
```

Lokal bestätigter HEAD:

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

Zusätzlich zeigte die Ausgabe, dass die anschließend verwendete Prüfung von `$LASTEXITCODE` diesen Fall nicht zuverlässig erkennt: `CommandNotFoundException` entsteht in PowerShell, bevor ein nativer `lua`-Prozess gestartet wird; deshalb ist `$LASTEXITCODE` für genau diesen Fehlerpfad kein belastbarer Nachweis. Zukünftige lokale Anweisungen dürfen einen fehlenden Befehl nicht allein über `$LASTEXITCODE` absichern.

Arbeitsregel für Folgeaufträge:

```text
Vor lokalen Testanweisungen muss die bekannte lokale Tooling-Baseline berücksichtigt werden.
Auf diesem Owner-Arbeitsplatz keine direkten `lua`-/`luac`-Kommandos verlangen,
solange der Projektinhaber nicht ausdrücklich eine geänderte Tooling-Baseline bestätigt.
Verfügbare versionierte PowerShell-Builder verwenden; Lua-Syntax-/Unit-Tests über die vorhandene CI ausführen,
wenn lokal kein Interpreter vorhanden ist.
Falls ein externer Befehl künftig zwingend lokal benötigt wird, vorher dessen Verfügbarkeit explizit prüfen;
CommandNotFound darf nicht nur über `$LASTEXITCODE` bewertet werden.
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

## Lokaler Worktree

Nach der Verifikation enthielt `git status --short` ausschließlich die bereits bekannten generierten untracked Build-Verzeichnisse:

```text
?? mission/tests/fire-support-strategic-resupply-gate4-stage3-regression/dist/
?? mission/tests/stage3-honaker-wright-full-response/dist/
```

Keine tracked lokale Änderung wurde gemeldet.

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

Damit ist die korrigierte Registry-/Gate-2-Vertragsänderung durch CI geprüft, obwohl der direkte lokale Lua-Aufruf mangels Interpreter nicht möglich war.

## Gate-5 Six-Site Guard Runtime – erster lokaler Buildversuch

Der Projektinhaber übernahm den funktionalen Gate-5-Runtime-Stand per Fast-Forward auf:

```text
9ae057f61b02125b86bd72e90f153c047eac2883
```

Der Pull war erfolgreich. Anschließend wurde der versionierte Builder wie angegeben direkt aus der laufenden Windows-PowerShell aufgerufen:

```text
& ".\tools\build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1"
```

Der Builder wurde **nicht gestartet**, weil die lokale Windows-PowerShell-ExecutionPolicy die direkte Ausführung von `.ps1`-Dateien blockierte. Die reale Fehlermeldung lautete sinngemäß:

```text
PSSecurityException / UnauthorizedAccess
Die Ausführung von Skripts auf diesem System ist deaktiviert.
```

Folgerichtig wurde kein Gate-5-Bundle erzeugt. Die nachfolgenden Meldungen `bundle not found` und der fehlgeschlagene Bundle-Hash sind reine Folgefehler dieses nicht gestarteten Builders und **keine Lua-/DCS-/MOOSE-Fehler**.

Reale lokale Hashes auf diesem Head:

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/src/01-six-site-guard-runtime-acceptance.lua
SHA256: 3699B9111ED15C0C93DE4895545CE3276632927E3DCDB1117CEACC7141B62821

tools/build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1
SHA256: 993FC2190A3C659AA608A0A0220D09E7198F2AF0F17F5785795A9B1D04E3CBB9
```

Der Worktree enthielt weiterhin nur die zwei bereits bekannten untracked Build-Verzeichnisse:

```text
?? mission/tests/fire-support-strategic-resupply-gate4-stage3-regression/dist/
?? mission/tests/stage3-honaker-wright-full-response/dist/
```

### Tooling-Korrektur

Die lokale ExecutionPolicy wird **nicht dauerhaft verändert**. Für diesen Arbeitsplatz wird der versionierte Builder in einem separaten PowerShell-Prozess mit prozessbezogenem `-ExecutionPolicy Bypass` gestartet. Damit bleibt die Maschinen-/Benutzer-Policy unverändert und der Build-Auftrag ist reproduzierbar.

Verbindliche Arbeitsregel für diesen lokalen Kontext:

```text
- keine dauerhafte Änderung der Windows-PowerShell-ExecutionPolicy;
- versionierte .ps1-Builder bei blockierter direkter Ausführung über
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File <builder> starten;
- Exitcode des gestarteten PowerShell-Prozesses prüfen;
- Bundle-Existenz und SHA-256 erst nach erfolgreichem Builder-Exit prüfen;
- keine Folge-Hashprüfung durchführen, wenn der Builder vorher nicht gestartet bzw. fehlgeschlagen ist.
```

## Acceptance-Grenze

Diese Evidenz bestätigt:

```text
- korrekten lokalen Fast-Forward auf den korrigierten Gate-5-Head;
- exakten Drei-Dateien-Changeset des vorherigen Korrekturschritts;
- reale lokale Hashes dieser drei Dateien;
- unveränderten tracked Worktree;
- CI-PASS für Dokumentation und MissionDemand auf exakt dem korrigierten Head;
- lokale Lua-Test-Unverfügbarkeit als Tooling-Grenze, nicht als Code-Failure;
- `$LASTEXITCODE` allein ist kein belastbarer Guard für PowerShell CommandNotFound;
- erfolgreichen lokalen Pull auf den Gate-5-Runtime-Head `9ae057f6...`;
- Runtime-Source- und Builder-Hash auf diesem Head;
- direkten Builder-Aufruf durch lokale ExecutionPolicy blockiert;
- kein Gate-5-Bundle erzeugt und daher noch kein DCS-Test möglich.
```

Sie bestätigt noch nicht:

```text
- erfolgreichen lokalen Gate-5-Runtime-Build;
- generische Six-Site-Guard-Runtime in DCS;
- Patrol-/Pathfinding-Verhalten aller sechs Guard-Routen;
- Runtime-Alarm-/Response-Verhalten aller sechs Sites;
- generische Six-Site-DCS-Acceptance.
```

Der nächste funktionale Schritt bleibt der erfolgreiche Build des bereits versionierten Gate-5-Runtime-Harnesses und anschließend der DCS-Test mit dem real erzeugten Bundle.