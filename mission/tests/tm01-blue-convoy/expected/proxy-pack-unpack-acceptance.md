# TM01C – Abnahmevertrag für manuellen Proxy-Pack/Unpack-Test

## Status

TM01C ist ein isolierter technischer Nachweis. Reveal-Fenster und automatische Spieler-/Feindrelevanz sind ausdrücklich nicht Bestandteil dieses Tests.

Der Test gilt erst nach einem dokumentierten DCS-Lauf als bestanden. Lua-Parsing, Bundle-Build und Mock-Lauf sind Vorprüfungen, keine DCS-Abnahme.

## Pflichtobjekte im Mission Editor

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
ZONE_TM01_START_BAGRAM
ZONE_TM01_ROUTE_01
ZONE_TM01_ROUTE_02
ZONE_TM01_ROUTE_03
ZONE_TM01_ROUTE_04
ZONE_TM01_ROUTE_05
ZONE_TM01_ROUTE_06
ZONE_TM01_ROUTE_07
ZONE_TM01_TARGET_JALALABAD
```

Reveal-Zonen werden von TM01C nicht gelesen.

## F10-Menü

```text
OMW Tests
└── TM01C
    ├── Start convoy
    ├── Pack convoy
    ├── Unpack convoy
    ├── Show status
    └── Validate configuration
```

## Verbindliche Zustände

```text
NOT_STARTED
EXPANDED
COLLAPSED_PROXY
ARRIVED
DESTROYED
```

`Proxy` bezeichnet nur die Rolle des aktuell vordersten überlebenden Fahrzeugs.

## Startkriterien

1. Konfiguration `TM01C-manual-proxy-pack-unpack-1` wird geladen.
2. Bootstrap meldet `READY`.
3. Der Straßenpfad wird aus Start, sieben Ankern und Ziel kompiliert.
4. Der Start erzeugt exakt die sechs ursprünglichen Fahrzeuge.
5. Jedes Fahrzeug erhält eine eigene finale Straßenposition und ein eigenes Heading.
6. Die tatsächlich von `GetClosestPointToRoad()` gelieferte Koordinate wird verwendet.
7. Wasser und flaches Wasser werden abgelehnt.
8. Die Gruppe erhält eine verbleibende `On Road`-Route bis Jalalabad.
9. Der BLUE-Marker folgt der aktuellen Führungsrolle.

## Pack-Kriterien

1. `Pack convoy` ist nur in `EXPANDED` zulässig.
2. Vor dem Pack werden alle aktuell lebenden stabilen Slots erfasst.
3. Bereits zerstörte Slots werden dauerhaft aus der Überlebendenliste entfernt.
4. Der letzte Slot der geordneten Liste `rear-to-front` wird Führungs-/Proxy-Slot.
5. Nur dieses reale Führungsfahrzeug bleibt physisch.
6. Alle anderen Überlebenden bleiben im CampaignState gespeichert.
7. Die verbleibende physische Gruppe enthält exakt eine lebende Unit.
8. Das Führungsfahrzeug erhält die verbleibende Straßenroute neu zugewiesen.
9. Der Marker folgt ohne Unterbrechung der Führungsrolle.
10. Ein wiederholtes Pack im Proxyzustand wird abgewiesen.

## Unpack-Kriterien

1. `Unpack convoy` ist nur in `COLLAPSED_PROXY` zulässig.
2. Die reale Proxyposition wird auf den kompilierten Straßenpfad projiziert.
3. Der erste Kandidat verwendet exakt den aktuellen Routenfortschritt; weitere Kandidaten dürfen nur die konfigurierten kleinen Vorwärtsversätze verwenden.
4. Der verwendete Versatz wird immer protokolliert.
5. Materialisiert werden ausschließlich die konkret gespeicherten Überlebenden.
6. Kein zerstörter Slot wird neu erzeugt.
7. Die Spawnreihenfolge ist vorne nach hinten; der aktuelle Führungs-Slot bleibt vorne.
8. Die Fahrzeuge erhalten individuelle Straßenpositionen und Headings.
9. Wasser, flaches Wasser, zu große Straßensnap-Abweichung und zu kleine Fahrzeugabstände führen zu Fail-closed.
10. Bei ungültigem Layout bleibt das Proxyfahrzeug bestehen.
11. Vor dem Gruppentausch wird das alte Proxyobjekt nativ als entfernt bestätigt.
12. Scheitert der neue Spawn nach bestätigter Entfernung, wird ein Einzelfahrzeug-Proxy aus demselben Führungs-Slot wiederhergestellt.
13. Die neue Restgruppe erhält die verbleibende Straßenroute.
14. Ein wiederholtes Unpack im expandierten Zustand wird abgewiesen.

## Verlust- und Führungswechseltest

Ausgangsfolge von hinten nach vorne:

```text
HMVEE, HMVEE, LKW, LKW, HMVEE, HMVEE ->
```

Verbindlicher Test:

1. vorderstes und hinterstes Fahrzeug zerstören;
2. Reststärke muss exakt vier konkrete Slots enthalten;
3. neues vorderstes Fahrzeug wird Führungsfahrzeug;
4. Pack lässt nur dieses Fahrzeug physisch bestehen;
5. Unpack erzeugt exakt vier Fahrzeuge;
6. weiteres Führungsfahrzeug und ein LKW zerstören;
7. Reststärke muss exakt zwei konkrete Slots enthalten;
8. Pack/Unpack erzeugt exakt diese zwei Fahrzeuge;
9. kein zerstörter Slot erscheint erneut.

## Zielankunft

1. Erreicht die expandierte Restgruppe vollständig die Zielzone, wechselt sie auf `ARRIVED`.
2. Erreicht das Proxyfahrzeug die Zielzone, startet automatisch ein Unpack.
3. Die Ankunft erfolgt mit der tatsächlichen Reststärke.
4. `convoy_route_arrived` wird genau einmal protokolliert.

## Erforderliche Logereignisse

```text
configuration_valid
convoy_proxy_test_started
convoy_packed
convoy_unpack_started
convoy_unpacked
convoy_losses_observed
convoy_unpack_site_unavailable
convoy_unpack_failed_proxy_restored
convoy_route_arrived
convoy_proxy_status
```

## DCS-Abnahmeablauf

### Lauf A – ohne Verluste

1. Start mit sechs Fahrzeugen.
2. Mindestens fünf Pack-/Unpack-Zyklen an unterschiedlichen Straßenabschnitten.
3. Mindestens ein Unpack auf gerader Straße und eines in einer Kurve.
4. Proxy und Restgruppe müssen nach jedem Wechsel weiterfahren.
5. Zielankunft mit sechs Fahrzeugen.

### Lauf B – mit Verlusten

1. Start mit sechs Fahrzeugen.
2. Zwei Fahrzeuge zerstören, darunter das Führungsfahrzeug.
3. Pack und Unpack: exakt vier Fahrzeuge.
4. Zwei weitere Fahrzeuge zerstören.
5. Pack und Unpack: exakt zwei Fahrzeuge.
6. Zielankunft mit exakt zwei Fahrzeugen.

## Nicht Bestandteil dieses Teststands

- automatische Spieler- oder Feinderkennung;
- Entfernungshysterese und Cooldown;
- Sichtlinien-, Sensor- oder Waffenreichweitenlogik;
- Persistenz über Missions- oder Serverneustart;
- Übertragung partieller Schadenswerte auf neu erzeugte DCS-Units;
- Unterdrückung externer Death-Event-Auswertung für absichtlich eingepackte Units;
- mehrere gleichzeitige Konvois;
- serverseitiger Lastvergleich zwischen Vollgruppe und Proxybetrieb.
