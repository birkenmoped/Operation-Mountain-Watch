# 05 – Logistik

## Ziel

Logistik soll spielerisch relevant sein, ohne die Kampagne durch Mikromanagement zu dominieren. Hauptbasen besitzen große strategische Reserven; FOBs sind lokal begrenzt und müssen versorgt, verstärkt und gegebenenfalls neu aufgebaut werden.

## Transportarten

Die Kampagne unterscheidet fünf reguläre Lieferverfahren sowie eine automatische Rückfallebene:

1. Straßenkonvoi
2. Hubschraubertransport mit interner Fracht
3. Hubschraubertransport mit Außenlast
4. Transportflugzeug mit Landung und Entladung
5. Transportflugzeug mit Luftabwurf
6. automatische AI-Notversorgung als begrenzte Rückfallebene

Straße, interne Drehflüglerfracht, Außenlast, gelandeter Lufttransport und Luftabwurf sind gleichwertige logistische Werkzeuge mit unterschiedlichen Voraussetzungen, Risiken und Kapazitäten. Kein Verfahren ersetzt grundsätzlich die anderen.

## Gemeinsames Manifestmodell

Jede Lieferung besitzt unabhängig vom Transportweg eine eindeutige Cargo-ID und ein Manifest. Das Manifest beschreibt Ressourcenart, Menge, Gewicht, Volumen, Herkunft, Ziel und aktuellen Status.

Mögliche Statuswerte:

- `AVAILABLE`
- `LOADING`
- `INTERNAL`
- `SLING`
- `IN_TRANSIT`
- `DELIVERED`
- `LOST`
- `DESTROYED`

Eine Cargo-ID darf genau einmal einem Zielbestand gutgeschrieben werden. Ein Wechsel zwischen interner Fracht, Außenlast, Zwischenlager und Weitertransport erzeugt keine neue Ressource.

## Cargo Units

Operation Mountain Watch verwendet Cargo Units als strategisches Planungsmaß:

```text
1 CU = 1.000 kg nominale Transportmasse
```

CU wird in Schritten von `0.25 CU` geführt. CU ersetzt weder tatsächliches Gewicht und Volumen noch technische DCS-Grenzen.

Jedes Manifest führt mindestens:

```lua
{
  cargoId = "CARGO_FENTY_CONNOLLY_027",
  cargoUnits = 1.25,
  weightKg = 1250,
  volumeClass = "MEDIUM",
  handlingMode = "INTERNAL",
  resourceType = "AMMUNITION",
  vehicleSlots = 0,
  validationStatus = "CAMPAIGN_STANDARD",
}
```

Personal wird über Sitzplätze, Teams und Spezialistenrollen geführt. Fahrzeuge bleiben strategische Entities mit realer Transportmasse, Abmessungen und Vehicle Slots.

Die vollständigen Kapazitäts-, Status- und Testregeln stehen in `docs/22-transport-capacity-model.md` und ADR 0008.

## Kampagnen-Standardkapazitäten

| Plattform | Interne Fracht | Außenlast | Geladene Lieferung | Luftabwurf |
|---|---:|---:|---:|---:|
| UH-1H | 1 CU | 1 CU | – | – |
| UH-60L Community Mod | 2 CU, vorläufig | 3 CU, vorläufig | – | – |
| CH-47F | 5 CU | 4 CU | – | – |
| schwerer Transport-Lkw | 2 CU | – | – | – |
| C-130J | – | – | 12 CU | 8 CU |

Diese Werte sind konservative Standardmissionspakete und keine technischen Maximalzuladungen.

Die effektive Kapazität wird durch die kleinste relevante Grenze bestimmt:

```lua
effectiveCapacityCU = math.min(
  campaignPackageLimitCU,
  weightLimitedCapacityCU,
  volumeLimitedCapacityCU,
  performanceLimitedCapacityCU,
  moduleSupportedCapacityCU
)
```

## Hybride Warehouse-Architektur

`CampaignState` bleibt die persistente Quelle der Wahrheit. Native DCS-Warehouses werden an dauerhaften, spielerrelevanten Logistikknoten eingesetzt und über einen `WarehouseAdapter` synchronisiert.

Für den Prototyp gilt:

- Jalalabad/FOB Fenty besitzt eine native Warehouse-Anbindung;
- FOB Connolly besitzt eine native Warehouse-Anbindung oder einen getesteten, als Warehouse nutzbaren Depotknoten;
- Bagram und Kabul bleiben zunächst strategisch abstrahiert und erhalten bei physischer Nutzung eine native Anbindung;
- der afghanische Checkpoint besitzt nur einen abstrakten lokalen Bestand;
- temporäre Landezonen und Drop Zones sind keine eigenen Warehouses;
- rote Camps und Hide Sites besitzen keine blauen DCS-Warehouses.

Native Warehouses bilden nur Ressourcen ab, die DCS tatsächlich verwalten und verbrauchen kann, zum Beispiel Flugzeuge, Waffen, Treibstoffe und geeignete Cargo-Inhalte. Personal, Ingenieurkapazität, Baumaterial, medizinische Kapazität, Intelligence und Moral bleiben strategische Ressourcen.

## Warehouse-Transaktionen

Jede Bestandsänderung an einem nativen Warehouse erhält eine stabile Transaktions-ID.

Ablauf einer Lieferung:

```text
Fracht validieren
→ Transaktion anlegen
→ CampaignState gutschreiben
→ unterstützte native Warehouse-Bestände aktualisieren
→ Bestände zurücklesen
→ Transaktion abschließen
```

Direkter Verbrauch durch Spieler oder AI wird vom `WarehouseAdapter` erkannt und anschließend im `CampaignState` belastet. Unbekannte Differenzen werden als `RECONCILE_REQUIRED` markiert und nicht stillschweigend übernommen.

Der `LogisticsManager` kennt keine internen DCS-Itemnamen und greift nicht direkt auf MOOSE `STORAGE` zu.

## Warehouse- und Übergabezonen

Die physische Lieferung wird über explizite Zonen erkannt. Räumliche Nähe zu einem Depotobjekt allein genügt nicht.

Jalalabad/Fenty benötigt mindestens:

- `ZONE_FENTY_WAREHOUSE`
- `ZONE_FENTY_INTERNAL_UNLOAD`
- `ZONE_FENTY_SLING_DROP`
- `ZONE_FENTY_C130_UNLOAD`
- `ZONE_FENTY_VEHICLE_DELIVERY`

FOB Connolly benötigt mindestens:

- `ZONE_CONNOLLY_WAREHOUSE`
- `ZONE_CONNOLLY_INTERNAL_UNLOAD`
- `ZONE_CONNOLLY_SLING_DROP`
- `ZONE_CONNOLLY_VEHICLE_DELIVERY`
- `ZONE_CONNOLLY_LZ`

Eine Zone kann mehrere physische Darstellungen enthalten, besitzt aber nur eine klar definierte Übergaberegel je Transportmodus.

## Straßenkonvoi

Straßenkonvois transportieren Personal, Munition, Treibstoff, Baumaterial und Fahrzeuge zwischen straßengebundenen Basen. Sie sind langsam, planbar und anfällig für IEDs, RPGs und Hinterhalte.

Entfernte, unbegleitete Konvois dürfen virtualisiert werden. Bei Spielereskorte, Feindkontakt, Annäherung an ein Ziel oder einen Hinterhalt bleiben sie physisch.

### Physische Gruppengröße

```text
bevorzugte DCS-Gruppengröße: 4–6 Fahrzeuge
harte Obergrenze:            8 Fahrzeuge
ab 9 Fahrzeugen:             mehrere getrennte Serials
```

Größere logische Konvois bleiben ein strategischer Auftrag, werden aber in mehrere physische DCS-Gruppen mit getrennten Controllern aufgeteilt.

Richtwerte für Serials:

- 60–120 Sekunden Startabstand; oder
- ungefähr 500–1.000 Meter Marschabstand;
- gemeinsame strategische Mission;
- eindeutige Frachtzuordnung je Fahrzeug.

### Standardkonvoi Fenty–Connolly

```text
1 Lead-Sicherungsfahrzeug
1 vorderes Sicherungsfahrzeug oder Gun Truck
2 schwere Transport-Lkw mit je 2 CU
1 Führungs-, Berge-, Sanitäts- oder Sicherungsfahrzeug
1 rückwärtiges Sicherungsfahrzeug
```

Der Standardkonvoi besteht damit aus fünf bis sechs Fahrzeugen und transportiert regulär 4 CU.

Die Eskorte trägt standardmäßig keine versteckte Fracht. Nur ausdrücklich im Manifest eingetragene Fahrzeuge besitzen CU.

```lua
convoyManifest = {
  totalCargoUnits = 4,
  allocations = {
    TRUCK_01 = 2,
    TRUCK_02 = 2,
  },
}
```

Wird ein Fracht-Lkw zerstört, gehen nur dessen zugeordnete CU verloren.

Am Ziel wird das Manifest in der Fahrzeug-Übergabezone validiert. Erst danach wird eine Warehouse-Transaktion erzeugt.

## Hubschraubertransport mit interner Fracht

Interne Fracht wird im Laderaum transportiert. Dazu zählen je nach Plattform und technischer Integration:

- Kisten und Behälter
- Paletten oder palletisierte Versorgungsgüter
- Munition, Treibstoff und Baumaterial als Manifest
- Personal, Ingenieurgruppen und Verwundete

Die Kampagnenlogik prüft:

1. Die Fracht ist an einer gültigen Ladezone verfügbar.
2. Gewicht und Volumen liegen innerhalb des Plattformprofils.
3. Die Cargo-ID wird dem Luftfahrzeug zugeordnet.
4. Das Luftfahrzeug erreicht eine gültige Entlade- oder Übergabezone.
5. Die Cargo-ID wird genau einmal an das Ziel übergeben.

Interne Fracht kann nativ durch das DCS-Modul, über MOOSE CTLD oder durch einen projektspezifischen Adapter repräsentiert werden. Der strategische Zustand bleibt davon unabhängig.

## Hubschraubertransport mit Außenlast

Außenlasten werden als physische Frachtobjekte am Lasthaken transportiert. Dieser Pfad ist technisch von interner Fracht getrennt.

Die Kampagnenlogik berücksichtigt:

- Aufnahme an einer gültigen Außenlastzone
- erfolgreichen Hook- oder Sling-Zustand
- Gewichtslimit der Plattform
- Verlust, Zerstörung oder Notabwurf
- Ablage innerhalb einer gültigen Absetzzone
- stabile Endposition vor der Ressourcengutschrift

Eine zuvor intern transportierte Fracht darf nur über einen expliziten Umschlagprozess zur Außenlast werden. Dieselbe Cargo-ID darf nicht gleichzeitig intern und extern geführt werden.

### Außenlastklassen

| Klasse | CU | Plattformen |
|---|---:|---|
| `SLING_LIGHT` | 0.5 | UH-1H, UH-60L, CH-47F |
| `SLING_STANDARD` | 1.0 | UH-1H, UH-60L, CH-47F |
| `SLING_MEDIUM` | 2.0 | UH-60L, CH-47F |
| `SLING_HEAVY` | 3.0 | UH-60L, CH-47F |
| `SLING_VERY_HEAVY` | 4.0 | CH-47F |

## Hubschrauberplattformen

### CH-47F

Die CH-47F ist die primäre schwere taktische Transportplattform.

```text
intern:    5 CU
Außenlast: 4 CU
Status:    CAMPAIGN_STANDARD
```

Getrennt unterstützt und getestet werden:

- interne Kisten und Paletten
- Truppentransport
- interne Frachtentladung
- einpunktige Außenlast
- Warehouse-to-Warehouse-Transfer

Mehrpunkt-Außenlast gehört nicht zum Prototyp und wird erst aktiviert, wenn sie im verwendeten DCS-Stand verfügbar und getestet ist.

### UH-1H

Die UH-1H ist die leichte Transportplattform.

```text
intern:    1 CU
Außenlast: 1 CU
Status:    CAMPAIGN_STANDARD
```

Die genaue technische Schnittstelle für interne Fracht und Außenlast wird gegen die installierte DCS- und MOOSE-Version geprüft.

### UH-60L Community Mod

Der UH-60L Community Mod ist eine optionale Plattform für interne Fracht, Außenlast, Transport, MEDEVAC und Verbindung. Er wird nicht zur verpflichtenden Projekt- oder Serverabhängigkeit.

```text
intern:    2 CU
Außenlast: 3 CU
Status:    PROVISIONAL
```

Die Werte bleiben versionsbezogen und werden gegen die tatsächlich verwendete Mod-Dokumentation und Testmission geprüft.

## C-130J mit Landung

Die C-130J kann geeignete Flugplätze und größere operative Basen direkt versorgen. Die vorgesehene Lieferkette lautet:

1. Fracht an einer strategischen oder regionalen Basis laden.
2. Flug zum Zielairfield durchführen.
3. sicher landen und einen definierten Entlade- oder Lagerbereich erreichen.
4. Fracht entladen beziehungsweise an das lokale Lager übergeben.
5. Manifest genau einmal dem Zielbestand gutschreiben.

Dieses Verfahren ist nur für Ziele mit geeigneter Start- und Landebahn, Rollwegen, Parkpositionen und Entladefläche zulässig. Jalalabad Airfield / FOB Fenty ist im Kernoperationsraum die wichtigste Ausnahme gegenüber reinen FOBs. Bagram und Kabul sind grundsätzlich weitere strategische Knoten.

Die C-130J-Entladung wird über `ZONE_FENTY_C130_UNLOAD` erkannt. Der WarehouseAdapter führt anschließend die strategische und, soweit unterstützt, native Buchung aus.

### Standardpaket

```text
gelandete Standardlieferung: 12 CU
Status: CAMPAIGN_STANDARD
```

Dieser Wert ist keine technische Maximalzuladung. Weight and Balance, Start- und Landegrenzen, Treibstoff, Schwerpunkt, Volumen und Modulunterstützung bleiben maßgeblich.

### Roll-on/Roll-off

Fahrzeugtransport ist grundsätzlich vorgesehen. Konkrete DCS-Fahrzeugtypen, Anzahl je Typ und Kombinationen mit Zusatzfracht bleiben `REQUIRES_DCS_TEST`.

Fahrzeuge behalten ihre strategische Entity-ID und werden nicht in allgemeine CU umgewandelt.

## C-130J-Luftabwurf

Luftabwurf versorgt Ziele ohne geeignete Landebahn oder bei gesperrten Straßen- und Landezonen. DCS simuliert den physischen Abwurf.

```text
reguläres Standardpaket: 8 CU
Status: CAMPAIGN_STANDARD
```

Die Kampagnenlogik bewertet:

1. Das einzelne Frachtobjekt ist stabil gelandet.
2. Seine Endposition liegt innerhalb der definierten Drop Zone.
3. Die Cargo-ID wurde noch nicht gutgeschrieben.

Bei Erfolg wird nur das gültige Einzelpaket dem Zielbestand gutgeschrieben. Abwurfhöhe, Geschwindigkeit, Fallschirm und Drift werden nicht doppelt simuliert.

Die Handbuch-Arbeitskopie unterscheidet:

- `PER`
- `CDS`
- `HE`
- `BDL_OTHER`

Für `CDS` und `HE` werden `TOWPLATE` und `EXTRACTION_CHUTE` als Release-Systeme geführt. Diese Angaben bleiben `WORKING_MANUAL`, bis sie gegen das installierte Modulhandbuch geprüft sind.

Standardaufteilungen für 8 CU:

```text
4 × 2 CU
2 × 3 CU + 1 × 2 CU
8 × 1 CU
```

Eine Drop Zone ist kein Warehouse. Die gültige Fracht wird dem zugeordneten Warehouse-Knoten oder abstrakten lokalen Lager gutgeschrieben.

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
1 C-130J-Standardabwurf
= 8 CU
≈ 2 Standardkonvois
```

```text
1 gelandete C-130J-Standardlieferung
= 12 CU
≈ 3 Standardkonvois
```

Diese Äquivalenzen gelten nur für Kampagnenbalancing.

## Hybride Steuerung

Normale Versorgung wird über Spielerauftrag oder F10-Menü angefordert. Automatische Maßnahmen greifen nur bei kritischem Mindestbestand, aktivem Großangriff oder längerer Abwesenheit geeigneter Logistikspieler.

Der Dispatcher berücksichtigt:

- verfügbare Plattformen
- Cargo Units, reales Gewicht und Volumen
- Zielinfrastruktur
- Warehouse-Modus und Capabilities
- Bedrohungslage
- Wetter und Tageszeit
- Dringlichkeit
- verfügbare Eskorte
- Straßen-, Lande-, Absetz- und Drop-Zone-Status
- Plattform- und Versionsstatus

## FOB-Wiederaufbau

Ein zerstörter FOB wird stufenweise aufgebaut:

1. Standort sichern.
2. Baucontainer und Ingenieurgruppe liefern.
3. minimale Infrastruktur erzeugen.
4. Personal, Munition, Treibstoff und Fahrzeuge separat zuführen.
5. Warehouse- oder abstrakten Lagerbetrieb wiederherstellen.
6. volle Einsatzbereitschaft herstellen.

Die Lieferungen können je nach Ziel und Lage per Konvoi, interner Hubschrauberfracht, Außenlast oder Luftabwurf erfolgen. Ein gelandeter C-130J-Transport ist nur an dafür geeigneten Airfields oder großen Basen möglich.

Die Zerstörung eines sichtbaren Depotobjekts vernichtet nicht automatisch den vollständigen strategischen Bestand. Die Wirkung hängt von Depotklasse, Schadensmodell und CampaignState-Regeln ab.

## Noch zu entscheiden und zu testen

- genaue Kapazitäten der FOB-Klassen
- konkrete Cargo-Manifeste, Kistentypen und Palettenmodelle
- 5-, 6- und 8-Fahrzeug-Konvois auf der Route Fenty–Connolly
- mehrere Konvoi-Serials mit gemeinsamem strategischem Auftrag
- CH-47F: 5 CU intern, 4 CU einpunktige Außenlast und Warehouse-Transfer
- UH-1H: 1 CU intern und 1 CU Außenlast über die tatsächlich verfügbaren Pfade
- UH-60L-Mod: 2 CU intern und 3 CU Außenlast gegen die verwendete Version
- Umschlag zwischen Lager, interner Fracht und Außenlast
- Regeln für verlorene, zerstörte oder außerhalb der Absetzzone gelandete Fracht
- C-130J: tatsächliches Modulhandbuch, Weight and Balance und 12-CU-Standardlieferung
- C-130J: 8-CU-Abwurf, Paketklassen und Teilverluste
- C-130J: unterstützte RORO-Fahrzeuge und Fahrzeugkombinationen
- native Warehouse-Sichtbarkeit für Spieler je Warehouse-Typ
- konkrete DCS-Itemnamen und Ressourcen-Mappings
- Erkennung von Spieler- und AI-Verbrauch
- Reconciliation bei Abweichungen und Spielerbeitritt
- Verhalten bei zerstörtem oder fehlendem Depotobjekt
- Umfang automatischer AI-Nachversorgung
