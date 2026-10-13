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
