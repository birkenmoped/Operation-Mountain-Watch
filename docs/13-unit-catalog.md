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
- `TPL_BLUE_CONVOY_SUPPLY_STANDARD_01`
- `TPL_BLUE_CONVOY_SECURITY_01`
- `TPL_BLUE_QRF_LIGHT_01`
- `TPL_BLUE_FOB_GARRISON_MEDIUM_01`
- `TPL_BLUE_ENGINEER_TEAM_01`

Das Zeichen `#` wird in Template-Namen nicht verwendet, da MOOSE es für Laufzeitnamen erzeugter Gruppen nutzt.

## Benötigte blaue Rollen

- leichter Versorgungskonvoi
- Standard-Versorgungskonvoi
- verstärkter Versorgungskonvoi
- Konvoisicherung
- Berge- oder Recovery-Fahrzeug
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
- Cargo-Unit-Kapazität
- Frachtzuordnung je Fahrzeug
- Validierungsstatus der Kapazität
- virtuelle Durchschnittsgeschwindigkeit
- erlaubte Missionsarten
- geeignetes Gelände
- Rückzugsschwelle
- erforderliche Module oder Mods

## Standardkonvoi Fenty–Connolly

Der reguläre physische Konvoi besteht bevorzugt aus fünf bis sechs Fahrzeugen. Acht Fahrzeuge sind die harte Obergrenze einer einzelnen DCS-Gruppe.

```text
1 Lead-Sicherungsfahrzeug
1 vorderes Sicherungsfahrzeug oder Gun Truck
2 schwere Transport-Lkw mit je 2 CU
1 Führungs-, Berge-, Sanitäts- oder Sicherungsfahrzeug
1 rückwärtiges Sicherungsfahrzeug
```

Eine reduzierte Fünf-Fahrzeug-Variante verzichtet auf das zusätzliche Führungs- oder Unterstützungsfahrzeug.

Beispiel:

```yaml
template_name: TPL_BLUE_CONVOY_SUPPLY_STANDARD_01
coalition: BLUE
country: USA
role: SUPPLY_CONVOY
preferred_group_size: 6
maximum_group_size: 8
composition:
  - catalog_role: LEAD_SECURITY_VEHICLE
    count: 1
  - catalog_role: FORWARD_SECURITY_VEHICLE
    count: 1
  - catalog_role: HEAVY_CARGO_TRUCK
    count: 2
    cargo_units_each: 2
  - catalog_role: SUPPORT_OR_RECOVERY_VEHICLE
    count: 1
  - catalog_role: REAR_SECURITY_VEHICLE
    count: 1
cargo:
  total_cargo_units: 4
  allocations:
    CARGO_TRUCK_01: 2
    CARGO_TRUCK_02: 2
capacity_status: CAMPAIGN_STANDARD
virtual_speed_kph: 30
retreat_threshold: 0.35
```

Die Eskorte besitzt standardmäßig keine Cargo Units. Nur ausdrücklich im Manifest eingetragene Frachtfahrzeuge tragen Ressourcen.

## Konvoi-Serials

Ab neun Fahrzeugen wird ein logischer Konvoi in mehrere physische DCS-Gruppen aufgeteilt.

```text
CONVOY_FENTY_CONNOLLY_004
├── SERIAL_ALPHA – 5 Fahrzeuge
└── SERIAL_BRAVO – 5 Fahrzeuge
```

Metadaten eines Serials:

```yaml
serial_id: SERIAL_ALPHA
parent_convoy_id: CONVOY_FENTY_CONNOLLY_004
start_delay_seconds: 0
planned_spacing_m: 750
manifest_allocations:
  - CARGO_TRUCK_ALPHA_01
```

Die Serials besitzen getrennte DCS-Controller, aber einen gemeinsamen strategischen Auftrag. Teilverluste werden anhand der tatsächlichen Frachtzuordnung verbucht.

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
- CH-47F: primärer schwerer taktischer Transport mit interner Fracht und Außenlast
- UH-1H: leichter taktischer Transport mit interner Fracht und Außenlast
- UH-60: AI- oder Skriptplattform für Transport, MEDEVAC und Verbindung
- UH-60L Community Mod: optionale spielbare Transportplattform mit versionsabhängigen internen und externen Frachtpfaden
- C-130J: regionaler Lufttransport mit gelandeter Lieferung, Fahrzeugtransport und Luftabwurf

Die Liste beschreibt Kampagnenfunktionen, nicht automatisch eine dauerhafte Stationierung jedes Typs an jeder Basis.

## Transportfähigkeitsprofil

Jede Transportplattform erhält ein explizites Fähigkeitsprofil. Interne Fracht und Außenlast sind getrennte Fähigkeiten und dürfen nicht in einem allgemeinen Feld `cargo=true` zusammengefasst werden.

Zu dokumentierende Felder:

- `transport_mode`: `GROUND`, `ROTARY_WING` oder `FIXED_WING`
- `internal_cargo`: ja oder nein
- `internal_cargo_interface`: `NATIVE`, `CTLD`, `ADAPTER` oder `NONE`
- `internal_cargo_types`: zum Beispiel Kisten, Paletten, Personal oder Verwundete
- `internal_weight_limit`
- `internal_volume_limit`
- `campaign_internal_capacity_cu`
- `sling_load`: ja oder nein
- `sling_load_interface`: `NATIVE`, `CTLD`, `ADAPTER` oder `NONE`
- `sling_hook_count`
- `sling_weight_limit`
- `campaign_sling_capacity_cu`
- `troop_capacity`
- `vehicle_slots`
- `requires_runway`: ja oder nein
- `requires_landing_zone`: ja oder nein
- `supports_airdrop`: ja oder nein
- `supports_landed_delivery`: ja oder nein
- `airdrop_classes`
- `campaign_landed_capacity_cu`
- `campaign_airdrop_capacity_cu`
- `capacity_validation_status`
- `requires_mod`: ja oder nein
- `historical_status`: verbindlich, plausibel, optional oder ahistorische Gameplay-Alternative

## Standardprofile

### CH-47F

```yaml
platform: CH-47F
transport_mode: ROTARY_WING
internal_cargo: true
internal_cargo_interface: NATIVE
internal_cargo_types:
  - CRATE
  - PALLET
  - PERSONNEL
campaign_internal_capacity_cu: 5
sling_load: true
sling_load_interface: NATIVE
sling_hook_count: 1
campaign_sling_capacity_cu: 4
requires_landing_zone: true
requires_mod: false
capacity_validation_status: CAMPAIGN_STANDARD
```

Mehrpunkt-Außenlast wird erst nach verfügbarer und getesteter DCS-Funktion ergänzt.

### UH-1H

```yaml
platform: UH-1H
transport_mode: ROTARY_WING
internal_cargo: true
internal_cargo_interface: ADAPTER
campaign_internal_capacity_cu: 1
sling_load: true
sling_load_interface: NATIVE
sling_hook_count: 1
campaign_sling_capacity_cu: 1
requires_landing_zone: true
requires_mod: false
capacity_validation_status: CAMPAIGN_STANDARD
```

Die konkrete interne Schnittstelle wird gegen die installierte DCS- und MOOSE-Version ermittelt.

### UH-60L Community Mod

```yaml
platform: UH-60L
transport_mode: ROTARY_WING
internal_cargo: true
internal_cargo_interface: MOD_NATIVE_OR_ADAPTER
campaign_internal_capacity_cu: 2
sling_load: true
sling_load_interface: MOD_NATIVE_OR_ADAPTER
campaign_sling_capacity_cu: 3
requires_landing_zone: true
requires_mod: true
capacity_validation_status: PROVISIONAL
```

### C-130J

```yaml
platform: C-130J
transport_mode: FIXED_WING
internal_cargo: true
internal_cargo_interface: NATIVE
supports_landed_delivery: true
supports_airdrop: true
supports_vehicle_transport: true
campaign_landed_capacity_cu: 12
campaign_airdrop_capacity_cu: 8
airdrop_classes:
  - PER
  - CDS
  - HE
  - BDL_OTHER
vehicle_slots: REQUIRES_DCS_TEST
capacity_validation_status: CAMPAIGN_STANDARD_WITH_TECHNICAL_VALIDATION
requires_runway: true
requires_mod: false
```

Die C-130J-CU-Werte sind Standardmissionspakete, keine technischen Maximalzuladungen. Roll-on/Roll-off-Fahrzeugtypen und Kombinationen bleiben bis zum Modultest offen.

## Außenlastklassen

| Klasse | CU | Plattformen |
|---|---:|---|
| `SLING_LIGHT` | 0.5 | UH-1H, UH-60L, CH-47F |
| `SLING_STANDARD` | 1.0 | UH-1H, UH-60L, CH-47F |
| `SLING_MEDIUM` | 2.0 | UH-60L, CH-47F |
| `SLING_HEAVY` | 3.0 | UH-60L, CH-47F |
| `SLING_VERY_HEAVY` | 4.0 | CH-47F |

## Transport-Testmatrix

Mindestens folgende Kombinationen werden separat geprüft:

| Plattform | Interne Fracht | Außenlast | Geladene Lieferung | Luftabwurf | Fahrzeugtransport |
|---|---:|---:|---:|---:|---:|
| CH-47F | erforderlich | erforderlich | – | – | – |
| UH-1H | erforderlich | erforderlich | – | – | – |
| UH-60L Community Mod | optional | optional | – | – | – |
| C-130J | erforderlich | – | erforderlich | erforderlich | erforderlich |

Jeder Test erfasst:

- Plattform- und Versionsstand;
- Cargo-ID;
- CU, reales Gewicht und Volumen;
- Laden;
- Flug oder Fahrt;
- Entladen beziehungsweise Absetzen;
- Verlustfall;
- genau einmalige Ressourcengutschrift;
- Performance- und Grenzverhalten.

## Mod-Politik

Der Kern der Kampagne soll ohne verpflichtende Community-Mods funktionieren. Ein optionaler UH-60L-Mod kann zusätzliche Spielerslots und Transportoptionen bieten, darf aber nicht dazu führen, dass Spieler ohne Mod den Server oder die Mission nicht nutzen können.

Für jede Mod-Abhängigkeit müssen dokumentiert werden:

- Download- und Versionsquelle
- Multiplayer-Kompatibilität
- Update- und Wartungsaufwand
- Verhalten bei fehlendem Mod
- Auswirkungen auf Missionsdatei und Serverstart
- Ersatz durch Core-, AI- oder Skriptplattformen
- versionsbezogene Transportkapazitäten

## Noch zu entscheiden

- konkrete DCS-Typen je Rolle
- Länderzuordnung für afghanische Einheiten und verfügbare Assets
- endgültige Mod-Politik für den UH-60L
- Skill-Stufen und endgültige Formationen
- Bedrohungs- und Ressourcenkosten
- genaue Luftfahrzeug-Slots und historische Verfügbarkeit
- gemessene interne Fracht- und Außenlastkapazitäten je Plattform
- unterstützte DCS-, MOOSE-CTLD- und Adapterpfade je Plattform
- C-130J-RORO-Fahrzeugkatalog und Fahrzeugkombinationen
- tatsächliche C-130J-Airdrop-Pakete und Release-Systeme der installierten Version
