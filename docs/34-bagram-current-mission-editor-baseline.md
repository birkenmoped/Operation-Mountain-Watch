---
document_id: OMW-AIR-BAGRAM-ME-BASELINE
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - current Bagram Mission Editor object state
  - current Bagram clients templates statics warehouse and parking
  - Bagram runtime implementation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/31-bagram-current-mission-editor-baseline.md
  - conflicting implementation values in the former Bagram planning manifest
source_branch: docs/bagram-air-operations-manifest
source_mission: OMW_TEST_TM01M_MooseFirst(8).miz
validated_in_dcs: false
---

# 34 – Bagram Current Mission Editor Baseline

## 1. Dokumentstatus und Autorität

Dieses Dokument ist für den tatsächlich gesetzten Bagram-Missionseditorstand und für die Übergabe an die noch zu erstellende MOOSE-Laufzeitimplementierung autoritativ.

Abgrenzung:

- `OMW-AIR-BAGRAM-MANIFEST`: historische Fighter-Evidenz und aktive Fighter-ORBAT;
- `OMW-AIR-PLAYER-SLOT-POLICY`: projektweite Clientregel;
- dieses Dokument: konkrete Missionseditorobjekte, Warehouse-Anker, Parking-Baseline und Runtime-Übergabe.

## 2. Aktueller Missionseditorbestand

### 2.1 Clientgruppen

Projektregel:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Flugplatz
1 Luftfahrzeug je Clientgruppe
```

Gesetzt:

```text
CLIENT_US_BGRM_F15E_01
CLIENT_US_BGRM_F15E_02
CLIENT_US_BGRM_F16_01
CLIENT_US_BGRM_F16_02
CLIENT_US_BGRM_C130_01
CLIENT_US_BGRM_C130_02
CLIENT_US_BGRM_CH47F_01
CLIENT_US_BGRM_CH47F_02
CLIENT_US_BGRM_OH58_01
CLIENT_US_BGRM_OH58_02
```

Alle Gruppen bestehen aus einer Unit und verwenden `skill = Client`.

Parkpositionen:

```text
F-15E: M25, M26
F-16C: M15, M16
C-130J-30: A09, A08
CH-47F: R21, R22
OH-58D: P01, P02
```

### 2.2 KI-Templates

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
TPL_AIR_US_BGRM_F16_CAS_2SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_UH60_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_LEAD_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_COVER_1SHIP
```

Eigenschaften:

```text
Late Activation: ja
Uncontrolled: nein
Fighter-Skill: High
Templates sind Authoring-Seeds und kein zusätzlicher Bestand.
```

Für F-16C existiert bewusst kein separates `ARMED_RECON`-Template.

### 2.3 Statics

```text
6 F-15E
7 F-16C
4 UH-60
2 UH-60A als HH-60G-/CSAR-Repräsentation
2 CH-47D
2 C-130
1 KC-130
1 C-17A
1 KC-135 MPRS
Gesamt: 26 Luftfahrzeug-Statics
```

Statics sind ausschließlich sichtbare Repräsentationen. Sie werden nicht zusätzlich zum logischen AIRWING-/SQUADRON-Bestand gezählt.

### 2.4 DCS-Abbildung

```text
F-15E: Client F-15ESE; KI/Static F-15E
F-16C: historisch Block 30; DCS-Abbildung Block 50
CH-47: Client CH-47Fbl1; KI/Static CH-47D
HH-60G: KI/Static UH-60A als technischer Ersatz
```

Community-Mods bleiben optional und sind keine Voraussetzung der Basismission.

## 3. Verbindliche Runtime-Zielstruktur

```text
AW_US_BAGRAM
├── SQ_US_BGRM_F15E_335_EFS
├── SQ_US_BGRM_F16C_121_EFS
├── SQ_US_BGRM_C130_AIRLIFT
├── SQ_US_BGRM_CH47_LIFT
├── SQ_US_BGRM_UH60_UTILITY
└── SQ_US_BGRM_HH60G_CSAR

WH_AIR_US_BAGRAM
```

Die historischen Namen der noch nicht abschließend zugeordneten Transport-/Rotary-Wing-SQUADRONs müssen vor produktiver Registrierung gegen `OMW-AIR-ACTIVE-ORBAT` geprüft werden. Bis dahin sind die obigen Namen Implementierungskennungen, keine neue historische Behauptung.

## 4. AIRWING-Registrierung

Die Implementierung muss:

1. `WH_AIR_US_BAGRAM` als Warehouse-Anker erkennen;
2. genau ein Bagram-AIRWING `AW_US_BAGRAM` erzeugen beziehungsweise binden;
3. alle Bagram-SQUADRONs diesem AIRWING zuordnen;
4. Templates nur als Spawn-/Payload-Seeds verwenden;
5. Clientgruppen und Statics niemals als zusätzliche SQUADRON-Assets zählen;
6. F-15E-Komponenten wegen `THIRD_PARTY_AT_RISK` deaktivierbar halten, ohne die übrige Struktur umzubauen;
7. den AIRWING-Start erst nach erfolgreicher Warehouse-, Template- und Parking-Prüfung ausführen.

## 5. SQUADRON-Bestandsverwaltung

Verbindliche Fighter-Bestände:

```text
SQ_US_BGRM_F15E_335_EFS: 13 Airframes
SQ_US_BGRM_F16C_121_EFS: 13 Airframes
```

Für beide ungeraden Bestände gilt zunächst als bevorzugter Testkandidat:

```text
12 Airframes als 6 Two-Ship-Assets
+ 1 separat geführte logische Reserve
```

Alternativ dürfen 13 Single-Ship-Assets nur nach MOOSE-First-Test verwendet werden. Es darf niemals rechnerisch ein 14. Airframe entstehen.

Für C-130, CH-47, UH-60 und HH-60G sind die logischen Bestände noch nicht durch die Static- oder Templateanzahl definiert. Vor Registrierung ist je Verband ein expliziter Anfangsbestand festzulegen und als offene Konfiguration zu dokumentieren.

Getrennt zu führen:

```text
verfügbar
reserviert/zugewiesen
aktiv im Einsatz
zurückkehrend
in Wartung/Cooldown
beschädigt
verloren
logische Reserve
```

## 6. Warehouse-Erkennung

Verbindlicher Missionseditoranker:

```text
WH_AIR_US_BAGRAM
DCS-Objekttyp: container_20ft
```

Die Erkennung muss fail-closed erfolgen:

- Objekt nicht gefunden: Bagram-AIRWING nicht starten;
- Name mehrfach gefunden: Konfigurationsfehler;
- falsche Koalition oder ungültiges Objekt: Konfigurationsfehler;
- erfolgreicher Fund: Objektname, DCS-Typ, Koalition und Koordinate protokollieren.

Der Anker ist Referenzobjekt; seine sichtbare Objektart definiert nicht automatisch Lagerkapazität oder Luftfahrzeugbestand.

## 7. AUFTRAG-Ausführung

Vorgesehene Rollen nach vorhandenen Templates:

```text
F-15E: CAS, STRIKE; später ggf. ESCORT über AUFTRAG/Payload
F-16C: CAS; weitere Rollen ohne vorsorgliches Zusatztemplate
C-130: TRANSPORT / AIRLIFT
CH-47: TRANSPORT / OPSTRANSPORT
UH-60: TRANSPORT / UTILITY
HH-60G: CSAR Lead/Cover
```

Vor eigener Tasking-Logik sind MOOSE `AIRWING`, `SQUADRON`, `AUFTRAG`, `OPSTRANSPORT`, `FLIGHTGROUP` und vorhandene CSAR-Funktionen zu prüfen.

Jeder Auftrag benötigt mindestens:

- erlaubte SQUADRON und Template-/Payloadauswahl;
- Start- und Zielbedingungen;
- Mindest- und Maximalgruppengröße;
- ROE und Alarm State;
- Erfolg-, Abbruch- und Rückkehrkriterien;
- Behandlung bei Verlust, Beschädigung oder Treibstoffmangel;
- eindeutige Rückgabe des Assets an den Bestand.

## 8. Safe Parking und Blacklist

Clientpositionen sind dauerhaft zu reservieren:

```text
M25, M26, M15, M16, A09, A08, R21, R22, P01, P02
```

Die Laufzeitdiagnose muss:

1. alle Bagram-TerminalIDs und Koordinaten erfassen;
2. die 26 Statics geometrisch dem nächsten Parking-Spot zuordnen;
3. bewusst belegte Spots als Blacklist-Kandidaten ausgeben;
4. Clientpositionen explizit von dynamischer KI ausschließen;
5. Safe Parking aktivieren und je Luftfahrzeugklasse validieren;
6. ungeeignete Spots wegen Größe, Kollision, Rollweg oder Shelter-Geometrie sperren.

Die endgültige Blacklist darf nicht aus geratenen TerminalIDs bestehen. Sie wird ausschließlich aus der Laufzeitdiagnose abgeleitet.

## 9. Verlust- und Rückgabelogik

Verbindliche Zustandsregel:

```text
Mission angenommen -> Asset reserviert
Spawn/Start -> aktiv
Landung und sichere Rückkehr -> verfügbar oder Wartung/Cooldown
Abbruch mit Rückkehr -> verfügbar oder Wartung/Cooldown
Beschädigte Rückkehr -> beschädigt/Wartung
Zerstörung/Crash -> verloren
Despawn ohne bestätigte sichere Rückkehr -> nicht automatisch verfügbar
```

Eine erfolgreiche Auftragswirkung darf einen danach verlorenen Airframe nicht wieder in den Bestand zurückgeben. Rückgabe erfolgt erst nach einem nachgewiesenen Rückkehrereignis beziehungsweise einer ausdrücklich getesteten MOOSE-Endzustandslogik.

Persistente Verluste und Reparaturzeiten werden später an den zentralen CampaignState angebunden. Bis dahin muss die lokale Laufzeitbilanz deterministisch und protokolliert sein.

## 10. Flugplatzspezifische Funktionszonen

Der aktuelle Bagram-Grundknoten benötigt keine künstlichen Static-, Reserve-, Load- oder Recovery-Zonen.

Nicht anzulegen:

```text
ZONE_AIR_US_BGRM_STATIC_F15E
ZONE_AIR_US_BGRM_STATIC_F16C
ZONE_AIR_US_BGRM_F15E_AI_RESERVE
ZONE_AIR_US_BGRM_F16C_AI_RESERVE
ZONE_AIR_US_BGRM_FIGHTER_LOAD
ZONE_AIR_US_BGRM_FIGHTER_RECOVERY
```

Zonen dürfen nur angelegt werden, wenn eine konkrete Funktion sie tatsächlich benötigt. Erwartbare spätere Kandidaten sind:

```text
Bagram OPSTRANSPORT Ladezone
Bagram OPSTRANSPORT Entlade-/Stagingzone
Bagram CSAR/MEDEVAC Übergabezone
Bagram Cargo-/Slingload-Bereich
```

Namen, Koordinaten und Radien werden erst mit der jeweiligen Funktionsimplementierung festgelegt. Parking- und Rampzuordnung erfolgt primär über Airbase, TerminalIDs, Safe Parking und Blacklists, nicht über Hilfszonen.

## 11. Offene Implementierungsentscheidungen

- logische Anfangsbestände für C-130, CH-47, UH-60 und HH-60G;
- historische endgültige SQUADRON-Bezeichnungen dieser Komponenten;
- Payloadsets und ROE je AUFTRAG-Rolle;
- Cooldown-, Wartungs- und Reparaturzeiten;
- persistente Verlustübergabe an CampaignState;
- vollständige TerminalID-/Blacklist-Tabelle;
- konkrete OPSTRANSPORT-, CSAR- und Logistikzonen.

## 12. Acceptance-Kriterien für den späteren Bagram-Runtime-Test

```text
genau 1 Warehouse-Anker erkannt
genau 1 AIRWING gestartet
keine Doppelzählung von Clients, Templates oder Statics
13 F-15E und 13 F-16C logisch ohne 14. Airframe abgebildet
keine Spawns auf reservierten Client- oder Static-Spots
AUFTRAG kann Assets anfordern, starten, zurückführen und freigeben
Verluste reduzieren den Bestand
sichere Rückkehr gibt den korrekten Bestand zurück
keine spontane Aktivierung der Late-Activation-Templates
keine relevante Lua-, Parking- oder Timerfehlermeldung
```
