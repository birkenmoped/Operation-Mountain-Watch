# TM01C – DCS-Ergebnis: Fahrzeugausrichtung und wiederholte Pack-/Unpack-Zyklen

Datum: 16. Juli 2026  
Status: PASS für den manuellen Repräsentationswechsel und die Spawn-Ausrichtung

## Laufzeitkontext

```text
DCS:                  2.9.27.25340 Open Beta MT
Konfigurationsversion: TM01C-manual-proxy-pack-unpack-4
Build-Zeitstempel:     2026-07-16T19:53:27Z
Entität:               TEST.TM01.CONVOY.001
Route:                 ROUTE_TM01_BAGRAM_JALALABAD
Fahrzeuge:             3 × HMMWV, 3 × Lkw
```

## Beobachtung

Der Konvoi wurde wiederholt manuell ein- und ausgepackt. Die Unpack-Vorgänge fanden auf unterschiedlichen Straßenabschnitten statt, einschließlich Kurven und S-Kurven.

Bei jedem Unpack:

- standen alle sechs Fahrzeuge auf der Straße;
- folgte jeder Stable Slot der lokalen Straßenkrümmung;
- zeigte jede Fahrzeugfront in die aktuelle Marschrichtung;
- trat kein 180-Grad-Wendemanöver auf;
- war keine Entwirrung durch querstehende oder entgegen gerichtete Fahrzeuge erforderlich;
- nahm die neu erzeugte Runtime-Gruppe die Fahrt anschließend auf.

Die korrekte Aufstellung in Kurven und S-Kurven bestätigt, dass TM01C keine gemeinsame starre Gruppenausrichtung verwendet. Position und Heading werden pro Fahrzeug aus dem lokalen Verlauf des kompilierten Straßenpfades bestimmt.

## Lognachweis

Der DCS-Lauf enthält:

```text
convoy_proxy_test_started              1
convoy_pack_started                    9
convoy_packed                          9
convoy_unpack_started                  9
convoy_unpacked                        9
convoy_route_activation_confirmed     10
```

Für TM01C wurden in diesem Lauf keine folgenden Zustände gefunden:

```text
level=ERROR
movementState=FAILED
halted=true
convoy_pack_failed
convoy_unpack_failed
convoy_route_activation_timeout
```

Alle neun Unpack-Vorgänge verwendeten die Version-4-Heading-Berechnung und führten zu einer bestätigten Routenaktivierung. Die Runtime-Generation stieg erwartungsgemäß mit jedem Gruppentausch.

## Technische Bewertung

Der zuvor identifizierte Achsenfehler in der DCS-Heading-Berechnung ist im DCS-Lauf behoben.

Korrekte Konvention:

```text
DCS Vec2.x = Nord
DCS Vec2.y = Ost
Heading    = atan2(Ost, Nord)
```

Die Kombination aus:

- individueller Straßenposition pro Stable Slot;
- lokalem Heading pro Fahrzeug;
- asynchron bestätigtem Gruppentausch;
- begrenzter Routenaktivierungsphase;
- realer Bewegungsbestätigung;

ist für den manuellen Pack-/Unpack-Kern belastbar nachgewiesen.

## Abnahmestatus

| Prüffeld | Status |
|---|---|
| Initiale Straßenaufstellung | PASS |
| Heading in Marschrichtung | PASS |
| Unpack auf gerader Straße | PASS |
| Unpack in Kurven | PASS |
| Unpack in S-Kurven | PASS |
| Weiterfahrt nach Unpack | PASS |
| Wiederholte Pack-/Unpack-Zyklen | PASS |
| Keine Controller-Fehler im Lauf | PASS |

## Noch offene, getrennte Regressionstests

Diese Punkte blockieren den nächsten Automatisierungsschritt nicht, bleiben aber für die vollständige TM01C-Gesamtabnahme offen:

1. gezielter visueller Nachweis der Teilschadenswiederherstellung;
2. Angriff auf ein bereits eingepacktes Proxyfahrzeug;
3. vollständige Zielankunft im expandierten und im Proxyzustand;
4. vollständige Verlustsequenz bis auf zwei konkrete Survivor-Slots mit Zielankunft.

## Entscheidung für den nächsten Teststand

Der manuelle Repräsentationswechsel ist ausreichend stabil, um als nächstes eine isolierte automatische Spielerrelevanzsteuerung aufzusetzen.

Der nächste Teststand soll:

```text
Spieler nähert sich dem fahrenden Proxy
→ automatisch entpacken

kein relevanter Spieler mehr im Bereich
→ 30 Sekunden Abwesenheit bestätigen
→ automatisch einpacken
```

Die manuellen F10-Befehle bleiben als Diagnose- und Override-Werkzeug erhalten.

Für den ersten Automatiktest gelten folgende Schutzregeln:

- ausschließlich lebende, tatsächlich besetzte BLUE-Spielerunits zählen;
- Zuschauer und unbesetzte Client-Slots zählen nicht;
- der nächste Spieler bestimmt die Relevanz;
- ein einzelner Spieler im Bereich hält den Konvoi expandiert;
- Wiedereintritt während der 30-Sekunden-Frist bricht den Pack-Timer ab;
- keine neue Automatikaktion während `PACKING`, `UNPACKING` oder `ACTIVATING_ROUTE`;
- nach einer laufenden Transition wird die Relevanz erneut ausgewertet;
- jede Timer- und Zustandsentscheidung wird strukturiert geloggt;
- keine automatische Feindrelevanz in diesem ersten Schritt.

Empfohlen wird eine Distanzhysterese statt nur eines einzelnen Grenzwerts.

## Festgelegte Testparameter für den ersten visuellen Automatiklauf

Dieser erste Lauf dient ausdrücklich der direkten Sichtbeobachtung aus einem Spielerhubschrauber. Er bildet noch keine operative Sichtbarkeit, Sensorreichweite oder taktische Relevanz ab.

Verbindliche Testwerte:

```text
Automatisches Unpack:  horizontale Distanz ≤ 500 m
Pack-Timer starten:   horizontale Distanz > 750 m
Pack-Verzögerung:     30 s kontinuierlich außerhalb 750 m
Hysteresezone:        500 m bis 750 m
Höhe:                 wird für die Relevanzdistanz ignoriert
Geometrie:             vertikaler Zylinder um die aktuelle Lead-/Proxyposition
```

Einordnung der vom Tester genannten Größenordnung:

```text
1000 ft ≈ 305 m
1500 ft ≈ 457 m
500 m   ≈ 1640 ft
750 m   ≈ 2460 ft
```

Begründung:

- 500 m liegt nahe an der gewünschten Größenordnung von 1000–1500 ft und erlaubt eine klar beobachtbare Annäherung;
- bei 750 m bleibt der Konvoi aus einem Hubschrauber weiterhin sichtbar;
- die 250-m-Hysterese verhindert Flattern an einer einzigen Distanzgrenze;
- 30 Sekunden außerhalb des Außenradius machen Timerstart, Timerabbruch und Packen sichtbar und reproduzierbar;
- die Verwendung einer horizontalen 2D-Distanz verhindert, dass Flughöhe den Test verfälscht.

Nicht Bestandteil dieses ersten Automatiklaufs:

- Sichtlinie;
- Geländeabschattung;
- Sensor- oder Waffenreichweiten;
- Feinderkennung;
- Sichtweitenmodell;
- Flughöhenabhängigkeit;
- taktische Bedrohungsbewertung.

Nach erfolgreichem Test werden diese kleinen Werte nicht als Produktionsparameter übernommen. Der spätere operative Relevanzbereich wird separat entworfen und abgenommen.
