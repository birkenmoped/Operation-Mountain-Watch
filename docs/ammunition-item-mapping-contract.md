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

### 4.3 Airborne Ammo / Parking Correlation

Der Lauf `AIRBORNE-AMMO-PARKING-CORRELATION-3` liefert zusätzlich den praktischen Payload-/STORAGE-Abgleich für die bereits beschlossenen OMW-Templates:

```text
Branch: agent/airborne-ammo-parking-correlation
Source commit: 5ad6d2c535c2e6796a677fd18975be794533ab8b
BuilderVersion: AIRBORNE-AMMO-PARKING-CORRELATION-3
Bundle SHA-256: cb650dd8bab448de39eb1a26f4bc856964f375600df51a5587fcf02c521a65fd
MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: 8f345af681276bc8634128b023873be4473df459deb2f6f9b230f3cbd901c84d
DCS: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: a0473859853a2786c188b3cf3c3095e570806c20b6cb49216e9befe0ac6df7b8
debrief.log SHA-256: 5b083460b339b78aa6d8d1754e60c81d10c3f7e84f56f9f74eedece6fc31eca3
```

Die nachfolgenden Zuordnungen sind damit keine Ableitung aus Mission-Editor-Labels, sondern tatsächlich beobachtete STORAGE-Deltas der getesteten Templates.

## 5. Mapping-Matrix

| Strategic Resource ID | MOOSE/DCS item family | Runtime status | Produktiver Mirror-Status |
|---|---|---|---|
| `AMMUNITION_HELLFIRE` | `weapons.missiles.AGM_114K` für die getestete OMW-AH-64D-CAS-Payload; `weapons.missiles.AGM_114` bleibt als sichtbarer anderer Kandidat | `AGM_114K` debit-semantics DCS-validiert: 2 Stück je AH-64D der getesteten Payload | `PAYLOAD_VARIANT_DEBIT_VALIDATED`; kein generischer Hellfire-Familien-Mirror über alle Varianten |
| `AMMUNITION_ROCKETS_70MM` | `weapons.nurs.HYDRA_70_M151` für die getestete OMW-AH-64D-/OH-58D-Payload; `weapons.nurs.HYDRA_70_M156` für die getestete Kandahar-A-10C-Payload | `M151` und `M156` als reale Template-Debits beobachtet; Varianten bleiben technisch getrennt | `PAYLOAD_VARIANT_DEBIT_VALIDATED`; strategische Familienaggregation darf die konkreten DCS-Varianten nicht verlieren |
| `AMMUNITION_30MM_M230` | `weapons.gunmounts.M230`, `weapons.shells.M230_*` | geprüfte Kandidaten lieferten `0`; reale M230-Abgabe ist per `FLIGHTGROUP:GetAmmoTot()`/Debrief belegbar, aber ohne direkten STORAGE-Round-Delta | `TELEMETRY_ONLY_NO_DIRECT_STORAGE_MIRROR` |
| `AMMUNITION_30MM_GAU8` | `weapons.shells.GAU8_30_*` | geprüfte Kandidaten lieferten `0`; reale GAU-8-Abgabe ist per `FLIGHTGROUP:GetAmmoTot()`/Debrief und physischem Return belegt | `TELEMETRY_ONLY_NO_DIRECT_STORAGE_MIRROR` |
| `AMMUNITION_50CAL_M3P` | `weapons.containers.OH58D_M3P_L500` für die aktuelle OMW-Standardpayload; weitere L100/L200/L300/L400-Container sichtbar | L500 wird je OH-58D als ein Container debitiert; keine belastbare Round-Conversion und kein normaler Container-Recredit nach realer M3P-Abgabe belegt | `STORE_WITHOUT_ROUND_CONVERSION` |

## 6. Hellfire

Für die getestete OMW-AH-64D-CAS-Payload ist jetzt praktisch bestätigt:

```text
Strategic family: AMMUNITION_HELLFIRE
DCS/MOOSE debit item: weapons.missiles.AGM_114K
Observed quantity: 2 per AH-64D
Observed 2-ship quantity: 4
```

Der read-only Korrelationslauf beweist diese konkrete Payload-Variante. Er beweist nicht, dass `weapons.missiles.AGM_114` oder andere Hellfire-Varianten identische Buchungssemantik haben. Eine produktive Mappingliste muss deshalb payload- beziehungsweise variantenspezifisch bleiben.

## 7. Hydra 70

Für die getestete OMW-AH-64D-CAS-Payload ist praktisch bestätigt:

```text
DCS/MOOSE item: weapons.nurs.HYDRA_70_M151
Observed quantity: 38 per AH-64D
Observed 2-ship quantity: 76
```

Für die getestete OMW-OH-58D-Standardpayload wurde zusätzlich beobachtet:

```text
DCS/MOOSE item: weapons.nurs.HYDRA_70_M151
Observed quantity: 7 per OH-58D
Observed 2-ship quantity: 14
```

Für die beschlossene Kandahar-A-10C-CAS-Payload wurde beobachtet:

```text
DCS/MOOSE item: weapons.nurs.HYDRA_70_M156
Observed quantity: 7 per A-10C
Observed 2-ship quantity: 14
```

Damit sind M151 und M156 konkrete DCS-Warehouse-Items innerhalb derselben strategischen 70-mm-Familie, aber nicht derselbe technische STORAGE-Key.

## 8. M230 30 mm

Für die geprüften MOOSE/DCS-Kandidaten des AH-64-M230-Pfads wurde im Item-Matrix-Lauf kein positiver Warehouse-Item-Bestand beobachtet. Die späteren Airborne-Korrelationsläufe belegten reale M230-Abgabe über `FLIGHTGROUP:GetAmmoTot()` und DCS-Debrief, aber keinen direkten M230/M789-Weapon-Inventory-Delta.

Daraus folgt:

```text
AMMUNITION_30MM_M230
!= direct STORAGE round mirror
```

Bis ein tatsächlicher Warehouse-Round-Pfad nachgewiesen wird, bleibt diese Resource strategisch in CampaignState und wird operativ nur über bestätigte Onboard-Telemetrie korreliert.

## 9. GAU-8 30 mm

Für die geprüften `GAU8_30_*`-Shell-Kandidaten wurde kein positiver Warehouse-Item-Bestand beobachtet. Im Lauf `AIRBORNE-AMMO-PARKING-CORRELATION-3` wurden dagegen real `536` verschossene GAU-8-Runden sowohl über `FLIGHTGROUP:GetAmmoTot()` als auch im DCS-Debrief korreliert. Beide A-10C wurden vom Projektinhaber physisch bis Parking und Engine shutdown beobachtet.

Damit gilt:

```text
AMMUNITION_30MM_GAU8
-> strategic CampaignState count
-> onboard/debrief telemetry available
-> no direct STORAGE round mirror
```

M230- und GAU-8-Bestände bleiben strategisch getrennt und erhalten keine gemeinsame Fallback-Zuordnung.

## 10. OH-58 M3P .50 cal

Für die aktuelle OMW-OH-58D-Standardpayload wurde beim Materialisieren eines 2-Ship beobachtet:

```text
weapons.containers.OH58D_M3P_L500: -2
weapons.nurs.HYDRA_70_M151:        -14
FLIGHTGROUP:GetAmmoTot():          1600 gun rounds + 14 rockets
```

Der saubere Vorgängerlauf belegte reale M3P-Abgabe und normalen Aircraft-Return, ohne daraus einen belastbaren `L500 == 500 rounds`-Warehouse-Recredit abzuleiten. Der aktuelle Parking-Correlation-Lauf ist wegen Baumkollision/Notlandung eines Elements für eine erneute Round-Korrelation kontaminiert.

Die L100/L200/L300/L400/L500-Bezeichnungen dürfen deshalb weiterhin nicht als frei konvertierbare Einzelrundenbestände interpretiert werden.

Daher gilt:

```text
AMMUNITION_50CAL_M3P
-> strategic CampaignState count
-> DCS container path weapons.containers.OH58D_M3P_L500 for the current payload
-> no approved container-to-round conversion factor
```

## 11. IAFS ComboPak

Der AH-64D-Korrelationslauf beobachtete zusätzlich:

```text
weapons.droptanks.{IAFS_ComboPak_100}
Observed quantity: 1 per AH-64D
Observed 2-ship quantity: 2
```

Das Item wurde bei Materialisierung debitiert, aber bei normaler Rückkehr nicht wieder gutgeschrieben. Es ist keine der fünf strategischen Munitionsressourcen dieses Vertrags und bleibt `TECHNICAL_NON_STRATEGIC`.

## 12. Beschlossene Payloads: beobachtete DCS/STORAGE-Items

### 12.1 Kandahar A-10C II CAS

Die bereits beschlossene OMW-Payload wurde im Runtime-Lauf technisch wie folgt aufgelöst:

```text
2-ship debit:
weapons.bombs.GBU_38                  -8
weapons.bombs.LUU_2B                  -16
weapons.containers.AAQ-28_LITENING    -2
weapons.missiles.AGM_65D              -2
weapons.nurs.HYDRA_70_M156            -14
```

Das entspricht exakt pro Aircraft:

```text
4 x GBU-38
8 x LUU-2B via SUU-25
1 x AAQ-28 LITENING
1 x AGM-65D
7 x Hydra 70 M156
```

Ein bereits dokumentierter normaler A-10C-CAS-Lifecycle-Lauf wies für diese fünf STORAGE-Items `weaponDebitTotal=42`, `weaponRecovered=42` und `weaponRecredit=FULL` aus. Die externen Stores dieser Payload verhalten sich damit im getesteten normalen Return-Pfad als vollständig rückgabefähige operative Warehouse-Items, solange sie nicht verbraucht wurden.

### 12.2 Bagram F-16C CAS

Die beschlossene Vanilla-DCS-Ersatzpayload wurde im Runtime-Lauf technisch bestätigt:

```text
2-ship debit:
weapons.bombs.GBU_12                   -4
weapons.bombs.GBU_38                   -4
weapons.containers.AN_AAQ_33           -2
weapons.droptanks.fuel_tank_370gal     -4
weapons.missiles.AIM_120C              -4
```

Damit ist für den getesteten Missionsstand zugleich geklärt, dass der tatsächlich gespeicherte AIM-120-Subtyp `AIM_120C` und der TGP-STORAGE-Key `AN_AAQ_33` ist.

Beim normalen Return wurden beobachtet:

```text
GBU_12       +4
GBU_38       +4
AN_AAQ_33    +2
AIM_120C     +4
370gal tank   0 observed recredit
```

Die beiden 370-gal-Tanks pro Aircraft werden also beim Materialisieren real aus STORAGE entnommen, im getesteten normalen AIRWING-Return aber nicht wieder gutgeschrieben.

### 12.3 Bagram F-15E CAS

Die beschlossene F-15E-CAS-Payload wurde im Runtime-Lauf technisch bestätigt:

```text
2-ship debit:
weapons.bombs.GBU_38                       -6
weapons.bombs.GBU_54_V_1B                  -6
weapons.containers.F-15E_AAQ-13_LANTIRN    -2
weapons.containers.F-15E_AAQ-14_LANTIRN    -2
weapons.droptanks.F-15E_Drop_Tank          -4
weapons.missiles.AIM_120C                   -2
weapons.missiles.AIM_9                      -2
```

Das entspricht pro Aircraft der beschlossenen `3 + 3`-CAS-Bombenmischung, zwei externen Tanks, je einem AIM-120/AIM-9 sowie beiden LANTIRN-Containern. Der Runtime-Key `AIM_9` bleibt der technisch beobachtete STORAGE-Key; die genaue Mission-Editor-Subtypbezeichnung wird dadurch nicht neu interpretiert.

Beim normalen Return wurden beobachtet:

```text
GBU_38                    +6
GBU_54_V_1B               +6
F-15E_AAQ-13_LANTIRN      +2
F-15E_AAQ-14_LANTIRN      +2
AIM_120C                   +2
AIM_9                      +2
F-15E_Drop_Tank             0 observed recredit
```

Auch die F-15E-Drop-Tanks werden damit real bei Materialisierung debitiert, aber im getesteten normalen Return nicht wieder gutgeschrieben.

## 13. Utility-Helicopter-Bordwaffen

Der gleiche Lauf liefert für die noch offenen Utility-Helicopter-Fragen:

```text
UH-60A:
  FLIGHTGROUP:GetAmmoTot() = 0
  no weapon STORAGE delta observed

CH-47F:
  FLIGHTGROUP:GetAmmoTot().Guns = 800
  weapons.containers.{CH47_PORT_M60D} -1 on spawn / +1 on normal return
  weapons.containers.{CH47_STBD_M60D} -1 on spawn / +1 on normal return
  no real M60D expenditure observed in the tested mission
```

Damit ist für das getestete UH-60A-Template kein Bordwaffenbestand vorhanden. Für das CH-47F-Template sind zwei M60D-Container technisch als rückgabefähige Stores sichtbar; aus den `800` Onboard-Runden wird ohne realen Schusstest keine Container-zu-Round-Conversion abgeleitet.

## 14. Externe Tanks: technische Ausnahmefrage

Der F-16C- und F-15E-Lauf zeigt dasselbe Muster:

```text
spawn: external tank debit
normal return: no external tank recredit
unused bombs/missiles/pods: normal recredit
```

Damit ist die fehlende Tankrückgabe kein bloßer Verdacht mehr, sondern für beide getesteten Fixed-Wing-Templates reproduzierbar im selben DCS-/MOOSE-Lauf beobachtet worden.

Noch **nicht** entschieden wird in diesem Vertrag, ob externe Tanks strategisch als:

```text
TECHNICAL_NON_STRATEGIC
unlimited DCS warehouse item
explicit CampaignState exception
or compensated operational mirror item
```

geführt werden. Eine künstliche Rückgabe darf nicht stillschweigend implementiert werden. Die endgültige Policy benötigt eine ausdrückliche Owner-Entscheidung, weil sie die Ressourcenhoheit und Warehouse-Semantik beeinflusst.

## 15. Nächste Runtime-Gates

Durch den vorhandenen Lauf sind A-10C-, F-16C- und F-15E-Payload-Item-Identitäten für die getesteten CAS-Templates bereits technisch korreliert; dafür ist kein weiterer reiner Spawn-Census erforderlich.

Offen bleiben gezielt:

```text
F-15E STRIKE template: GBU-31(V)1/B and GBU-31(V)3/B item correlation
CH-47 M60D: real-fire round/container semantics only if later required
M230 direct STORAGE representation only if a positive item path becomes observable
external-tank production policy decision
unused-store behavior for any future payload variant not covered above
```

Die Tests sollen weiterhin MOOSE `STORAGE:GetInventory()` / `GetItemAmount()` zur Beobachtung nutzen und keine eigene Warehouse-Mechanik implementieren.

## 16. Implementierungsgrenze

Bis zu den jeweiligen erfolgreichen Korrelationsgates beziehungsweise Owner-Entscheidungen ist verboten:

```text
automatic CampaignState-to-STORAGE weapon mirror for M230, GAU-8 or M3P
invented shell-to-resource conversion factors
container-count == round-count assumptions
cross-use between M230 and GAU-8 resources
generic AMMUNITION_30MM fallback
generic AMMUNITION_50CAL fallback for OH-58 M3P
artificial external-tank recredit without approved policy
```

Für die DCS-validierten konkreten Payload-Items ist die beobachtete Warehouse-Debit-/Return-Semantik dokumentiert. Eine strategische CampaignState-Verbrauchsautomatik oder ein schreibender STORAGE-Adapter ist damit noch nicht automatisch genehmigt oder getestet.
