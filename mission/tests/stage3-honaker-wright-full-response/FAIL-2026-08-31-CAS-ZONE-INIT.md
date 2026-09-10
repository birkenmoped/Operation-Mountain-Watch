---
document_id: OMW-TEST-STAGE3-HONAKER-WRIGHT-FAIL-2026-08-31-CAS-ZONE-INIT
status: HISTORICAL_TEST_FIXTURE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact 2026-08-31 Stage 3 DCS failure provenance and observed initialization failure
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: 2bfa2b8e9f1b6a1efe2f4699fe59b9e4f4944d8d
validated_in_dcs: false
---

# Stage 3 Honaker/Wright – DCS FAIL 2026-08-31: CAS-Zone-Initialisierung

## Ergebnis

Der DCS-Lauf vom 31.08.2026 ist **FAIL**. Er validiert weder Guard, Alarmierung, QRF, CAS, ARTY noch strategische Closure, weil der Acceptance-Harness waehrend `setupDefenceAndThreat()` vor Aktivierung dieser Kette abbrach.

## Exakte Provenienz

```text
Git commit:
2bfa2b8e9f1b6a1efe2f4699fe59b9e4f4944d8d

BuilderVersion:
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-7

Bundle SHA-256:
BEFBC6E8481980F50030E1A5DF5B5A30FEBADEFE4088C2617C33C96B62B3CFBD

MIZ:
OMW_Template_v20_GroundWorks.miz

Uploaded tested MIZ SHA-256:
1A856E9602C204BAC65AC115722CA68FEC724301B45AC2E2F63D93B04C3F12FA

DCS:
2.9.29.27278

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Reale Runtime-Evidenz

Das `dcs.log` zeigt unmittelbar nach Anlage des Honaker-BRIGADE-Kontexts:

```text
Error in timer function:
OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua:5071:
attempt to call method 'SetDrawZone' (a nil value)

stack:
setupDefenceAndThreat
```

Der Acceptance-Code hatte auf einer `ZONE_RADIUS`-Instanz fälschlich folgende `OPSZONE`-Methoden aufgerufen:

```lua
state.casTacticalZone:SetDrawZone(false)
state.casTacticalZone:SetMarkZone(false)
```

Die gepinnte `Moose.lua` belegt `SetDrawZone()` / `SetMarkZone()` fuer `OPSZONE`; fuer die verwendete `ZONE_RADIUS` waren diese Methoden nicht vorhanden. Die CAS-Tactical-Zone muss nicht explizit "unsichtbar geschaltet" werden, solange `DrawZone()` beziehungsweise `MarkZone()` nicht aufgerufen werden.

## Warum die gesamte Honaker-Kette ausfiel

Der Fehler lag nicht in einer bereits laufenden CAS-Mission. Die CAS-Tactical-Zone wurde im alten Harness **eager** innerhalb von `setupDefenceAndThreat()` erzeugt, bevor:

```text
Guard-Platoon / Guard mission
QRF-Platoon
BRIGADE start
Threat OPSZONE start
Alarm callback
CAS demand
ARTY dispatch
```

vollstaendig aktiviert waren. Ein Fehler in einer spaeter eigentlich optional beziehungsweise demand-getriebenen Response-Komponente konnte dadurch die komplette Installationsreaktion vor ihrem Start abbrechen.

## Korrekturprinzip nach dem FAIL

Ab dem Folgecommit wird fuer diesen Acceptance-Harness folgende Fehlergrenze verwendet:

```text
Foundation / installation defence
-> Guard / QRF / threat sensing / ARTY remain independently observable

CAS tactical context
-> created lazily only after a real CAS demand exists

CAS setup / dispatch / corridor failure
-> scoped CAS failure
-> blocks final Stage-3 PASS
-> MUST NOT stop Guard/QRF/ARTY/logistics diagnostic execution
```

Das ist keine Abschwaechung der Acceptance-Kriterien. Ein CAS-Fehler verhindert weiterhin den Gesamt-PASS. Die Aenderung verhindert lediglich, dass ein isolierter Subsystemfehler alle anderen Testpfade unobservable macht.

## DCS-Grenze

Die Korrektur ist erst nach einem neuen Build mit neuer Commit-/Bundle-Provenienz und einem neuen realen DCS-Lauf bewertbar. Dieser FAIL bleibt historischer Nachweis und darf nicht als `VALIDATED` oder `PASS` interpretiert werden.
