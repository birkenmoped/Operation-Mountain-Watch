# TM01M – Audit und Anpassung der umbenannten MSR-Endpunkte

Datum: 1. August 2026

## Anlass

Die aktuelle Hauptvorlage

```text
OMW_Template_v4_Kandahar(5).miz
```

enthält neue fachliche Namen für die Start- und Zielzonen der fünf TM01M-Konvois. Die im Repository und in der Missionsdatei eingebettete TM01M-Konfiguration verwies noch auf die vorherigen Zonennamen. Dadurch schlug die Mission-Editor-Objektauflösung bereits vor der Routenkompilierung fehl.

## Befund in der Missionsdatei

Die folgenden zehn neuen Triggerzonen sind vorhanden:

```text
MSR_HORSESHOE_START_BAGRAM
MSR_HORSESHOE_E3_TARGET_KABUL
MSR_ILLINOIS_E2_START_KABUL
MSR_ILLINOIS_E2_TARGET_JALALABAD
MSR_ILLINOIS_E1_START_TORKHAM
MSR_ILLINOIS_E1_TARGET_JALALABAD
MSR_CALIFORNIA-C1_START_JALALABAD
MSR_CALIFORNIA-C1_TARGET_ASADABAD
MSR_CALIFORNIA-C2_START_ASADABAD
MSR_CALIFORNIA-C03_TARGET_FOB_BOSTIK
```

Alle zehn Zonen haben in der geprüften Vorlage weiterhin einen Radius von 182,88 m und liegen an den für den bisherigen Fünf-Konvoi-Test verwendeten Übergabepunkten.

## Verbindliche Umbenennungszuordnung

```text
ALT                                      NEU
MSR_EAST_E3_START_BAGRAM                 MSR_HORSESHOE_START_BAGRAM
MSR_EAST_E3_TARGET_KABUL                 MSR_HORSESHOE_E3_TARGET_KABUL
MSR_EAST_E2_START_KABUL                  MSR_ILLINOIS_E2_START_KABUL
MSR_EAST_E2_TARGET_JALALABAD             MSR_ILLINOIS_E2_TARGET_JALALABAD
MSR_EAST_E1_START_TORKHAM                MSR_ILLINOIS_E1_START_TORKHAM
MSR_EAST_E1_TARGET_JALALABAD             MSR_ILLINOIS_E1_TARGET_JALALABAD
MSR_KUNAR K1_START_JALALABAD             MSR_CALIFORNIA-C1_START_JALALABAD
MSR_KUNAR K1_TARGET_ASADABAD             MSR_CALIFORNIA-C1_TARGET_ASADABAD
MSR_CALIFORNIA_START_ASADABAD            MSR_CALIFORNIA-C2_START_ASADABAD
MSR_CALIFORNIA_TARGET_FOB_BOSTIK         MSR_CALIFORNIA-C03_TARGET_FOB_BOSTIK
```

Die Schreibweise ist exakt zu übernehmen. Die Bindestriche in den CALIFORNIA-Namen sind Bestandteil der Mission-Editor-Objektnamen. Der letzte Zielpunkt verwendet in der Vorlage die Schreibweise `BOSTIK`.

## Unveränderte PATHLINE-Objekte

Die fachliche MSR-Neubenennung wurde nicht auf die internen PATHLINE-Objektnamen übertragen. In der geprüften Vorlage existieren weiterhin:

```text
MSR_EAST_E03
MSR_EAST_E02
MSR_EAST_E01
MSR_KUNAR_K01
MSR_CAL_C01
MSR_CAL_C02
```

Daher ist keine Änderung der bewährten Routenkompilierung erforderlich. Die Zuordnung bleibt:

```text
HORSESHOE Bagram → Kabul           MSR_EAST_E03
ILLINOIS-E2 Kabul → Jalalabad      MSR_EAST_E02
ILLINOIS-E1 Torkham → Jalalabad    MSR_EAST_E01
CALIFORNIA-C1 Jbad → Asadabad      MSR_KUNAR_K01
CALIFORNIA-C2/C3 Asad → Bostik     MSR_CAL_C01 + MSR_CAL_C02
```

## Eingebetteter Skriptstand

Die geprüfte `.miz` enthält unter `l10n/DEFAULT/TM01M.lua` noch die ältere Konfiguration

```text
TM01M-moose-native-five-convoys-1
```

mit den alten Zonennamen. Ein Repository-Build ersetzt diesen eingebetteten Stand nicht automatisch. Nach dem Build muss `dist/TM01M.lua` im Mission Editor erneut im vorhandenen `DO SCRIPT FILE`-Eintrag ausgewählt und die Mission gespeichert werden.

## Repository-Anpassung

Neue Konfiguration:

```text
TM01M-moose-native-five-convoys-3
```

Geändert wurden ausschließlich:

- die zehn Start-/Zielzonennamen;
- die sichtbaren Konvoi-Bezeichnungen entsprechend HORSESHOE, ILLINOIS und CALIFORNIA;
- der statische Vertragstest und die DCS-Acceptance-Dokumentation.

Unverändert bleiben:

- fünf stabile Konvoi-IDs;
- fünf Laufzeitaliasse;
- sechs interne PATHLINE-Namen;
- Routengeometrie und automatische PATHLINE-Ausrichtung;
- 50 km/h und `On Road`;
- sechs Fahrzeuge je Konvoi;
- 60 Sekunden Zielbereichsaufenthalt und stiller MOOSE-Despawn.

## Validierungsgrenze

Der statische Test muss beweisen, dass ausschließlich die zehn neuen Endpunktnamen konfiguriert sind und die sechs bisherigen PATHLINE-Bindungen unverändert bleiben.

Ein erneuter DCS-Lauf ist erforderlich, weil nur DCS/MOOSE die tatsächliche Auflösung der umbenannten Mission-Editor-Zonen und die unveränderte Straßenanbindung bestätigen kann.
