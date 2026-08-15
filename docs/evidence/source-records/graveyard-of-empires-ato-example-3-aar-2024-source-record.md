# Quellenakte - Graveyard of Empires ATO Example 3: Air-to-Air Refueling

## Quelle

- Graveyard of Empires, *Air Tasking Order - Example 3 - Air to Air Refueling*, 15. November 2024.
- Original-URL: <https://www.patreon.com/graveyard4DCS/posts/air-tasking-3-to-115746467>
- Vom Projektinhaber bereitgestellte PDF-Erfassung: `ATO-AAR.pdf`, 4 Seiten.
- Zugehörige OMW-Fachreferenz: [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](../../54-air-tasking-airspace-control-cas-requests-and-mission-data.md), dort Quelle `T08`.

## Quellenklasse und Verwendungsgrenze

```text
SOURCE_CLASS: SECONDARY_DCS_INTERPRETATION / SYNTHETIC_EXAMPLE
PUBLICATION_DATE: 2024-11-15
OMW_PERIOD_RELATION: POST_PERIOD_REFERENCE
HISTORICAL_STATUS: EXAMPLE_ONLY
HISTORICAL_CLAIM: false
```

Der Beitrag ist ein didaktisches ATO-/AAR-Beispiel. Er belegt die Struktur und semantische Verknüpfung der dargestellten Felder, aber **keine reale 2010/2011-Afghanistan-Mission**. Callsigns, Missionsnummern, Orbitname, Zeiten, Höhen, IFF-Codes, Frequenzbezeichner und Offload-Mengen des Beispiels dürfen deshalb nicht als historische OMW-Daten übernommen werden.

## Im Beitrag dargestellte Nachricht

```text
AMSNDAT/1AT101/-/-/-/AR/-/-/DEPLOC:UCFM/ARRLOC:UCFM//

MSNACFT/1/ACTYP:C135FR/TOTAL31/BEST/-/101/-/32005//

AMSNLOC/161330ZAPR/161900ZAPR/RUSH/260//

REFTSK/BDA/KLBS:005/-/-//

5REFUEL

/MSNNO /RECCS /NO/ACTYPE /OFLD /ARCT /SEQ /TYP /ARS

/1AT204 /RAGE51/ 2/AC:M2KD /KLB:004.8/161415Z/ -/A:JP8/BDA//

CONTROLA/CRC/SLAPSTICK/PFREQ:BLU10/SFREQ:WHT06/NAME:REGINA//
```

## Vom Autor angegebene Feldbedeutung

### `AMSNDAT` - Aircraft Mission Data

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Mission Number | `1AT101` | Mission identifier |
| AMC Mission Number | `-` | N/A |
| Package Identification | `-` | N/A |
| Mission Commander | `-` | N/A |
| Primary Mission Type | `AR` | Aerial Refueling |
| Secondary Mission Type | `-` | N/A |
| Alert Status | `-` | N/A |
| Departure Location | `UCFM` | Manas |
| Recovery Base | `UCFM` | Manas |

### `MSNACFT` - Individual Aircraft Mission Data

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Number of Aircraft | `1` | One aircraft |
| Aircraft Type and Model | `C135FR` | C-135FR Stratotanker |
| Aircraft Call Sign | `TOTAL31` | Total 31 |
| Primary Configuration Code | `BEST` | Best available |
| Secondary Configuration Code | `-` | N/A |
| IFF/SIF Mode 1 | `01` | Mode 1 code |
| IFF/SIF Mode 2 | `-` | N/A |
| IFF/SIF Mode 3 | `2005` | Mode 3 code |

### `AMSNLOC` - Aircraft Mission Location

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Start | `161330ZAPR` | 16 April, 1330Z |
| Stop | `161900ZAPR` | 16 April, 1900Z |
| Mission Location Name | `RUSH` | Refueling orbit/location |
| Altitude | `260` | FL260 |

### `REFTSK` - Refueling Tasking

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Aerial Refueling System | `BDA` | Boom Drogue Adapter |
| Total Offload Fuel | `KLBS:005` | 5,000 lb planned offload |
| Alert/Contingency Offload | `-` | N/A |
| Primary Frequency | `-` | N/A |

### `5REFUEL` - Aerial Refueling / Receiver Allocation

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Mission Number | `1AT204` | Receiver mission identifier |
| Receiver Call Sign | `RAGE51` | Rage 51 |
| Aircraft Allocated | `2` | Two receiver aircraft |
| Aircraft Type and Model | `M2KD` | Dassault Mirage 2000D |
| Offload Fuel | `KLB:004.8` | 4,800 lb |
| Air Refueling Control Time | `161415Z` | 16 April, 1415Z |
| Cell Sequence Number | `-` | N/A |
| Fuel Type | `A:JP8` | JP-8 |
| Aerial Refueling System | `BDA` | BDA |

### `CONTROLA` - Control of Air Assets

Der Beitrag interpretiert den Block als:

- aircraft control agency type: Control Reporting Center (`CRC`);
- primary frequency/net designator: `BLUE 10`;
- secondary frequency/net designator: `WHITE 06`;
- report-in point: `REGINA`.

## Plain-text-Bedeutung des Beispiels

Nach der Erläuterung des Autors beschreibt Mission `1AT101` einen einzelnen C-135FR mit Callsign `Total 31`, der von Manas zum AAR-Orbit `RUSH` fliegt und dort von 1330Z bis 1900Z auf FL260 geplant ist. Das Flugzeug ist im Beispiel mit `BDA` gekennzeichnet und soll insgesamt 5,000 lb JP-8 abgeben.

Als Receiver ist Mission `1AT204`, Callsign `Rage 51`, mit zwei Mirage 2000D eingetragen. Für diese Formation sind 4,800 lb Offload und eine Air Refueling Control Time (`ARCT`) von 1415Z vorgesehen.

## Dokumentierte Quellenanomalie

Im bereitgestellten Original ist eine interne Inkonsistenz sichtbar:

```text
Raw CONTROLA set:  CONTROLA/CRC/SLAPSTICK/PFREQ:BLU10/SFREQ:WHT06/NAME:REGINA//
Author explanation: CALL SIGN: CROWBAR
```

Die Rohzeile nennt für das Control-Agency-Callsign `SLAPSTICK`, während die unmittelbar folgende Erläuterung des Beitrags `CROWBAR` nennt. OMW löst diesen Widerspruch **nicht** stillschweigend auf. Beide Angaben bleiben als Quellenbefund erhalten; keine davon wird aus diesem Beispiel als historische 2010/2011-Tatsache übernommen.

## Für OMW verwertbare Struktur

Das Beispiel unterstützt insbesondere folgende bereits in Dokument 54 vorgesehene Datenbeziehungen:

```text
TANKER MISSION
  -> tanker aircraft / callsign / departure / recovery
  -> refueling area or orbit
  -> on-station time window
  -> tanker altitude
  -> refueling system
  -> planned total offload
  -> one or more receiver allocations
       -> receiver mission ID
       -> receiver callsign
       -> receiver aircraft count and type
       -> planned receiver offload
       -> ARCT
       -> sequence
  -> control agency
  -> report-in point
```

Für OMW ist besonders relevant, dass die AAR-Zuordnung nicht nur einen Tanker beschreibt, sondern den Tankerauftrag mit konkreten Receiver-Missionen und einem geplanten Contact-Zeitpunkt verknüpft. Das ist eine geeignete Struktur für spätere ATO-like Player-Produkte und MissionDemand-/AAR-Zuordnungen, ohne die synthetischen Beispielwerte selbst zu übernehmen.

## Nicht aus dieser Quelle abzuleiten

Nicht belegt werden durch dieses Beispiel:

- reale ISAF-/OEF-Mission `1AT101` oder `1AT204`;
- reale Verwendung von `TOTAL31`, `RAGE51`, `RUSH`, `SLAPSTICK` oder `CROWBAR` im OMW-Zeitraum;
- reale UCFM-basierte C-135FR-Sortie mit den genannten Zeiten;
- historische FL260-Zuweisung für einen bestimmten Afghanistan-AAR-Track;
- reale IFF/SIF-Codes `01` oder `2005`;
- reale Frequenzen hinter `BLUE 10` oder `WHITE 06`;
- generelle 5,000-lb-Offload- oder 4,800-lb-Receiver-Planungswerte;
- die für 2010/2011 maßgebliche USMTF-/ADatP-3-Version oder exakte Feldsyntax.

## Verwendungsregel

```text
SOURCE EXAMPLE
-> preserve raw message and author interpretation
-> retain internal contradictions explicitly
-> use only for data-model semantics and test-fixture design
-> do not promote example values to historical OMW facts
-> verify any production parser field mapping against the applicable message standard/version
```
