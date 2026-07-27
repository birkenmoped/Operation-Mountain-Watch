# 15 – Template-Bibliothek und Spawnstrategie

## Ziel

Reguläre physische Gruppen werden aus wiederverwendbaren Mission-Editor-Templates erzeugt. Die Kampagnenlogik entscheidet, wann, wo und mit welchem Auftrag eine strategische Entität materialisiert wird; das Mission-Editor-Template definiert ihre physische Zusammensetzung und DCS-spezifischen Eigenschaften.

## Verbindliche Grundentscheidung

Der Standardweg für Bodenverbände und AI-Luftfahrzeuge ist:

1. Gruppe im DCS Mission Editor anlegen.
2. Gruppe auf `Late Activation` setzen.
3. Einen eindeutigen Template-Namen vergeben.
4. Template über MOOSE `SPAWN:New()` oder `SPAWN:NewWithAlias()` referenzieren.
5. Gruppe an einer Laufzeitposition, in einer Zone oder an einer Airbase erzeugen.
6. Den MOOSE-Laufzeitnamen mit einer stabilen strategischen Entity-ID verknüpfen.

Vollständig in Lua aufgebaute DCS-Gruppentabellen sind eine Ausnahme und nicht der Standard des ersten Prototyps.

## Warum Mission-Editor-Templates

Ein Mission-Editor-Template hält DCS-spezifische Details zusammen:

- Einheitentypen
- Gruppenzusammensetzung
- relative Positionen und Formation
- Skill
- Bewaffnung und Payload
- Livery
- Funk- und Callsign-Daten
- Startzustand
- Route und Aufgaben, soweit diese übernommen werden sollen

Dadurch müssen komplexe DCS-Gruppentabellen nicht manuell in Lua gepflegt werden.

## Template-Bibliothek

Die Mission enthält eine überschaubare Bibliothek wiederverwendbarer Gruppen. Beispiele:

```text
TPL_RED_CELL_INF_SMALL_01
TPL_RED_CELL_INF_MEDIUM_01
TPL_RED_AMBUSH_RPG_01
TPL_RED_MORTAR_TEAM_01
TPL_RED_TECHNICAL_LIGHT_01
TPL_RED_CAPTURE_TEAM_01

TPL_BLUE_CONVOY_SUPPLY_LIGHT_01
TPL_BLUE_CONVOY_SUPPLY_HEAVY_01
TPL_BLUE_CONVOY_SECURITY_01
TPL_BLUE_QRF_LIGHT_01
TPL_BLUE_ANA_CHECKPOINT_01
TPL_BLUE_ENGINEER_TEAM_01
```

Templates können im Mission Editor in getrennten Arbeitsbereichen organisiert werden:

```text
TEMPLATE AREA – BLUE GROUND
TEMPLATE AREA – RED GROUND
TEMPLATE AREA – BLUE AIR
TEMPLATE AREA – RED AIR
TEMPLATE AREA – LOGISTICS
```

Die Template-Position ist nicht die spätere Einsatzposition, sofern die Gruppe mit einer Laufzeitkoordinate, Zone oder Airbase erzeugt wird.

## Namensebenen

### Template-ID

Beispiel:

```text
TPL_RED_CELL_INF_SMALL_01
```

Diese ID bezeichnet die Mission-Editor-Gruppe und wird an MOOSE übergeben.

### MOOSE-Laufzeitname

MOOSE ergänzt normalerweise einen Spawn-Zähler. Beispiel:

```text
RED_NANGARHAR_CELL_003#001
```

Das Zeichen `#` ist deshalb in eigenen Template- und Aliasnamen verboten.

### DCS-Einheitenname

Einzelne Units erhalten ebenfalls Laufzeitsuffixe. Diese Namen dürfen nicht als dauerhafte Kampagnen-IDs verwendet werden.

### Strategische Entity-ID

Beispiel:

```text
RED_CELL_NANGARHAR_003_ASSAULT_GROUP_02
```

Diese ID gehört zum `CampaignState` und bleibt unabhängig von einer konkreten DCS-Gruppe stabil.

## Laufzeitverknüpfung

Beim Materialisieren wird eine explizite Zuordnung gespeichert:

```lua
EntityManager:LinkPhysicalGroup(
  "RED_CELL_NANGARHAR_003_ASSAULT_GROUP_02",
  spawnedGroup:GetName()
)
```

Der persistente Zustand darf nie allein über den MOOSE- oder DCS-Laufzeitnamen identifiziert werden.

## Koalition und Land

Templates werden im Normalfall bereits für die richtige Koalition und das richtige Land erstellt.

Beispiele:

```text
TPL_BLUE_US_CONVOY_LIGHT_01
TPL_BLUE_ANA_INFANTRY_01
TPL_RED_INSURGENT_CELL_01
```

MOOSE kann Koalition, Land und Kategorie überschreiben. Diese Funktion wird nur gezielt verwendet, weil DCS-Einheitentypen, Liveries und verfügbare Assets länderabhängig sein können.

## Spawnvarianten

### Standard

```lua
local spawner = SPAWN:New("TPL_RED_CELL_INF_SMALL_01")
local group = spawner:SpawnInZone(spawnZone)
```

### Alias für operative Namen

```lua
local spawner = SPAWN:NewWithAlias(
  "TPL_RED_CELL_INF_SMALL_01",
  "RED_NANGARHAR_CELL_003"
)
```

### Andere Position

Je nach Gruppe können unter anderem Laufzeitkoordinaten, Zonen oder Airbases als Spawnziel verwendet werden. Die konkrete Methode wird durch den EntityManager gekapselt.

## Wiederherstellung reduzierter Gruppen

Eine persistent beschädigte Gruppe darf nicht automatisch wieder in voller Template-Stärke erscheinen.

Für den Prototyp gilt folgende Priorität:

1. mehrere geprüfte Template-Varianten für typische Stärkestufen;
2. Kopie eines Mission-Editor-Templates und gezielte Entfernung nicht mehr vorhandener Units;
3. vollständig dynamische `SPAWN:NewFromTemplate()`-Tabellen nur für begründete Sonderfälle.

Beispielhafte Varianten:

```text
TPL_RED_CELL_INF_SMALL_FULL_01
TPL_RED_CELL_INF_SMALL_REDUCED_01
TPL_RED_CELL_INF_SMALL_CRITICAL_01
```

Langfristig kann die Zusammensetzung aus dem CampaignState auf eine Kopie des Templates angewendet werden. Dabei werden nur getestete Felder verändert.

## Vollständig dynamische Gruppentabellen

MOOSE unterstützt `SPAWN:NewFromTemplate()` mit einer vollständigen DCS-Gruppentabelle. Dieser Weg erfordert unter anderem:

- valide interne DCS-Typnamen
- Gruppen- und Unit-Struktur
- Koalition, Land und Kategorie
- Positionen und Formation
- Route und Aufgaben
- Skill, Payload und weitere typspezifische Daten
- garantiert eindeutige Namen

Er wird im ersten Prototyp nicht als primärer Mechanismus verwendet.

## Spieler-Slots

Spielerflugzeuge und Spielerhubschrauber bleiben reguläre Mission-Editor-Slots. MOOSE-Spawnvorlagen dienen primär für AI-Gruppen, Bodenverbände, Logistikobjekte und dynamisch materialisierte Kampagnenentitäten.

## Template-Metadaten

Zu jedem Template werden außerhalb der `.miz` mindestens dokumentiert:

```yaml
template_id: TPL_RED_CELL_INF_SMALL_01
coalition: RED
country: TBD
role: INFANTRY_CELL
strength_class: SMALL
mission_editor_group: TPL_RED_CELL_INF_SMALL_01
composition:
  personnel: 8
  rpg: 1
  machine_gun: 1
allowed_missions:
  - AMBUSH
  - RAID
  - DEFEND_CAMP
terrain:
  - VALLEY
  - VILLAGE
  - MOUNTAIN
```

## Validierung

Jedes Template wird in einer Testmission geprüft:

- Gruppe wird von MOOSE gefunden;
- `Late Activation` ist gesetzt;
- alle DCS-Typnamen sind verfügbar;
- Spawn in Zone und an Koordinate funktioniert;
- Formation ist plausibel;
- AI kann den vorgesehenen Auftrag ausführen;
- Laufzeitnamen kollidieren nicht;
- Verluste können dem CampaignState eindeutig zugeordnet werden;
- Mod-Abhängigkeiten sind dokumentiert.

## Nicht zulässig

- individuelle Kampagnenentitäten als hunderte separate Mission-Editor-Gruppen anzulegen;
- persistente Entity-IDs aus MOOSE-Laufzeitnamen abzuleiten;
- `#` in Template- oder Aliasnamen zu verwenden;
- ungetestete DCS-Gruppentabellen direkt aus externen Listen zu erzeugen;
- vollständig dynamische Gruppenerzeugung einzusetzen, obwohl ein geprüftes Mission-Editor-Template ausreicht.
