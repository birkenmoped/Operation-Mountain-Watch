# Quellenakte - Graveyard of Empires ATO Example 2: Ground Alert CAS

## Quelle

- Graveyard of Empires, *Air Tasking Order - Example 2 - Ground Alert CAS*, 14. November 2024.
- Original-URL: <https://www.patreon.com/graveyard4DCS/posts/air-tasking-2-115745557>
- Vom Projektinhaber bereitgestellte PDF-Erfassung: `ATO-CAS2.pdf`, 3 Seiten.
- Zugehörige OMW-Fachreferenz: [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](../../54-air-tasking-airspace-control-cas-requests-and-mission-data.md), dort Quelle `T07`.

## Quellenklasse und Verwendungsgrenze

```text
SOURCE_CLASS: SECONDARY_DCS_INTERPRETATION / SYNTHETIC_EXAMPLE
PUBLICATION_DATE: 2024-11-14
OMW_PERIOD_RELATION: POST_PERIOD_REFERENCE
HISTORICAL_STATUS: EXAMPLE_ONLY
HISTORICAL_CLAIM: false
```

Der Beitrag ist ein didaktisches ATO-/Ground-Alert-Beispiel. Er illustriert Ground Alert, Alert-Status, Missionszeitfenster und die Verknüpfung einer geplanten Mission mit einer Air Support Request Number. Er belegt **keine reale 2010/2011-Afghanistan-Mission** und keinen generellen historischen 15-Minuten-Standard.

## Vom Autor erläutertes Alert-Konzept

Der Beitrag beschreibt Ground Alerts als geplante Missionen, die noch nicht gestartet sind und am Boden auf Tasking warten. Die Reaktionszeit hängt laut Beispiel vom Alert Status ab. Für einen `15M`-Status wird erläutert, dass die Mission innerhalb von 15 Minuten nach Notification airborne sein soll.

Als Präfixbeispiele nennt der Beitrag:

```text
G...  -> Ground Alert
GAR   -> Ground Alert Air Refueling

X...  -> Airborne Alert
XSAR  -> Airborne Alert Search And Rescue
```

Diese Präfixkonventionen werden für OMW nur als vom Autor dargestellte Beispielsprache festgehalten. Vor einer produktiven Abbildung müssen sie gegen die für den relevanten Zeitraum maßgebliche Message-Format-Version geprüft werden.

## Im Beitrag dargestellte Nachricht

```text
AMSNDAT/AN1041/-/-/-/GCAS/-/15M/DEPLOC:OAKN/ARRLOC:OAKN//

MSNACFT/2/ACTYP:A10/HOG07/4A652A2S2/-/101/-/32011//

AMSNLOC/061400ZMAR/061700ZMAR/-/-/1A//

REQNO/8V031
```

## Vom Autor angegebene Feldbedeutung

### `AMSNDAT` - Aircraft Mission Data

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Mission Number | `AN1041` | Mission identifier |
| AMC Mission Number | `-` | N/A |
| Package Identification | `-` | N/A |
| Mission Commander | `-` | N/A |
| Primary Mission Type | `GCAS` | Ground Alert Close Air Support |
| Secondary Mission Type | `-` | N/A |
| Alert Status | `15M` | 15 minutes |
| Departure Location | `OAKN` | Kandahar |
| Recovery Base | `OAKN` | Kandahar |

### `MSNACFT` - Individual Aircraft Mission Data

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Number of Aircraft | `2` | Two aircraft |
| Aircraft Type and Model | `A10` | A-10 Thunderbolt II |
| Aircraft Call Sign | `HOG07` | Hog 07 |
| Primary Configuration Code | `4A652A2S2` | Configuration code |
| Secondary Configuration Code | `-` | N/A |
| IFF/SIF Mode 1 | `01` | Mode 1 code |
| IFF/SIF Mode 2 | `-` | N/A |
| IFF/SIF Mode 3 | `2011` | Mode 3 code |

### `AMSNLOC` - Aircraft Mission Location

| Feld | Beispielwert | Vom Autor angegebene Bedeutung |
|---|---|---|
| Start | `061400ZMAR` | 6 March, 1400Z |
| Stop | `061700ZMAR` | 6 March, 1700Z |
| Mission Location Name | `-` | N/A |
| Altitude | `-` | N/A |
| Mission Priority | `1A` | Priority 1A |

### `REQNO` - Air Support Request Number

```text
REQNO/8V031
```

Der Beitrag interpretiert `8V031` als Air Support Request Number.

## Plain-text-Bedeutung des Beispiels

Nach der Erläuterung des Autors beschreibt Mission `AN1041` zwei A-10 auf Ground Alert in Kandahar. Sie stehen von 1400Z bis 1700Z in diesem Alert-Fenster. Wird eine CAS-Mission angefordert, sollen sie gemäß dem beispielhaften `15M`-Alertstatus innerhalb von 15 Minuten nach Notification starten beziehungsweise airborne sein.

## Bedeutung von `REQNO` im Beispiel

Der Autor hebt die Request Number als Track-and-Trace-Schlüssel hervor. Im Beispiel fordert eine Army Ground Unit Ground Alert Close Air Support unter der Request Number `8V031` an. Durch Suche nach diesem Request-Identifier im ATO kann die unterstützende Mission `AN1041` gefunden werden.

Für OMW ist dies strukturell relevant, weil es die Beziehung

```text
AIR SUPPORT REQUEST
  -> request_id / REQNO
  -> assigned mission
  -> mission_id
  -> alert status
  -> alert window
```

illustriert.

Damit unterstützt das Beispiel die in Dokument 54 bereits vorgesehene Trennung zwischen Request-Lifecycle und Mission-Lifecycle: Eine Anfrage benennt einen Bedarf; eine konkrete Mission wird diesem Bedarf zugewiesen und bleibt über die Request-ID nachvollziehbar.

## Für OMW verwertbare Struktur

Das Beispiel unterstützt insbesondere:

```text
GROUND ALERT MISSION
  -> mission ID
  -> mission role / alert role
  -> alert readiness time
  -> departure and recovery base
  -> aircraft count and type
  -> callsign and configuration
  -> alert window start/stop
  -> mission priority
  -> linked air support request number
```

Für die spätere OMW-Umsetzung ist wichtig, Alert Window und Reaktionszeit getrennt zu behandeln:

```text
alert window
!=
launch/readiness time
!=
transit time
!=
on-station time
```

Das entspricht der bereits in Dokument 54 festgehaltenen Projektregel, Start, Taxi, Takeoff und Transit als getrennte Zeiten zu behandeln.

## Nicht aus dieser Quelle abzuleiten

Nicht belegt werden durch dieses Beispiel:

- reale ISAF-/OEF-Mission `AN1041`;
- reale Air Support Request `8V031`;
- reale Verwendung von `HOG07` für diesen Auftrag;
- ein genereller historischer `15M`-Ground-Alert-Standard in Afghanistan;
- reale Missionspriorität `1A` für einen bestimmten OEF-/ISAF-Auftrag;
- reale IFF/SIF-Codes `01` oder `2011`;
- reale A-10-Konfiguration `4A652A2S2`;
- dass jedes Ground-Alert-Mission-Type zwingend durch ein `G`-Präfix beziehungsweise jedes Airborne Alert durch ein `X`-Präfix codiert wurde;
- die für 2010/2011 maßgebliche USMTF-/ADatP-3-Version oder exakte Feldsyntax.

## Verwendungsregel

```text
SOURCE EXAMPLE
-> preserve raw message and author interpretation
-> use REQNO only as demonstrated request-to-mission linkage semantics
-> keep alert window and readiness time separate
-> do not promote example values or prefix conventions to historical OMW facts
-> verify production field mappings and mission-type codes against the applicable message standard/version
```
