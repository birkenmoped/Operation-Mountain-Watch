---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-ME-CONTRACT
status: PLANNED
document_class: MISSION_EDITOR_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5 Mission Editor prerequisites for persistent Guard and installation alarm geometry on the six current Ground Foundation sites
  - exact OMW object names for owner-authored Guard PATHLINEs and installation alarm zones in this branch
  - DCS validation criteria required before generic six-site Guard runtime activation
not_authoritative_for:
  - final Mission Editor coordinates or route geometry
  - DCS runtime acceptance
  - Guard personnel strength or CampaignState quantity decisions
  - QRF composition or local-fire asset selection
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

# Gate 5 – Mission-Editor-Vertrag für sechs Ground-Sites

## 1. Zweck

Gate 4 hat den generischen Base-Vertrag zusammen mit dem historischen Honaker/Wright-Fixture geprüft. Gate 5 bereitet den flächigen Standortvertrag für die sechs aktuell reconciliierten Ground-Domänen vor, ohne eine `.miz` zu verändern und ohne Guard-Routen oder Alarmgeometrie automatisch zu erzeugen.

Aktueller Scope:

```text
Jalalabad / FOB Fenty
COP Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick
```

Die projektweit bindende Guard-Regel bleibt maßgeblich:

```text
site active
-> persistent local Guard
-> active owner-authored patrol

installation attack evidence
-> one installation attack incident
-> local-first response
-> QRF / local capabilities where actually available
-> unmet capability becomes external support demand
```

Die Alarmzone ist nur Threat-Detection-/Response-Trigger und weder taktisches Kampfgebiet noch Fire-Support-/CAS-Endbedingung.

## 2. MOOSE-first Route Contract

Der gepinnte MOOSE-Stand enthält `CONTROLLABLE:PatrolRoute()`. Diese Methode liest die Template-Routenpunkte der Ground Group über `GetTemplateRoutePoints()` und hängt am letzten Wegpunkt einen erneuten `CONTROLLABLE.PatrolRoute`-Aufruf ein.

Der historische Honaker-Stage-3-Pfad hat zusätzlich den bereits praktisch verwendeten owner-authored `PATHLINE`-Ansatz belegt: `PATHLINE:FindByName(...)` -> `GetCoordinates()` -> `COORDINATE:WaypointGround(...)` -> MOOSE `GROUP:Route(...)` mit MOOSE `TaskFunction(...)` für die Wiederholung.

Für Gate 5 wird deshalb keine freie Patrol-Zone, kein A*-Routing und keine automatisch berechnete Route eingeführt. Der Mission Editor liefert pro Site eine explizite, vom Owner gezeichnete Guard-PATHLINE. Die spätere Runtime darf diese Geometrie ausschließlich über öffentliche MOOSE-Wrapper-/Route-Funktionen verwenden.

Wichtig: Der Name der PATHLINE ist der stabile Mission-Editor-Vertrag. Die konkrete Punktgeometrie bleibt Owner-ME-Arbeit und muss in DCS validiert werden.

## 3. Exakter Objektvertrag

| Site | Installation-ID | Warehouse | ACCESS | Guard PATHLINE | Alarmzone |
|---|---|---|---|---|---|
| Fenty | `BLUE_GROUND_HUB_JALALABAD_FENTY` | `WH_BLUE_GND_FENTY` | `ZON_BLUE_GND_FENTY_ACCESS` | `OMW_RTE_BLUE_GUARD_FENTY_01` | `ZON_BLUE_GND_FENTY_ALARM` |
| Fortress | `BLUE_GROUND_COP_FORTRESS` | `WH_BLUE_GND_FORTRESS` | `ZON_BLUE_GND_FORTRESS_ACCESS` | `OMW_RTE_BLUE_GUARD_FORTRESS_01` | `ZON_BLUE_GND_FORTRESS_ALARM` |
| Joyce | `BLUE_GROUND_FOB_JOYCE` | `WH_BLUE_GND_JOYCE` | `ZON_BLUE_GND_JOYCE_ACCESS` | `OMW_RTE_BLUE_GUARD_JOYCE_01` | `ZON_BLUE_GND_JOYCE_ALARM` |
| Wright | `BLUE_GROUND_FOB_WRIGHT` | `WH_BLUE_GND_WRIGHT` | `ZON_BLUE_GND_WRIGHT_ACCESS` | `OMW_RTE_BLUE_GUARD_WRIGHT_01` | `ZON_BLUE_GND_WRIGHT_ALARM` |
| Honaker-Miracle | `BLUE_GROUND_COP_HONAKER_MIRACLE` | `WH_BLUE_GND_HONAKER` | `ZON_BLUE_GND_HONAKER_ACCESS` | `OMW_RTE_BLUE_GUARD_HONAKER_01` | `ZON_BLUE_GND_HONAKER_ALARM` |
| Bostick | `BLUE_GROUND_FOB_BOSTICK` | `WH_BLUE_GND_BOSTICK` | `ZON_BLUE_GND_BOSTICK_ACCESS` | `OMW_RTE_BLUE_GUARD_BOSTICK_01` | `ZON_BLUE_GND_BOSTICK_ALARM` |

`OMW_RTE_BLUE_GUARD_HONAKER_01` ist bereits aus dem historischen Stage-3-Fixture bekannt. Gate 5 übernimmt nur seinen stabilen Namen; die Produktionsgeometrie ist trotzdem gegen den aktuellen Missionsstand zu prüfen.

## 4. Guard-PATHLINE – Owner-ME-Anforderung

Für jede der sechs PATHLINEs gilt:

```text
- vom Projektinhaber im Mission Editor gezeichnet;
- mindestens zwei nutzbare Koordinaten;
- innerhalb beziehungsweise unmittelbar um die reale Installationssicherung geführt;
- keine Route durch Gebäude, HESCOs, Mauern, steile unbefahrbare Hänge oder andere bekannte Ground-AI-Hindernisse;
- erster erreichbarer Patrol-Punkt muss vom vorhandenen ACCESS-/Materialisierungsbereich plausibel erreichbar sein;
- Übergang vom letzten zum ersten Patrol-Punkt muss physisch fahrbar beziehungsweise für Infantry begehbar sein, weil der Rundkurs wiederholt wird;
- keine automatisch erzeugte Geländeabkürzung;
- kein beobachtbarer Teleport/Respawn zur Routenkorrektur.
```

Gate 5 legt bewusst keine universelle Patrol-Geschwindigkeit und keine feste Zahl von Wegpunkten fest. Gelände und Installationsgröße unterscheiden sich; die Geometrie ist je Site in DCS zu prüfen.

## 5. Guard-Template-Grenze

Das bereits vorhandene Mission-Editor-Template

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

ist im aktuellen Ground-Production-Vertrag als physisches Template vorhanden und wurde im Honaker-Stage-3-Fixture als Guard-Template verwendet. Gate 5 erzeugt deshalb kein zweites paralleles Guard-Template-System.

Aus diesem Befund wird jedoch **keine neue strategische Guard-Personalstärke pro Site** abgeleitet. Die spätere MOOSE-PLATOON-/COHORT-Konfiguration darf das vorhandene Template als physische Repräsentation verwenden, aber CampaignState-Ressourcenautorität, Site-Garrison-Entitlements und Settlement bleiben getrennt zu prüfen.

## 6. Materialisierung, Start und Rückkehr

Vorhandene Ground-Foundation-Grenze pro Site:

```text
Warehouse / BRIGADE domain
-> existing ZON_BLUE_GND_<SITE>_ACCESS
-> MOOSE materialization
-> owner-authored Guard PATHLINE
```

Es wird **keine zusätzliche Guard-Spawnzone** eingeführt. `ACCESS` bleibt die etablierte Materialisierungs-/Return-Handoff-Grenze.

Für den persistenten Guard bedeutet das:

```text
site startup
-> MOOSE recruits/materializes Guard through the site Ground domain
-> Guard reaches owner-authored PATHLINE
-> repeated patrol remains active independent of attack incidents
```

Normales Incident-Ende darf den Guard nicht zurückrufen oder löschen. Ein späterer Site-Shutdown-/Reconstitution-Pfad muss den bestehenden MOOSE-/Ground-Return-Vertrag verwenden und darf keine sichtbare Teleport-Rückkehr einführen. Gate 5 validiert zunächst Start und dauerhafte Patrouille; ein neuer Shutdown-Pfad wird hier nicht erfunden.

## 7. Alarmzone – Owner-ME-Anforderung

Pro Site wird genau eine benannte Installations-Alarmzone aus Abschnitt 3 benötigt. Ihre Geometrie wird nicht automatisch aus Warehouse, ACCESS oder Guard-Route abgeleitet.

Verbindliche Semantik:

```text
alarm zone
= installation threat-detection / response-trigger boundary
!= tactical battlespace
!= weapons engagement zone
!= fire-support target area
!= CAS engagement area
!= mission-end condition
```

Die Geometrie darf je Installation unterschiedlich sein. Der Owner setzt sie im Mission Editor so, dass die tatsächliche Installation sinnvoll abgedeckt wird. Der spätere Runtime-Adapter darf zusätzlich die bereits bindend definierten Multi-Evidence-Klassen für Direct Fire, Indirect Fire und bestätigte Hits verwenden; das Verlassen der Zone beendet einen laufenden Response-Auftrag nicht automatisch.

## 8. Lokale Fire-Support-Grenzen

Gate 5 verändert die bestehenden Fachgrenzen nicht:

```text
Fortress -> lokale L118-Fähigkeit in Ground-Baseline konfiguriert
Honaker  -> lokale 2B11-Mörserfähigkeit in Ground-Baseline konfiguriert
Bostick  -> lokale L118-Fähigkeit in Ground-Baseline konfiguriert
Wright   -> aktuelle lokale ARTY-Zuordnung ungeklärt
Fenty    -> lokale Fires durch aktuelle Baseline nicht etabliert
Joyce    -> lokale Fires durch aktuelle Baseline nicht etabliert
```

Das historische Wright-L118-Fixture ist kein Beweis für eine generische lokale Wright-Artilleriefähigkeit.

## 9. OP-Grenze

Die abhängigen OPs

```text
Honaker-Miracle -> OP JoJo
Bostick -> OP Mustang / OP Clydesdale / OP Stallion
```

sind von der projektweiten Guard-Regel erfasst, besitzen aber nicht automatisch eigenen Warehouse-, Personnel-, QRF- oder Patrol-Origin-Bestand. Gate 5 aktiviert deshalb zunächst den sechs-Domain-Vertrag. Separate OP-PATHLINEs und Alarmzonen werden erst nach eigener ME-Reconciliation ergänzt; ihre Ressourcen bleiben an den dokumentierten Parent-Ground-Node gebunden.

## 10. DCS-Acceptance vor Runtime-Aktivierung

Bevor die generische Base alle sechs Guards produktiv startet, muss der Owner für jede Site mindestens bestätigen:

```text
[ ] PATHLINE existiert unter exakt vereinbartem Namen
[ ] Alarmzone existiert unter exakt vereinbartem Namen
[ ] Guard materialisiert ohne sichtbare Dublette/Kollision
[ ] Guard erreicht die PATHLINE ohne unbrauchbares Pathfinding
[ ] komplette Patrol-Runde einschließlich last -> first funktioniert
[ ] Guard bleibt nach mindestens einer vollständigen Runde aktiv
[ ] Guard bleibt unabhängig von einem Attack-Incident bestehen
[ ] kein sichtbarer Teleport/Respawn
[ ] Alarmzone löst nur Alarm/Response aus und begrenzt nicht das taktische Engagement
```

Ein Site-FAIL verhindert den sechs-Site-PASS, darf aber die bereits validierten anderen Ground-/Stage-3-Fixtures nicht als rückwirkend fehlgeschlagen klassifizieren.

## 11. Noch nicht freigegeben

Dieser Vertrag allein autorisiert noch nicht:

```text
- produktive sechs-Site-Guard-Runtime;
- neue Guard-Personalbestände;
- neue QRF-Templates oder QRF-Stärken;
- lokale ARTY für Wright;
- frei berechnete Patrol-/Alarmgeometrie;
- neue Native-DCS-/private-MOOSE-Fallbacks;
- automatische `.miz`-Änderungen.
```

Nächster Schritt nach Owner-ME-Arbeit ist eine read-only Objektvertragsprüfung der aktualisierten Mission. Erst bei vollständigem Objektvertrag folgt die kleinste MOOSE-first Runtime-Erweiterung und ein eigener DCS-Acceptance-Lauf.