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

## Verbindlich präzisierter Support-Lifecycle

Der Projektinhaber hat den bereits angelegten Standortbetrieb für die generische Base wie folgt präzisiert:

```text
Standort aktiv
-> Guard als dauerhafte Nahbereichssicherung / Patrouille

Installation wird angegriffen
-> QRF als lokale Selbstverteidigung
-> lokale Mortars / lokale ARTY nur, wenn für den konkreten Standort nachgewiesen und konfiguriert

qualifizierter Alarm-/Perimeterzustand
-> C2-Anforderung für externe ARTY und/oder CAS

Warehouse-/Store-Bestand unterschreitet konfigurierte Schwelle
-> Resupply-Anforderung unabhängig von einem Angriffsincident
```

Die bestehende projektweite Ground-Alarm-Regel bleibt unverändert: Die standortbezogene MOOSE-`OPSZONE`-/Radiuszone ist Threat-Detection- und Response-Trigger, keine Engagement Area und keine Missionsendebedingung.

`enabled=true` bleibt ausschließlich Capability-Freigabe. Die Aktivierungssemantik ist separat:

- `GUARD`: `SITE_PERSISTENT`;
- `QRF`: `INCIDENT_LOCAL_DEFENSE`;
- vorhandener generischer `ARTY`-Pfad: `C2_ESCALATION_EXTERNAL`;
- `CAS`: `C2_ESCALATION_EXTERNAL`;
- `GROUND_RESUPPLY` / `AIR_RESUPPLY`: `RESOURCE_THRESHOLD`.

Lokale Mortars oder lokale ARTY werden nicht aus dem historischen Wright-Fire-Support-Fixture verallgemeinert. Eine solche Fähigkeit wird erst dann als eigene lokale Standortfähigkeit konfiguriert, wenn die jeweilige Site-/ORBAT-Baseline sie tatsächlich belegt.

## Regressionsgrenze

Der reale Stage-3-Stand zeigt folgenden fachlichen Ablauf:

```text
lokale Honaker-Verteidigung bereits aktiv
-> MOOSE Alarm-/OPSZONE-Evidenz
-> Attack Incident
-> QRF nach lokalem Incident-Bedarf
-> externe ARTY und CAS nach qualifiziertem Fire-Support-/C2-Bedarf
-> lokale Wright-Rearm-Kette bei physischem Bedarf
-> strategischer Resupply erst nach konkretem Ressourcenbedarf
-> bestätigte MOOSE-Lifecycle-Ereignisse
-> idempotente strategische Buchung
```

Der historische Stage-3-Test bleibt für seine konkreten Honaker-/Wright-/Jalalabad-Fixtures unverändert. Die neue Base darf diese konkrete Testverdrahtung nicht stillschweigend als Produktionsarchitektur übernehmen.

## Base-Vertrag vor DCS-Gate 4

Die generische Base trennt drei unabhängige Lifecycle-Domänen:

1. `StartSite(siteId)` startet die persistente Site-Security und den Guard-Vertrag. Ein Incident-Ende darf diesen Guard nicht abbrechen.
2. `OpenIncident(...)` erzeugt ausschließlich Incident-Kontext. `RequestIncidentSupport(...)` ist auf QRF, externe ARTY und CAS begrenzt.
3. `RequestResupply(...)` ist standort- und ressourcenbezogen, unabhängig von Incidents und erwartet bereits einen fachlich qualifizierten Threshold-/Reorder-Bedarf. Die Base berechnet keine Warehouse-/Store-Schwelle selbst; dafür bleibt die vorhandene `OMW_ResourceDemandPolicy.lua` zuständig.

Wiederholte Incident-Support-Zyklen und Resupply-Zyklen verwenden stabile `requestKey`s. MOOSE bleibt für operative Rekrutierung, Queue, Ausführung und physische Lifecycle-Ereignisse zuständig.

## Gate-4-Build

Der Gate-4-Builder erzeugt weiterhin zuerst den unveränderten historischen Stage-3-Build-1-26 und hängt davor ausschließlich den neuen Base-Vertrags-Preflight. Er mutiert keine `.miz`.

Der Preflight muss vor dem historischen Fixture mindestens nachweisen:

- persistenter Guard wird site-scoped erzeugt;
- `OpenIncident()` erzeugt keinen automatischen Support;
- QRF/ARTY/CAS werden nur explizit incident-scoped angefordert;
- Guard und Resupply werden als Incident-Support abgewiesen;
- Resupply wird site-scoped und ressourcenspezifisch erzeugt;
- Incident-Ende hat keine Autorität über persistenten Guard oder separat gültigen Resupply.

## Späterer DCS-Minimalnachweis

Gate 4 bleibt `PLANNED`, bis eine vom Projektinhaber manuell aktualisierte Kopie der v22-MIZ mindestens erneut belegt:

1. Guard ist als normale Standort-Nahbereichssicherung vorhanden und nicht vom Attack-Incident abhängig.
2. Alarm und fachliche Trigger erzeugen QRF sowie C2-Supportbedarfe zum vorgesehenen Zeitpunkt.
3. lokale Selbstverteidigung und externe ARTY/CAS bleiben getrennte Verantwortungsbereiche.
4. ARTY, CAS und Resupply blockieren sich nur an dokumentierten Deconfliction-Grenzen.
5. CAS verwendet eigene Detektion und dynamische Owner-Routen.
6. Resupply entsteht nur aus dem vorgesehenen Ressourcen-/Threshold-Pfad und nicht aus einem Attack-Incident.
7. Rückgabe und Lieferung werden erst nach bestätigtem MOOSE-Ereignis strategisch gebucht.
8. Keine OMW-Asset-Vorselektion, keine zweite Retry-/Dispatcher-Queue und keine festen CAS-Marker/Battle-Positionen.
