---
document_id: OMW-TEST-FIXED-WING-CAS-RESPONSE-ACCEPTANCE-1
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local three-flight MOOSE-C2 fixed-wing CAS response timing acceptance
  - response measurement and Bagram two-ship staggered incident trigger
not_authoritative_for:
  - DCS-validated response times, routing, ATC causality or AAR behavior
  - changes to existing aircraft foundations, AAR or CampaignState contracts
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fixed-Wing CAS Response – Acceptance 1

## Ziel und unveraenderte Eingangsmission

Ein DCS-Lauf mit drei tatsaechlichen MOOSE-`AUFTRAG:NewCAS`-Anforderungen, demselben `COMMANDER`, bestehenden AIRWING-/SQUADRON-Objekten und drei vorhandenen Two-Ship-Templates:

1. Bagram / `SQ_US_BGRM_F16C_121_EFS` / `TPL_AIR_US_BGRM_F16C_CAS_2SHIP`;
2. Kandahar / `SQ_US_KAF_A10C_74_EFS` / `TPL_AIR_US_KAF_A10C_CAS_2SHIP`;
3. Bagram / `SQ_US_BGRM_F15E_335_EFS` / `TPL_AIR_US_BGRM_F15E_CAS_2SHIP`.

Quellmission: vom Projektinhaber bereitgestellte `OMW_Template_v26_GroundWorks_Ready(4).miz`. **Das GitHub-Bundle veraendert diese Datei nicht.** Ihre eingebettete `l10n/DEFAULT/Moose.lua` wurde im Quellarchiv mit SHA-256 `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915` geprueft; gepinnter MOOSE-Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`. Die eigentliche DCS-Testkopie erhaelt vor einem Lauf eine neue MIZ-/Bundle-Hashkette.

## Bestehende Architektur, kein alternativer Dispatcher

Die Missionseditor-Skripte `OMW_AirOps_Bagram.lua` und `OMW_AirOps_Kandahar.lua` legen jeweils AIRWING, SQUADRON, Gruppenbestand, Gruppierung und Payloads an und starten die Wings. Sie erzeugen laut Source selbst **keinen** Fixed-Wing-CAS-Dispatcher.

Das Acceptance-Bundle arbeitet ausschliesslich auf den publizierten `OMW.AirOps.Bagram/Kandahar`-Objekten:

```text
MOOSE COMMANDER
  -> AUFTRAG:NewCAS(AO)
  -> AUFTRAG:AssignSquadrons({vorhandene SQUADRON})
  -> AUFTRAG:SetRequiredAssets(1,1)
  -> COMMANDER:AddMission
  -> AIRWING/SQUADRON/FLIGHTGROUP normale MOOSE-Missionsausfuehrung
```

Eine Asset-Gruppe besteht hier laut bestehenden SQUADRON-Definitionen aus zwei Maschinen (`grouping=2`). Deshalb bedeutet `SetRequiredAssets(1,1)` **eine Two-Ship-Gruppe** und nicht zwei Asset-Gruppen.

Die Staffelzuweisung ist eine **MOOSE-eigene Request-Capability-Einschraenkung**, um die drei ausdrücklich gewuenschten Luftfahrzeugtypen zu testen; alle Auswahl-, Rekrutierungs- und Flug-Lifecycles laufen weiter in MOOSE. Es gibt keinen OMW-Spawn-Dispatcher, kein Controller-Routing und keinen koordinierten ATC-Eingriff.

**Scope-Grenze:** Dieser erste vertikale Test erzeugt echte MOOSE-Missionen ueber `COMMANDER`, aber noch keinen vollstaendig integrierten produktiven `MissionDemand -> AIR_SUPPORT_REQUEST -> AIR_TASKING_PLAN`-Datensatz. Dessen automatische Fixed-Wing-CAS-Runtime ist laut verbindlicher ATO-Foundation noch nicht vorhanden. Diese Grenze darf nicht als fertiger Produktivpfad ausgegeben werden.

## Szenario-Trigger und Beobachtung

- Bundle beginnt mit einer einmaligen Startverzoegerung von 30 s, ausschliesslich um die vorhandenen Mission-Editor-Initialisierungen abwarten zu koennen.
- Request `CAS_F16` zuerst.
- Request `CAS_A10` einmalig 60 s nach dem ersten Request, als separater zweiter Incident waehrend des laufenden Szenarios.
- Request `CAS_F15E` **erst nach zwei unterschiedlichen MOOSE-`OnAfterElementAirborne`-Ereignissen der zugewiesenen F-16-`FLIGHTGROUP`**, zusaetzlich `CountElements() == 2` und `GROUP:IsAirborne(true)`.
- Beobachtungsintervall 15 s fuer Positionsprotokollierung; kein Steuer-/Korrektureingriff.
- Gemeinsame AO-Basis: vorhandene ME-Zone `ZON_BLUE_GND_HONAKER_ACCESS`; fuer diesen spezifischen Vergleich ein MOOSE-`ZONE_RADIUS` von 5 NM um ihren Anker. Diese temporaere Test-AO ist keine generelle CAS-Routendoktrin oder Ground-Alarm-Zone.

Wichtige Logger-Marker:

```text
HARNESS_LOADED
C2_STARTED
REQUEST_CREATED / REQUEST_SUBMITTED_C2
FLIGHT_ASSIGNED
ELEMENT_TAXIING / ELEMENT_TAKEOFF / ELEMENT_AIRBORNE (je individuelles Flugzeug)
MOOSE_MISSION_EXECUTE
ELEMENT_IN_AO (je individuelles Flugzeug)
TWO_SHIP_IN_AO
POSITION_OBSERVER / ELEMENT_FUEL_OBSERVER
```

Alle Events protokollieren `UTILS.SecondsOfToday()`. Berechnet werden pro Flight `REQUEST_CREATED -> ELEMENT_AIRBORNE` getrennt pro Aircraft, `REQUEST_CREATED -> ELEMENT_IN_AO` und `REQUEST_CREATED -> TWO_SHIP_IN_AO`. Die Positionserfassung mit 15-s-Intervall erzeugt einen Messfehler von bis zu ungefaehr 15 s beim AO-Eintritt. Landebahnkreuzung, ATC-Freigabe und Nachbrenneraufholen sind aufgrund fehlender expliziter MOOSE-Events **zunaechst visuelle DCS-/Track-Beobachtungen**, nicht als automatisch bewiesene Ursachen auszugeben.

## AAR-/Fuel-Grenze

Alle MOOSE-/DCS-Entscheidungen zu Fuel, AAR, RTB, Taxi, Nachbrenner, Navigation und Waffen bleiben unveraendert. Das Bundle weist **keinen** Tanker zu und erzeugt keine AAR-Mission. Gegebenenfalls vorhandene AAR-Automatik der geladenen Mission wirkt unveraendert; eine autonome Refuel-Entscheidung des CAS-Flights ist **nicht** schon durch die Moeglichkeit `FLIGHTGROUP:Refuel` bewiesen. Tatsaechliches AAR-Verhalten muss im DCS-Lauf beobachtet werden.

## MOOSE-Source- und Demo-Nachweise

Im mitgelieferten `Moose.lua`-Stand:

- `COMMANDER:New`, `COMMANDER:AddAirwing`, `COMMANDER:AddMission`, `COMMANDER:Start` und `OnAfterOpsOnMission`: normaler C2-Auftragsweg.
- `AUFTRAG:NewCAS`, `AssignSquadrons`, `SetRequiredAssets`: native CAS-Mission und Staffelbindung.
- `FLIGHTGROUP:OnEventTakeOff` fuehrt `ElementTakeoff` je Unit aus; `onafterElementTakeoff` aktualisiert Status und triggert `ElementAirborne`.
- `OnAfterElementAirborne` ist ein oeffentlicher FSM-Callback; `CountElements` zaehlt registrierte Formationselemente.
- `GROUP:IsAirborne(true)` prueft die aktuell vorhandenen Gruppen-Units auf `InAir`.
- `ZONE_BASE:IsCoordinateInZone`, `GROUP:GetUnits`, `UNIT:GetCoordinate` liefern passive AO-Beobachtung.
- `SCHEDULER:New` erzeugt ausschliesslich die zweite Szenarioanforderung und passive Beobachtung.

Offizielles Demosample: [EVT-102 – UNIT OnEventTakeoff Example](https://github.com/FlightControl-Master/MOOSE_MISSIONS_UNPACKED/blob/master/EVT%20-%20Event%20Handling/EVT-102%20-%20UNIT%20OnEventTakeoff%20Example/EVT-102%20-%20UNIT%20OnEventTakeoff%20Example.lua). Die Demonstration ist ein Unit-Event-Beispiel, **kein End-to-End-CAS-/Bagram-ATC-Test**.

## Build und DCS-Acceptance

Builder: `tools/build-fixed-wing-cas-response-acceptance-1.ps1`.

Output: `mission/tests/fixed-wing-cas-response/dist/OMW_FixedWing_CAS_Response_Acceptance_1.lua`.

Der Builder schreibt Version, Git-Commit, UTC-Erzeugungszeit und gepinnten MOOSE-Hash in den Lua-Header. Er enthaelt statische No-Override-Pruefungen und ist in PowerShell ohne Python ausfuehrbar.

Eine Kopie der v26-Mission ist gemäss [Dokument 22](../../../docs/22-test-mission-build-transfer-and-validation-workflow.md) in DCS zur Testmission zu machen; das generierte Bundle muss nach `Moose.lua` und beiden AIRWING-Foundation-Skripten als **DO SCRIPT FILE** eingebunden werden. Kein bestehender Trigger darf ersetzt oder deaktiviert werden. Nach dem Mission-Editor-Speichern die vollstaendige MIZ-/MOOSE-/Bundle-SHA-256-Kette ermitteln. **Der vorhandene Upload bleibt unveraendert. Die ME-Einbindung des Bundles ist eine explizite Testkopie und noch kein in DCS bestaetigtes Artefakt.**

Acceptance nach realem Test:
1. Alle drei Anfragen wurden genau einmal erstellt; F-15E erst nach zwei F-16-Airborne-Ereignissen.
2. MOOSE rekrutiert je eine Two-Ship-Gruppe aus der zugewiesenen SQUADRON; alle Aircraft sind identifizierbar.
3. Vollstaendiger Taxi-, Start-, AO- und Missionsverlauf wird beobachtet; Bagram-Runway-Kreuzungsreihenfolge visuell dokumentieren.
4. Lead-/Wingman-Response und Fuel-/AAR-Verhalten werden aus Logs/Debrief und Beobachtung getrennt ausgewertet.
5. Bei Fehlverlauf bleiben MOOSE-Mission, Fuehrung, DCS-ATC und native Fuel-Regeln unveraendert; kein automatische Testreparatur.
6. Kein `VALIDATED` ohne durchgefuehrten DCS-Test mit Commit, Bundle, MIZ, DCS- und MOOSE-Provenienz.

Keine DCS-Runtime-Behauptung vor dem realen Test.


## Acceptance 2 (Nachfolge; A1 unveraendert)

Auf den dokumentierten A1-DCS-Befund folgt [Acceptance 2](ACCEPTANCE-2.md): MOOSE `SetMissionHoldingCoord` + `AddConditionPush` fuer Bagram-Two-Ship-Join, CAS-Missionshoehe 22.000 ft MSL, Fuel-Low-/Critical-/RTB-Observer und C2-Pending-Diagnostik fuer Kandahar. Neues Lua-Quellfile und eigener PowerShell-Builder. Beide Testbundles **niemals gleichzeitig in der .miz laden**. A2 ist `DCS_PENDING`, kein DCS-PASS.
