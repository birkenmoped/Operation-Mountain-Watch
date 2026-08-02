---
document_id: OMW-TEMPLATE-LIBRARY-SPAWNING
status: BINDING
document_class: TEMPLATE_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - Mission Editor template library and runtime naming strategy
  - standard physical group creation through MOOSE templates
  - canonical BLUE convoy template names
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - prototype-only exception wording for Lua-built groups
  - TPL_TEST_BLUE_CONVOY_STANDARD_01
superseded_by:
source_branch: main
source_commit: PENDING_COMMIT
validated_in_dcs: false
---

# 15 – Template-Bibliothek und Spawnstrategie

## 1. Grundentscheidung

Reguläre physische Gruppen werden aus wiederverwendbaren Mission-Editor-Templates erzeugt. CampaignState entscheidet über Existenz, Auftrag und Ressourcen; das Template definiert DCS-spezifische Zusammensetzung und Eigenschaften.

Der vollständige frühere Template- und Spawnentwurf bleibt erhalten:

- [`Legacy-Template- und Spawnstrategie`](evidence/source-records/legacy-15-template-library-and-spawning.md)

## 2. Standardverfahren

1. Gruppe im DCS Mission Editor anlegen.
2. `Late Activation` setzen.
3. eindeutigen, dokumentierten Template-Namen vergeben.
4. Template über MOOSE `SPAWN`, AIRWING-/SQUADRON- oder OPS-Funktion referenzieren.
5. an validierter Laufzeitposition, Zone oder Airbase erzeugen.
6. Laufzeitgruppe mit stabiler CampaignState-Entity-ID verknüpfen.
7. Start, Template-Auswahl, Events, Verlust und Abschluss protokollieren.

Vollständig in Lua aufgebaute DCS-Gruppentabellen sind keine Standardlösung. Sie benötigen eine dokumentierte MOOSE-Prüfung und ausdrückliche Projektinhaberfreigabe.

## 3. Namensebenen

- Template-ID: stabile Mission-Editor-Gruppe;
- MOOSE-/DCS-Laufzeitname: flüchtige physische Repräsentation;
- DCS-Einheitenname: flüchtige Unit-Referenz;
- CampaignState-Entity-ID: persistente strategische Identität.

`#` ist in eigenen Template- und Aliasnamen verboten.

Der allgemeine Präfix `TPL_` bleibt für nicht gesondert normierte technische Templates zulässig und bevorzugt. Für kanonische fachliche Vorlagen kann der Projektinhaber jedoch einen eigenen stabilen Bibliotheksnamen festlegen. Die folgenden BLUE-Konvoi-Namen sind eine solche verbindliche Ausnahme und werden ohne `TPL_` geführt:

```text
BLUE_CONVOY_LIGHT_06
BLUE_CONVOY_STANDARD_07
```

Der alte Testname ist ersetzt:

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
```

Er darf in neuen Missionsständen und neuen Laufzeitkonfigurationen nicht mehr als aktive Konvoi-Vorlage referenziert werden. Historische Testmissionen und Ergebnisberichte dürfen ihn als Nachweis ihres damaligen Stands weiterhin enthalten.

## 4. Template-Bibliothek

Die Bibliothek wird nach Koalition, Domäne und Rolle strukturiert. Jedes Template besitzt Metadaten aus Dokument 13 und wird gegen die verwendete DCS-/MOOSE-Version validiert.

Für die regulären BLUE-Logistikkonvois gelten zwei kanonische Varianten:

```text
BLUE_CONVOY_LIGHT_06
BLUE_CONVOY_STANDARD_07
```

Ihre genaue Fahrzeugfolge und Rolle ist in `OMW-CIED-ROUTE-CLEARANCE-CONVOY-DESIGN` (`docs/67-afghanistan-route-clearance-counter-ied-and-convoy-design.md`) festgelegt.

## 5. MOOSE-native Template-Auswahl

Sind mehrere freigegebene Mission-Editor-Templates für dieselbe Laufzeitrolle vorhanden, ist vor eigener Zufallslogik eine passende MOOSE-Funktion zu verwenden. Für die beiden BLUE-Konvoi-Varianten gilt:

```lua
SPAWN:InitRandomizeTemplate({
  "BLUE_CONVOY_LIGHT_06",
  "BLUE_CONVOY_STANDARD_07",
})
```

Die Auswahl erfolgt unabhängig je erzeugtem Konvoi. Beide Gruppen müssen im Mission Editor vorhanden, `Late Activation` und zur Laufzeit über MOOSE auflösbar sein. Ein fehlendes Template ist ein Konfigurationsfehler; es gibt keinen stillen Rückfall auf das verbliebene Template.

Da die Varianten sechs beziehungsweise sieben Fahrzeuge besitzen, muss die Laufzeitlogik beide Fahrzeugzahlen akzeptieren und die ausgewählte Variante protokollieren. Eine globale feste Sollzahl für alle Spawns ist unzulässig.

## 6. Spawn- und Beobachtungsregeln

- keine Spawns in plausibler Spielerbeobachtung;
- keine Doppelzählung von Templates und Kampagnenbestand;
- Position, Fahrtrichtung und Gelände vor Spawn validieren;
- Materialisierung und Dematerialisierung nach Dokument 07;
- keine ungeprüfte Übernahme alter Controller-Aufgaben;
- Fehler und fehlende Templates fail-fast protokollieren.
