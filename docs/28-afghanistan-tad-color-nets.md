# Afghanistan TAD- und Color-Net-Frequenzplan

## 1. Status und Zweck

**Status:** `REFERENCE` / projektweiter Frequenzanhang für Missionsdesign und spätere technische Implementierung.

Dieses Dokument übernimmt die Inhalte des Beitrags **„TAD & Color Nets: Tactical Frequency Presets for Afghanistan Theater“** von *Graveyard of Empires* sowie die bereitgestellte Anlage **„Afghanistan Theater - Radio Color Preset“**, Version `v1.0` vom **17. Oktober 2025**.

Der Frequenzplan stellt für **Operation Mountain Watch** bereit:

- 20 benannte Color-Net-Gruppen mit jeweils 20 Slots,
- insgesamt **400 eindeutige Color-Net/Frequenz-Zuordnungen**,
- die Zuordnung der DCS-AI-Funkfrequenzen von 14 Flugplätzen beziehungsweise getrennten Flugplatz-/Heliport-Funkstellen,
- verbindliche Regeln für die Trennung von JTAC-, C2-, Flugplatz- und weiteren taktischen Funknetzen,
- eine stabile logische Netzbezeichnung, die unabhängig von späteren Änderungen der numerischen Frequenz verwendet werden kann.

Die Tabellen sind als **DCS-Missionsdesign-Datensatz** zu verstehen. Sie sind keine freigegebene historische COMPLAN-, ATO- oder SPINS-Frequenzliste und belegen nicht, dass diese numerischen Zuordnungen im realen Afghanistan-Einsatz verwendet wurden.

## 2. Begriffe und operativer Hintergrund

### 2.1 TAD

`TAD` steht im hier verwendeten Kontext für **Tactical Air Direction**. Die im Beitrag ausdrücklich zurückgewiesene Auflösung „Tactical Air Designator“ ist für diesen Zweck nicht zu verwenden.

Ein TAD-Net ist ein taktisches Sprechfunknetz zur lokalen Führung und Koordination von Luftfahrzeugen. Es trennt zeitkritischen taktischen Funkverkehr von übergeordneten Führungsnetzen und stellt insbesondere Terminal Controllern, airborne controllers und Strikern ein gemeinsames, eindeutig bezeichnetes Arbeitsnetz bereit.

### 2.2 TAD-Slots und Color Nets

TAD-Slots verwenden nummerierte Bezeichnungen wie `TAD.001`. Color Nets verwenden stattdessen kurze Farbnamen mit Slotnummer, beispielsweise `PEACH 01` oder `KHAKI 12`. Beide Verfahren verfolgen denselben Zweck:

- kürzere und weniger fehleranfällige Funkanweisungen,
- eine prozedurale OPSEC-Schicht, weil die numerische Frequenz nicht offen genannt werden muss,
- zentrale Pflege der Frequenzzuordnung, ohne jedes Briefing und jede Missionsunterlage ändern zu müssen,
- eindeutige und standardisierte Referenzen in COMPLAN, SPINS, ATO, Briefing und Kneeboard.

Die Codierung ist kein technischer Schutz gegen moderne Funkaufklärung oder Spektrumsuche. Sie verbessert vor allem Verfahren, Eindeutigkeit und Dokumentationspflege.

### 2.3 Lehre aus Afghanistan: diskrete JTAC-Netze

Der Ausgangsbeitrag hebt als wesentliche Lehre aus Koalitionsoperationen in Afghanistan hervor: **Jeder aktive JTAC benötigt ein diskretes TAD-Netz.** Ein JTAC-Netz darf nicht gleichzeitig von einem zweiten JTAC oder einer anderen C2-Stelle als Arbeitsnetz verwendet werden.

Geteilte Netze erhöhen insbesondere:

- den Aufwand für Deconfliction,
- die Gefahr von Talk-over und falsch zugeordneten Funksprüchen,
- das Risiko, den tatsächlich zur Waffenfreigabe autorisierten Controller zu verwechseln,
- das Fratricide-Risiko,
- die Belastung des JTAC bei der präzisen Terminal Attack Control.

## 3. Verbindliche Projektregeln

Für **Operation Mountain Watch** gelten auf Basis dieser Quelle folgende Regeln:

1. **Ein aktiver JTAC - ein diskretes Arbeitsnetz.** Zwei gleichzeitig aktive JTACs teilen kein TAD-/Color-Net.
2. **Keine Vermischung mit C2.** ASOC, ABCCC/AWACS, FAC(A), Strike Control, Range Control, Airfield/ATC und sonstige C2-Stellen erhalten eigene Netze, sofern nicht ausdrücklich ein gemeinsames Netz als Teil des Missionsdesigns vorgesehen ist.
3. **AI-/ATC-Slots sind reserviert.** Alle in Abschnitt 6 aufgeführten Color-Net-Slots dürfen nicht für JTAC-, C2-, Package-, AAR- oder sonstige taktische Netze erneut vergeben werden.
4. **Color-Net und Frequenz werden gemeinsam veröffentlicht.** Briefings und Kneeboards nennen mindestens logische Netzbezeichnung, numerische Frequenz, Modulation und Funktion.
5. **Die logische Bezeichnung ist stabil.** Wird eine numerische Frequenz wegen DCS-, Karten- oder Spektrumsänderungen ersetzt, bleibt die Color-Net-Bezeichnung nach Möglichkeit unverändert.
6. **Funkgerätekompatibilität ist vor Zuweisung zu prüfen.** Nicht jedes DCS-Luftfahrzeug kann jede im Gesamtdatensatz enthaltene Frequenz und Modulation nutzen.
7. **Keine automatische Bandannahme allein aus dem Color-Net.** Das Color-Net ist eine logische Kennung; Frequenzbereich und Modulation sind separate Datenfelder.
8. **Jede Vergabe wird zentral registriert.** Ad-hoc-Zuweisungen außerhalb des projektweiten Frequenzregisters sind nicht zulässig.
9. **Frequenzen werden nicht anhand realer historischer Geheimhaltung behauptet.** Der Datensatz ist eine DCS-konforme, quellenbasierte Missionsdesign-Lösung.
10. **Änderungen erhalten eine neue Planversion.** Anpassungen werden mit Quelle, Datum, Grund und betroffenen Slots dokumentiert.

## 4. Technische Kennung und Datenmodell

### 4.1 Gesprochene und technische Kennung

Empfohlene gesprochene Form:

```text
<COLOR> <SLOT>
```

Beispiele: `PEACH 1`, `KHAKI 12`, `TURQUOISE 20`.

Empfohlene technische ID:

```text
CLR_<COLOR>_<NN>
```

Beispiele:

```text
CLR_PEACH_01
CLR_KHAKI_12
CLR_TURQUOISE_20
```

### 4.2 Mindestfelder im zentralen Frequenzregister

| Feld | Bedeutung |
|---|---|
| `net_id` | stabile interne ID, beispielsweise `CLR_PEACH_01` |
| `spoken_name` | gesprochene Bezeichnung, beispielsweise `PEACH 1` |
| `color` | Color-Net-Gruppe |
| `slot` | Slotnummer 1-20 |
| `frequency_mhz` | numerische Frequenz in MHz |
| `modulation` | `AM` oder `FM`; muss explizit festgelegt werden |
| `band_class` | projektseitige technische Klassifikation, beispielsweise VHF-FM, VHF-AM oder UHF-AM |
| `role` | JTAC, FAC(A), ASOC, ATC, Package, AAR, Guard, Admin usw. |
| `owner` | zugewiesene Einheit, Stelle oder dynamische Instanz |
| `area` | Einsatzraum oder Flugplatz |
| `status` | `FREE`, `ALLOCATED`, `RESERVED_AI_ATC`, `BLOCKED`, `RETIRED` |
| `source_version` | hier zunächst `AFG-COLOR-v1.0-2025-10-17` |
| `valid_from` / `valid_to` | Gültigkeitszeitraum der projektseitigen Zuordnung |
| `notes` | Einschränkungen, Funkgerätekompatibilität, Konflikte |

## 5. Datenprüfung der übernommenen Anlage

Die vier Quelltabellen wurden vollständig übernommen und gegen die gerenderten Seiten geprüft. Für Version `v1.0` ergeben sich:

- 20 Color-Net-Gruppen,
- 20 Slots pro Gruppe,
- 400 Einträge,
- 400 unterschiedliche numerische Frequenzen,
- niedrigster Tabellenwert: `37.600 MHz`,
- höchster Tabellenwert: `399.600 MHz`.

Die Eindeutigkeit gilt nur innerhalb dieser Tabellenversion. Sie ersetzt nicht die Kollisionsprüfung gegen missionsspezifische Frequenzen, Guard, Tanker, AWACS, Spieler-Standardpresets, SRS-Konfigurationen oder spätere DCS-Änderungen.

## 6. Reservierte DCS-AI-/Airfield-Frequenzen

Die Anlage weist 14 Flugplatz- beziehungsweise Heliport-Funkstellen mit je drei DCS-AI-Frequenzen aus. Die zugehörigen 42 Color-Net-Slots sind projektweit als `RESERVED_AI_ATC` zu behandeln.

| Flugplatz/Funkstelle | AI UHF | MHz | AI VHF | MHz | AI FM | MHz |
|---|---:|---:|---:|---:|---:|---:|
| Bagram | Lemon 14 | 325.750 | Iron 7 | 120.100 | Khaki 12 | 39.150 |
| Camp Bastion | Teal 11 | 250.100 | Gray 14 | 123.300 | Brass 19 | 38.700 |
| Camp Bastion Heliport | Tan 13 | 250.200 | Cherry 19 | 118.200 | Turquoise 20 | 39.100 |
| Dwyer | Cherry 13 | 343.000 | Brass 10 | 121.750 | Khaki 16 | 38.450 |
| Jalalabad | Peach 1 | 231.000 | Zinc 15 | 129.700 | Cherry 4 | 39.400 |
| Kabul | Coral 7 | 284.250 | Peach 14 | 120.600 | Salmon 17 | 39.300 |
| Kandahar | Carmine 2 | 360.200 | Green 5 | 125.500 | Peach 9 | 38.950 |
| Kandahar Heliport | Purple 19 | 300.200 | Salmon 4 | 119.500 | White 19 | 38.800 |
| Khost | Turquoise 2 | 250.500 | Lemon 19 | 118.400 | Maroon 12 | 39.350 |
| Khost Heliport | Carmine 12 | 250.600 | Carmine 17 | 118.500 | Coral 1 | 39.450 |
| Shindand | Khaki 20 | 265.650 | Lemon 4 | 134.750 | Aqua 3 | 38.500 |
| Shindand Heliport | Turquoise 12 | 344.000 | Tan 11 | 121.500 | Purple 10 | 38.750 |
| Tarin Kowt | Maroon 19 | 250.400 | Gray 10 | 128.000 | White 4 | 39.050 |
| Urgoon | Zinc 6 | 250.250 | Teal 17 | 118.250 | Lemon 2 | 39.200 |

### 6.1 Konsequenz für Jalalabad

Für Jalalabad sind damit fest reserviert:

- `PEACH 1` - `231.000 MHz` - AI UHF,
- `ZINC 15` - `129.700 MHz` - AI VHF,
- `CHERRY 4` - `39.400 MHz` - AI FM.

Diese drei Slots dürfen in den Jalalabad-Testmissionen und im Hauptprojekt nicht als JTAC-, FAC(A)-, ASOC-, Package- oder sonstiges taktisches Arbeitsnetz wiederverwendet werden.

## 7. Vollständiger Color-Net-Frequenzplan

Alle Frequenzen sind in MHz angegeben. Die Tabellen übernehmen die Quellwerte unverändert.

### 7.1 Aqua, Brass, Carmine, Cherry, Coral

| Slot | Aqua | Brass | Carmine | Cherry | Coral |
|---:|---:|---:|---:|---:|---:|
| 1 | 320.000 | 228.400 | 119.100 | 126.800 | 39.450 |
| 2 | 125.100 | 332.400 | 360.200 | 270.500 | 125.800 |
| 3 | 38.500 | 375.700 | 371.300 | 118.700 | 249.100 |
| 4 | 258.300 | 323.300 | 119.800 | 39.400 | 133.800 |
| 5 | 124.900 | 131.300 | 399.100 | 122.500 | 388.700 |
| 6 | 398.100 | 280.000 | 57.200 | 282.900 | 52.500 |
| 7 | 130.600 | 123.700 | 290.300 | 281.000 | 284.250 |
| 8 | 312.300 | 290.800 | 268.700 | 286.000 | 51.700 |
| 9 | 355.700 | 347.100 | 131.700 | 230.700 | 128.600 |
| 10 | 236.400 | 121.750 | 396.000 | 127.100 | 130.500 |
| 11 | 263.000 | 132.500 | 127.700 | 319.200 | 237.500 |
| 12 | 242.900 | 369.700 | 250.600 | 119.900 | 123.100 |
| 13 | 348.600 | 133.200 | 55.300 | 343.000 | 50.000 |
| 14 | 346.500 | 274.200 | 313.200 | 124.100 | 126.600 |
| 15 | 303.200 | 272.600 | 132.300 | 367.100 | 249.700 |
| 16 | 282.500 | 127.000 | 127.300 | 124.700 | 62.200 |
| 17 | 292.700 | 120.500 | 118.500 | 122.900 | 278.700 |
| 18 | 295.000 | 230.500 | 132.900 | 235.200 | 119.600 |
| 19 | 126.500 | 38.700 | 318.000 | 118.200 | 277.700 |
| 20 | 52.900 | 124.800 | 131.800 | 40.800 | 367.600 |

### 7.2 Crimson, Gray, Green, Iron, Khaki

| Slot | Crimson | Gray | Green | Iron | Khaki |
|---:|---:|---:|---:|---:|---:|
| 1 | 119.300 | 43.000 | 366.000 | 124.300 | 129.000 |
| 2 | 122.200 | 287.600 | 121.300 | 131.000 | 342.700 |
| 3 | 128.400 | 373.300 | 54.900 | 133.000 | 299.100 |
| 4 | 48.100 | 342.800 | 121.900 | 37.600 | 129.900 |
| 5 | 130.100 | 260.800 | 125.500 | 129.400 | 132.200 |
| 6 | 366.100 | 251.700 | 300.400 | 347.500 | 237.600 |
| 7 | 120.800 | 295.900 | 376.000 | 120.100 | 131.500 |
| 8 | 355.800 | 130.900 | 301.600 | 123.200 | 343.400 |
| 9 | 124.600 | 62.700 | 268.600 | 246.400 | 121.400 |
| 10 | 384.700 | 128.000 | 124.000 | 387.100 | 320.700 |
| 11 | 126.700 | 121.100 | 128.500 | 123.500 | 127.800 |
| 12 | 237.300 | 48.500 | 339.700 | 374.300 | 39.150 |
| 13 | 118.300 | 299.500 | 372.600 | 368.300 | 45.600 |
| 14 | 321.900 | 123.300 | 125.700 | 285.500 | 386.300 |
| 15 | 252.500 | 119.400 | 273.700 | 343.600 | 325.200 |
| 16 | 253.600 | 67.500 | 315.000 | 396.800 | 38.450 |
| 17 | 118.800 | 251.600 | 121.600 | 354.300 | 131.200 |
| 18 | 333.800 | 365.500 | 130.000 | 351.000 | 132.000 |
| 19 | 126.300 | 230.400 | 385.300 | 121.200 | 127.900 |
| 20 | 267.300 | 121.700 | 129.600 | 396.700 | 265.650 |

### 7.3 Lemon, Maroon, Peach, Purple, Salmon

| Slot | Lemon | Maroon | Peach | Purple | Salmon |
|---:|---:|---:|---:|---:|---:|
| 1 | 348.500 | 128.100 | 231.000 | 126.200 | 263.900 |
| 2 | 39.200 | 345.500 | 308.300 | 250.000 | 236.800 |
| 3 | 131.600 | 243.500 | 125.000 | 120.300 | 53.200 |
| 4 | 134.750 | 300.000 | 327.800 | 238.000 | 119.500 |
| 5 | 353.800 | 399.600 | 123.900 | 120.900 | 256.700 |
| 6 | 120.200 | 57.000 | 331.300 | 261.300 | 120.400 |
| 7 | 131.100 | 275.400 | 120.700 | 324.400 | 305.900 |
| 8 | 133.300 | 297.600 | 127.500 | 125.200 | 379.500 |
| 9 | 129.500 | 124.200 | 38.950 | 234.800 | 314.200 |
| 10 | 243.400 | 376.700 | 225.800 | 38.750 | 274.800 |
| 11 | 321.100 | 289.200 | 123.400 | 274.400 | 119.200 |
| 12 | 350.000 | 39.350 | 126.900 | 133.500 | 335.400 |
| 13 | 304.400 | 242.100 | 272.900 | 132.700 | 384.800 |
| 14 | 325.750 | 303.700 | 120.600 | 321.700 | 344.300 |
| 15 | 229.200 | 240.500 | 118.900 | 304.100 | 288.000 |
| 16 | 132.800 | 302.000 | 238.100 | 133.100 | 133.400 |
| 17 | 340.900 | 319.700 | 133.900 | 271.200 | 39.300 |
| 18 | 251.400 | 60.700 | 385.200 | 240.000 | 123.800 |
| 19 | 118.400 | 250.400 | 226.900 | 300.200 | 273.200 |
| 20 | 381.800 | 338.600 | 127.200 | 332.000 | 127.400 |

### 7.4 Tan, Teal, Turquoise, White, Zinc

| Slot | Tan | Teal | Turquoise | White | Zinc |
|---:|---:|---:|---:|---:|---:|
| 1 | 298.700 | 273.100 | 68.400 | 311.400 | 389.600 |
| 2 | 365.700 | 122.400 | 250.500 | 278.300 | 364.600 |
| 3 | 393.700 | 122.300 | 323.900 | 125.400 | 122.800 |
| 4 | 354.000 | 133.600 | 395.600 | 39.050 | 336.300 |
| 5 | 393.900 | 235.900 | 241.600 | 125.600 | 271.300 |
| 6 | 59.800 | 69.000 | 119.000 | 335.500 | 250.250 |
| 7 | 376.100 | 308.000 | 119.700 | 316.000 | 122.600 |
| 8 | 124.400 | 269.500 | 132.600 | 129.100 | 338.000 |
| 9 | 67.800 | 387.500 | 120.000 | 131.400 | 310.900 |
| 10 | 127.600 | 124.500 | 132.100 | 299.300 | 122.700 |
| 11 | 121.500 | 250.100 | 50.700 | 125.900 | 357.100 |
| 12 | 125.300 | 123.000 | 344.000 | 73.800 | 365.200 |
| 13 | 250.200 | 350.300 | 272.700 | 334.700 | 118.600 |
| 14 | 126.400 | 121.800 | 128.900 | 118.000 | 51.300 |
| 15 | 371.400 | 255.300 | 228.500 | 232.600 | 129.700 |
| 16 | 131.900 | 360.600 | 130.400 | 322.200 | 264.800 |
| 17 | 121.000 | 118.250 | 267.500 | 351.400 | 380.300 |
| 18 | 384.400 | 267.800 | 235.600 | 294.100 | 357.300 |
| 19 | 126.100 | 397.500 | 52.600 | 38.800 | 238.500 |
| 20 | 386.500 | 122.000 | 39.100 | 132.400 | 74.000 |

## 8. Vergabeprozess für Missionen

Vor jeder Vergabe ist folgende Reihenfolge einzuhalten:

1. **Funktion bestimmen:** JTAC, FAC(A), ASOC, Package, AAR, ATC, Guard, Admin oder andere Rolle.
2. **Benötigten Funkbereich und Modulation bestimmen:** anhand der tatsächlich beteiligten DCS-Module und ihrer Funkgeräte.
3. **Reservierungen prüfen:** AI-/ATC-Slots aus Abschnitt 6 sowie bereits missionsweit belegte Netze ausschließen.
4. **Freien Color-Net-Slot auswählen:** bevorzugt aus einem für die Rolle vorgesehenen Pool; keine zufällige globale Vergabe ohne Band- und Kompatibilitätsprüfung.
5. **Netz registrieren:** `net_id`, Frequenz, Modulation, Rolle, Eigentümer, Einsatzraum und Gültigkeit eintragen.
6. **Briefing synchronisieren:** Mission Briefing, Kneeboard, F10-Menüs, SRS-/Radio-Presets und technische Konfiguration müssen dieselbe Zuordnung verwenden.
7. **Laufzeitstabilität sicherstellen:** Ein aktiver JTAC oder C2-Knoten behält sein Netz für seine gesamte Lebensdauer beziehungsweise den gesamten Auftrag.
8. **Freigabe dokumentieren:** Ein Slot wird erst nach Ende oder eindeutigem Abbruch der zugewiesenen Funktion wieder als `FREE` markiert.

## 9. Einbindung in DCS und MOOSE

Die Color-Net-Bezeichnung ist eine projektseitige Metadaten- und Bedienebene. DCS und MOOSE benötigen für die tatsächliche Funkfunktion weiterhin die numerische Frequenz und die korrekte Modulation.

Für eine spätere dynamische Implementierung ist ein zentraler Frequenzmanager vorzusehen, der mindestens:

- AI-/ATC-Reservierungen vorlädt,
- freie Slots nach Frequenzbereich, Modulation und Rolle filtert,
- parallele Doppelvergabe verhindert,
- einer JTAC-/FAC(A)-Instanz einen stabilen Slot zuweist,
- die Zuordnung für Briefing, F10-Menüs, SRS und Logging bereitstellt,
- nach Missionsende oder Persistenz-Recovery den Zustand korrekt wiederherstellt.

Vor Eigenentwicklung ist gemäß der verbindlichen MOOSE-First-Richtlinie zu prüfen, welche vorhandenen MOOSE-Klassen und Methoden Frequenz, Modulation, Callsign, FAC/JTAC, FAC(A), DESIGNATE, AIRBOSS/ATC-nahe Funktionen sowie dynamische Aufgaben bereits abbilden. Eine eigene Vergabelogik darf nur den nicht durch MOOSE abgedeckten Teil ergänzen.

## 10. Pflege und Versionskontrolle

Der Ausgangsbeitrag weist darauf hin, dass der Frequenzplan nach DCS-Theater-Updates oder aufgrund neuer Missionsanforderungen geändert werden kann. Deshalb gilt:

- Die aktuelle Projektversion wird zentral geführt.
- Änderungen an numerischen Frequenzen erfolgen nicht direkt in einzelnen Missionen, sondern zuerst im Frequenzregister.
- Nach DCS-Afghanistan-Updates sind insbesondere die AI-/Airfield-Frequenzen erneut zu prüfen.
- Jede Änderung erhält eine nachvollziehbare Änderungsnotiz mit alter und neuer Zuordnung.
- Missionen müssen ihre verwendete Frequenzplanversion im Briefing oder in der Konfiguration ausweisen.

Empfohlene Versionskennung für den unveränderten Ausgangsdatensatz:

```text
AFG-COLOR-v1.0-2025-10-17
```

## 11. Quellen und Quellenstatus

- Graveyard of Empires: *TAD & Color Nets: Tactical Frequency Presets for Afghanistan Theater*, veröffentlicht am 24. Oktober 2025: <https://www.patreon.com/graveyard4DCS/posts/tad-color-nets-141675991?collection=833534>
- Projektseitig bereitgestellte Anlage: *Afghanistan Theater - Radio Color Preset*, Version `v1.0`, Stand 17. Oktober 2025, fünf Seiten.

### 11.1 Quellenabgrenzung

Der Beitrag erläutert das reale Verfahren und die operative Zweckmäßigkeit codierter TAD-/Color-Netze. Die beigefügte numerische Tabelle ist eine für DCS World erstellte Afghanistan-Theater-Zuordnung. Sie darf nicht als offengelegte reale Afghanistan-Frequenztabelle ausgegeben werden.

## 12. Offene Projektaufgaben

- [ ] Zentrales maschinenlesbares Frequenzregister aus dieser Referenz ableiten.
- [ ] Alle derzeit geplanten JTAC-, FAC(A)-, ASOC-, AWACS-, AAR-, Package- und Admin-Netze inventarisieren.
- [ ] Pro DCS-Fluggerät die nutzbaren Frequenzbereiche, Modulationen und Preset-Grenzen verifizieren.
- [ ] Rollebasierte freie Pools definieren, ohne AI-/ATC-Reservierungen zu verletzen.
- [ ] SRS-, Briefing- und Kneeboard-Ausgabe aus derselben Datenquelle erzeugen.
- [ ] Nach jedem relevanten Afghanistan-Kartenupdate die Airfield-Frequenzen gegen den aktuellen DCS-Stand prüfen.
- [ ] MOOSE-Methoden für Frequenz-/Modulationszuweisung und dynamische JTAC-/FAC(A)-Instanzen versionsbezogen verifizieren.
