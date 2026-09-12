---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE4-STAGE3-REGRESSION
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-4 regression scope for the historical Honaker/Wright Stage-3 fixture
not_authoritative_for:
  - DCS runtime acceptance
  - production acceptance of the generic base
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Gate 4 – Stage-3-Regression Honaker/Wright

## Referenz

Read-only bereitgestellter Missionsstand:

```text
OMW_Template_v22_GroundWorks(8).miz
MIZ SHA-256: 25387ABB697E9D500F243EF5D2220459EC6AA711712DB57F126DDF7C7D47E0FA
embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
embedded Stage-3 bundle SHA-256: 33CEB7AA6BC7FA833CCF456C41B689245B0CB70BD587AF533D0071A92B346661
```

Die MIZ wird nicht automatisch verändert.

## Regressionsgrenze

Der reale Stage-3-Stand zeigt folgenden fachlichen Ablauf:

```text
lokale Honaker-Verteidigung bereits aktiv
-> MOOSE Alarm-/OPSZONE-Evidenz
-> Attack Incident
-> QRF und CAS nach konkretem Bedarf
-> ARTY erst nach vorhandener C2-Ziellage
-> lokale Wright-Rearm-Kette bei physischem Bedarf
-> strategischer Resupply erst nach konkretem Ressourcenbedarf
-> bestätigte MOOSE-Lifecycle-Ereignisse
-> idempotente strategische Buchung
```

`enabled=true` im SupportProfile ist daher nur eine Capability-Freigabe. Es ist kein Auftrag, beim Öffnen eines Incidents alle Supportarten sofort zu dispatchen.

## Korrektur vor DCS-Gate 4

Der erste Gate-3-Smoke-Entwurf hatte alle aktivierten Supporttypen beim `OpenIncident()` automatisch erzeugt. Der Vergleich mit dem realen Stage-3-Stand widerlegt dieses Verhalten. Die Base wird deshalb vor dem Gate-4-Runtime-Test auf folgenden Vertrag korrigiert:

- `OpenIncident()` erzeugt ausschließlich den Incident-Kontext.
- `RequestSupport()` erzeugt genau einen fachlich angeforderten Supportbedarf.
- Wiederholte Zyklen dürfen einen stabilen `requestKey` verwenden.
- Resupply wird ressourcenspezifisch angefordert und nicht pauschal beim Angriff gestartet.
- MOOSE bleibt für operative Rekrutierung, Queue und Ausführung zuständig.

## Späterer DCS-Minimalnachweis

Gate 4 bleibt `PLANNED`, bis eine vom Projektinhaber manuell aktualisierte Kopie der v22-MIZ mindestens erneut belegt:

1. Alarm und fachliche Trigger erzeugen die Supportbedarfe zum vorgesehenen Zeitpunkt.
2. Guard/QRF bleiben lifecycle-seitig getrennt.
3. ARTY, CAS und Resupply blockieren sich nur an dokumentierten Deconfliction-Grenzen.
4. CAS verwendet eigene Detektion und dynamische Owner-Routen.
5. Rückgabe und Lieferung werden erst nach bestätigtem MOOSE-Ereignis strategisch gebucht.
6. Keine OMW-Asset-Vorselektion, keine zweite Retry-/Dispatcher-Queue und keine festen CAS-Marker/Battle-Positionen.
