---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-HANDOFF
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - current branch Gate 0-5 handoff status and evidence map
  - continuation order after Gate 5 Acceptance 2
not_authoritative_for:
  - overriding project governance or BINDING baselines
  - claiming DCS validation beyond cited exact scopes
  - creating new gate numbers or architecture decisions without owner approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Fire Support / Strategic Resupply – Gate 5 Handoff

## 1. Zweck

Dieses Dokument ist die vollständige Übergabe des aktuellen Arbeitsstandes für den Branch

```text
agent/fire-support-strategic-resupply-base-gate0
```

zum Zeitpunkt von Gate 5 / Acceptance 2. Es übergibt:

- die verbindlichen Arbeitsanweisungen und Autoritätsregeln;
- das Projektcredo **MOOSE first**;
- die abgeschlossenen Gates 0 bis 4;
- den aktuellen Gate-5-Stand einschließlich Fehlerkorrekturen und DCS-Evidenz;
- den nächsten offenen DCS-Test;
- die danach noch offenen Arbeitsbereiche;
- die vollständige relevante Dokumentations-, Evidence- und Source-Lesereihenfolge.

Dieses Handoff ist **keine neue Governance**. Bei Widerspruch gelten ausschließlich die Autoritätshierarchie und die aktuellen `BINDING`-Dokumente aus `docs/00-project-governance.md`.

---

## 2. Zwingende Arbeitsanweisungen – „Gesetze“

Ein Folge-Chat muss vor jeder relevanten Arbeit mindestens lesen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

Danach sind die jeweils aktuellen Fach-, Ground-, MOOSE-, Acceptance-, Result- und Manifest-Dokumente heranzuziehen.

Verbindlich gelten insbesondere:

1. **Governance vor Implementierung.** Alte Tests, Handovers, Branch-Notizen oder frühere Annahmen überschreiben keine aktuelle Governance-/`BINDING`-Baseline.
2. **Nicht raten.** Keine MOOSE-Klasse, Methode, Signatur, Rückgabe, FSM, DCS-API-Eigenschaft, Mission-Editor-Funktion, Commit-ID, Hash oder Testergebnis erfinden.
3. **Nur exakter Scope gilt.** Ein DCS-PASS gilt nur für den dokumentierten Branch-, Commit-, Missions-, Bundle-, DCS- und MOOSE-Stand.
4. **`VALIDATED` nur nach dokumentiertem DCS-Test.** Source Review, CI und lokale Builds sind keine DCS-Laufzeitvalidierung.
5. **Keine doppelte Ressourcenhoheit.** `CampaignState`, MOOSE Warehouse/STORAGE und DCS Warehouses dürfen nicht dieselbe Ressource unabhängig autoritativ führen.
6. **DCS-/MOOSE-Adapter von Kampagnenlogik trennen.** Physische Gruppen sind temporäre Repräsentationen, nicht automatisch strategische Wahrheit.
7. **Ground AI ist unzuverlässig.** Owner-authored/validierte Routen, Anchors, Sammel- und Rückzugspunkte verwenden; keine unbegründeten sichtbaren Teleports.
8. **Kein MIST ohne genehmigte Ausnahme.**
9. **`MissionScripting.lua` nicht automatisch ändern.**
10. **Keine CODEX-Übergabe.** ChatGPT prüft, implementiert, dokumentiert, committed und veröffentlicht selbst; der Projektinhaber führt nur die ausdrücklich angeforderten lokalen PowerShell-/Build-/DCS-Schritte aus.
11. **Projektinhaber entscheidet Architektur-Ausnahmen.** Notwendige private MOOSE-/Native-DCS-/Parallelimplementierungen dürfen nicht stillschweigend beschlossen werden.
12. **Nur main ist projektweit autoritativ.** Branch-`BINDING_PROJECT_DECISION` wird erst durch Merge projektweit wirksam.
13. **PR bleibt Draft, bis der Projektinhaber ausdrücklich Ready/Merge freigibt.**
14. **MIZ-Arbeit bleibt beim Projektinhaber.** ChatGPT editiert keine `.miz`.
15. **Lokales Tooling beachten.** Auf der Owner-Workstation steht kein `lua`/`luac` zur Verfügung. Builds erfolgen über versionierte PowerShell-Builder. Direkte `.ps1`-Ausführung kann an der Execution Policy scheitern; der funktionierende Aufruf erfolgt über Windows PowerShell mit `-ExecutionPolicy Bypass -File`. `$LASTEXITCODE` allein erkennt PowerShell-Parser-/CommandNotFound-/Policy-Fehler nicht zuverlässig; Ausgabe-Artefakte müssen zusätzlich geprüft werden.
16. **Dokumentation sofort, aber keine Dokumentations-Endlosschleife.** Sachliche Entscheidungen, Owner-Korrekturen, falsche Annahmen, neue Evidenz und Runtime-Ergebnisse werden im selben Arbeitsstrom dokumentiert. Reine Dokumentationscommits erzeugen aber keinen eigenen Pull-/Hash-Readback-Zyklus.

Sprachregel:

```text
Code / identifiers / logs / commit messages: English
Design-Dokumentation: Deutsch
Spielertexte: DE/EN soweit praktikabel
```

Aktuelle Projektphase:

```text
COMPLETE_FOUNDATION_BUILD_PHASE
```

Historischer Kampagnenrahmen:

```text
01.08.2010–31.12.2011
```

---

## 3. Projektcredo: MOOSE first

**MOOSE first ist verbindlich und kein optionaler Stil.**

Vor eigener Lua-Logik ist immer in dieser Reihenfolge zu prüfen:

```text
passende MOOSE-Dokumentation
-> tatsächlich verwendete / gepinnte Moose.lua
-> exakte Signaturen, Rückgaben, Events, FSMs und Voraussetzungen
-> offizielle MOOSE-Demos/Tests, soweit relevant
```

Implementierungspriorität:

```text
MOOSE direkt
-> vorhandene MOOSE-Funktion konfigurieren / kombinieren
-> MOOSE Events / Callbacks / FSMs
-> kleinster notwendiger Adapter
-> eigene/native DCS-Lösung nur nach dokumentierter Lückenprüfung und Owner-Freigabe
```

Es ist ausdrücklich verboten, vorhandene MOOSE-Funktionalität parallel neu zu implementieren, nur weil eine Eigenlösung vermeintlich einfacher erscheint.

Für diesen Workstream gilt zusätzlich:

```text
fachlicher Bedarf / MissionDemand / Incident
-> MOOSE-Organisation und öffentlicher MOOSE-Auftrag bzw. Transport
-> MOOSE selektiert und rekrutiert operative Assets
-> MOOSE/DCS führt physischen Lifecycle aus
-> bestätigtes physisches Lifecycle-Ereignis
-> idempotente strategische Buchung CampaignState
```

---

## 4. Branch / PR / Baseline

```text
Repository: birkenmoped/Operation-Mountain-Watch
Main baseline: 980340c9225a81921aed8995aa8f50cad7d1c215
Branch: agent/fire-support-strategic-resupply-base-gate0
PR: #149
PR state: Draft
```

Der Branch darf nicht ohne ausdrückliche Owner-Freigabe Ready gesetzt oder gemerged werden.

Wichtige aktuelle Stände:

```text
Owner-local functional Acceptance-2 build HEAD:
e5b1a79e5bdb6e9ba4479ebc9e35d76ba5dddab2

Remote documentation head immediately before this handoff:
01ba66a3ec1ebfe76b0ae0230f68c183cd96bc8a
```

Der Unterschied ist reine Dokumentation der bereits gelieferten Build-Evidenz und rechtfertigt keinen separaten lokalen Readback-Zyklus.

---

## 5. Gate 0 – Ressourcen-/Autoritätsentscheidung

**Status: abgeschlossen für den Branch-Architekturscope.**

Verbindliche Owner-Entscheidung:

```text
MOOSE owns operational asset selection and warehouse recruitment.
CampaignState does not preselect operational assets.
CampaignState owns strategic persistence, ownership, entitlements,
campaign-level state and resources not authoritatively represented by MOOSE/DCS.
Confirmed MOOSE/DCS lifecycle events are settled into CampaignState idempotently.
No resource may have two independent authorities.
```

Dokument:

```text
docs/adr/0008-fire-support-strategic-resupply-resource-authority.md
```

ADR-Status:

```text
BINDING_PROJECT_DECISION
PENDING_MERGE
validated_in_dcs: false
```

Wichtig: Diese Entscheidung ist auf dem Arbeitsbranch bindend, aber erst nach Merge projektweit bindend.

---

## 6. Gate 1 – MOOSE Gap Analysis

**Status: `COMPLETE_SOURCE_REVIEWED`.**

Dokument:

```text
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-1-MOOSE-GAP-ANALYSIS.md
```

Gepinnter MOOSE-Stand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Wesentliche Ergebnisse:

- `CHIEF` für diese Architektur verworfen;
- `COMMANDER` als MOOSE-Aggregator;
- Guard über Ground-`AUFTRAG`;
- QRF bleibt semantische lokale Reaktionsrolle;
- ARTY über vorhandene MOOSE-Ground-/Artilleriepfade;
- generische CAS-Anforderung über `COMMANDER`/`AIRWING`-Organisationen;
- physischer Nachschub über passende MOOSE-Mission/`OPSTRANSPORT`/`STORAGE`-Pfade, abhängig von der festgelegten Ressourcenautorität;
- Stage-1D-P-Air-Resupply ist historische, exakt begrenzte Evidenz und keine generische Multi-AIRWING-Freigabe;
- im Gate-1-Scope wurde **keine MOOSE-Lücke festgestellt, die bereits eine Nicht-MOOSE-Ausnahme erfordert**.

Source-seitig geprüft wurden unter anderem:

```text
COMMANDER:AddMission(...)
COMMANDER:AddOpsTransport(...)
COMMANDER:CheckMissionQueue()
AUFTRAG Cancel lifecycle
OPSTRANSPORT:SetTime(...)
OPSTRANSPORT:AddConditionStart(...)
OPSTRANSPORT:Cancel(...)
```

Gate 1 ist Source Review, keine allgemeine DCS-Validierung.

---

## 7. Gate 2 – Pure-Lua Daten- und Vertragsbasis

**Status: abgeschlossen für den Pure-Lua-/Contract-Scope.**

Relevante Dateien:

```text
scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua
scripts/campaign/OMW_FireSupStratResupply_SupportProfiles.lua
tests/mission-demand/test_fire_support_strategic_resupply_gate2.lua
```

Der Six-Site-Vertrag umfasst:

```text
JALALABAD_FENTY
COP_FORTRESS
FOB_JOYCE
FOB_WRIGHT
COP_HONAKER
FOB_BOSTICK
```

Stable installation IDs:

```text
BLUE_GROUND_HUB_JALALABAD_FENTY
BLUE_GROUND_COP_FORTRESS
BLUE_GROUND_FOB_JOYCE
BLUE_GROUND_FOB_WRIGHT
BLUE_GROUND_COP_HONAKER_MIRACLE
BLUE_GROUND_FOB_BOSTICK
```

Wichtig: Frühere falsche Gate-5-Annahmen über notwendige Mission-Editor-Alarmzonen wurden aus Registry und Gate-2-Tests entfernt. Gate 2 wählt keine operativen Assets vor.

Gate 2 ist **nicht** DCS-validiert; es ist der geprüfte Pure-Lua-/Contract-Scope.

---

## 8. Gate 3 – Generischer Coordinator/Base

**Status: abgeschlossen für den generischen Coordinator-Vertrag.**

Datei:

```text
scripts/campaign/OMW_FireSupStratResupply_Base.lua
```

Aktueller Vertrag, Schema 3:

- Coordinator only;
- keine eigene Assetselektion;
- keine zweite Retry Queue;
- kein eigener strategischer Stock;
- `StartSite(...)` erzeugt persistenten Guard-Bedarf;
- `OpenIncident(...)` erzeugt Incident-Kontext, nicht automatisch Unterstützung;
- `RequestIncidentSupport(...)` nur QRF / ARTY / CAS;
- `RequestResupply(...)` nur Ground/Air mit `requestKey`, Ressource und Menge; keine Threshold-Auswertung im Base;
- `CloseIncident(...)` beendet nur Incident-Demands, nicht persistenten Guard und nicht unabhängigen Resupply-Bedarf.

Die Sollarchitektur lautet:

```text
normal site operation
├ Guard persistent
├ resource monitor independent -> threshold -> RESUPPLY
└ threat in local alarm/perimeter
  ├ local defense: QRF + local mortars/ARTY if configured
  └ C2 escalation criterion -> external ARTY + CAS
```

und:

```text
Site Runtime
├ Local Security
│ ├ Guard persistent / normal operations
│ ├ QRF incident-driven local defense
│ └ Local Fires incident-driven if configured
├ C2 Support
│ ├ External ARTY escalation/perimeter-driven
│ └ CAS escalation/perimeter-driven
└ Logistics
  └ Resupply threshold-driven only
```

Gate 3 ist kein Six-Site-DCS-Acceptance-PASS.

---

## 9. Verbindliche Alarm-/Perimeter-Semantik

Aus Governance und Ground-Entscheidungen gilt:

```text
FOB / COP / OP alarm zone
= threat-detection and response-trigger boundary
!= tactical battlespace
!= weapons engagement zone
!= fire-support target area
!= CAS engagement area
!= mission-end condition
```

Folge:

```text
enemy enters perimeter
-> incident / alarm state
-> lokale Reaktion + ggf. C2-Eskalation
-> Unterstützungsmissionen laufen nach ihren eigenen Completion-Kriterien
```

Das Verlassen des Perimeters darf ARTY/CAS/QRF **nicht automatisch abbrechen**.

Ganz wichtig: „Alarm zone“ bedeutet hier **keine Mission-Editor Trigger Zone**.

Der vorhandene Adapter:

```text
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
```

erzeugt den Perimeter zur Laufzeit als:

```text
installation anchor + radius
-> MOOSE ZONE_RADIUS
-> MOOSE OPSZONE
```

Es werden daher **keine** `ZON_BLUE_GND_*_ALARM`-Objekte in der `.miz` benötigt.

---

## 10. Gate 4 – Historische Stage-3-Regression

**Status: realer DCS-PASS im exakt dokumentierten historischen Scope; kein generischer Six-Site-PASS.**

Dokument:

```text
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-4-STAGE3-REGRESSION-PLAN.md
```

Historisch praktisch nachgewiesen wurden unter anderem:

- Guard bereits vor Angriff aktiv;
- MOOSE-`OPSZONE` erkennt Bedrohung;
- QRF wird ausgelöst;
- externe ARTY erst nach C2-Zielbild;
- Wright-Rearm;
- Resupply;
- CAS mit eigener Detection/Route;
- AIRWING Asset Return Settlement;
- `OPSTRANSPORT` Delivery Settlement.

Reale PASS-Zeile:

```text
[STAGE 3][PASS] Honaker full response complete: Guard/QRF + supported-element CAS release + 28 live Wright fire missions + M1083 rearm + CH-47 OPSTRANSPORT ... + Wright 30/30
```

Finale dokumentierte Runtime-Elemente umfassten:

```text
WrightAmmo=30
JalalabadAmmo=85
perimeterClear=true
threatStopped=true
qrfReturned=true
casOnStation=true
casFired=false
casNoContact=true
```

Referenzstände:

```text
Historical MIZ: OMW_Template_v22_GroundWorks(8).miz
SHA-256: 25387ABB697E9D500F243EF5D2220459EC6AA711712DB57F126DDF7C7D47E0FA

Stage3 reference bundle SHA-256:
33CEB7AA6BC7FA833CCF456C41B689245B0CB70BD587AF533D0071A92B346661
```

Die v23-GroundWorks-Basis wurde später vom Projektinhaber manuell im Mission Editor erstellt. ChatGPT verändert `.miz` nicht.

Dokumentationsschuld: Der formale Gate-4-Plan kann gegenüber der später gelieferten realen PASS-Evidenz noch veraltete Statusformulierungen enthalten. Das ist bei nächster sinnvoller fachlicher Dokumentationsrunde zu korrigieren, ohne den exakten historischen Scope zu überdehnen.

---

## 11. Ground Foundation – verbindliche Six-Site-Basis

Operative Domains:

```text
Jalalabad / FOB Fenty
COP Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick
```

ACCESS-Zonen:

```text
ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS
```

Alle sechs owner-authored Guard-PATHLINEs sind in der geprüften GroundWorks-Mission vorhanden:

```text
OMW_RTE_BLUE_GUARD_FENTY_01
OMW_RTE_BLUE_GUARD_FORTRESS_01
OMW_RTE_BLUE_GUARD_JOYCE_01
OMW_RTE_BLUE_GUARD_WRIGHT_01
OMW_RTE_BLUE_GUARD_HONAKER_01
OMW_RTE_BLUE_GUARD_BOSTICK_01
```

Ground-Entscheidung für Guard:

```text
Guard = permanente lokale first security
Guard = aktive Patrouille, nicht statisch
owner-authored Mission Editor Guard route bevorzugt
free-patrol zone nur Fallback
```

---

## 12. Gate 5 – Korrektur der falschen ME-Annahmen

**Status: Korrektur abgeschlossen und dokumentiert.**

Gate-5-Vertrag:

```text
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-5-SIX-SITE-ME-CONTRACT.md
```

Frühere falsche Annahmen des Assistenten:

1. Die sechs Guard-PATHLINEs müssten vom Projektinhaber noch erstellt werden.
2. Es müssten sechs `ZON_BLUE_GND_*_ALARM` Mission-Editor-Zonen erstellt werden.

Owner-Korrektur und anschließende Prüfung ergaben:

```text
6/6 Guard PATHLINEs bereits vorhanden
0 Mission-Editor Alarmzonen erforderlich
Alarm-/Threat-Perimeter entsteht zur Laufzeit über ZONE_RADIUS + OPSZONE
```

Anti-Regression-Regel für jeden Folge-Chat:

```text
aktuelle Ground-Baseline
-> aktuelle tatsächliche MIZ read-only prüfen
-> vorhandenen Runtime-Code prüfen
-> erst danach ein Mission-Editor-Objekt als fehlend erklären
```

Diese Fehler dürfen nicht wiederholt werden.

---

## 13. Gate 5 – Acceptance 1

Source:

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/src/01-six-site-guard-runtime-acceptance.lua
```

Builder:

```text
tools/build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1
```

Output:

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/dist/OMW_FireSupStratResupply_Gate5_Six_Site_Guard_Runtime.lua
```

Acceptance 1 prüfte:

```text
6 Sites
-> je 1 BRIGADE
-> je 1 PLATOON / Guard-Gruppe
-> vorhandene ACCESS-Zone
-> vorhandene Guard-PATHLINE
-> MOOSE AUFTRAG ONGUARD
-> physische Materialisierung
-> Route auf owner-authored PATHLINE
-> 300 Sekunden Beobachtung
-> mindestens 25 m Bewegung je Guard
```

Ergebnis:

- Six-Site-Plumbing funktionierte grundsätzlich;
- alle sechs Guard-Aufträge/PATHLINEs konnten im getesteten Ablauf verarbeitet werden;
- reale DCS-Läufe zeigten jedoch standortabhängig praktisch keine Bewegung einzelner Gruppen;
- ein Lauf zeigte Fenty mit `0.0 m`, ein anderer Fortress mit ungefähr `0.3 m`, obwohl Gruppe alive und Route gestartet war.

Dokument:

```text
results/2026-09-12-gate5-acceptance1-runtime-findings.md
```

Interpretation im aktuellen Scope:

```text
kein genereller Six-Site-/PATHLINE-Auflösungsfehler nachgewiesen
aber Materialisierung/Formation in dichter HESCO-/Gebäude-/Static-Geometrie noch nicht robust genug
```

Der Projektinhaber legte daraufhin verbindlich fest, dass Guard-Gruppen kompakt und auf die Route ausgerichtet materialisiert werden sollen, ähnlich dem praktisch bewährten Convoy-Prinzip.

---

## 14. Gate 5 – Acceptance 2: aktueller Stand

**Status: BUILD PASS / CI PASS / DCS-RUNTIME-TEST AUSSTEHEND.**

Acceptance-Dokument:

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/ACCEPTANCE-2.md
```

MOOSE Technical Note:

```text
docs/moose/GATE5-GUARD-COMPACT-ALIGNED-MATERIALIZATION.md
```

Source:

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/src/02-six-site-guard-compact-aligned-acceptance.lua
```

MOOSE-first source-reviewt:

```text
PATHLINE:GetCoordinates()
COORDINATE:WaypointGround(speed, formation)
CONTROLLABLE:OptionFormationInterval(meters)
CONTROLLABLE:TaskFunction(...)
CONTROLLABLE:SetTaskWaypoint(...)
CONTROLLABLE:Route(...)
```

Materialisierungsvertrag:

```text
bestehende ACCESS-Zone
+ bestehende OMW_RTE_BLUE_GUARD_<SITE>_01
+ TPL_BLUE_GND_INF_RIFLE_SQUAD_9
-> 1 BRIGADE / 1 PLATOON / 1 ONGUARD-Auftrag
```

Spawn-Geometrie:

```text
Basis: erstes Segment der vorhandenen Guard-PATHLINE
9 Infanteristen als schmale Linie entlang dieses Segments
Zielabstand: 2 m
bei kurzem ersten Segment automatisch reduziert
Test-Mindestabstand: 0,75 m
alle Einheiten mit identischem Heading Punkt 1 -> Punkt 2
jeder vorbereitete Spawnpunkt innerhalb der bestehenden ACCESS-Zone
keine neue ME-Zone
keine MIZ-Mutation
```

Nach Materialisierung:

```text
Formation: Off Road
MOOSE OptionFormationInterval: 2 m
Speed: 5 km/h
Route: vorhandene Guard-PATHLINE
```

`On Road` wird bewusst nicht benutzt, weil die owner-authored Guard-PATHLINE und nicht das DCS-Straßennetz die Führung vorgibt.

### 14.1 Private Warehouse-Spawn-Ausnahme

Der gepinnte öffentliche MOOSE-Warehouse-Pfad bietet keinen Parameter für die gewünschte exakte, kompakte 9-Mann-Ausrichtung auf dem ersten Guard-PATHLINE-Segment.

Acceptance 2 verwendet deshalb **ausschließlich im Testscope** dasselbe bereits am 19.08.2026 vom Projektinhaber genehmigte und in ARMY Ground Acceptance 3-2 praktisch erprobte Adaptermuster:

```text
MOOSE BRIGADE / WAREHOUSE Lifecycle bleibt erhalten
-> vorbereitete absolute Spawnpositionen / Headings
-> private Warehouse-Materialisierungsstelle wird im Testscope adaptiert
```

Diese Nutzung ist `INTERNAL_RESTRICTED` und **keine produktive Generalfreigabe**.

### 14.2 Reale Owner-Build-Evidenz

```text
Functional local HEAD:
e5b1a79e5bdb6e9ba4479ebc9e35d76ba5dddab2

BuilderVersion:
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-2

TestId:
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

Formation:
Off Road

FormationIntervalM:
2

SpawnAlignment:
PATHLINE_FIRST_SEGMENT

Bundle SHA-256:
D30E63BFFCC506EB579FAE3AF662D6EED8C2C0D06DD5F57C0F22C12BA026390C

Acceptance-2 source SHA-256:
1BF6A18992355B150CF2C5507636497141A3C2A9BBDF771D8E447D61C77AE9F5

Builder SHA-256:
50001FC4DCC1976F024F29CC88B5BDA6BF3B0C18528763C26345ADCB178E7846

Encoding:
UTF-8 without BOM

MIZ mutation:
false
```

CI für exakt den funktionalen Head `e5b1a79...`:

```text
Documentation validation: PASS
MissionDemand validation: PASS
```

### 14.3 Nächster Schritt

Der nächste Schritt ist **kein weiterer Dokumentations-Readback**, sondern der bereits gebaute DCS-Test.

Zu testen:

```text
6/6 Guards materialisieren kompakt und PATHLINE-ausgerichtet
6/6 Guards leben
6/6 Routen starten
6/6 Gruppen bewegen sich in 300 s mindestens 25 m
visuell keine Soldaten beim Spawn/Anlaufen in HESCOs, Gebäuden oder Statics festgefahren
Formation ausreichend kompakt
```

Für diesen Test keine Honaker-Angreifer in Wirkreichweite lassen; Acceptance 2 enthält bewusst keinen Alarm-/QRF-/ARTY-/CAS-Stimulus.

Gate 5 darf erst nach realer DCS-Ausgabe des Projektinhabers als entsprechend akzeptiert bewertet werden.

---

## 15. Noch offene Arbeitsbereiche nach Gate 5

Die aktuell geprüfte Branch-Dokumentation definiert keinen belastbaren, autoritativen nummerierten „Gate 6+“-Vertrag. Deshalb dürfen Folge-Chats **keine Gate-Nummern erfinden**.

Nach erfolgreichem Gate-5-Abschluss sind fachlich noch mindestens folgende Bereiche offen; ihre endgültige Nummerierung/Struktur entscheidet der Projektinhaber beziehungsweise eine vorhandene, später aufgefundene autoritative Baseline:

1. **Acceptance-2-DCS-Runtime abschließen.** Reale Logs + visuelle Owner-Beobachtung auswerten und exakt dokumentieren.
2. **Produktionsentscheidung zur Guard-Materialisierung.** Nach PASS prüfen, ob der kompakt/aligned Adapter als eng begrenztes Produktionsmuster genehmigt wird oder ob ein öffentlicher MOOSE-Weg gefunden/erforderlich wird. Keine stillschweigende Generalisierung der privaten Warehouse-Methode.
3. **Generische Runtime-Perimeter-Integration.** Bestehenden `OMW_FobThreatOpsZoneAdapter.lua` verwenden; `ZONE_RADIUS + OPSZONE`, keine ME-Alarmzonen.
4. **Generische Six-Site Incident Response.** Lokale QRF, lokale Fires nur wo konfiguriert, externe ARTY/CAS erst nach Eskalationskriterium. Verlassen des Alarmperimeters beendet Unterstützungsaufträge nicht automatisch.
5. **Resupply unabhängig vom Incident.** Threshold-/Ressourcen-getrieben, MOOSE/DCS-Ressourcenautorität respektieren; CampaignState nur idempotent aus bestätigtem Lifecycle buchen.
6. **Kombinierte Six-Site Regression.** Ground-AI-Pathfinding, Warehouse-/Return-/Delivery-Lifecycle, Parallelität und Multiplayer-relevante Effekte testen.
7. **Gate-4-Dokumentationsschuld bereinigen.** Formales Gate-4-Dokument mit der tatsächlich vorhandenen historischen DCS-PASS-Evidenz synchronisieren, ohne den Scope zu erweitern.
8. **PR-Abschluss erst nach Owner-Freigabe.** PR #149 bleibt bis dahin Draft; Ready/Merge nicht selbständig ausführen.

---

## 16. Vollständige Übergabe – Pflicht-Lesereihenfolge

### A. Gesetze / Governance – zuerst lesen

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

### B. Autorität / Ground Foundation / MOOSE-Baseline

```text
docs/adr/0008-fire-support-strategic-resupply-resource-authority.md
docs/11-bases-and-fobs.md
docs/ground/ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION.md
docs/ground/ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION.md
docs/ground/ARMY-GROUND-PRODUCTION-BASE.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/GROUND-OPERATIONS.md
docs/moose/VERIFIED-METHODS.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-1-MOOSE-GAP-ANALYSIS.md
```

### C. Gate-/Acceptance-Dokumente

```text
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-4-STAGE3-REGRESSION-PLAN.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-5-SIX-SITE-ME-CONTRACT.md
docs/moose/GATE5-GUARD-COMPACT-ALIGNED-MATERIALIZATION.md
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/ACCEPTANCE-1.md
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/ACCEPTANCE-2.md
```

### D. Evidence / Results

```text
results/2026-09-12-fire-support-gate5-correction-local-verification.md
results/2026-09-12-gate5-acceptance1-runtime-findings.md
results/2026-09-12-gate5-lua-pasted-into-powershell-correction.md
mission/tests/stage3-honaker-wright-full-response/
mission/tests/fire-support-strategic-resupply-gate4-stage3-regression/
```

Die Stage-3-Verzeichnisse enthalten den historischen Regressionstest und die dazugehörige exakte Evidence-Basis. Keine historische Evidence darf als generische Six-Site-Produktionsvalidierung umgedeutet werden.

### E. Produktive/zu integrierende Sources

```text
scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua
scripts/campaign/OMW_FireSupStratResupply_SupportProfiles.lua
scripts/campaign/OMW_FireSupStratResupply_Base.lua
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
scripts/logistics/OMW_GroundInitialStock.lua
```

### F. Gate-5-Testsource und Builder

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/src/01-six-site-guard-runtime-acceptance.lua
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/src/02-six-site-guard-compact-aligned-acceptance.lua
tools/build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1
```

### G. Tatsächlich verwendete MOOSE-Basis

Zusätzlich zur Projektdokumentation muss der Folge-Chat bei jeder neuen MOOSE-Nutzung wieder gegen die tatsächlich gepinnte `Moose.lua` prüfen. Dokumentation allein beweist keine API-Verfügbarkeit.

---

## 17. Bekannte Fehler / Irrungen, die nicht wiederholt werden dürfen

1. **Keine erfundenen ME-Prerequisites.** Die sechs Guard-PATHLINEs existieren bereits; Alarmzonen sind runtime-generiert.
2. **Keine Vorfilterung operativer Assets durch OMW, wenn MOOSE die Selektion leisten soll.** MOOSE owns operational recruitment.
3. **Keine Vermischung von Guard, Incident Support und Resupply Lifecycles.** Guard persistent, Incident Support incident-driven, Resupply resource-driven.
4. **Keine automatische Beendigung von Unterstützung beim Verlassen der Alarmzone.**
5. **Kein roher Lua-Code als lokaler Ausführungsauftrag.** Der etablierte Owner-Workflow ist PowerShell-Builder -> Bundle -> DCS.
6. **Keine Dokumentations-Endlosschleife.** Ein docs-only Commit rechtfertigt keinen neuen lokalen Pull-/Hash-Zyklus.
7. **Keine Übertragung historischer Wright-/Stage-3-Fähigkeiten auf den generischen aktuellen Six-Site-Bestand ohne aktuelle Fachbaseline.**
8. **Keine produktive Generalisierung des privaten Warehouse-Spawn-Adapters ohne Owner-Entscheidung.**

---

## 18. Übergabezustand in einem Satz

```text
Gate 0–3 sind für ihre dokumentierten Architektur-/Source-/Pure-Lua-Scope abgeschlossen,
Gate 4 hat einen realen historischen Exact-Scope-DCS-PASS,
Gate 5 hat die ME-Vertragsfehler korrigiert und Acceptance 1 praktisch ausgewertet;
Acceptance 2 ist gebaut, CI-geprüft und wartet jetzt ausschließlich auf den realen DCS-Lauf
für kompakt/PATHLINE-ausgerichtete Guards an allen sechs Sites.
```

Der Folge-Chat setzt **genau dort** fort und beginnt nicht erneut mit Architektur, Assetselektion, Alarmzonen oder bereits geklärten MOOSE-Grundfragen.
