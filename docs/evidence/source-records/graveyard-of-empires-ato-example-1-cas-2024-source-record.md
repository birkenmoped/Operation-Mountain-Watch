# Quellenakte - Graveyard of Empires ATO Example 1: CAS Mission

## Quelle

- Graveyard of Empires, *Air Tasking Order - Example 1 - CAS Mission*, 13. November 2024.
- Original-URL: <https://www.patreon.com/graveyard4DCS/posts/air-tasking-1-115712325>
- Vom Projektinhaber bereitgestellte PDF-Erfassung: `ATO-CAS1.pdf`, 3 Seiten.
- Zugehörige OMW-Fachreferenz: [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](../../54-air-tasking-airspace-control-cas-requests-and-mission-data.md), dort Quelle `T06`.

## Quellenklasse und Verwendungsgrenze

```text
SOURCE_CLASS: SECONDARY_DCS_INTERPRETATION / SYNTHETIC_EXAMPLE
PUBLICATION_DATE: 2024-11-13
OMW_PERIOD_RELATION: POST_PERIOD_REFERENCE
HISTORICAL_STATUS: EXAMPLE_ONLY
HISTORICAL_CLAIM: false
```

Der Beitrag ist ein didaktisches ATO-/CAS-Beispiel. Er zeigt die Struktur und semantische Verknüpfung der dargestellten Missions-, Aircraft-, Location-, Control- und Amplification-Felder, belegt aber **keine reale Afghanistan-Mission des OMW-Zeitraums 2010/2011**.

Die Formulierung des Autors, das Beispiel sei einer in Afghanistan möglichen Mission sehr ähnlich, wird als Kontext erhalten, aber nicht als historische Evidenz für die konkreten Beispielwerte gewertet.

## Im Beitrag dargestellte Nachricht

```text
AMSNDAT/AN0714/-/-/-/CAS/-/-/DEPLOC:AOKN/ARRLOC:OAKN//

MSNACFT/2/ACTYP:A10/HOG07/4A652A2S2/-/101/-/32007//

AMSNLOC/061300ZMAR/061600ZMAR/84CJ/150//

CONTROLA/FAC/WIDOW/PFREQ:AMB10/SFREQ:RED3/NAME:ACP10//

AMPN/CONTROL TASKUNIT: 232 DASC//
```

## Vom Autor angegebene Feldbedeutung

### `AMSNDAT` - Aircraft Mission Data

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Mission Number | `AN0714` | Mission identifier |
| AMC Mission Number | `-` | N/A |
| Package Identification | `-` | N/A |
| Mission Commander | `-` | N/A |
| Primary Mission Type | `CAS` | Close Air Support |
| Secondary Mission Type | `-` | N/A |
| Alert Status | `-` | N/A |
| Departure Location | raw: `AOKN`; interpretation: `OAKN` | Kandahar |
| Recovery Base | `OAKN` | Kandahar |

### `MSNACFT` - Individual Aircraft Mission Data

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Number of Aircraft | `2` | Two aircraft |
| Aircraft Type and Model | `A10` | A-10 Thunderbolt II |
| Aircraft Call Sign | `HOG07` | Hog 07 |
| Primary Configuration Code | `4A652A2S2` | SCL/configuration code |
| Secondary Configuration Code | `-` | N/A |
| IFF/SIF Mode 1 | `01` | Mode 1 code |
| IFF/SIF Mode 2 | `-` | N/A |
| IFF/SIF Mode 3 | `2007` | Mode 3 code |

### `AMSNLOC` - Aircraft Mission Location

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Start | `061300ZMAR` | 6 March, 1300Z |
| Stop | `061600ZMAR` | 6 March, 1600Z |
| Mission Location Name | `84CJ` | CAS working area/location identifier |
| Altitude | `150` | FL150 according to the author's interpretation |

### `CONTROLA` - Control of Air Assets

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Control Agency Type | `FAC` | Forward Air Controller |
| Call Sign | `WIDOW` | Widow |
| Primary Frequency/Net | `AMB10` | Amber 10 |
| Secondary Frequency/Net | `RED3` | Red 3 |
| Report-In Point | `ACP10` | ACP10 |

### `AMPN` - Amplification

Der Beitrag interpretiert:

```text
CONTROL TASKUNIT: 232 DASC
```

als `232 Direct Air Support Center`.

Der Beitrag erwähnt außerdem `NARR` als Narrative Information mit freiem Text, obwohl im dargestellten Raw-Block kein eigener `NARR`-Datensatz enthalten ist.

## Plain-text-Bedeutung des Beispiels

Nach der Erläuterung des Autors beschreibt Mission `AN0714` zwei A-10 in einem Close-Air-Support-Auftrag. Die Formation ist von 1300Z bis 1600Z im Arbeitsgebiet `84CJ` vorgesehen. Der FAC `WIDOW` soll die A-10 über `AMBER 10` oder alternativ `RED 3` kontaktieren und tasken.

## Dokumentierte Quellenanomalie: `AOKN` versus `OAKN`

Die Raw-Nachricht enthält:

```text
DEPLOC:AOKN
ARRLOC:OAKN
```

Die anschließende Erklärung des Autors interpretiert **beide** Felder als `OAKN (Kandahar)`. OMW korrigiert die Raw-Zeile im Quellenrecord nicht stillschweigend. Die Abweichung bleibt als Quellenbefund dokumentiert.

Für produktive OMW-Orts- und ICAO-Daten gilt weiterhin der separat validierte Projektbestand; dieses synthetische Beispiel ist keine Autorität zur Festlegung eines Location Codes.

## Für OMW verwertbare Struktur

Das Beispiel unterstützt insbesondere folgende bereits in Dokument 54 vorgesehene Datenbeziehungen:

```text
CAS MISSION
  -> mission ID
  -> aircraft count and type
  -> aircraft callsign
  -> configuration profile
  -> departure and recovery location
  -> mission area
  -> on-station time window
  -> altitude/block
  -> control agency type and callsign
  -> primary/secondary communication net
  -> report-in point
  -> control task unit / amplification
```

Für OMW ist dabei besonders relevant, dass ein CAS-Missionsdatensatz nicht nur Aircraft und Area beschreibt, sondern auch die taktische Control Agency, Kommunikationsreferenzen und den Report-In Point mitführt. Diese Struktur kann später für Air-Tasking-Plan, Player Mission Cards, Kneeboard und MissionDemand-/Tasking-Verknüpfung genutzt werden.

## Nicht aus dieser Quelle abzuleiten

Nicht belegt werden durch dieses Beispiel:

- reale ISAF-/OEF-Mission `AN0714`;
- reale Verwendung von `HOG07`, `WIDOW`, `84CJ` oder `ACP10` im OMW-Zeitraum;
- reale Frequenzen hinter `AMBER 10` oder `RED 3`;
- reale IFF/SIF-Codes `01` oder `2007`;
- reale Einsatzhöhe FL150 für einen konkreten Afghanistan-CAS-Auftrag;
- reale A-10-Konfiguration `4A652A2S2` für eine OMW-Mission;
- historische Existenz oder Zuständigkeit eines `232 DASC` allein aus diesem Beispiel;
- die für 2010/2011 maßgebliche USMTF-/ADatP-3-Version oder exakte Feldsyntax.

## Verwendungsregel

```text
SOURCE EXAMPLE
-> preserve raw message and author interpretation
-> retain source anomalies explicitly
-> use only for data-model semantics and test-fixture design
-> do not promote example values to historical OMW facts
-> verify production field mappings against the applicable message standard/version
```
