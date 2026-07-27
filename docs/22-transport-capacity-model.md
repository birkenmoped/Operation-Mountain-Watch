# 22 – Transportkapazitäten, Cargo Units und Konvoigrößen

## Ziel

Dieses Dokument definiert ein gemeinsames Kapazitätsmodell für Straßenkonvois, Hubschrauber, Außenlasten und C-130J-Transporte. Es trennt technische Plattformgrenzen von konservativen Kampagnen-Standardladungen.

Das Modell soll:

- alle Transportwege mit demselben Manifestmodell vergleichbar machen;
- keine technisch unmöglichen Lasten erlauben;
- dennoch verständliche und balancierbare Logistikaufträge erzeugen;
- Teilverluste einzelner Fahrzeuge oder Frachtpakete abbilden;
- versionsabhängige DCS- und Mod-Funktionen ausdrücklich kennzeichnen.

## Quellen- und Validierungsstatus

Jeder Kapazitätswert besitzt einen Status.

### `MANUFACTURER_CONFIRMED`

Die Eigenschaft oder Zahl ist auf einer offiziellen Eagle-Dynamics-Produktseite oder in einer Primärquelle des Mod-Erstellers bestätigt.

### `WORKING_MANUAL`

Die Angabe stammt aus einer bereitgestellten Arbeitskopie eines Modulhandbuchs, ist aber noch gegen das tatsächlich installierte DCS-Handbuch zu prüfen.

### `CAMPAIGN_STANDARD`

Der Wert ist eine bewusst konservative Balancing- und Missionsplanungsgrenze von Operation Mountain Watch. Er ist keine technische Maximalzuladung.

### `PROVISIONAL`

Der Wert ist ein vorläufiger Projektwert und muss mit der tatsächlich verwendeten DCS- oder Mod-Version getestet werden.

### `REQUIRES_DCS_TEST`

Die Funktion ist grundsätzlich vorgesehen oder plausibel, konkrete Lasttypen, Kombinationen oder Grenzwerte sind aber noch nicht reproduzierbar bestätigt.

## Quellen

### Eagle Dynamics – DCS C-130J

https://www.digitalcombatsimulator.com/de/products/planes/c-130j/

Die offizielle Produktseite bestätigt:

- Transport von Truppen, Fahrzeugen beziehungsweise Panzern, Nachschub und Hilfsgütern;
- realistische Beladung, Frachtverwaltung und Auslieferung;
- gelandete Frachteinsätze;
- Fracht- und Präzisionsabwürfe;
- interaktive Lademeisterposition und Frachtraum;
- eine etwa neun Tonnen schwere MOAB als besondere Last.

Die MOAB-Angabe ist kein Nachweis einer regulären neun Tonnen schweren Standardversorgungslast.

### Eagle Dynamics – DCS CH-47F

https://www.digitalcombatsimulator.com/en/shop/modules/ch-47f/

Die offizielle Produktseite bestätigt:

- mehr als 21.000 lb beziehungsweise ungefähr 9.500 kg Nutzlast als allgemeine Leistungsangabe;
- interne Fracht abhängig von Gewicht und Volumen;
- einpunktige Außenlast im aktuellen Early-Access-Umfang;
- Warehouse-to-Warehouse-Cargotransfer;
- Mehrpunkt-Außenlast als spätere Early-Access-Funktion.

### Eagle Dynamics – DCS UH-1H

https://www.digitalcombatsimulator.com/en/products/helicopters/

Die offizielle Produktseite nennt 4.000 lb beziehungsweise ungefähr 1.814 kg für Waffen und Fracht zusammen. Dieser Wert ist keine garantierte reine Frachtzuladung bei voller Betankung, Bewaffnung, großer Höhe oder hoher Temperatur.

### UH-60L Community Mod

https://www.patreon.com/posts/uh60l-mod-2-0-138859868

Der Ersteller bestätigt für Version 2.0 Cargo-Hauling. Konkrete interne und externe Lastgrenzen werden aus der mitgelieferten Dokumentation und durch Tests der tatsächlich eingesetzten Version ermittelt.

### C-130J-Handbuch-Arbeitskopie

https://de.scribd.com/document/961883035/DCS-C-130J-User-Manual

Die bereitgestellte Arbeitskopie bezeichnet sich als Version 0.8.1 vom 21. November 2025. Sie wird als technische Arbeitsquelle verwendet, bis ihre Angaben gegen das mit dem installierten Modul ausgelieferte Handbuch geprüft wurden.

## Cargo Unit

```text
1 Cargo Unit (CU) = 1.000 kg nominale Transportmasse
```

CU wird in Schritten von `0.25 CU` geführt.

CU ist:

- ein strategisches Planungsmaß;
- eine vereinfachte Vergleichsgröße zwischen Transportwegen;
- die Grundlage für Standardpakete und Missionsbalancing.

CU ist nicht:

- die technische Maximalzuladung einer Plattform;
- ein Ersatz für tatsächliches Gewicht und Volumen;
- eine Garantie, dass ein bestimmtes DCS-Frachtobjekt geladen werden kann;
- eine Erlaubnis, Schwerpunkt-, Start-, Lande- oder Hovergrenzen zu überschreiten.

## Manifestdaten

Jede physische oder abstrakte Fracht enthält mindestens:

```lua
{
  cargoId = "CARGO_FENTY_CONNOLLY_027",
  cargoUnits = 1.25,
  weightKg = 1250,
  volumeClass = "MEDIUM",
  handlingMode = "INTERNAL",
  resourceType = "AMMUNITION",
  vehicleSlots = 0,
  personnelSeats = 0,
  validationStatus = "CAMPAIGN_STANDARD",
}
```

Zusätzliche mögliche Felder:

- `lengthM`, `widthM`, `heightM`;
- `dcsCargoType`;
- `slingClass`;
- `palletType`;
- `airdropClass`;
- `releaseSystem`;
- `fuselageStation`;
- `centerOfGravityContribution`;
- `requiresForklift`;
- `requiresRamp`;
- `requiresRigging`;
- `entityId` bei Fahrzeugtransport.

## Personal und Fahrzeuge

Personal wird nicht ausschließlich als CU geführt.

```text
Personal:
- Sitzplätze
- Teams
- Verwundete oder Tragen
- Spezialistenrollen

Versorgung:
- Masse
- Volumen
- CU
- Handling-Modus

Fahrzeuge:
- stabile Entity-ID
- tatsächliche Transportmasse
- Abmessungen
- Vehicle Slots
- Be- und Entladefähigkeit
```

Ein Fahrzeug bleibt beim Transport eine strategische Entität. Es wird nicht in allgemeine Versorgungspunkte umgewandelt.

## Kapazitätsmatrix

Die folgende Matrix enthält konservative Standardwerte für Kampagnenaufträge.

| Plattform | Interne Fracht | Außenlast | Geladene Lieferung | Luftabwurf | Status |
|---|---:|---:|---:|---:|---|
| UH-1H | 1.0 CU | 1.0 CU | – | – | `CAMPAIGN_STANDARD` |
| UH-60L Community Mod | 2.0 CU | 3.0 CU | – | – | `PROVISIONAL` |
| CH-47F | 5.0 CU | 4.0 CU | – | – | `CAMPAIGN_STANDARD` |
| schwerer Transport-Lkw | 2.0 CU | – | – | – | `CAMPAIGN_STANDARD` |
| C-130J | – | – | 12.0 CU | 8.0 CU | `CAMPAIGN_STANDARD` |

Die C-130J-Werte sind Standardmissionspakete und keine technische Maximalzuladung. Die effektive Zuladung kann geringer oder höher sein, wird für reguläre Kampagnenaufträge aber zunächst durch diese Standardpakete begrenzt.

## Effektive Kapazität

```lua
effectiveCapacityCU = math.min(
  campaignPackageLimitCU,
  weightLimitedCapacityCU,
  volumeLimitedCapacityCU,
  performanceLimitedCapacityCU,
  moduleSupportedCapacityCU
)
```

Für jede Mission gilt die kleinste relevante Grenze.

## Straßenkonvois

### Größenklassen

| Konvoityp | Fahrzeuge | Verwendung |
|---|---:|---|
| leichter Resupply Run | 3–4 | kleiner Posten, dringende Lieferung |
| Standard-CLP | 5–6 | reguläre Versorgung Fenty–Connolly |
| verstärkte CLP | 7–8 | erhöhte Bedrohung oder höheres Frachtvolumen |
| große Bewegung | 9 oder mehr | mehrere physische DCS-Gruppen |

### Verbindliche Gruppengröße

```text
bevorzugte physische DCS-Gruppe: 4–6 Fahrzeuge
harte Obergrenze je DCS-Gruppe:   8 Fahrzeuge
ab 9 Fahrzeugen:                 in mehrere Serials aufteilen
```

Die Obergrenze dient der Routenstabilität und reduziert Probleme mit:

- Kreuzungen und Ortsdurchfahrten;
- engen Kurven;
- Brücken und Engstellen;
- unterschiedlichen Beschleunigungen;
- Aufstauen und Wendemanövern;
- zerstörten oder festgefahrenen Fahrzeugen;
- Ausweichbewegungen unter Beschuss.

### Standardkonvoi Fenty–Connolly

```text
1. Lead-Sicherungsfahrzeug, HMMWV oder MRAP
2. vorderes Sicherungsfahrzeug oder Gun Truck
3. schwerer Transport-Lkw, 2 CU
4. schwerer Transport-Lkw, 2 CU
5. Führungs-, Berge-, Sanitäts- oder Sicherungsfahrzeug
6. rückwärtiges Sicherungsfahrzeug
```

Zulässige reduzierte Variante:

```text
2 Sicherungsfahrzeuge vorn
2 schwere Transport-Lkw
1 Sicherungsfahrzeug hinten
= 5 Fahrzeuge, 4 CU
```

Die Eskorte besitzt standardmäßig keine versteckte Versorgungskapazität. Nur ausdrücklich im Manifest eingetragene Frachtfahrzeuge tragen CU.

### Frachtverteilung und Teilverluste

```lua
convoyManifest = {
  totalCargoUnits = 4,
  allocations = {
    TRUCK_01 = 2,
    TRUCK_02 = 2,
  },
}
```

Wird ein Lkw zerstört, gehen nur dessen zugeordnete CU verloren. Die übrige Fracht kann weitertransportiert oder geborgen werden.

### Mehrere Serials

Eine größere logische Kolonne bleibt eine strategische Mission, wird aber in mehrere physische Gruppen aufgeteilt.

```text
CONVOY_FENTY_CONNOLLY_004
├── SERIAL_ALPHA – 5 Fahrzeuge
└── SERIAL_BRAVO – 5 Fahrzeuge
```

Richtwerte:

- 60–120 Sekunden Startabstand; oder
- ungefähr 500–1.000 Meter Marschabstand;
- getrennte DCS-Gruppen und Controller;
- gemeinsamer strategischer Auftrag und gemeinsames Gesamtmanifest;
- Frachtzuordnung bleibt je Fahrzeug eindeutig.

## Hubschrauber mit interner Fracht

### UH-1H

```text
Standard intern: 1.0 CU
Status: CAMPAIGN_STANDARD
```

Begründung:

- offizielle Gesamtangabe 4.000 lb für Waffen und Fracht zusammen;
- konservative Reserve für Treibstoff, Besatzung, Bewaffnung, Höhe und Temperatur;
- reguläre interne Standardladung von ungefähr 1.000 kg.

Eine spätere Testkonfiguration bis `1.25 CU` ist möglich, wird aber nicht als allgemeiner Standard angeboten.

### UH-60L Community Mod

```text
Standard intern: 2.0 CU
Status: PROVISIONAL
```

Der Wert bleibt vorläufig, bis Version, Dokumentation, Flugleistung, interne Frachtobjekte und Multiplayer-Verhalten geprüft wurden.

### CH-47F

```text
Standard intern: 5.0 CU
Status: CAMPAIGN_STANDARD
```

Dieser Wert liegt deutlich unter der offiziellen allgemeinen Nutzlastangabe und lässt Reserve für afghanische Einsatzbedingungen, Treibstoff, Besatzung und sichere Leistungsgrenzen.

## Hubschrauber-Außenlasten

### Außenlastklassen

| Klasse | CU | Plattformen |
|---|---:|---|
| `SLING_LIGHT` | 0.5 | UH-1H, UH-60L, CH-47F |
| `SLING_STANDARD` | 1.0 | UH-1H, UH-60L, CH-47F |
| `SLING_MEDIUM` | 2.0 | UH-60L, CH-47F |
| `SLING_HEAVY` | 3.0 | UH-60L, CH-47F |
| `SLING_VERY_HEAVY` | 4.0 | CH-47F |

### Plattformgrenzen als Kampagnenstandard

```text
UH-1H:
  maximal regulär 1.0 CU
  Status CAMPAIGN_STANDARD

UH-60L:
  maximal regulär 3.0 CU
  Status PROVISIONAL

CH-47F:
  maximal regulär 4.0 CU
  Status CAMPAIGN_STANDARD
```

Für die CH-47F gilt bis zur bestätigten Mehrpunktfunktion:

- maximal eine aktive Außenlast;
- einpunktige Außenlast;
- maximal `4.0 CU` als reguläres Kampagnenpaket;
- Mehrpunkt-Außenlast nicht Bestandteil des Prototyps.

## C-130J – bestätigter Funktionsumfang

Die offizielle Eagle-Dynamics-Seite bestätigt grundsätzlich:

- Frachtbeladung;
- Frachtverwaltung;
- Transport von Truppen, Fahrzeugen und Versorgung;
- gelandete Auslieferung;
- Luftabwurf und Präzisionsabwurf;
- Lademeisterinteraktion;
- Frachtmanagement als simuliertes System.

Sie nennt keine verbindliche reguläre CU-, Paletten- oder Fahrzeugkapazität für unsere Kampagne.

## C-130J – Arbeitsdaten aus dem Handbuch

Die bereitgestellte Handbuch-Arbeitskopie nennt unter anderem:

| Grenze | Gewicht |
|---|---:|
| maximaler normaler Start | 164.000 lb |
| maximaler alternativer Start | 175.000 lb |
| empfohlene Landemasse | 162.285 lb |
| maximale normale Landung | 164.000 lb |
| maximale alternative Landung | 175.000 lb |
| vollständige interne und externe Treibstoffkapazität | 61.360 lb |

Status: `WORKING_MANUAL`.

Diese Zahlen bestimmen die zulässige Fracht nicht allein. Erforderlich sind zusätzlich:

- Operating Weight;
- Besatzung und Ausrüstung;
- tatsächlicher Treibstoff;
- Startbahn- und Hindernisdaten;
- Bremsenergie;
- Steigleistung;
- Schwerpunkt und Ladeposition;
- Wetter, Höhe und Temperatur.

```text
zulässige Fracht
= zulässige Startmasse
- Betriebsmasse
- Besatzung und Ausrüstung
- Treibstoff
```

## C-130J – Weight and Balance

Das Manifest soll neben CU reale Ladeparameter abbilden.

```lua
{
  cargoId = "CARGO_C130_0031",
  cargoUnits = 2,
  weightKg = 2000,
  fuselageStation = 537,
  deliveryMode = "AIRDROP",
  airdropClass = "CDS",
}
```

Ein C-130J-Auftrag darf nur freigegeben werden, wenn:

- das berechnete Gross Weight innerhalb der zulässigen Grenze liegt;
- der Schwerpunkt zulässig ist;
- das Frachtobjekt in den Frachtraum und das Ladeschema passt;
- der Flugplatzbetrieb die Mission zulässt;
- das Modul die Frachtart technisch unterstützt.

## C-130J – gelandete Lieferung

```text
reguläres Kampagnenpaket: 12.0 CU
Status: CAMPAIGN_STANDARD
```

Der Wert ist ein Balancing-Limit für reguläre Logistikmissionen und kein Nachweis der technischen Maximalzuladung.

Die effektive Kapazität wird bei ungünstiger Startbahn, hoher Temperatur, großer Treibstoffmenge, Schwerpunktproblemen oder nicht unterstützten Lastobjekten reduziert.

## C-130J – Roll-on/Roll-off

Fahrzeugtransport ist auf der offiziellen Produktseite grundsätzlich vorgesehen. Konkrete Fahrzeugtypen und Kombinationen bleiben `REQUIRES_DCS_TEST`.

Ein Roll-on/Roll-off-Manifest verwendet:

```lua
{
  cargoType = "VEHICLE",
  entityId = "ENTITY_BLUE_MRAP_014",
  transportWeightKg = 7200,
  lengthM = 6.0,
  widthM = 2.5,
  heightM = 2.7,
  vehicleSlots = 1,
  validationStatus = "REQUIRES_DCS_TEST",
}
```

Noch nicht verbindlich festgelegt sind:

- konkrete ladbare HMMWV-, MRAP-, Lkw- und Spezialfahrzeugtypen;
- Anzahl je Fahrzeugtyp;
- Kombination mit zusätzlicher Palettenfracht;
- Rampen-, Tür- und Innenraumkollisionen;
- Fahrzeugentladung und Übergabe an CampaignState;
- Fahrzeugabwurf.

Vorläufige RORO-Konfigurationen werden erst nach reproduzierbaren Modultests aktiviert.

## C-130J – Luftabwurf

```text
reguläres Kampagnenpaket: 8.0 CU
Status: CAMPAIGN_STANDARD
```

Die geringere Standardkapazität berücksichtigt:

- Fallschirme und Rigging;
- Plattformen und Verpackung;
- Abwurfabstände;
- Drop-Zone-Größe;
- Drift- und Verlustrisiko;
- zusätzliche DCS-Objekte;
- Teilverluste einzelner Pakete.

### Airdrop-Klassen

Die Handbuch-Arbeitskopie unterscheidet:

- `PER` – Personal;
- `CDS` – Container Delivery System;
- `HE` – Heavy Equipment;
- `BDL_OTHER` – Trainingsbündel oder sonstiges Bündel.

Für `CDS` und `HE` werden als Release-Systeme beschrieben:

- `TOWPLATE`;
- `EXTRACTION_CHUTE`.

Status: `WORKING_MANUAL`.

### Paketaufteilung

Zulässige Standardaufteilungen für 8 CU:

```text
4 × 2 CU
2 × 3 CU + 1 × 2 CU
8 × 1 CU
```

Jedes Paket besitzt eine eigene Cargo-ID.

```lua
{
  flightManifestId = "MANIFEST_C130_0021",
  packages = {
    { id = "CARGO_101", cargoUnits = 2 },
    { id = "CARGO_102", cargoUnits = 2 },
    { id = "CARGO_103", cargoUnits = 2 },
    { id = "CARGO_104", cargoUnits = 2 },
  },
}
```

Nur gültig gelandete Pakete werden gutgeschrieben.

```text
3 von 4 Paketen gültig
→ 6 CU gutgeschrieben
→ 2 CU verloren
```

Fahrzeugabwurf ist nicht Bestandteil des ersten Prototyps.

## Standardäquivalenzen

```text
2 schwere Transport-Lkw
= 4 CU
≈ 1 CH-47F-Außenlast
≈ 2 UH-60L-interne Flüge
≈ 3–4 UH-1H-Flüge
```

```text
1 CH-47F-interner Standardflug
= 5 CU
```

```text
1 C-130J-Standardabwurf
= 8 CU
≈ 2 Standardkonvois
```

```text
1 gelandete C-130J-Standardlieferung
= 12 CU
≈ 3 Standardkonvois
```

Die Äquivalenzen gelten für Kampagnenbalancing und nicht als technische Leistungsbehauptung.

## Verlust- und Gutschriftregeln

- Jede Cargo-ID wird genau einmal gutgeschrieben.
- Jede Fracht wird einem Fahrzeug, Luftfahrzeug oder Abwurfpaket eindeutig zugeordnet.
- Teilverluste reduzieren nur die tatsächlich verlorene Zuordnung.
- Eskorte erzeugt keine Frachtgutschrift.
- Eine Cargo-ID darf nicht gleichzeitig intern, als Außenlast und auf einem Fahrzeug geführt werden.
- Fahrzeugtransport erhält eine Entity-ID und keine reine CU-Umwandlung.
- Abwurfpakete werden einzeln ausgewertet.
- Technische Modulgrenzen überschreiben Kampagnenstandardwerte.

## Testmatrix

### Konvoi

- 5- und 6-Fahrzeug-Standardgruppe auf Fenty–Connolly;
- 8-Fahrzeug-Obergrenze;
- zwei getrennte Serials mit gemeinsamer Mission;
- Verhalten bei zerstörtem Lead-, Cargo- und Schlussfahrzeug;
- Teilverlust eines einzelnen Fracht-Lkw;
- Übergabe von 4 CU an FOB Connolly.

### UH-1H

- 1.0 CU intern;
- 1.0 CU Außenlast;
- Beladung, Flugleistung und Entladung;
- Verlust, Notabwurf und genau einmalige Gutschrift.

### UH-60L

- verwendete Mod-Version und Dokumentation erfassen;
- 2.0 CU intern als vorläufigen Wert prüfen;
- 3.0 CU Außenlast als vorläufigen Wert prüfen;
- Multiplayer- und Mod-Abhängigkeitsfolgen prüfen.

### CH-47F

- 5.0 CU intern;
- 4.0 CU einpunktige Außenlast;
- Gewicht und Volumen gegen native Frachtverwaltung prüfen;
- Warehouse-to-Warehouse-Transfer;
- keine Mehrpunkt-Außenlast im Prototyp.

### C-130J gelandet

- tatsächliches Modulhandbuch gegen Arbeitskopie prüfen;
- Cargo- und Loadmaster-Oberfläche erfassen;
- Weight-and-Balance-Eingaben prüfen;
- 12-CU-Standardpaket in Jalalabad testen;
- Start-, Lande-, Park-, Roll- und Entladeablauf prüfen;
- unterstützte Paletten und Cargo-Objekte katalogisieren;
- RORO-Fahrzeugkatalog ermitteln;
- Warehouse-Übergabe genau einmal ausführen.

### C-130J Airdrop

- `PER`, `CDS`, `HE` und `BDL_OTHER` gegen installierte Version prüfen;
- Release-Systeme und Paketanzahl prüfen;
- 8-CU-Standardpaket testen;
- einzelne Paket-IDs und Teilverluste auswerten;
- stabile Endposition und Drop-Zone-Zugehörigkeit prüfen;
- Fahrzeugabwurf im Prototyp deaktiviert lassen.

## Nicht zulässig

- CU als technische Maximalzuladung darzustellen;
- reale Masse oder Volumenprüfung durch CU zu ersetzen;
- nicht getestete RORO-Fahrzeugkombinationen verbindlich anzubieten;
- UH-60L-Werte ohne Versionsbezug als bestätigt auszugeben;
- die neun Tonnen schwere MOAB als reguläre Versorgungskapazität zu interpretieren;
- mehr als acht Fahrzeuge in einer einzelnen regulären DCS-Konvoigruppe zu planen;
- Frachtverlust pauschal auf die gesamte Mission anzuwenden, wenn einzelne Zuordnungen überleben.
