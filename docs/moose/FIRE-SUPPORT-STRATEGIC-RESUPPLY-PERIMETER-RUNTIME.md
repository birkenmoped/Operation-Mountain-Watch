# Fire Support / Strategic Resupply – generische Perimeter-Runtime

Status: SOURCE_REVIEWED / NICHT DCS-VALIDIERT

## Zweck

`OMW_FireSupStratResupply_PerimeterRuntime.lua` verdrahtet die bereits festgelegten Bausteine fuer die sechs Ground-Installationen zu einer site-unabhaengigen Runtime. Das Modul fuehrt keine eigene Feinderkennung, Missionsauswahl oder Ressourcenlogik ein.

Der Laufzeitpfad lautet:

```text
SiteRegistry
-> site-spezifischer Installationsanker + Alarmradius (injizierte Konfiguration)
-> OMW_FobThreatOpsZoneAdapter
-> MOOSE ZONE_RADIUS / OPSZONE
-> OMW_FireSupStratResupply_PerimeterBridge
-> OMW_FireSupStratResupply_Base
-> initial nur QRF als INCIDENT_LOCAL_DEFENSE
```

## MOOSE-first-Grenze

Die eigentliche Perimeterbewertung bleibt bei MOOSE `OPSZONE`. Der neue Runtime-Baustein erstellt keine parallele Scan-, Scheduler- oder Threat-Logik. Er instanziiert lediglich den vorhandenen Threat-Adapter fuer jede registrierte Site und verbindet dessen Raw-Incident-Callback mit dem bestehenden Perimeter-Bridge.

ARTY und CAS werden durch diese Runtime nicht automatisch ausgeloest. Sie bleiben gemaess SupportProfile explizite C2-Eskalationsanforderungen.

## Konfigurationsgrenze

Das Modul trifft **keine** stillschweigende Projektentscheidung ueber konkrete Alarmradien oder Installationsanker. Diese Werte muessen fuer jede Site injiziert werden:

- `anchorCoordinate`
- `radiusM`
- `priority`
- optional `zoneName`
- optional `updateSeconds`
- optional `captureThreatlevel`
- optional `captureNunits`

Coalition-IDs werden runtimeweit injiziert.

Damit bleibt die fachliche Entscheidung ueber den konkreten Alarmperimeter ausserhalb des Assemblers.

## ACCESS-Zonen

`ZON_BLUE_GND_*_ACCESS` gehoeren ausschliesslich zum Convoy-/Access-Vertrag. Die Perimeter-Runtime benutzt diese Zonen weder als Anchor noch als Radiusquelle noch zur Guard-, Threat- oder Incident-Qualifikation.

## Lebenszyklus

`StartSite(siteId)` startet genau einen Threat-Adapter fuer die Site. Wiederholtes Starten ist idempotent und liefert `ALREADY_STARTED`.

`StartAll()` startet alle Sites deterministisch nach `siteId`. Falls eine Site nicht gestartet werden kann, werden die in diesem Aufruf bereits gestarteten Perimeter in umgekehrter Reihenfolge wieder gestoppt.

`StopSite()` und `StopAll()` stoppen ausschliesslich die Perimeter-Runtime. Ein `OPSZONE:Defeated` bzw. das Verlassen des Alarmperimeters schliesst den Base-Incident **nicht** automatisch.

## Verifikation

Quellseitig abgedeckt durch:

```text
tests/mission-demand/test_fob_threat_opszone_adapter.lua
tests/mission-demand/test_fob_threat_opszone_raw_incident.lua
tests/mission-demand/test_fire_support_strategic_resupply_perimeter_bridge.lua
tests/mission-demand/test_fire_support_strategic_resupply_perimeter_runtime.lua
```

Der neue Six-Site-Runtime-Test prueft insbesondere:

- alle sechs Registry-Sites werden assembliert;
- Installation-ID, Zone-Name, Radius, Prioritaet und Coalitions werden korrekt an den Threat-Adapter uebergeben;
- kein `accessZoneName` wird an den Perimeterpfad uebergeben;
- Threat- und Clear-Callbacks gehen an den PerimeterBridge;
- Clear schliesst den Incident nicht;
- Start/Stop sind idempotent bzw. sauber rueckbaubar.

Eine DCS-Validierung ist damit noch nicht erfolgt. Fuer einen DCS-Acceptance-Lauf fehlen weiterhin die verbindlichen konkreten Installationsanker-/Alarmradiuswerte fuer die sechs Sites sowie ein entsprechendes Bundle/Acceptance-Artefakt.
