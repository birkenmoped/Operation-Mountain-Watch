---
document_id: OMW-DECISION-KANDAHAR-A10C-CAS-LOADOUT-2026-08-01
status: BINDING_PROJECT_DECISION
document_class: PROJECT_DECISION_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar A-10C II CAS Mission Editor payload baseline
  - exact DCS station allocation for TPL_AIR_US_KAF_A10C_CAS_2SHIP
  - evidence boundary between historically documented Kandahar stores and the OMW composite payload
  - historical eligibility boundary for additional A-10C II stores in the OMW period
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - undocumented Kandahar A-10C CAS payload assumptions
superseded_by:
source_branch: agent/kandahar-a10c-cas-loadout-reconciliation
source_commit: 8eeb10b43dcf7f72cc6b77ccdcef52e1ec955873
validated_in_dcs: false
decision_date: 2026-08-01
reconciled_on: 2026-08-14
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

### 4.1 Zeitstandsprüfung zusätzlicher A-10C-II-Stores

Die technische Verfügbarkeit eines Stores am DCS-Objekt `A-10C_2` beweist nicht, dass dieser Store im OMW-Zeitraum auf der realen A-10C bereits einsatzfähig oder in Kandahar tatsächlich verwendet wurde. Für zusätzliche DCS-A-10C-II-Stores gilt deshalb die folgende quellenbezogene Einordnung:

| Store | Historischer Nachweis | OMW-Einstufung | Konsequenz für Template / Warehouse |
|---|---|---|---|
| GBU-54 LJDAM | Die 40th Flight Test Squadron führte am 5. November 2008 den ersten erfolgreichen GBU-54-Abwurf von einer A-10C durch und wies die Integration nach. Die USAF dokumentiert den ersten GBU-54-Kampfeinsatz im afghanischen AOR im Herbst 2010 durch F-16 der 510th FS. | `OMW_PERIOD_ELIGIBLE`, aber direkter Einsatz durch 74th EFS / Kandahar-A-10C 2010/2011 derzeit nicht belegt. | Darf bei einer späteren ausdrücklich genehmigten Warehouse- oder Loadout-Entscheidung berücksichtigt werden. Die aktuelle verbindliche GBU-38-Stationsbelegung wird dadurch nicht geändert. |
| APKWS II / AGR-20 | Die USAF dokumentiert den ersten A-10-Festflügler-Testschuss des APKWS II erst im Februar 2013. | `OUT_OF_PERIOD_FOR_A10` | Für OMW-A-10 nicht bevorraten und nicht in A-10-Loadouts freigeben. |
| AGM-65L | Für den OMW-Zeitraum wurde bislang kein belastbarer A-10-spezifischer Nachweis für diesen Maverick-Untertyp festgestellt. Der Kandahar-Nachweis vom Dezember 2011 belegt nur die Maverick-Familie beziehungsweise den Launcher, nicht den Untertyp. | `NOT_CLEARED` | Bis zu einem periodenspezifischen A-10-Nachweis nicht bevorraten und nicht für OMW-A-10-Loadouts freigeben. |

Zusätzliche Primärquellen für diese Zeitstandsprüfung:

7. Air Force Materiel Command, `A-10 successfully drops laser-guided bomb`, 17 November 2008; Testflug vom 5. November 2008: <https://www.afmc.af.mil/News/Article-Display/Article/154635/a-10-successfully-drops-laser-guided-bomb/>
8. U.S. Air Force, `Airmen make impact with first GBU-54 combat drop in Afghanistan`, 4 October 2010: <https://www.af.mil/News/Article-Display/Article/115416/airmen-make-impact-with-first-gbu-54-combat-drop-in-afghanistan/>
9. U.S. Air Force, `A-10 fires its first laser-guided rocket`, 3 April 2013; Testschüsse im Februar 2013: <https://www.af.mil/News/Article-Display/Article/109423/a-10-fires-its-first-laser-guided-rocket/>

Die GBU-54-Einstufung trennt bewusst drei unterschiedliche Aussagen:

```text
A-10C integration demonstrated in 2008
!= A-10C combat employment in Afghanistan proven
!= 74th EFS / Kandahar employment in 2010-2011 proven
```

Die afghanische GBU-54-Erstverwendung von 2010 belegt die zeitgerechte Theaterverfügbarkeit der Waffe, erfolgte nach der ausgewerteten USAF-Quelle jedoch durch F-16. Sie wird deshalb nicht als direkter Kandahar-A-10C-Einsatznachweis behandelt.

## 5. Nicht durch die historischen Quellen bewiesen

Die ausgewerteten Primärquellen beweisen **nicht** die vollständige OMW-Konfiguration als ein einheitliches historisches Standard-Loadout. Insbesondere sind daraus nicht direkt ableitbar:

```text
exactly four GBU-38 on a standard Kandahar sortie
AGM-65D as the exact historical Maverick subtype
AGM-65L as a Kandahar A-10C Maverick subtype in 2010-2011
GBU-54 employment by 74th EFS / Kandahar A-10C in 2010-2011
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

Die Zeitstandsprüfung aus Abschnitt 4.1 ändert die verbindliche Stationsbelegung aus Abschnitt 2 nicht. Für die historische Store-Zulässigkeit der OMW-A-10 gilt bis zu einer neueren ausdrücklichen Entscheidung:

```text
GBU-54   -> OMW_PERIOD_ELIGIBLE; no automatic template or stock change
APKWS II -> OUT_OF_PERIOD_FOR_A10; do not stock / do not authorize
AGM-65L  -> NOT_CLEARED; do not stock / do not authorize pending evidence
```

Damit wird zwischen **Store-Zulässigkeit** und **Bestandshöhe** unterschieden. Die Nichtbevorratung von `APKWS II` und `AGM-65L` ist für die OMW-A-10 eine historische Freigabegrenze; sie legt keine numerischen Warehouse-Stückzahlen für andere Stores fest.

Dieses Dokument bestimmt weiterhin ausdrücklich **nicht**:

- initiale Warehouse-Stückzahlen für zugelassene Stores;
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

Die Ergänzung der historischen Store-Zulässigkeit ist eine quellenbezogene Dokumentationsänderung und erzeugt keinen neuen DCS-Testnachweis.

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
