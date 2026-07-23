# Operation Mountain Watch – Testmissionen

Für alle Testmissionen gilt verbindlich:

```text
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Kurzablauf:

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
