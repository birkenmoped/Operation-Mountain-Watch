# Jalalabad Phase 1 – MOOSE-first Build-Gate FAIL und vollständige Korrektur

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

Nach einer ersten unvollständigen Korrektur wurde der Build bei Commit

```text
fb037f645f090db0449f944075216e954ec5e3ad
```

erneut mit derselben Meldung abgebrochen.

## 2. Vollständige Ursache

Der Builder prüft alle kanonischen Lua-Quellen gemeinsam. Die erste Fehlerausgabe nannte nur das verbotene Muster, jedoch nicht die betroffenen Dateien. Deshalb wurden zunächst nur zwei Fundstellen korrigiert.

Die vollständige Prüfung aller Builder-Quellen ergab insgesamt fünf betroffene Dateien:

```text
04-dump-aircraft-types.lua
05-validate-mission-templates.lua
05a-validate-squadron-parking-pools.lua
05b-validate-runtime-name-contract.lua
10-validate-and-start-complete-node.lua
```

Alle fünf Dateien griffen direkt oder indirekt auf die interne MOOSE-Gruppenvorlagentabelle zu.

Der zunächst verwendete Ersatz

```lua
GROUP:FindByName(name)
GROUP:Register(name)
GROUP:GetTemplate()
```

war ebenfalls nicht die endgültig richtige Lösung. `GROUP:Register()` kann für nicht vorhandene optionale Gruppen einen Wrapper erzeugen. Das ist für eine reine Existenzprüfung unnötig und kann die Laufzeitdatenbank beeinflussen.

## 3. Verwendete MOOSE-Funktion

Die gepinnte MOOSE-Version stellt die öffentliche Methode bereit:

```lua
DATABASE:GetGroupTemplate(GroupName)
```

Die kanonische Verwendung lautet jetzt in allen fünf Dateien:

```lua
local ok, template = pcall(function()
  return _DATABASE:GetGroupTemplate(name)
end)
```

Damit werden Mission-Editor-Gruppenvorlagen einschließlich unbesetzter Clientgruppen und Late-Activation-Templates über eine dokumentierte MOOSE-Methode gelesen. Es wird nicht mehr direkt auf die interne Tabellenstruktur zugegriffen und es werden keine künstlichen GROUP-Wrapper erzeugt.

## 4. Betroffene Korrekturen

```text
6bc564221be7049aa1f7311db938c48681a6fe97
  04-dump-aircraft-types.lua

4c0207d5ee3712530f1014b88b1e9b57c89db1c0
  05-validate-mission-templates.lua

9353e5ac0ca50aa2a6a0ecb860d11d75c0b4ff4c
  05a-validate-squadron-parking-pools.lua

bc3dcf30194e582a31e0b452e272a032c3332437
  05b-validate-runtime-name-contract.lua

caddfc1e0faba35f9b4af67f68c81397637d6b1f
  10-validate-and-start-complete-node.lua
```

Die früheren Commits `75d0aeaf...` und `5fdd0054...` mit dem `GROUP:Register()`-Ansatz sind durch diese einheitliche DATABASE-API-Korrektur superseded.

## 5. Builder-Diagnostik

Der Builder wurde zusätzlich verbessert:

```text
899d37446fe940696ec3e19b9816c7d8cc9e9613
```

Der Regression-Gate prüft weiterhin alle verbotenen Muster. Bei einem Treffer werden jetzt jedoch sämtliche Fundstellen mit Dateiname und Zeilennummer ausgegeben.

Beispiel:

```text
MOOSE-first source regressions found:
 - 04-dump-aircraft-types.lua:8 [_DATABASE\.Templates\.Groups]
 - 05a-validate-squadron-parking-pools.lua:30 [_DATABASE\.Templates\.Groups]
```

Zusätzlich ist `GetGroupTemplate` nun eine verpflichtende MOOSE-API des kanonischen Bundles.

## 6. Unveränderte Grenzen

- keine `.miz` geändert;
- keine Mission-Editor-Objekte geändert;
- keine Paketgrößen geändert;
- keine AIRWING-/SQUADRON-Bestände geändert;
- keine Transport- oder Logistiksemantik geändert;
- keine DCS-Abnahme durchgeführt;
- kein altes PHASE1-9-Bundle darf weiterverwendet werden.

## 7. Lokaler Fremdkörper `-File`

Beim zweiten lokalen Versuch zeigte `git status --short`:

```text
?? -File
```

Diese unversionierte Datei gehört nicht zum Repository und nicht zum Builder. Sie entstand wahrscheinlich durch eine zuvor unvollständig interpretierte PowerShell-Befehlszeile. Sie muss vor dem nächsten Pull/Build lokal gelöscht werden.

## 8. Noch ausstehend

Nach dem Pull des endgültigen Branch-HEAD:

1. lokale Datei `-File` löschen;
2. sicherstellen, dass `git status --short` leer ist;
3. altes `dist/OMW_AirOps_Jalalabad.lua` löschen;
4. Builder erneut ausführen;
5. neuen Bundle-Header prüfen;
6. erst nach erfolgreichem Build das Bundle in der bestehenden `.miz` neu auswählen;
7. zunächst ausschließlich den UH-60-OPSTRANSPORT-Test durchführen.

Erwarteter Bundle-Header:

```text
BuilderVersion: JBAD-AIR-OPS-PHASE1-11-MOOSE-FIRST
GitCommit: <aktueller Branch-HEAD nach dieser Dokumentation>
```

Ein erfolgreicher Build ist noch kein DCS-PASS. Der DCS-Status bleibt `VALIDATION PENDING`.
