---
document_id: OMW-EVIDENCE-RC-EAST-CAS-AAR-SPATIAL-SCHEDULE-20261026
status: SOURCE_REVIEWED
document_class: RESEARCH_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - verified existing AAR geometry comparisons and A5-3 scheduling constraints
not_authoritative_for:
  - release of new CAS standby-track coordinates, ACO clearance, aircraft endurance limits, DCS-validated CAS sortie schedule
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
validated_in_dcs: false
---

# RC East – konkreter AAR-Geometrieabgleich und CAS-Schedule-Gates

## 1. Verbindliche Ist-Geometrie

Geprueft wurden `main:data/air-operations/aar/omw-2011-aar-areas.geojson` (Git Blob `5ab7dca2b7264efa65747a1e8a9ca23471f30c69`), `main:data/air-operations/aar/omw-2011-aar-areas.csv` (`2a00369c6c13af47d3c77b9e22c41a3324c18227`), `main:data/air-operations/aar/omw-2011-aar-operational-core.csv` (`be0924ed997108206b9de62ecb67e55e327cb032`) sowie `docs/29-isaf-2009-2013-air-to-air-refueling.md` und das vorrangige `docs/89-aar-acceptance-7-finalization.md`. Alle 19 Areas bleiben unveraendert; die sechs operativen STANDARD/RESERVE-Rollen werden nicht neu festgelegt.

| Area | Rolle (main) | Orbit-Endpunkt A (lat, lon) | Orbit-Endpunkt B (lat, lon) | Leg |
|---|---|---|---|---|
| PATTY | SLOW / A-10 RC East, STANDARD | 34.971341, 71.477896 | 34.975529, 70.766509 | 35 NM |
| NELSON | FAST / Fast Jets, STANDARD | 36.376667, 71.018333 | 35.803426, 70.887291 | 35 NM |
| KRUSTY | SLOW / A-10 East-Southeast Recovery, STANDARD | 32.651230, 68.159463 | 33.145725, 68.527244 | 35 NM |
| MILHOUSE | SLOW / A-10 Kandahar Return, STANDARD | 33.442196, 65.464664 | 33.184454, 64.838990 | 35 NM |
| LISA | FAST / Reserve, RESERVE | 33.666249, 61.812945 | 33.084901, 61.761270 | 35 NM |
| MOE | FAST / Swing Reserve, RESERVE | 35.076039, 65.326034 | 34.742611, 65.909957 | 35 NM |

**Nur Geometrie-Evidenz:** WGS84-Positionen aus GeoJSON, kein DCS-gepruefter CAS-Steuerpunkt. Ein `geometry_status=OMW_2011_AIP_CORRECTED` und `validated_in_dcs=false` fuer die GeoJSON-AAR-Geometrie ist nicht mit dem **separat** bestandenen Acceptance-7-AAR-Lifecycle gleichzusetzen. Keine stillschweigende Umschreibung von PATTY/NELSON oder den AAR-Acceptance-7-Parametern.

Als Grobordnung der relativen Lage wurden WGS84-Grosskreis-Distanzen zwischen den **jeweils naechsten beiden publizierten Leg-Endpunkten**, nicht zwischen Track-Perimetern und **nicht** als reale AAR-Anflugstrecke, berechnet:

| Paar | Endpunkt-zu-Endpunkt, ca. |
|---|---:|
| PATTY – NELSON | 50.1 NM |
| PATTY – KRUSTY | 156.4 NM |
| NELSON – KRUSTY | 197.7 NM |
| MILHOUSE – KRUSTY | 143.7 NM |
| MILHOUSE – MOE | 81.2 NM |

Die Werte belegen die unterschiedlichen Raeume, nicht eine priorisierte Receiver-Zuweisung. Die produktiven Receiver-Provider-Rollen und das echte MOOSE-Refuel-/Eligibility-Verhalten bleiben bindend.

## 2. Reale OMW-AO aus der vom Owner bereitgestellten Test-MIZ (read-only)

Read-only ZIP-`mission`-Inspektion der Testkopie `OMW_Template_v26_GroundWorks_Ready(3).miz`:

- `ZON_BLUE_GND_HONAKER_ACCESS`: lokales DCS-Koordinatensystem `x=135607.77669508,` `y=439498.60910658`.
- Die A5-Harness-AO wird ueber diese Zone als Zentrum fuer `ZONE_RADIUS` mit `AO_RADIUS_M=9260` (ca. 5 NM) konstruiert. **A5-Test-AO ist kein bereits freigegebener CAS-Standby-Track.**
- GeoJSON der AAR-Tracks ist WGS84 (lon/lat), die Zone in der `.miz` ist DCS-Local-XY. Eine bestaetigte DCS-Coordinate-/Mapdatum-Transformation fuer diese Mission wurde in dieser Dokumentationsreconciliation **nicht** durchgefuehrt. Daher keinerlei erfundene Entfernungen `Honaker -> PATTY/NELSON`, keine behauptete Ueberschneidung und keine willkuerlichen WGS84-CAS-Track-Koordinaten.

Der in A5-3 erzeugte 5NM-Standoff/8NM-Leg-Racetrack bei Bagram/Kandahar ist **Departure Join**, nicht produktives CAS-Standby oder Honaker-AO. Eine Uebernahme als CAS-Standby-Geometrie waere eine Kategorienverwechslung.

## 3. Echte A5-3 Zeit-/FSM-Evidenz

Owner-Test `dcs(6).log` und `debrief(6).log` vom 26.10.2026, Build A5-3 `a407cc3bea9b3734482167fb986c17549df31ce2`, vom Owner gemeldetes Bundle-SHA256 `951BEB67CC41E502FB8359F8692116C10CF2F853689F70ED2BBB4ED2C676A285`. Logbeobachtung:

- A-10 `TWO_SHIP_JOINED`, anschliessend `DEPARTURE_HOLD_CLEARED releaseFlag=1`; erstes `AAR_REFUELED`, danach `TWO_SHIP_IN_AO`.
- F-16 und F-15E: `DEPARTURE_HOLD_CLEARED releaseFlag=1`, aber spaeter `AAR_FALLBACK_MOOSE_RTB` wegen nicht eligiblen Tankers. Ein `TWO_SHIP_IN_AO` der F-15E tritt erst im RTB-Zusammenhang auf und beweist nicht unabhaengig eine erfolgreiche operative CAS-Stationierung.
- A-10: vier `AAR_REFUELED`-Events vor Owner-Testabbruch. Kein abgeschlossener A-10-RTB-/Landing-Nachweis und keine definierte maximale Sortiedauer.
- Mission Clock aus Telemetrie-Events ist von DCS-Wallclock zu unterscheiden. Der A5-Test ist eine **CAS-Auftrags-Harness ohne echte persistente Scheduled-CAS-/Relief-ATO**, deshalb sind 8h+ und vier Betankungen keine direkt gemessene optimale Schichtdauer.
- Jede AAR-Unterbrechung muss CAS-`AVAILABLE` temporär reduzieren; `TWO_SHIP_IN_AO` belegt nur den geometrischen AO-Eintritt, nicht dauerhaftes CAS-`AVAILABLE`.

## 4. Ausdruecklicher Planungsvorschlag, keine genehmigte Runtime-Entscheidung

`CAS_COVERAGE_WINDOW` als ATO-Ziel, `CAS_AVAILABLE` als separat gemessener operativer Zustand und `SORTIE_TIME` als Takeoff-bis-Landung-Hartgrenze. Der Standby-Airspace-Block braucht eigene ID, WGS84- oder authentisch transformierte DCS-Koordinaten, Altitude-Block (MSL/AGL), Aktivierungsfenster, Konfliktpruefung und C2-Eigner. PATTY ist fuer RC-East-A-10 gemaess `main` primärer AAR-Support; NELSON fuer Fast Jets. Beim geplanten Top-off/erneuten AAR *Provider-Availability und Entfernung in der realen Runtime* und die verbleibende CAS-Verfuegbarkeit pruefen; MILHOUSE/KRUSTY gemaess bestehendem Recovery-Vertrag, nicht als automatische prioritaere CAS-Standby-Tanker umwidmen.

**Schedule-Kalkulation pro Two-Ship**:

`requestedCoverageStart - measured(taxi+join+route+plannedAAR) = plannedTakeoff`

`plannedReturn = min(onStationEnd + egress, firstTakeoff + authorizedSortieLimit - predictedRecovery - margin)`

Die gesamte verfuegbare ON_STATION-Zeit muss AAR-Abwesenheit und andere Nichtverfuegbarkeit gesondert ausweisen; Ablosung vor `plannedReturn` disponieren oder eine ausdrueckliche `COVERAGE_GAP` melden. Time-on-station-Zielwerte und maximale Sortiedauer muessen vom Owner separat verbindlich genehmigt werden. Vorschlaege 3h A-10 verfuegbar / 8h regulaer /10h Ausnahme sind noch **keine BINDING-Policy**. Keine pauschale Begrenzung von AAR auf zwei oder drei Events ohne Zeit-/Fuel-Logik.

## 5. Noch erforderliche Nachweise vor Festlegung von CAS-Racetracks

1. DCS-konforme Umrechnung/Validierung von `ZON_BLUE_GND_HONAKER_ACCESS` aus Local XY in WGS84 oder gemeinsame DCS-Local-Geometrie aller Trackpunkte; danach Distanz und Luftraumblock wirklich gegen PATTY/NELSON ausrechnen.
2. Ausweisung eines **separaten** CAS-Bereitschaftsraums neben der taktischen Honaker-AO; Hoehenband, topografische Freigabe, ziviler ATS-/IFR-/VFR-Konflikt und ACO-Zeitfenster.
3. AAR-Interception fuer PATTY/NELSON inkl. Zeitverlust durch Racetrack-Position und Log-Nachweis; kuerzeste Endpunktdistanz ist kein AAR-Zeitwert.
4. Reale A-10-Rueckflug-/Recovery-Zeit und sichere maximale Sortiezeit, Bagram-RTB- und Asset-Return; laufendes A5-Bundle nicht zu einer produktiven Scheduled-ATO umetikettieren.
5. Owner-Freigabe konkreter Standby-Geometrie und Sortie-Policy; dann MOOSE-First-Pruefung von ORBIT/AUFTRAG/FLIGHTGROUP/COMMANDER und ein integrierter statt stueckweiser DCS-Acceptance-Test.

**Keine Runtime-/MIZ-/AAR-Track-Aenderung aus diesem Dokument.** Status `SOURCE_REVIEWED / GEO_ALIGNMENT_INCOMPLETE / OWNER_DECISION_PENDING / DCS_PENDING`.
