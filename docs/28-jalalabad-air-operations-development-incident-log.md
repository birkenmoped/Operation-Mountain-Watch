# Jalalabad Air Operations – Entwicklungs- und Fehlerchronik

Stand: 2026-07-25  
Zweck: chronologische Aufzeichnung aller bekannten Fehlannahmen, Fehlzustände, Korrekturen und belastbaren Ergebnisse vom Grundknoten bis zur taktischen Phase 1

Verbindliche Architekturregeln:

- `docs/27-jalalabad-air-operations-phase1-postmortem-and-guardrails.md`
- `mission/tests/jalalabad-air-operations/expected/jalalabad-phase1-package-contract.md`
- `mission/tests/jalalabad-air-operations/expected/jalalabad-phase1-architecture-regression-checklist.md`

## 1. Statusgrenze

### 1.1 Belastbar akzeptiert

Der Jalalabad-Grundknoten wurde in DCS als `OPERATIONAL / ACCEPTED` nachgewiesen:

```text
AIRWING aufgebaut und gestartet
COMMANDER verknüpft und gestartet
Warehouse-Anker vorhanden
SQUADRONs vorhanden
Parking-Modell validiert
keine spontane Jalalabad-KI-Mission im Leerlauftest
```

Akzeptierter Grundknoten-Stand:

```text
Commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
BuilderVersion: JBAD-AIR-OPS-COMPLETE-5
```

### 1.2 Noch nicht akzeptiert

Nicht durch den Grundknoten-Lauf abgenommen wurden:

```text
RECON-Auftragsausführung
CAS-Auftragsausführung
TROOPTRANSPORT-Pickup/Dropoff
CARGOTRANSPORT-Terminalauswertung
Two-Ship-Rückkehr und Landung
vollständiges UH-60 Lead-/Guard-MEDEVAC-Paket
dynamische Spieleranforderungen
```

Aktueller funktionaler Vertragsstand:

```text
JBAD-AIR-OPS-PHASE1-7
DCS VALIDATION PENDING
```

## 2. Grundknoten: Repository- und Arbeitsfehler

### INC-001 – Branchwechsel durch lokale generierte Datei blockiert

Befund:

Ein Branchwechsel wurde durch eine lokal vorhandene generierte Datei verhindert.

Ursache:

Generierte Artefakte und Quellstand waren nicht sauber getrennt beziehungsweise der lokale Arbeitsbaum wurde vor dem Wechsel nicht ausreichend geprüft.

Auswirkung:

- Verzögerung;
- Unsicherheit, welcher Branch tatsächlich aktiv war;
- Risiko, Änderungen auf falscher Basis auszuführen.

Korrektur:

Vor jedem Wechsel:

```powershell
git branch --show-current
git status --short
git fetch origin
```

Guardrail:

- `dist`-Artefakte sind reproduzierbar und keine manuell zu pflegende Quelle;
- kein `git switch` oder `git pull`, bevor Branch und Arbeitsbaum geprüft wurden.

### INC-002 – Pull auf dem falschen aktiven Branch

Befund:

Nach dem blockierten Wechsel wurde ein Pull ausgeführt, obwohl nicht der erwartete Branch aktiv war.

Auswirkung:

- falscher lokaler Stand;
- zusätzliche Fehlersuche;
- unklare Zuordnung von Build und Commit.

Korrektur:

Der erwartete Branch und anschließend `git rev-parse HEAD` werden immer explizit geprüft.

Guardrail:

Jede Übergabe nennt:

```text
Branch
vollständigen erwarteten Commit
Builder
lokale Build- und Hashprüfung
```

## 3. Grundknoten: Mission-Editor- und DCS-Objektfehler

### INC-003 – `STATIC:FindByName(name)` erzeugte Timerfehler

Befund:

Die Suche nach erwartbar noch nicht vorhandenen Statics erzeugte DCS-/MOOSE-Fehler.

Ursache:

Die nicht stille Suchvariante wurde für ein optionales beziehungsweise während des Aufbaus möglicherweise fehlendes Objekt verwendet.

Korrektur:

```lua
STATIC:FindByName(name, false)
```

Guardrail:

Bei erwartbar fehlenden Objekten wird die stille Suchvariante verwendet. Ein fehlendes Objekt wird durch den eigenen Validator gemeldet, nicht durch einen unkontrollierten MOOSE-Fehler.

### INC-004 – Warehouse-Anker war im Missionseditor nicht korrekt gespeichert

Befund:

Der zunächst angelegte Warehouse-Anker war unter dem erwarteten Namen nicht verfügbar.

Ursache:

Missionseditor-Änderung war nicht korrekt gespeichert beziehungsweise der Name entsprach nicht dem Vertrag.

Korrektur:

- exakter Name `WH_AIR_US_JALALABAD`;
- erneutes Speichern der Mission;
- Prüfung über DCS-Log und MOOSE-Suche.

Guardrail:

ME-Objekte gelten erst nach DCS-Nachweis als vorhanden. Screenshots oder Annahmen ersetzen die Laufzeitprüfung nicht.

### INC-005 – Unbelegte Client-Gruppen falsch geprüft

Befund:

Nicht besetzte Client-Gruppen waren über aktive Gruppenwrapper nicht zuverlässig auffindbar.

Ursache:

Eine Missionseditorvorlage wurde mit einer aktiven Laufzeitgruppe verwechselt.

Korrektur:

Client- und Templategruppen werden über `_DATABASE.Templates.Groups` validiert.

Guardrail:

Authoring-Objekt und aktive Runtime-Instanz sind getrennte Ebenen.

## 4. Grundknoten: Bestands- und ORBAT-Irrtümer

### INC-006 – Verfrühte Vollständigkeitsbehauptung `24/8/6`

Befund:

Ein Zwischenstand wurde als vollständig dargestellt, obwohl der Bestand noch nicht belastbar geklärt war.

Korrektur:

Die Behauptung wurde zurückgezogen. Der verbindliche logische Bestand lautet:

```text
24 OH-58D
 8 AH-64D
 8 UH-60
 8 CH-47
```

Guardrail:

Bestandszahlen benötigen eine benannte Ebene und eine dokumentierte Quelle beziehungsweise Projektentscheidung.

### INC-007 – Spielerplätze zunächst zu hoch angesetzt

Befund:

Es waren zunächst vier Spielerplätze je nutzbarem Typ vorgesehen.

Korrektur:

Der modfreie Kernstand wurde auf zwei Clientplätze je OH-58D, AH-64D und CH-47 reduziert. UH-60L bleibt optional.

Guardrail:

Clientplätze, logischer Bestand und dynamische KI-Kapazität werden getrennt geplant.

### INC-008 – Falsche UH-60-Cover-Livery

Befund:

Das UH-60-Cover-Template verwendete zeitweise `Egyptian Air Force` statt `standard`.

Korrektur:

Beide UH-60-MEDEVAC-Templates verwenden `standard`.

Guardrail:

Templatevalidierung prüft Typ, Gruppengröße und missionsrelevante Livery.

## 5. Grundknoten: Parking- und Darstellungsfehler

### INC-009 – Templates, dynamische Spawns und sichtbare Statics vermischt

Fehlannahme:

Die sieben Luftfahrzeuge in fünf Late-Activation-Templates wurden teilweise so behandelt, als belegten sie dauerhaft Ramp- und Bestandsplätze.

Korrekte Trennung:

```text
MOOSE-Template = technische Kopiervorlage
AIRWING-Spawn = dynamische physische Laufzeitgruppe
Static = sichtbare Ramp-Darstellung
Client = Spielergruppe
logischer Bestand = Kampagnenbestand
```

Guardrail:

Keine gemeinsame Summenbildung über diese Ebenen.

### INC-010 – Absichtliche CH-47-Static-Parkplätze als Kollision bewertet

Befund:

Vier CH-47-Statics stehen absichtlich auf echten DCS-Parkknoten:

```text
TerminalID 49
TerminalID 37
TerminalID 23
TerminalID 35
```

Der erste Validator wertete diese absichtlichen Belegungen als unerwartete Kollisionen.

Korrektur:

- explizite Static-Parking-Reservierungen;
- Blacklist `23,35,37,49`;
- Validator unterscheidet deklarierte Reservierung und unerwartete Überlagerung.

Guardrail:

Eine belegte Parkposition ist nicht automatisch ein Fehler. Sie muss einer klaren Ebene und einem Eigentümer zugeordnet sein.

### INC-011 – Builder enthielt veralteten Finalizer

Befund:

Der Bundle-Builder band eine obsolete Finalizer-Datei ein.

Auswirkung:

Spätere, bereits korrigierte Logik konnte durch alte Funktionen erneut überschrieben werden.

Korrektur:

Builder-Liste bereinigt.

Guardrail:

- Builder-Reihenfolge ist Teil der Architekturprüfung;
- entfernte beziehungsweise obsolete Quellen dürfen nicht im Bundle verbleiben;
- generiertes Bundle wird anhand seiner `BEGIN SOURCE`-Blöcke geprüft.

## 6. Taktische Phase: Identitäts- und Spawnfehler

### INC-012 – Fremde OH-58-Clientmaschine als Missionsasset gezählt

Befund:

`TEST_TM01A_CLIENT_01` wurde durch type-only/provisional matching als aktive Missionsmaschine beansprucht.

Gleichzeitig wurde die echte MOOSE-OH-58-Gruppe als unerwarteter Spawn behandelt und abgebrochen.

Ursache:

- Typgleichheit statt exakter Identität;
- Runtime-Gruppe noch nicht registriert;
- unsicherer Fallback.

Korrektur:

```text
exakter SQUADRON_AID-Gruppenpräfix
exakte Einheitenregel
kein type-only fallback
Authoring-/Client-Ausschluss
```

Guardrail:

Ein Event ohne exakte aktive Gruppen- und Einheitennamenszuordnung wird ignoriert oder als separater Fehler protokolliert, aber niemals provisorisch beansprucht.

## 7. Taktische Phase: Two-Ship-Irrtum

### INC-013 – Two-Ship-Templates als unabhängige Single-Ships verwendet

Befund:

Die ME-Templates für OH-58D und AH-64D enthielten jeweils zwei Luftfahrzeuge. Der SQUADRON-Code setzte dennoch `SetGrouping(1)`.

Folge:

- zwei unabhängige AID-Gruppen;
- keine gemeinsame DCS-Formation;
- zeitlich und räumlich stark auseinandergezogene Maschinen;
- keine gegenseitige Deckung;
- unterschiedliche Rückkehr- und Landeverläufe.

Fehlannahme:

Zwei reservierte Single-Ship-Assets seien ein ausreichendes „logisches Two-Ship“.

Korrektur:

```text
OH-58D: SetGrouping(2), 1 Gruppe, 2 Luftfahrzeuge
AH-64D: SetGrouping(2), 1 Gruppe, 2 Luftfahrzeuge
```

Guardrail:

`PHYSICAL_TWO_SHIP` ist eine physische DCS-Gruppe. Das Paketmodell darf nicht als Workaround für Lifecycle-Probleme geändert werden.

### INC-014 – AH-64D-Wingman-Landeproblem falsch behandelt

Befund:

Bei einem physischen AH-64D-Two-Ship landete der Lead, während der Wingman kreiste.

Fehlentscheidung:

Statt Landing-/RTB-/Despawn-Logik zu korrigieren, wurde das Two-Ship in zwei Single-Ships zerlegt.

Korrektur:

Das physische Two-Ship wurde wiederhergestellt. Das Landeverhalten muss separat geprüft und gelöst werden.

Guardrail:

Ein Problem auf der Lifecycle-Ebene darf nicht durch eine fachlich falsche Änderung der Gruppenstruktur beseitigt werden.

## 8. Taktische Phase: OH-58D-Routing und Fuel

### INC-015 – RECON-Höhe von `4000 ft ASL` war im Gebirge ungeeignet

Befund:

Die OH-58D befanden sich in Gelände um etwa 10.800 ft MSL, während der Auftrag 4.000 ft ASL vorgab.

Folge:

DCS-AI musste Terrainavoidance und Auftragsvorgabe widersprüchlich behandeln.

Guardrail:

ASL und AGL werden nie gleichgesetzt. Höhenwerte werden gegen DCS-Geländedaten geprüft.

### INC-016 – Direkter Rückflug vom letzten RECON-Punkt

Befund:

Der Hinflug folgte den RECON-Punkten. Nach dem letzten Punkt führte MOOSE/DCS die Maschinen direkt nach Jalalabad zurück.

Folge:

- Konturenflug;
- Überquerung ungeeigneter Berghänge;
- hohe Steig- und Sinkanforderungen;
- unnötiger Kraftstoffverbrauch;
- Außenlandung.

Korrektur:

Expliziter Rückkorridor:

```text
RECON_03 -> RECON_02 -> RECON_01 -> Jalalabad
```

Guardrail:

Hinroute und Rückroute sind beide Bestandteil des Auftragsdesigns. Ein vorhandener Hinweg beweist keinen sicheren RTB-Weg.

### INC-017 – Sinnlose Pirouetten am Ziel

Befund:

Die OH-58D drehten am dritten Wegpunkt enge beziehungsweise nahezu stationäre Kreise ohne nachvollziehbare Aufklärungswirkung.

Wahrscheinlicher Zusammenhang:

Widerspruch zwischen Zone, Höhe, Terrainavoidance, Missionsfortschritt und Route.

Guardrail:

Ein MOOSE-Missionsstatus ersetzt keine operationelle Beobachtung. Unplausibles Verhalten ist ein operationeller FAIL, auch wenn der Auftrag technisch weiterläuft.

### INC-018 – Heuristische Grenzen als Safety-Gate ausgegeben

Eingeführte Werte:

```text
18.000 m Zone-Entfernung
11.000 m Teilstrecke
42.000 m Gesamtroute
1.300 m Gelände
6.500 ft Missionshöhe
```

Diese Werte waren nicht aus DCS-Fuelmessung oder Flugleistungsberechnung abgeleitet.

Folge:

Ein Test wurde wegen 1.438 m Überschreitung blockiert, obwohl daraus kein physischer Fehler bewiesen war.

Korrektur:

Heuristiken sind Warnungen/Telemetrie. Harte Fuel-Grenzen benötigen empirische Daten oder ein dokumentiertes Modell.

## 9. Taktische Phase: Readiness und Status

### INC-019 – OH-58D-Validator blockierte alle Aufträge

Befund:

Ein RECON-Fehler verhinderte auch AH-64D, UH-60 und CH-47.

Korrektur:

- globales Basisgate;
- auftragsspezifische Readiness;
- unabhängige Tests bleiben startbar.

### INC-020 – Falscher Blockgrund `mission-editor-objects-missing`

Befund:

Das Log meldete `ME_OBJECTS PASS`, während F10 dennoch `mission-editor-objects-missing` ausgab.

Ursache:

Konkreter Rückgabefehler wurde durch einen pauschalen String ersetzt.

Korrektur:

Der exakte Fehlergrund wird unverändert bis F10 und Log weitergereicht.

### INC-021 – Veraltetes Pending-Kriterium

Befund:

Beide OH-58D-Landungen wurden gezählt, dennoch blieb `landing-count-mismatch` sichtbar.

Korrektur:

Pending-Status wird aus dem aktuellen Zustand neu berechnet. Nach vollständiger Landung, aber vor Freigabe gilt `awaiting-inventory-release`.

## 10. Taktische Phase: UH-60

### INC-022 – TROOPTRANSPORT-Erfolg ohne Flug

Befund:

- UH-60 spawnte;
- kein Engine Start, Takeoff oder Landing;
- Infanterie bewegte sich;
- Ziel wurde dennoch bestätigt beziehungsweise Mission beendet.

Ursache:

Die Infanterieposition allein genügte als Erfolgsbedingung.

Korrektur:

Erforderlicher Lifecycle:

```text
Takeoff
Pickup beobachtet
Transport
Dropoff nach Pickup
RTB
Landing
Asset Release
```

### INC-023 – TROOPTRANSPORT und MEDEVAC sprachlich vermischt

Befund:

Der Single-Ship-UH-60-Transporttest wurde teilweise so behandelt, als prüfe er das vollständige MEDEVAC-Paket.

Korrektur:

```text
UH60_TROOP = Single-Ship-Transporttest
UH60_MEDEVAC = späterer Lead-/Guard-Paketmeilenstein
```

Guardrail:

Testname, Paketmodell und Abnahmekriterien müssen dieselbe fachliche Bedeutung besitzen.

## 11. Taktische Phase: CH-47

### INC-024 – Operationeller Erfolg, aber Controller-Fail

Befund:

CH-47 transportierte die Fracht korrekt, kehrte zurück und landete. Nach der physischen Zielerfüllung meldete MOOSE zusätzliche Terminalzustände, die der Controller als Fehler wertete.

Korrektur:

Physisches Ziel und MOOSE-Terminalstatus werden getrennt erfasst. Eine Normalisierung ist nur bei nachgewiesener Frachtzustellung zulässig.

Guardrail:

Weder „MOOSE sagt SUCCESS“ noch „Objekt liegt in der Zone“ genügt allein. Der vollständige, auftragsspezifische Lifecycle ist maßgeblich.

## 12. Hubschrauber-Taxi und Vertikalbetrieb

### INC-025 – unnötiges Rollen zur Startbahn

Befund:

Hubschrauber mit Fahrwerk rollten zur Startbahn; der CH-47 rollte teilweise die Bahn entlang, statt direkt vertikal zu starten.

Korrektur:

```lua
AIRWING:SetOptionPreferVerticalLanding()
```

Die gepinnte MOOSE-Version verwendet diese Option als Präferenz für vertikalen Start und vertikale Landung.

Guardrail:

Die Option ist eine Präferenz, keine Garantie. Das tatsächliche DCS-Verhalten muss visuell geprüft werden.

## 13. Codearchitektur und Korrekturschichten

### INC-026 – Wahrheit hing von Bundle-Reihenfolge ab

Befund:

Mehrere späte Dateien überschrieben Manifest, Factory, Observer und Controller:

```text
17-phase1-operational-safety.lua
18-phase1-readiness-and-recon-telemetry.lua
19-phase1-oh58-formation-recovery-counting.lua
19a-phase1-oh58-runtime-finalizer.lua
```

Folge:

- widersprüchliche Gruppenmodelle;
- alte Logtexte;
- unterschiedliche Inventarannahmen;
- schwer nachvollziehbare Laufzeitwirkung.

Korrektur:

Zentraler Paketvertrag und allgemeine paketabhängige Observer-/Lifecycle-Logik. Der spezielle Finalizer wurde entfernt.

Guardrail:

Keine weitere Architekturkorrektur durch eine zusätzliche späte Override-Datei. Grundlegende Werte werden konsolidiert.

## 14. Arbeitsgrenzen und unnötige Missionsdatei-Arbeit

### INC-027 – `.miz` ohne Auftrag erstellt beziehungsweise vorbereitet

Befund:

Der Assistent bereitete eigenständig eine neue Testmission beziehungsweise `.miz` vor, obwohl nur Lua-/Repository-Arbeit beauftragt war.

Auswirkung:

- mehr als 30 Minuten Verzögerung;
- unnötige Artefakte;
- Token- und Arbeitsaufwand;
- Abweichung vom etablierten Workflow.

Verbindliche Absprache:

```text
Assistent:
  Lua
  Builder
  GitHub-Dokumentation
  Commit
  Logauswertung

Projektinhaber:
  lokaler Pull
  lokaler Build
  DO SCRIPT FILE
  Missionseditor
  .miz
  DCS-Test
```

Jede Missionseditor-Anweisung beginnt mit der Entscheidung, ob die Mission unverändert bleibt, umbenannt wird oder noch nicht bearbeitet werden soll.

## 15. Ergebnis der Bereinigung

Kanonischer Paketvertrag:

```text
OH58D: 24 Luftfahrzeuge / 12 Asset-Gruppen / Grouping 2 / Auftrag 1x2
AH64D:  8 Luftfahrzeuge /  4 Asset-Gruppen / Grouping 2 / Auftrag 1x2
UH60:   8 Luftfahrzeuge /  8 Asset-Gruppen / Grouping 1
CH47:   8 Luftfahrzeuge /  8 Asset-Gruppen / Grouping 1 / Auftrag 1x1
```

Aktueller Status:

```text
Paketvertrag: IMPLEMENTED
statische Vertragsprüfung: implementiert
OH-58D neuer DCS-Test: ausstehend
AH-64D neuer DCS-Test: ausstehend
UH-60 neuer DCS-Test: ausstehend
CH-47 Regressionstest: ausstehend
Gesamtablauf: blockiert bis Einzeltests bestanden
weitere Flugplätze: blockiert bis Jalalabad funktional abgenommen
```

## 16. Was künftig vor jedem Fix beantwortet werden muss

1. Auf welcher Ebene liegt der Fehler?
2. Welche konkrete DCS-/Log-Beobachtung belegt ihn?
3. Ist es ein MOOSE-, DCS-AI-, Routing-, Paket-, Parking- oder Testcontroller-Problem?
4. Ändert der Fix unbeabsichtigt das taktische Paketmodell?
5. Wird eine Heuristik als Heuristik gekennzeichnet?
6. Gibt es eine zentrale Vertragsprüfung gegen die Wiederholung?
7. Kann der Fix in einem isolierten Test nachgewiesen werden?
8. Wird erst danach der Gesamtablauf freigegeben?

## 17. Verbindliche Schlussfolgerung

Die Hauptursache der vermeidbaren Probleme war das Vermischen von Ebenen und das anschließende Reparieren auf der falschen Ebene.

Die folgenden Aussagen sind deshalb dauerhaft verbindlich:

```text
Ein Template ist kein Static.
Ein Static ist kein AIRWING-Asset.
Ein Client ist kein KI-Asset.
Ein Flugzeugbestand ist keine Asset-Gruppenzahl.
Zwei Single-Ships sind kein physisches Two-Ship.
Ein Lifecycle-Fehler rechtfertigt keine Änderung der taktischen Formation.
Eine Heuristik ist kein Fuel-Modell.
Ein MOOSE-Terminalstatus ist nicht automatisch der physische Missionserfolg.
Ein Build-PASS ist kein DCS-PASS.
Der Assistent verändert keine .miz ohne ausdrücklichen Auftrag.
```
