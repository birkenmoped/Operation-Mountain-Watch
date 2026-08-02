---
document_id: OMW-HANDOFF-TEMPLATE-AIRFIELD-AIRWING-COMMANDER
status: BINDING
document_class: CHAT_HANDOFF_TEMPLATE
owning_policy: OMW-GOV-001
authoritative_for:
  - required content of a new airfield AIRWING/SQUADRON/COMMANDER chat handoff
  - mandatory initial review and response order
  - copy-paste kickoff prompt for the next airfield
not_authoritative_for:
  - base-specific ORBAT, names or technical decisions
  - merge or Ready-for-Review authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - ad-hoc next-airfield chat prompts without explicit gates
superseded_by:
source_branch: agent/normalize-salerno-air-orbat
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Vorlage – Neuer Flugplatzchat für AIRWING, SQUADRONs und COMMANDER

## Verwendung

Die Vorlage wird kopiert und vollständig ausgefüllt. Nicht bekannte Werte werden mit `OPEN` gekennzeichnet und nicht geraten.

Der neue Chat darf vor der Dokumentations- und Bestandsprüfung keinen Lua-Code erzeugen und keine Mission-Editor-Namen, Bestände, Parking-IDs oder MOOSE-Verträge erfinden.

---

## Direkt kopierbarer Startauftrag

````markdown
# Projektübernahme: Operation Mountain Watch – <FLUGPLATZ> AIRWING/SQUADRON/COMMANDER

Wir setzen die Entwicklung von **Operation Mountain Watch** mit dem Flugplatz beziehungsweise Luftfahrtknoten **<FLUGPLATZ>** fort.

Repository:

```text
birkenmoped/Operation-Mountain-Watch
```

Lokaler Pfad:

```text
P:\DCS-DEV\Operation-Mountain-Watch
```

Aktiver beziehungsweise vorgesehener Entwicklungsbranch:

```text
<BRANCH_ODER_OPEN>
```

Basisbranch und Abhängigkeit:

```text
Base branch: <BASE_BRANCH>
Base commit: <BASE_COMMIT_ODER_OPEN>
Abhängige PRs/Branches: <LISTE_ODER_NONE>
```

Aktuelle Missionsdatei:

```text
<MISSION_DATEINAME>
SHA-256: <MISSION_SHA256_ODER_OPEN>
```

Ziel dieses Arbeitsstrangs:

```text
<FLUGPLATZ> als reproduzierbaren MOOSE-Grundknoten vorbereiten und validieren:
AIRBASE/Warehouse -> AIRWING -> SQUADRONs -> Capabilities/Payloads
-> isolierter direkter Dispatch -> isolierter COMMANDER-Dispatch.
```

## Verbindliche Arbeitsweise

Bevor du Vorschläge machst, Code änderst oder Mission-Editor-Arbeiten anweist, prüfe vollständig:

```text
docs/00-project-governance.md
docs/DOCUMENT-METADATA-POLICY.md
docs/DOCUMENT-REGISTRY.md
docs/SUBPROJECT-REGISTRY.md
docs/18-air-operations-implementation.md
docs/19-active-air-orbat-decisions.md
docs/20-air-orbat-mission-editor-worklist.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/26-moose-first-development-policy.md
docs/38-mission-editor-master-worklist.md
docs/airfield-airwing-squadron-commander-implementation-workflow.md
docs/moose/VERSION-AND-SOURCES.md
docs/moose/AIR-OPERATIONS.md
docs/moose/EVENTS-AND-FSM.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
```

Zusätzlich vollständig prüfen:

```text
<FLUGPLATZ_MANIFEST_ODER_OPEN>
<ORBAT_ENTSCHEIDUNGEN>
<MISSION_EDITOR_AUDITS>
<PAYLOAD_LOADOUT_ENTSCHEIDUNGEN>
<RELEVANTE_EVIDENZDOKUMENTE>
<RELEVANTE_HANDOFFS>
<RELEVANTE_OFFENE_BRANCHES_UND_PRS>
```

Verwende Jalalabad, Bagram, Kandahar und Salerno nur als technische Referenzen. Übernimm keine Bestände, Namen, Parking-IDs, Templategrößen, Payloads oder lokalen Sonderregeln ungeprüft.

## MOOSE-first

Verbindlich:

1. passende MOOSE-Dokumentation prüfen;
2. den exakten Quellcode der tatsächlich eingebetteten MOOSE-Version prüfen;
3. offizielle MOOSE-Demos/Testmissionen prüfen;
4. vorhandene OMW-Referenzimplementierungen prüfen;
5. erst danach eigene Lua-Ergänzungen entwickeln.

Tatsächlich eingebetteter MOOSE-Stand:

```text
MOOSE commit: <MOOSE_COMMIT_ODER_OPEN>
Moose.lua SHA-256: <MOOSE_SHA256_ODER_OPEN>
DCS version: <DCS_VERSION_ODER_OPEN>
```

Keine Änderung an `Moose.lua`.

## Aktuell bekannte Flugplatzdaten

```yaml
historical_name: <WERT_ODER_OPEN>
dcs_airbase_name: <WERT_ODER_OPEN>
moose_airbase_enum: <WERT_ODER_OPEN>
airdrome_id: <WERT_ODER_TO_BE_MEASURED>
warehouse_anchor: <WERT_ODER_OPEN>
active_orbat: <WERT_ODER_OPEN>
logical_inventory: <WERT_ODER_OPEN>
clients: <WERT_ODER_OPEN>
ai_templates: <WERT_ODER_OPEN>
statics: <WERT_ODER_OPEN>
zones: <WERT_ODER_OPEN>
parking_status: <UNTESTED|CALIBRATION_AVAILABLE|DEFERRED|ACCEPTED>
```

Bereits vorbereitete Mission-Editor-Objekte:

```text
<LISTE_ODER_NONE>
```

Bereits existierende AIRWING-/SQUADRON-Namen:

```text
<LISTE_ODER_NONE>
```

## Verbindliche Testtrennung

- Read-only-Diagnose vor jeder Mutation.
- Parking-Kalibrierung getrennt von operativer Parking-Acceptance.
- Ein Dispatchpfad pro Acceptance-Lauf.
- Ein erwarteter Missionstyp und Aircrafttyp pro Auswahltest.
- Direkter AIRWING-Dispatch und COMMANDER-Dispatch niemals parallel.
- `planned` und `unknown` gelten nicht als Fortschritt.
- Interne Tabellenkonsistenz beweist keine tatsächliche DCS-Spawnposition.
- Jede Runtime-Unit einer Multi-Unit-Gruppe wird separat bewertet.
- FAIL-, PARTIAL- und INVALID-Läufe werden dauerhaft dokumentiert.

Parking darf bei mangelnder Zuverlässigkeit `DEFERRED` werden, ohne den sauber abgegrenzten AIRWING-/SQUADRON-/COMMANDER-Grundknoten zu blockieren.

## Erwartete Repository-Artefakte

```text
docs/<FLUGPLATZ>-air-operations-manifest.md
docs/evidence/<flugplatz>-air-operations-*.md
docs/handoffs/<datum>-<flugplatz>-current-state-and-next-step-handoff.md

mission/tests/<flugplatz>-air-operations/
├── README.md
├── calibration/
├── expected/
├── results/
└── src/

tools/build-<flugplatz>-air-operations-bundle.ps1
```

## Erwartete Arbeitsphasen

```text
G0 Repository-/Branch-/Missionsbaseline
G1 Dokumentations-, ORBAT- und Evidenzprüfung
G2 Manifest und vollständiger Objektvertrag
G3 Mission-Editor-Grundaufbau
G4 MOOSE-first-Quellenprüfung
G5 Read-only-Diagnose
G6 Parking-Kalibrierung oder NOT_APPLICABLE
G7 AIRWING/SQUADRON/Capability/Payload-Grundknoten
G8 isolierter direkter Dispatch
G9 isolierter COMMANDER-Dispatch
separate operative Parking-Acceptance oder DEFERRED
G10 Provenienz, Ergebnisberichte, Dokumentation und Handoff
```

## Erste Antwort des neuen Chats

Die erste Antwort darf noch keinen Implementierungscode enthalten. Sie muss liefern:

1. geprüfte `main`- und Branch-Dokumente;
2. aktuelle Branch-/PR-Abhängigkeiten;
3. aktuelle ORBAT- und Mission-Editor-Bestandsaufnahme;
4. bereits festgelegte Namen und Mengen;
5. Widersprüche, Nachweislücken und offene Entscheidungen;
6. MOOSE-Klassen, Methoden, Quellcodedateien und Demos, die geprüft werden müssen;
7. eine phasenweise To-do-Liste gemäß G0 bis G10;
8. den genau einen nächsten zulässigen Arbeitsschritt.

Keine Behauptung über vorhandene Objekte, Parking-IDs, Bestände oder MOOSE-Funktionalität ohne Dokument- oder Runtime-Nachweis.

## Git- und PR-Regeln

```text
Kein Merge ohne ausdrückliche Freigabe des Projektinhabers.
Kein Ready-for-Review ohne ausdrückliche Freigabe.
Keine Force-Pushes oder Hard-Resets ohne ausdrückliche Freigabe.
Keine lokalen Änderungen verwerfen.
Keine generierten dist-Dateien manuell bearbeiten.
```

Nach jeder ausführbaren Code- oder Builderänderung muss die Übergabe den vollständigen lokalen Pull-, Build-, Mission-Editor- und Testblock aus Dokument 22 enthalten.
````

---

## Ausfüllkontrolle vor dem Absenden

```text
[ ] Flugplatz und Zielscope eindeutig
[ ] Repository, Branch und Basisbranch angegeben
[ ] Mission und Hash angegeben oder als OPEN markiert
[ ] relevante Dokumente und Branches benannt
[ ] MOOSE-Provenienz angegeben oder als OPEN markiert
[ ] bekannte ORBAT- und ME-Daten eingetragen
[ ] unbekannte Werte nicht geraten
[ ] Testtrennung ausdrücklich enthalten
[ ] G0–G10 enthalten
[ ] Merge-/Ready-Sperre enthalten
[ ] erste Antwort auf Bestandsaufnahme begrenzt
```

## Minimale Übergabe aus dem vorherigen Flugplatz

Der vorherige Arbeitsstrang muss zusätzlich bereitstellen:

```yaml
previous_airfield:
accepted_branch:
accepted_commit:
accepted_builder_version:
accepted_bundle_sha256:
accepted_mission:
accepted_mission_sha256:
dcs_version:
moose_commit:
moose_sha256:
accepted_scope:
deferred_scope:
reusable_lessons:
known_nontransferable_local_rules:
```

Damit wird verhindert, dass lokale Parking-, Bestands- oder Namensregeln des vorherigen Flugplatzes unbemerkt auf den neuen Knoten übertragen werden.
