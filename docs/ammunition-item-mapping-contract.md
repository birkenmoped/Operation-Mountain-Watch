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
validated_in_dcs: partial
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

## 4. Acceptance-Grundlagen

### 4.1 Item-Sichtbarkeit

`STORAGE-WEAPON-ITEM-MATRIX-1`:

```text
Source/Builder commit: 19836e4862e0b0a1d6bc1cee987cb9ce308ee3eb
DCS: 2.9.28.26385 MT
MIZ SHA-256: 9431918c103359d0207db9b98c1cdb938afc48e55e0b828c21a8eb1a15a39c11
Bundle SHA-256: 46568c872d29e3542fddc47d781897f75d2f40a057b995e0b4c1437ae0877aa5
MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS, 7/7 STORAGE endpoints
```

Dieser Test war read-only und bestätigte Item-Sichtbarkeit sowie numerische `GetItemAmount()`-Rückgaben.

### 4.2 AH-64D External-Store-Debit

`STORAGE-WEAPON-CONSUMPTION-CORRELATION-1`:

```text
Source/Builder commit: 4844c4fab70e1227e6e96a70b8747cc12238190d
DCS: 2.9.28.26385 MT
Executed MIZ SHA-256: abfaff193ac3618d2e0e3414d0ffd88f51f009c5b4b7f35f3ba8350459207093
Internal mission SHA-256: 28fd89a1ac9c3556d97bb438a90ec9db6c47f60d6550e241ad904173b06c5819
Correlation bundle SHA-256: 1fe44ed294784563a358148fb0463b6ce93fb7c8bbd506de1c43128a361cd729
MOOSE SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS, 7/7 STORAGE endpoints, 3 isolated Shindand weapon deltas
```

Die isolierte Aktion materialisierte eine `grouping=2` AH-64D-CAS-Assetgruppe. Beobachtet wurden:

```text
weapons.nurs.HYDRA_70_M151: -76
weapons.missiles.AGM_114K: -4
weapons.droptanks.{IAFS_ComboPak_100}: -2
```

Dies entspricht pro AH-64D `38 x M151`, `2 x AGM-114K` und `1 x IAFS ComboPak`.

## 5. Mapping-Matrix

| Strategic Resource ID | MOOSE/DCS item family | Runtime status | Produktiver Mirror-Status |
|---|---|---|---|
| `AMMUNITION_HELLFIRE` | `weapons.missiles.AGM_114K` für die getestete OMW-AH-64D-CAS-Payload; `weapons.missiles.AGM_114` bleibt als sichtbarer anderer Kandidat | `AGM_114K` debit-semantics DCS-validiert: 2 Stück je AH-64D der getesteten Payload | `PAYLOAD_VARIANT_DEBIT_VALIDATED`; kein generischer Hellfire-Familien-Mirror über alle Varianten |
| `AMMUNITION_ROCKETS_70MM` | `weapons.nurs.HYDRA_70_M151` für die getestete OMW-AH-64D-CAS-Payload; weitere Hydra-/AGR-20-Varianten separat | `HYDRA_70_M151` debit-semantics DCS-validiert: 38 Stück je AH-64D der getesteten Payload | `PAYLOAD_VARIANT_DEBIT_VALIDATED`; andere 70-mm-Varianten weiterhin separat zu korrelieren |
| `AMMUNITION_30MM_M230` | `weapons.gunmounts.M230`, `weapons.shells.M230_*` | geprüfte Kandidaten lieferten `0`; AH-64-Materialisierung erzeugte keinen zusätzlich beobachteten M230/M789-Inventory-Delta | `NO_DIRECT_STORAGE_MIRROR_YET` |
| `AMMUNITION_30MM_GAU8` | `weapons.shells.GAU8_30_*` | geprüfte Kandidaten lieferten `0` | `NO_DIRECT_STORAGE_MIRROR_YET` |
| `AMMUNITION_50CAL_M3P` | `weapons.containers.OH58D_M3P_L100/L200/L300/L400/L500`; zusätzlich gunmount/shell candidates | Container-Keys im Inventory sichtbar; geprüfte gunmount/shell candidates lieferten `0` | `CONTAINER_PATH_VISIBLE_SEMANTICS_UNRESOLVED` |

## 6. Hellfire

Für die getestete OMW-AH-64D-CAS-Payload ist jetzt praktisch bestätigt:

```text
Strategic family: AMMUNITION_HELLFIRE
DCS/MOOSE debit item: weapons.missiles.AGM_114K
Observed quantity: 2 per AH-64D
Observed 2-ship quantity: 4
```

Der read-only Korrelationslauf beweist diese konkrete Payload-Variante. Er beweist nicht, dass `weapons.missiles.AGM_114` oder andere Hellfire-Varianten identische Buchungssemantik haben. Eine produktive Mappingliste muss deshalb payload- beziehungsweise variantenspezifisch bleiben.

## 7. Hydra 70 und AGR-20

Für die getestete OMW-AH-64D-CAS-Payload ist jetzt praktisch bestätigt:

```text
Strategic family: AMMUNITION_ROCKETS_70MM
DCS/MOOSE debit item: weapons.nurs.HYDRA_70_M151
Observed quantity: 38 per AH-64D
Observed 2-ship quantity: 76
```

Weitere Hydra-70-Varianten sowie AGR-20/APKWS werden nicht automatisch dieser konkreten debit-validierten Variante gleichgesetzt. Ihre technische Kaliberverwandtschaft genügt nicht; weitere produktive Varianten benötigen eigene Payload-/Historik-Baseline und bei relevanter Mengen-Semantik eine eigene Runtime-Korrelation.

## 8. M230 30 mm

Für die geprüften MOOSE/DCS-Kandidaten des AH-64-M230-Pfads wurde im Item-Matrix-Lauf kein positiver Warehouse-Item-Bestand beobachtet. Der spätere isolierte AH-64D-CAS-Korrelationslauf zeigte trotz Materialisierung der 2-Ship-Gruppe ebenfalls keinen zusätzlichen M230/M789-Weapon-Inventory-Delta.

Daraus folgt:

```text
AMMUNITION_30MM_M230
!= currently proven direct STORAGE item mirror
```

Bis ein tatsächlicher Beladungs-/Verbrauchspfad korreliert ist, bleibt diese Resource ausschließlich strategisch in CampaignState und darf nicht über einen geratenen Shell- oder Gunmount-Key gespiegelt werden.

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

## 11. IAFS ComboPak

Der AH-64D-Korrelationslauf beobachtete zusätzlich:

```text
weapons.droptanks.{IAFS_ComboPak_100}
Observed quantity: 1 per AH-64D
Observed 2-ship quantity: 2
```

Dieses Item ist keine der fünf strategischen Munitionsressourcen dieses Vertrags. Der Befund wird als Payload-/Warehouse-Telemetrie festgehalten und nicht stillschweigend einer Munitions-Resource-ID zugeordnet.

## 12. Nächste Runtime-Gates

Die verbleibenden Mapping-Lücken liegen weiterhin in der konkreten DCS-Warehouse-Buchungssemantik, nicht in einer fehlenden MOOSE-STORAGE-Abstraktion.

Als naechste gezielte Korrelationsgates sind fachlich sinnvoll:

```text
A-10 / GAU-8 isolated payload or rearm correlation
OH-58 / M3P isolated container debit correlation
M230-specific correlation only if a DCS warehouse representation can be observed
unused-store return / recredit behavior for already validated external stores
```

Die Tests sollen weiterhin MOOSE `STORAGE:GetInventory()` / `GetItemAmount()` zur Beobachtung nutzen und keine eigene Warehouse-Mechanik implementieren.

## 13. Implementierungsgrenze

Bis zu den jeweiligen erfolgreichen Korrelationsgates ist verboten:

```text
automatic CampaignState-to-STORAGE weapon mirror for M230, GAU-8 or M3P
invented shell-to-resource conversion factors
container-count == round-count assumptions
cross-use between M230 and GAU-8 resources
generic AMMUNITION_30MM fallback
generic AMMUNITION_50CAL fallback for OH-58 M3P
```

Für die DCS-validierten AH-64D-Varianten `HYDRA_70_M151` und `AGM_114K` ist die konkrete Warehouse-Debit-Semantik bestätigt. Eine strategische CampaignState-Verbrauchsautomatik oder ein schreibender STORAGE-Adapter ist damit noch nicht genehmigt oder getestet.