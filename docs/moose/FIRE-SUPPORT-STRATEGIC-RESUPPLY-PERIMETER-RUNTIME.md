---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - generic six-site perimeter runtime assembly source contract
  - MOOSE OPSZONE perimeter evidence integration boundary
  - owner-approved current six-site alarm anchor and radius contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
---

# Fire Support / Strategic Resupply – generische Perimeter-Runtime

Status: SOURCE_REVIEWED / NICHT DCS-VALIDIERT

## Zweck

`OMW_FireSupStratResupply_PerimeterRuntime.lua` verdrahtet den MOOSE-`OPSZONE`-Perimeter fuer die registrierten Ground-Installationen. Das Modul fuehrt keine eigene Feinderkennung, Missionsauswahl oder Ressourcenlogik ein.

Wichtig: Der Perimeter ist **nicht** die Incident-Autoritaet. Nach Abgleich mit `docs/ground/ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION.md` wird ein `OPSZONE:Attacked` nur als `PROXIMITY_INTRUSION`-Evidence an den bestehenden Installation-Attack-Incident-Layer uebergeben.

Der Laufzeitpfad lautet:

```text
SiteRegistry
-> site-spezifischer Installationsanker + Alarmradius (injizierte Konfiguration)
-> OMW_FobThreatOpsZoneAdapter
-> MOOSE ZONE_RADIUS / OPSZONE
-> OMW_FireSupStratResupply_PerimeterBridge
-> PROXIMITY_INTRUSION evidence
-> OMW_FireSupStratResupply_InstallationIncidentRuntime
-> OMW_GroundInstallationAttackIncident
-> OMW_FireSupStratResupply_InstallationIncidentBridge
-> OMW_FireSupStratResupply_Base
-> initial nur QRF als INCIDENT_LOCAL_DEFENSE
```

Weitere MOOSE-basierte Evidenzkanaele (`Hit`, `Shot`, `ShootingStart`, gefiltertes `WEAPON`-Impact-Tracking) koennen ueber `OMW_GroundInstallationAlarmEvidenceAdapter` denselben Installation-Incident speisen. Die generische Base stellt dafuer `ReportInstallationEvidence(evidence)` bereit.

## Autoritaetsgrenzen

Die Perimeterbewertung bleibt bei MOOSE `OPSZONE`. `OMW_FireSupStratResupply_PerimeterBridge` erzeugt daraus lediglich eine Evidence-Nachricht. Es existiert dadurch keine zweite Incident- oder Response-Autoritaet.

`OMW_GroundInstallationAttackIncident` bleibt der eine aktive Attack-Incident je Installation. Sein Start wird auf genau einen Base-Incident abgebildet; nur dieser Start erzeugt die initiale lokale QRF-Anforderung. Weitere Evidenz aktualisiert denselben Installation-Incident und erzeugt keine zweite QRF-Anforderung.

ARTY und CAS werden durch Perimeter oder Incident-Start nicht automatisch ausgeloest. Sie bleiben explizite C2-Eskalationsanforderungen.

Ein `OPSZONE:Defeated` bzw. das Verlassen des Alarmperimeters schliesst weder den Installation-Incident noch den Base-Incident. Die Incident-Schliessung muss ueber die autoritative Installation-Incident-Lifecycle-Entscheidung erfolgen; die Base exponiert dafuer `CloseInstallationIncident(installationId, reason)`.

## Konfigurationsgrenze

Das Perimeter-Modul trifft **keine** stillschweigende Projektentscheidung ueber konkrete Alarmradien oder Installationsanker. Diese Werte werden fuer jede Site injiziert:

- `anchorCoordinate`
- `radiusM`
- `priority`
- optional `zoneName`
- optional `updateSeconds`
- optional `captureThreatlevel`
- optional `captureNunits`

Coalition-IDs werden runtimeweit injiziert.

Die fachliche Auswahl von Anchor und Radius liegt damit ausserhalb des Assemblers und ist im aktuellen `OMW_FireSupStratResupply_SiteRegistry.lua`-Vertrag festgelegt.

### Owner-Entscheidung 2026-09-14 – aktuelle Six-Site-Anker und Radien

Der Projektinhaber hat die bereits im aktuellen SiteRegistry eingetragenen Alarmradien ausdruecklich bestaetigt. Sie bleiben unveraendert:

```text
JALALABAD_FENTY   2438.4 m   8000 ft
COP_FORTRESS      1524.0 m   5000 ft
FOB_JOYCE         2743.2 m   9000 ft
FOB_WRIGHT        1219.2 m   4000 ft
COP_HONAKER       2743.2 m   9000 ft
FOB_BOSTICK       1524.0 m   5000 ft
```

Fuer kompakte FOB-/COP-Installationen ist der Warehouse-Anker die regulaere Regel. Fuer grosse Flugplaetze duerfen bewusst abweichende, flugplatzweite Anker verwendet werden.

Jalalabad/Fenty ist eine ausdruecklich bestaetigte Ausnahme von der Warehouse-Anchor-Regel:

```text
JALALABAD_FENTY
-> MOOSE zone anchor: OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT
-> runtime ZONE_RADIUS: 2438.4 m / 8000 ft
```

Diese Ausnahme ist beabsichtigt, weil der Alarmperimeter den Flugplatz als Installation abbilden soll und nicht nur den Punkt des Ground-Warehouse. Sie darf nicht durch eine pauschale Vereinheitlichung auf `WH_BLUE_GND_FENTY` ersetzt werden.

Fuer die anderen aktuell registrierten Sites bleibt der Warehouse-basierte Anchor-Vertrag bestehen:

```text
COP_FORTRESS -> WH_BLUE_GND_FORTRESS
FOB_JOYCE    -> WH_BLUE_GND_JOYCE
FOB_WRIGHT   -> WH_BLUE_GND_WRIGHT
COP_HONAKER  -> WH_BLUE_GND_HONAKER
FOB_BOSTICK  -> WH_BLUE_GND_BOSTICK
```

Damit sind Anchor- und Radiuswerte fuer den aktuellen Gate-5B-Scope fachlich entschieden. Dies ist noch kein DCS-PASS fuer die generische Six-Site-Perimeter-Runtime.

## ACCESS-Zonen

`ZON_BLUE_GND_*_ACCESS` gehoeren ausschliesslich zum Convoy-/Access-Vertrag. Die Perimeter-Runtime benutzt diese Zonen weder als Anchor noch als Radiusquelle noch zur Guard-, Threat- oder Incident-Qualifikation.

## Lebenszyklus

`StartSite(siteId)` startet genau einen Threat-Adapter fuer die Site. Wiederholtes Starten ist idempotent und liefert `ALREADY_STARTED`.

`StartAll()` startet alle Sites deterministisch nach `siteId`. Falls eine Site nicht gestartet werden kann, werden die in diesem Aufruf bereits gestarteten Perimeter in umgekehrter Reihenfolge wieder gestoppt.

`StopSite()` und `StopAll()` stoppen ausschliesslich die Perimeter-Runtime. Sie haben keine semantische Incident-Close-Wirkung.

Der Installation-Incident-Layer wird im generischen `OMW_FireSupStratResupply_Runtime` unabhaengig vom optionalen Perimeter vorbereitet, damit auch andere qualifizierte Evidence-Quellen denselben autoritativen Incident speisen koennen.

## Verifikation

Quellseitig abgedeckt durch:

```text
tests/mission-demand/test_fob_threat_opszone_adapter.lua
tests/mission-demand/test_fob_threat_opszone_raw_incident.lua
tests/mission-demand/test_ground_installation_alarm_evidence_adapter.lua
tests/mission-demand/test_ground_installation_attack_incident.lua
tests/mission-demand/test_fire_support_strategic_resupply_perimeter_bridge.lua
tests/mission-demand/test_fire_support_strategic_resupply_perimeter_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_installation_incident_bridge.lua
tests/mission-demand/test_fire_support_strategic_resupply_installation_incident_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_runtime.lua
```

Die Tests pruefen insbesondere:

- Perimeter-Einbruch wird nur `PROXIMITY_INTRUSION`-Evidence;
- alle weiteren Evidence-Typen koennen denselben Installation-Incident aktualisieren;
- ein Installation-Incident wird genau einmal auf einen Base-Incident abgebildet;
- die initiale QRF-Anforderung wird nicht bei Incident-Refresh dupliziert;
- Evidence-Prioritaet und initialer Positions-/Target-Kontext bleiben erhalten;
- Perimeter-Clear schliesst keinen Incident;
- explizite autoritative Incident-Schliessung wird an `Base:CloseIncident()` weitergereicht;
- kein `accessZoneName` gelangt in diesen Alarm-/Incident-Pfad.

Eine generische Six-Site-DCS-Validierung der Perimeter-Runtime ist damit noch nicht erfolgt. Die fuer Gate 5B erforderlichen konkreten Anchor-/Radiusentscheidungen sind nun vorhanden; offen bleibt der gezielte DCS-Acceptance-Nachweis der sechs runtime-generierten `ZONE_RADIUS`/`OPSZONE`-Perimeter und ihrer Evidence-/Incident-Anbindung.
