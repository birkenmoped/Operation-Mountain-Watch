---
document_id: OMW-TEST-FIXED-WING-CAS-RESPONSE-ACCEPTANCE-4
status: PLANNED
document_class: TEST_ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local fixed-wing CAS MOOSE AAR and flight profile acceptance
not_authoritative_for:
  - validated safe return, optimized CAS tanker selection, durable C2 AAR policy
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fixed-wing CAS response — Acceptance 4

## Grundlage

Aufbauend auf dem A3-DCS-Lauf: sechs Fluege gestartet, alle drei Squadrons wurden rekrutiert; F-16/F-15E bildeten einen Two-Ship Join, aber A-10 hatten keinen eigenen Kandahar-Holding-Vertrag. Der A3-Transit war auf den niedrigen, aus `NewCAS` geerbten Missions-Speed beschraenkt. Ein F-16-Wingman und beide A-10 gingen nach Treibstofferschoepfung verloren. Automatisches MOOSE-FuelLow-RTB funktionierte, brachte die Langstreckenfluege aber nicht rechtzeitig zurueck.

A3 lokaler Bundle SHA-256 `19E6C3054F90D7538BA65F6AA4A898F37BE8BE54794C3EDFD50CA0B000CF41ED`; zugehoeriger Branch-Commit `08e54252aeba88245cff70e1d4a7fda47f2883e3`. A4 enthaelt neue, noch nicht in DCS getestete CAS-AAR-Integration.

## A4-MOOSE-First-Aenderungen

- MOOSE-Holding/Join fuer **alle drei Two-Ships**, Kandahar-A-10 bei zunaechst 12.000 ft MSL / 210 kn; maximal 2 NM Abstand, beide airborne; Bagram unveraendert.
- `AUFTRAG:SetMissionSpeed` **getrennt** vom `AUFTRAG:NewCAS(..., orbitSpeed)`: F-16 450 kn / Orbit 350 kn, F-15E 460 / 350, A-10 260 / 230. 22.000 ft MSL Cruise einschliesslich MOOSE-RTB (Streckenpruefung noch ausstehend).
- A-10 `COHORT:SetMissionRange(400)` und `AUFTRAG:SetMissionRange(400)` bleiben test-only Rekrutierungsparameter, **keine** Reichweitengarantie.
- Tankerauswahl: `OMW.AAR.GetActive(area, profile)` aus dem bestehenden Produktions-AAR-Controller auf `main`. Es werden **nur tatsaechlich aktive, alive, auf Station befindliche, nicht im Egress befindliche** physische Tanker betrachtet. Physische Kompatibilitaet wird mit `UNIT:IsTanker()` gegen `FLIGHTGROUP.refueltype` geprueft. Luftlinienentfernung im Test: Tanker muss naeher als `homebase` und maximal 500 NM entfernt sein.
- A-10-Kandidaten ausschliesslich **PATTY/SLOW** und **MILHOUSE/SLOW**. KRUSTY ist fuer diesen Auftrag explizit ausgeschlossen. Fastjets Kandidaten **NELSON/FAST**, **LISA/FAST**, **MOE/FAST**; LISA/MOE werden nur betrachtet, wenn ihre realen Reserve-Runtimes aktiv sind.
- Bei MOOSE-`FuelLow` wird ein geeigneter Tanker gewaehlt. `FLIGHTGROUP:Refuel(tankerCoordinate)` bleibt der **einzige** physische Betankungsauftrag und nutzt MOOSE-`PauseMission` und `Refueled`. Falls kein geeigneter Tanker vorhanden ist, wird der normale MOOSE-`RTB` aufgerufen.
- Bei A-10 testweise **fruehzeitiges** AAR bei 65 % `FLIGHTGROUP:GetFuelMin()`, nachdem beide Flugzeuge sich nach Kandahar-Departure im Join befinden, solange noch kein vollstaendiger AO-Eintritt gemessen wurde und vorher keine AAR begonnen hat. Dieser Wert stammt als **Explorationswert** aus dem nachgewiesenen AWACS-Muster und ist **keine genehmigte langfristige CAS-Fuel-Policy**.
- `SetFuelLowRTB(false)` und `SetFuelLowRefuel(false)` waehrend A4, damit das MOOSE-FuelLow-Ereignis nicht gleichzeitig unkoordiniert automatisches 50-NM-Refuel oder RTB ausfuehrt. Der A4-Observer faellt bei fehlendem geeigneten Tanker auf `FLIGHTGROUP:RTB` zurueck. Das gepinnte MOOSE-`FuelCritical`-RTB bleibt unveraendert. Keine native DCS-Refuel-/Flight-Routine.
- AAR-Events: `AAR_SELECTED`, `AAR_NOT_AVAILABLE`, `AAR_REFUELED`, `AAR_FALLBACK_MOOSE_RTB`. Bestehende Fuel-/Cruise-Telemetrie bleibt.

**Sicherheits-/Evidenzgrenzen:** Die aktive AAR-Auswahl prueft die Luftliniennaehe, nicht die Kraftstoffmenge fuer eine tatsaechlich sichere Rendezvous- und Landing-Route. MOOSE Flightgroup-`Refuel` ist fuer unsere CAS-Two-Ship-Mission noch nicht DCS-validiert. Ein fehlender geeigneter Tanker kann auch bei FuelLow zu spaet sein, um zum Heimatflugplatz zurueckzukommen. **Deshalb nicht als sichere produktive Fuel-Policy freigeben.** A4 ist ein gezielter, explizit zu beobachtender Test.

## Durchfuehrung

Gleicher C2-/CAS-Honaker-Test, mit F-16 Bagram, A-10 Kandahar 60 s spaeter, F-15E nach beiden F-16-Takeoffs. Nur Nutzer editiert separate Test-`.miz`; A1/A2/A3 nicht gleichzeitig laden. Vor Start lokale Git-Pull/PowerShell-Build-/SHA256- und MIZ/MOOSE/Bundle-Verifikation. AAR-Produktionscontroller und Tanker-Bootstrap muessen vor A4 geladen sein; AAR-Availability sowie physische on-station-Pruefung per Log dokumentieren. Bei fehlendem `OMW.AAR` oder ohne aktive Kandidaten muss A4 das eindeutig anzeigen und darf keine Tanker-Fiktion annehmen.

Abnahme:
1. Jeder Two-Ship nach der Departure gejoint, auch A-10 ueber Kandahar.
2. Schnellerer Alarm-CAS-Transit und wirtschaftlicher CAS-Orbit in TAS/IAS/Fuel gemessen.
3. Alle drei Aircraft-Typen haben einen echten C2-Request, eine reale AAR-Auswahl nur aus den erlaubten Tracks und einen MOOSE Refuel/Refueled-Lifecycle, soweit ein Kandidat benoetigt und verfuegbar ist.
4. Kein paralleler DCS-Task-Override, kein Name-/Tanker-Crossmix und keine erfundene AAR-Verfuegbarkeit.
5. Rueckkehr/Einsatzfortsetzung/Fuel bis nach Landung, kein eigener Fuel- oder Terrain-Verlust.

## Offene Architekturentscheidung

Einsatzprofil `Alarm-CAS` vs. `Scheduled CAS Standby` bleibt getrennt. Der fuer A4 gewaehlte A-10-65%-Fruehausloeser ist **ausschliesslich ein zu bewertender Testparameter**. Ein verbindlicher Scheduled-CAS-Tanker-vor-AO-Vertrag, eine C2-MissionDemand-API fuer receiverseitige Betankungsanforderungen, sichere Reichweitenprognosen und die Wahl des Tanksystems im Warteschleifen-Engpass erfordern eigene Governance-/Akzeptanzentscheidung. A4 faehrt **keine** eigene dynamische Treibstoff-Vorhersage.

## Dateien

```text
mission/tests/fixed-wing-cas-response/src/acceptance-4-three-flight-joined-aar.lua
tools/build-fixed-wing-cas-response-acceptance-4.ps1
mission/tests/fixed-wing-cas-response/dist/OMW_FixedWing_CAS_Response_Acceptance_4.lua
```

Quellen: `docs/moose/AWACS-FUEL-DRIVEN-AAR-LIFECYCLE.md`, `docs/29-isaf-2009-2013-air-to-air-refueling.md`, `scripts/air-operations/OMW_AAR_Controller.lua`, `scripts/air-operations/OMW_AWACS_Controller_FullLifecycle_V3.lua`, gepinnte `Moose.lua` 2.9.18 (siehe Source-Dokumentation).

## DCS-Ergebnisnachtrag vom 17.10.2026: FAIL

Dieser Abschnitt ergaenzt den **urspruenglichen Testvertrag**, ohne dessen damalige Planungsparameter nachtraeglich umzudeuten. Originaltest-Source `ae4961a46cbe2bd47dfbb1a67426e480798b2135`, Owner-Bundle-SHA-256 `284F001BD397DC171F4EB17B8676E75BAA37AC00D2588D59724804722E3C7FA8`, DCS `2.9.30.28738 MT`, User-Uploads `dcs(3).log` und `debrief(3).log`, eingesetzte MOOSE-Version projektseitig `2.9.18`. **MIZ- und embedded-MOOSE-SHA256 nicht abschliessend vorgelegt, daher keine komplette technische Akzeptanzprovenienz.**

**Resultat:** Alle drei echten MOOSE-C2-Requests wurden zugewiesen und jeweils zwei Flugzeuge starteten. Alle drei Two-Ships erreichten `TWO_SHIP_JOINED`. A-10 wurden bei PATTY ueber MOOSE betankt (`AAR_SELECTED t=58191, fuelMin=64.89 %`; `AAR_REFUELED t=61295, fuelMin=98.04 %`), danach **kein** `MISSION_EXECUTE`/`ELEMENT_IN_AO` fuer die A-10 nachgewiesen. F-16-Wingman erreichte `fuelFraction=0` und crashte. Beide A-10 crashen deutlich **nach** ihren letzten Observer-Werten von ca. 86–87 % Fuel; unmittelbare Crashursache offen, weil danach Telemetrie fehlt. Beide F-15E landeten in Bagram und stellten die Triebwerke ab, bei geringer Restreserve. **Gesamt: drei sicher zurueck, drei verloren. Acceptance 4 FAIL.**

`missionState=success` ist kein Beleg fuer vollendetes CAS im AO oder fuer physische sichere Rueckkehr. `Fuel=0` bei einer F-15E am Ende der Bodentelemetrie liegt **nach** Landung, darf nicht als Absturz gewertet werden. `AAR_NOT_AVAILABLE` bei den Fastjets meint Ablehnung der konkreten Test-Tankerauswahl, nicht generelle Nichtexistenz eines Tankers. Vordringliche Reconciliation: A-10 AAR -> MOOSE-Pause/Resume -> Mission-Abschluss ohne AO; Observer-Luecke vor beiden A-10-Crashs; F-16 Fuel- und Bagram-Landing-Recovery ohne akzeptablen Tanker. Die Testergebnisse uebertragen keine erfolgreiche AAR-/RTB-Policy auf Produktion.

**Vollstaendige Evidenz-/Folgechat-Uebergabe:** [Handoff 2026-10-17](../../../docs/handoffs/2026-10-17-fixed-wing-cas-acceptance-1-to-4-handoff.md). A5 erst nach MOOSE-/AWACS-/AAR-Source-Abgleich und Architekturentscheidung.
