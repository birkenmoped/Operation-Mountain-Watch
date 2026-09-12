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

## Acceptance-Grenze

Diese Evidenz bestätigt:

```text
- korrekten lokalen Fast-Forward auf den korrigierten Gate-5-Head;
- exakten Drei-Dateien-Changeset;
- reale lokale Hashes dieser drei Dateien;
- unveränderten tracked Worktree;
- CI-PASS für Dokumentation und MissionDemand auf exakt diesem Head;
- lokale Lua-Test-Unverfügbarkeit als Tooling-Grenze, nicht als Code-Failure;
- `$LASTEXITCODE` allein ist kein belastbarer Guard für PowerShell CommandNotFound.
```

Sie bestätigt noch nicht:

```text
- generische Six-Site-Guard-Runtime in DCS;
- Patrol-/Pathfinding-Verhalten aller sechs Guard-Routen;
- Runtime-Alarm-/Response-Verhalten aller sechs Sites;
- generische Six-Site-DCS-Acceptance.
```

Der nächste funktionale Schritt bleibt die generische MOOSE-first Runtime-Integration auf Basis der bereits vorhandenen Guard-PATHLINEs und der runtime-generierten `ZONE_RADIUS`/`OPSZONE`-Perimeter.