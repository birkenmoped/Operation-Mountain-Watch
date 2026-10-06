---
document_id: OMW-HANDOFF-FSSR-BASE-MULTISITE-20261002
status: PLANNED
document_class: CHAT_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - current Fire Support / Strategic Resupply branch handoff after A10 DCS PASS
  - next-chat development sequence toward the general Production Base
  - Acceptance 11 multi-FOB/COP autonomous full-response target
not_authoritative_for:
  - repository-wide governance before merge to main
  - new MOOSE/native-DCS exceptions
  - DCS validation beyond cited exact provenance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-HANDOFF-FSSR-FINAL-BASE-PREPARATION-20260920
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – Übergabe nach A10 zur Multi-Site-Base

## 1. Auftrag des Folgechats

Auf demselben Branch weiterarbeiten:

~~~text
repository: birkenmoped/Operation-Mountain-Watch
branch: agent/fire-support-strategic-resupply-base-gate0
PR: #149
status: OPEN / DRAFT
~~~

Ziel ist die allgemeine Production Base, nicht ein weiterer standortspezifischer Testadapter.

Der naechste grosse DCS-Test ist Production Base Acceptance 11:

~~~text
several FOBs/COPs attacked by existing RED late-activation groups
-> multiple installation incidents
-> overlapping ARTY / mortar / CAS / Strategic Resupply demands
-> MOOSE processes operational selection/recruitment without OMW provider preselection
-> accepted production lifecycles execute independently and concurrently
~~~

## 2. Pflicht-Lesereihenfolge

Vor jeder Implementierung vollstaendig lesen:

~~~text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/adr/0008-fire-support-strategic-resupply-resource-authority.md
docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md
docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-ASSEMBLY.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-EXTERNAL-SUPPORT.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-RESOURCE-MONITOR.md
docs/moose/FIXED-FIRE-SUPPORT-REARM.md
docs/moose/VERIFIED-METHODS.md
docs/moose/PROJECT-CLASS-INDEX.md
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-9.md
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-10.md
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-11.md
results/2026-09-20-production-base-acceptance9-dcs-pass.md
results/2026-10-02-production-base-acceptance10-real-arty-dcs-pass.md
~~~

Fuer Strategic Resupply zusaetzlich die aktuell referenzierten OPSTRANSPORT/STORAGE-/Ground-Resupply-Acceptance- und Settlement-Dokumente lesen, bevor Production-Code veraendert wird.

## 3. Nicht verhandelbare Arbeitsregeln

~~~text
MOOSE first.
CampaignState = strategic resource authority.
MOOSE = operational selection/recruitment/physical lifecycle.
No second provider selector.
No second resource ledger.
No second fire/rearm/CAS/return FSM.
No guessed MOOSE API.
No MIST.
No CODEX.
No .miz mutation by ChatGPT.
Owner integrates built LUA into the .miz.
PR #149 remains Draft without explicit owner instruction.
~~~

Bei vorhandener Acceptance gilt:

~~~text
inherit -> reuse -> minimally adapt -> test changed boundary
~~~

## 4. Gepinnter MOOSE-Stand

~~~text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
~~~

Vor neuer API-Nutzung: MOOSE docs -> exact pinned Moose.lua -> signatures/returns/events/FSM -> official demos/tests where relevant.

## 5. Aktueller Branchstand bei Übergabe

Vor dieser Dokumentationsrunde:

~~~text
remote head:
9f866d15a634f94245127947d89b19a668325d5d

MissionDemand validation #1097 = PASS
Documentation validation #2326 = PASS
~~~

Der neue Handoff-Commit folgt darauf. Der Folgechat muss den dann aktuellen Remote-HEAD und CI erneut verifizieren.

## 6. DCS-validierte Reuse-Baselines

### 6.1 QRF

~~~text
incident participants
-> nearest living authorized target
-> same ARMYGROUP
-> EngageTarget(... On Road)
-> Disengage/reacquire
-> no living authorized targets
-> Cancel
-> ReturnToLegion / RTZ / Returned
~~~

Keine neue QRF-/Strassen-/Spawnlogik ohne realen Fehler gegen diese Baseline.

### 6.2 Rotary CAS – A9

~~~text
source commit:
c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2
bundle:
D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0
DCS:
2.9.29.27468
MOOSE:
2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
~~~

Validiert: MOOSE provider/asset selection -> selected-provider execution profile -> owner route -> tactical ingress/mission/distinct egress -> own FLIGHTGROUP detection -> profile-specific release -> controlled closure -> reverse owner route -> home landing -> exact LegionAssetReturned.

### 6.3 Functional ARTY + M1083

~~~text
source/build:
d52a47a418fe3a1a996a5b68198b8dc033ff86c4
bundle:
CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B
mission:
388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620
DCS:
2.9.28.26385 MT
~~~

Invarianten: one Functional ARTY owner, AssignTargetCoord, CeaseFire, startArty=false on rearm, CampaignState consumption at accepted hook, M1083 physical rearm, ARTY Rearmed, M1083 return-to-stock.

### 6.4 A10 Real ARTY/Mortar selection – neu akzeptiert

~~~text
acceptance source commit:
4c8793a9b155f85e7a229117725fca55f58987c3
mission SHA-256:
95F28962F15659399051813F426A1401797EA95F931588349F9EAB1523E28232
bundle SHA-256:
FA0CD024F050BA19DECAEE9AB1EF71C35B976346A327D118EFCC59DC249C84C9
DCS:
2.9.30.28536 MT
MOOSE:
2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
~~~

Validierte neue Kette:

~~~text
late-activation real fixed-fire-support template
-> PLATOON / site BRIGADE / real Warehouse Assetitem
-> exact LoadBackAssetInPosition materialization
-> real ARMYGROUP / asset.flightgroup
-> COMMANDER CanMission + RecruitAssetsForMission
-> real asset reservation
-> exact physical group
-> Functional ARTY owner
-> fire
-> CeaseFire
-> UnRecruitAssets
-> accepted M1083 rearm
~~~

A10 hatte Wright und Honaker gleichzeitig als geeignete Provider. Der Harness gab keinen Provider vor. MOOSE selektierte Wright.

Maximal beobachtete emplacement-Abweichung: 0.014 m. Wright: 300 -> 296 rounds, rearm -> 301, stationary after fire/rearm, M1083 returned to stock.

## 7. A10-Irrwege und Erfahrungen

Bereits aktive ME-Batterien duerfen nicht als bereits existierende BRIGADE/Warehouse-Assets behandelt werden. BRIGADE:AddPlatoon fuehrt in den Warehouse-Lifecycle; das ist keine In-place-Adoption.

Die Descriptor-only-Option war ein technisch moeglicher Selection-Token, wurde aber vor DCS-Acceptance superseded, nachdem der Owner die MOOSE-Materialisierung der realen Batterien freigegeben hat. Die finale Base soll diesen Descriptor-Pfad nach Referenzpruefung aus der aktiven Composition entfernen.

ARMYGROUP kann bestehende Gruppen wrappen, loeste aber weder die COMMANDER/LEGION-Rekrutierung noch die Single-Owner-Frage des bereits akzeptierten Functional ARTY. Nicht als Alternativpfad zurueckbringen.

BRIGADE:LoadBackAssetInPosition ist fuer den engen A10-Fixed-Battery-Bootstrap nun real DCS-belegt. Daraus keine allgemeine OMW-Spawnregel ableiten.

MOOSE-Runtime-Gruppennamen wie WrightArtillery_AID-221#001 sind keine strategischen IDs. Stable OMW IDs bleiben erforderlich.

Der erste A10-Lauf scheiterte an Fortress nicht-Late-Activation; der zweite Lauf bestand. Vor A11 alle Fixed-Fire-Support-Templates auf korrekten Startzustand pruefen.

Der bhHook.lua tcp-nil Fehler trat nach Dispatcher Stop auf und gehoert nicht zum FSSR-Lifecycle.

## 8. Was A10 nicht bewiesen hat

~~~text
multiple simultaneous support demands
contention/queueing across busy/reserved assets
selected 2B11 fire path
multiple simultaneous CAS requests
additional CAS owner profiles
Strategic Resupply physical OPSTRANSPORT/STORAGE lifecycle
combined multi-FOB/COP full response
~~~

## 9. Strategic Resupply – aktueller Stand

Bereits vorhanden/source- bzw. contract-tested:

~~~text
CampaignState ResourceDemandPolicy
MissionDemand
ResupplyMonitor
StorageTransportFactory
TransportRuntime
TransportSettlement
MOOSE OPSTRANSPORT/STORAGE composition
~~~

Noch nicht als allgemeiner physischer FSSR-Lifecycle DCS-akzeptiert:

~~~text
shortage
-> demand
-> strategic reservation
-> MOOSE carrier/provider recruitment
-> physical pickup/loading
-> in-transit evidence
-> physical delivery or loss
-> idempotent CampaignState settlement
~~~

Strategic Resupply ist nicht dasselbe wie der lokale M1083 ARTY rearm. PARTIAL delivery bleibt offen, solange keine allgemeine CampaignState-Teiltransfer-Semantik beschlossen/implementiert ist.

## 10. Nächste Entwicklungsreihenfolge

~~~text
1. reconcile current branch against mandatory docs/current main
2. remove/supersede obsolete descriptor composition only after reference check
3. close Strategic Resupply physical lifecycle using existing OPSTRANSPORT/STORAGE/Settlement code
4. ensure production state is demand-scoped and supports concurrent incidents
5. ensure 2B11 selected-fire owner handoff uses the same generic RealAssetRegistry/Functional ARTY path
6. ensure CAS candidate profiles needed for autonomous multi-demand selection are available/fail-closed
7. build combined Base composition without provider preselection
8. implement A11 observer-only multi-site harness
9. CI/static/unit checks
10. remote commit/push
11. owner local LUA build + hashes
12. owner inserts LUA into MIZ
13. owner runs real multi-FOB/COP DCS acceptance
14. evaluate logs against A11
~~~

## 11. Acceptance 11 – Ownerentscheidung

~~~text
next DCS test:
attack on multiple FOBs/COPs

RED:
use the existing late-activation RED attack groups still present in the owner MIZ

core question:
can MOOSE process multiple support requests autonomously without OMW specifying the concrete provider?

required support coverage:
ARTY
mortar
CAS
Strategic Resupply
~~~

Guard/QRF gehoeren zur Full-Response-Kette und muessen regressionsfrei bleiben. Die Acceptance muss echte Ueberlappung erzeugen; isolierte nacheinander abgespielte Smoke-Tests beweisen die geforderte Multi-Demand-Orchestrierung nicht.

## 12. Provider-Autonomie

Verboten: site-to-provider mapping, fixed Wright/Honaker mapping, fixed Jalalabad AH-64, fixed Squadron, fixed carrier, eigener nearest-provider selector oder OMW fallback.

Zulaessig: demand + geometry + capability/range + availability + owner execution profiles -> MOOSE selection/recruitment.

Wenn kein geeigneter/freier Provider existiert, gilt MOOSE queue/wait/reject semantics; kein OMW-Bypass.

## 13. Mortar-Nachweis

A10 materialisierte Honaker und zeigte ihn als reichweitenfaehig, aber Wright wurde selektiert. A11 muss erstmals beobachten:

~~~text
MOOSE selects real 2B11 asset
-> selected physical group maps to Functional ARTY owner
-> mortar fires
-> ammo decreases
-> CeaseFire
-> reservation release
-> fixed position preserved
~~~

Der Harness darf Honaker nicht direkt waehlen. Reale Range-/Capability-/Availability-Constraints und gleichzeitige Belegung anderer Assets sind legitime MOOSE-Auswahlbedingungen.

## 14. CAS-Nachweis

A9 beweist einen Rotary-Wing-CAS-Lifecycle, nicht beliebige Providerprofile. Vor A11 muss jeder von MOOSE auswählbare CAS-Provider entweder ein freigegebenes owner execution profile besitzen oder fail closed behandelt werden. Kein Direct-Line-Fallback.

A11 soll mehrere CAS-Demands ueberlappen lassen, ohne AIRWING/SQUADRON/Asset vorzugeben.

## 15. Strategic-Resupply-Nachweis

Mindestens ein realer Resource-Shortage-Demand muss im Combined Run entstehen:

~~~text
resource <= threshold
-> MissionDemand
-> CampaignState reserve exactly once
-> MOOSE OPSTRANSPORT/STORAGE recruitment/execution
-> physical lifecycle
-> confirmed delivery/loss
-> idempotent settlement exactly once
~~~

Der Acceptance-Harness darf keine Carrier-Instanz waehlen.

## 16. GitHub-/MIZ-Workflow

ChatGPT: inspect -> implement -> tests/docs -> commit -> push. Danach nur nummerierte Owner-Schritte fuer git pull, LUA build und hash verification.

Der Owner baut lokal, setzt das erzeugte LUA selbst in die MIZ ein, startet DCS und liefert reale Hash-/Log-Evidenz. ChatGPT mutiert die MIZ nicht.

## 17. Stop-Grenzen

Nicht raten, wenn die pinned MOOSE API nicht nachweisbar ist, ein Shortcut einen zweiten Provider-Selector erzeugen wuerde, Strategic Resupply CampaignState duplizieren wuerde, ein CAS-Provider kein Execution Profile besitzt, ein Harness einen akzeptierten Lifecycle besitzen muesste, konkrete RED-Fixture-Namen unbekannt sind oder eine stille MIZ-Aenderung notwendig waere.

## 18. Kurzfassung

~~~text
A9 CAS lifecycle = accepted exact-provenance baseline.
A10 real fixed ARTY/Mortar representation + MOOSE selection = accepted exact-provenance baseline.
Fixed batteries may be MOOSE-materialized at their original positions and must never relocate.
A10 proved Wright/Honaker both eligible and MOOSE selected Wright without OMW provider preselection.
A10 did NOT prove concurrent multi-demand handling, selected mortar fire or Strategic Resupply.
Next block = general Base + Strategic Resupply + multi-demand orchestration.
Next DCS acceptance = multiple FOB/COP attacks using existing RED late-activation fixtures.
A11 must prove MOOSE handles overlapping ARTY, mortar, CAS and Strategic Resupply demands without hard-coded provider selection.
Harness = observer/stimulus only.
Owner builds LUA and inserts it into MIZ.
PR #149 stays Draft.
~~~


## 19. Strategic-Resupply-Reconciliation nach Handoff

Beim Folgeabgleich wurde bestaetigt, dass die Stage-3-STORAGE-Arbeit die
gepinnten MOOSE-Grenzen bereits beruecksichtigt hatte. Der historische Pfad nutzte:

~~~text
LEGION.RecruitCohortAssets(... AUFTRAG.Type.OPSTRANSPORT ..., physical weight)
-> OPSTRANSPORT:AddAsset
-> AIRWING:TransportAssign
~~~

Die zwischenzeitliche generische Base-Vereinfachung
`COMMANDER:AddOpsTransport(...)` war fuer STORAGE-only-Cargo nicht
lifecycle-treu. Sie wird deshalb **nicht** als neue Architektur beibehalten.

Die generalisierte Base verwendet stattdessen den oeffentlichen COMMANDER-Wrapper:

~~~text
COMMANDER:RecruitAssetsForTransport(...)
-> MOOSE cohort/provider/asset selection
-> OPSTRANSPORT:AddAsset(selected Assetitems)
-> COMMANDER:TransportAssign(selected Legions)
~~~

Damit bleibt die konkrete Auswahl bei MOOSE, ohne die alte Acceptance-spezifische
Jalalabad-/CH-47-Vorgabe zu uebernehmen. CampaignState und TransportSettlement bleiben
unveraendert strategische bzw. Settlement-Autoritaet.

Dieser Block ist Reconciliation eines vorhandenen Projektpfads, keine neue
Carrier-Policy.


## 20. Strategic-Resupply route-preservation reconciliation – 04.10.2026

Nach der Carrier-Recruitment-Korrektur wurde vor A11 auch der historische physische
Air-Resupply-Routenvertrag abgeglichen. Stage 3 verwendete bereits die gemeinsame
Produktionskomponente:

~~~text
OMW_OpsTransportCorridorAdapter
-> selected FLIGHTGROUP OnAfterTransport
-> owner-authored FlightPath outbound
-> OPSTRANSPORT delivery
-> selected FLIGHTGROUP OnAfterDelivered
-> owner-authored FlightPath reverse
~~~

Die allgemeine Base muss diesen Pfad direkt wiederverwenden. Ein A11-Harness darf ihn
nicht kopieren oder neu besitzen.

Neue allgemeine Bindung:

~~~text
COMMANDER:RecruitAssetsForTransport
-> MOOSE-selected Assetitem / Legion
-> selected Legion OnAfterAssetSpawned
-> exact asset.flightgroup
-> existing OMW_OpsTransportCorridorAdapter:Bind
~~~

Keine AIRWING-/SQUADRON-/Carrier-Vorauswahl wird eingefuehrt. Bei einem als erforderlich
markierten, aber fehlenden/ungueltigen Korridor wird fail-closed abgebrochen; direkte
Route ist kein Fallback.

Der geerbte geroutete Scope bleibt vorerst single-carrier. Multi-carrier routing/cargo
splitting ist keine stillschweigende Erweiterung.

Nach dieser Reconciliation ist der naechste Schritt weiterhin der observer-only
A11-Composition-Harness.


## 21. A11 composition source – 04.10.2026

Nach erfolgreicher lokaler Base-32-Verifikation:

~~~text
commit:
f4765721f0930424029e16161b9d3ef435652d1a

Production builder SHA-256:
1E9868F0439D51232AEEB22B029A91C699A88110753D1BC1C70959F0CDC24173

Production Base bundle SHA-256:
B59791CA021C39A3A97A0C07BB0C165659F0F460DDAF38404C4B60AA89631719

Documentation validation #2336:
PASS

MissionDemand validation #1107:
PASS
~~~

wurde der observer-only A11-Composition-Harness erstellt.

Der Test nutzt Joyce, Wright und Honaker als gleichzeitig angegriffene Installationen
und wartet vor externer Eskalation auf reale QRF-`EngageTarget`-Evidenz aller drei
Sites. Erst dann werden zwei ARTY- und zwei CAS-Demands im selben Tick erzeugt und die
threshold-driven Strategic-Resupply-Evaluation gestartet.

Der Strategic-Resupply-Testzustand wird reproduzierbar im **autoritativen**
CampaignState durch eine abgeschlossene Consumption-Transaktion auf Wright-AMMO bis
`reorder - 1` erzeugt. Danach muss der normale ResourceDemandPolicy/ResupplyMonitor-
Pfad den Demand erstellen. Der Harness setzt keinen Resupply-Demand direkt und besitzt
keine Settlement-Logik.

Der AIR_RESUPPLY-Descriptor liefert nur physischen STORAGE-Vertrag und den
owner-authored MOOSE-FlightPath-Corridor. Carrier-Rekrutierung, Assetwahl,
OPSTRANSPORT-Ausfuehrung, Corridor-Bindung und Settlement bleiben Production/MOOSE.

A11 ist damit source-seitig gebaut, aber noch nicht lokal gehasht, in eine Owner-MIZ
integriert oder in DCS validiert.


## 22. Honaker A11 QRF ACCESS-Containment – Owner-Korrektur 05.10.2026

Der erste reale A11-Lauf zeigte einen reproduzierbaren Honaker-QRF-Abbruch im
gemeinsamen `OMW_GroundRoadSpawnAdapter`:

~~~text
road spawn position outside access zone
entityId=BLUE_GROUND_COP_HONAKER_MIRACLE|QRF
unit=1
~~~

Die Demand-/BRIGADE-Kette selbst war intakt; Joyce und Wright materialisierten und
engagierten. Der Blocker war die historische Adapter-Guardrail, die jede einzelne
berechnete Fahrzeugposition mit `accessZone:IsVec2InZone(...)` pruefte.

Der Projektinhaber hat am 05.10.2026 klargestellt, dass dies nie der gewollte
Vertrag war. Verbindliche aktuelle Semantik:

~~~text
ACCESS = validierter Road-/Materialisierungsanker
ACCESS != Bounding-Zone fuer komplette Formation

anchor inside ACCESS
+ road/snap/spacing/heading safeguards
-> formation may extend outside ACCESS
~~~

Die per-Unit-Containment-Pruefung wird entfernt und durch Unit-/Contract-Gates
gegen Wiedereinfuehrung abgesichert. Der MOOSE BRIGADE/WAREHOUSE/PLATOON/
ARMYGROUP/AUFTRAG-Lifecycle bleibt unveraendert. Der geaenderte physische
Materialisierungsrand benoetigt einen neuen lokalen Build-/Hash-Nachweis und
anschliessend A11-DCS-Revalidation.

## 23. A11 DCS-PASS 06.10.2026 – Runtime geschlossen, Missionshash noch offen

Der Wiederholungslauf auf Source-Commit
1193a3b9b1ad67ddfa2e43b16d408f34851b62e2 mit Production Base-33 und
Acceptance-11-2 bestand den kombinierten A11-Lifecycle unter DCS 2.9.30.28738 MT.

Belegt sind:

~~~text
all three Guard paths observed
all three QRF materializations successful
Honaker ACCESS anchor-only correction successful
all three QRF direct-target engagements
MOOSE-selected Wright L118 fire
MOOSE-selected Honaker 2B11 fire
physical mortar hit/kill evidence
two independent CAS owner-corridor lifecycles
both CAS assets home-landed and returned to Legion
threshold-driven Strategic Resupply
MOOSE-selected CH-47
outbound corridor
STORAGE in-transit
DELIVERED settlement changed=true
return corridor
home landing
Legion asset return
[PRODUCTION BASE A11][PASS]
~~~

Getestete Hashes:

~~~text
Production Builder:
04FF1D73202D1863709C0ED01FDBAA95F10B4B0A299BC87E2CE29651B2E9B17C

Production Base bundle:
EC1CC8BD359AB97E4A03D0DCA2F70FD854903F3AF23E21178CE40681A3C736F1

Acceptance Builder:
D81A721D41291C20DB620A7890A780DDC4110211FCD1ABA91C672D316CB01E0F

Acceptance bundle:
680D727C991A4F98A4CFA291CFA8C1BBA9AED54889DC31CC35D1F37A05A3E539

MOOSE:
2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
~~~

Die einzige noch fehlende Acceptance-Provenienz ist der SHA-256 der tatsächlich
getesteten OMW_Template_v25_GroundWorks_base.miz. Bis dieser reale Owner-Hash
vorliegt, bleibt die formale Hochstufung auf ACCEPTED_TECHNICAL_BASELINE
governance-konform gesperrt. Der DCS-Lauf selbst ist als PASS dokumentiert.

