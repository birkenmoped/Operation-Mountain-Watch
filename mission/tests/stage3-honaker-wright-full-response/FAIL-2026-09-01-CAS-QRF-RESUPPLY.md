---
document_id: OMW-STAGE3-HONAKER-WRIGHT-FAIL-2026-09-01-CAS-QRF-RESUPPLY
status: HISTORICAL_TEST_FIXTURE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact Stage 3 build 1-10 DCS failure observations and follow-up analysis scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
test_id: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: 24f9b12f6685257272b15d0acbc96d3ca24b8273
builder_version: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-10
bundle_sha256: C42D5967DB56D2FD5CE2D881395A73BD2ABC61F2320596C24F1C3175E8B6DCD3
jalalabad_air_ops_sha256: 36D841121A176EA48B778EAD0C705724EBB6A29D176CD079F18B6075246928DC
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs_version: 2.9.29.27278
validated_in_dcs: false
result: FAIL
---

# Stage 3 DCS FAIL – CAS flight profile, QRF/Guard composition and RESUPPLY closure

## 1. Provenienz

Dieser Bericht dokumentiert den realen DCS-Lauf mit dem lokal gebauten Stage-3-Stand `1-10`.

```text
Branch: agent/fire-support-strategic-resupply-alarm-evidence
Git commit: 24f9b12f6685257272b15d0acbc96d3ca24b8273
Stage-3 builder: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-10
Stage-3 bundle SHA-256: C42D5967DB56D2FD5CE2D881395A73BD2ABC61F2320596C24F1C3175E8B6DCD3
Jalalabad AirOps SHA-256: 36D841121A176EA48B778EAD0C705724EBB6A29D176CD079F18B6075246928DC
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.29.27278
Mission observed by owner: OMW_Template_v20_GroundWorks.miz
Runtime logs: dcs(20260831-222410).log, debrief(20260831-222410).log
```

Ein reproduzierbarer MIZ-Dateihash ist in diesem Bericht noch nicht eingetragen, weil für die hochgeladene Kopie in dieser Dokumentationsrunde kein belastbarer lokaler Hashzugriff vorlag. Die eingebetteten Stage-3-, Jalalabad-AirOps- und Moose.lua-Stände waren zuvor gegen die lokal gebauten/gepinnten Hashes abgeglichen worden.

## 2. Gesamtergebnis

```text
Alarm / Incident                                      PASS / vorhandene Evidenz
QRF request                                           PASS
QRF ArmyOnMission                                     PASS / Log-Evidenz
QRF gewünschte Zusammensetzung Infantry + vehicle    FAIL / Test enthält nur Infantry
Guard gewünschte owner-authored Patrol Route          FAIL / Test nutzt ONGUARD am FOB-Anker
ARTY live fire / retarget                             PASS
M1083 materialization / local ARTY rearm              PASS
CampaignState Wright 16 -> 15                         PASS
Wright reorder threshold 15 / 30                     PASS
strategischer RESUPPLY                               BLOCKED durch fehlerhaftes Acceptance-Dedupe-Gate
AH-64 CASENHANCED allocation/start                    PASS
AH-64 corridor ingress                                teilweise PASS
AH-64 WEST altitude profile                           FAIL
AH-64 CAS tactical attack profile                     FAIL
AH-64 mission/RTB/return behavior                     FAIL / ungeklärt
AH-64 survivability                                   FAIL; beide Luftfahrzeuge gingen verloren
Gesamt-Acceptance                                     FAIL
```

## 3. CAS – beobachtetes Verhalten

Der Projektinhaber beobachtete:

- realen AH-64D-Start und einen zunächst plausiblen Anflug;
- Höhenaufnahme ab `OMW_FlightPath_WEST`, danach deutlich zu große tatsächliche AGL-Höhe;
- mehrere Kreise im Zielgebiet ohne wirksamen Waffeneinsatz;
- anschließend einen Flug auf direkter Luftlinie weit in Richtung Jalalabad, nicht entlang der vorgesehenen WEST-/Hauptroute;
- danach eine Umkehr zurück Richtung Honaker;
- einen extrem steilen Sink-/Sturzflug des Lead-Hubschraubers aus großer Höhe bis zum CFIT;
- den zweiten AH-64 in zu tiefer und zu naher Bodenbekämpfung, wobei gegnerische Infanterie vor dem Apache das Feuer eröffnete und Anflüge unter Beschuss abgebrochen wurden;
- keinen taktisch sinnvollen Einsatz der überlegenen Waffen-/Sensorreichweite.

Der Lauf belegt damit nicht nur einen kosmetischen Höhenfehler, sondern ein unbrauchbares CAS-Flug- und Angriffsprofil.

## 4. WEST-Höhenprofil – bestätigter Regelabweichung

Stage 3 fordert auf WEST `2500 ft AGL`. Die Telemetrie zeigte jedoch ein anhaltendes Überschießen der Sollhöhe, unter anderem ungefähr:

```text
requested 2500 ft AGL
actual ~2349 ft AGL
actual ~3399 ft AGL
actual ~4524 ft AGL
actual ~4913 ft AGL
actual ~5018 ft AGL
actual >6200 ft AGL
actual >7300 ft AGL
actual >7500 ft AGL
```

Der OMW-Adapter setzt derzeit sowohl AGL/RADIO-Wegpunkthöhen als auch profilgebundene `FLIGHTGROUP:SetAltitude(..., Keep=true, RadarAlt=true)`-Übergänge. Ob das DCS-Verhalten durch die Kombination, durch den MOOSE/DCS-Auftragsübergang oder durch eine weitere Tasking-Wirkung entsteht, ist noch nicht bewiesen.

Aus dem aktuellen Source ist dagegen **nicht** ersichtlich, dass `2500 ft` je Wegpunkt additiv auf die vorherige Höhe aufgeschlagen würden. Diese Hypothese bleibt bis zur MOOSE-/DCS-Quellprüfung verworfen.

## 5. CAS Route/Lifecycle – direkter Heimflug und erneute Umkehr

Der beobachtete Flug auf direkter Luftlinie Richtung Jalalabad passt nicht zur owner-authored `OMW_FlightPath_WEST -> OMW_FlightPath`-Rückroute. Deshalb darf dieses Verhalten nicht einfach dem vorhandenen Corridor-Return-Path zugeschrieben werden.

Zu prüfen ist insbesondere die MOOSE-Befehlskette:

```text
AIRWING allocation
-> FLIGHTGROUP mission route
-> AUFTRAG CASENHANCED mission waypoint / Executing
-> CASENHANCED detection/engagement lifecycle
-> egress / mission done / return-to-base decisions
-> mögliche erneute Mission-/Target-Reaktivierung
```

Die Tatsache, dass der Apache zuerst direkt Richtung Heimat flog und anschließend zum aktiven Zielgebiet zurückkehrte, ist als eigener Lifecycle-/Tasking-Fehler zu behandeln.

## 6. Corridor lateral offset – neue owner-authored Metadatenanforderung

Der aktuelle `OMW_HelicopterFlightPathCorridor` verwendet einen globalen Rechtsversatz von standardmäßig 500 m auch für zusammengesetzte PATHLINE-Sequenzen. Damit wird auch `OMW_FlightPath_WEST` seitlich versetzt.

Der Projektinhaber hat festgestellt, dass WEST durch ein zu enges Tal führt und dort keine getrennten Hin-/Rückspuren zulässig sind.

Als gewünschte projektseitige Metadatenkonvention ist zu untersuchen und anschließend zu dokumentieren:

```text
OMW_FlightPath_R500
  -> 500 m rechts relativ zur jeweiligen Flugrichtung

OMW_FlightPath_WEST
  -> kein Offset / Centerline

OMW_FlightPath_EAST_L250
  -> 250 m links relativ zur jeweiligen Flugrichtung
```

Grundidee:

```text
PATHLINE name
-> optionaler _R<meters> / _L<meters> End-Suffix
-> segmentbezogener Laufzeit-Offset
-> kein Suffix = 0 m Offset
```

Dies ist noch keine implementierte oder DCS-validierte Lösung. Vor Implementierung ist MOOSE-first zu prüfen, ob MOOSE bereits geeignete PATHLINE-/routingbezogene Metadaten oder Offset-Mechanismen bereitstellt. Falls nicht, wäre nur ein kleiner Parser/Geometrie-Adapter zulässig; eine produktive projektspezifische Ergänzung benötigt die dokumentierte Freigabe gemäß `docs/26-moose-first-development-policy.md`.

## 7. CAS Lagebild / Targeting – offene MOOSE-Frage

Der Projektinhaber beobachtete ein Verhalten, das nicht wie ein autonomes Apache-Search-and-Destroy mit vollständigem Lagebild wirkte. Der AH-64 schien vielmehr einzelne Zielanflüge zu erhalten, brach diese unter gegnerischem Feuer ab und nutzte seine Standoff-Fähigkeit nicht sinnvoll.

OMW übergibt an `CASENHANCED` derzeit eine taktische Zone und einen Detected-Target-Bereich, nicht eine fest verdrahtete einzelne RED-Gruppe. Trotzdem ist noch source-genau zu klären:

- wie `AUFTRAG:NewCASENHANCED` Detection aufbaut;
- wie erkannte Ziele in DCS-Tasks umgesetzt werden;
- welche ROE-/ROT-Optionen gesetzt werden;
- ob MOOSE einzelne `EngageTarget`-/Attack-Aufträge erzeugt;
- wann Ziele neu gewählt werden;
- ob die AI ein vollständiges Detected Set erhält oder nur jeweils task-spezifische Ziele;
- ob MOOSE eine dokumentierte Standoff-/weapon-range-/attack-direction-Konfiguration für Rotary CAS bereitstellt.

Keine eigene Search-and-Destroy-, Zielwechsel- oder Waffenreichweitensteuerung wird entwickelt, bevor diese Prüfung abgeschlossen ist.

## 8. QRF – Zusammensetzung weicht vom gewünschten Design ab

Der aktuelle Acceptance-Code erstellt ausschließlich:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

für Guard und QRF. Damit enthält Build `1-10` keine Fahrzeugkomponente der QRF.

Der Projektinhaber erwartet die bereits besprochene QRF-Grundidee `Infantry + vehicle`. Vor der nächsten Implementierung muss die aktuelle verbindliche Guard-/QRF-Fachbaseline auf `main` gegen diesen Testcode abgeglichen werden. Falls `Infantry + vehicle` bindend dokumentiert ist, ist Build `1-10` an dieser Stelle fachlich falsch.

## 9. Guard – kein Patrol-Route-Verhalten im Test

Der aktuelle Test erzeugt für die Guard eine `AUFTRAG:NewONGUARD(state.guardCoord)`-Mission am FOB-/BRIGADE-Anker. Die vorhandene owner-authored Mission-Editor-Route `OMW_RTE_BLUE_GUARD_HONAKER_01` wird in Build `1-10` nicht verwendet.

Der Projektinhaber beobachtete entsprechend keine Guard-Patrouille auf der vorgesehenen Route, sondern eine Infanteriegruppe, die sich im FOB festlief und bis Missionsende nicht befreien konnte.

Der nächste Stand darf deshalb nicht stillschweigend behaupten, Guard-Patrol sei geprüft. Zuerst ist die aktuelle `main`-Baseline zu ermitteln und der passende MOOSE-Patrol-/route-basierte Auftrag gegen Quelle und Beispiele zu prüfen.

## 10. M1083 / Reorder / RESUPPLY – Acceptance-Gate statt Runtime-Fehler

Im Gegensatz zu Build `1-8` funktionierte der lokale M1083-Pfad in diesem Lauf:

```text
ARTY depletion
-> M1083 request
-> M1083 materialization
-> real ARTY rearm
-> CampaignState Wright 16 -> 15
-> M1083 return to Warehouse
-> reorder threshold 15 / 30 reached
```

Danach brach der Test mit `RESUPPLY dedupe failed` ab.

Die Sourceprüfung zeigt einen Acceptance-Fehler: Der erste `EvaluateAndCreate()`-Aufruf erzeugt den Demand. Der zweite Aufruf soll Deduplizierung beweisen. `MissionDemand.Registry:Create()` gibt für `active_duplicate` jedoch eine **Deep Copy** des bestehenden Demands zurück. Der Acceptance-Test vergleicht aktuell Tabellenidentität:

```lua
if duplicate ~= demand or duplicateCreated ~= false or duplicateReason ~= "active_duplicate" then
  fail("RESUPPLY dedupe failed")
end
```

`duplicate ~= demand` ist für zwei getrennte Lua-Tabellen auch dann wahr, wenn beide denselben Demand repräsentieren. Das Gate muss semantische Identität prüfen, mindestens stabile Demand-ID/Dedupe-Key plus `created == false` und `reason == active_duplicate`.

Der strategische Reorder selbst ist damit in diesem Lauf **nicht** als ausgefallen zu bewerten; der CH-47-/Slingload-Pfad wurde durch das fehlerhafte Acceptance-Gate vorzeitig blockiert.

## 11. Vor weiterer Implementierung verpflichtend

Gemäß MOOSE-first wird vor dem nächsten DCS-Lauf geprüft und dokumentiert:

```text
A. CASENHANCED
   - constructor/signature
   - Detection / SetEngageDetected interaction
   - ROE / ROT
   - target tasking
   - success / done / cancel / egress / RTB lifecycle
   - rotary-wing attack/standoff options

B. FLIGHTGROUP / OPSGROUP routing
   - AddWaypoint altitude units and alt type
   - SetAltitude feet/meters, ASL/RADIO, Keep semantics
   - mission waypoint and egress waypoint behavior
   - route mutation timing
   - interaction with AUFTRAG-generated route

C. PATHLINE / corridor
   - existing MOOSE offset or metadata facilities
   - segment-specific routing support
   - owner-authored route handling

D. Guard / QRF
   - binding main baseline
   - patrol-route MOOSE path
   - QRF mixed composition / cohort capabilities
   - ONGUARD + SetEngageDetected semantics

E. RESUPPLY
   - acceptance semantic dedupe check only
   - existing MOOSE CARGOTRANSPORT path remains unchanged until the gate is reached
```

Erst nach dieser Prüfung wird entschieden, welche kleinste Änderung notwendig ist. Keine der in diesem Bericht beschriebenen CAS-/Guard-/QRF-Korrekturen gilt bereits als `VALIDATED`.
