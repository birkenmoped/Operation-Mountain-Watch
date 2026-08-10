---
document_id: OMW-ARCH-AMMUNITION-ITEM-MAPPING-CONTRACT
status: BINDING
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - current strategic-ammunition to MOOSE STORAGE item mapping status
  - accepted and unresolved weapon-item correlations
  - prohibition of unverified direct STORAGE mirrors for gun ammunition
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ammunition-exact-item-mapping
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/ammunition-resource-id-split
base_commit: d0fb954d6367364c303f7fd3173c0070baa2daeb
base_status: BINDING_PROJECT_DECISION_CHILD_BRANCH
merged_to_main: false
inherited_risk:
  - parent resource-ID decision is not yet merged to main
---

# Ammunition Item-Mapping Contract

## 1. Zweck

Dieses Dokument setzt die freigegebene Trennung der strategischen Munitionsressourcen in einen belastbaren technischen Mapping-Status um. Es trennt ausdrücklich zwischen:

```text
strategic CampaignState resource identity
MOOSE STORAGE / DCS warehouse item identity
AIRWING payload identity and availability
```

Die Resource IDs bleiben strategische Eigentums- und Reservierungsobjekte. Ein DCS-/MOOSE-Item wird erst dann als operativer Mirror einer Resource ID verwendet, wenn die Zuordnung und ihre Mengen-Semantik praktisch belegt sind.

## 2. Verbindliche strategische IDs

```text
AMMUNITION_HELLFIRE
AMMUNITION_ROCKETS_70MM
AMMUNITION_30MM_M230
AMMUNITION_30MM_GAU8
AMMUNITION_50CAL_M3P
```

Die drei systemspezifischen IDs wurden durch `OMW-ARCH-AMMUNITION-RESOURCE-ID-CONTRACT` freigegeben. Sie sind untereinander nicht austauschbar.

## 3. MOOSE-First-Stand

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im tatsächlich verwendeten `Moose.lua` sind für diesen Vertrag insbesondere bestätigt:

```text
STORAGE:GetInventory()
STORAGE:GetItemAmount(Name)
STORAGE:SetItem(Name, Amount)
STORAGE:AddItem(Name, Amount)
STORAGE:RemoveItem(Name, Amount)
ENUMS.Storage.weapons
```

`STORAGE:GetItemAmount()` delegiert im gepinnten Quellstand direkt an `warehouse:getItemCount(Name)`. Die Source-Prüfung belegt damit den verwendeten MOOSE-Pfad; sie ersetzt nicht die Runtime-Zuordnung eines konkreten Aircraft-/Payload-Verbrauchs.

## 4. Acceptance-Grundlage

Maßgeblich ist `STORAGE-WEAPON-ITEM-MATRIX-1`:

```text
Source/Builder commit: 19836e4862e0b0a1d6bc1cee987cb9ce308ee3eb
DCS: 2.9.28.26385 MT
MIZ SHA-256: 9431918c103359d0207db9b98c1cdb938afc48e55e0b828c21a8eb1a15a39c11
Bundle SHA-256: 46568c872d29e3542fddc47d781897f75d2f40a057b995e0b4c1437ae0877aa5
MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS, 7/7 STORAGE endpoints
```

Der Test war read-only. Er hat Item-Sichtbarkeit und numerische `GetItemAmount()`-Rückgaben bestätigt, aber keine Beladungs-, Rearm-, Verbrauchs- oder Rückgabebuchung ausgelöst.

## 5. Mapping-Matrix

| Strategic Resource ID | MOOSE/DCS item family | Runtime status | Produktiver Mirror-Status |
|---|---|---|---|
| `AMMUNITION_HELLFIRE` | `weapons.missiles.AGM_114`, `weapons.missiles.AGM_114K` | beide im Acceptance-Lauf numerisch sichtbar | `CANDIDATE_CONFIRMED`; konkreter Payload-Verbrauch noch zu korrelieren |
| `AMMUNITION_ROCKETS_70MM` | mehrere `weapons.nurs.HYDRA_70_*` | mehrere Hydra-Varianten im Acceptance-Lauf numerisch sichtbar | `CANDIDATE_CONFIRMED`; zugelassene OMW-Varianten noch auf Payload-/Historik-Baseline begrenzen |
| `AMMUNITION_30MM_M230` | `weapons.gunmounts.M230`, `weapons.shells.M230_*` | geprüfte Kandidaten lieferten `0` | `NO_DIRECT_STORAGE_MIRROR_YET` |
| `AMMUNITION_30MM_GAU8` | `weapons.shells.GAU8_30_*` | geprüfte Kandidaten lieferten `0` | `NO_DIRECT_STORAGE_MIRROR_YET` |
| `AMMUNITION_50CAL_M3P` | `weapons.containers.OH58D_M3P_L100/L200/L300/L400/L500`; zusätzlich gunmount/shell candidates | Container-Keys im Inventory sichtbar; geprüfte gunmount/shell candidates lieferten `0` | `CONTAINER_PATH_VISIBLE_SEMANTICS_UNRESOLVED` |

## 6. Hellfire

Für den akzeptierten Runtime-Stand wurden mindestens folgende Items mit numerischem Bestand beobachtet:

```text
weapons.missiles.AGM_114
weapons.missiles.AGM_114K
```

Damit ist die Itemfamilie technisch belastbar sichtbar. Noch nicht belegt ist, welche konkrete OMW-AIRWING-Payloadvariante welchen Item-Key und welche Stückzahl beim Beladen beziehungsweise Rearm tatsächlich abbucht.

Folge: Noch kein automatischer CampaignState-to-STORAGE-Mirror und noch keine automatische Verbrauchsbuchung.

## 7. Hydra 70 und AGR-20

Der gepinnte MOOSE-Enum enthält mehrere Hydra-70-Varianten. Im Acceptance-Lauf waren mehrere davon numerisch sichtbar. Zusätzlich wurden unter anderem folgende Keys beobachtet:

```text
weapons.missiles.AGR_20A
weapons.missiles.AGR_20_M282
weapons.nurs.HYDRA_70_WTU1B
weapons.nurs.HYDRA_70_MK5
```

AGR-20/APKWS wird nicht automatisch `AMMUNITION_ROCKETS_70MM` zugeschlagen. Die technische Kaliberverwandtschaft allein genügt nicht. Zulässige OMW-Varianten müssen aus aktiver Payload- und historischer Baseline hervorgehen.

## 8. M230 30 mm

Für die geprüften MOOSE/DCS-Kandidaten des AH-64-M230-Pfads wurde im Acceptance-Lauf kein positiver Warehouse-Item-Bestand beobachtet. Das gilt unter anderem für die geprüften `gunmounts`-/`shells`-Kandidaten.

Daraus folgt ausdrücklich nicht, dass M230-Munition in DCS nicht existiert oder nicht verbraucht wird. Es folgt nur:

```text
AMMUNITION_30MM_M230
!= currently proven direct STORAGE item mirror
```

Bis ein tatsächlicher Beladungs-/Verbrauchspfad korreliert ist, bleibt diese Resource ausschließlich strategisch in CampaignState und darf nicht über einen geratenen Shell-Key gespiegelt werden.

## 9. GAU-8 30 mm

Für die geprüften `GAU8_30_*`-Shell-Kandidaten wurde im Acceptance-Lauf ebenfalls kein positiver Warehouse-Item-Bestand beobachtet.

Damit gilt analog:

```text
AMMUNITION_30MM_GAU8
!= currently proven direct STORAGE item mirror
```

M230- und GAU-8-Bestände bleiben strategisch getrennt und erhalten keine gemeinsame Fallback-Zuordnung.

## 10. OH-58 M3P .50 cal

Der Runtime-Lauf machte folgende Container-/Store-Keys sichtbar:

```text
weapons.containers.OH58D_M3P_L100
weapons.containers.OH58D_M3P_L200
weapons.containers.OH58D_M3P_L300
weapons.containers.OH58D_M3P_L400
weapons.containers.OH58D_M3P_L500
```

Der MOOSE-Enum enthält zusätzlich gleichnamige `gunmounts`-Varianten sowie .50-cal-Shell-Kandidaten. Die geprüften gunmount/shell candidates lieferten im Acceptance-Lauf `0`.

Die sichtbaren Container-Keys dürfen nicht stillschweigend als einzelne .50-cal-Runden interpretiert werden. Ihre L100/L200/L300/L400/L500-Bezeichnung legt eine Kapazitäts-/Store-Semantik nahe, aber deren genaue DCS-Warehouse-Buchungssemantik ist erst praktisch zu beweisen.

Daher gilt:

```text
AMMUNITION_50CAL_M3P
-> strategic CampaignState count
-> no direct STORAGE conversion factor yet
```

## 11. Nächster Runtime-Gate

Die verbleibende technische Lücke ist kein MOOSE-Funktionsdefizit. MOOSE stellt den benötigten STORAGE-Lese-/Schreibpfad bereit. Unbekannt ist die DCS-Warehouse-Buchungssemantik konkreter Flugzeugbewaffnung.

Deshalb wird als nächster Test ein read-only Korrelationsgate vorgesehen:

```text
STORAGE-WEAPON-CONSUMPTION-CORRELATION-1
```

Ziel des Gates:

```text
pre-load STORAGE snapshot
-> konkrete, bereits genehmigte OMW-Aircraft-/Payload-Aktion
-> post-load / post-rearm STORAGE snapshot
-> delta je beobachtetem Item-Key
-> keine Test-seitige SetItem/AddItem/RemoveItem-Mutation
-> keine CampaignState-Mutation
```

Der Test darf MOOSE `STORAGE:GetInventory()` und `STORAGE:GetItemAmount()` zur Beobachtung verwenden. Er darf keine eigene Warehouse-Mechanik implementieren. Die operative Aircraft-/Payload-Ausführung muss über bereits vorhandene MOOSE-/DCS-Funktionalität erfolgen und wird vor Implementierung gegen den gepinnten MOOSE-Stand geprüft.

## 12. Implementierungsgrenze

Bis zum erfolgreichen Korrelationsgate ist verboten:

```text
automatic CampaignState-to-STORAGE weapon mirror for M230, GAU-8 or M3P
invented shell-to-resource conversion factors
container-count == round-count assumptions
cross-use between M230 and GAU-8 resources
generic AMMUNITION_30MM fallback
generic AMMUNITION_50CAL fallback for OH-58 M3P
```

Hellfire/Hydra dürfen ebenfalls noch nicht automatisch verbrauchsgebucht werden, solange der konkrete Payload-Delta-Pfad nicht bestätigt ist.
