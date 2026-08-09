---
document_id: OMW-TEST-MISSION-BUILD-TRANSFER-VALIDATION
status: BINDING
document_class: TEST_ARTIFACT_WORKFLOW
owning_policy: OMW-GOV-001
authoritative_for:
  - construction, transfer and identity verification of OMW DCS test bundles
  - owner-facing handoff of local build, transfer and verification steps
  - MIZ artifact invalidation after save, replacement or transfer
  - required hash chain and test evidence package
  - static preflight before long DCS runs
  - observer-client handling during test execution
not_authoritative_for:
  - airfield-specific object contracts
  - acceptance of tactical runtime behavior
  - merge or Ready-for-Review authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-only Document 22 workflow in Draft PR 18
  - dead main references to a non-existent docs/22-test-mission-build-transfer-and-validation-workflow.md
superseded_by:
source_branch: agent/tarinkot-revised-parking-layout
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Testmissionen bauen, übertragen und validieren

## 1. Zweck

Dieses Dokument ist der kanonische, auf `main` vorgesehene Workflow für jedes OMW-Testbundle und jede damit getestete `.miz`. Es integriert die bisher nur branchgebundene Dokument-22-Funktion und beseitigt damit die tote Abhängigkeit aus dem allgemeinen Flugplatzworkflow.

Verbindliche Begleitdokumente:

```text
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/moose/AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md
mission/tests/GOVERNANCE.md
```

## 2. Artefaktkette

Jeder Teststand besitzt eine lückenlose Kette:

```text
Git-Commit
-> Source-Lua
-> Builder
-> generiertes Bundle
-> eingebettetes Bundle in der MIZ
-> ausgeführte MIZ
-> DCS-Log
-> Debrief
-> Ergebnisbericht
```

Kein Glied darf nur anhand eines Dateinamens angenommen werden.

## 3. Source und Builder

Regeln:

- `src/` enthält die lesbare Testlogik;
- `dist/` wird ausschließlich vom Builder erzeugt;
- das generierte Bundle wird nicht manuell verändert;
- der Builder besitzt eine eindeutige `BuilderVersion`;
- der Builder schreibt Git-Commit und UTC-Erzeugungszeit in den Bundle-Header;
- verbotene Klassen und Pfade werden statisch geprüft;
- AirOps-Builder führen zusätzlich `tools/Test-AirOpsLifecycleGuards.ps1` aus;
- ein Builder-Fail blockiert Bundle-Erzeugung und DCS-Lauf.

## 4. Pflichtheader des Bundles

```text
Builder
BuilderVersion
GitCommit
GeneratedUtc
Gate/Test-ID
Scope
explizite Ausschlüsse
MOOSE-Commit und Moose.lua-SHA-256, sofern MOOSE verwendet wird
```

Der Bundle-Hash wird nach Erzeugung berechnet und im Testprotokoll festgehalten.

## 5. MIZ-Einbindung

Vor dem Test werden geprüft:

```text
erwarteter Ressourcenpfad in l10n/DEFAULT
Trigger oder DO SCRIPT FILE verweist auf genau diese Ressource
keine alte parallele Version desselben Testbundles aktiv
Moose.lua wird vor dem Testbundle geladen
keine unerwartete Testmission oder Diagnose desselben Gates parallel aktiv
```

Die eingebetteten Bytes müssen mit dem lokal gebauten Bundle übereinstimmen. Dateiname allein genügt nicht.

## 6. MIZ-Invalidierungsregel

Jedes Speichern, Neuverpacken, Überschreiben oder Übertragen einer `.miz` invalidiert die bisherige Zuordnung des Struktur-PASS zu dieser Arbeitsdatei.

Nach jeder Änderung werden neu erfasst:

```text
MIZ-SHA-256
interner mission-SHA-256
eingebetteter Bundle-SHA-256
eingebetteter Moose.lua-SHA-256
Objektvertragssmoke für alle Objekte des nächsten Gates
```

Ein früherer PASS bleibt historisch gültig für seine alte Hashkette, darf aber nicht als Beweis für die geänderte MIZ verwendet werden.

## 7. Objektvertragssmoke nach MIZ-Änderung

Vor mutierender Testlogik müssen alle für das Gate verwendeten Objekte erneut bestätigt werden:

```text
AIRBASE Name und ID
Warehouse-Anker
Clients
KI-Templates
Statics
Zonen
Parkingcount und verwendete TerminalIDs
DCS-Typen
Gruppengrößen
Late-Activation-/Uncontrolled-Status
```

Der Smoke darf im gleichen kombinierten Bundle vor dem eigentlichen Gate laufen. Ein separates langes DCS-Szenario ist nicht erforderlich.

## 8. Transfer zum DCS-System

Der Transfer muss reproduzierbar sein. Pro Teststand werden protokolliert:

```text
Quellpfad des gebauten Bundles
Ziel-MIZ
Ziel-Ressourcenpfad
lokaler Bundle-SHA-256
MIZ-SHA-256 vor beziehungsweise nach Einbindung
MIZ-interner Bundle-SHA-256
```

Eine manuelle Ersetzung ist zulässig, solange die Hashprüfung unmittelbar danach erfolgt. Ein Mission-Editor-Speichern nach der Einbindung erzeugt wiederum einen neuen MIZ-Hash und verlangt die erneute interne Prüfung.

### 8.1 Verbindliche Form der lokalen Arbeitsübergabe

Wenn ein Build-, Hash-, Transfer-, Mission-Editor- oder DCS-Schritt auf dem Windows-System des Projektinhabers ausgeführt werden muss, wird der Auftrag direkt an den Projektinhaber formuliert. Es wird kein Codex, CODEX-CLI, Subagent oder anderer externer Ausführer angenommen oder zwischengeschaltet.

Die feste Arbeitsteilung lautet:

```text
Entwicklung und Bereitstellung durch den Assistenten:
- verbindliche Regeln und Dokumentation auf main vollständig prüfen
- MOOSE-First-Recherche durchführen
- Source-Lua, Builder, Guards und Dokumentation entwickeln
- alle verfügbaren statischen Prüfungen ausführen und den Diff prüfen
- Änderungen committen und den Arbeitsbranch remote bereitstellen

Projektmanagement und lokale Ausführung durch den Projektinhaber:
- fachliche Entscheidungen und ausdrückliche Freigaben erteilen
- die lokale Git-Arbeitskopie nach konkreter Anweisung aktualisieren
- das ignorierte dist/-Bundle mit dem bereitgestellten Builder erzeugen
- die projektinhabergeführte MIZ nur nach ausdrücklicher Anweisung ändern
- den bereitgestellten Lua-Stand in DCS testen und visuell bewerten
```

Der Projektinhaber entwickelt dabei keinen Lua-Code, leitet keine Builderlogik oder Sollwerte selbst her und repariert keine Repository-Dateien. Vor einer lokalen Build-Übergabe muss der Assistent den vollständigen ausführbaren Stand unter einem erreichbaren Remote-Branch und einem exakten Commit bereitgestellt haben.

Die Übergabe muss als nummerierte, unmittelbar kopierbare Schrittfolge mindestens enthalten:

```text
1. exakter lokaler Repository-Pfad und Wechsel in dieses Verzeichnis
2. Befehle zum Aktualisieren und Prüfen von Branch, HEAD und Arbeitsbaum
3. exakt erwarteter Branch und vollständiger erwarteter Commit-Hash
4. Hinweis auf absichtlich untracked bleibende Artefakte, insbesondere dist/
5. vollständiger PowerShell-Aufruf des freigegebenen Builders
6. erwartete relevante Builder-, Guard- und Versionsausgabe
7. exakter Pfad des erzeugten Artefakts
8. vollständiger Befehl zur SHA-256-Prüfung
9. eindeutige Stop-Bedingungen bei abweichendem Commit, dirty Arbeitsbaum,
   Builder-Fail, Guard-Fail, fehlender Datei oder unerwarteter Ausgabe
10. genaue Angabe, welche vollständigen Ausgaben und Hashes zur Auswertung
    zurückgegeben werden müssen
```

Ein Skriptname, ein einzelner Shell-Befehl oder die bloße Aussage, ein Bundle müsse gebaut werden, ist keine ausreichende Arbeitsübergabe. Der Projektinhaber soll weder Builderlogik noch erwartete Sollwerte selbst herleiten und niemals ein generiertes Bundle manuell bearbeiten.

Die Übergabe umfasst nur den aktuell autorisierten und fachlich abgegrenzten Schritt. MIZ-Änderung, Bundle-Einbindung, DCS-Start und Runtime-Test werden erst als eigener Folgeschritt angewiesen, wenn die jeweils vorgelagerten Nachweise ausgewertet und die erforderlichen Freigaben erteilt wurden.

Nach jedem lokalen Schritt liefert der Projektinhaber die vollständige Konsolenausgabe und die angeforderten Hashes zurück. Erst nach deren Prüfung wird der nächste Schritt formuliert.

## 9. Statische Freigabe vor DCS

Vor einem längeren DCS-Lauf müssen PASS sein:

```yaml
branch_and_commit_known: true
builder_version_known: true
source_guard_pass: true
lifecycle_guard_pass: true
bundle_built_from_current_source: true
bundle_hash_recorded: true
miz_hash_recorded: true
embedded_bundle_hash_matches: true
embedded_moose_hash_matches: true
object_contract_smoke_present: true
acceptance_criteria_current: true
previous_failures_documented: true
```

Ohne diese Freigabe wird kein 30-Minuten-Test gestartet.

## 10. Observer-Client

Ein Beobachter-Client darf verwendet werden, wenn:

- seine Clientposition im Objektvertrag bestätigt ist;
- seine TerminalID hart aus KI-Parkingpools ausgeschlossen ist;
- das Gate durch den Client nicht funktional beeinflusst wird;
- der Client als Beobachter im Testbericht genannt wird.

Telemetrie muss tatsächliche Detektion und Blockierwirkung getrennt ausgeben:

```text
observerClientsDetected
observerClientsAllowed
observerClientsBlocking
observerClientUnits
```

Der erkannte Wert darf nicht durch eine Wrapperfunktion auf null gesetzt werden.

## 11. Testausführung

Technisch zusammengehörige Prüfungen werden standardmäßig gebündelt:

```text
ein Bundle
eine MIZ-Ersetzung
ein DCS-Lauf
Subsystemmarker
ein Aggregatergebnis
```

Getrennte Läufe sind nur erforderlich, wenn der kombinierte Lauf eine Fehlerursache nicht isolieren kann.

Während des Laufs werden mindestens erfasst:

```text
DCS-Version
Missionsstart und Missionsende
Bundle-BUILD-Marker
Objektvertragssmoke
Gate-spezifische Ereignisse
Lua-/Timer-/Schedulerfehler
unerwartete Spawns oder Missionen
Observer-Client-Telemetrie
finaler RESULT-Marker
```

## 12. Ergebnisbewertung

Jeder Lauf erhält genau eine Klassifikation:

```text
PASS
PASS_WITH_LIMITATION
PARTIAL
FAIL
INVALID
NOT_RUN
```

Ein PASS setzt positive Nachweise voraus. Beispiele:

- `Running` statt nur kein Fehler;
- erwartete Assetzahl nach dem korrekten Lifecycle-Zeitpunkt;
- `MissionAssign`, `MissionRequest`, `OpsOnMission` und Zustandsfortschritt statt nur sichtbares Luftfahrzeug;
- tatsächliche Unitposition statt nur konfigurierte Parkingliste.

Ein fehlerhaftes einzelnes Telemetriefeld kann verworfen werden, wenn der Rohlog den tatsächlichen Wert eindeutig enthält. Die Einschränkung muss dann ausdrücklich dokumentiert werden.

## 13. Pflichtprovenienz des Ergebnisberichts

```text
Branch
Source-Commit
Builder-Version
Sourcepfad
Bundlepfad
Bundle-SHA-256
MIZ-Dateiname
MIZ-SHA-256
interner mission-SHA-256
DCS-Version
MOOSE-Commit
Moose.lua-SHA-256
Testdatum und Laufzeitfenster
DCS-Log-SHA-256
Debrief-SHA-256
Observer-Client
visuelle Beobachtungen
```

Zusätzlich:

```text
Ziel
erwartetes Ergebnis
tatsächliches Ergebnis
Klassifikation
Root Cause
Korrektur
weiterhin gültige Befunde
verworfene Annahmen
Restgrenzen
nächster freigegebener Schritt
```

## 14. Abschlussregel

Ein nachfolgendes Gate darf erst vorbereitet werden, wenn:

- Ergebnisbericht und Test-README synchron sind;
- Manifest und PR-Beschreibung denselben Status nennen;
- zentrale MOOSE-/Lifecycle-Dokumentation aktualisiert ist;
- Builder-Guards den bekannten Fehler künftig blockieren;
- die nächste MIZ-/Bundle-Kette eindeutig ist.

Ein technischer PASS erteilt keine Merge- oder Ready-for-Review-Freigabe.
