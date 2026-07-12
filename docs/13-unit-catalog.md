# 13 – Einheiten- und Templatekatalog

## Ziel

Der Katalog beschreibt nur Einheiten, Gruppen und Luftfahrzeuge, die in der Kampagne tatsächlich verwendet werden. Eine vollständige Kopie aller DCS-Einheiten ist nicht erforderlich.

## Vier getrennte Identifikatoren

### DCS-Typname

Der von `Unit:getTypeName()` zurückgegebene interne Typname identifiziert ein konkretes Fahrzeug, einen Soldaten oder ein Luftfahrzeug. Er wird für Persistenz, Verlustauswertung, Klassifizierung und Template-Validierung benötigt.

### Mission-Editor-Gruppenname

MOOSE `SPAWN` referenziert primär den Namen einer auf `Late Activation` gesetzten Template-Gruppe.

Beispiel:

```lua
local spawn = SPAWN:New("TPL_RED_CELL_INF_SMALL_01")
```

### Mission-Editor-Einheitenname

Jede einzelne Einheit innerhalb eines Templates besitzt einen eigenen Namen. Diese Namen sind nicht als dauerhafte strategische IDs zu verwenden, da MOOSE beim Spawn Laufzeitsuffixe ergänzt.

### Strategische Entity-ID

Die Kampagne vergibt eine eigene persistente ID, die unabhängig von einer konkreten DCS-Gruppe bestehen bleibt.

Beispiel:

```text
RED_CELL_KUNAR_003_ASSAULT_GROUP_02
```

## Namenskonventionen

Template-Gruppen verwenden:

```text
TPL_<COALITION>_<ROLE>_<VARIANT>
```

Beispiele:

- `TPL_RED_CELL_INF_SMALL_01`
- `TPL_RED_CELL_ASSAULT_01`
- `TPL_RED_MORTAR_TEAM_01`
- `TPL_RED_CAPTURE_TEAM_01`
- `TPL_BLUE_CONVOY_SUPPLY_LIGHT_01`
- `TPL_BLUE_CONVOY_SECURITY_01`
- `TPL_BLUE_QRF_LIGHT_01`
- `TPL_BLUE_FOB_GARRISON_MEDIUM_01`
- `TPL_BLUE_ENGINEER_TEAM_01`

Das Zeichen `#` wird in Template-Namen nicht verwendet, da MOOSE es für Laufzeitnamen erzeugter Gruppen nutzt.

## Benötigte blaue Rollen

- leichter Versorgungskonvoi
- schwerer Versorgungskonvoi
- Konvoisicherung
- leichte QRF
- mechanisierte QRF
- FOB-Garnison
- Ingenieurgruppe
- Mörsergruppe
- MEDEVAC- und CSAR-Team
- afghanischer Kontrollpunkt
- ANA-Infanterie
- ANP- und Grenzpolizeiposten

## Benötigte rote Rollen

- kleine Infanteriezelle
- mittlere Infanteriezelle
- Angriffsgruppe
- Hinterhaltgruppe
- RPG-Team
- Maschinengewehrteam
- Mörserteam
- Technical-Gruppe
- Aufklärer oder Spotter
- Kurier
- Capture-Team
- Camp-Garnison
- Nachschubgruppe

Rote Kampfgruppen bestehen üblicherweise aus mindestens fünf Personen. Kleinere Elemente sind für Spotter, Kuriere oder Vorhut zulässig.

## Template-Metadaten

Für jedes Gruppentemplate werden dokumentiert:

- Template-Gruppenname
- Koalition und Land
- operative Rolle
- Einheitenzusammensetzung
- DCS-Typnamen
- Skill und Formation
- Bewaffnung oder Loadout
- Bedrohungswert
- Ressourcen- und Wiederbeschaffungskosten
- Transport- oder Frachtkapazität
- virtuelle Durchschnittsgeschwindigkeit
- erlaubte Missionsarten
- geeignetes Gelände
- Rückzugsschwelle
- erforderliche Module oder Mods

## Beispielstruktur

```yaml
template_name: TPL_BLUE_CONVOY_SUPPLY_LIGHT_01
coalition: BLUE
country: USA
role: SUPPLY_CONVOY
composition:
  - catalog_role: CARGO_TRUCK
    count: 4
  - catalog_role: SECURITY_VEHICLE
    count: 2
cargo:
  ammunition: 30
  fuel: 20
  construction: 10
virtual_speed_kph: 30
retreat_threshold: 0.35
```

## Erfassung interner DCS-Namen

Interne Typnamen werden nicht aus unsicheren Tabellen abgeschrieben. Eine Testmission enthält alle ausgewählten Templates. Ein Debugskript protokolliert für jede Gruppe:

- Gruppenname
- Einheitenname
- `Unit:getTypeName()`
- Koalition und Land

Dadurch stammen die Strings aus der tatsächlich installierten DCS-Version.

## Luftfahrzeugrollen

Für die erste Kampagnenplanung sind folgende Module oder Rollen vorgesehen:

- A-10C: CAS und Armed Overwatch
- F-16C: CAS, Präzisionsangriff und Air Presence
- F-15E: größere Präzisions- und Nachtangriffe
- F/A-18C: externe Trägerunterstützung
- AH-64D: Attack Aviation
- OH-58D: Aufklärung und Zielzuweisung
- UH-60: KI- oder Skriptplattform für Transport, MEDEVAC und Verbindung
- CH-47F: schwerer taktischer Transport
- C-130J: regionaler Lufttransport und Luftabwurf

Die Liste beschreibt Kampagnenfunktionen, nicht automatisch eine dauerhafte Stationierung jedes Typs an jeder Basis.

## Noch zu entscheiden

- konkrete DCS-Typen je Rolle
- Länderzuordnung für afghanische Einheiten und verfügbare Assets
- benötigte Community-Mods oder ausschließlich Core-/Modul-Assets
- Skill-Stufen und Gruppengrößen
- Bedrohungs- und Ressourcenkosten
- genaue Luftfahrzeug-Slots und historische Verfügbarkeit
