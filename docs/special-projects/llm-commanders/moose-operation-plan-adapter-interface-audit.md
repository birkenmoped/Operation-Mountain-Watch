---
document_id: OMW-SP-LLM-COMMANDERS-MOOSE-ADAPTER-AUDIT
status: DRAFT_TECHNICAL_EVIDENCE
document_class: MOOSE_ADAPTER_INTERFACE_AUDIT
authoritative_for:
  - source-level candidate boundary between OperationPlan AdapterCommand and MOOSE
  - candidate use of AUFTRAG COMMANDER LEGION OPERATION OPSGROUP and OPSTRANSPORT
  - adapter mapping risks and required acceptance tests
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/optional-llm-commanders
source_commit: 7be3ed28757f8036a43184a6c774df4701bec98c
validated_in_dcs: false
moose_target_version: 2.9.18
moose_source_commit_reviewed: 23112c99545d8b052f850fe0680d77272d24433b
moose_bundle_commit_candidate: 0f62c084ddb1c54bb6467fa9b0c01c80d3a4e7f2
---

# MOOSE-Schnittstellen-Audit für OperationPlan und DCS-Adapter

## 1. Zweck

Dieses Audit prüft die technische Grenze zwischen den sprachneutralen Verträgen des optionalen Multi-Commander-Projekts und der taktischen MOOSE-Ausführung.

Untersucht wird insbesondere:

```text
OPERATION_PLAN
-> ADAPTER_COMMAND
-> FIXED_CAPABILITY_PROFILE
-> DCS_MOOSE_ADAPTER
-> MOOSE_OBJECTS
-> ADAPTER_RESULT_AND_EVENTS
```

Das Dokument beantwortet nicht, welche realen Mission-Editor-Templates, Squadrons, Force Packages, Routen oder Zielobjekte verwendet werden. Diese Daten sind weiterhin nicht zu erfinden und müssen aus den zuständigen Manifesten und Mappings stammen.

## 2. Ergebnis in einem Satz

Die vorhandenen MOOSE-OPS-Klassen bieten einen grundsätzlich geeigneten taktischen Unterbau, aber es existiert keine zulässige oder belastbare Eins-zu-eins-Übersetzung von `OPERATION_PLAN` in eine einzelne MOOSE-Klasse.

Verbindliche Zielarchitektur:

```text
ONE_OPERATION_PLAN
-> ZERO_OR_MORE_AUFTRAG
-> ZERO_OR_MORE_OPSTRANSPORT
-> OPTIONAL_MOOSE_OPERATION_CONTAINER
-> COMMANDER_OR_LEGION_OR_OPSGROUP_DISPATCH
```

Dabei bleibt:

```text
DOMAIN_OPERATION_PLAN != MOOSE_OPERATION
FORCE_PACKAGE != DCS_GROUP
CAPABILITY_PROFILE != MOOSE_METHOD_NAME
ADAPTER_COMMAND != LUA
```

## 3. Evidenz- und Geltungsgrenze

### 3.1 Geprüfte OMW-Basis

```yaml
repository: birkenmoped/Operation-Mountain-Watch
branch: docs/optional-llm-commanders
commit: 7be3ed28757f8036a43184a6c774df4701bec98c
operation_plan_contract: docs/special-projects/llm-commanders/19-language-neutral-contracts-and-json-schemas.md
orchestrator_boundary: docs/special-projects/llm-commanders/09-orchestrator-architecture-and-adjudication.md
```

### 3.2 Geprüfte MOOSE-Quellen

Quellstand für dieses Audit:

```yaml
repository: FlightControl-Master/MOOSE
commit: 23112c99545d8b052f850fe0680d77272d24433b
review_type: SOURCE_LEVEL_INTERFACE_REVIEW
```

Geprüfte beziehungsweise einbezogene Quelldateien:

```text
Moose Development/Moose/Ops/Auftrag.lua
Moose Development/Moose/Ops/Commander.lua
Moose Development/Moose/Ops/Operation.lua
Moose Development/Moose/Ops/Target.lua
Moose Development/Moose/Ops/OpsTransport.lua
Moose Development/Moose/Ops/OpsGroup.lua
Moose Development/Moose/Ops/Legion.lua
Moose Development/Moose/Ops/AirWing.lua
Moose Development/Moose/Ops/Brigade.lua
Moose Development/Moose/Ops/ArmyGroup.lua
```

### 3.3 Noch nicht bewiesene Gleichheit mit der Projektdatei `Moose.lua`

Zusätzlich wurde ein MOOSE_INCLUDE-Kandidat betrachtet:

```yaml
repository: FlightControl-Master/MOOSE_INCLUDE
commit: 0f62c084ddb1c54bb6467fa9b0c01c80d3a4e7f2
embedded_source_hash_in_bundle_header: 792aa73832fd42310307b25131f35d6fbb201b86
```

Dieser Bundle-Commit beweist nicht, dass die in Operation Mountain Watch tatsächlich eingebundene Datei exakt diesem Inhalt entspricht. Ebenso ist die Gleichheit zwischen dem geprüften MOOSE-Quellcommit `23112c...` und dem im Bundle genannten Quellhash `792aa...` nicht nachgewiesen.

Deshalb gilt:

```text
SOURCE_API_CANDIDATE_REVIEWED = YES
ACTUAL_OMW_MOOSE_LUA_HASH_VERIFIED_FOR_THIS_ADAPTER = NO
OFFICIAL_DEMO_MISSIONS_REVIEWED_FOR_THIS_ADAPTER = NO
DCS_RUNTIME_VALIDATED = NO
```

Keine Klasse und keine Methode erhält durch dieses Dokument den Status `VALIDATED_FOR_DOCUMENTED_SCOPE`.

## 4. Verbindliche Sicherheits- und Autoritätsgrenze

Das Commander-Modell oder ein LLM darf ausschließlich strukturierte Domänenabsichten erzeugen.

Nicht zulässig:

```text
LLM -> Lua
LLM -> MOOSE class name
LLM -> MOOSE method name
LLM -> raw DCS task
LLM -> Mission Editor object name
LLM -> direct COMMANDER or AUFTRAG call
```

Zulässig:

```text
SCRIPTED_COMMANDER_OR_LLM
-> COMMANDER_DECISION
-> VALIDATION_AND_ADJUDICATION
-> OPERATION_PLAN
-> ADAPTER_COMMAND
-> REVIEWED_CAPABILITY_PROFILE
-> FIXED_ADAPTER_MAPPING
-> MOOSE
```

Nur der Adapter besitzt die technische Zuordnung zwischen einem geprüften `capability_profile_ref` und konkreten MOOSE-Konstruktoren, Settern, Dispatch-Pfaden und Callbacks.

## 5. Klassenentscheidung

| MOOSE-Klasse | Rolle im Adapter | Status dieses Audits | Grenze |
|---|---|---|---|
| `AUFTRAG` | kanonisches taktisches Missionsobjekt | `SOURCE_VERIFIED_CANDIDATE` | Signaturen je Capability Profile erneut gegen die tatsächlich geladene `Moose.lua` prüfen |
| `COMMANDER` | übergeordnete Auswahl geeigneter Legions und Assets | `SOURCE_VERIFIED_CANDIDATE` | DCS-Test für Queueing, Auswahl, Cancel und Callback-Korrelation erforderlich |
| `LEGION` | gemeinsame Basis für `AIRWING`, `BRIGADE`, `FLEET` | `SOURCE_VERIFIED_CANDIDATE` | nicht als Fraktions- oder CampaignState-Eigentümer interpretieren |
| `AIRWING` | Luftkräftebereitstellung und Asset-Auswahl | bereits projektseitig teilweise belegt | neuer Adapterpfad und weitere Basen nicht durch Jalalabad-Grundtest bewiesen |
| `BRIGADE` | Bodenkräftebereitstellung | `PLANNED_SOURCE_CANDIDATE` | keine Adapter-Acceptance vorhanden |
| `FLEET` | Seestreitkräftebereitstellung | `OUT_OF_CURRENT_AFGHANISTAN_SCOPE` | nur bei späterem Bedarf prüfen |
| `OPERATION` | optionaler MOOSE-Phasencontainer | `SOURCE_VERIFIED_OPTIONAL_CANDIDATE` | nicht mit dem Domänenobjekt `OPERATION_PLAN` gleichsetzen |
| `OPSGROUP` | direkte Ausführung durch bereits materialisierte Gruppe | `SOURCE_REVIEW_PARTIAL` | umgeht Teile der Commander-/Warehouse-Auswahl und ist nicht der Standardpfad |
| `OPSTRANSPORT` | eigener taktischer Transportauftrag | `SOURCE_REVIEW_PARTIAL` | getrennt von generischen `AUFTRAG`-Missionen modellieren |
| `TARGET` | MOOSE-Zielabstraktion | `SOURCE_REVIEW_PARTIAL` | Target Resolver und Lebenszyklus müssen separat geprüft werden |
| `CHIEF` | automatische strategisch-taktische Steuerung | `REJECTED_FOR_PROJECT_USE` | bleibt gemäß OMW-Klassenindex außerhalb der aktuellen Architektur |

## 6. Warum `OPERATION_PLAN` keine MOOSE-`OPERATION` ist

Der OMW-Vertrag `OPERATION_PLAN` enthält unter anderem:

```text
owner faction and commander
supporting factions
resource reservations
force package references
agreements
materialization policy
campaign lifecycle
multiple domain tasks
correlation and causation metadata
```

Die MOOSE-Klasse `OPERATION` ist dagegen ein taktischer Phasen- und Ablaufcontainer mit Phasen, Bedingungen, Branches, zugeordneten Missionen, Legions, Cohorts und Targets.

Daraus folgt:

```text
OPERATION_PLAN = CAMPAIGN_AND_ADAPTER_AUTHORITY
MOOSE_OPERATION = OPTIONAL_TACTICAL_RUNTIME_CONTAINER
```

Ein Adapter darf eine MOOSE-`OPERATION` erzeugen, wenn mehrere physische Aufgaben in DCS als zusammenhängender Phasenablauf koordiniert werden sollen. Für eine einzelne taktische Aufgabe ist sie nicht zwingend erforderlich.

## 7. Primärer Materialisierungspfad

Empfohlener Standardpfad für einen genehmigten physischen Auftrag:

```text
1 validate ADAPTER_COMMAND and domain payload
2 resolve capability profile
3 resolve target references through authoritative mapping registry
4 resolve force package references and eligible MOOSE providers
5 construct one or more AUFTRAG objects
6 apply only profile-approved parameters
7 register correlation mappings before dispatch
8 dispatch through COMMANDER or selected LEGION
9 collect MOOSE FSM callbacks and DCS observations
10 emit idempotent ADAPTER_RESULT and domain events
```

Der bevorzugte Dispatch-Pfad ist:

```text
AUFTRAG
-> COMMANDER:AddMission()
-> eligible LEGION selection
-> AIRWING or BRIGADE asset allocation
-> OPSGROUP execution
```

Direkter Legion-Pfad:

```text
AUFTRAG
-> preselected AIRWING or BRIGADE
```

Dieser Pfad ist nur zulässig, wenn das autoritative Mapping die zuständige Legion bereits eindeutig festlegt und die übergeordnete Commander-Auswahl bewusst nicht benötigt wird.

Direkter Gruppenpfad:

```text
AUFTRAG
-> existing FLIGHTGROUP ARMYGROUP or NAVYGROUP
```

Dieser Pfad ist auf bereits materialisierte und eindeutig zugewiesene Gruppen zu beschränken. Er darf die Force-Package-, Warehouse- oder Readiness-Prüfung nicht stillschweigend umgehen.

## 8. Separater Transportpfad

MOOSE behandelt taktische Transportzuweisungen über `OPSTRANSPORT` als eigenen Pfad. `COMMANDER` besitzt hierfür einen separaten Transport-Queue- und Dispatch-Mechanismus über `AddOpsTransport()`.

Daher gilt:

```text
MATERIALIZE_TRANSFER
OR TRANSPORT_OPERATION
-> OPSTRANSPORT_MAPPING

NORMAL_TACTICAL_MISSION
-> AUFTRAG_MAPPING
```

Ein `RESOURCE_TRANSFER` wird nicht automatisch zum physischen Transport. Erst wenn der autoritative Plan und die Materialisierungspolitik einen DCS-Transport verlangen, darf der Adapter einen `OPSTRANSPORT` erzeugen.

```text
RESOURCE_TRANSFER != OPSTRANSPORT
CARGO_MANIFEST != OPSTRANSPORT
OPSTRANSPORT = TACTICAL_EXECUTION_OBJECT_ONLY
```

## 9. Kandidaten für Capability Profiles

Die folgenden Profile sind nur Architektur- und Testkandidaten. Sie sind keine freigegebenen Runtime-Mappings.

| abstraktes Profil | MOOSE-Kandidat | vor Freigabe zu prüfen |
|---|---|---|
| `AIR_CAS_ZONE` | `AUFTRAG:NewCAS()` oder `AUFTRAG:NewCASENHANCED()` | Zonensemantik, Zieltypen, No-Engage-Zonen, Höhe, Geschwindigkeit, ROE, Reaktion auf bewegte Ziele |
| `AIR_BAI_TARGET` | `AUFTRAG:NewBAI()` | zulässige Target-Typen, Zielresolver, Waffen- und Abbruchlogik |
| `AIR_STRIKE_TARGET` | `AUFTRAG:NewSTRIKE()` | Target-Lebenszyklus, Wirkungsauswertung, NSL- und ROE-Gates |
| `AIR_CAP_ZONE` | `AUFTRAG:NewCAP()` | Patrol-Zone, Engagement-Zone, Höhe, Geschwindigkeit, Missionsgrenzen |
| `AIR_RECON_AREA` | `AUFTRAG:NewRECON()` | Sensor- und Intelligence-Integration; kein automatischer `INTEL`-Agent |
| `AIR_SEAD_TARGET` | `AUFTRAG:NewSEAD()` | Zielklassifikation und Emission-Verhalten |
| `AIR_ESCORT_ENTITY` | `AUFTRAG:NewESCORT()` | eskortiertes Objekt, Offset, Engagement-Regeln und Verlustbehandlung |
| `GROUND_ESCORT_ENTITY` | `AUFTRAG:NewGROUNDESCORT()` | Wegfindung, Haltbedingungen, Watchguard und Feindnähe |
| `TACTICAL_TRANSPORT` | `OPSTRANSPORT` | Cargo- und Carrier-Auswahl, Pickup, Staging, Disembark, Verlust und Teilzustellung |

Nicht zulässig ist eine generische Tabelle wie:

```text
profile_name -> arbitrary constructor string
```

Stattdessen benötigt jedes Profil geprüften Adaptercode mit fest verdrahtetem Konstruktor und expliziter Feldvalidierung.

## 10. Zeit- und Prioritätsmapping

### 10.1 Zeit

`AUFTRAG:SetTime()` und `OPERATION:SetTime()` akzeptieren MOOSE-/DCS-bezogene Zeitwerte. Die OMW-Verträge verwenden dagegen UTC-Zeitstempel und getrennte Campaign-Zeit.

Der Adapter benötigt deshalb eine explizite, testbare Konvertierung:

```text
campaign UTC timestamp
-> current DCS session epoch mapping
-> DCS absolute mission time or approved clock string
```

Nicht zulässig:

```text
pass ISO timestamp directly to MOOSE
assume campaign time equals timer.getAbsTime()
reuse wall clock after mission restart without reconciliation
```

### 10.2 Priorität

`AUFTRAG:SetPriority(Prio, Urgent, Importance)` verwendet im geprüften Quellstand insbesondere:

```text
Prio: 1 high to 100 low
Urgent: may displace a lower-priority running mission
Importance: ordering constraint for lower-valued missions
```

Diese Semantik darf nicht direkt aus einem allgemeinen Commander-Score abgeleitet werden. Ein Capability Profile oder eine Adapter-Policy muss den Domänenwert kontrolliert auf MOOSE-Werte abbilden.

## 11. Target Resolver

`target_refs` aus dem Domänenvertrag sind opake fachliche IDs. Sie dürfen keine Mission-Editor-Namen oder MOOSE-Objektnamen enthalten müssen.

Erforderliche Kette:

```text
DOMAIN_TARGET_REF
-> TARGET_MAPPING_REGISTRY
-> current DCS entity or coordinate or zone
-> MOOSE TARGET or constructor-specific target argument
```

Der Resolver muss mindestens unterscheiden:

```text
ENTITY_TARGET
GROUP_TARGET
UNIT_TARGET
STATIC_TARGET
ZONE_TARGET
COORDINATE_TARGET
ROUTE_OR_AREA_TARGET
RESOURCE_SOURCE_TARGET
```

Vor jeder Materialisierung sind zu prüfen:

- Existenz und aktuelle Mapping-Version;
- Sichtbarkeit und Wissensberechtigung des Commanders;
- No-Strike- und ROE-Freigaben;
- DCS-Lebenszustand;
- Eigentümer und Koalition;
- Staleness der Beobachtung;
- Eignung für den ausgewählten AUFTRAG-Konstruktor.

## 12. Force-Package- und Provider-Resolver

Ein `FORCE_PACKAGE` ist keine DCS-Gruppe und keine MOOSE-Legion.

Erforderliche Kette:

```text
FORCE_PACKAGE_REF
-> MATERIALIZATION_MAPPING
-> eligible template or existing physical entity
-> owning faction and support authority check
-> eligible AIRWING BRIGADE cohort or OPSGROUP
```

Der Adapter darf nur bereits autorisierte und reservierte Force Packages berücksichtigen. MOOSE darf taktisch geeignete Assets auswählen, aber diese Auswahl darf nicht:

- Fraktionseigentum ändern;
- nicht genehmigte Partnerkräfte verwenden;
- Resource Reservations umgehen;
- virtuelle oder verlorene Force Packages spontan materialisieren;
- Mission-Editor-Namen aus einem LLM-Text erzeugen.

## 13. Idempotenz und Mapping Registry

Vor dem ersten MOOSE-Dispatch muss ein persistenter oder reproduzierbar rekonstruierbarer Mapping-Eintrag angelegt werden.

Mindeststruktur:

```yaml
adapter_mapping:
  mapping_id: string
  mapping_version: integer
  campaign_id: string
  dcs_session_id: string
  command_id: string
  idempotency_key: string
  operation_id: string|null
  operation_task_id: string|null
  capability_profile_ref: string
  moose_object_type: AUFTRAG|OPSTRANSPORT|OPERATION|OPSGROUP
  moose_runtime_ref: opaque
  dispatch_owner_type: COMMANDER|LEGION|OPSGROUP
  dispatch_owner_ref: opaque
  lifecycle_state: string
  created_at: datetime
  last_observed_at: datetime
```

Wiederholte Zustellung desselben `idempotency_key` darf niemals ein zweites taktisches Objekt erzeugen.

```text
SAME_IDEMPOTENCY_KEY
-> SAME_EFFECT
-> NO_DUPLICATE_AUFTRAG
-> NO_DUPLICATE_OPSTRANSPORT
```

## 14. Update- und Abort-Semantik

### 14.1 Update

Es gibt keinen freigegebenen generischen Runtime-Befehl, der beliebige Felder eines laufenden AUFTRAG-Objekts sicher mutiert.

Bis zur DCS-Acceptance gilt:

```text
UPDATE_OPERATION
-> validate requested change against capability-specific update matrix
-> apply only explicitly tested setter or FSM event
-> otherwise reject as UNSUPPORTED_RUNTIME_UPDATE
```

Ein stilles Cancel-and-Recreate ist nicht gleichbedeutend mit einem Update und darf nur als ausdrücklich definierte Fachtransaktion eingesetzt werden.

### 14.2 Abort

Der geprüfte COMMANDER-Quellstand bietet `MissionCancel()` und leitet die Abbruchanforderung an zugeordnete Legions und OPS-Gruppen weiter.

Der Adapter muss beim Abbruch:

1. alle zugehörigen AUFTRAG- und OPSTRANSPORT-Mappings ermitteln;
2. bereits terminale Objekte als idempotenten No-op behandeln;
3. den passenden Owner-Pfad verwenden;
4. das beobachtete MOOSE-Ergebnis abwarten;
5. keine Kampagnenressourcen allein aufgrund des gesendeten Cancel-Befehls freigeben;
6. erst nach Result Translator und Adjudication den CampaignState ändern.

## 15. Event- und Ergebnisbrücke

Relevante source-level Kandidaten sind unter anderem:

```text
COMMANDER:OnAfterMissionAssign
COMMANDER:OnAfterOpsOnMission
COMMANDER:OnAfterMissionCancel
COMMANDER:OnAfterTransportAssign
COMMANDER:OnAfterTransportCancel
AUFTRAG:OnAfterSuccess
AUFTRAG:OnAfterFailed
AUFTRAG cancellation and terminal FSM events
OPERATION phase and over events
```

Jeder Callback wird zunächst in eine technische Beobachtung übersetzt. Er darf nicht unmittelbar einen strategischen Erfolg behaupten.

Beispiel:

```text
AUFTRAG OnAfterSuccess
-> TACTICAL_MOOSE_MISSION_REPORTED_SUCCESS
-> observation and evidence collection
-> operation completion rule evaluation
-> adjudicated campaign event
```

```text
MOOSE_SUCCESS != STRATEGIC_EFFECT_ACHIEVED
DCS_GROUP_DESTROYED != RESOURCE_SOURCE_NEUTRALIZED
MISSION_CANCELLED != RESOURCE_RESERVATION_RELEASED
```

## 16. Materialisierungspolitik

| `materialization_policy` | Adapterwirkung |
|---|---|
| `VIRTUAL_ONLY` | keine MOOSE-Objekte; ausschließlich CampaignState |
| `EVENT_ONLY` | keine dauerhafte physische Ausführung; gegebenenfalls adjudiziertes Ereignis |
| `HYBRID` | nur ausgewählte Tasks werden physisch materialisiert |
| `PHYSICAL_REQUIRED` | genehmigte physische Tasks müssen erfolgreich gemappt werden oder der Adapter lehnt den Plan ab |

Ein `PHYSICAL_REQUIRED`-Plan darf nicht stillschweigend als rein virtuelles Ereignis abgeschlossen werden.

## 17. Rolle von MOOSE-`OPERATION`

MOOSE-`OPERATION` ist als optionaler Container sinnvoll, wenn:

- mehrere physische AUFTRAG-Objekte phasenweise koordiniert werden;
- MOOSE-seitige Start-, Over- oder Phasenbedingungen benötigt werden;
- ein taktischer Branchwechsel innerhalb der laufenden DCS-Sitzung erforderlich ist;
- Legions oder Cohorts für den taktischen Ablauf dediziert werden sollen.

MOOSE-`OPERATION` sollte im ersten minimalen Adapter nicht zwingend verwendet werden, wenn ein einzelner AUFTRAG ausreichend ist. Dadurch wird eine unnötige zweite Kampagnen-State-Machine vermieden.

Verbindliche Grenze:

```text
CAMPAIGN_LIFECYCLE_OWNED_BY_ORCHESTRATOR
TACTICAL_PHASE_EXECUTION_MAY_BE_DELEGATED_TO_MOOSE_OPERATION
```

## 18. Warum `CHIEF` ausgeschlossen bleibt

Der bestehende OMW-Klassenindex führt `CHIEF` als `REJECTED_FOR_PROJECT_USE`.

Das Multi-Commander-Projekt besitzt bereits:

- getrennte strategische Commander;
- subjektive CommanderViews;
- Validierung und Adjudication;
- Ressourcen- und Eigentumsmodelle;
- einen autoritativen OperationPlan;
- Fog-of-War-Grenzen.

Eine zusätzliche automatische CHIEF-Ebene könnte Ziele, Zonen und Missionen eigenständig ableiten und damit die autoritative Entscheidungs- und Wissensgrenze umgehen.

Daher:

```text
NO_CHIEF_IN_FIRST_ADAPTER
NO_CHIEF_AS_LLM_REPLACEMENT
NO_CHIEF_DIRECT_ZONE_TRUTH_BYPASS
```

Eine spätere Neubewertung benötigt eine eigene Architekturentscheidung und Acceptance.

## 19. Minimaler Adapter-Scope für den ersten Test

Der erste isolierte DCS-Test sollte genau einen engen, ungefährlichen und vollständig beobachtbaren Pfad abdecken.

Empfohlener Scope:

```text
one fixed capability profile
one pre-existing target mapping
one approved provider mapping
one AUFTRAG
one COMMANDER or one LEGION
one idempotency retry
one explicit abort
one success or failure callback
no LLM
no dynamic schema selection
no OPERATION phases
no OPSTRANSPORT
```

Der konkrete Missionstyp, die Basis, das Template und der Zielname werden erst nach Prüfung der vorhandenen OMW-Manifeste und Testmissionen festgelegt.

## 20. Erforderliche Acceptance-Tests

### AT-01 Konstruktion

- genau ein AUFTRAG wird aus einem validen AdapterCommand erzeugt;
- unbekanntes Capability Profile wird abgelehnt;
- keine dynamische Methodenauflösung aus Vertragsdaten.

### AT-02 Idempotenz

- identischer `idempotency_key` wird zweimal zugestellt;
- es entsteht nur ein MOOSE-Missionsobjekt;
- zweites Result ist `DUPLICATE_NOOP` oder verweist auf das vorhandene Result.

### AT-03 Provider-Auswahl

- nur autorisierte Legion oder Cohort ist zulässig;
- ungeeignete beziehungsweise nicht verfügbare Assets führen zu kontrolliertem Ergebnis;
- keine fremde Fraktionsressource wird verwendet.

### AT-04 Zeit

- UTC-/Campaign-Zeit wird reproduzierbar in DCS-Zeit umgerechnet;
- Mission-Restart und Session-ID-Wechsel werden erkannt;
- abgelaufener Befehl wird nicht materialisiert.

### AT-05 Abort

- queued, assigned und executing Zustände werden getrennt geprüft;
- Abbruch erzeugt keine Doppelereignisse;
- Ressourcenfreigabe erfolgt erst nach Adjudication.

### AT-06 Ergebnisbrücke

- MissionAssign, OpsOnMission, Success, Failed und Cancel werden korreliert;
- Callback-Duplikate sind idempotent;
- strategischer Erfolg wird nicht allein aus einem MOOSE-Callback abgeleitet.

### AT-07 DCS-Neustart und Reconciliation

- alte Runtime-Handles werden nicht blind wiederverwendet;
- `RECONCILE_STATE` erkennt fehlende, zerstörte und noch vorhandene Objekte;
- Mapping-Version wird kontrolliert erhöht.

### AT-08 Negative Sicherheitstests

Der Adapter lehnt Payloads ab, die enthalten oder verlangen:

```text
lua
script
method
function
raw_moose_call
raw_dcs_task
unknown mission editor name
unapproved template reference
unmapped target reference
```

## 21. Vor Implementierung noch zwingend offen

```text
1 identify exact project Moose.lua used by the intended test branch
2 record Moose.lua SHA-256 and embedded commit header
3 prove or reject equivalence to reviewed source files
4 inspect official MOOSE demo missions for selected capability
5 define one capability profile and exact field mapping
6 define target and force-package mapping fixtures
7 define adapter update matrix
8 create isolated test mission
9 document DCS build mission hash bundle hash and OMW commit
10 run and record acceptance tests
```

## 22. Freigabestatus

```text
MOOSE_FIRST_REVIEW_STARTED = YES
SOURCE_LEVEL_CLASS_BOUNDARY_DOCUMENTED = YES
OPERATION_PLAN_TO_SINGLE_MOOSE_CLASS_MAPPING = REJECTED
FIXED_CAPABILITY_PROFILE_ARCHITECTURE = CANDIDATE
ACTUAL_MOOSE_LUA_VERIFIED = NO
OFFICIAL_DEMOS_CHECKED = NO
ADAPTER_IMPLEMENTED = NO
DCS_TESTED = NO
PRODUCTION_APPROVED = NO
MERGE_READY = NO
```

## 23. Quellen

### OMW

- `docs/00-project-governance.md`
- `docs/26-moose-first-development-policy.md`
- `docs/moose/PROJECT-CLASS-INDEX.md`
- `docs/moose/VERIFIED-METHODS.md`
- `docs/special-projects/llm-commanders/09-orchestrator-architecture-and-adjudication.md`
- `docs/special-projects/llm-commanders/19-language-neutral-contracts-and-json-schemas.md`

### MOOSE

- <https://github.com/FlightControl-Master/MOOSE/commit/23112c99545d8b052f850fe0680d77272d24433b>
- <https://github.com/FlightControl-Master/MOOSE/blob/23112c99545d8b052f850fe0680d77272d24433b/Moose%20Development/Moose/Ops/Auftrag.lua>
- <https://github.com/FlightControl-Master/MOOSE/blob/23112c99545d8b052f850fe0680d77272d24433b/Moose%20Development/Moose/Ops/Commander.lua>
- <https://github.com/FlightControl-Master/MOOSE/blob/23112c99545d8b052f850fe0680d77272d24433b/Moose%20Development/Moose/Ops/Operation.lua>
- <https://github.com/FlightControl-Master/MOOSE/blob/23112c99545d8b052f850fe0680d77272d24433b/Moose%20Development/Moose/Ops/OpsTransport.lua>
- <https://github.com/FlightControl-Master/MOOSE/blob/23112c99545d8b052f850fe0680d77272d24433b/Moose%20Development/Moose/Ops/OpsGroup.lua>
- <https://github.com/FlightControl-Master/MOOSE_INCLUDE/commit/0f62c084ddb1c54bb6467fa9b0c01c80d3a4e7f2>
