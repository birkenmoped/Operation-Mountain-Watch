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

Vor einer produktiven Ausweitung darf daher nicht je FOB ein eigener nahezu identischer Rearm-Stack kopiert werden. Der nächste Architektur-Review muss prüfen, welche Bostick-spezifischen Teile reine Konfiguration sind und in einen gemeinsamen Fixed-Fire-Support-Rearm-Service überführt werden können.

Dabei bleiben verbindlich:

```text
CampaignState = einzige strategische Ressourcenautorität
MOOSE ARTY = operativer Fire-Support-/Rearm-Lifecycle
MOOSE WAREHOUSE/BRIGADE/PLATOON = bestehende physische Support-Materialisierung
DCS groups = temporäre physische Repräsentation
```

Keine zusätzliche Native-DCS-Rearm-Logik, kein eigener Truck-Dispatcher und keine zweite Ressourcenhoheit werden eingeführt.

## Noch nicht bestätigt

```text
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

Zuerst wird der aktuelle Branch-Source nach Abschluss der bereits gestagten Lifecycle-Hygiene gegen diesen Vier-Consumer-Scope reconciliiert. Ziel ist die kleinste MOOSE-first Generalisierung ohne Duplikation der bestehenden Bostick-Komposition.

Ein weiterer DCS-Lauf wird erst nach Source-/Contract-Prüfung und einem kombinierten Acceptance-Plan angefordert; kein identischer Bostick-Einzellauf wird wiederholt.
