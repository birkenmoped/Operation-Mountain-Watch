---
document_id: OMW-HANDOFF-AWACS-EXTERNAL-LIFECYCLE-TODO-2026-08-24
status: PLANNED
document_class: HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local AWACS external lifecycle completion order
  - current progress and remaining work for PR 121
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# AWACS External Lifecycle – finaler Abschlussstand

## 1. Branch und Ziel

```text
Branch: agent/awacs-external-lifecycle-foundation
PR: #121 – Stage external AWACS lifecycle foundation
Status: Draft bis zum finalen DCS-/Provenienz-Gate
```

Ziel:

```text
OFFMAP_AL_DHAFRA
-> sichtbare externe WIZARD-Materialisierung
-> ROSIE ingress
-> FL350 / 270 KIAS normal transit
-> APOC FL320 / 250 KIAS persistent racetrack
-> zeitgesteuerter Sensorservice
-> 65 % LISA pre-dispatch
-> LISA FL250 / 270 KIAS AAR track
-> WIZARD FL250 / 290 KIAS dedicated-LISA rendezvous route
-> MOOSE Refuel / DCS final join-contact
-> APOC rejoin
-> Service-Ende-Egress
-> ROSIE outbound
-> external handoff
-> despawn / exact-once strategic recredit
```

## 2. Maßgebliche Regeln

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
```

MOOSE-Stand:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Erledigte Entwicklung

### Stage A – Acceptance-5-Auswertung

Erledigt:

- [x] 15 E-3A-Profile vollständig in DCS geflogen.
- [x] `ALL_COMPLETE profiles=15`.
- [x] 14 `STABLE`, `FL350 / 310 KIAS` `MARGINAL`.
- [x] Runtime-Engineering-Profil aus realen DCS-Messwerten abgeleitet.
- [x] DCS-Version des erfolgreichen Laufs dokumentiert: `2.9.28.26385 MT`.
- [x] ausgeführter Runtime-Source-Stand und Acceptance-5-Bundle-SHA dokumentiert.

Noch reine Provenienzergänzung aus der **real ausgeführten** MIZ:

- [ ] Acceptance-5-MIZ SHA-256.
- [ ] Acceptance-5-internal-`mission` SHA-256.

Ohne diese beiden Werte bleibt Acceptance 5 gemäß Governance `DRAFT`; sie werden nicht geraten.

### Stage B – finale WIZARD-Flugprofile

Erledigt:

- [x] normal transit `FL350 / 270 KIAS`.
- [x] optional fast transit `FL350 / 290 KIAS` dokumentiert, nicht automatisch ausgewählt.
- [x] APOC `FL320 / 250 KIAS`.
- [x] Spawn-/Waypoint-Speed auf dieselbe `UTILS.IasToTas()`-Konvertierung wie Acceptance 5 umgestellt.
- [x] normaler Egress ebenfalls `FL350 / 270 KIAS`.

Finaler Controller:

```text
scripts/air-operations/OMW_AWACS_Controller_FullLifecycle_V3.lua
```

`OMW_AWACS_Controller_FullLifecycle_V2.lua` bleibt nur als Branch-Entwicklungshistorie erhalten und wird vom finalen Foundation-Builder nicht mehr verwendet.

### Stage C – LISA/AAR-Reconciliation

Erledigt:

- [x] LISA AAR track auf `FL250 / 270 KIAS` gesetzt.
- [x] WIZARD dedicated-LISA rendezvous target auf `FL250 / 290 KIAS` gesetzt.
- [x] LISA-ready-Altitude-Gate auf FL250 reconciliert.
- [x] MOOSE-Source für `SetDefaultSpeed`, `AddWaypoint`, `Refuel`, `PauseMission`, `UnpauseMission` geprüft.
- [x] `FLIGHTGROUP:Refuel()` bleibt einziger Receiver-Task-Pfad.
- [x] kein Native-DCS-Refuel-Ersatz.
- [x] kein eigener Contact-Controller.
- [x] Fallback-Tanker erhält kein künstliches LISA-Profil.
- [x] nach `Refueled` wird WIZARD-Default-Speed auf normalen Transit zurückgesetzt.

Source-Befund:

```text
FLIGHTGROUP:Refuel(Coordinate)
-> PauseMission()
-> DCS TaskRefueling()
-> receiver route mit self.speedCruise
-> Refueled FSM
```

Daraus folgt für planned LISA:

```text
SetDefaultSpeed(TAS equivalent of FL250 / 290 KIAS)
-> FLIGHTGROUP:Refuel(LISA coordinate)
-> DCS final join/contact
```

### Stage D – Fuel/Bingo-Reconciliation

Erledigt:

- [x] akzeptierte Tanker-Fuelbaseline auf `main` geprüft.
- [x] deren Formel von unbewiesenen Annahmen getrennt.
- [x] 65/40/25 neu bewertet und **unverändert** gelassen.
- [x] 25 % nicht als physische Al-Dhafra-Landing-Fuel-Garantie dargestellt.

Akzeptierte Tankerlogik auf `main`:

```text
measured TRACK_DEPARTURE -> EXTERNAL_HANDOFF burn
+ virtual EXTERNAL_HANDOFF -> source-base burn
+ 45-minute reserve
```

Zusätzlich existiert dort ein 13,000-lb-Landing-Floor; die 45-Minuten-Komponente war für die dokumentierten Tankerprofile kontrollierend. Eine separate `diversion allowance` ist dort nicht als eigener Term dokumentiert und wird für WIZARD nicht erfunden.

Acceptance 5 ergibt bei `FL350 / 270 KIAS` rein rechnerisch etwa `13.0 %` Fuel für 45 Minuten stabilisierten Geradeausflug. Das ist keine vollständige E-3A-Bingoformel.

OMW-Bedeutung der Schwellen:

```text
65 % = planned LISA pre-dispatch
40 % = fallback AAR trigger
25 % = visible DCS off-map contingency floor
```

### Stage E – Runtime/Builder/Acceptance-Reconciliation

Erledigt:

- [x] finaler V3-Controller erstellt.
- [x] Foundation-Builder auf V3 umgestellt.
- [x] Builder-Marker auf neue Profile umgestellt.
- [x] BOM-Prüfung im Foundation-Builder ergänzt.
- [x] Acceptance-4-Observer um IAS sowie LISA-/AAR-Geometrie erweitert.
- [x] Acceptance-4-Builder auf finale Profile umgestellt.
- [x] Acceptance 4 bleibt observer-only.
- [x] `AWACS-FUEL-DRIVEN-AAR-LIFECYCLE.md` auf finalen Branch-Stand reconciliert.
- [x] Acceptance-4-Dokument auf finalen integrierten Lauf reconciliert.

### Stage F – einheitlicher Build-/Verifikationspfad

Erledigt:

- [x] `tools/build-awacs-final-lifecycle.ps1` erstellt.
- [x] Foundation + Acceptance 4 werden damit in einem Lauf gebaut.
- [x] Source-/Bundle-Hashes werden ausgegeben.
- [x] UTF-8-BOM wird geprüft.
- [x] optional können Acceptance-5-MIZ und finale Lifecycle-MIZ inklusive internal-`mission` SHA-256 ausgewertet werden.
- [x] AWACS-CI prüft zusätzlich `OMW_AWACS_Controller_FullLifecycle_V3.lua` mit Lua 5.1.

## 4. Finaler DCS-Gate

Es ist **kein weiterer Einzel-Speed-Test** vorgesehen. Der nächste DCS-Lauf ist der integrierte Abschlusslauf.

Er muss mindestens beobachten:

```text
WIZARD external spawn
ROSIE ingress
FL350 / 270 KIAS transit
APOC FL320 / 250 KIAS
15:30 service activation without detour
65 % LISA pre-dispatch
LISA FL250 / 270 KIAS ready
immediate planned AAR after LISA ready
WIZARD dedicated-LISA rendezvous behavior
DCS final join/contact
MOOSE Refueled
APOC physical rejoin
sensor restore only after rejoin
LISA deferred FuelLow egress if the condition occurs
service-end / requested egress
ROSIE outbound
external handoff
exact-once CampaignState reconciliation
```

Nicht jeder bereits separat belegte negative Fallback muss künstlich provoziert werden, sofern die finale Änderung seinen Pfad nicht verändert hat.

## 5. Noch offen bis Branch-Abschluss

Nur reale lokale/DCS-Evidenz:

- [ ] `git pull` auf den finalen Remote-HEAD.
- [ ] One-pass Build ausführen.
- [ ] reale Source-/Bundle-Hashes zurückmelden.
- [ ] Acceptance-5-MIZ + internal-`mission` SHA ergänzen, sofern die exakt erfolgreich ausgeführte MIZ vorliegt.
- [ ] Foundation- und Acceptance-4-Bundle in die finale Test-MIZ übernehmen; keine automatisierte MIZ-Mutation.
- [ ] finale Test-MIZ + internal-`mission` SHA erfassen.
- [ ] integrierten DCS-Lauf durchführen.
- [ ] `dcs.log`/relevante Laufzeitevidenz auswerten.
- [ ] Acceptance-Status nur auf Basis dieser realen Ausgabe setzen.
- [ ] PR #121 aus Draft nehmen, finalen Diff/CI prüfen und nach Freigabe mergen.

## 6. Abschlussgrenze

Die Branch-Entwicklung ist damit code-/designseitig auf den finalen DCS-Gate vorbereitet. `VALIDATED` oder `ACCEPTED_TECHNICAL_BASELINE` wird für den neuen V3-Lifecycle erst nach realer DCS-Provenienz gesetzt.
