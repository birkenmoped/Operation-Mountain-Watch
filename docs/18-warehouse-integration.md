# 18 – Warehouse-Integration

## Ziel

Die Kampagne kombiniert den persistenten `CampaignState` mit nativen DCS-Warehouses. Spieler sollen an wichtigen Logistikknoten reale Bestände sehen und nutzen können, ohne dass jeder kleine Posten ein vollständiges Warehouse benötigt oder die Kampagnenlogik von DCS-internen Itemnamen abhängig wird.

## Verbindlicher Grundsatz

`CampaignState` bleibt die autoritative und persistente Quelle für strategische Ressourcen. Native DCS-Warehouses sind die operative Repräsentation ausgewählter, direkt von DCS verbrauchbarer Bestände.

Das bedeutet:

- strategische Entscheidungen und Persistenz basieren auf `CampaignState`;
- DCS-Warehouses bilden Flugzeuge, Waffen, Treibstoffe und geeignete Cargo-Inhalte ab;
- ein `WarehouseAdapter` synchronisiert beide Ebenen;
- keine Ressource wird allein deshalb strategisch erzeugt oder gelöscht, weil eine DCS- oder MOOSE-Repräsentation neu aufgebaut wird;
- jede Bestandsänderung erhält eine nachvollziehbare Transaktion.

## Warehouse-Klassen

### Strategisches Warehouse

Verwendung für große, dauerhaft relevante Basen:

- Bagram Airfield
- Kabul
- Jalalabad Airfield / FOB Fenty

Eigenschaften:

- große Kapazitäten;
- Flugzeuge und Luftfahrzeugbewaffnung;
- Jet Fuel und weitere native Flüssigkeiten;
- Empfang strategischer Lufttransporte;
- Quelle regionaler Lieferungen;
- grundsätzlich spielerrelevant.

Bagram und Kabul dürfen im ersten Prototyp zunächst strategisch abstrahiert bleiben. Sobald sie physisch und spielerisch genutzt werden, erhalten sie eine native Warehouse-Anbindung.

### FOB-Warehouse

Verwendung für permanente, spielerrelevante Außenposten mit regelmäßigem Logistikverkehr.

FOB Connolly erhält im ersten Prototyp ein natives DCS-Warehouse beziehungsweise ein als Warehouse nutzbares Depotobjekt. Der Standort wird zusätzlich im `CampaignState` geführt.

Eigenschaften:

- begrenzte Kapazitäten;
- keine automatisch unbegrenzten Bestände;
- Empfang von Konvois, interner Hubschrauberfracht, Außenlasten und gegebenenfalls Luftabwürfen;
- lokale Versorgung von Garnison, AI und Spielern;
- sichtbarer oder anderweitig abfragbarer operativer Bestand, soweit DCS dies für den konkreten Warehouse-Typ unterstützt.

### Abstraktes lokales Lager

Verwendung für:

- kleine COPs;
- Beobachtungsposten;
- afghanische Checkpoints;
- temporäre Patrouillenbasen;
- temporäre Landezonen;
- kurzfristige Missionsziele.

Diese Standorte erhalten kein eigenes natives DCS-Warehouse. Ihre Bestände werden ausschließlich im `CampaignState` geführt und bei Bedarf durch Kisten, statische Objekte, Zonen oder Meldungen dargestellt.

## Zuordnung im Prototyp

| Standort | Native DCS-Warehouse-Anbindung | CampaignState |
|---|---:|---:|
| Bagram | später, sobald physisch genutzt | ja |
| Kabul | später, sobald physisch genutzt | ja |
| Jalalabad / FOB Fenty | erforderlich | ja |
| FOB Connolly | erforderlich | ja |
| afghanischer Checkpoint | nein | ja |
| temporäre LZ oder Drop Zone | nein | nur missionsbezogene Fracht |
| rote Camps und Hide Sites | nein | ja |

## Native und strategische Ressourcen

### Geeignet für das native Warehouse

- Flugzeuge und Hubschrauber;
- konkrete DCS-Waffen und Munitionsobjekte;
- Jet Fuel;
- Flugbenzin;
- Diesel, sofern technisch und spielerisch verwendet;
- statische oder dynamische Cargo-Inhalte, sofern über die verwendete DCS-/MOOSE-Version zuverlässig zugänglich;
- Ressourcen, die DCS bei Bewaffnung, Betankung oder Cargo-Interaktion tatsächlich verbraucht.

### Bleiben strategisch

- Personal;
- Ingenieurkapazität;
- medizinische Kapazität;
- allgemeines Baumaterial;
- Ersatzteile;
- Intelligence;
- Moral und Bereitschaft;
- lokale Unterstützung und Einfluss;
- Gefangene und HVT-Informationen;
- abstrakte Fahrzeug- oder Wiederaufbaupunkte, solange keine eindeutige native DCS-Abbildung existiert.

## MOOSE-Integration

MOOSE kapselt native DCS-Warehouses über `STORAGE`. Der Name `STORAGE` wird verwendet, weil MOOSE bereits eine andere Klasse `WAREHOUSE` besitzt.

Vorgesehene Zugriffe:

```lua
local airbase = AIRBASE:FindByName(AIRBASE.Afghanistan.Jalalabad)
local storage = airbase:GetStorage()
```

Für geeignete statische oder dynamische Cargo-Objekte können abhängig von der eingebundenen MOOSE- und DCS-Version verwendet werden:

```lua
local storage = STORAGE:NewFromStaticCargo("DEPOT_BLUE_FOB_CONNOLLY")
```

oder:

```lua
local storage = STORAGE:NewFromDynamicCargo(dynamicCargoName)
```

Die tatsächliche Sichtbarkeit für Spieler und die Verfügbarkeit aller Funktionen werden in einer Multiplayer-Testmission geprüft. Die Architektur darf nicht voraussetzen, dass jeder Warehouse-Typ dieselbe Benutzeroberfläche wie eine native Airbase besitzt.

## WarehouseAdapter

Der `WarehouseAdapter` ist die einzige Schicht, die strategische Ressourcen mit nativen DCS-Warehouse-Inhalten synchronisiert.

Aufgaben:

- Warehouse-Objekte finden und registrieren;
- Capability und unterstützte Ressourcentypen prüfen;
- strategische Ressourcen auf DCS-Items und Flüssigkeiten abbilden;
- Bestände lesen, setzen, hinzufügen und entfernen;
- Liefermanifeste genau einmal verbuchen;
- Verbrauch durch Spieler oder AI erkennen;
- Differenzen protokollieren und abgleichen;
- Server als alleinige Schreibinstanz durchsetzen;
- fehlende Warehouse-Funktionen kontrolliert auf den abstrakten Modus zurückfallen lassen.

Domänenmodule greifen nicht direkt auf `STORAGE`, `Warehouse` oder interne DCS-Itemnamen zu.

## Ressourcen-Mapping

Native Namen werden nicht unkontrolliert in der Domänenlogik verteilt. Das Mapping liegt in einer versionierten Konfiguration.

```lua
WarehouseMappings = {
  JET_FUEL = {
    kind = "LIQUID",
    dcsType = STORAGE.Liquid.JETFUEL,
    strategicUnitKg = 1000,
  },

  AMMUNITION = {
    kind = "COMPOSITE",
    dcsItems = {
      -- konkrete, in der Testmission ermittelte DCS-Itemnamen
    },
  },
}
```

Ein strategischer Ressourcenpunkt muss nicht zwingend genau einem DCS-Objekt entsprechen. Umrechnungsfaktoren werden explizit dokumentiert und getestet.

## Transaktionsmodell

Jede Bestandsänderung erhält eine stabile Transaktions-ID.

Beispiel:

```lua
{
  transactionId = "TXN_LOGISTICS_000184",
  warehouseId = "WH_BLUE_CONNOLLY",
  source = "CARGO_MANIFEST",
  sourceId = "CARGO_FENTY_CONNOLLY_027",
  resource = "AMMUNITION",
  amount = 20,
  status = "PENDING",
}
```

Mögliche Statuswerte:

- `PENDING`
- `APPLIED_DCS`
- `APPLIED_CAMPAIGN`
- `COMPLETED`
- `REJECTED`
- `RECONCILE_REQUIRED`

Eine Lieferung gilt erst als abgeschlossen, wenn die Kampagnenbuchung und die erforderliche native Warehouse-Buchung erfolgreich beziehungsweise bewusst als nicht anwendbar markiert wurden.

## Synchronisationsrichtung

### Lieferung an ein Warehouse

```text
Fracht validieren
→ Transaktion anlegen
→ CampaignState gutschreiben
→ unterstützte DCS-Warehouse-Bestände aktualisieren
→ Bestände zurücklesen
→ Transaktion abschließen
```

### Direkter DCS-Verbrauch

```text
DCS-Warehouse-Bestand sinkt
→ Adapter erkennt bestätigte Differenz
→ Verbrauch klassifizieren
→ CampaignState belasten
→ Differenz protokollieren
```

Unbekannte oder widersprüchliche Differenzen werden nicht stillschweigend übernommen. Sie führen zu `RECONCILE_REQUIRED` und einem Logeintrag.

## Warehouse- und Übergabezonen

Die Erkennung einer Lieferung erfolgt nicht allein durch räumliche Nähe zu einem Warehouse-Objekt. Jeder physische Warehouse-Knoten erhält explizite Zonen.

Jalalabad/Fenty:

```text
ZONE_FENTY_WAREHOUSE
ZONE_FENTY_INTERNAL_UNLOAD
ZONE_FENTY_SLING_DROP
ZONE_FENTY_C130_UNLOAD
ZONE_FENTY_VEHICLE_DELIVERY
```

FOB Connolly:

```text
ZONE_CONNOLLY_WAREHOUSE
ZONE_CONNOLLY_INTERNAL_UNLOAD
ZONE_CONNOLLY_SLING_DROP
ZONE_CONNOLLY_VEHICLE_DELIVERY
ZONE_CONNOLLY_LZ
```

Die Zonen dürfen sich überschneiden, müssen aber unterschiedliche Übergaberegeln besitzen.

## Start, Laden und Persistenz

Beim Missionsstart:

1. `CampaignState` laden;
2. Warehouse-Knoten und Capabilities erkennen;
3. strategische Sollbestände bestimmen;
4. native Bestände kontrolliert initialisieren oder abgleichen;
5. Abweichungen protokollieren;
6. erst danach Logistikaufträge und Spielerinteraktion freigeben.

Beim Speichern werden primär strategische Bestände, Transaktionen und Mapping-Versionen persistiert. Native DCS-Warehouse-Daten können zusätzlich als Diagnose gespeichert werden, sind aber nicht die alleinige Persistenzquelle.

## Fehlerfälle

- Warehouse-Objekt fehlt;
- Objekt existiert, unterstützt aber keine erwartete Warehouse-Funktion;
- DCS-Itemname ist in der aktuellen Version nicht verfügbar;
- Bestand wird negativ oder überschreitet Kapazität;
- Manifest wurde bereits verbucht;
- DCS- und CampaignState-Bestand weichen ohne bekannte Transaktion ab;
- Spieler verbindet sich während einer Synchronisierung;
- Warehouse oder Depot wird zerstört beziehungsweise der FOB wechselt den Zustand.

In diesen Fällen muss die Mission weiterlaufen können. Der betroffene Knoten fällt kontrolliert auf einen eingeschränkten oder abstrakten Lagerbetrieb zurück und erzeugt einen eindeutigen Logeintrag.

## Zerstörung und Wiederaufbau

Das physische Depotobjekt ist eine Repräsentation des Warehouse-Knotens. Seine Zerstörung kann:

- Zugriff für Spieler sperren;
- lokale Kapazität reduzieren;
- einen Teil der Bestände vernichten;
- Lieferungen blockieren;
- einen Wiederaufbauauftrag auslösen.

Bestände werden nicht automatisch vollständig vernichtet, nur weil ein einzelnes sichtbares Objekt zerstört wird. Die Schadenswirkung wird über den CampaignState und die Depotklasse bestimmt.

## Testmatrix

Mindestens zu prüfen:

- Jalalabad-Airbase-Warehouse finden und auslesen;
- FOB-Connolly-Depot als Warehouse anbinden oder kontrolliert auf abstrakten Modus zurückfallen;
- Bestände aus Sicht eines Spielers prüfen;
- Flugzeugbewaffnung und Betankung reduzieren native Bestände;
- interne Fracht wird genau einmal gutgeschrieben;
- Außenlast wird genau einmal gutgeschrieben;
- Konvoiübergabe wird genau einmal gutgeschrieben;
- C-130J-Entladung aktualisiert Jalalabad/Fenty;
- Neustart stellt strategische Bestände reproduzierbar wieder her;
- unbekannte Differenzen werden erkannt;
- fehlende Warehouse-Funktion beendet die Mission nicht.

## Nicht zulässig

- jedem OP, Checkpoint oder temporären Landeplatz ein natives Warehouse zuzuweisen;
- Domänenlogik direkt an DCS-Itemnamen zu koppeln;
- DCS-Warehouse und CampaignState unabhängig voneinander Bestände erzeugen zu lassen;
- Lieferungen ohne Transaktions-ID zu verbuchen;
- Spieleranzeige als Beweis zu verwenden, dass Persistenz und Synchronisierung korrekt funktionieren;
- unbegrenzte Bestände an spielerrelevanten FOBs zu verwenden, sofern dies nicht ausdrücklich als Testmodus markiert ist.
