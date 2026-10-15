---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-12
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - production mission bootstrap integration gate after PR #149
  - load-order and dependency validation for OMW_FireSupStratResupply_Production.lua
  - confirmation that the normal mission starts the merged FSSR Production Base without Acceptance fixtures
not_authoritative_for:
  - new CAS provider profiles beyond the already accepted Jalalabad rotary profile
  - production Strategic Resupply physical STORAGE mapping before that mapping is explicitly configured
  - any new MOOSE/native-DCS exception
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-production-bootstrap
source_commit: PENDING_MERGE
validated_in_dcs: false
validation_status: DCS_PENDING
---

# Production Base Acceptance 12 – Mission Bootstrap Integration

## 1. Ziel

Acceptance 12 prueft nicht erneut Guard/QRF, ARTY, CAS oder Strategic Resupply als
fachliche Lifecycles. Diese Pfade behalten ihre jeweils dokumentierte Acceptance.

A12 prueft nur die neue Integrationsgrenze:

~~~text
normal OMW mission
-> Warehouse Base
-> Ground Base
-> AirOps foundations
-> FSSR Production Base package
-> FSSR Production Bootstrap
-> shared runtime prepared
-> perimeters started
-> six sites started
-> ready flag set
~~~

## 2. Ausgangsmission

Owner-Basis fuer die Mission-Editor-Integration:

~~~text
OMW_Template_v26_GroundWorks_Ready.miz
owner-upload baseline SHA-256 before Production-Bootstrap insertion:
ACCA37DB29939CDE773FBD1987EC9A6D761A91B4965E306D5F221356DFAA3537
~~~

Der Hash ist nur der Eingangszustand. Die nach Einbettung des neuen Production-Bundles
gespeicherte Testmission benoetigt einen neuen realen SHA-256.

## 3. Load Order

~~~text
T+00  Moose.lua
T+01  OMW_AirOps_Warehouse_Base.lua
T+02  OMW_Ground_Base.lua
T+05  OMW_AAR_Base.lua
T+05  OMW_AWACS_Base.lua
T+08  Bagram AirOps
T+11  Kandahar AirOps
T+14  Jalalabad AirOps
T+17  Salerno AirOps
T+20  Tarinkot AirOps
T+24  Shindand AirOps
T+30  OMW_FireSupStratResupply_Base.lua
T+40  OMW_FireSupStratResupply_Production.lua
~~~

Der T+40-Trigger darf nur feuern, wenn mindestens die bereits verwendeten
Warehouse-/Ground-READY-Gates gesetzt sind. Der Production-Bootstrap prueft die
Runtime-Abhaengigkeiten zusaetzlich selbst fail-closed.

## 4. PASS-Kriterien

Der reale DCS-Lauf muss mindestens zeigen:

~~~text
DCS user flag OMW_WAREHOUSE_READY = 1
DCS user flag OMW_GROUND_READY = 1
OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED = 1
OMW_FSSR_PRODUCTION_BOOTSTRAP_LOADED = 1

[OMW][FireSupStratResupply.Production] AIRWING_REGISTERED ...
[OMW][FireSupStratResupply.Production] PERIMETER_CONFIG ... for all six sites
[OMW][FireSupStratResupply.ArtyRealAssetRegistry] registered real asset ... x4
[OMW][FireSupStratResupply.Runtime] prepared generic runtime ...
[OMW][FireSupStratResupply.Production] RESULT status=RUNNING sites=6 ...

OMW_FSSR_READY = 1
~~~

Ausserdem:

~~~text
no BadGuys_A3_* activation by the Production Bootstrap
no synthetic CampaignState shortage
no Acceptance PASS/FAIL harness
no Acceptance watchdog
no automatic support request merely because the bootstrap loaded
~~~

## 5. Strategic Resupply in A12

Die aktuelle v26-Eingangsmission besitzt noch keinen explizit genehmigten produktiven
physischen STORAGE-/Transport-Descriptor fuer den allgemeinen FSSR-Bootstrap.

Daher ist fuer A12 ohne zusaetzliche Owner-Konfiguration erwartet:

~~~text
OMW_FSSR_READY = 1
OMW_FSSR_RESUPPLY_READY = 0

log:
STRATEGIC_RESUPPLY_NOT_CONFIGURED
reason=PRODUCTION_PHYSICAL_TRANSPORT_DESCRIPTOR_REQUIRED
~~~

Das ist ein erwarteter fail-closed Zustand und kein A12-Fehler.

A11 bleibt der technische Nachweis, dass der generische Strategic-Resupply-Pfad mit
explizitem physischem Descriptor funktioniert. A12 darf dessen STORAGE-Fixtures nicht
als Production-Konfiguration uebernehmen.

## 6. FAIL-Kriterien

A12 ist fehlgeschlagen bei:

~~~text
Production Bootstrap ERROR
shared CampaignState mismatch
missing site/template/pathline dependency
no running AIRWING
perimeter start failure
site start failure
OMW_FSSR_READY != 1
Acceptance fixture or synthetic shortage triggered by Production Bootstrap
~~~

## 7. DCS-Nachweis

Nach dem Lauf benoetigt die Acceptance:

~~~text
branch/commit
Production Base bundle SHA-256
Production Bootstrap bundle SHA-256
test mission filename
test mission SHA-256
DCS version
MOOSE commit
Moose.lua SHA-256
relevant dcs.log excerpt
~~~

VALIDATED beziehungsweise ACCEPTED_TECHNICAL_BASELINE erst nach diesem realen Nachweis.


## 8. Readiness-Nachtrag nach erstem A12-Lauf

Der erste reale A12-Start hat die Mission-Editor-Bedingungen passiert, der Bootstrap
hat jedoch irrtuemlich gleichnamige Lua-Globals statt der DCS-Userflags gelesen.

Realer Befund:

~~~text
FSSR-Trigger wurde ausgefuehrt
-> Mission-Editor OMW_WAREHOUSE_READY / OMW_GROUND_READY waren damit erfuellt
-> Production Bootstrap brach mit "OMW_WAREHOUSE_READY is not set" ab
~~~

Die Korrektur verwendet die gepinnte MOOSE-USERFLAG-API:

~~~text
USERFLAG:New("OMW_WAREHOUSE_READY"):Get()
USERFLAG:New("OMW_GROUND_READY"):Get()
~~~

Keine zusaetzliche Readiness-Autoritaet und keine Lua-Global-Spiegelung werden
eingefuehrt. Der naechste DCS-Lauf muss Bootstrap-2 verwenden.


## 9. Full-Response-Regressionscope nach Bootstrap-PASS

Der erste Bootstrap-2-Lauf bestaetigte, dass Production Runtime, Perimeter, Site-BRIGADEs,
AIRWING-Registrierung und QRF bis in reale Engagements funktionieren. Gleichzeitig
wurde eine Orchestration-Regression sichtbar: der qualifizierte Installation-Incident
erzeugte nur Guard/QRF-Demands, obwohl ARTY/CAS-Adapter bereits vorbereitet waren.

Bootstrap-3 / Production-Base-34 muss deshalb zusaetzlich zeigen:

~~~text
qualified installation incident
-> GUARD requested
-> QRF requested
-> C2_EXTERNAL_SUPPORT_REQUEST supportType=CAS
-> C2_EXTERNAL_SUPPORT_REQUEST supportType=ARTY

CAS:
-> Base demand DISPATCHED
-> MOOSE provider selection
-> CAS_PROVIDER_PROFILE_BOUND
-> CAS_MISSION_ASSIGNED
-> CAS_OWNER_CORRIDOR_INSTALLED
-> CAS_EXECUTING
-> physical CAS behavior according to inherited lifecycle

ARTY:
-> Base demand DISPATCHED
-> MOOSE selection-only provider reservation
-> FUNCTIONAL_ARTY_OWNER_CREATED for selected real battery
-> physical ARTY/Mortar EVENTS.Shot evidence
~~~

Die Acceptance darf dafuer keine neue Provider-Auswahl, kein FireAtPoint-AUFTRAG als
zweiten ARTY-Owner und keine eigene CAS-Release-/Recovery-Logik einfuehren.

Dieser Nachweis ist eine Regression der Production-Orchestration-Grenze. Die bereits
akzeptierten A9/A10-Lifecycles werden nicht neu definiert.


## 10. Fixed-Fire-Readiness-Gate

Der reale Bootstrap-2-Lauf zeigte, dass die vier Fixed-Fire-Support-Assets erst kurz
nach BRIGADE-Start physisch materialisiert werden. Ein externer ARTY-Demand darf nicht
vor diesem MOOSE-Lifecycle-Ereignis freigegeben werden.

Bootstrap-4 verwendet deshalb **keinen Timer-Retry**. Stattdessen gilt:

~~~text
BRIGADE start
-> MOOSE OnAfterAssetSpawned
-> ArtyRealAssetRegistry marks real asset materialized
-> all four fixed-fire assets materialized
AND COMMANDER started
-> start installation perimeters
-> OMW_FSSR_READY = 1
~~~

Damit kann ein qualifizierter Installation-Incident erst entstehen, nachdem die realen
L118/2B11-Assets fuer die bereits akzeptierte MOOSE-Selection-/Functional-ARTY-Kette
bereitstehen.

Erwartete Marker:

~~~text
WAITING_FOR_FIXED_FIRE_ASSETS
FIXED_FIRE_READINESS_EVENT ...
RESULT status=RUNNING ... fixedFireMaterialized=true
~~~

Kein eigener Scheduler und kein Polling-Loop werden eingefuehrt.


## 11. Owner-Beobachtung und Regression nach Lauf 14.10.2026

Die Gesprächsauswertung und der vorliegende Owner-Bericht sind gesondert als
Reconciliation-Handoff dokumentiert:

```text
docs/handoffs/2026-10-14-fssr-production-reconciliation.md
```

Der Eigentümer beobachtete zwei gleichzeitig über Honaker operierende AH-64D-Two-Ships:
alle vier Helikopter bekämpften aktiv RED-Einheiten, die Two-Ships griffen
unterschiedliche Ziele an. Die nominellen Demands AID-158 bis AID-161 blieben
Honaker/Joyce/Wright/Fortress zugeordnet. Ein formelles Retasking, eine
PATROLZONE-Überlappung oder eine fehlerhafte AO-Geometrie ist **nicht bewiesen**.
Die nächste Acceptance benötigt zugeordnetes CAS-Target-/Flight-/Demand-Logging.
Das beobachtete Verhalten darf vor Klärung nicht blind unterbunden werden.

In derselben Auswertung wurde eine Production-Regression beim ARTY-/Mörser-Lifecycle
festgehalten: Nach einer einzelnen Vier-Schuss-Fire-Mission wurde der gesamte
ARTY-Bedarf beendet statt das lebende C2-Zielbild erneut auszuwerten und
gegebenenfalls die nächste begrenzte Mission zu starten. Der historische lokale
M1083-Rearm-/CampaignState-Verbrauch und die Ground-/Air-Strategic-Resupply-
Capability müssen aus akzeptierten Implementierungen in Production reconciliert
werden. Bei Fortress fehlt physische Shot-Evidenz trotz protokolliertem Abschluss.

**Offene Owner-Entscheidung:** konkrete `selectSupportType`-Policy für
gleichzeitig mögliche `GROUND_RESUPPLY` und `AIR_RESUPPLY`. A12-Storage-
Fixtures dürfen nicht als Production-Konfiguration ausgegeben werden.

Ein AH-64D-Verlust (MissionID 1000080) wurde in der Auswertung berichtet,
jedoch kein eindeutig belegter Fuel-Starvation-Crash. Asset-Level-Settlement
ist gegenüber Flight-Level-Landing-Meldungen gesondert zu prüfen.

Dieser Nachtrag ist ein Scope-/Evidenzverweis und **kein A12-PASS**.


## 12. Production-Bootstrap-5 – optionales Local-M1083-Rearm-Gate

Der Production-Bootstrap-5 bettet die **unveraenderten** vorhandenen Ground-Module `OMW_GroundSupportMaterializer`, `OMW_FixedFireSupportAmmoSupport`, `OMW_GroundAmmoRearmAdapter` und `OMW_FixedFireSupportAmmoRearmService` in das Production-Bundle ein.

**Ohne** `OMW.FireSupStratResupplyProductionConfig.localArtyRearm` darf sich das bisherige Bootstrap-Verhalten nicht aendern. Der normale A12-Start darf weder automatisch einen M1083 materialisieren noch einen CampaignState-Rearm-Verbrauch buchen.

**Mit** ausdruecklicher, gepruefter Standortkonfiguration ist zusaetzlich zu pruefen:

1. Der MOOSE-ausgewaehlte, physisch vorhandene Functional-ARTY-Owner wird weiterhin ausschliesslich einmal erzeugt; kein zweiter `ARTY:New`-Owner fuer den Rearm.
2. Die Local-Rearm-Composition wird beim ersten Resolve dieses Functional-Owners eingerichtet; MOOSE-Support-BRIGADE und Support-PLATOON sind genau einem Standort zugeordnet.
3. `nodeId` der Konfiguration muss `SiteRegistry.Sites[siteId].campaignNodeId` entsprechen. Falsche Node-ID muss fail-closed abgewiesen werden.
4. `RequestLocalArtyRearm(assetId, spec)` darf keine andere Artilleriegruppe, keinen fremden Carrier und keine andere Ressourcenart unterschieben; `startArty=false` bleibt zwingend.
5. Der Request nutzt nur den bestehenden Service: reale M1083-Materialisierung, `ARTY:Rearm()`, `OnAfterRearmed`, CampaignState-Consumption/Completion, Rueckkehr zum Warehouse und erneute Wiederverwendbarkeit.
6. Schwellwert-/Request-Ausloesung und ARTY-Continuation muessen als separate Produktionsintegration nachgewiesen werden. Ohne diese Verdrahtung ist das vorliegende Gate **kein** Ende-zu-Ende-Resupply-/Fire-Continuation-PASS.

Fuer den DCS-Lauf benoetigt der Projektinhaber reale Builder-/Bundle-Hashes, Missions-/MOOSE-/DCS-Provenienz, M1083- und ARTY-Lifecycle-Evidenz sowie Ressourcen-Snapshots. Die vorhandene A10-Fixture-Konfiguration wird nicht automatisch als Production-Manifest uebernommen.

**Status:** SOURCE_IMPLEMENTED / LOCAL_BUILD_PENDING / DCS_PENDING. Weder ARTY-Continuation noch Ground-/Air-Strategic-Resupply sind durch diese A12-Erweiterung abgenommen.


## 13. ARTY-Selection-Completion-Signal – Source-Gate

Die Production enthaelt einen **optionalen** Completion-Listener `onArtyFireMissionFinished`. Seine einzige aktuelle Aufgabe ist, `OnAfterCeaseFire` / `OnAfterDead` und fruehen Cancel des bereits existierenden MOOSE-Functional-ARTY-Lifecycles korreliert und einmalig nach Freigabe der MOOSE-Selection-Reservierung zu melden. Es existiert derzeit **kein** eingerichteter automatischer C2-Retarget-Listener.

Zu pruefen: exakte Demand-ID und Site-Korrelation, nur ein Callback pro Fire-Mission, Ursache `CEASE_FIRE` / `FUNCTIONAL_ARTY_DEAD` / `CANCELLED_BEFORE_FIRE_START`, Release vor Callback, Listenerfehler ohne MOOSE-FSM-Ausfall. `CeaseFire` ohne physische `EVENTS.Shot`-Evidenz zaehlt weiterhin **nicht** als nachgewiesenes Feuer; neue Fire-Mission nach CeaseFire und Wiederaufnahme nach Rearm bleiben eigene ausstehende DCS-Gates.

**Status:** SOURCE_IMPLEMENTED / TEST_NOT_RUN / DCS_PENDING.


## 14. CAS-AO-Deconfliction-Signal – Base 36

`CasLifecycleRuntime:IsOnStationAt(coordinate)` ist ein read-only Adapter auf die vorhandene MOOSE-CAS-Flight-Position und die bereits vorhandene Mission-AO-`ZONE`. Fuer ein geeignetes Target gilt:
- belegte physische CAS-Position innerhalb des gemeinsamen Ziel-AO: **true**;
- relevante aktive Mission, deren physischer Flight nicht aufloesbar ist: **nil/unknown**, keinesfalls ARTY-Dispatch-Freigabe;
- kein bekannter physisch anwesender Flight: **false** (noch kein gesamtes taktisches Fire-Clearance-Gate).
- physisches CAS-Egress und Return sind separat von `releaseRequested` nachzuweisen.

Regressionsnachweis: mehr als eine CAS-Mission, AO-Ueberlappung, anschliessender Egress, Return-to-Legion, fehlende Koordinate, laufender ARTY-Salvenabschluss ohne vorzeitigen Abbruch. Keine Aenderung der bisherigen CAS-Corridor-/PATROLZONE-/Targeting-FSM.

**Status:** Source implementiert, Unit-Test erweitert, lokal noch nicht ausgefuehrt, **DCS_PENDING**. Es wird noch keine automatische ARTY-Continuation getriggert.


## 15. Physisches ARTY-Shot-Evidence-Gate – Base 38

`ArtySelectionRuntime` Schema 3 beobachtet `ARTY:OnEventShot` am bereits laufenden MOOSE-Owner. Events muessen gegen `ARTY.groupname` und `ARTY.currentTarget.name` korreliert werden. `OnAfterCeaseFire` meldet `NO_PHYSICAL_SHOT_EVIDENCE`, falls kein korrelierter Shot existiert; dies darf **niemals** als erfolgreiche Feuermission gelten. Abbruch-/Dead-Reasons und MOOSE-Recruitment-/Release-Semantik unveraendert.

**DCS-Gates:** Fortress-False-Positive (CeaseFire ohne Shot), Wright/Honaker echte physische Shot-Events, zwei getrennte Auftraege und jeweils exakte Demand-/Target-Korrelation, no-double-count nach Release, andere Batterie als Negativtest. Pruefe End-to-End nachher M1083-Rearm und physisch neues Target; hier noch **keine** neue C2-Continuation.

**Status:** Source und Unit-Test aktualisiert; Unit-Testausfuehrung, Builder-38-Hash und DCS-PASS ausstehend.
