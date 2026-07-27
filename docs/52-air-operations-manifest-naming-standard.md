---
document_id: OMW-AIR-MANIFEST-NAMING
status: BINDING
document_class: AUTHORING_STANDARD
owning_policy: OMW-GOV-001
authoritative_for:
  - naming formulas for air operations manifests
  - Mission Editor group unit static warehouse airwing squadron and zone identifiers
  - consistency requirements for future basis-specific air manifests
not_authoritative_for:
  - active local aircraft inventories
  - historical unit selection
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - implicit naming patterns copied independently between basis manifests
superseded_by:
source_branch: agent/document-salerno-air-operations
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 52 – Benennungsstandard für Air-Operations-Manifeste

## 1. Zweck

Dieses Dokument macht das bislang in Jalalabad, Bagram und Kandahar verwendete Benennungsschema zur allgemeinen Arbeitsanweisung für alle bestehenden und zukünftigen Air-Operations-Manifeste.

Die Vorgaben gelten für:

- Client-Gruppen und enthaltene Units;
- Mission-Editor-KI-Templates und enthaltene Units;
- Luftfahrzeug-Statics;
- MOOSE-`AIRWING`- und `SQUADRON`-Namen;
- Warehouse-Anker;
- funktionsbezogene Zonen;
- basisbezogene Manifeste, Testharnesses und Acceptance-Skripte.

Abweichungen sind nur zulässig, wenn ein bestehendes autoritatives Manifest bereits einen anderen stabilen Namen verwendet oder eine technische Einschränkung dokumentiert ist. Namen werden nicht aus rein kosmetischen Gründen geändert.

## 2. Allgemeine Syntaxregeln

```text
Großbuchstaben:          ja
Worttrenner:             Unterstrich
Leerzeichen:             nein
Bindestriche in IDs:     nein
Sonderzeichen:           nein
fortlaufende Nummern:    zweistellig ab 01
Unit-Suffix:             _UNIT_01, _UNIT_02, ...
# in eigenen Namen:      verboten
```

Namen müssen:

1. eindeutig sein;
2. den Standort erkennen lassen;
3. Muster oder historische Rolle erkennen lassen;
4. bei Templates die vorgesehene OMW-Rolle und Gruppengröße erkennen lassen;
5. stabil bleiben, sobald sie in Skripten, Tests oder CampaignState referenziert werden;
6. Client-, Template-, Static- und Laufzeitnamen klar voneinander trennen.

## 3. Standortkürzel

Jedes Basenmanifest legt genau ein stabiles Standortkürzel fest.

Bestehende Beispiele:

| Standort | Kürzel |
|---|---|
| Bagram | `BGRM` |
| Jalalabad / FOB Fenty | `JBAD` |
| Kandahar | `KAF` |
| FOB Salerno | `SAL` |

Regeln:

- drei bis vier Großbuchstaben;
- innerhalb des Projekts eindeutig;
- nach produktiver Verwendung nicht umbenennen;
- das Kürzel steht in Client-, Template-, Static-, SQUADRON- und Zonennamen;
- ausgeschriebene Standortnamen werden für `AIRWING` und Warehouse bevorzugt.

## 4. Client-Gruppen

### 4.1 Formel

```text
CLIENT_<NATION>_<BASE>_<PLAYER_TYPE>_<NN>
```

Für US-Luftfahrzeuge:

```text
CLIENT_US_<BASE>_<PLAYER_TYPE>_<NN>
```

Enthaltene Unit:

```text
<CLIENT_GROUP_NAME>_UNIT_01
```

### 4.2 Beispiele

```text
CLIENT_US_SAL_AH64D_01
  CLIENT_US_SAL_AH64D_01_UNIT_01

CLIENT_US_BGRM_F15E_02
  CLIENT_US_BGRM_F15E_02_UNIT_01

CLIENT_US_KAF_CH47F_01
  CLIENT_US_KAF_CH47F_01_UNIT_01
```

### 4.3 Regeln

- eine Client-Gruppe enthält genau ein Luftfahrzeug;
- die Nummer bezeichnet den Slot, nicht eine historische Tail Number;
- der Typteil bezeichnet die tatsächlich vom Spieler verwendete DCS-Modulvariante;
- eine bewusste historische Ersatzdarstellung wird im Manifest dokumentiert;
- Rollen wie `CAS`, `RECON` oder `MEDEVAC` werden grundsätzlich nicht in Clientnamen aufgenommen;
- ein Muster erhält nicht mehrere Clientserien, nur um die projektweite Clientobergrenze zu umgehen.

## 5. KI-Template-Gruppen

### 5.1 Formel

```text
TPL_AIR_<NATION>_<BASE>_<TYPE_OR_ROLE>_<MISSION_ROLE>_<FORMATION>
```

Übliche Formationssuffixe:

```text
1SHIP
2SHIP
4SHIP
```

Enthaltene Units:

```text
<TEMPLATE_GROUP_NAME>_UNIT_01
<TEMPLATE_GROUP_NAME>_UNIT_02
...
```

### 5.2 Beispiele

```text
TPL_AIR_US_SAL_AH64D_CAS_2SHIP
  TPL_AIR_US_SAL_AH64D_CAS_2SHIP_UNIT_01
  TPL_AIR_US_SAL_AH64D_CAS_2SHIP_UNIT_02

TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP
  TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP_UNIT_01

TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
  TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP_UNIT_01
```

### 5.3 Typ- und Rollenwahl

Der Typteil darf je nach Zweck enthalten:

- das historische Muster, wenn DCS es passend abbildet;
- die historische Rolle, wenn das DCS-Modell nur technischer Ersatz ist;
- die für das Projekt stabile Musterfamilie, wenn mehrere DCS-Varianten dieselbe logische Rolle abbilden.

Beispiel:

```text
TPL_AIR_US_KAF_HH60G_CSAR_LEAD_1SHIP
```

Der Name bewahrt die historische HH-60G-/CSAR-Rolle, obwohl das eingesetzte DCS-Modell `UH-60A` sein kann.

### 5.4 Template-Regeln

- jedes Template ist `Late Activation`;
- `Uncontrolled = false`, sofern das Manifest nichts anderes festlegt;
- Templates sind Authoring-Seeds und kein zusätzlicher Kampagnenbestand;
- Gruppengröße steht zwingend im Namen;
- die enthaltene Unitzahl muss zum Formationssuffix passen;
- zusätzliche rollenidentische Templates werden nicht vorsorglich angelegt;
- vor separaten Escort-, Slingload-, Armed-Recon- oder Payloadvarianten ist MOOSE-first zu prüfen, ob `AUFTRAG`, Payloads, ROE oder `OPSTRANSPORT` denselben Seed wiederverwenden können;
- unterschiedliche physische Eigenschaften, die MOOSE nicht zuverlässig setzen kann, dürfen ein separates Template begründen, müssen aber dokumentiert werden.

## 6. Statische Luftfahrzeuge

### 6.1 Formel

```text
STATIC_AIR_<NATION>_<BASE>_<TYPE_OR_ROLE>_<NN>
```

### 6.2 Beispiele

```text
STATIC_AIR_US_SAL_AH64_01
STATIC_AIR_US_SAL_UH60_ASSAULT_03
STATIC_AIR_US_SAL_UH60_MEDEVAC_01
STATIC_AIR_US_KAF_HH60G_02
```

### 6.3 Regeln

- Statics sind sichtbare Repräsentationen des logischen Bestands;
- sie erhöhen den Kampagnenbestand nicht;
- bei technisch ersetzten Mustern darf der Name die historische Rolle führen;
- Rollen werden nur ergänzt, wenn mehrere organisatorisch getrennte Bestände dasselbe DCS-Modell verwenden;
- Nummern laufen innerhalb einer Serie ohne Lücken;
- ein Static wird nicht dauerhaft einem bestimmten Client- oder KI-Asset zugeordnet;
- Statics dürfen keine reservierten Client-, KI-, Ready-, Recovery-, Hot-Refueling- oder Sicherheitsflächen blockieren;
- bewusst blockierte DCS-Parking-Nodes werden diagnostisch erfasst und für dynamische KI gesperrt.

## 7. AIRWING

### 7.1 Formel

```text
AW_<NATION>_<FULL_LOCATION_NAME>
```

### 7.2 Beispiele

```text
AW_US_BAGRAM
AW_US_JALALABAD
AW_US_KANDAHAR
AW_US_SALERNO
AW_USMC_BASTION
```

### 7.3 Regeln

- grundsätzlich ein `AIRWING` pro physischem Flugplatz oder dauerhaftem Luftfahrtknoten;
- die ausgeschriebene stabile Ortsbezeichnung wird verwendet;
- Koalition oder Teilstreitkraft darf abgebildet werden, wenn sie organisatorisch relevant ist;
- ein zweiter AIRWING am selben physischen Knoten benötigt eine ausdrückliche Architektur- und Bestandsentscheidung;
- ein reines Transportziel, eine Landezone oder ein FARP ohne dauerhaft stationierten Bestand erhält nicht automatisch einen eigenen AIRWING.

## 8. SQUADRON

### 8.1 Formel

```text
SQ_<NATION>_<BASE>_<TYPE>_<UNIT_OR_ROLE_IDENTIFIER>
```

### 8.2 Beispiele

```text
SQ_US_BGRM_F15E_335_EFS
SQ_US_JBAD_OH58D_6_6_CAV
SQ_US_SAL_OH58D_B_6_6_CAV
SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN
SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT
```

### 8.3 Regeln

- ein SQUADRON ist typrein;
- der Einheitenbezeichner wird nur verwendet, wenn er ausreichend belegt ist;
- bei ungeklärter Untereinheit wird eine stabile, nicht erfundene Rollenbezeichnung verwendet;
- keine erfundenen Company-Buchstaben oder Battalion-Zuordnungen;
- historische Detachments werden nicht am Stammflugplatz doppelt gezählt;
- `Ngroups` bezeichnet MOOSE-Gruppen, nicht einzelne Luftfahrzeuge;
- ungerade Bestände benötigen eine dokumentierte Reserve- oder Single-Ship-Lösung.

## 9. Warehouse-Anker

### 9.1 Formel

```text
WH_AIR_<NATION>_<FULL_LOCATION_NAME>
```

### 9.2 Beispiele

```text
WH_AIR_US_BAGRAM
WH_AIR_US_JALALABAD
WH_AIR_US_KANDAHAR
WH_AIR_US_SALERNO
```

### 9.3 Regeln

- genau ein primärer technischer Warehouse-Anker pro AIRWING;
- der Anker ist ein benanntes, von MOOSE auffindbares `STATIC`- oder `UNIT`-Objekt;
- reine Kartenszenerie wird nicht als benanntes Missionsobjekt vorausgesetzt;
- der Anker wird in einem plausiblen Lager-/Supportbereich gesetzt;
- Rollwege, Landezonen und Parkpositionen bleiben frei;
- zusätzliche zerstörbare Tank- oder Munitionslager sind CampaignState-Infrastruktur und nicht automatisch der technische AIRWING-Anker.

## 10. Funktionszonen

### 10.1 Formel

```text
ZONE_AIR_<NATION>_<BASE>_<FUNCTION>
```

### 10.2 Beispiele

```text
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_SAL_MEDEVAC_READY
ZONE_AIR_US_SAL_LOGISTICS_LOAD
```

### 10.3 Regeln

- Zonen werden nur für eine konkrete MOOSE-, `AUFTRAG`-, `OPSTRANSPORT`-, CSAR-, Logistik- oder Testfunktion angelegt;
- keine Zonen allein zur optischen Gruppierung oder statischen Zählung;
- der Funktionsname beschreibt die technische Verwendung;
- doppelte Zonen für denselben Zweck sind zu vermeiden;
- Zonenlage und Radius gehören in das zuständige Basenmanifest;
- noch nicht benötigte Zonen werden nicht vorsorglich erstellt.

## 11. Rollen- und Typvokabular

Bevorzugte stabile Rollenbezeichner:

```text
CAS
STRIKE
RECON
AFAC
ESCORT
TRANSPORT
ASSAULT
UTILITY
MEDEVAC
CSAR
HEAVYLIFT
SLINGLOAD
LOGISTICS
```

Bevorzugte Musterbezeichner orientieren sich an den bestehenden Manifesten:

```text
F15E
F16C oder bestehend F16
A10C
C130
AH64D für Clients/Templates
AH64 für Statics
OH58D
UH60 oder UH60L nach Darstellungsart
HH60G für historische CSAR-Rolle
CH47F für Player
CH47 für Templates/Statics
MQ1A
MQ9
```

Bestehende stabile Namen werden nicht allein zur Vereinheitlichung zwischen `F16` und `F16C`, `CH47` und `CH47F` oder vergleichbaren Varianten umbenannt. Neue Manifeste müssen die lokale Wahl ausdrücklich dokumentieren.

## 12. Pflichtangaben jedes zukünftigen Air-Operations-Manifests

Jedes neue Basenmanifest enthält mindestens:

1. Standortname und Standortkürzel;
2. AIRWING- und Warehouse-Namen;
3. aktive Einheiten und logische Bestände;
4. historische Muster und tatsächliche DCS-Abbildung;
5. vollständige Client-Gruppen- und Unitnamen;
6. vollständige Template-Gruppen- und Unitnamen;
7. Gruppengröße, Rolle, Task, Skill, Late Activation und Uncontrolled-Status;
8. vollständige Static-Serien und Zielzahlen;
9. SQUADRON-Namen und geplante MOOSE-Gruppenzahlen;
10. Parking-, Blacklist- und Flächenregeln;
11. nur tatsächlich benötigte Zonen;
12. explizite Liste nicht anzulegender Objekte;
13. DCS-/MOOSE-Validierungsanforderungen;
14. Branch-, Commit-, Mission-, Bundle- und Versionsprovenienz nach technischer Acceptance.

## 13. Musterblock für ein neues Manifest

```text
Standortkürzel: XXX
AIRWING:        AW_US_<LOCATION>
Warehouse:      WH_AIR_US_<LOCATION>

Clients:
CLIENT_US_XXX_<PLAYER_TYPE>_01
  CLIENT_US_XXX_<PLAYER_TYPE>_01_UNIT_01
CLIENT_US_XXX_<PLAYER_TYPE>_02
  CLIENT_US_XXX_<PLAYER_TYPE>_02_UNIT_01

Template:
TPL_AIR_US_XXX_<TYPE>_<ROLE>_2SHIP
  TPL_AIR_US_XXX_<TYPE>_<ROLE>_2SHIP_UNIT_01
  TPL_AIR_US_XXX_<TYPE>_<ROLE>_2SHIP_UNIT_02

Statics:
STATIC_AIR_US_XXX_<TYPE_OR_ROLE>_01 ... _NN

SQUADRON:
SQ_US_XXX_<TYPE>_<UNIT_OR_ROLE_IDENTIFIER>

Zone nur bei technischer Funktion:
ZONE_AIR_US_XXX_<FUNCTION>
```

## 14. Abschlussregel

Ein Name gilt als verbindlich, sobald er in einem `BINDING`-Manifest, einem Missionseditorstand, einem Skript oder einer Acceptance referenziert wird. Änderungen danach benötigen:

- dokumentierte Migrationsliste;
- Anpassung aller Skripte, Tests und Querverweise;
- Prüfung auf doppelte oder verwaiste Namen;
- erneute Validierung des betroffenen Knotens, sofern Laufzeitreferenzen geändert wurden.