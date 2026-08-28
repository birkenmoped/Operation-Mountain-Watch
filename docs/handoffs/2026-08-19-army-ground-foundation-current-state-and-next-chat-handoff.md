---
document_id: OMW-HANDOFF-ARMY-GROUND-FOUNDATION-2026-08-19
status: PLANNED
document_class: IMPLEMENTATION_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - current continuation state of the Jalalabad and Kunar ARMY Ground Foundation
  - branch, acceptance, operational-domain and next-test context for the next development chat
not_authoritative_for:
  - repository-wide authority before merge to main
  - final ground-force ORBAT strengths
  - final Mission Editor coordinates
  - final production vehicle quantities for Fortress or Honaker-Miracle
  - merge or Ready-for-Review authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-HANDOFF-ARMY-GROUND-FOUNDATION-2026-08-18
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
validated_in_dcs: false
---

# ARMY Ground Foundation – aktueller Stand und Next-Chat-Handoff 19.08.2026

## 1. Zweck

Dieses Handoff ersetzt für die Fortsetzung des aktuellen Arbeitsstrangs das Handoff vom 18.08.2026. Es fasst den Branch-Ist-Stand nach Ground Acceptance 1 und 2, der Fortress-/Honaker-Reconciliation und der Vorbereitung des sechsfachen Ground-Integrationstests zusammen.

Zentrale Arbeitsdateien:

```text
docs/handoffs/2026-08-19-army-ground-foundation-current-state-and-next-chat-handoff.md
mission/tests/army-ground-foundation/TODO.md
docs/ground/ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION.md
mission/tests/army-ground-foundation/ACCEPTANCE-3.md
```

## 2. Repository und Arbeitsbranch

```text
Repository:
birkenmoped/Operation-Mountain-Watch

Arbeitsbranch:
agent/army-ground-foundation-reconciliation

Continuation base before this handoff commit:
6c3aadef471acbcb0295200e07f04580867f6e75

Branch base on main:
08f679926e5ac059e9853f54ffa7bb634063eaa4
```

Der lokale Stand des Projektinhabers kann hinter dem Remote-Branch liegen. Lokale Pull-/Build-/Hash-Verifikation wird nachgeholt, sobald wieder Zugriff auf die Entwicklungsstation besteht. Keine lokalen Ergebnisse oder Hashes annehmen oder simulieren.

## 3. Pflichtprüfung im neuen Chat

Vor weiterer fachlicher oder technischer Arbeit mindestens prüfen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
mission/tests/GOVERNANCE.md
docs/moose/VERSION-AND-SOURCES.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/GROUND-OPERATIONS.md
docs/moose/GROUND-ARMOREDGUARD-ACCEPTANCE.md
docs/11-bases-and-fobs.md
docs/ground/ARMY-GROUND-FOUNDATION-DOMAIN-CONTRACT.md
docs/ground/ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT.md
docs/ground/ARMY-GROUND-ROLE-AND-PLATOON-BASELINE.md
docs/ground/ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION.md
mission/tests/army-ground-foundation/TODO.md
mission/tests/army-ground-foundation/ACCEPTANCE-2.md
mission/tests/army-ground-foundation/ACCEPTANCE-3.md
this handoff
```

Bei MOOSE-Fragen zusätzlich die tatsächlich verwendete `Moose.lua`, passende MOOSE-Dokumentation und soweit relevant offizielle Demo-/Testmissionen prüfen. Keine API, Signatur, Event- oder FSM-Eigenschaft erfinden.

## 4. Verbindliche Arbeitsgrenzen

```text
Research / campaign period:
01.08.2010-31.12.2011

Active Ground ORBAT working reference:
JULY 2011

Project phase:
COMPLETE_FOUNDATION_BUILD_PHASE
```

Architektur:

```text
CampaignState
= sole strategic resource/state authority

MOOSE BRIGADE / PLATOON / ARMYGROUP / WAREHOUSE
= operational selection, materialization and lifecycle

DCS GROUP / UNIT
= temporary physical representation
```

ChatGPT verändert keine `.miz`. Mission-Editor-Arbeit erfolgt durch den Projektinhaber. Kein Merge oder Ready-for-Review ohne ausdrückliche Freigabe.

## 5. Aktueller Ground-Installationsscope

Nach der aktuellen Reconciliation werden sechs operative Ground-Standorte für den nächsten Integrationslauf geführt:

```text
Jalalabad / FOB Fenty
FOB Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick
```

Abhängige OPs bleiben separate Installationsobjekte und sind nicht Teil des unmittelbar nächsten sechsfachen Patrol-/Guard-Tests:

```text
COP Honaker-Miracle
`-- OP JoJo

FOB Bostick
+-- OP Mustang
+-- OP Clydesdale
`-- OP Stallion
```

## 6. Fortress – korrigierte Einordnung

Für OMW gilt:

```text
canonical display name: FOB Fortress
canonical stable ID: BLUE_GROUND_FOB_FORTRESS
historical source alias: COP Fortress
```

Mehrere historische Quellen verwenden unterschiedliche Klassifizierungen. Für OMW wird Fortress aufgrund der belegten Funktion als größerer, regelmäßig genutzter Ground-/Logistik-/Operationsstandort als FOB geführt.

Fortress erhält für den aktuellen MOOSE-Integrationsscope eine eigene operative Materialisierungs-/Lifecycle-Domäne:

```text
BDE_BLUE_GND_FORTRESS
WH_BLUE_GND_FORTRESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
```

Das beweist keinen separaten strategischen Ressourcenpool und keine endgültige permanente Fahrzeugstärke.

## 7. Honaker-Miracle – korrigierte Einordnung

Die frühere Behandlung als reine Destination ohne lokale operative Domäne ist für den aktuellen Arbeitsstand verworfen.

2011er Evidenz stützt:

```text
- COP Honaker-Miracle blieb beim Pech Realignment als gehaltene US-Stellung bestehen
- diente als staging ground für Operation Hammer Down
- Reservekräfte wurden von dort eingesetzt
- mehrere Resupply-Missionen waren erforderlich
- 2 x M777A2, C Battery / 3-321 FA, sind am 30.07.2011 direkt belegt
```

Daraus folgt für den aktuellen Test:

```text
BDE_BLUE_GND_HONAKER
WH_BLUE_GND_HONAKER
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_HONAKER_PATROL_TEST_01
```

Diese operative MOOSE-Domäne bedeutet ausdrücklich nicht, dass Honaker einen neu erfundenen unabhängigen CampaignState-Fahrzeugbestand erhält.

## 8. Parentage und physischer Dispatch sind getrennt

Der frühere implizite Vertrag

```text
direct strategic parent = mandatory physical dispatch origin
```

ist für die aktuelle Reconciliation zu grob.

Aktuelle Grenze:

```text
CampaignState parent / strategic obligation
!= physical dispatch origin
```

Honaker bleibt vorerst CampaignState-seitig an Joyce gebunden. Für konkrete physische Supportmissionen können abhängig von MissionDemand, Verfügbarkeit, Route und Geografie auch Wright, Joyce oder lokaler Honaker-Bestand als Dispatch-Ursprung dienen. Wright wird dadurch nicht zum strategischen Parent.

## 9. Geplante sechsfach MOOSE-Topologie

```text
BLUE COMMANDER
|
+-- BDE_BLUE_GND_JALALABAD
|   `-- WH_BLUE_GND_FENTY
|
+-- BDE_BLUE_GND_FORTRESS
|   `-- WH_BLUE_GND_FORTRESS
|
+-- BDE_BLUE_GND_JOYCE
|   `-- WH_BLUE_GND_JOYCE
|
+-- BDE_BLUE_GND_WRIGHT
|   `-- WH_BLUE_GND_WRIGHT
|
+-- BDE_BLUE_GND_HONAKER
|   `-- WH_BLUE_GND_HONAKER
|
`-- BDE_BLUE_GND_BOSTICK
    `-- WH_BLUE_GND_BOSTICK
```

`BDE_` ist eine technische MOOSE-Domäne und behauptet keine historische Brigadegliederung.

## 10. Ground Acceptance 1 – bestätigter technischer Stand

Acceptance 1 bestätigte im realen DCS-Lauf für die Joyce-Testgruppe:

```text
BRIGADE / PLATOON startup
one materialization
MissionDone with SetReturnToLegion(false)
same physical ARMYGROUP retained
same-group follow-up mission reuse
spawnCount = 1
```

Die verwendete `PATROLZONE`-Bewegung wurde nicht als Production-Fahrzeugverhalten übernommen. Die kleinen Kreise im ACCESS-Bereich blieben als Routing-/Pathfinding-Quality-Note dokumentiert.

## 11. Ground Acceptance 2 – bestätigter technischer Stand

Acceptance 2 ersetzte `PATROLZONE` durch zwei MOOSE-`ARMOREDGUARD`-Aufträge:

```text
ACCESS
-> ARMOREDGUARD / On Road
-> approach halt
-> MissionDone + SetReturnToLegion(false)
-> same physical ARMYGROUP
-> ARMOREDGUARD / Vee
-> FullStop / stable observation halt
```

Realer Runtime-Lauf bestätigte insbesondere:

```text
one materialization
same-group reuse
approach reached
Vee mission executed
stable hold
spawnCount = 1
no OMW_GND_A2 FAIL marker
```

Owner-Beobachtung:

```text
- Verhalten deutlich besser als PATROLZONE
- Convoy-Reise grundsätzlich plausibel
- sichtbarer Wechsel in Vee im Zielgebiet
- Reisegeschwindigkeit des A2-Laufs zu langsam
- DCS-Zeitbeschleunigung wurde deshalb benutzt
```

Die dokumentierte TM01M-Konvoi-Baseline verwendet `50 km/h`. Acceptance 3 setzt deshalb den normalen Straßenmarsch auf `27 kt` als technische Annäherung an ca. `50 km/h`.

## 12. Bewegungsvertrag für Acceptance 3

```text
NORMAL ROAD TRANSIT
ARMOREDGUARD
On Road
27 kt (~50 km/h)

TACTICAL FINAL LEG
ARMOREDGUARD
Vee
8 kt

OBJECTIVE
FullStop
stable hold
SetReturnToLegion(false)
```

Die 8 kt der taktischen Endphase sind weiterhin Testwert, keine historische Doktrinvorgabe.

## 13. Acceptance 3 – aktueller nächster Test

Dateien:

```text
mission/tests/army-ground-foundation/ACCEPTANCE-3.md
mission/tests/army-ground-foundation/src/03-army-ground-acceptance-3.lua
tools/build-army-ground-acceptance-3.ps1
```

Testscope:

```text
FENTY
FORTRESS
JOYCE
WRIGHT
HONAKER
BOSTICK
```

Acceptance 3 prüft gemeinsam:

```text
- six BRIGADE instances resolve and start
- six physical warehouse hosts resolve
- six independent ACCESS materializations
- exactly one test patrol group per domain
- no alias/callback/state collision between domains
- normal road transit at 27 kt mission speed
- no prolonged spawn-area circling
- final tactical Vee transition
- ARMOREDGUARD stable hold
- same-group lifecycle continuity
- no duplicate materialization
- no visible teleport/despawn
- DCS pathfinding quality at all six sites
```

Fortress- und Honaker-Assets sind in diesem Test `test-only operational allocation`. Aus dem Test darf keine permanente Property-Book-Menge abgeleitet werden.

## 14. Mission-Editor-Gate für Acceptance 3

Vor lokalem Build und DCS-Lauf muss die aktuelle Owner-`.miz` read-only gegen mindestens folgende Objekte geprüft werden:

```text
WH_BLUE_GND_FENTY
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_JOYCE
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_HONAKER
WH_BLUE_GND_BOSTICK

ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS

ZON_BLUE_GND_FENTY_PATROL_TEST_01
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
ZON_BLUE_GND_WRIGHT_PATROL_TEST_01
ZON_BLUE_GND_HONAKER_PATROL_TEST_01
ZON_BLUE_GND_BOSTICK_PATROL_TEST_01

TPL_BLUE_GND_PATROL_MATV_4
```

Das gemeinsame Template bleibt:

```text
TPL_BLUE_GND_PATROL_MATV_4
4 x CHAP_MATV
late activation
```

ChatGPT verändert die `.miz` nicht.

## 15. Working Vehicle Baseline – nicht stillschweigend ändern

Aktuell dokumentierte produktionsnahe Bestände:

```text
Jalalabad / Fenty   48 wheeled vehicles
FOB Joyce           20 wheeled vehicles
FOB Wright          22 wheeled vehicles
FOB Bostick         26 wheeled vehicles
Honaker-Miracle      0 previously assigned permanent wheeled vehicles
                      2 x M777A2 fixed artillery confirmed
Fortress             production vehicle quantity NOT YET DECIDED
```

Die neue operative Honaker-Domäne hebt die frühere `0 permanent wheeled vehicles`-Baseline **nicht automatisch** auf. Ebenso erzeugt Fortress keine permanente Fahrzeugmenge durch die Aufnahme in Acceptance 3.

Eine spätere Mengenentscheidung benötigt eine eigene Owner-Entscheidung auf Basis historischer Evidenz und Gameplay-Anforderung.

## 16. MOOSE-first bestätigte Bausteine für den aktuellen Pfad

Gepinnter Stand:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für den aktuellen Testpfad source-geprüft bzw. in Acceptance 1/2 praktisch eingesetzt:

```lua
BRIGADE:New(...)
WAREHOUSE:SetSpawnZone(...)
PLATOON:New(...)
COHORT:AddMissionCapability(...)
COHORT:CountAssets(...)
LEGION:AddMission(...)
AUFTRAG:NewARMOREDGUARD(...)
AUFTRAG:SetMissionSpeed(...)
AUFTRAG:SetReturnToLegion(false)
AUFTRAG:__Cancel(...)
COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:GetClosestPointToRoad(...)
OPSGROUP MissionExecute / MissionDone callbacks
ARMYGROUP:FullStop()
```

Keine eigene Native-DCS-Routing-/Spawn-/Formation-Implementierung ergänzen, solange MOOSE den aktuellen Pfad ausreichend abbildet.

## 17. Noch ausdrücklich offene Punkte

Nicht als erledigt behandeln:

```text
- read-only Prüfung der neuesten Owner-.miz gegen alle Acceptance-3-Objekte
- lokaler Build von Acceptance 3
- realer Bundle-SHA-256
- Einbindung des erzeugten Bundles in die Owner-Test-.miz
- finaler MIZ-/internal-mission-/embedded-bundle-/embedded-Moose-Hash
- realer sechsfacher DCS-Integrationstest
- Fortress production vehicle/personnel baseline
- Honaker permanent/mobile vehicle contract after operational-domain reconciliation
- final selection logic for Honaker physical support origin
- mobile return/handoff and Warehouse return acceptance
- CampaignState runtime adapter / exactly-once settlement
- OPSTRANSPORT validation
- restart/reconstitution validation
- QRF / logistics / OP reinforcement production tests
```

## 18. Arbeitsreihenfolge für den nächsten Chat

```text
1. Governance and main authority check
2. Verify remote branch head and read this handoff + TODO
3. Do not reopen already closed Acceptance-1/2 architecture questions without new evidence
4. Check newest owner .miz read-only when available
5. Reconcile missing/incorrect six-domain ME objects only as owner instructions; ChatGPT does not mutate .miz
6. Build Acceptance 3 locally only when owner has workstation access
7. Record real build hash and exact source commit
8. Owner embeds bundle and returns final hashes
9. Run one six-domain DCS integration test
10. Evaluate logs + owner visual observations
11. Update acceptance/MOOSE docs only from real evidence
12. Continue to return/handoff, CampaignState settlement and other Ground Foundation functions after the multi-domain gate
```

## 19. Startauftrag für einen neuen Chat

Der folgende Text kann direkt als Startauftrag verwendet werden:

```text
Lese und beachte vollständig:

docs/handoffs/2026-08-19-army-ground-foundation-current-state-and-next-chat-handoff.md
mission/tests/army-ground-foundation/TODO.md
docs/ground/ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION.md
mission/tests/army-ground-foundation/ACCEPTANCE-3.md

Arbeitsbranch:
agent/army-ground-foundation-reconciliation

Continuation-Basis vor dem Handoff:
6c3aadef471acbcb0295200e07f04580867f6e75

Setze die ARMY Ground Foundation exakt ab dem aktuellen Remote-Stand dieses Branches fort.
Prüfe zuerst AGENTS.md, Governance und MOOSE-First auf main, danach Branch-Ist-Stand, dieses Handoff und TODO.

Ground Acceptance 1 und 2 besitzen reale DCS-Evidenz. Acceptance 3 ist als sechsfacher Integrationstest für Fenty, Fortress, Joyce, Wright, Honaker-Miracle und Bostick vorbereitet, aber noch nicht lokal gebaut oder in DCS ausgeführt.

Keine .miz-Änderungen durch ChatGPT.
Keine MOOSE-API oder DCS-Eigenschaft erfinden.
CampaignState bleibt alleinige strategische Ressourcenautorität.
Fortress/Honaker-Testassets erzeugen keine stillschweigende permanente Fahrzeugstärke.
Noch kein Merge oder Ready-for-Review ohne meine ausdrückliche Freigabe.
Keine lokalen Builds, Hashes oder DCS-Ergebnisse annehmen oder simulieren.
Kein CODEX.
```

## 20. Übergabegrenze

Der neue Chat soll nicht bei der historischen Grundsatzdiskussion von vorne beginnen. Maßgeblicher Arbeitsstand ist:

```text
Acceptance 1 -> lifecycle baseline demonstrated
Acceptance 2 -> ARMOREDGUARD OnRoad -> Vee -> stable hold demonstrated
Fortress -> canonical OMW FOB, own operational MOOSE domain planned
Honaker -> active COP with local operational/staging domain planned
Six-domain topology -> prepared
Acceptance 3 -> next real integration gate
```

Neue Evidenz darf diesen Stand selbstverständlich ändern; Änderungen müssen jedoch gegen Governance, Quellqualität, CampaignState-Autorität und den tatsächlich verwendeten MOOSE-Stand geprüft werden.
