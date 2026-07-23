# Jalalabad AirOps – verbindliche Zonenplatzierung

## Zweck

Diese Liste definiert die elf für den vollständigen Jalalabad-AirOps-Knoten erforderlichen Triggerzonen. Die Zonen werden im DCS Mission Editor als normale Triggerzonen angelegt.

Die Namen müssen exakt übernommen werden. Die angegebenen Radien sind verbindliche Ausgangswerte für den technischen Abschlusslauf. Eine spätere Feinjustierung aufgrund praktischer Spawn-, Lade- oder Kollisionsversuche bleibt möglich.

## Allgemeine Regeln

- Zonenmittelpunkt auf die tatsächlich vorgesehene Nutzfläche setzen.
- Nicht unnötig über Startbahn, Rollwege oder benachbarte Funktionsflächen ausdehnen.
- Spieler- und KI-Spawnplätze dürfen innerhalb einer Bereitschaftszone liegen.
- Static-Zonen sollen nur den jeweiligen sichtbaren Static-Bereich abdecken.
- Lade-, Entlade- und Sling-Zonen sollen klar voneinander unterscheidbar sein.
- Eine Zone darf mehrere physische Einzelpositionen umfassen, solange die Funktion eindeutig bleibt.

## 1. OH-58D-Staticbereich

```text
Name: ZONE_AIR_US_JBAD_STATIC_OH58D
Radius: 90 m
```

Platzierung:

- über dem Bereich `G01-G07`,
- alle sieben OH-58D-Statics einschließen,
- keine darüber hinausgehenden Spieler-/KI-Flächen erforderlich.

## 2. AH-64D-Staticbereich

```text
Name: ZONE_AIR_US_JBAD_STATIC_AH64D
Radius: 90 m
```

Platzierung:

- über der südlichen beziehungsweise westlichen AH-64D-Staticgruppe,
- alle vier AH-64D-Statics einschließen,
- möglichst keine UH-60-Statics einschließen.

## 3. UH-60-Staticbereich

```text
Name: ZONE_AIR_US_JBAD_STATIC_UH60
Radius: 90 m
```

Platzierung:

- über der UH-60A-Staticgruppe,
- alle vier UH-60A-Statics einschließen,
- getrennt von der AH-64D-Staticzone halten, soweit die Rampgeometrie dies zulässt.

## 4. CH-47-Staticbereich

```text
Name: ZONE_AIR_US_JBAD_STATIC_CH47
Radius: 130 m
```

Platzierung:

- im Bereich `C01-C14`,
- die fünf CH-47-Statics einschließen,
- nicht zwingend die zwei CH-47-Spielerplätze oder KI-Templateposition umfassen.

## 5. MEDEVAC-Bereitschaft

```text
Name: ZONE_AIR_US_JBAD_MEDEVAC_READY
Radius: 80 m
```

Platzierung:

- über den beiden UH-60A-KI-Templatepositionen,
- MEDEVAC Lead und MEDEVAC Cover einschließen,
- freie Abflugrichtung gewährleisten.

## 6. CH-47-Bereitschaft

```text
Name: ZONE_AIR_US_JBAD_CH47_READY
Radius: 100 m
```

Platzierung:

- über dem CH-47-KI-Template und den für Heavy-Lift-Einsätze reservierten freien C-Positionen,
- die fünf CH-47-Statics nicht zwingend vollständig einschließen,
- mindestens zwei freie CH-47-taugliche Spawn-/Rückkehrflächen berücksichtigen.

## 7. Heavy-Lift-Ladezone

```text
Name: ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
Radius: 80 m
```

Platzierung:

- auf einer freien, CH-47-tauglichen Ladefläche nahe `C01-C14`,
- nicht direkt auf einem Spieler- oder KI-Spawnpunkt,
- ausreichend Rotorabstand zu Statics, Gebäuden und Containern,
- für Truppen- und interne Frachtaufnahme vorgesehen.

## 8. Allgemeine Logistik-Ladezone

```text
Name: ZONE_AIR_US_JBAD_LOGISTICS_LOAD
Radius: 80 m
```

Platzierung:

- im Lager-/Versorgungsbereich nahe `WH_AIR_US_JALALABAD`,
- für aufzunehmende Fracht und Personal,
- nicht mit der C-130-Entladezone identisch platzieren.

## 9. Allgemeine Logistik-Entladezone

```text
Name: ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
Radius: 80 m
```

Platzierung:

- auf einer getrennten Übergabe- oder Verteilfläche,
- nahe genug am Lagerbereich für plausible Bodenlogistik,
- räumlich von `ZONE_AIR_US_JBAD_LOGISTICS_LOAD` unterscheidbar.

## 10. Slingload-Aufnahmezone

```text
Name: ZONE_AIR_US_JBAD_SLING_PICKUP
Radius: 70 m
```

Platzierung:

- auf einer freien Außenlastfläche ohne Gebäude, Masten oder Rotorhindernisse,
- Cargo-Objekte können später innerhalb dieser Zone erzeugt oder platziert werden,
- nicht auf einer regulären DCS-Parkposition.

## 11. C-130-Entladezone

```text
Name: ZONE_AIR_US_JBAD_C130_UNLOAD
Radius: 120 m
```

Platzierung:

- auf der für C-130 geeigneten Fixed-Wing-Cargo-/Apronfläche,
- nicht im Hubschrauberbereich `C01-C14`,
- Rollweg und Abstellfläche für ein C-130-Luftfahrzeug freihalten.

## Kontrollliste

Vor dem Test müssen exakt elf Zonen vorhanden sein:

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_STATIC_CH47
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_CH47_READY
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

Erwartete Validator-Zusammenfassung:

```text
SUMMARY ZONE present=11 missing=0
```
