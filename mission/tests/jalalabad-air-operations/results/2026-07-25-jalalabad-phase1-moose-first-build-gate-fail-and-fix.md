# Jalalabad Phase 1 – MOOSE-first Build-Gate FAIL und Korrektur

Stand: 2026-07-25  
Branch: `feature/jalalabad-airwing-phase1-functional-tests`  
Ausgangscommit: `ca9c6d306623e03ff9affd297e5a6a4123987bc1`  
BuilderVersion: `JBAD-AIR-OPS-PHASE1-11-MOOSE-FIRST`  
Status: **SOURCE FIXED IN GITHUB / LOCAL BUILD PENDING / DCS NOT RUN**

## 1. Beobachteter Fehler

Der erste lokale Build nach dem MOOSE-first-Refactoring wurde vom neuen Regression-Gate abgebrochen:

```text
MOOSE-first regression: forbidden custom/internal pattern '_DATABASE\.Templates\.Groups'.
```

Der Abbruch erfolgte vor der Erzeugung eines neuen Bundles. Die anschließend vorhandene Datei

```text
mission/tests/jalalabad-air-operations/dist/OMW_AirOps_Jalalabad.lua
```

war weiterhin das alte Bundle:

```text
BuilderVersion: JBAD-AIR-OPS-PHASE1-9
GitCommit: 522ea5e5924ff6e338ac8de91eba8806667e7415
```

Dieses alte Bundle ist für den MOOSE-first-Teststand ungültig und darf nicht in die `.miz` übernommen werden.

## 2. Ursache

Das Refactoring hatte direkte Zugriffe auf MOOSE-interne Tabellen als unzulässig definiert und im Builder blockiert. Zwei ältere Validierungsdateien verwendeten dennoch weiterhin:

```lua
_DATABASE.Templates.Groups
```

Betroffen waren:

```text
05-validate-mission-templates.lua
05b-validate-runtime-name-contract.lua
```

Der neue Builder-Gate hat damit korrekt funktioniert. Der Fehler lag darin, dass der Refactoring-Stand vor einem vollständigen lokalen Builder-Durchlauf veröffentlicht wurde.

## 3. Korrektur

Beide direkten Tabellenzugriffe wurden im GitHub-Branch entfernt.

Verwendet wird nun der öffentliche MOOSE-Wrapperpfad:

```lua
GROUP:FindByName(name)
GROUP:Register(name)
GROUP:GetTemplate()
```

`GROUP:Register()` wird nur verwendet, wenn für eine unbesetzte Clientgruppe oder ein Late-Activation-Template noch kein Wrapper durch `GROUP:FindByName()` geliefert wird. `GROUP:GetTemplate()` bleibt die öffentliche Quelle für die Mission-Editor-Vorlage.

Die Namensprüfung wertet nun direkt die von `GROUP:GetTemplate()` gelieferte Template-Tabelle aus; die frühere interne Zwischenstruktur mit `entry.Template` entfällt.

## 4. GitHub-Commits

```text
75d0aeaf58991144461992380b924218751fcb31
  05-validate-mission-templates.lua

5fdd00549ba5ed477a5f9acc497cdc79a7f0de01
  05b-validate-runtime-name-contract.lua
```

## 5. Unveränderte Grenzen

- keine `.miz` geändert;
- keine Mission-Editor-Objekte geändert;
- keine Paketgrößen geändert;
- keine AIRWING-/SQUADRON-Bestände geändert;
- keine Transport- oder Logistiksemantik geändert;
- keine DCS-Abnahme durchgeführt;
- kein altes PHASE1-9-Bundle darf weiterverwendet werden.

## 6. Noch ausstehend

Der Projektinhaber muss nach dem Pull:

1. das alte `dist/OMW_AirOps_Jalalabad.lua` löschen;
2. den Builder erneut ausführen;
3. den neuen Bundle-Header prüfen;
4. erst nach erfolgreichem Build das Bundle in der bestehenden `.miz` neu auswählen;
5. zunächst ausschließlich den UH-60-OPSTRANSPORT-Test durchführen.

Erwarteter Bundle-Header:

```text
BuilderVersion: JBAD-AIR-OPS-PHASE1-11-MOOSE-FIRST
GitCommit: <aktueller Branch-HEAD nach dieser Dokumentation>
```

Ein erfolgreicher Build ist noch kein DCS-PASS. Der DCS-Status bleibt `VALIDATION PENDING`.
