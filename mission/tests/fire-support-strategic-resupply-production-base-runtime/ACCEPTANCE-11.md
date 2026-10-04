---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-11
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local plan for combined multi-installation Production Base acceptance
  - autonomous MOOSE provider selection under concurrent support demand
  - required ARTY, mortar, CAS and Strategic Resupply coverage
not_authoritative_for:
  - runtime acceptance before the real DCS test
  - provider identities or deterministic support assignments
  - new MOOSE/native-DCS exceptions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Production Base Acceptance 11 – Multi-FOB/COP Autonomous Full Response

## 1. Owner-Ziel

Der naechste grosse DCS-Lauf soll kein einzelner synthetischer Support-Dispatch mehr sein. Verwendet werden die bereits in der Owner-MIZ vorhandenen RED-Gruppen mit Late Activation. Mehrere FOBs/COPs werden zeitlich ueberlappend angegriffen. Daraus muessen reale Installation-Incidents und mehrere gleichzeitige beziehungsweise ueberlappende Support-Demands entstehen.

Der zentrale Nachweis ist:

~~~text
multiple real installation attacks
-> multiple concurrent support demands
-> MOOSE operational organizations receive the demands
-> MOOSE COMMANDER / LEGION / AIRWING / BRIGADE selects and recruits
   available eligible operational assets
-> OMW does not prescribe the concrete provider
-> each selected asset executes its already accepted production lifecycle
-> busy/reserved assets are not double-booked
-> additional demands use another eligible asset or remain queued/rejected
   according to MOOSE capability/availability
~~~

Der Test muss ARTY, mortar, CAS und Strategic Resupply einschliessen.

## 2. Was "ohne unsere Vorgaben" bedeutet

Nicht erlaubt:

~~~text
incident/site -> fixed ARTY battery
incident/site -> fixed mortar battery
incident/site -> fixed AIRWING/SQUADRON/aircraft
incident/site -> fixed M1083/carrier instance
acceptance harness chooses nearest/best provider itself
acceptance harness keeps its own availability queue
acceptance harness retries around MOOSE
acceptance harness moves a fixed battery into range
~~~

Erlaubte/erforderliche Inputs sind ausschliesslich fachliche Constraints:

~~~text
support type
target / supported-element geometry
mission capability
weapon/range feasibility
release/recovery profile for whichever provider MOOSE selects
resource shortage / destination / transferable resource
approved transport-mode policy where the domain demand requires one
~~~

Ein natuerlicher Range-, Capability- oder Verfuegbarkeitsconstraint ist keine Provider-Vorwahl. Der konkrete Provider bleibt MOOSE-Entscheidung.

## 3. Lifecycle-Inheritance-Gate

| Bereich | Geerbter Produktionspfad | Status vor A11 | A11 darf |
|---|---|---|---|
| Installation alarm / incident | OPSZONE evidence -> authoritative incident | bestehende Base-Baseline | nur RED fixture aktivieren und Incident beobachten |
| Guard | incident-local ONGUARD -> ReturnToLegion | bestehende Base-Baseline | beobachten |
| QRF | accepted direct-target / On-Road / reacquire / RTZ | akzeptierte Baseline | beobachten |
| Rotary CAS | A9 shared CasLifecycleRuntime + release/recovery | A9 DCS PASS | Demand ausloesen, Auswahl und Lifecycle beobachten |
| Fixed ARTY | A10 RealAssetRegistry -> selection-only MOOSE recruitment -> Functional ARTY | A10 DCS PASS | Demand ausloesen, Auswahl und Feuer beobachten |
| Mortar | gleicher A10 RealAssetRegistry/Functional-ARTY-Vertrag | materialization/range eligibility DCS-belegt; realer selected-fire path noch offen | erstmals realen selected-fire path beobachten |
| M1083 local rearm | accepted FixedFireSupportAmmoRearmService | A10 Regression PASS fuer Wright | wiederverwenden/mehrfach beobachten |
| Strategic Resupply | ResourceDemandPolicy + MissionDemand + StorageTransportFactory + OPSTRANSPORT/STORAGE + TransportSettlement | source/contract-tested; physical full lifecycle noch nicht DCS-accepted | nach Production-Reconciliation erstmals end-to-end beobachten |

A11 darf keinen dieser Lifecycles nachbauen.

## 4. Vor A11 noch notwendige Production-Entwicklung

A11 wird erst als Build-/DCS-Kandidat freigegeben, wenn diese Base-Grenzen geschlossen sind:

~~~text
A. obsolete descriptor path cleanup
B. real multi-demand External Support composition, demand-scoped and concurrent
C. selected 2B11 owner handoff with no Honaker provider forcing
D. CAS multi-demand readiness with fail-closed owner profiles
E. Strategic Resupply physical OPSTRANSPORT/STORAGE lifecycle + idempotent settlement
F. combined orchestration with no double-booking of busy/reserved assets
~~~

## 5. RED-Angriffsfixture

Die Owner-MIZ besitzt bereits RED-Angriffsgruppen als Late-Activation-Fixtures. Sie bleiben Owner-MIZ-Arbeit; ChatGPT mutiert die MIZ nicht.

Der A11-Harness darf diese Fixtures fuer den Test aktivieren, weil Fixture-Aktivierung zum erlaubten Acceptance-Scope gehoert. Er darf danach keinen Supportprovider direkt aufrufen.

Ziel ist mindestens:

~~~text
two or more installation attacks overlap in time
preferably enough concurrency that at least one support asset is already reserved/busy
while another qualified demand is created
~~~

Die konkreten RED-Gruppennamen werden vor dem Builder aus der Owner-MIZ beziehungsweise ihrer dokumentierten Mission-Editor-Baseline uebernommen. Namen werden nicht geraten.

## 6. Required observable support coverage

Ein A11-PASS benoetigt im selben realen DCS-Lauf mindestens beobachtbare Evidenz fuer:

~~~text
ARTY:
- generic demand exists
- MOOSE selects real fixed ARTY asset
- Functional ARTY fires
- reservation releases
- battery never relocates

MORTAR:
- a real 2B11 asset is selected by MOOSE without explicit Honaker mapping
- Functional ARTY owner for that selected mortar fires
- ammo decreases
- reservation releases
- mortar position remains fixed

CAS:
- at least two independent CAS demands overlap or contend with other support
- concrete AIRWING/SQUADRON/asset is not specified by demand/harness
- MOOSE selects/recruits
- selected-provider profile binds
- accepted route/release/home-landing/exact-asset-return lifecycle completes

RESUPPLY:
- real resource shortage crosses approved policy threshold
- MissionDemand is created/deduplicated
- CampaignState reserves strategic quantity exactly once
- MOOSE transport organization recruits carrier/assets
- physical pickup/loading/in-transit/delivery or loss is observed
- CampaignState settles exactly once from confirmed physical evidence
- no concrete carrier is selected by the harness
~~~

Guard and QRF remain regression-observed because the RED attacks originate from real installation incidents.

## 7. Autonomy / contention assertions

The combined run must explicitly record:

~~~text
demandId
incidentId/siteId
supportType
eligible organization count where observable
selected Legion/AIRWING/BRIGADE
selected Assetitem/runtime group
reservation start
mission/transport execution
release/return/settlement
terminal reason
~~~

PASS requires:

~~~text
- no demand contains a concrete provider identity before MOOSE recruitment
- no operational asset is simultaneously reserved for incompatible demands
- multiple demands can remain active concurrently
- one completed/released asset may later be recruited for a new demand
- lack of an immediately available provider does not trigger an OMW-side forced fallback
- unrelated demand types continue while another support asset is busy
~~~

## 8. Strategic Resupply scope

"Resupply" in A11 means the CampaignState/MissionDemand -> MOOSE OPSTRANSPORT/STORAGE strategic transfer path, not only the local M1083 artillery rearm.

The accepted M1083 path is still tested as local fire-support rearm where triggered, but it does not by itself satisfy the A11 Strategic Resupply requirement.

PARTIAL delivery remains outside PASS unless a general CampaignState partial-transfer semantic is explicitly implemented and separately approved.

## 9. Acceptance-harness boundary

A11 may activate RED late-activation attack fixtures, observe incidents/demands, collect MOOSE selection/recruitment evidence, observe production lifecycle callbacks, assert concurrency/reservation/physical return/settlement, and declare PASS/FAIL.

A11 may not select a provider, battery, mortar, AIRWING/SQUADRON/aircraft or concrete carrier asset; route CAS/QRF; move ARTY/mortar; own the fire or transport FSM; force return/recovery; or settle CampaignState independently of production settlement.

## 10. PASS rule

A11 is a combined orchestration acceptance, not a list of isolated smoke tests.

PASS only when the same run demonstrates:

~~~text
multiple overlapping installation attacks
+ concurrent independent demands
+ MOOSE-owned operational provider/asset selection
+ ARTY execution
+ mortar execution
+ CAS execution and recovery
+ Strategic Resupply physical execution and settlement
+ inherited Guard/QRF behavior without regression
+ no hard-coded provider shortcut
+ no duplicate resource/mission owner
~~~

Until then:

~~~text
A11 status = PLANNED / NOT RELEASED FOR DCS
~~~


## 11. Source-readiness gate – 02.10.2026

Vor Implementierung des observer-only Harness wurden folgende Production-Grenzen
source-/CI-seitig geschlossen:

~~~text
descriptor-only ARTY removed from active Production Base composition
RealAssetRegistry generic L118 + 2B11 owner-resolution contract
ARTY concurrent-demand reservation isolation
CAS demand-scoped release-state isolation + unknown-provider fail-closed behavior
ResupplyMonitor independent node/resource shortage episodes
StorageTransportFactory explicit strategic-to-physical amount mapping
TransportSettlement default MOOSE OPSTRANSPORT in-transit observer
CampaignState full-delivery/full-loss exactly-once settlement contract
~~~

Der Strategic-Resupply-Descriptor muss `cargoAmount` explizit als physische
DCS-STORAGE-Menge angeben. A11 darf daraus keine neue strategische Ressourcenautoritaet
ableiten; `demand.quantity` bleibt die zu reservierende/settlebare CampaignState-Menge.

Der Default-In-Transit-Nachweis ist absichtlich konservativ:

~~~text
storage cargoLoaded > 0
AND at least one assigned MOOSE carrier exists
AND every currently assigned carrier is outside pickupZone
-> confirm CampaignState IN_TRANSIT
~~~

Das Harness darf diesen Zustand nur beobachten. Es darf weder Carrier auswaehlen noch
den Status selbst erzwingen.

Diese Source-Readiness aendert den Release-Status nicht:

~~~text
A11 status = PLANNED / NOT RELEASED FOR DCS
~~~

Der Harness wird erst im naechsten Schritt als observer-only Composition gebaut.


## 12. Strategic-Resupply recruitment reconciliation – 02.10.2026

Vor Freigabe des A11-Harness wurde der generische Resupply-Dispatch gegen den bereits
erprobten Stage-3-STORAGE-Pfad reconciliert.

Nicht mehr verwendet:

~~~text
STORAGE OPSTRANSPORT
-> COMMANDER:AddOpsTransport(...)
-> assume automatic queue recruitment
~~~

Produktive Source-Richtung:

~~~text
STORAGE OPSTRANSPORT
+ explicit physical manifest weight
-> COMMANDER:RecruitAssetsForTransport(...)
-> MOOSE aggregates eligible COMMANDER cohorts
-> MOOSE selects/reserves Assetitem(s)
-> OPSTRANSPORT:AddAsset(selected Assetitem)
-> COMMANDER:TransportAssign(selected Legions)
-> normal LEGION/OPSTRANSPORT physical lifecycle
-> existing TransportSettlement
~~~

Der A11-Harness darf weiterhin weder Cohort, AIRWING, SQUADRON noch Assetitem
vorgeben. Die damalige Stage-3-Jalalabad/CH-47-Bindung ist Acceptance-Konfiguration
und wird **nicht** in die allgemeine Base uebernommen.

Bei fehlendem rekrutierbarem Carrier endet der Dispatch fail-closed mit
`MOOSE_TRANSPORT_CARRIER_UNAVAILABLE`; es gibt keinen OMW-Retry-Selector und keinen
Fallback auf einen konkret benannten Carrier.

Status dieser Reconciliation:

~~~text
source implementation: complete
contract/CI: pending remote workflow
DCS combined concurrency: A11 pending
~~~


## 13. Strategic-Resupply route lifecycle inheritance gate – 04.10.2026

Vor dem A11-Harness gilt fuer gerouteten Rotary-Wing-Strategic-Resupply folgende
verbindliche Lifecycle-Inheritance:

| Feld | A11-Vertrag |
|---|---|
| inherited_contract | Stage-3 MOOSE OPSTRANSPORT/STORAGE mit owner-authored FlightPath outbound + reverse recovery route |
| accepted_source_paths | `scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua`, `scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua`, allgemeiner `ResupplyTransportRuntime` |
| evidence | fruehere Stage-3-Evidenz nur fuer deren exakte Jalalabad/Wright/CH-47-Provenienz; keine pauschale A11-Validierung |
| invariants | MOOSE waehlt Carrier; OMW bindet nur das Profil des gewaehlten Assets; outbound owner route; reverse owner route after Delivered; kein Direct-Line-Fallback; CampaignState bleibt strategische Autoritaet |
| reuse_mode | DIRECT_REUSE + MINIMAL_ADAPTER |
| harness_role | Trigger / Observation / Assertion only |
| changed_boundary | allgemeine Bindung des bestehenden CorridorAdapters an das von COMMANDER/LEGION ausgewaehlte Carrier-Asset |
| owner_approval | keine neue Architekturentscheidung; Reconciliation des bereits verwendeten Stage-3-Vertrags |
| revalidation_scope | A11 muss den allgemeinen MOOSE-selected Carrier + Route + STORAGE + Settlement-Lifecycle real unter DCS belegen |

A11 darf deshalb den Transportweg **nicht** selbst ueber FLIGHTGROUP-Waypoints bauen.
Die missionsspezifische A11-Composition darf lediglich den vorhandenen owner-authored
PATHLINE-Korridor aufloesen und als Descriptor an die Production Base uebergeben.

Fuer den geerbten gerouteten Scope gilt weiterhin ein Carrier. Mehrere Carrier fuer
denselben gerouteten OPSTRANSPORT sind nicht Teil dieser Acceptance.

Der Harness bleibt bis zur vollstaendigen Composition und statischen/CI-Pruefung:

~~~text
A11 status = PLANNED / NOT RELEASED FOR DCS
~~~


## 14. Mandatory Helicopter Corridor – Owner clarification 04.10.2026

Fuer A11 ist der Helicopter-Korridor keine optionale Konfiguration.

~~~text
AIR_RESUPPLY / rotary-wing carrier
-> owner-authored corridor mandatory
-> missing corridor = FAIL CLOSED
-> no direct-line fallback
~~~

Der Acceptance-Harness darf weder den Korridor abschalten noch eine direkte Route
zulassen. Er darf den vorhandenen Corridor lediglich aufloesen und an die Production
Base uebergeben.
