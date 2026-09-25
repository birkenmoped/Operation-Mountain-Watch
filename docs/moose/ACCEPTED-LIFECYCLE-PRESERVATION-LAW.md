---
document_id: OMW-MOOSE-ACCEPTED-LIFECYCLE-PRESERVATION-LAW
status: BINDING
document_class: IMPLEMENTATION_GUARDRAIL
owning_policy: OMW-GOV-001
authoritative_for:
  - preservation of accepted and binding runtime lifecycles
  - Base/generalization anti-regression workflow
  - Acceptance harness boundaries
  - lifecycle inheritance documentation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - ad-hoc lifecycle reconstruction inside Acceptance harnesses
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Accepted Lifecycle Preservation Law

## 1. Zweck

Dieses Dokument verhindert, dass bereits akzeptierte oder verbindlich festgelegte Laufzeit-Lifecycles bei einer spaeteren Generalisierung, Base-Bildung, Reconciliation oder Acceptance-Arbeit erneut teilweise implementiert und dadurch regressiv verschlechtert werden.

Die verbindliche Arbeitsregel lautet:

```text
accepted / binding lifecycle
-> inherit
-> reuse
-> adapt minimally
-> preserve invariants
-> test only changed boundary

NOT:

accepted / binding lifecycle
-> copy ideas
-> rebuild state machine in a harness
-> assume equivalence
```

## 2. Definitionen

### 2.1 Accepted lifecycle

Ein Lifecycle gilt fuer seinen dokumentierten Scope als technisch akzeptiert, wenn eine exakt provenance-gebundene DCS-Acceptance dies belegt.

Beispiele im aktuellen Projekt:

- Ground QRF direct-target / On-Road / ReturnToLegion lifecycle in der akzeptierten A4-8-Baseline.
- Ground ARTY M1083 rearm lifecycle im dokumentierten Ground Ammo Rearm Acceptance 1.
- Air PERSONNEL FlightPath return lifecycle im dokumentierten Stage-1D-P Acceptance-4.
- AWACS full lifecycle in seinem dokumentierten Acceptance-Scope.

### 2.2 Binding lifecycle law

Ein Lifecycle kann als verbindlicher Design-/Architekturvertrag festgelegt sein, obwohl nicht jede Generalisierung bereits DCS-validiert ist.

Beispiel:

- STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md fuer CAS Routing, Release und Recovery.

Ein solcher Vertrag darf ebenfalls nicht stillschweigend durch einen Acceptance-Harness ersetzt oder verkuerzt werden.

## 3. Mandatory Lifecycle Inheritance Gate

Vor Implementierung oder Test eines Subsystems mit vorhandener Acceptance-/Runtime-Evidenz muss im zustaendigen Fach- oder Acceptance-Dokument eine Lifecycle-Inheritance-Tabelle stehen.

Pflichtfelder:

| Feld | Inhalt |
|---|---|
| inherited_contract | akzeptierter Lifecycle oder bindendes Lifecycle-Gesetz |
| accepted_source_paths | produktive Source-Dateien, die den Lifecycle ausfuehren |
| evidence | Branch/Commit/Bundle/Mission/DCS/MOOSE, soweit akzeptiert |
| invariants | Zustands-/Autoritaetsregeln, die erhalten bleiben muessen |
| reuse_mode | DIRECT_REUSE, SHARED_EXTRACTION, MINIMAL_ADAPTER, INTENTIONAL_CHANGE |
| harness_role | nur Trigger/Observation/Assertion |
| changed_boundary | exakt geaenderte Grenze, falls vorhanden |
| owner_approval | erforderlich bei INTENTIONAL_CHANGE |
| revalidation_scope | exakt neu zu testender Teil |

Ohne diese Tabelle darf kein neuer Base-/Reconciliation-Acceptance-Lauf als gueltiger Nachweis vorbereitet werden.

## 4. Harness Law

Acceptance- und Diagnosecode darf:

```text
activate fixture
observe events
correlate IDs
collect evidence
assert invariants
declare PASS / FAIL
```

Acceptance- und Diagnosecode darf einen bestehenden produktiven Lifecycle nicht besitzen.

Insbesondere verboten, wenn dafuer bereits produktive oder akzeptierte Logik existiert:

```text
second routing authority
second target-selection authority
second mission-completion authority
second CAS release state machine
second RTB/recovery state machine
second ReturnToLegion state machine
second asset recredit/settlement authority
second strategic resource owner
```

Wenn ein Harness solche Logik benoetigt, ist das ein Architekturhinweis, dass die betreffende Funktion noch nicht korrekt in eine gemeinsame Produktionskomponente extrahiert wurde.

## 5. Watchdog Law

Ein Acceptance-Watchdog ist standardmaessig diagnostisch:

```text
watchdog elapsed
-> log WARN / diagnostic state
-> continue observing the physical lifecycle
```

Er darf nicht:

```text
set a terminal state that disables lifecycle monitoring
cancel a productive mission
force RTB
force release
force settlement
```

Ausnahme nur, wenn derselbe Timeout Teil des bindenden Produktionsvertrags ist.

Die A7-Regressionsursache vom 18.09.2026 ist explizite Negativ-Evidenz fuer diese Regel: ein Acceptance-Timeout setzte state.failed, dadurch stoppte derselbe Harness seinen CAS-Release-Monitor, waehrend der physische MOOSE-Auftrag weiterlief.

## 6. Generalization / Base Law

Beim Uebergang von einem spezialisierten Acceptance-Pfad in eine allgemeine _base gilt:

1. Zuerst den akzeptierten produktiven Lifecycle identifizieren.
2. Dessen ausfuehrende Module direkt wiederverwenden.
3. Wenn ein spezialisierter Harness die einzige Implementierung enthaelt, zuerst die Lifecycle-Logik in eine gemeinsame Produktionskomponente extrahieren.
4. Die neue Base darf danach nur die allgemeine Orchestrierung und Dependency Injection uebernehmen.
5. Der Acceptance-Harness darf die extrahierte Produktionskomponente nur ausloesen und beobachten.
6. Kein Copy/Paste eines State-Machines in den Harness.
7. Kein neuer paralleler Scheduler fuer bereits event-/FSM-getriebene Lifecycle-Schritte.
8. Kein neuer eigener MOOSE-Ersatz, wenn ein vorhandener MOOSE-Pfad den Vertrag bereits abbildet.

## 7. Acceptance Evidence Inheritance

Eine neue Implementierung erbt fruehere Acceptance-Evidenz nur dann, wenn der akzeptierte produktive Ausfuehrungspfad unveraendert weiterverwendet wird.

```text
same production module + same invariant
-> prior evidence may remain applicable to that inherited boundary

copied logic
or rewritten logic
or changed state authority
or changed callback/event
-> prior evidence does NOT transfer
-> DCS revalidation required
```

Ein neuer Harness-PASS kann keine fehlende produktive Implementierung nachtraeglich legitimieren.

## 8. Current FSSR Lifecycle Inheritance Registry

### 8.1 QRF – accepted technical baseline

Verbindliche Referenz:

```text
docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md
accepted A4-8 technical baseline
source/acceptance commit:
a1ab98318b4f614875847d95e58bd0b15695a2d3
DCS:
2.9.29.27468
MOOSE:
2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Zu erhaltende Invarianten:

```text
ONGUARD = recruitment/materialization anchor only
same physical ARMYGROUP
incident participants = target authority
nearest living authorized UNIT
EngageTarget(..., On Road)
Disengage -> reacquire next living target
zero living authorized targets
-> Cancel mission
-> SetReturnToLegion(true)
-> RTZ / Returned / Warehouse lifecycle
```

Jede Base muss diesen Produktionspfad wiederverwenden. Acceptance-eigene QRF-Targeting-/Routing-Logik ist verboten.

### 8.2 Guard – binding production contract

Aktueller produktiver Vertrag:

```text
no physical Guard before alarm
qualified installation incident
-> incident-local ONGUARD
no permanent PATHLINE patrol
no proactive pursuit cycle
incident close
-> Guard Cancel
-> MOOSE ReturnToLegion
```

Der aktuelle allgemeine Guard-Scope ist weiterhin nur fuer die exakt dokumentierten Acceptance-Staende DCS-validiert beziehungsweise DCS-pending zu bewerten. Die Invarianten duerfen dennoch nicht in neuen Harnesses neu erfunden werden.

### 8.3 CAS – binding route/release/recovery law

Verbindliche Referenzen:

```text
docs/moose/STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md
docs/moose/STAGE3-CAS-TACTICAL-CORRIDOR-DECISION.md
docs/moose/STAGE3-CAS-SUPPORT-REQUIREMENT-AND-ENGAGEMENT-DECISION.md
```

Zu erhaltende Invarianten:

```text
MOOSE owns physical mission FSM
owner-authored helicopter route
-> tactical ingress
-> mission area
-> separate egress
-> owner reverse route

own FLIGHTGROUP detection
supported-element release authority
stable no-contact qualification
FuelLow/Bingo != normal mission completion

controlled recovery
-> physical landing at provider home
-> Legion/AIRWING asset returned

OpsOnMission != lifecycle PASS
MissionDone != physical recovery
```

Wenn diese Lifecycle-Funktionen bisher nur in einem spezialisierten Integrationstest implementiert sind, muessen sie vor _base-Acceptance in eine gemeinsame produktive CAS-Lifecycle-Komponente extrahiert werden. Sie duerfen nicht erneut in A8/A9/etc. als Acceptance-eigene State-Machine nachgebaut werden.

### 8.4 Functional ARTY rearm – accepted technical baseline

Referenz:

```text
Ground Ammo Rearm Acceptance 1
source/build commit:
213119ca03a6aeae529d4291b4bbe174ac0995c2
Result: PASS
```

Zu erhaltende Invarianten:

```text
one Functional ARTY FSM owner
Winchester / Rearm / Rearming / Rearmed lifecycle
M1083 physical rearm execution
no simultaneous AUFTRAG:NewARTY ownership of the same battery
```

Eine generische FSSR-ARTY-Integration darf diesen Lifecycle nicht durch einen zweiten Mission-Owner ersetzen.

## 9. Mandatory Pre-Implementation Questions

Vor neuem Code muessen alle Fragen mit YES beantwortet sein oder explizit als genehmigte Aenderung dokumentiert werden:

```text
[ ] Habe ich den letzten akzeptierten Lifecycle gefunden?
[ ] Habe ich dessen produktive Source identifiziert?
[ ] Nutzt mein neuer Pfad genau diese Source weiter?
[ ] Habe ich jede Lifecycle-Invariante dokumentiert?
[ ] Ist der Harness nur Trigger/Observer/Assertion?
[ ] Gibt es keinen zweiten Scheduler/FSM fuer denselben Lifecycle?
[ ] Gibt es keinen neuen Routing-/Release-/Recovery-Owner?
[ ] Ist jede Aenderung gegen die akzeptierte Baseline explizit benannt?
[ ] Ist fuer jede Aenderung die noetige DCS-Revalidation festgelegt?
```

Wenn eine Frage NO ist, wird nicht weiter implementiert.

## 10. A7/A8 corrective consequence

A7 ist Negativ-Evidenz fuer einen Verstoss gegen dieses Gesetz:

```text
accepted/binding CAS lifecycle concepts
-> partially rebuilt inside Acceptance
-> Acceptance timeout became lifecycle authority
-> monitor stopped
-> MOOSE mission continued
-> FuelLow/Bingo path
```

A8 darf daher nicht als DCS-Kandidat freigegeben werden, solange sein CAS Release/Recovery noch als Acceptance-eigene State-Machine implementiert ist.

Der naechste zulaessige Schritt ist:

```text
existing CAS route/release/recovery implementation
-> extract/reconcile into shared production CAS lifecycle module
-> Base injects dependencies
-> Acceptance triggers and observes only
-> static/unit/CI checks
-> owner-local build/hash
-> DCS regression acceptance
```


## 11. A9 validated CAS lifecycle baseline and terminal-return law

Production Base Acceptance 9 has now validated the shared production rotary-wing CAS lifecycle for its exact documented Joyce/Jalalabad scope.

Validated provenance:

```text
source commit:
c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2

Acceptance bundle SHA-256:
D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0

DCS:
2.9.29.27468

MOOSE:
2.9.18
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

For this exact scope the preserved production lifecycle is:

```text
subject-matter CAS demand
-> MOOSE COMMANDER / LEGION provider + asset selection
-> selected-provider owner execution profile
-> owner-authored outbound helicopter route
-> tactical ingress / mission area / separate egress
-> AUFTRAG executing
-> own FLIGHTGROUP detection
-> profile-specific supported-element / no-contact release qualification
-> controlled mission closure
-> owner reverse route
-> physical landing at selected provider home
-> exact LEGION/AIRWING asset return
-> lifecycle complete
```

The following invariants are now mandatory preservation rules for every later FSSR Base reconciliation that reuses this lifecycle:

```text
MOOSE owns operational provider/asset selection.
OMW does not preselect a concrete operational CAS asset.
A selected provider without a known owner execution profile fails closed.
Direct-line routing is not a fallback.
OpsOnMission is not lifecycle completion.
MissionDone is not physical recovery.
FuelLow/Bingo is not normal mission completion.
Release policy is explicit and profile-specific.
nil detection is not equivalent to no contact.
Physical home landing is required before return completion.
Exact Legion/AIRWING asset return is required before lifecycle completion.
Acceptance watchdogs are diagnostic only.
Acceptance harnesses do not own CAS routing, detection, release, RTB or recovery.
```

### 11.1 Post-return physical-representation rule

The A9 first-run false-fail established an additional lifecycle rule:

```text
physical group alive count > 0
-> may be useful loss evidence before authoritative return

LEGION/AIRWING asset returned
-> authoritative physical-return confirmation for this lifecycle
-> later removal/despawn of the temporary DCS group representation
   is cleanup, not asset-loss evidence
```

Therefore:

- loss monitoring based on the temporary physical group must stop once the exact asset-return event has been confirmed;
- a post-return `CountAliveUnits()==0` must not reclassify a returned asset as lost;
- landing alone still does not replace exact asset-return evidence;
- an asset-return event must not be inferred from a despawn;
- CampaignState settlement, when connected later, must use the confirmed lifecycle event idempotently and must not derive a strategic loss from post-return DCS cleanup.

A later implementation may change these invariants only through the existing `INTENTIONAL_CHANGE` path: explicit owner approval, documented reason, bounded revalidation scope and a new real DCS acceptance.

### 11.2 Evidence scope

A9 validates only the documented rotary-wing CAS composition used in that run. It does not automatically validate:

```text
fixed-wing CAS
other provider execution profiles
other site-specific route profiles
ARTY
ARTY rearm
strategic resupply
combined full-response orchestration
```

Those paths must reuse this accepted CAS lifecycle where applicable and test only their genuinely new boundary.
