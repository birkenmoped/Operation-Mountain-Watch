# TM01B – Dynamische Proxy-Führungsrolle

Datum: 15. Juli 2026

## Status

Dieses Dokument ergänzt und korrigiert die Übergabe vom 14. Juli 2026.

Die Bezeichnung `Proxyfahrzeug` meint **kein fest definiertes Fahrzeug und keinen dauerhaft reservierten Template-Slot**. Der Proxy ist eine dynamische Rolle innerhalb derselben strategischen Konvoientität.

Zusätzlich gilt verbindlich: **Der Konvoi wird nach Verlusten niemals wieder auf seine ursprüngliche Sollstärke aufgefüllt.** Gespeichert und später erneut materialisiert werden ausschließlich die tatsächlich noch überlebenden Fahrzeuge.

## Verbindliche Identitätsregel

Im reduzierten Zustand wird immer das aktuell vorderste überlebende Fahrzeug des Konvois physisch dargestellt.

Beispiel, von hinten nach vorne:

```text
HMVEE, HMVEE, LKW, LKW, HMVEE, HMVEE ->
```

Solange alle Fahrzeuge leben, ist der vorderste HMVEE Träger der Proxy-Führungsrolle.

Fällt das Führungsfahrzeug während einer expandierten Kampf- oder Relevanzphase aus, gilt:

```text
vorderstes Fahrzeug zerstört
→ nächstes überlebendes Fahrzeug in Marschrichtung wird Führungsfahrzeug
→ dieses Fahrzeug trägt beim nächsten Collapse die Proxy-Führungsrolle
```

Beispiel:

```text
1. vorderster HMVEE fällt aus
2. zweiter vorderer HMVEE wird Führungsfahrzeug
3. fällt auch dieser aus, wird der vorderste LKW Führungsfahrzeug
```

Der Fahrzeugtyp ist für die Proxy-Rolle unerheblich. Entscheidend ist ausschließlich die aktuelle Reihenfolge der überlebenden Fahrzeuge entlang der Marschrichtung.

## Persistente Reststärke

Die strategische Konvoientität besitzt zu jedem Zeitpunkt eine konkrete Liste überlebender Fahrzeuge. Diese Liste schrumpft durch bestätigte Verluste dauerhaft.

Ausgangsstärke:

```text
HMVEE, HMVEE, LKW, LKW, HMVEE, HMVEE ->
```

Nach Verlust des hintersten und des vordersten HMVEE:

```text
HMVEE, LKW, LKW, HMVEE ->
```

Nach Verlust des nun vordersten HMVEE und des ersten LKW:

```text
HMVEE, LKW ->
```

Diese beiden Fahrzeuge sind anschließend die vollständige aktuelle Restgruppe. Die vier zerstörten Fahrzeuge bleiben dauerhaft verloren.

Verboten ist insbesondere:

```text
Restgruppe beim nächsten Expandieren wieder auf sechs Fahrzeuge ergänzen
zerstörte Slots erneut erzeugen
nur eine numerische Gruppenstärke speichern und Fahrzeugidentitäten verlieren
```

Gespeichert wird daher nicht nur `groupStrength = 2`, sondern die konkrete geordnete Überlebendenliste.

## Konsequenz für CampaignState

Der CampaignState darf keine Eigenschaft wie `fixedProxySlot` oder `proxyVehicleType` als dauerhafte Identität führen.

Erforderlich sind mindestens:

```text
survivingVehicleSlots
orderedVehicleSlotsAlongRoute
currentLeadSlot
currentLeadUnitType
representationState
routeProgress beziehungsweise reale Führungsposition
```

Jeder Eintrag in `survivingVehicleSlots` benötigt mindestens:

```text
stabile Slot-ID
Fahrzeugtyp
logische Marschreihenfolge
Lebensstatus
Schadenszustand, soweit technisch belastbar
```

`currentLeadSlot` wird aus der realen Marschreihenfolge der überlebenden Fahrzeuge abgeleitet und nach Verlusten aktualisiert.

## Expanded-Zustand

Im expandierten Zustand existieren **alle aktuell überlebenden Fahrzeuge** physisch. `Expanded` bedeutet nicht, dass die ursprüngliche Sollstärke wiederhergestellt wird.

Während dieses Zustands:

- werden Verluste pro stabiler Slot-ID erfasst;
- werden zerstörte Slots dauerhaft aus der Überlebendenliste entfernt;
- wird die aktuelle Reihenfolge der überlebenden Fahrzeuge bestimmt;
- ist das vorderste überlebende Fahrzeug das reale Führungsfahrzeug;
- bleibt die aktuelle Restgruppe vollständig physisch, solange taktische Relevanz besteht;
- darf nicht auf eine vorab definierte Proxy-Einheit zurückgefallen werden.

## Collapse-Zustand

Beim Übergang von `EXPANDED` nach `COLLAPSED_PROXY`:

1. alle noch lebenden Fahrzeuge und ihre Reihenfolge entlang der Route erfassen;
2. zerstörte Slots endgültig aus dem CampaignState entfernen beziehungsweise als zerstört markieren;
3. das vorderste überlebende Fahrzeug als `currentLeadSlot` bestimmen;
4. dessen Typ, Schaden und Position soweit technisch belastbar übernehmen;
5. alle übrigen überlebenden Fahrzeuge speichern und physisch entfernen;
6. nur das aktuelle Führungsfahrzeug physisch weiterfahren lassen;
7. BLUE-Tracking und Relevanzprüfung an dieses Fahrzeug binden.

Beispiel mit der Restgruppe:

```text
vor Collapse physisch:
HMVEE, LKW ->

nach Collapse physisch:
LKW ->

im CampaignState gespeichert:
HMVEE
```

Wenn kein Fahrzeug überlebt, ist die strategische Konvoientität zerstört und darf nicht erneut materialisiert werden.

## Expansion

Beim Übergang von `COLLAPSED_PROXY` nach `EXPANDED` bleibt das aktuell fahrende Führungsfahrzeug der Bezugspunkt.

Materialisiert werden ausschließlich die zusätzlich gespeicherten **überlebenden** Fahrzeuge. Die aktuelle Restgruppe wird relativ zur realen Führungsposition entlang der Straße wiederhergestellt.

Beispiel:

```text
COLLAPSED_PROXY physisch:
LKW ->

gespeichert:
HMVEE

nach Expansion:
HMVEE, LKW ->
```

Nicht wieder erzeugt werden die vier zuvor zerstörten Fahrzeuge aus der ursprünglichen Sechsergruppe.

Die Wiederaufstellung erfolgt in der gespeicherten logischen Marschreihenfolge. Bereits zerstörte Slots werden nicht neu erzeugt.

## Zielankunft

Erreicht das aktuelle Führungsfahrzeug das Ziel im Zustand `COLLAPSED_PROXY`, wird die noch gespeicherte Restgruppe am Ziel wieder materialisiert.

Die Ankunft erfolgt damit in der tatsächlichen verbliebenen Stärke:

```text
ursprünglich:
HMVEE, HMVEE, LKW, LKW, HMVEE, HMVEE ->

nach Verlusten verblieben:
HMVEE, LKW ->

Ankunft am Ziel:
HMVEE, LKW ->
```

Die Zielankunft darf keine zerstörten Fahrzeuge rekonstruieren und keine ursprüngliche Sollstärke vortäuschen.

## Taktische Relevanz

Der Proxy-Zustand ist nur außerhalb realistischer taktischer Interaktion zulässig.

Bevor ein Spieler oder Gegner den Konvoi identifizieren, begleiten oder bekämpfen kann, muss die aktuelle Restgruppe bereits expandiert sein.

Das im reduzierten Zustand fahrende Führungsfahrzeug ist daher kein beabsichtigtes Einzelziel. Ein regulärer Waffenangriff auf den Proxy bedeutet, dass die Relevanz- und Vorwarnlogik zu spät ausgelöst hat.

## BLUE-Lagebild

BLUE kennt die Konvoiposition in beiden Zuständen:

```text
COLLAPSED_PROXY:
Marker und Status folgen dem aktuellen Führungsfahrzeug

EXPANDED:
Marker und Status folgen dem aktuellen Führungsfahrzeug der Restgruppe
```

Ein Führungswechsel darf den strategischen Marker nicht unterbrechen. Der Marker ist an die Konvoientität und ihre aktuelle Führungsrolle gebunden, nicht an einen festen DCS-Unitnamen.

## Technische Konsequenzen

Die Implementierung benötigt:

- stabile Slot-Identitäten für alle ursprünglichen Fahrzeuge;
- eine geordnete Liste ausschließlich der überlebenden Slots;
- dauerhafte Entfernung beziehungsweise Markierung bestätigter Verluste;
- Bestimmung des vordersten Fahrzeugs entlang der Route;
- Aktualisierung von `currentLeadSlot` nach Verlusten;
- Markerbindung an die strategische Entität;
- Expansion relativ zur aktuellen realen Führungsposition;
- Materialisierung ausschließlich der gespeicherten Überlebenden;
- Collapse auf das aktuelle Führungsfahrzeug, nicht auf einen fest konfigurierten Slot;
- Expansion der Restgruppe bei Zielankunft.

## Verbotene Vereinfachungen

Folgende Modelle sind für das Endsystem nicht zulässig:

```text
immer Slot 1 als Proxy verwenden
immer einen bestimmten HMVEE als Proxy verwenden
ein separates künstliches Proxy-Fahrzeug außerhalb des eigentlichen Konvois verwenden
bei Verlust des Proxy-Slots den gesamten Konvoi als zerstört behandeln
zerstörte Führungsfahrzeuge bei Expansion neu erzeugen
zerstörte Begleitfahrzeuge bei Expansion neu erzeugen
den Konvoi bei jeder Expansion auf die ursprüngliche Sollstärke auffüllen
nur eine abstrakte Gruppenstärke ohne konkrete Fahrzeugslots speichern
```

## Offener technischer Nachweis

Vor Integration in die vollständige Strecke muss ein Test nachweisen:

1. vollständige ursprüngliche Sechsergruppe expandiert;
2. vorderstes und hinterstes Fahrzeug werden zerstört;
3. Überlebendenliste enthält anschließend exakt vier Fahrzeuge;
4. weiteres Führungsfahrzeug und ein LKW werden zerstört;
5. Überlebendenliste enthält anschließend exakt zwei konkrete Fahrzeuge;
6. nächstes Fahrzeug übernimmt die Führung;
7. Konvoi wird reduziert;
8. nur das neue Führungsfahrzeug bleibt physisch;
9. BLUE-Marker folgt ohne Unterbrechung;
10. erneute Expansion erzeugt exakt die zwei verbliebenen Fahrzeuge;
11. kein zerstörter Slot wird neu erzeugt;
12. Reihenfolge und Verluste bleiben korrekt;
13. erneuter Collapse speichert wieder genau dieselbe Reststärke;
14. Zielankunft materialisiert genau die verbleibende Restgruppe;
15. fällt auch das aktuelle Führungsfahrzeug aus, übernimmt der nächste überlebende Slot unabhängig vom Fahrzeugtyp.

## Verbindliche Entscheidung

`Proxy` bezeichnet ausschließlich die dynamische Rolle des aktuell vordersten überlebenden Fahrzeugs.

`Expanded` bezeichnet ausschließlich die physische Darstellung aller aktuell noch überlebenden Fahrzeuge, nicht die Wiederherstellung der ursprünglichen Sollstärke.

Der Konvoi schrumpft durch Verluste dauerhaft und erreicht Begegnungen sowie das Ziel ausschließlich mit seiner tatsächlichen Reststärke.