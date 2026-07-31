# Operation Mountain Watch – Testmissionen

Für alle Testmissionen gilt verbindlich:

```text
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Für alle taktischen Hubschrauber-Testmissionen gilt zusätzlich:

```text
docs/27-helicopter-formations-and-ah64-afghanistan-configuration.md
```

Damit sind insbesondere folgende Punkte projektweit vorgegeben:

- Combat Cruise beziehungsweise eine begründete taktische Alternative statt einer pauschalen Vee-Standardformation,
- missionsphasenabhängiger Formationswechsel,
- dokumentierte FCR-Darstellung beim AH-64D,
- IAFS/Robbie Tank mit 300 Schuss als AH-64D-COIN-Standardbaseline,
- MOOSE-First-Prüfung vor eigener Formations- oder Abstandslogik.

Lokale `expected/`-Dokumente dürfen diese Baseline konkretisieren, aber nicht stillschweigend ersetzen.

## Verbindliche Übergabe jedes neuen Teststands

Jede Implementierungs- oder Korrekturübergabe muss dem Benutzer einen unmittelbar ausführbaren lokalen Befehlsblock liefern. Er muss mindestens enthalten:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git pull --ff-only

git branch --show-current
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\<KONKRETER_TESTBUILDER>.ps1"
```

Zusätzlich sind immer konkret zu nennen:

```text
Branch
Erwarteter Commit
Builder-Version
Erzeugter Bundlepfad
Zu öffnende .miz
Im Trigger neu auszuwählende Lua-Datei
Erwarteter PASS-/FAIL-Abschlussmarker
Danach benötigte Logdateien
```

Ein allgemeiner Hinweis wie „Bundle neu bauen“, „Mission aktualisieren“ oder „Retest durchführen“ reicht nicht aus. Nach dem Build muss ausdrücklich angewiesen werden, das Bundle im bestehenden `DO SCRIPT FILE`-Trigger erneut auszuwählen und die `.miz` zu speichern, da ein externer Neubau die eingebettete Datei nicht automatisch aktualisiert.

## Kurzablauf

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
git switch <TESTBRANCH>
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\<TESTBUILDER>.ps1"
```

Danach:

1. erzeugtes Bundle im DCS-Missionseditor erneut über `DO SCRIPT FILE` auswählen,
2. `.miz` speichern,
3. Test gemäß `expected/`-Dokument ausführen,
4. standardmäßig nur die aktuelle `dcs.log` bereitstellen,
5. Ergebnis unter `results/` dokumentieren.

Die `.miz` wird nicht nach jedem Lauf benötigt. Sie wird nur bei Einbettungsnachweis, Missionseditor-Unklarheiten, fehlgeschlagenen Tests oder größeren Meilensteinen angefordert.
