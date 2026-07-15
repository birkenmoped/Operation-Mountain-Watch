# TM01B – Dynamische Proxy-Führungsrolle

Datum: 15. Juli 2026

## Status

Dieses Dokument ergänzt und korrigiert die Übergabe vom 14. Juli 2026.

Die Bezeichnung `Proxyfahrzeug` meint **kein fest definiertes Fahrzeug und keinen dauerhaft reservierten Template-Slot**. Der Proxy ist eine dynamische Rolle innerhalb derselben strategischen Konvoientität.

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

`currentLeadSlot` wird aus der realen Marschreihenfolge der überlebenden Fahrzeuge abgeleitet und nach Verlusten aktualisiert.

## Expanded-Zustand

Im expandierten Zustand existiert der vollständige physische Konvoi.

Während dieses Zustands:

- werden Verluste pro Template-Slot erfasst;
- wird die aktuelle Reihenfolge der überlebenden Fahrzeuge bestimmt;
- ist das vorderste überlebende Fahrzeug das reale Führungsfahrzeug;
- bleibt der Konvoi vollständig physisch, solange taktische Relevanz besteht;
- darf nicht auf eine vorab definierte Proxy-Einheit zurückgefallen werden.

## Collapse-Zustand

Beim Übergang von `EXPANDED` nach `COLLAPSED_PROXY`:

1. alle lebenden Fahrzeuge und ihre Reihenfolge entlang der Route erfassen;
2. das vorderste überlebende Fahrzeug als `currentLeadSlot` bestimmen;
3. dessen Typ, Schaden und Position soweit technisch belastbar übernehmen;
4. alle übrigen überlebenden Fahrzeuge in den strategischen Zustand zurückführen;
5. nur das aktuelle Führungsfahrzeug physisch weiterfahren lassen;
6. BLUE-Tracking und Relevanzprüfung an dieses Fahrzeug binden.

Wenn kein Fahrzeug überlebt, ist die strategische Konvoientität zerstört und darf nicht erneut materialisiert werden.

## Expansion

Beim Übergang von `COLLAPSED_PROXY` nach `EXPANDED` bleibt die Identität des aktuell fahrenden Führungsfahrzeugs erhalten.

Die zusätzlichen überlebenden Slots werden relativ zur realen Führungsposition entlang der Straße materialisiert.

Die Wiederaufstellung erfolgt in der gespeicherten logischen Marschreihenfolge. Bereits zerstörte Slots werden nicht neu erzeugt.

Beispiel nach zwei Verlusten:

```text
ursprünglich:
HMVEE, HMVEE, LKW, LKW, HMVEE, HMVEE ->

vordere HMVEE zerstört:
HMVEE, HMVEE, LKW, LKW ->

vorderster überlebender LKW:
- aktuelles Führungsfahrzeug
- physischer Proxy im reduzierten Zustand
- Bezugspunkt für die spätere Expansion
```

## Taktische Relevanz

Der Proxy-Zustand ist nur außerhalb realistischer taktischer Interaktion zulässig.

Bevor ein Spieler oder Gegner den Konvoi identifizieren, begleiten oder bekämpfen kann, muss die vollständige Gruppe bereits expandiert sein.

Das im reduzierten Zustand fahrende Führungsfahrzeug ist daher kein beabsichtigtes Einzelziel. Ein regulärer Waffenangriff auf den Proxy bedeutet, dass die Relevanz- und Vorwarnlogik zu spät ausgelöst hat.

## BLUE-Lagebild

BLUE kennt die Konvoiposition in beiden Zuständen:

```text
COLLAPSED_PROXY:
Marker und Status folgen dem aktuellen Führungsfahrzeug

EXPANDED:
Marker und Status folgen dem aktuellen Führungsfahrzeug der Vollgruppe
```

Ein Führungswechsel darf den strategischen Marker nicht unterbrechen. Der Marker ist an die Konvoientität und ihre aktuelle Führungsrolle gebunden, nicht an einen festen DCS-Unitnamen.

## Technische Konsequenzen

Die Implementierung benötigt:

- stabile Slot-Identitäten für alle Fahrzeuge;
- eine geordnete Liste der überlebenden Slots;
- Bestimmung des vordersten Fahrzeugs entlang der Route;
- Aktualisierung von `currentLeadSlot` nach Verlusten;
- Übergabe der Führungsrolle ohne Neuerschaffung zerstörter Slots;
- Markerbindung an die strategische Entität;
- Expansion relativ zur aktuellen realen Führungsposition;
- Collapse auf das aktuelle Führungsfahrzeug, nicht auf einen fest konfigurierten Slot.

## Verbotene Vereinfachungen

Folgende Modelle sind für das Endsystem nicht zulässig:

```text
immer Slot 1 als Proxy verwenden
immer einen bestimmten HMVEE als Proxy verwenden
ein separates künstliches Proxy-Fahrzeug außerhalb des eigentlichen Konvois verwenden
bei Verlust des Proxy-Slots den gesamten Konvoi als zerstört behandeln
zerstörte Führungsfahrzeuge bei Expansion neu erzeugen
```

## Offener technischer Nachweis

Vor Integration in die vollständige Strecke muss ein Test nachweisen:

1. vollständiger Konvoi expandiert;
2. vorderstes Fahrzeug wird zerstört;
3. nächstes Fahrzeug übernimmt die Führung;
4. Konvoi wird reduziert;
5. nur das neue Führungsfahrzeug bleibt physisch;
6. BLUE-Marker folgt ohne Unterbrechung;
7. erneute Expansion erzeugt nur die überlebenden Slots;
8. Reihenfolge und Verluste bleiben korrekt;
9. fällt auch das zweite Führungsfahrzeug aus, übernimmt der nächste überlebende Slot unabhängig vom Fahrzeugtyp.

## Verbindliche Entscheidung

`Proxy` bezeichnet ab sofort ausschließlich die dynamische Rolle des aktuell vordersten überlebenden Fahrzeugs. Es existiert kein spezifisches Proxyfahrzeug.