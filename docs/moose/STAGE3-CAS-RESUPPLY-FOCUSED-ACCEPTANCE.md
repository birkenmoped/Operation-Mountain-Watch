---
document_id: OMW-MOOSE-STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - focused Stage 3 AH-64 CAS route and execution acceptance
  - focused Stage 3 CH-47 slingload route acceptance
  - rejection and remediation of the 2026-09-05 focused test-fixture failure
  - removal of IncidentParticipants as tactical completion evidence in this acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 – Focused CAS + Air-AMMO Resupply Acceptance

## Zweck

Dieser Acceptance-Lauf isoliert die beiden im letzten vollständigen Stage-3-Lauf weiterhin fehlerhaften Luftpfade. Guard, QRF, Artillerie und strategische CampaignState-Abrechnung werden bewusst nicht erneut getestet.

## MOOSE-Basis

Verbindlicher Stand:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Rejected focused run – 2026-09-05

Der erste fokussierte Lauf ist ausdrücklich `REJECTED` und nicht als Verifikation irgendeines Luftpfades verwertbar.

Provenienz:

```text
Git commit:
31fb168b12dd893ed94ba71155a7edf86043e69d

BuilderVersion:
STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-1

Bundle SHA256:
9ABAED9388293DF31A201DE0F2C334BF384F3CCB8B3FB6B3FB9CC2DF938643D4

MizMutation:
false
```

Der reale DCS-Lauf zeigte unmittelbar nach dem Start des Focus-Fixtures:

```text
CAS geometry prepared
CAS mission queued
RESUPPLY FAIL: cargo numeric ID unavailable
READY message was nevertheless emitted
```

Die Ursache lag im Acceptance-Code und nicht in einer nachgewiesenen DCS-Slingload-Einschränkung. Das Fixture verlangte fälschlich:

```lua
if type(state.cargo:GetID()) ~= "number" then
  fail(...)
end
```

Die tatsächlich gepinnte `Moose.lua` dokumentiert `OBJECT:GetID()` als String und verwendet bei `AUFTRAG:NewCARGOTRANSPORT()` den Rückgabewert von `StaticCargo:GetID()` direkt als `CargoTransportation.params.groupId`. Die numerische Typforderung war daher ein erfundener Test-Gate.

Zusätzlich verwendete das Fixture einen einzigen globalen `state.failed`. Dadurch unterdrückte der RESUPPLY-Fehler anschließend auch die unabhängige CAS-Routeninstallation. Das erklärt den im realen Lauf beobachteten direkten AH-64-Flug statt R500/WEST. Der CH-47-Auftrag wurde wegen des vorherigen falschen Gates überhaupt nicht angelegt.

Diese Fehlerklasse ist für das Focus-Fixture jetzt ausdrücklich verboten:

```text
CAS failure      != stop RESUPPLY execution
RESUPPLY failure != stop CAS execution
Acceptance observation != artificial runtime prerequisite
```

## CAS

Der Test verwendet `AUFTRAG:NewCAS`, nicht `AUFTRAG:NewPATROLZONE`.

Die taktische Geometrie wird explizit aus den vorhandenen OMW-Daten abgeleitet:

```text
Jalalabad
-> OMW_FlightPath_R500
-> OMW_FlightPath_WEST
-> tactical ingress = WEST-Ausgang Richtung Honaker
-> CAS working point = Honaker-AO-Zentrum
-> tactical egress = WEST-Ausgang (Acceptance-Variante 1)
-> WEST reverse
-> R500 reverse
-> Jalalabad
```

MOOSE erhält den Ingress über `AUFTRAG:SetMissionIngressCoord()` und den Egress über `AUFTRAG:SetMissionEgressCoord()`. Die CAS-Mission erhält das Honaker-AO-Zentrum als expliziten Orbit-/Working-Point über den `Coordinate`-Parameter von `AUFTRAG:NewCAS`. `SetMissionWaypointRandomization(0)` entfernt die sonst verwendete zufällige Mission-Waypoint-Abweichung.

`AUFTRAG:SetMissionWaypointCoord()` wird für den AH-64 bewusst nicht verwendet, weil die gepinnte MOOSE-Quelle die Methode als `[NON-AIR]` dokumentiert.

Der abgebrochene Focus-Lauf zeigte außerdem eine Regression des Angriffverhaltens: `AUFTRAG:NewCAS()` setzt in der gepinnten MOOSE-Version standardmäßig `ROE=OpenFire`, aber `ROT=EvadeFire`. Der zuvor verwendete CAS-Dispatch-Pfad hatte zusätzlich `SetEngageDetected()` gesetzt; `PATROLZONE` verwendete `PassiveDefense`. Für den nächsten Focus-Lauf wird deshalb ausschließlich über öffentliche, in der gepinnten `Moose.lua` verifizierte AUFTRAG-Methoden explizit gesetzt:

```lua
mission:SetEngageDetected(CAS_RADIUS_NM, {"Ground Units"}, casZone, nil)
mission:SetROE(ENUMS.ROE.OpenFire)
mission:SetROT(ENUMS.ROT.PassiveDefense)
```

Das ist keine neue parallele CAS-Implementierung, sondern die explizite Konfiguration des MOOSE-Auftrags, damit das bereits zuvor verwendete Engagement-Verhalten nicht durch den Wechsel auf `NewCAS()` verloren geht.

Für diesen Focus-Test erfolgt die Freigabe zur Rückkehr ausschließlich testbedingt 90 Sekunden nach dem ersten real bestätigten AH-64-Waffeneinsatz. Dies ist kein Produktionskriterium.

Ausdrücklich nicht zulässig als CAS-/Gefechtsabschluss:

```text
IncidentParticipants == 0
KNOWN_ATTACKERS_NEUTRALIZED
OPSZONE Defeated allein
Alarmzonen-Ausgang allein
```

`IncidentParticipants` sind höchstens Evidenz/Attribution/Targeting-Historie und keine taktische Gesamtlage.

## CH-47 Air-AMMO

Der Test behält `AUFTRAG:NewCARGOTRANSPORT` als MOOSE-Ausführer für den physischen Slingload bei.

Die gepinnte MOOSE-Quelle legt beim Konstruktor bereits die relevanten Referenzen an:

```text
cargo
cargo groupId = StaticCargo:GetID()  # MOOSE ID may be string
DropZone
DropZone zoneId
```

Der Acceptance-Kontext hält Cargo und DropZone zusätzlich explizit fest und übergibt beim Route-Handoff:

```text
cargo
cargoId = cargo:GetID()              # string or number; no invented numeric gate
dropZone
zoneId = dropZone.ZoneID
```

Nach physisch bestätigter Aufnahme wird über den öffentlichen MOOSE-Lifecycle `PauseMission()` die laufende CargoTransportation-Aufgabe freigegeben. Erst nach Task-Freigabe wird R500 outbound/return installiert; am Wright-seitigen Routenende wird der CargoTransportation-Task für exakt dasselbe Cargo und dieselbe DropZone erneut angesetzt. Die physische Ablieferung muss bestätigt sein, bevor die Mission als erfolgreich gilt.

Die bekannte DCS-Runtime-Frage bleibt unverändert offen und kann nur im realen Test beantwortet werden: Bleibt der externe Slingload während `PauseMission -> TaskCancel -> TaskDone` physisch angehängt? Diese Unsicherheit wird nicht durch einen künstlichen Test-Gate vorweggenommen.

## Acceptance-Isolation

Das Focus-Fixture besitzt getrennte Zustände für:

```text
fatal/shared setup failure
CAS failure
RESUPPLY failure
```

Nur ein echter gemeinsamer Setup-Fehler darf beide Pfade verhindern. Ein CAS-Fehler darf den CH-47-Pfad nicht abschalten; ein CH-47-Fehler darf die AH-64-Routen-/Angriffsausführung nicht abschalten. `READY` darf nur für tatsächlich angelegte/aktive Teiltests ausgegeben werden.

## Acceptance-Dateien

```text
mission/tests/stage3-cas-resupply-focused/src/01-stage3-cas-resupply-focused-acceptance.lua
tools/build-stage3-cas-resupply-focused-acceptance-1.ps1
```

Generiertes Bundle:

```text
mission/tests/stage3-cas-resupply-focused/dist/OMW_Stage3_CAS_Resupply_Focused_Acceptance_1.lua
```

## DCS-Acceptance

CAS muss real nachweisen:

```text
AH-64 Start Jalalabad
R500
WEST
expliziter taktischer Ingress
CAS-Ausführung im Honaker-Bereich
realer Waffeneinsatz trotz gegnerischen Bodenfeuers
Acceptance-Release
erklärter Egress
WEST reverse
R500 reverse
Landung Jalalabad
AIRWING recovery
```

CH-47 muss real nachweisen:

```text
CARGOTRANSPORT tatsächlich angelegt
physische Slingload-Aufnahme
MOOSE Task Release
Slingload bleibt physisch erhalten
R500 outbound
physische Ablieferung Wright
R500 reverse
Landung Jalalabad
AIRWING recovery
```

`VALIDATED` wird erst nach dokumentiertem realem DCS-Lauf gesetzt. Ein vollständiger Stage-3-Retest ist erst zulässig, wenn beide Focus-Pfade unabhängig funktional nachgewiesen sind.
