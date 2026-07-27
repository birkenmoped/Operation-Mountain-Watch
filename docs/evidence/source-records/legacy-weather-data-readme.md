# Wetterdaten Jalalabad 2010–2011

Dieses Verzeichnis enthält die versionierbaren Datengrundlagen zur historischen Wetterauswertung für **Operation Mountain Watch**.

## Zeitliche Einordnung

```text
Verbindlicher Kampagnenzeitraum:
01.08.2010–31.12.2011

Abdeckung der hier dokumentierten QL5/KQL5-Daten:
01.08.2010–20.05.2011 UTC
```

Die beiden Zeiträume sind nicht gleichzusetzen. Die vorhandenen Daten bleiben für ihre tatsächliche Abdeckung gültig; für 21.05.2011 bis 31.12.2011 besteht ein Erweiterungsauftrag.

## Dateien

- `QL5-selected-historical-weather-profiles-2010-2011.csv` – 16 ausgewählte reale METAR-Beobachtungen, vier je Jahreszeit innerhalb der vorhandenen Abdeckung
- `QL5-seasonal-weather-statistics-2010-2011.csv` – saisonale Kennzahlen aus 4.886 Beobachtungen der vorhandenen Abdeckung

Die Dateinamen bleiben aus Gründen stabiler Referenzen bestehen. Sie bedeuten nicht, dass bereits das gesamte Kalenderjahr 2011 ausgewertet wurde.

Die vollständige IEM-Rohdatei wird nicht im Repository dupliziert. Sie kann mit dem dokumentierten Abruf neu erzeugt werden.

## Reproduzierbarer Rohdatenabruf

```powershell
curl.exe "https://mesonet.agron.iastate.edu/cgi-bin/request/asos.py?station=QL5&data=all&year1=2010&month1=8&day1=1&year2=2011&month2=5&day2=21&tz=Etc%2FUTC&format=onlycomma&latlon=yes&elev=yes&missing=M&trace=T&direct=no&report_type=2&network=AF__ASOS" -o QL5_Jalalabad_2010-08-01_bis_2011-05-20.csv
```

Der IEM-Endtermin ist exklusiv. Deshalb wird der 21. Mai 2011 angegeben, damit der 20. Mai vollständig enthalten ist.

Kontrolle:

```powershell
$file = ".\QL5_Jalalabad_2010-08-01_bis_2011-05-20.csv"
Get-Item $file | Select-Object Name, Length
$lines = (Get-Content $file | Measure-Object -Line).Lines
"Zeilen insgesamt: $lines"
"Wetterbeobachtungen: $($lines - 1)"
```

Erwarteter Stand:

```text
Zeilen insgesamt: 4887
Wetterbeobachtungen: 4886
```

## CSV-Format

- UTF-8;
- Semikolon als Trennzeichen;
- UTC und Afghanistan-Ortszeit als getrennte Felder;
- METAR-Windrichtung als Richtung, aus der der Wind kommt;
- Wolkenbasen in Fuß AGL;
- QNH in hPa;
- unveränderter Original-METAR-Text zur Nachprüfung.

## Auswertungsregeln der vorhandenen Abdeckung

- Datenabdeckung: 01.08.2010 00:00 UTC bis 20.05.2011 23:59 UTC;
- Sommersegment: August 2010;
- Herbst: September bis November 2010;
- Winter: Dezember 2010 bis Februar 2011;
- Frühling: März bis 20.05.2011;
- Sicht `9999`: mindestens 10 km, für Mittelwerte bei 10 km gedeckelt;
- Wetterkategorien können sich überschneiden;
- Prozentwerte beziehen sich auf Beobachtungen, nicht auf Tage;
- `BKN000`/`OVC000` bei Staub wird als verdeckter Himmel interpretiert, nicht als echte Wolkenbasis auf 0 ft.

## Datenqualität

Viele KQL5-Meldungen enthalten:

```text
WND DATA ESTMD
ALSTG/SLP ESTMD
```

Wind- und Druckwerte sind dort als geschätzt gekennzeichnet. Die Datensätze sind historische Stationsbeobachtungen mit Qualitätsvorbehalt, keine vollständig qualitätskontrollierten Klimanormalwerte.

Die IEM-Koordinate für QL5 weist gegenüber OAJL einen auffälligen Längengradunterschied auf. Andere historische Aviation-Verzeichnisse behandeln KQL5 und OAJL als Jalalabad. Die genaue Sensorposition bleibt als Metadatenunsicherheit dokumentiert.

## Erweiterung bis Dezember 2011

Eine spätere Ergänzung muss getrennt speichern und dokumentieren:

- Abrufquelle und Stationscode;
- tatsächliche Datenabdeckung;
- Beobachtungszahl;
- Stations- und Qualitätsunsicherheit;
- neue Profile und stabile IDs;
- getrennte Statistik für den ergänzten Zeitraum;
- Regeln für regionale Ersatzstationen, falls QL5 lückenhaft bleibt.

## Zugehörige Hauptdokumentation

Siehe [`OMW-WX-HISTORICAL-BASELINE`](../../41-historical-weather-baseline-2010-2011.md).
