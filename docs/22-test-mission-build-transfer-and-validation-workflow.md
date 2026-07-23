# 22 – Verbindlicher Workflow für DCS-Testmissionen

## 1. Zweck und Geltungsbereich

Dieses Dokument ist der projektweit verbindliche Arbeitsablauf für alle Testmissionen von **Operation Mountain Watch**.

Es regelt:

- wie der richtige Git-Branch lokal bereitgestellt wird,
- wie generierte Lua-Bundles gebaut und geprüft werden,
- wie ein neues Bundle in eine DCS-`.miz` übertragen wird,
- welche Dateien nach einem Testlauf benötigt werden,
- wie Testergebnisse im Repository dokumentiert werden,
- wie mit lokalen Änderungen und Branchwechseln umzugehen ist.

Der Benutzer muss diesen Ablauf in späteren Gesprächen nicht erneut erklären. Neue Testpakete müssen ihre konkreten Werte – Branch, erwarteter Commit, Builder, Bundlepfad, Mission und Laufdauer – auf Basis dieses Standardablaufs angeben.

## 2. Grundregeln

1. **Quellcode, Builder, Acceptance-Vorgaben und Ergebnisberichte gehören in GitHub.**
2. Dateien unter `dist/` werden ausschließlich durch den jeweiligen Builder erzeugt und niemals manuell bearbeitet.
3. Eine DCS-Mission bettet den Inhalt einer über `DO SCRIPT FILE` ausgewählten Lua-Datei beim Speichern in die `.miz` ein.
4. Ein späterer externer Neubau der Lua-Datei aktualisiert eine bereits gespeicherte `.miz` nicht automatisch.
5. Nach jedem relevanten Neubau muss die erzeugte Lua-Datei im Missionseditor erneut ausgewählt und die Mission gespeichert werden.
6. Der Testlauf muss dem exakt angegebenen Git-Commit und Bundle-Hash zugeordnet werden können.
7. Die `dcs.log` genügt normalerweise für PASS/FAIL. Die `.miz` wird nur in den unter Abschnitt 8 genannten Fällen benötigt.
8. Kein Teststand wird als vollständig oder produktionsreif bezeichnet, solange der zugehörige DCS-Acceptance-Test nicht PASS ist.
9. Nach jedem Test werden Fehlerursache, Korrektur und verbleibende Risiken im Repository dokumentiert, bevor der nächste Arbeitsauftrag erteilt wird.

## 3. Standardablauf: Repository aktualisieren

### 3.1 In das Repository wechseln

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch
```

### 3.2 Aktuellen Zustand prüfen

```powershell
git branch --show-current
git status --short
```

Diese Prüfung darf nicht übersprungen werden. Sie verhindert, dass versehentlich der falsche Branch aktualisiert oder gebaut wird.

### 3.3 Remote-Stand abrufen

```powershell
git fetch origin
```

### 3.4 Auf den für den Test genannten Branch wechseln

Wenn der Branch lokal noch nicht existiert:

```powershell
git switch --track origin/<TESTBRANCH>
```

Wenn er lokal bereits existiert:

```powershell
git switch <TESTBRANCH>
git pull --ff-only
```

### 3.5 Commit prüfen

```powershell
git rev-parse HEAD
```

Die Ausgabe muss exakt dem im jeweiligen Arbeitsauftrag genannten Commit entsprechen:

```text
<ERWARTETER_COMMIT>
```

Bei einer Abweichung wird nicht gebaut, sondern zuerst Branch und Pull-Ergebnis geklärt.

## 4. Lokale Änderungen und blockierte Branchwechsel

### 4.1 Keine pauschalen Resets

Lokale Änderungen werden niemals mit `git reset --hard` oder `git clean -fd` verworfen, solange nicht ausdrücklich feststeht, dass sie entbehrlich sind.

### 4.2 Einzelne verfolgte Datei sichern

Wenn eine lokal geänderte generierte Datei den Branchwechsel blockiert:

```powershell
git stash push -m "Preserve local bundle before test branch switch" -- <PFAD_ZUR_DATEI>
```

Danach erneut prüfen:

```powershell
git status --short
```

Der Stash wird auf dem Testbranch nicht eingespielt. Er wird erst nach der Rückkehr auf den ursprünglichen Branch wiederhergestellt.

### 4.3 Nicht verfolgte Dateien

Nicht verfolgte Dateien verhindern einen Branchwechsel nur, wenn der Zielbranch dieselben Pfade belegt. Sie werden nicht automatisch gelöscht. Bei einem Konflikt werden sie gezielt verschoben oder gesichert.

### 4.4 Rückkehr zum vorherigen Branch

```powershell
git switch <URSPRUNGSBRANCH>
git stash list
git stash pop
```

`git stash pop` wird nur ausgeführt, wenn der betreffende Stash eindeutig zu diesem Ursprungsbranch gehört.

## 5. Standardablauf: Bundle bauen

Jedes Testpaket nennt seinen Builder. Beispiel Jalalabad:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"
```

Ein erfolgreicher Builder muss mindestens ausgeben:

```text
Built: <AUSGABEDATEI>
SHA256: <HASH>
GitCommit: <COMMIT>
```

Danach wird die Datei unabhängig geprüft:

```powershell
Get-Item <AUSGABEDATEI> |
    Select-Object FullName, Length, LastWriteTime

Get-FileHash <AUSGABEDATEI> -Algorithm SHA256
```

Builder-Hash und `Get-FileHash` müssen identisch sein.

## 6. Bundle in die DCS-Mission übertragen

### 6.1 Triggerreihenfolge

MOOSE muss vor allen MOOSE-basierten Projektbundles geladen werden. Die konkrete Mission kann weitere bereits bestehende Bundles enthalten.

Typisches Beispiel:

```text
MISSION START
1. DO SCRIPT FILE -> Moose.lua
2. DO SCRIPT FILE -> bestehendes Test-/Projektbundle
3. DO SCRIPT FILE -> neu gebautes Testbundle
```

### 6.2 Erneut auswählen

Im DCS-Missionseditor:

1. vorhandene Aktion `DO SCRIPT FILE` des betreffenden Bundles öffnen,
2. die neu gebaute Datei erneut auswählen,
3. Mission speichern.

Es genügt nicht, dass im Editor bereits derselbe Dateiname angezeigt wird. Erst das erneute Auswählen und Speichern bettet den neuen Inhalt in die `.miz` ein.

### 6.3 Mission nicht durch externen Build aktualisiert

```text
Builder -> externe Lua-Datei aktualisiert
Missionseditor speichern -> Lua-Inhalt wird in .miz eingebettet
```

Ohne den zweiten Schritt verwendet die Mission weiterhin den alten eingebetteten Stand.

## 7. Testlauf

Der konkrete Acceptance-Bericht nennt:

- benötigte Missionseditor-Objekte,
- Mindestlaufzeit,
- erwartete Logzeilen,
- unzulässige Fehler oder Spawns,
- PASS-/FAIL-Kriterium.

Allgemein gilt:

1. Mission speichern.
2. Mission starten.
3. Mindestens die angegebene Zeit laufen lassen.
4. Sichtbare Spawns, Kollisionen und unerwartetes Verhalten beobachten.
5. Mission regulär beenden.
6. `dcs.log` nicht durch einen weiteren DCS-Start überschreiben lassen, bevor sie bereitgestellt wurde.

## 8. Übergabe der Testergebnisse

### 8.1 Standard: nur `dcs.log`

Für normale PASS/FAIL-Prüfungen wird ausschließlich die aktuelle `dcs.log` benötigt.

Typischer Pfad:

```text
C:\Users\<BENUTZER>\Saved Games\DCS\Logs\dcs.log
```

oder entsprechend im tatsächlich verwendeten Saved-Games-Profil, beispielsweise `DCS.openbeta`.

### 8.2 Wann zusätzlich die `.miz` benötigt wird

Die Mission wird nur angefordert, wenn mindestens einer dieser Fälle vorliegt:

- erstes Einbetten eines neuen Bundles und Hash-/Versionsnachweis erforderlich,
- Missionseditor-Name oder Objekt wurde vom Log nicht ausreichend erfasst,
- ein Test schlägt trotz scheinbar korrekter ME-Konfiguration fehl,
- Triggerreihenfolge oder eingebettete Dateien müssen geprüft werden,
- Abschluss eines größeren Meilensteins,
- Verdacht, dass eine andere oder ungespeicherte Mission getestet wurde.

### 8.3 `debrief.log`

Die `debrief.log` wird nur benötigt, wenn Ereignisse, Abschüsse, Verluste oder Missionsresultate dort genauer als in der `dcs.log` abgebildet werden. Sie wird nicht standardmäßig verlangt.

### 8.4 Übertragungsweg

Browser-/Chat-Upload bleibt der Standard, solange der Benutzer keinen anderen Weg verlangt. GitHub-CLI, ZIP-Sammelordner oder automatische Extraktionsskripte werden nicht vorausgesetzt.

## 9. Verbindliche Ergebnisdokumentation

Jeder relevante Testlauf erhält unter dem jeweiligen Testpfad einen Bericht in `results/`.

Der Bericht enthält mindestens:

```text
Datum und Teststufe
Branch
Git-Commit
Builder-Version
Bundle-SHA-256
Missionsname
MOOSE-Version/Commit, sofern relevant
Testziel
Erwartetes Ergebnis
Tatsächliches Ergebnis
PASS / PARTIAL / FAIL
Fehlerzeilen
Ursache
Korrektur
Weiterhin gültige Erkenntnisse
Verworfene Annahmen
Offene Risiken
Nächster Arbeitsauftrag
```

Ein fehlgeschlagener Lauf wird nicht überschrieben oder verschwiegen. Er bleibt als historischer Nachweis erhalten und wird durch einen separaten Retest-Bericht ergänzt.

## 10. Verbindliche Kommunikation pro neuem Teststand

Ein neuer Arbeitsauftrag muss kompakt und vollständig enthalten:

### 10.1 Repository

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git pull --ff-only
git rev-parse HEAD
```

Erwarteter Commit:

```text
<ERWARTETER_COMMIT>
```

### 10.2 Build

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\<BUILDER>.ps1"
```

### 10.3 Mission

- zu öffnende `.miz`,
- neu auszuwählende Bundle-Datei,
- anzulegende oder zu ändernde ME-Objekte,
- Dinge, die ausdrücklich noch nicht angelegt werden dürfen.

### 10.4 Test

- Mindestlaufzeit,
- erwartete Abschlussmeldung,
- unzulässige Fehler,
- danach benötigte Datei, standardmäßig nur `dcs.log`.

## 11. Typische Fehler und Gegenmaßnahmen

### Falscher Branch gebaut

Symptom: Builder fehlt oder der Commit entspricht einem anderen Testzweig.

Gegenmaßnahme:

```powershell
git branch --show-current
git rev-parse HEAD
```

vor jedem Build prüfen.

### `git pull` auf dem falschen Branch

Ein erfolgreicher Pull bestätigt nur, dass der aktuelle Branch aktualisiert wurde. Er bestätigt nicht, dass es der richtige Testbranch ist.

### Neues Bundle nicht in `.miz` eingebettet

Symptom: DCS loggt alte Builder-Version oder alten Hash.

Gegenmaßnahme: `DO SCRIPT FILE` neu auswählen und Mission speichern.

### ME-Objektname nicht gespeichert

Symptom: Validator meldet Objekt trotz sichtbarer Platzierung als fehlend.

Gegenmaßnahme: Einheiten-/Gruppenname prüfen, Mission explizit speichern, Test wiederholen.

### Unbesetzte Client-Gruppen über Runtime-GROUP geprüft

Client-Slots sind unbesetzt nicht immer als aktive MOOSE-`GROUP` verfügbar. Ihre Existenz wird über `_DATABASE.Templates.Groups` beziehungsweise die Mission-Template-Datenbank validiert.

### MOOSE-Wrapper wirft bei fehlendem Objekt Fehler

Bei `STATIC:FindByName()` wird für erwartbar fehlende Statics der nichtfehlerwerfende Aufruf verwendet:

```lua
STATIC:FindByName(name, false)
```

## 12. Abschlussregel

Ein Testbereich gilt erst als abgeschlossen, wenn:

1. der aktuelle Acceptance-Test PASS ist,
2. keine relevanten Lua-/Timerfehler auftreten,
3. erwartete Objekte und Bestände vollständig validiert wurden,
4. sichtbares Verhalten und Kollisionen geprüft wurden,
5. der Ergebnisbericht im Repository liegt,
6. die Dokumentation keine widersprüchlichen älteren Arbeitswerte mehr als aktuell ausweist.
