---
document_id: OMW-GROUND-AMMO-REARM-V15-7-FIRE-SUPPORT-REVIEW
status: DRAFT
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - read-only v15(7) Ground fire-support inventory evidence
  - source-reviewed ARTY RearmingGroup applicability boundary for fixed fire-support consumers
  - current owner decisions for Fire-Support proxy retention and DCS-test consolidation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: b58f788dcd6ea194f31715d27d9b02cc1008a3ca
validated_in_dcs: false
---

# OMW Template v15(7) – Ground Fire Support Review

Stand: 22.08.2026

## Zweck

Dieses Dokument hält den read-only Befund der vom Projektinhaber bereitgestellten `OMW_Template_v15(7).miz` für den Ground-Rearm-/Fixed-Fire-Support-Scope fest.

Es ist **kein neuer DCS-Acceptance-Lauf** und erweitert die bereits geschlossene Bostick-Acceptance nicht automatisch auf andere Standorte oder Waffensysteme.

## Artefakt-Provenienz

```text
Mission artifact:
OMW_Template_v15(7).miz

MIZ SHA-256:
EEF6F408FB907186A5FD2CD85DFBDB3C276D3A38B8AB2D18C55140E6500C81F8

internal mission SHA-256:
5527AF6655EF52CA0D3A140654AC85BD37CF377DEF53A1CA3C2FFFC7FC902AEF
```

Die Mission wurde für diese Bestandsaufnahme ausschließlich read-only ausgewertet. Es wurde keine `.miz`-Mutation vorgenommen.

## Bestätigte Fire-Support-Gruppen

```text
FOB Bostick
Group: TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
Units: 2 x L118_Unit

FOB Wright
Group: TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2
Units: 2 x L118_Unit

FOB Fortress
Group: TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
Units: 1 x L118_Unit

FOB Honaker
Group: TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2
Units: 2 x 2B11 mortar
```

Damit ist die reale Mission nicht als einzelner Bostick-Rearm-Fall zu modellieren. Der relevante Consumer-Scope umfasst mindestens drei L118-Standorte sowie einen 2B11-Mörserstandort.

## MOOSE-First Source Review – wichtige Korrektur für Mortar

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der gepinnte `ARTY`-Source unterscheidet zwei Rearm-Varianten:

```text
1. Rearming Group
   ARTY:SetRearmingGroup(group)
   -> der Versorgungstruck fährt zur ARTY-/Mortar-Gruppe

2. Rearming Place
   ARTY:SetRearmingPlace(coord)
   -> die ARTY-Gruppe selbst muss zum Rearming Place fahren
```

Die im MOOSE-Source dokumentierte Einschränkung

```text
"for a mortar this rearming procedure would not work"
```

bezieht sich auf die **Rearming-Place-Variante**, weil der Empfänger dafür mobil sein muss. Sie ist kein Source-Beleg dafür, dass ein Mortar nicht über eine explizite `RearmingGroup` versorgt werden kann.

Für OMW folgt daraus source-seitig:

```text
Bostick L118
Wright L118
Fortress L118
Honaker 2B11 mortar

-> ARTY + explicit SetRearmingGroup(...) ist für alle vier Consumer zunächst der gemeinsame MOOSE-first Kandidat.
```

Das ist für Wright, Fortress und Honaker **SOURCE_REVIEWED / DCS_PENDING**. Nur der exakt dokumentierte Bostick-L118-/CHAP_M1083-Pfad besitzt bereits `VALIDATED_FOR_DOCUMENTED_SCOPE`-Runtime-Evidenz.

## Architekturfolge

Die vorhandenen branch-spezifischen Module

```text
OMW_BostickAmmoSupport.lua
OMW_BostickAmmoRearmService.lua
```

sind derzeit standortspezifische Composition-Module. Der zugrunde liegende

```text
OMW_GroundAmmoRearmAdapter.lua
```

ist bereits weitgehend standortunabhängig und koppelt CampaignState an den öffentlichen MOOSE-`ARTY`-FSM.

Vor einer produktiven Ausweitung darf daher nicht je FOB ein eigener nahezu identischer Rearm-Stack kopiert werden.

Der Branch enthält deshalb jetzt zusätzlich die standortneutralen Source-Contracts:

```text
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua
```

Diese Schicht generalisiert ausschließlich die bereits vorhandene Komposition:

```text
MOOSE BRIGADE/PLATOON/WAREHOUSE self-request materialization
+ bestehender GroundRoadSpawnAdapter
+ bestehender GroundAmmoRearmAdapter
+ MOOSE ARTY SetRearmingGroup/Rearm FSM
```

Standortidentität wird über Konfiguration geliefert:

```text
nodeId
carrierEntityId
templateName
platoonName
assignment
accessZone
forwardCoordinate
alias
```

Es wird kein eigener Dispatcher, kein zusätzlicher Spawnpfad, kein eigener Rearm-FSM und keine zweite Ressourcenhoheit eingeführt.

Die bisherigen Bostick-Module bleiben bis zur kombinierten Runtime-Acceptance unverändert als bereits praktisch belegter Referenzpfad erhalten. Eine Ablösung oder Löschung erfolgt erst nach erfolgreicher gemeinsamer Acceptance und ist nicht aus dem Source-Review abzuleiten.

Dabei bleiben verbindlich:

```text
CampaignState = einzige strategische Ressourcenautorität
MOOSE ARTY = operativer Fire-Support-/Rearm-Lifecycle
MOOSE WAREHOUSE/BRIGADE/PLATOON = bestehende physische Support-Materialisierung
DCS groups = temporäre physische Repräsentation
```

Keine zusätzliche Native-DCS-Rearm-Logik, kein eigener Truck-Dispatcher und keine zweite Ressourcenhoheit werden eingeführt.

## Aktuelle Ressourcen-Nodes

Die aktuelle Ground-Resource-Baseline führt für den Vier-Consumer-Scope bereits eigenständige CampaignState-Nodes:

```text
GROUND_NODE_FORTRESS
GROUND_NODE_WRIGHT
GROUND_NODE_HONAKER
GROUND_NODE_BOSTICK
```

Damit benötigt die Fire-Support-Rearm-Komposition keine neue strategische Ressourcenautorität und keine künstliche gemeinsame Bostick-Ressource für andere Standorte.

## Owner-Entscheidung – aktuelle DCS-Waffen bleiben zunächst bestehen

Nach Vergleich der in DCS verfügbaren BLUE-Alternativen bleibt die aktuelle Mission zunächst unverändert:

```text
Bostick   -> L118
Wright    -> L118
Fortress  -> L118
Honaker   -> 2B11 mortar
```

Für Bostick ist historische 155-mm-Feuerunterstützung belegt. Die verfügbare DCS-M109 bildet zwar Kaliber und Reichweitenklasse besser ab, bringt in der konkreten Kunar-Geometrie aber keinen ausreichenden operativen Reichweitengewinn, um die deutlich schlechtere visuelle und organisatorische Proxy-Passung zu rechtfertigen.

Daher erfolgt **kein aktueller Wechsel auf M109**. Diese Entscheidung ändert keine historische Quellenbewertung; sie ist eine Missionsdesign-/Proxy-Entscheidung.

## Owner-Entscheidung – DCS-Testzeit bündeln

Ein DCS-Lauf kostet praktisch mindestens etwa 30 Minuten. Kleine Folgetests, die nur unwesentlich vom unmittelbar vorherigen PASS abweichen, werden deshalb vermieden, sofern sie nicht der konkreten Fehlerbehebung oder Fehlerisolierung dienen.

Standard für diesen Scope:

```text
kein separater Bostick-only Regression Run

nächster DCS-Lauf nach Möglichkeit kombiniert:
- Bostick: Regression des bereits validierten Pfades nach Source-Härtung
- Wright: L118 Rearm
- Fortress: L118 Rearm
- Honaker: 2B11 Rearm über explicit RearmingGroup
- getrennte Subsystemmarker und getrennte Standortergebnisse
- ein Aggregatergebnis
```

Ein separater kleiner Lauf ist nur vorgesehen, wenn ein konkreter Fehler anders nicht sauber isoliert oder behoben werden kann.

## Noch nicht bestätigt

```text
- generischer FixedFireSupportAmmoSupport in DCS
- generischer FixedFireSupportAmmoRearmService in DCS
- Wright L118 rearm in DCS
- Fortress L118 rearm in DCS
- Honaker 2B11 mortar rearm in DCS
- CHAP_M1083 behavior for those three receivers
- per-site support origin/parking/road geometry
- per-site quantity policy beyond existing GROUND_AMMO_PACKAGE semantics
- restart/replay semantics for CONSUMED but not durably completed LOCAL REARM
```

Diese Punkte dürfen nicht aus dem Bostick-PASS extrapoliert werden.

## Nächster technischer Schritt

Die Source-Generalisation ist jetzt als standortneutraler Contract vorbereitet. Vor dem nächsten DCS-Lauf folgt:

```text
1. Source-/Contract-Diff prüfen.
2. Generische Contract-Tests in die Ground-Test-Suite aufnehmen.
3. Kombinierten Vier-Consumer-Acceptance-Harness entwerfen.
4. Pro Standort sichere und eindeutige Testziel-Geometrie festlegen.
5. Notwendige MIZ-Änderungen vor Mutation ausdrücklich freigeben.
6. EIN kombiniertes Bundle bauen und per Hashkette in die freigegebene MIZ einbinden.
7. EINEN kombinierten DCS-Lauf durchführen.
```

Kein identischer oder nahezu identischer Bostick-Einzellauf wird ohne Fehlerbehebungsgrund wiederholt.
