# 27 – Hubschrauberformationen und AH-64D-Konfiguration im Afghanistan-COIN-Szenario

## 1. Status und Geltungsbereich

Dieses Dokument definiert die projektweite historische und missionsgestalterische Baseline für:

- taktische Formationen von Kampf-, Aufklärungs-, Utility- und Transporthubschraubern,
- die Verwendung einer Vee-Formation,
- die Darstellung des AH-64D mit oder ohne AN/APG-78 Longbow Fire Control Radar (FCR),
- den internen Zusatztank (Internal Auxiliary Fuel System, IAFS beziehungsweise „Robbie Tank“),
- die daraus resultierende 30-mm-Munitionsmenge.

Gültiger Simulationszeitraum:

```text
1. August 2010 bis 20. Mai 2011
```

Primärer Kontext ist ein COIN-Einsatz in Afghanistan mit Gebirge, engen Tälern, hohen Dichtehöhen, Kleinwaffen- und RPG-Bedrohung sowie langen Bereitschafts-, Escort-, Reconnaissance- und Overwatch-Aufträgen.

Dieses Dokument ist für alle Luftoperations-Teilprojekte verbindlich. Lokale Manifeste dürfen strengere Regeln festlegen, aber nicht ohne dokumentierte Begründung von dieser Baseline abweichen.

## 2. Evidenzklassen

Die Aussagen werden in drei Klassen getrennt:

| Klasse | Bedeutung |
|---|---|
| **Doktrin** | Zeitgenössische US-Army-Vorschrift für Formation und Einsatzgrundsätze |
| **Periodenbeleg** | Quelle oder Bild aus beziehungsweise unmittelbar vor dem Missionszeitraum |
| **Projektentscheidung** | Historisch plausible, aber nicht für jedes einzelne Luftfahrzeug tagesgenau belegte Missionsbaseline |

Diese Trennung ist erforderlich, weil öffentlich verfügbare Quellen nicht für jede Staffel, jedes Datum und jede einzelne AH-64D-Zelle den montierten Missionssatz dokumentieren.

## 3. Keine allgemeine Vee-Standardformation

### 3.1 Grundsatz

Eine Vee-Formation ist keine universell empfohlene Standardformation für Hubschrauber im COIN-Einsatz.

Die zeitgenössischen Army-Handbücher für Attack/Reconnaissance- sowie Utility/Cargo-Hubschrauber nennen als grundlegende taktische Flugformationen:

- Combat Cruise,
- Combat Cruise Left/Right,
- Combat Trail,
- Combat Spread.

Die Wahl der Formation richtet sich nach Auftrag, Gegner, Gelände, Wetter, Sicht, Besatzungsausbildung, gegenseitiger Unterstützung und verfügbarem Manöverraum. Eine optisch symmetrische Formation ist daher kein Selbstzweck.

### 3.2 Combat Cruise als Regelfall im COIN-Transit

`Combat Cruise` ist die bevorzugte Ausgangsformation, wenn ein Team:

- schnell verlegen soll,
- sehr niedrig fliegt,
- Gelände zur Maskierung nutzt,
- seine Flugbahn nicht vorhersehbar machen soll,
- mit erheblicher Kleinwaffenbedrohung rechnen muss.

Der Wingman erhält seitlichen Manöverraum und soll nicht dauerhaft exakt in der Flugspur des Lead fliegen. Für Attack/Reconnaissance-Teams beschreibt FM 3-04.126 Combat Cruise ausdrücklich als Standardformation für das Scout Weapons Team (SWT).

### 3.3 Combat Cruise Left/Right

`Combat Cruise Left/Right` ist zweckmäßig, wenn:

- die Seite des Wingman kontrolliert werden muss,
- Beobachtungs- und Feuersektoren zwischen Lead und Wingman aufgeteilt werden,
- Wetter, Sicht oder Nachtsichtbedingungen eine stärker definierte Position erfordern,
- die Bedrohung trotzdem hoch bleibt.

Die optimale Position liegt nach den Handbüchern ungefähr 45 Grad schräg hinter dem Lead; Abstand und Winkel bleiben gelände- und bedrohungsabhängig.

### 3.4 Combat Trail

`Combat Trail` ist für:

- enge Täler,
- begrenzte Korridore,
- restriktive Landezonen,
- Situationen mit höherem Führungsbedarf

geeignet. Es soll nicht ohne Grund über lange Strecken als starre Formation verwendet werden.

### 3.5 Combat Spread

`Combat Spread` ist geeignet, wenn:

- maximale Beobachtung nach vorn erforderlich ist,
- offenes Gelände schnell überquert werden soll,
- die Expositionszeit eines Pakets reduziert werden soll,
- ein Angriff mit überlappender Feuerwirkung vorbereitet wird.

Im stark manöverintensiven Zielgebiet kann Combat Spread dagegen die Arbeitsbelastung erhöhen und ist nicht automatisch die beste Wahl.

### 3.6 Rolle der Vee-Formation

Vee bleibt eine mögliche situationsbezogene Formation, insbesondere:

- im geordneten Anflug mehrerer Transporthubschrauber auf eine ausreichend große Landezone,
- zur schnellen räumlichen Verteilung an oder nach der Landezone,
- in übersichtlichem Gelände bei geringer Bedrohung,
- für administrative oder repräsentative Formationsflüge.

Sie wird **nicht** als projektweite Marsch-, Escort-, Reconnaissance- oder Kampfstandardformation verwendet.

## 4. Verbindliche Formationsbaseline nach Rolle

| Rolle | Projektweiter Regelfall | Situative Alternativen |
|---|---|---|
| AH-64D / OH-58D Two-Ship | Combat Cruise beziehungsweise Combat Cruise Left/Right | Combat Spread für offene Querungen oder Feuereröffnung; Combat Trail in engen Tälern |
| UH-60 / CH-47 Transit | Combat Cruise beziehungsweise gestaffelte Formation | Combat Trail in engem Gelände; Combat Spread bei offenen Gefahrenräumen |
| Air Assault / LZ-Anflug | missions- und LZ-abhängig | Trail, Echelon, Spread oder Vee |
| MEDEVAC Lead + Cover | getrennte Rollen und Flugprofile | Lead zum Landeplatz; Cover in geeigneter Sicherungsposition, keine erzwungene symmetrische Vee |

Die Formation darf während eines Auftrags wechseln. Eine Mission soll nicht von Start bis Landung in einer einzigen starren geometrischen Formation verbleiben, wenn Gelände oder Bedrohung einen Wechsel verlangen.

## 5. DCS- und MOOSE-Umsetzung

### 5.1 MOOSE-First

Vor eigener Formations- oder Abstandslogik ist zu prüfen, welche Funktionen die verwendete MOOSE-Version bereits über `FLIGHTGROUP`, `AUFTRAG`, Routen-, Waypoint-, Task- und Option-Mechanismen bereitstellt.

Eine projektspezifische Nachsteuerung ist erst zulässig, wenn:

1. die relevante MOOSE-Klasse und deren Quellcode geprüft wurden,
2. DCS-AI-Verhalten praktisch getestet wurde,
3. die verbleibende Einschränkung dokumentiert ist.

### 5.2 Simulationsgrenzen

DCS-AI bildet reale taktische Formation, variable Abstände, Geländeausnutzung und reaktive Positionswechsel nur eingeschränkt ab. Daher gilt:

- keine Behauptung, dass eine DCS-Formation reale TTP vollständig reproduziert,
- kein erzwungener optischer Vee-Standard nur wegen einer verfügbaren Editoroption,
- Auswahl der nächstliegenden Formation je Missionsphase,
- Dokumentation sichtbarer Abweichungen im jeweiligen Testbericht.

## 6. AH-64D und Longbow-FCR

### 6.1 AH-64D bedeutet nicht automatisch montiertes FCR

Die Bezeichnung `AH-64D Apache Longbow` ist nicht gleichbedeutend mit einem auf jedem Luftfahrzeug montierten AN/APG-78-Radardom.

Der FCR war ein Missionssatz. Der US-Bestand umfasste wesentlich mehr AH-64D-Luftfahrzeuge als FCR-Kits. Der Congressional Budget Office beschrieb eine Planung von 666 AH-64D bei 227 FCR-Kits. Ein FCR-ausgerüsteter AH-64D konnte Sensordaten beziehungsweise Longbow-Hellfire-Fähigkeiten innerhalb des Teams unterstützen, während andere AH-64D ohne montiertes Radar flogen.

Damit ist eine gemischte oder überwiegend non-FCR dargestellte Staffel historisch plausibel. Eine vollständige FCR-Ausstattung aller acht Jalalabad-AH-64D wäre ohne konkreten Einheitsnachweis nicht anzunehmen.

### 6.2 Nutzen und Grenzen im Afghanistan-Szenario

Der FCR wurde primär für:

- schnelle großräumige Zielsuche,
- Zielklassifizierung,
- Einsatz bei Wetter, Staub und Sichtbehinderung,
- Bekämpfung höherwertiger mechanisierter Ziele,
- bestimmte Luftabwehr- und Longbow-Hellfire-Szenarien

entwickelt.

Im Afghanistan-COIN-Einsatz gegen kleine, häufig abgesessene und räumlich verteilte Gegner blieb er verwendbar, war aber nicht für jeden Auftrag der entscheidende Sensor. Gewicht, Luftwiderstand, Temperatur, Höhe, Ausdauer und das konkrete Zielbild konnten gegen einen montierten FCR sprechen.

Offizielle DVIDS-Aufnahmen aus Tirin Kot vom 14. Oktober 2010 dokumentieren AH-64D-Einsätze im Missionszeitraum. Bei der Auswertung einzelner Bilder ist zwischen der Typbezeichnung in der Bildunterschrift und dem tatsächlich sichtbaren Radardom zu unterscheiden.

### 6.3 Projektentscheidung

Für Operation Mountain Watch gilt:

```text
Standarddarstellung AH-64D im COIN-Einsatz:
- non-FCR bevorzugt
- FCR nicht auf jedem Luftfahrzeug
- FCR-ausgerüstete Einzelmaschinen oder Pakete bleiben missionsabhängig zulässig
```

Es wird **nicht** behauptet, dass während des gesamten Zeitraums jede AH-64D der B Company, 1-10 Aviation ohne FCR flog. Der öffentlich belegbare Detailgrad reicht dafür nicht aus.

## 7. Interner Zusatztank und 30-mm-Munition

### 7.1 Technischer Zusammenhang

Der interne Zusatztank ersetzt einen großen Teil des normalen Munitionsmagazins.

```text
ohne IAFS / Robbie Tank: bis zu 1.200 Schuss 30 mm
mit IAFS / Robbie Tank:  ungefähr 100 US-Gallonen Zusatzkraftstoff und 300 Schuss 30 mm
```

Die verringerte Munitionsmenge entsteht durch den Einbau des Tanks, nicht durch das Entfernen des FCR.

### 7.2 Periodenbeleg 2010

Der `101st Airborne Division (Air Assault) Gold Book` vom 12. April 2010 nennt für den AH-64D:

- 375 US-Gallonen reguläre Kraftstoffkapazität,
- zusätzlich 100 US-Gallonen Robbie Tank,
- 110 NM Aktionsradius ohne internen Zusatztank,
- 185 NM Aktionsradius mit internem Zusatztank,
- 300 Schuss 30-mm-Munition.

Der Gold Book ist keine formale Army-Doktrin, sondern eine divisionsspezifische TTP- und Planungshilfe. Für unseren Zeitraum und die 101st Combat Aviation Brigade ist er dennoch ein starker Periodenbeleg.

### 7.3 Projektentscheidung

Für lange COIN-Aufträge mit Escort, Armed Reconnaissance, Overwatch oder Bereitschaft gilt als Standardbaseline:

```text
IAFS / Robbie Tank: installiert
30-mm-Munition: 300 Schuss
```

Eine Konfiguration ohne internen Zusatztank und mit höherer 30-mm-Munitionsmenge bleibt zulässig für:

- kurze, feuerkraftintensive Einsätze,
- geringe Entfernung zur FARP,
- ausdrücklich geplante hohe Kanonenverwendung,
- Test- oder Sondermissionen.

Die Missionsplanung muss die gewählte Konfiguration sichtbar dokumentieren; sie darf nicht stillschweigend zwischen Templates wechseln.

## 8. Verbindliche AH-64D-Baseline für Jalalabad

Für `SQ_US_JBAD_AH64D_B_1_10_AVN` gilt:

```text
Paketgröße:           grundsätzlich Two-Ship
Marschformation:      Combat Cruise / Combat Cruise Left/Right
enge Täler:           Combat Trail zulässig
offene Gefahrenräume: Combat Spread zulässig
Vee:                  keine taktische Standardformation
FCR:                  standardmäßig nicht auf jeder Maschine; missionsabhängige Ausnahme
IAFS:                 standardmäßig installiert
30-mm-Munition:       standardmäßig 300 Schuss
```

Wo DCS oder das verwendete AI-Asset einzelne Konfigurationsmerkmale nicht getrennt abbilden kann, wird die nächstliegende Darstellung verwendet und die Einschränkung im jeweiligen Test dokumentiert.

## 9. Auswirkungen auf bestehende und künftige Tests

Die bereits akzeptierte Jalalabad-Grundbaseline wird dadurch nicht rückwirkend ungültig. Der Abschlusslauf validierte Bestand, Templates, Parking, Warehouse, AIRWING- und COMMANDER-Start, aber keine taktische Flugmission.

Künftige AUFTRAG-, Escort-, Reconnaissance-, OPSTRANSPORT- und MEDEVAC-Tests müssen zusätzlich prüfen:

- gewählte Formation je Missionsphase,
- Verhalten in engem und offenem Gelände,
- Vermeidung einer starren Vee als allgemeiner Standard,
- AH-64D-FCR-Darstellung,
- IAFS-/Munitionskonfiguration,
- Abweichungen aufgrund von DCS- oder MOOSE-Limits.

## 10. Quellen

### US-Army-Doktrin

- Headquarters, Department of the Army: **FM 3-04.126, Attack Reconnaissance Helicopter Operations**, 16 February 2007, insbesondere Kapitel 3, Absätze 3-11 bis 3-15. Öffentliche Kopie: <https://studylib.net/doc/10712674/fm-3-04.126-attack-reconnaissance-helicopter-operations-h...>
- Headquarters, Department of the Army: **FM 3-04.113, Utility and Cargo Helicopter Operations**, 7 December 2007, insbesondere Kapitel 3, Absätze 3-3 bis 3-14. Öffentliche Kopie: <https://studylib.net/doc/10712672/fm-3-04.113-utility-and-cargo-helicopter-operations-headq...>

### AH-64D, FCR und Periodenbelege

- Congressional Budget Office: **Existing and Planned Helicopters in the Army’s Fleet**; 666 geplante AH-64D und 227 FCR-Kits: <https://www.cbo.gov/sites/default/files/cbofiles/ftpdocs/88xx/doc8865/chapter1.5.1.shtml>
- U.S. Army Acquisition Support Center, Army AL&T, October–December 2010: **Apache Longbow Leverages Capabilities**: <https://asc.army.mil/armyalt/OctDec2010/html/43.html> und <https://asc.army.mil/armyalt/OctDec2010/html/44.html>
- Defense Visual Information Distribution Service, AH-64D in Tirin Kot, Afghanistan, 14 October 2010: <https://www.dvidshub.net/image/1493382/ah-64d-apache-longbow-afghanistan> und <https://www.dvidshub.net/image/1493409/ah-64d-apache-longbow-afghanistan>
- Headquarters, 101st Airborne Division (Air Assault): **2010 Gold Book**, 12 April 2010, AH-64D planning data. Öffentlich zugängliche Kopie: <https://www.scribd.com/doc/35884930/101st-Div-Gold-Book-2010>

### DCS-Abbildung

- Eagle Dynamics: **DCS: AH-64D Manual / Quick Start Manual**: <https://www.digitalcombatsimulator.com/en/downloads/documentation/dcs-ah64d_manual_de/>

## 11. Evidenzbewertung

| Aussage | Bewertung |
|---|---|
| Combat Cruise ist für sehr niedrigen Flug, Terrainmaskierung und erhebliche Kleinwaffenbedrohung bevorzugt | **hoch / Doktrin** |
| Vee ist keine universelle taktische Standardformation | **hoch / aus Doktrin und Formationsauswahl ableitbar** |
| AH-64D konnte mit oder ohne FCR betrieben werden | **hoch** |
| Nicht jede AH-64D der US Army verfügte gleichzeitig über ein FCR-Kit | **hoch** |
| IAFS reduziert die 30-mm-Kapazität auf 300 Schuss und liefert ungefähr 100 US-Gallonen Zusatzkraftstoff | **hoch** |
| IAFS + 300 Schuss ist für die 101st im Jahr 2010 als Planungswert belegt | **hoch / Periodenbeleg** |
| Alle acht Jalalabad-AH-64D flogen während des gesamten Zeitraums ohne FCR und mit IAFS | **nicht belegt** |
| non-FCR + IAFS + 300 Schuss ist die Standarddarstellung für unser COIN-Szenario | **verbindliche Projektentscheidung, historisch plausibel** |
