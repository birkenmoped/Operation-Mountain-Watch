---
document_id: OMW-HANDOFF-FSSR-BASE-GATE5-20260914
status: PLANNED
document_class: CHAT_HANDOFF_AND_IMPLEMENTATION_STATUS
owning_policy: OMW-GOV-001
authoritative_for:
  - current Fire Support / Strategic Resupply Base handoff context
  - completed Gate 0 through Gate 4 work summary
  - current Gate 5 six-site work state
  - mandatory continuation sequence and anti-regression constraints
not_authoritative_for:
  - repository-wide authority beyond current main governance
  - merge approval or Ready-for-Review approval
  - DCS acceptance beyond the exact cited acceptance provenance
  - permission to bypass MOOSE-first policy
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-HANDOFF-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-20260911 for current operational handoff context
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Übergabe – Fire Support / Strategic Resupply Base – aktueller Stand Gate 5

## 1. Zweck und Startpunkt für den Folgechat

Diese Übergabe ist der aktuelle operative Einstiegspunkt für die Fortsetzung der standortunabhängigen Fire-Support-/Strategic-Resupply-Basis von Operation Mountain Watch.

Arbeitsrepository und Branch:

```text
Repository: birkenmoped/Operation-Mountain-Watch
Branch: agent/fire-support-strategic-resupply-base-gate0
Pull Request: #149
PR-Status: Draft / offen / nicht gemergt
Branch-Head unmittelbar vor Erstellung dieser Übergabe:
7e921d7ab6e9ce11b9b2bed8e1a8fed3eaafc0c7
```

Der Folgechat beginnt **nicht** wieder bei Gate 0. Die Arbeiten bis Gate 4 sind fachlich und technisch weit fortgeschritten; der aktuelle Arbeitsbereich ist **Gate 5: generische Six-Site-Production-Base**.

Die ältere Übergabe

```text
docs/handoffs/2026-09-11-fire-support-strategic-resupply-base-chat-handoff.md
```

bleibt historische Entwicklungs- und Irrweg-Evidenz. Für die aktuelle Fortsetzung ist dieses Dokument maßgeblich. Wo die ältere Übergabe eine spätere Six-Site-Erweiterung noch als „Gate 6“ bezeichnet, gilt für die aktuelle Arbeitsplanung die inzwischen etablierte Gate-5-Six-Site-Terminologie. Es darf aus der alten Nummerierung kein neuer paralleler Gate-Plan konstruiert werden.

---

## 2. Arbeitsgesetze – vor jeder Änderung zwingend lesen

Diese Dateien sind keine optionalen Hinweise, sondern die verbindlichen Arbeitsregeln des Projekts:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/DOCUMENT-METADATA-POLICY.md
docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md
```

Für Gate 5 zusätzlich zwingend:

```text
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-5-SIX-SITE-ME-CONTRACT.md
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/ACCEPTANCE-1.md
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-4.md
```

### Gesetz 1 – Autoritätshierarchie

Bei Widersprüchen gilt ausschließlich die Hierarchie aus `docs/00-project-governance.md`:

```text
1. ausdrückliche Owner-Entscheidung in Governance/ADR auf main
2. aktuelle BINDING_PROJECT_DECISION / BINDING Baseline auf main
3. DCS-Acceptance für exakt dokumentierten Branch/Commit/MIZ/Bundle/MOOSE-Stand
4. Fachmanifest / Mission-Editor-Arbeitsliste
5. ältere Tests / Handovers / PRs / Ergebnisberichte
6. externe historische Quellen
```

Ein älteres, detaillierteres Dokument wird nicht dadurch wieder verbindlich, dass es mehr Text enthält.

### Gesetz 2 – Draft-Branch ist nicht automatisch Repository-Wahrheit

PR #149 ist Draft und nicht gemergt. Branch-Acceptances gelten exakt für ihre dokumentierte Provenienz. Repositoryweite normative Wirkung entsteht erst durch Merge nach `main` oder eine ausdrückliche Owner-Entscheidung in einer autoritativen Main-Governance.

### Gesetz 3 – CampaignState und MOOSE haben getrennte Autoritäten

```text
CampaignState
= persistente strategische Identität, Ressourcen, Verfügbarkeit, Verlust, Wartung, Verlegung

MOOSE
= physische Runtime-Ausführung, Rekrutierung, Queue, Mission, Rückkehr, Verlust, Warehouse-/Legion-Lifecycle

DCS-Gruppe
= temporäre physische Repräsentation
```

Keine doppelte Ressourcenhoheit. Ein `Done`, Cancel oder Rückkehrbefehl ist noch keine bestätigte physische Rückkehr. Strategische Freigabe erst nach dem passenden bestätigten MOOSE-Lifecycle-Ereignis.

### Gesetz 4 – Alarmzone ist nur Triggergrenze

Projektweit gilt:

```text
FOB / COP / OP alarm zone
= threat-detection and response-trigger boundary
!= tactical battlespace
!= weapons engagement zone
!= fire-support target area
!= CAS engagement area
!= mission-end condition
```

`OPSZONE:Defeated` beendet daher einen bereits ausgelösten QRF-/ARTY-/CAS-Auftrag nicht automatisch.

### Gesetz 5 – Acceptance darf Produktsemantik nicht erfinden

Ein Acceptance-Harness darf beobachten und notwendige physische Teststimuli erzeugen. Er darf jedoch weder QRF-Ziele auswählen, eigene Release-Bedingungen erfinden, `ExpireDemand` als Ersatz für Produkt-Completion verwenden, eigene Routensteuerung einführen noch eine alternative AUFTRAG-Art nur für einen bequemeren PASS verwenden.

### Gesetz 6 – Keine unbelegten Behauptungen

Ein Build beweist Build-/Syntax-/Hash-Konsistenz, nicht DCS-Verhalten. `VALIDATED` nur nach realem DCS-Test mit vollständiger Provenienz.

Niemals erfinden:

```text
MOOSE-Klassen
MOOSE-Methoden
Events / FSM-Callbacks
Argumente / Rückgaben
DCS-API-Verhalten
Mission-Editor-Verhalten
Commits
Hashes
Testergebnisse
```

---

## 3. CREDO: MOOSE FIRST

Dies ist das verbindliche Entwicklungscredo für die weitere Base-Arbeit:

```text
MOOSE-Dokumentation prüfen
-> tatsächlich verwendete Moose.lua prüfen
-> Signaturen, Rückgaben, Events, FSMs und Voraussetzungen prüfen
-> offizielle MOOSE-Demos/Tests prüfen, soweit relevant
-> vorhandene MOOSE-Funktion direkt verwenden
-> vorhandene MOOSE-Funktion konfigurieren/kombinieren
-> öffentliche Events/Callbacks/FSMs verwenden
-> nur falls nötig einen kleinen Adapter ergänzen
-> eigene/native DCS-Lösung nur nach dokumentierter Lücke UND ausdrücklicher Owner-Freigabe
```

Kurzform:

```text
MOOSE FIRST.
NICHT RATEN.
NICHT PARALLEL NACHBAUEN.
KEIN ZWEITER DISPATCHER.
KEIN ZWEITER ROUTER.
KEINE ZWEITE RESSOURCENHOHEIT.
```

Die verbindliche Priorität lautet:

```text
MOOSE direkt
-> MOOSE konfigurieren/kombinieren
-> MOOSE Events/Callbacks/FSM
-> kleiner OMW-Adapter
-> eigene/native Lösung nur als genehmigte Ausnahme
```

MIST ist ohne genehmigte Ausnahme ausgeschlossen.

Pinned MOOSE für den aktuellen FSSR-Nachweis:

```text
Release: 2.9.18
Commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Dokumentation allein beweist keine API-Verfügbarkeit. Maßgeblich ist die tatsächlich verwendete `Moose.lua`.

---

## 4. GitHub-/Arbeitsworkflow – ebenfalls Gesetz

ChatGPT führt Repository-Arbeit selbst aus:

```text
Repository/Governance prüfen
-> Änderung erstellen
-> vollständigen Diff prüfen
-> Syntax/Tests/Dokumentation/MOOSE-first prüfen
-> selbst committen
-> selbst auf den vorgesehenen Remote-Branch veröffentlichen
```

Erst danach bekommt der Projektinhaber ausschließlich eine nummerierte PowerShell-Anweisung für die lokal notwendigen Schritte.

Auf dem Owner-Windows-Arbeitsplatz gilt aus den dokumentierten Gate-5-Korrekturen:

```text
- kein direkter lokaler lua-/luac-Aufruf, solange die Tooling-Baseline nicht geändert wurde;
- versionierte PowerShell-Builder benutzen;
- bei blockierender ExecutionPolicy prozessbezogen:
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File <builder>
- keine dauerhafte Änderung der ExecutionPolicy erforderlich;
- Lua/CI-Prüfungen laufen über die vorhandene GitHub-CI, wenn lokal kein Interpreter verfügbar ist.
```

Lokale Builds, Hashes oder DCS-Verhalten dürfen niemals simuliert oder angenommen werden. Nur die reale Konsolenausgabe des Projektinhabers ist Evidenz.

**Kein CODEX. Keine CODEX-CLI-Übergabe.**

PR #149 bleibt Draft. Ready-for-Review oder Merge nur nach ausdrücklicher Owner-Freigabe.

---

## 5. Ziel der Base

Die Production Base soll standortunabhängig dieselbe fachliche Orchestrierung bereitstellen:

```text
Installation / lokale Lage
-> Incident / ResourceDemand
-> OMW_FireSupStratResupply_Base
-> kleiner Support-spezifischer MOOSE-Adapter
-> MOOSE Organisation / AUFTRAG / OPS / Transport / Warehouse Lifecycle
-> bestätigte physische Lifecycle-Ereignisse
-> idempotenter strategischer CampaignState-Abgleich
```

Die Base ist **kein eigener Combat-Dispatcher**, keine eigene MOOSE-Ersatzqueue und keine zweite Ressourcenautorität.

Der generische Lifecycle-Vertrag aus PR #149 lautet:

```text
StartSite(siteId)
-> persistent site-scoped Guard security

OpenIncident(...)
-> Incident-Kontext

RequestIncidentSupport(...)
-> QRF / externe ARTY / CAS

RequestResupply(...)
-> standort-/ressourcenbezogen und unabhängig vom Attack-Incident
```

MOOSE bleibt operative Rekrutierungs-, Queue-, Missions-/Transport- und physische Lifecycle-Autorität.

---

## 6. Gate-Status – aktuelles Gesamtbild

### Gate 0 – Authority Reconciliation – ERLEDIGT

Ziel war, vor jeder Implementierung zu klären, welche Entscheidungen bereits verbindlich sind und welche historischen Branch-/Teststände nur Evidenz darstellen.

Ergebnis:

```text
Governance-Hierarchie geklärt
MOOSE-first als verbindliches Gesetz geklärt
CampaignState/MOOSE-Ressourcenautorität getrennt
Branch-Acceptance vs. main-Autorität geklärt
FSSR bestehende Lifecycle-/Support-Gesetze reconciliert
```

Gate 0 darf nicht neu erfunden werden. Bei jedem neuen Konflikt wird die bestehende Hierarchie angewendet.

### Gate 1 – MOOSE-First Gap Analysis – ERLEDIGT als Architektur-/Research-Gate

Vor der Base-Implementierung wurden die einschlägigen MOOSE-Mechanismen gegen den gepinnten Source geprüft. Dazu gehören unter anderem AUFTRAG-, LEGION-/BRIGADE-/AIRWING-, WAREHOUSE-, OPSTRANSPORT-, ARTY-, ARMYGROUP-, OPSZONE-, PATHLINE- und FSM-Lifecycle-Pfade.

Grundentscheidung:

```text
OMW entscheidet fachlichen Bedarf und strategische Herkunft/Autorität.
MOOSE rekrutiert und besitzt operative Queue/Mission/Lifecycle.
OMW baut keine parallele Verfügbarkeits-/Retry-/Assetwahl-Queue.
```

Neue MOOSE-Nutzung in späteren Gate-5-Arbeitspaketen muss trotzdem erneut nach dem verbindlichen Rechercheweg verifiziert werden. Gate 1 bedeutet nicht, dass künftig unbekannte APIs angenommen werden dürfen.

### Gate 2 – Generic Domain Contracts / Grundmodule – ERLEDIGT als Branch-Basis

Die generische Base-/Demand-/Site-Struktur wurde geschaffen. Relevante aktuelle Bausteine sind insbesondere:

```text
scripts/campaign/OMW_FireSupStratResupply_Base.lua
scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua
scripts/campaign/OMW_FireSupStratResupply_QrfRuntime.lua
scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua
```

Gate 2 umfasst die Trennung von Site-Konfiguration, MissionDemand/ResourceDemand, CampaignState-Adapter und MOOSE-Lifecycle-Adaptern. Der Gate-5-Korrekturstand verbietet erneut eingeführte `alarmZone`-ME-Abhängigkeiten.

### Gate 3 – Generic Composition / One-Site Scaffold – ERLEDIGT als technische Grundlage

Der konkrete Honaker/Wright-/Stage-3-Hintergrund wurde in generische Base-Verträge überführt. Standortnamen und Testfixture-spezifische Werte dürfen nicht in der Base zur Produktionsannahme werden.

Die wesentlichen abstrahierten Invarianten lauten:

```text
Supportarten sind voneinander unabhängig.
Fehlende ARTY blockiert nicht automatisch QRF/CAS/Resupply.
Fehlendes CAS blockiert nicht automatisch QRF/ARTY/Resupply.
Alarm-/Perimeter-Clear ist nicht automatisch Mission-Ende.
Strategische Buchung folgt bestätigten physischen Lifecycle-Ereignissen.
```

### Gate 4 – Response Mechanics / QRF Direct Target Lifecycle – DCS VALIDATED

Gate 4 ist inzwischen deutlich über den frühen Honaker/Wright-Smoke hinausgegangen. Der Joyce-A4-8-Lauf bildet die aktuelle akzeptierte technische QRF-Baseline.

Verbindlicher QRF-Vertrag:

```text
physical installation alarm
-> exactly one local QRF demand
-> ACCESS-only road-aligned materialization
-> AUFTRAG:NewONGUARD(initial threat coordinate) nur als Recruitment/Materialization Anchor
-> dieselbe physische ARMYGROUP
-> nearest living known incident UNIT inside site-local 5 NM tactical zone
-> ARMYGROUP:EngageTarget(concrete UNIT, speed, "On Road")
-> target dead -> MOOSE Disengage
-> nächstes lebendes Incident-UNIT
-> keine lebenden autorisierten Incident-Ziele mehr
-> Mission completion/cancel
-> MOOSE ReturnToLegion / RTZ / Returned / Warehouse lifecycle
```

Target Authority:

```text
OMW_GroundInstallationAttackIncident:GetParticipants(true)
```

Keine zweite DCS-World-Scan-Autorität.

Verbotene Rückfälle:

```text
GROUNDATTACK
PATROLZONE + HuntingPatrol
SetEngageDetected als alleiniger Clearance-Mechanismus
Acceptance-eigene Targetsuche
OMW-Target-Scheduler
OMW-Straßenrouter
Vee als Marsch-/Transit-Default
Perimeter-Clear -> sofortiger Return
Incident-Close allein -> sofortiger Return
```

#### Gate-4 A4-8 – exakte validierte Provenienz

```text
Status: ACCEPTED_TECHNICAL_BASELINE
validated_in_dcs: true

Source commit:
a1ab98318b4f614875847d95e58bd0b15695a2d3

DCS:
2.9.29.27468

Mission:
OMW_Template_v24_GroundWorks_base.miz
Mission SHA-256:
524DF086D0C4EC1B8B71FAF4E45C713F3E5EA13152965AE793E10B5380C50979

Production bundle SHA-256:
17BBC6F7B0020BFB118B229CAD0F755CAA3B3771881546D430DF1AA6EE25D8FB

Acceptance bundle SHA-256:
098E888470547BF6D3836DF5AB19C47B914E96CAABDB9FAECE09821667489646

MOOSE release:
2.9.18
MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

Runtime log:
dcs(20260914-174452).log
Debrief:
debrief(20260914-174451).log
```

Der Lauf bewies:

```text
physical Joyce incident
exactly one QRF demand
On Road wird real an EngageTarget übergeben
RED-Fixture folgt unveränderter Mission-Editor-Route
QRF materialisiert innerhalb Joyce ACCESS
mindestens drei konkrete RED UNIT Targets werden nacheinander akquiriert
Fixture wird vollständig beseitigt
Target exhaustion löst ReturnToLegion aus
OnAfterReturned / OnAfterRTZ werden real beobachtet
finaler Acceptance PASS
```

#### Bekannte und akzeptierte Pathfinding-Grenze

`On Road` ist im realen A4-7/A4-8-Verhalten eine **Straßenpräferenz**, keine starre Road-Lock-Garantie. Bei beweglichen Zielen kann MOOSE/DCS die Route neu berechnen und je nach Geometrie Straßen- oder direkte Off-Road-Anteile wählen.

Für ummauerte FOBs wie Joyce ist dies nicht ideal. Trotzdem gilt:

```text
KEIN eigener OMW Gate-/Straßenrouter ohne dokumentierte MOOSE-Lücke und ausdrückliche Owner-Freigabe.
```

---

## 7. Gate 5 – AKTUELLER ARBEITSBEREICH

Gate 5 ist die **generische Six-Site-Production-Base**.

Scope:

```text
Jalalabad / FOB Fenty
COP Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick
```

Gate 5 ist noch `PLANNED` / nicht generisch DCS-validiert.

### 7.1 Mission-Editor-Vertrag – bereits geklärt

Folgende sechs Guard-PATHLINEs existieren bereits und dürfen nicht erneut angelegt werden:

```text
OMW_RTE_BLUE_GUARD_FENTY_01
OMW_RTE_BLUE_GUARD_FORTRESS_01
OMW_RTE_BLUE_GUARD_JOYCE_01
OMW_RTE_BLUE_GUARD_WRIGHT_01
OMW_RTE_BLUE_GUARD_HONAKER_01
OMW_RTE_BLUE_GUARD_BOSTICK_01
```

Read-only geprüfte historische Gate-5-Mission:

```text
OMW_Template_v23_GroundWorks_base(1).miz
SHA-256:
3DD8DFC0CE1A79A2C1D57A0ADEC0E2E5B1DC5AF9F35AA58F3F1A46F93F23871E
```

Es werden **keine** zusätzlichen Mission-Editor-Alarmzonen benötigt:

```text
KEIN ZON_BLUE_GND_FENTY_ALARM
KEIN ZON_BLUE_GND_FORTRESS_ALARM
KEIN ZON_BLUE_GND_JOYCE_ALARM
KEIN ZON_BLUE_GND_WRIGHT_ALARM
KEIN ZON_BLUE_GND_HONAKER_ALARM
KEIN ZON_BLUE_GND_BOSTICK_ALARM
```

Der Alarm-/Security-Perimeter entsteht zur Laufzeit durch den vorhandenen Adapter:

```text
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua

installation anchor + configured radius
-> MOOSE ZONE_RADIUS
-> MOOSE OPSZONE
-> Attacked / Defeated / Evaluated lifecycle
```

### 7.2 Six-Site Objektvertrag

```text
Fenty
Warehouse: WH_BLUE_GND_FENTY
ACCESS: ZON_BLUE_GND_FENTY_ACCESS
Guard PATHLINE: OMW_RTE_BLUE_GUARD_FENTY_01

Fortress
Warehouse: WH_BLUE_GND_FORTRESS
ACCESS: ZON_BLUE_GND_FORTRESS_ACCESS
Guard PATHLINE: OMW_RTE_BLUE_GUARD_FORTRESS_01

Joyce
Warehouse: WH_BLUE_GND_JOYCE
ACCESS: ZON_BLUE_GND_JOYCE_ACCESS
Guard PATHLINE: OMW_RTE_BLUE_GUARD_JOYCE_01

Wright
Warehouse: WH_BLUE_GND_WRIGHT
ACCESS: ZON_BLUE_GND_WRIGHT_ACCESS
Guard PATHLINE: OMW_RTE_BLUE_GUARD_WRIGHT_01

Honaker-Miracle
Warehouse: WH_BLUE_GND_HONAKER
ACCESS: ZON_BLUE_GND_HONAKER_ACCESS
Guard PATHLINE: OMW_RTE_BLUE_GUARD_HONAKER_01

Bostick
Warehouse: WH_BLUE_GND_BOSTICK
ACCESS: ZON_BLUE_GND_BOSTICK_ACCESS
Guard PATHLINE: OMW_RTE_BLUE_GUARD_BOSTICK_01
```

Gemeinsames Guard-Template:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

### 7.3 Harte ACCESS-Regel für QRF

```text
JALALABAD_FENTY -> ZON_BLUE_GND_FENTY_ACCESS
COP_FORTRESS    -> ZON_BLUE_GND_FORTRESS_ACCESS
FOB_JOYCE       -> ZON_BLUE_GND_JOYCE_ACCESS
FOB_WRIGHT      -> ZON_BLUE_GND_WRIGHT_ACCESS
COP_HONAKER     -> ZON_BLUE_GND_HONAKER_ACCESS
FOB_BOSTICK     -> ZON_BLUE_GND_BOSTICK_ACCESS
```

Nicht zulässig als QRF-Materialisierungsabhängigkeit:

```text
*_PATROL_TEST_01
Alarm-/Security-Zone
Warehouse-Center
FOB-/COP-Mittelpunkt
taktisches Ziel als Spawnzone
zusätzliche Mission-Editor-Spawnzone
```

### 7.4 Unmittelbar nächster Test: Gate 5 Six-Site Guard Runtime Acceptance 1

Dieser Test ist bereits vorbereitet, aber noch **nicht DCS-validiert**.

Dateien:

```text
Source:
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/src/01-six-site-guard-runtime-acceptance.lua

Builder:
tools/build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1

Acceptance:
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/ACCEPTANCE-1.md

Output:
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/dist/OMW_FireSupStratResupply_Gate5_Six_Site_Guard_Runtime.lua
```

Acceptance-1 prüft absichtlich nur:

```text
alle sechs Sites
-> Guard materialisiert über MOOSE
-> bestehende owner-authored PATHLINE aufgelöst
-> Route gesetzt
-> Guard lebt
-> mindestens 25 m physische Bewegung in 300 s
```

Explizit **nicht** Teil dieses ersten Tests:

```text
Feindangriff
Alarm-/OPSZONE-Acceptance
QRF
ARTY
CAS
Ground-/Air-Resupply
CampaignState-Settlement
MIZ-Mutation
```

Früherer realer lokaler Build-Nachweis für diesen Harness:

```text
Source commit:
4215e4786a6c6b316d8096e48f9026e3f9ac8f93

BuilderVersion:
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-1

Runtime source SHA-256:
3699B9111ED15C0C93DE4895545CE3276632927E3DCDB1117CEACC7141B62821

Builder SHA-256:
993FC2190A3C659AA608A0A0220D09E7198F2AF0F17F5785795A9B1D04E3CBB9

Generated bundle SHA-256:
F4C0BADF01557A38485BB3A5677EF723CA435729173CE8F23401FA90CF6F0518
```

Dieser Build ist **nur historische Build-Provenienz**. Da der Branch inzwischen weitergelaufen ist, muss vor einem neuen DCS-Test auf aktuellem Head neu gebaut und die reale neue Hashkette dokumentiert werden. Nicht den alten Bundle-Hash stillschweigend als aktuellen Teststand wiederverwenden.

---

## 8. Noch zu erledigende Arbeit auf dem Weg zur Production Base

Die folgenden Punkte sind **Arbeitspakete innerhalb Gate 5**. Sie sind keine stillschweigend neu erfundenen formalen Governance-Gate-Nummern. Ein späteres „Gate 6“ darf erst benannt werden, wenn die aktuelle Branch-Dokumentation beziehungsweise der Projektinhaber dies festlegt.

### Gate-5-Arbeitspaket 5A – Six-Site Guard Runtime

Status: **nächster Schritt / noch DCS-offen**.

Ziel:

```text
alle sechs Standorte
-> generische SiteRegistry
-> BRIGADE / PLATOON Guard
-> vorhandene PATHLINE
-> physische Materialisierung
-> reale Bewegung
```

Zunächst vorhandene Acceptance-1 ausführen. Danach nur dann einen längeren/full-loop Guard-Test ergänzen, wenn die Anforderungen dies tatsächlich verlangen.

### Gate-5-Arbeitspaket 5B – Six-Site Alarm / OPSZONE Runtime

Status: **offen**.

Ziel:

```text
site / installation anchor
+ standortspezifischer Radius
-> runtime ZONE_RADIUS
-> OPSZONE
-> echte Threat-/Alarm-Evidenz
-> Response-Demand
```

Keine Mission-Editor-Alarmzonen erzeugen.

Die Radiusfrage ist standortspezifisch. Große Flugplätze wie Jalalabad können einen deutlich größeren Alarmradius als kompakte COPs/FOBs benötigen. Keine Einheitsgröße ohne fachliche Prüfung festschreiben.

### Gate-5-Arbeitspaket 5C – Six-Site QRF Runtime

Status: **Joyce Mechanik validiert, generische Six-Site-Acceptance offen**.

Die A4-8-Baseline muss wiederverwendet werden; nicht neu entwickeln.

Besonderes Augenmerk:

```text
ACCESS-only materialization
RoadSpawnAdapter
On Road real an EngageTarget übergeben
known Incident participants as target authority
5-NM tactical target zone
Disengage-driven retarget
Target exhaustion
ReturnToLegion / RTZ / Returned
```

Historisch bekannte separate Materialisierungsprobleme bei Honaker/Bostick dürfen nicht durch Änderungen der Ziel-/Engagement-Architektur „gelöst“ werden. Falls sie erneut auftreten, den konkreten RoadSpawn-/ACCESS-Vertrag untersuchen.

### Gate-5-Arbeitspaket 5D – Fire-Support Response Paths

Status: **offen für generische Base-Abnahme**.

Lokale/externe ARTY und später CAS müssen denselben generischen Incident-/Demand-Vertrag nutzen. Keine zweite operative Assetwahl neben MOOSE. Unterstützungsarten bleiben voneinander unabhängig.

Vor jeder neuen Mission-/Klassenwahl die Accepted Implementation Matrix und die einschlägige MOOSE-Themendokumentation prüfen.

### Gate-5-Arbeitspaket 5E – Strategic Resupply

Status: **offen für die vollständige Base**.

Resupply bleibt fachlich unabhängig vom Attack-Incident:

```text
ResourceDemand / site-resource need
-> strategische Herkunft / CampaignState-Vertrag
-> MOOSE Transport-/Mission-Lifecycle
-> bestätigte physische Lieferung
-> idempotentes Settlement
```

Kein strategischer Bestand wird bei Start/Transit künstlich am Ziel erhöht.

### Gate-5-Arbeitspaket 5F – CampaignState / Warehouse Settlement und Restart

Status: **offen für vollständige Production-Base-Acceptance**.

Für jede integrierte Ressource müssen mindestens belegt werden:

```text
stabile Ressourcen-/Herkunfts-ID
reserve
physical deploy
return
loss
re-dispatch
idempotente Eventverarbeitung
Missions-/Serverstart-Reconciliation
Restart/Restore-Verhalten
Sperr-/Diagnoseverhalten bei absichtlich erzeugter Abweichung
```

Erst wenn diese Gate-5-Arbeitspakete in der zuständigen Acceptance ausreichend abgedeckt sind, kann die generische `OMW_FireSupStratResupply_Base` als vollständige Production Base bewertet werden.

---

## 9. Anti-Regression – diese Irrwege NICHT wiederholen

### Mission Editor

```text
NICHT behaupten, die sechs Guard-PATHLINEs fehlten.
NICHT ZON_BLUE_GND_*_ALARM im Mission Editor verlangen.
NICHT zusätzliche Spawnzonen für QRF erfinden.
```

Vor der Behauptung „ME-Objekt fehlt“ immer:

```text
aktuelle Fach-/Ground-Baseline
-> aktuelle MIZ read-only prüfen
-> bestehenden Runtime-Code prüfen
-> erst dann fehlendes Objekt erklären
```

### QRF

```text
kein GROUNDATTACK
kein PATROLZONE/HuntingPatrol
kein eigener Target-Scheduler
kein eigener Road-Router
kein Vee als Marsch-Default
kein Return nur wegen Perimeter-Clear
kein Return nur wegen Incident-Close
keine Acceptance-eigene Targetauswahl
```

### Ressourcen

```text
kein CampaignState + MOOSE Warehouse als zwei unabhängige Bestandsbesitzer
keine Rückbuchung bei bloßem Done/Cancel/RTZ-Befehl
keine Zielbestandsbuchung bei bloßem Transportstart
```

### Workflow

```text
kein Lua-Quelltext als PowerShell-Anweisung
kein direkter lokaler lua-Aufruf auf der bekannten Owner-Tooling-Baseline
keine erfundenen Hashes
keine erfundenen DCS-Ergebnisse
kein automatisches MissionScripting.lua-Edit
keine .miz-Mutation durch ChatGPT
kein CODEX
```

---

## 10. Vollständige Dokumentationsübergabe – Pflichtlektüre und Evidenzpfade

Der Folgechat darf diese Übergabe nicht isoliert verwenden. Die folgende Dokumentation ist als zusammengehöriger Arbeitsbestand zu lesen.

### A. Projektgesetze / Governance

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/DOCUMENT-METADATA-POLICY.md
docs/DOCUMENT-REGISTRY.md
docs/SUBPROJECT-REGISTRY.md
```

### B. Aktuelle FSSR-Gesetze / Anti-Regression

```text
docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-5-SIX-SITE-ME-CONTRACT.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
```

Zusätzlich die von diesen Dokumenten referenzierten Ground-/Alarm-/ACCESS-/Support-Lifecycle-Entscheidungen lesen, insbesondere die aktuellen Fassungen zu:

```text
ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION
ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT
MOOSE support-request lifecycle / ADR 0008
Stage-3 CAS tactical corridor / lifecycle recovery, soweit CAS betroffen ist
```

Nicht aus dem Dateinamen einen Status ableiten; Frontmatter und Governance-Hierarchie prüfen.

### C. Aktuelle Acceptance / DCS-Evidenz

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-4.md
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/ACCEPTANCE-1.md
```

A4-8 ist die aktuelle DCS-validierte QRF-Referenz für exakt dokumentierte Provenienz. Gate-5 Six-Site Guard Acceptance-1 ist vorbereitet, aber noch nicht DCS-validiert.

### D. Gate-5 Builder / Runtime

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/src/01-six-site-guard-runtime-acceptance.lua
tools/build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1
```

### E. Production Base / QRF Code

```text
scripts/campaign/OMW_FireSupStratResupply_Base.lua
scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua
scripts/campaign/OMW_FireSupStratResupply_QrfRuntime.lua
scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
scripts/ground/OMW_GroundRoadSpawnAdapter.lua
```

Beim Arbeiten an Incident-Teilnehmern zusätzlich die aktuelle Implementierung von `OMW_GroundInstallationAttackIncident` im Repository lokalisieren und lesen; nicht aus älteren Chat-Snippets rekonstruieren.

### F. Historische Übergabe / Entscheidungsverlauf

```text
docs/handoffs/2026-09-11-fire-support-strategic-resupply-base-chat-handoff.md
```

Sie enthält wichtige Stage-3-Ausgangslage, Irrwege und frühere Gate-Planung. Sie ist jedoch für den aktuellen operativen Stand durch diese Gate-5-Übergabe ersetzt.

### G. Gate-5 Workflow-/Tooling-Evidenz

```text
results/2026-09-12-fire-support-gate5-correction-local-verification.md
results/2026-09-12-gate5-lua-pasted-into-powershell-correction.md
```

Diese Ergebnisse erklären insbesondere die lokale ExecutionPolicy-/PowerShell-/Lua-Tooling-Grenze und verhindern, dass dieselben Fehler erneut produziert werden.

### H. Pinned MOOSE Primärquellen

```text
Moose.lua
MOOSE class documentation matching the pinned release/source
official MOOSE demos/tests where relevant
```

Die tatsächlich verwendete `Moose.lua` ist maßgeblich, nicht eine nur ähnlich benannte Dokumentationsseite.

---

## 11. Verifizierte QRF-MOOSE-Fakten, die nicht neu recherchiert werden müssen, solange der Pin unverändert bleibt

Für den dokumentierten Pin wurden bereits geprüft:

```text
ARMYGROUP:EngageTarget(Target, Speed, Formation)
- akzeptiert UNIT/GROUP/TARGET
- verfolgt die aktuelle Zielposition
- aktualisiert bei relevanter Zielbewegung bzw. fehlender LOS

ARMYGROUP:OnAfterDisengage
- kann zur ereignisgebundenen Retarget-Auswahl genutzt werden

ARMYGROUP RTZ / Returned
- bildet den physischen Rückkehr-/Reintegration-Lifecycle

AUFTRAG:NewONGUARD(...)
- bleibt Recruitment-/Materialization-Anchor im QRF-Vertrag

AUFTRAG:SetReturnToLegion(true)
- wird für die reguläre Rückkehr verwendet

On Road
- ist eine MOOSE/DCS-Straßenpräferenz, keine harte Road-Lock-Garantie
```

Wenn der MOOSE-Pin geändert wird, sind diese Aussagen für den neuen Stand erneut zu prüfen.

---

## 12. Nächster konkreter Arbeitsauftrag für den Folgechat

Nicht mit neuem QRF-Design beginnen.

Der nächste Arbeitsablauf lautet:

```text
1. diese Übergabe vollständig lesen
2. AGENTS.md + Governance + MOOSE-first + Accepted Implementation Matrix lesen
3. aktuellen Branch-/PR-Head prüfen
4. aktuellen Gate-5-Vertrag und Guard Acceptance-1 prüfen
5. gegen aktuellen Head verifizieren, ob Source/Builder seit dem historischen Build verändert wurden
6. CI-/Diff-Stand prüfen
7. falls erforderlich nur die kleinste notwendige Korrektur remote erstellen
8. remote committen/pushen
9. erst danach Owner eine nummerierte PowerShell-Anweisung für Pull/Build/Hash geben
10. reale Owner-Ausgabe abwarten
11. Gate-5 Six-Site Guard Acceptance in DCS ausführen
12. Logs/visuelle Beobachtung auswerten
13. nur bei vollständiger Provenienz Acceptance-Status aktualisieren
14. anschließend Gate-5 5B Alarm/OPSZONE planen
```

Kein erneuter A4-8-QRF-Test ist erforderlich, solange die dafür akzeptierte Implementierung nicht relevant verändert wurde und die neue Gate-5-Arbeit sie nicht regressiert.

---

## 13. Definition „Base fertig“

Die Base ist **nicht** fertig, nur weil Joyce-QRF funktioniert.

Sie ist erst als generische Production Base abnahmefähig, wenn die zuständige aktuelle Acceptance mindestens den vorgesehenen standortunabhängigen Vertrag belastbar nachweist:

```text
Six-Site Guard
+ Runtime Alarm/OPSZONE
+ generischer Response-Demand
+ Six-Site QRF auf Basis der A4-8-Mechanik
+ die vorgesehenen Fire-Support-Pfade
+ Strategic Resupply
+ CampaignState/Warehouse Settlement und Reconciliation
+ dokumentierter Restart/Recovery-Vertrag
```

Dabei bleibt die strategische/physische Trennung strikt:

```text
CampaignState
Ressourcen-/Warehousebestand
Clients
aktive KI
Statics
virtuelle Reserve
```

---

## 14. Entscheidungsgrenze

Der Projektinhaber entscheidet **was** umgesetzt wird und genehmigt jede notwendige Architektur-/Nicht-MOOSE-Ausnahme.

ChatGPT übernimmt:

```text
Analyse
Planung
MOOSE-Prüfung
Implementierung
Review
Tests/CI soweit verfügbar
Dokumentation
Commit
Remote-Veröffentlichung
```

ChatGPT trifft aber keine owner-gated Projektentscheidung stillschweigend selbst.

Arbeitsprinzip:

```text
Governance
-> Fachbaseline
-> realer Ist-Stand
-> MOOSE-Prüfung
-> kleinste notwendige Änderung
-> Diff/Syntax/Tests/Doku
-> Remote-Commit
-> lokale PowerShell-Verifikation
-> reale Ausgabe/Hashes
-> DCS-Test
-> Acceptance
```

**MOOSE first. Nicht raten. Keine vorhandene Funktion unnötig nachbauen. Keine ungeprüfte Aussage als validiert darstellen. Kein CODEX.**
