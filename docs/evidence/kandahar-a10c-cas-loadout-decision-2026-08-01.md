---
document_id: OMW-DECISION-KANDAHAR-A10C-CAS-LOADOUT-2026-08-01
status: BINDING_PROJECT_DECISION
document_class: PROJECT_DECISION_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar A-10C II CAS Mission Editor payload baseline
  - exact DCS station allocation for TPL_AIR_US_KAF_A10C_CAS_2SHIP
  - evidence boundary between historically documented Kandahar stores and the OMW composite payload
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - undocumented Kandahar A-10C CAS payload assumptions
superseded_by:
source_branch: agent/kandahar-a10c-cas-loadout-reconciliation
source_commit: 8eeb10b43dcf7f72cc6b77ccdcef52e1ec955873
validated_in_dcs: false
decision_date: 2026-08-01
reconciled_on: 2026-08-13
---

# Kandahar A-10C II CAS-Payload-Baseline

## 1. Zweck und Entscheidungsgrenze

Dieses Dokument übernimmt die bereits am 1. August 2026 im DCS Mission Editor festgelegte Kandahar-A-10C-II-CAS-Beladung in die aktuelle, von `main` abgeleitete Dokumentationslinie.

Die Entscheidung gilt für:

```text
SQ_US_KAF_A10C_74_EFS
TPL_AIR_US_KAF_A10C_CAS_2SHIP
2 x A-10C_2
Role: CAS
```

Sie legt die verbindliche OMW-Authoring-Beladung fest. Sie behauptet ausdrücklich **nicht**, dass jede reale A-10C-Sortie von Kandahar diese vollständige Kombination oder exakt diese Stationsverteilung führte.

Die aktuelle Juli-2011-ORBAT-Referenz führt die `74th Expeditionary Fighter Squadron` mit A-10C am Kandahar Airfield und Close Air Support als Auftrag. Sie dokumentiert außerdem, dass die 74th EFS die 75th EFS im April 2011 ablöste. Maßgebliche interne Referenz ist [`OMW-HIST-AFGHANISTAN-ORBAT-2011-07`](../64-afghanistan-order-of-battle-july-2011.md).

## 2. Verbindliche DCS-Stationsbelegung

Die Stationsnummerierung folgt der A-10C-II-Anzeige im DCS Mission Editor.

| Station | Verbindliche Beladung |
|---:|---|
| 11 | leer |
| 10 | AN/AAQ-28 LITENING AT Targeting Pod |
| 9 | SUU-25; DCS-Payloadanzeige zeigt acht Leuchtfackeln; exakter LUU-Untertyp im Arbeitsnachweis nicht erfasst |
| 8 | 1 x GBU-38 JDAM |
| 7 | 1 x GBU-38 JDAM |
| 6 | leer |
| 5 | 1 x GBU-38 JDAM |
| 4 | 1 x GBU-38 JDAM |
| 3 | LAU-117 mit 1 x AGM-65D Maverick |
| 2 | LAU-131 mit 7 x Hydra 70 M156 SM |
| 1 | leer |

Interne Waffe und Mission-Editor-Arbeitswerte:

```text
GAU-8/A gun load: 100 percent
DCS ammunition selection: CM mixed
Internal fuel: 100 percent / 11,087 lb
Chaff: 240
Flares: 240
Displayed weapon mass: 5,697 lb
Displayed total mass: 42,413 lb
Displayed maximum mass: 46,476 lb
Displayed load ratio: 91 percent
```

Die Massenwerte sind ausschließlich beobachtete DCS-Mission-Editor-Werte dieses Authoring-Stands. Sie sind keine unabhängig verifizierten Realflugzeug-Leistungsdaten.

## 3. Laterale Verteilung

Die vier GBU-38 werden symmetrisch verteilt:

```text
Station 8 <-> Station 4
Station 7 <-> Station 5
```

Die verbleibenden unterschiedlichen Außenlasten werden bewusst auf beide Flugzeugseiten verteilt:

```text
Stations 10 + 9: LITENING AT + SUU-25
Stations 3 + 2: AGM-65D/LAU-117 + LAU-131/M156 SM
```

Diese Verteilung ersetzt den verworfenen Arbeitsstand, bei dem Targeting Pod und Maverick auf derselben Seite lagen. Sie ist eine OMW-Mission-Editor-Entscheidung und kein behauptetes USAF-Standard-Loadsheet.

## 4. Historische Evidenz

Für den OMW-Zeitraum sind folgende Einzelpunkte für Kandahar belastbar dokumentiert:

- U.S. Air Forces Central dokumentiert A-10C der 74th EFS am Kandahar Airfield am 24./25. März 2011.
- DVIDS dokumentiert das Beladen einer GBU-38 auf eine A-10C am Kandahar Airfield am 8. August 2011; die Weapons Crew war von der 74th Aircraft Maintenance Unit eingesetzt.
- DVIDS dokumentiert am selben Tag die Arbeit an Raketen in einem an einer A-10C montierten Rocket Pod.
- DVIDS dokumentiert das Beladen von 1.150 Schuss 30-mm-Munition in eine A-10C am Kandahar Airfield.
- DVIDS dokumentiert im Dezember 2011 eine AGM-65 Maverick beziehungsweise deren Launcher-Mechanismus an einer Kandahar-A-10.

Primärquellen:

1. U.S. Air Forces Central, `74th EFS, Thunder!`, 25 March 2011: <https://www.afcent.af.mil/News/Article/219569/74th-efs-thunder/>
2. DVIDS image 441976, GBU-38 loading, Kandahar, 8 August 2011: <https://www.dvidshub.net/image/441976/airmen-deployed-afghanistan-load-ammo-onto-10s-missions>
3. DVIDS image 441975, rocket-pod servicing, Kandahar, 8 August 2011: <https://www.dvidshub.net/image/441975/airmen-deployed-afghanistan-load-ammo-onto-10s-missions>
4. DVIDS image 441962, 1,150 rounds of 30 mm ammunition, Kandahar, 8 August 2011: <https://www.dvidshub.net/image/441962/airmen-deployed-afghanistan-load-ammo-onto-10s-missions>
5. DVIDS image 494073, AGM-65 Maverick launcher installation, Kandahar, December 2011: <https://www.dvidshub.net/image/494073/10-inspection>
6. Eagle Dynamics, `DCS: A-10C II Tank Killer Flight Manual`, AN/AAQ-28 LITENING AT and station 2/10 carriage: <https://www.digitalcombatsimulator.com/en/downloads/documentation/dcs-warthog_2_flight_manual_en/>

## 5. Nicht durch die historischen Quellen bewiesen

Die ausgewerteten Primärquellen beweisen **nicht** die vollständige OMW-Konfiguration als ein einheitliches historisches Standard-Loadout. Insbesondere sind daraus nicht direkt ableitbar:

```text
exactly four GBU-38 on a standard Kandahar sortie
AGM-65D as the exact historical Maverick subtype
Hydra 70 M156 SM as the exact historical rocket warhead
SUU-25 on the same sortie as the other listed stores
this exact station-by-station arrangement
42,413 lb as a historical launch mass
```

Der DVIDS-Rocket-Pod-Nachweis benennt keinen Warhead-Untertyp. Der DVIDS-Maverick-Nachweis benennt keinen Maverick-Untertyp. `M156 SM` und `AGM-65D` sind deshalb bewusste OMW-Auswahlen innerhalb der in DCS verfügbaren A-10C-II-Bewaffnung.

Die vollständige Beladung ist damit ein **quelleninformiertes OMW-Komposit-CAS-Loadout**, keine Rekonstruktion eines einzelnen veröffentlichten USAF-Loadsheets.

## 6. Template- und Warehouse-Grenze

Beide Flugzeuge des Two-Ship-Seeds verwenden diese Beladung identisch, solange keine spätere ausdrücklich dokumentierte Mixed-Load-Entscheidung sie ersetzt.

Die aktuelle Kandahar-Foundation verwendet `TPL_AIR_US_KAF_A10C_CAS_2SHIP` bereits als SQUADRON-Seed und als MOOSE-Role-Payload für CAS/CASENHANCED. Diese Entscheidung bestimmt daher, **welche Store-Typen** für das Kandahar-A-10C-CAS-Template relevant sind.

Sie bestimmt ausdrücklich **nicht**:

- initiale Warehouse-Stückzahlen;
- Nachschubmengen oder Verbrauchsraten;
- Rückgabe-/Reconciliation-Verhalten nach Landung;
- Wiederbeschaffung;
- CampaignState-Ressourcenhoheit.

Diese Ressourcenfragen bleiben im Warehouse-/CampaignState-Vertrag separat autoritativ.

## 7. Verifikationsstatus

Der am 1. August 2026 vorgelegte Mission-Editor-Arbeitsstand dokumentierte die oben beschriebene Konfiguration visuell. Für diese Reconciliation wurde jedoch kein exakt dazugehöriges gespeichertes `.miz`-Artefakt mit SHA-256 erneut bereitgestellt.

Deshalb gilt:

```yaml
payload_authoring_decision: BINDING
saved_mission_payload_audit: PENDING
dcs_spawn_taxi_takeoff_recovery_acceptance: NOT_RUN
validated_in_dcs: false
```

Der bereits akzeptierte Kandahar-Foundation-Test beweist AIRWING-/SQUADRON-Registrierung und Role-Payload-Registrierung für seinen exakt dokumentierten Missions- und Bundle-Stand. Er beweist nicht automatisch, dass die hier festgelegte Stationsbelegung in einer aktuellen produktiven `.miz` gespeichert ist oder unter Last vollständig abgeflogen wurde.

## 8. Erforderlicher nächster Nachweis

Die nächste aktuelle Missionsdatei muss semantisch bestätigen:

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP = 2 x A-10C_2
both units use the exact station allocation from section 2
Late Activation remains enabled
CAS role remains assigned
fuel, gun and countermeasure settings match the approved authoring state
```

Ein späterer DCS-Acceptance-Lauf muss Spawn, Taxi, Takeoff, Waffenverfügbarkeit und Recovery auf einem vollständig dokumentierten Missions-, DCS-, Bundle- und MOOSE-Stand prüfen, bevor `validated_in_dcs: true` zulässig ist.
