---
document_id: OMW-AAR-ISAF-ACO
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW AAR-area and ACO mission-design reference for Afghanistan 2009-2013
  - source-derived tanker-area geometry and planning constraints
  - OMW 2011-compatible corrected AAR production-planning geometry
  - current OMW AAR runtime-scope planning
not_authoritative_for:
  - historical operational ACO authenticity
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - REFERENCE used as governance document status
superseded_by:
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# 29 – ISAF 2009–2013: Air-to-Air Refuelling und ACO-Referenz

## 1. Einordnung

Dieses Dokument ist die verbindliche quellenbasierte Planungsreferenz für AAR Areas, Tanker-Orbits und ACO-bezogene Missionsgestaltung in **Operation Mountain Watch**.

Der vollständige Quellen-, Tabellen-, KMZ- und CombatFlite-Auswertungstext bleibt unverändert erhalten:

- [`Legacy-AAR-/ACO-Quellenfassung`](evidence/source-records/legacy-29-isaf-aar-aco-source-capture.md)

Das allgemeine Datenmodell für ATO-/ACO-/SPINS-Produkte, Tanker-Receiver-Zuordnung, ARCT, Offload, Control Agency und Evidenzstufen steht ergänzend in:

- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md).

Die Graveyard-of-Empires-Daten bleiben die Quellenreferenz für Benennung, Höhenblöcke, Tankerrollen, TACAN, Frequenzreferenzen und das grundsätzliche Lagebild der AAR Areas. Die daraus extrahierte Geometrie ist jedoch **nicht** die produktive OMW-Geometrie, sobald sie mit dem für OMW maßgeblichen 2011er AIP-Luftraum kollidiert.

## 2. Quellenstatus

```yaml
source_author: Graveyard of Empires
patreon_parts_available: 3/3
pdf_table: evaluated
kmz_geometry: extracted
combatflite_cf: technically_evaluated
source_status: SOURCE_CAPTURE_COMPLETE
```

Die Aussagen sind als Wiedergabe und Projektableitung der bereitgestellten Quellen zu behandeln. Eine vollständige unabhängige historische Verifikation jeder AAR Area ist nicht behauptet.

Zusätzliche Quellenklassifizierung aus Dokument 54:

| Quelle | Einstufung | Verwendung |
|---|---|---|
| ATO Example 3 – AAR | `EXAMPLE_ONLY` | Datenmodell für Tanker, Receiver, ARCT und Offload |
| Tankers Callsigns List | `LEAD_ONLY` | Kandidaten, keine automatische historische Zuweisung |
| Tankers Refueling Altitudes | `SOURCE_DERIVED_HYPOTHESIS` | Planungsannahmen, keine bestätigten historischen Höhen |
| Tankers ROZ Locations | `BACKGROUND_ONLY` für 2010/2011 | frühe OEF-2001/2002-Ableitung |
| NATO/Combined-Ops-Verfahrensquellen | `POST_PERIOD_REFERENCE` | moderne Struktur- und Deconfliction-Referenz |

## 3. Verbindliche Missionsdesign-Grundsätze

- AAR Areas werden als klar benannte, räumlich definierte Gebiete mit Racetrack, Kontrollpunkten und Höhenblock geführt.
- Tankertyp, Receiver-Domain, optimale Höhe, Geschwindigkeit, TACAN, Frequenz und Callsign werden getrennt dokumentiert.
- Callsign, Track, Höhe, Tankertyp und Datum erhalten jeweils eine eigene Evidenzbewertung; ein bestätigtes Merkmal bestätigt nicht automatisch die übrigen.
- Mehrere Tanker benötigen definierte vertikale Staffelung und Konfliktfreiheit.
- DCS-Turnradien und Orbitverhalten müssen praktisch gegen die geplante Geometrie geprüft werden.
- AAR-Gebiete sind keine automatisch freigegebenen historischen Originalräume; ihre Nutzung ist eine quellenbasierte OMW-Planungsentscheidung.
- Airways, Terrain/MFE, Threat Envelope, Receiver Performance, CAS-/ISR-Arbeitsräume, Rejoin/Exit, Diverts und CSAR-Abdeckung werden gemeinsam betrachtet.
- pauschale Webannahmen wie FL200–FL290, mindestens 10.000 ft AGL oder 15 Minuten Entfernung zum Arbeitsgebiet werden nicht ohne Primärquelle und Test als Standard festgelegt.
- frühe OEF-Trackvorschläge 2001/2002 werden nicht auf 2010/2011 rückprojiziert.

## 4. Eigentümerentscheidung: 2011-kompatible OMW-Geometrie

Am **14.08.2026** hat der Projektinhaber entschieden, die aus Graveyard of Empires übernommenen AAR-Tracks dort zu korrigieren, wo sie mit den für OMW maßgeblichen Airways oder Class-C-/Class-D-Lufträumen kollidieren. Eine weitere Detailanalyse, welcher einzelne Teil eines fehlerhaften Racetracks den Konflikt verursacht, ist für diese Entscheidung nicht erforderlich.

Damit gilt verbindlich:

1. Graveyard of Empires bleibt Quellenbasis für das ungefähre Lagebild und die AAR-Planungsparameter.
2. Die ursprünglichen `isaf-2009-2013-*`-Dateien bleiben als Source-Derived-Evidence erhalten und werden nicht zur produktiven Track-Geometrie erhoben.
3. Für OMW wird eine **eigene, 2011-AIP-kompatible Geometrie** geführt.
4. AAR-Tracks werden so verschoben, dass die geplante Racetrack-/Refuelling-Linie außerhalb der 2011er Airways sowie außerhalb der relevanten Class-C-/Class-D-Lufträume liegt.
5. Die Lage wird nur so weit verändert, wie zur Konfliktfreiheit erforderlich; die bekannte ungefähre Area-Lage, 35-NM-Leg-Grundform und die übrigen AAR-Parameter bleiben soweit möglich erhalten.
6. Die korrigierte Geometrie ist eine **OMW-Designentscheidung**, kein Anspruch auf einen historisch originalen ACO-Track.

Produktive Planungsdaten:

- `data/air-operations/aar/omw-2011-aar-areas.csv`
- `data/air-operations/aar/omw-2011-aar-areas.geojson`

Die CSV bewahrt die ursprünglichen Graveyard-Control-Points und `Route(T)`-Werte in eigenen `source_*`-Feldern und stellt die korrigierten OMW-Werte daneben. Dadurch bleibt die Quellenabweichung vollständig nachvollziehbar.

### 4.1 Korrekturregeln

Für die aktuelle Foundation-Geometrie wurden die 2011er AIP-Airways als 20-NM-Korridore mit 10 NM seitlichem Schutzraum je Seite behandelt. Die OMW-Geometrie erhält zusätzlich einen kleinen Designabstand außerhalb dieser Airway-Grenze. Class-C-/Class-D-Lufträume werden lateral gemieden. Die Prüfung erfolgt bewusst konservativ horizontal; eine lediglich vertikale Trennung wird nicht genutzt, um einen Track weiterhin direkt in einer Airway-Achse zu belassen.

Die drei HAAR-Areas werden als geradlinige Refuelling-Segmente behandelt. Sie werden ebenfalls außerhalb der genannten Airways und Class-C-/Class-D-Lufträume geführt.

### 4.2 Ergebnisstatus

Alle 19 Areas besitzen jetzt einen OMW-korrigierten WGS84-Control-Point und eine korrigierte Route/Refuelling-Linie. Bereiche ohne notwendigen Konflikt behalten ihre Position; konfliktbehaftete Bereiche wurden verlagert. Die größten Verlagerungen betreffen insbesondere Barney, Krusty und Patty, weil die Source-Geometrie in stark belegte Airway-Strukturen fiel.

Status der neuen Daten:

```yaml
geometry_status: OMW_2011_AIP_CORRECTED
validated_in_dcs: false
historical_claim: false
```

Die Geometrie ist damit für die weitere OMW-Missionsplanung verbindlich, aber noch **nicht** als DCS-Runtime-Verhalten validiert.

### 4.3 Eigentümerentscheidung: aktueller Runtime-Scope RC-East

Die 19 AAR-Areas bilden die verfügbare AAR-Infrastruktur. Sie bedeuten ausdrücklich **nicht**, dass 19 Tanker gleichzeitig aktiv sind. Die Geometrien bleiben vollständig verfügbar; die Belegung mit Tankern ist ein davon getrennter Runtime-Zustand.

Für den aktuellen OMW-Kampagnenschwerpunkt gilt:

1. Das eigentliche Einsatzgebiet ist RC-East mit dem in Dokument 10 beschriebenen Schwerpunkt Jalalabad/Fenty, Laghman, Kabul River Valley, Kunar River Valley, Pech Valley und Nuristan-Zugänge.
2. Zusätzlich werden AAR-Möglichkeiten auf der relevanten Kandahar-zu-RC-East-Zuführung berücksichtigt, weil aktive Jets teilweise aus Kandahar kommen und vor beziehungsweise während längerer On-Station-Zeiten Treibstoffunterstützung benötigen können.
3. Der aktuelle Fixed-Wing-Receiverbestand benötigt Boom-AAR. MPRS-/Drogue-Tanker werden deshalb im derzeitigen Runtime-Scope nicht aktiviert.
4. Die drei HAAR-Geometrien bleiben erhalten, werden aber erst aktiviert, wenn der dafür vorgesehene Helicopter-/Tanker-Mod tatsächlich Bestandteil der OMW-Mission ist.
5. Ein Runtime-Tanker wird nur bei tatsächlichem operativem Bedarf einem geeigneten Track zugeordnet. Mehrere nahe oder funktional gleichartige Tracks sind Alternativen und nicht automatisch gleichzeitig zu belegen.

Maschinenlesbare Runtime-Scope-Planung:

- `data/air-operations/aar/omw-2011-aar-runtime-scope.csv`

Aktueller erster Boom-Scope:

| Area | Runtime-Klasse | Rolle |
|---|---|---|
| Clancy | `KANDAHAR_RC_EAST_ACCESS` | Kandahar-seitiger Access-/Top-off-Kandidat Richtung RC-East |
| Homer | `RC_EAST_SOUTH` | südlicher RC-East-/Paktika-Ghazni-seitiger Kandidat; Alternative zu Krusty |
| Krusty | `RC_EAST_SOUTH` | südlicher RC-East-/Paktika-Ghazni-seitiger Kandidat; Alternative zu Homer |
| Nelson | `RC_EAST_NORTH_ADJACENT` | nördlicher RC-East-/Nuristan-angrenzender Kandidat |
| Patty | `RC_EAST_EASTERN_PRIMARY` | primärer östlicher RC-East-/Kunar-Nangarhar-seitiger Kandidat |

Alle übrigen Fixed-Wing-Areas bleiben `STRATEGIC_RESERVE`. Insbesondere Lenny und Milhouse werden trotz relativer Nähe zu Kandahar beziehungsweise Zentralafghanistan zunächst nicht in den bevorzugten Kandahar-RC-East-Korridor aufgenommen, weil Clancy sowie Homer/Krusty die direktere östliche Zuführung abdecken.

Homer und Krusty liegen räumlich eng beieinander und werden deshalb in der Runtime-Planung als Alternativen derselben südlichen Funktionsgruppe behandelt. Ob beide gleichzeitig sicher nutzbar wären, ist **nicht** validiert und muss vor einer parallelen Aktivierung in DCS geprüft werden.

## 5. Datenfelder

Jede AAR-Zuordnung führt mindestens:

```yaml
aarAssignment:
  tanker_mission_id: string
  area_or_track_id: string
  tanker_type_id: string
  callsign: string
  callsign_confidence: VERIFIED_HISTORICAL | CORROBORATED | LEAD_ONLY | PROJECT_ASSIGNED
  altitude_block: string
  altitude_confidence: VERIFIED_HISTORICAL | SOURCE_DERIVED | PROJECT_ASSIGNED
  refueling_system: BOOM | DROGUE | BDA | OTHER
  fuel_type: string
  planned_total_offload_lb: number | null
  receiver_mission_ids: [string]
  arct_slots: [object]
  control_agency_id: string | null
  effective_from: datetime
  effective_to: datetime
  source_ids: [string]
```

Synthetische Beispiele tragen:

```yaml
example_only: true
historical_claim: false
```

## 6. Technische Zielartefakte

- maschinenlesbares AAR-Area-Register;
- Mission-Editor-Zonen und Orbitpunkte;
- Tanker-Templates und `AUFTRAG`-Konfiguration;
- Kneeboard- und Briefingtabellen;
- Request-/Mission-/Receiver-Verknüpfung;
- ARCT- und Offload-Planung;
- Konfliktprüfung gegen Flugplätze, zivile Routen, Trainingsräume, ROZ und Missionsziele;
- separate Divert- und Personnel-Recovery-Angaben.

`RAT` ist kein Bestandteil des operativen Tanker-Lifecycles. Externe Tanker werden als missionsgebundene Support-Assets geplant; der MOOSE-Lifecycle wird gesondert über `SPAWN`/`FLIGHTGROUP`/`AUFTRAG:TANKER` weitergeführt.

## 7. Noch erforderliche Validierung

- Übertragung der korrigierten WGS84-Geometrie in Mission Editor / DCS und visueller Abgleich;
- Tankerturns und Trackhaltung im verwendeten DCS-/MOOSE-Stand;
- Boom-/Drogue-/BDA-Eignung je Receiver;
- geplante Offload- und ARCT-Logik;
- Multiplayer-, TACAN- und Funkverhalten;
- Performance bei mehreren gleichzeitig aktiven Tankern;
- parallele Nutzung nahe beieinander liegender Tracks, insbesondere Homer/Krusty;
- dokumentierte DCS-, MOOSE-, Mission- und Bundle-Version.

Nicht mehr offen ist die Entscheidung, die konfliktbehaftete Graveyard-Geometrie unverändert zu übernehmen: **sie wird für OMW nicht verwendet.**
