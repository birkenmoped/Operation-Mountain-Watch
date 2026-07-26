# 29 – Verbindliche Spielerluftfahrzeug-Obergrenze

## 1. Status und Geltungsbereich

**Projektweit verbindlich**

Diese Regel gilt für alle Flugplätze, FARPs und Luftfahrzeugtypen in **Operation Mountain Watch**. Sie präzisiert und ersetzt ältere allgemeine Planungswerte mit bis zu vier Spielerluftfahrzeugen je Typ und Basis.

```text
maximale Spielerluftfahrzeuge je Muster und Basis: 2
maximale Clientgruppen je Muster und Basis: 2
Luftfahrzeuge je Clientgruppe: 1
```

Multicrew-Sitze zählen nicht als zusätzliche Luftfahrzeuge.

## 2. Abgrenzung

Die Obergrenze betrifft ausschließlich im Missionseditor gesetzte Spieler-/Client-Luftfahrzeuge. Sie verändert nicht automatisch:

- den historischen oder strategischen ORBAT-Bestand,
- die Anzahl der MOOSE-SQUADRON-Asset-Gruppen,
- die maximal gleichzeitig aktiven KI-Luftfahrzeuge,
- die Anzahl sichtbarer Statics,
- virtuelle Reserveflugzeuge im CampaignState.

Spielergruppen dürfen nicht zugleich als KI-Templates verwendet werden.

## 3. Verbindliche Anwendung auf Bagram

Für den Bagram-Fighter-Grundknoten gelten daher genau vier Clientgruppen insgesamt:

### F-15E

```text
CLIENT_US_BGRM_F15E_01
  CLIENT_US_BGRM_F15E_01_UNIT_01

CLIENT_US_BGRM_F15E_02
  CLIENT_US_BGRM_F15E_02_UNIT_01
```

### F-16C

```text
CLIENT_US_BGRM_F16C_01
  CLIENT_US_BGRM_F16C_01_UNIT_01

CLIENT_US_BGRM_F16C_02
  CLIENT_US_BGRM_F16C_02_UNIT_01
```

Die zuvor im Bagram-Manifest genannten Gruppen `_03` und `_04` je Muster werden **nicht angelegt**.

## 4. Bagram-Parking

Für Spieler sind zu reservieren:

```text
2 kollisionsfreie F-15E-Parking-Nodes
2 kollisionsfreie F-16C-Parking-Nodes
```

Diese vier Positionen dürfen weder von Statics noch von dynamischer KI genutzt werden. Weitere geeignete Fighter-Parking-Nodes bleiben für KI, Recovery, Reserve und spätere Erweiterungen verfügbar.

## 5. Verbindliche Bagram-KI-Templates

Die zuvor vorgesehene zweite F-16C-KI-Gruppe für `ARMED_RECON` beziehungsweise Recon entfällt. Eine eigene F-16-Recon-Templategruppe ist für den Bagram-Grundknoten weder missionsgestalterisch erforderlich noch fachlich sinnvoll.

### F-15E

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
```

### F-16C

```text
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Nicht anzulegen ist:

```text
TPL_AIR_US_BGRM_F16C_ARMED_RECON_2SHIP
```

Weitere F-16C-Rollen dürfen später über zusätzliche Payloads oder AUFTRAG-Zuweisungen auf Basis des vorhandenen CAS-Templates geprüft werden. Eine zusätzliche Missionseditor-Templategruppe wird dafür nicht vorsorglich angelegt.

## 6. Keine künstlichen Bagram-Funktionszonen

Für den Fighter-Grundknoten werden keine Zonen nur zur Gruppierung, Zählung oder visuellen Zuordnung von Statics angelegt. Statics sind Missionseditorobjekte ohne notwendige MOOSE-Zonenbindung und werden direkt aus der übergebenen `.miz` ausgewertet.

Nicht anzulegen sind:

```text
ZONE_AIR_US_BGRM_STATIC_F15E
ZONE_AIR_US_BGRM_STATIC_F16C
ZONE_AIR_US_BGRM_F15E_AI_RESERVE
ZONE_AIR_US_BGRM_F16C_AI_RESERVE
ZONE_AIR_US_BGRM_FIGHTER_LOAD
ZONE_AIR_US_BGRM_FIGHTER_RECOVERY
```

Grundsatz:

- Zonen werden nur erstellt, wenn eine konkrete Laufzeitfunktion sie technisch benötigt.
- Static-Anzahl, Static-Typ, Namen und Positionen werden aus der `.miz` gelesen.
- KI-Reserveparkplätze werden über Parking-/TerminalIDs, Safe Parking und gegebenenfalls Blacklists verwaltet, nicht über künstliche Triggerzonen.
- Load-, Recovery-, Staging- oder Operationszonen werden erst angelegt, wenn eine konkrete MOOSE-, AUFTRAG-, OPSTRANSPORT- oder Logistikfunktion implementiert wird.

## 7. Korrigierte Bagram-Baseline

```text
4 Clientgruppen insgesamt
  2 F-15E
  2 F-16C

3 Late-Activation-KI-Templates
  2 F-15E-Two-Ship-Templates
  1 F-16C-Two-Ship-Template

6 Templateflugzeuge insgesamt
  4 F-15E
  2 F-16C

16 sichtbare Statics
  9 F-15E
  7 F-16C

0 verpflichtende Funktionszonen
1 Warehouse-Anker
2 SQUADRONs
1 AIRWING
```

Die 16 Statics bleiben unverändert. Die Satelliten-Momentaufnahme wird nicht über eine feste Addition von Client- oder Templateflugzeugen rekonstruiert. Sichtbare Statics, aktive Spieler-/KI-Flugzeuge und virtuelle Reserve sind getrennte Repräsentationsebenen. Die tatsächliche Rampdarstellung hängt vom jeweiligen Missionszustand ab.

## 8. Korrigierte Arbeitsanweisung

Im Missionseditor:

1. je zwei Spielerpositionen für F-15E und F-16C auswählen;
2. genau die vier in Abschnitt 3 genannten Clientgruppen setzen;
3. jede Clientgruppe mit genau einer Unit anlegen;
4. Clientpositionen dauerhaft von Statics und KI freihalten;
5. zwei F-15E-Two-Ship-Templates für CAS und STRIKE anlegen;
6. genau ein F-16C-Two-Ship-Template für CAS anlegen;
7. kein separates F-16C-Recon-/Armed-Recon-Template anlegen;
8. keine der in Abschnitt 6 ausgeschlossenen Zonen anlegen;
9. mindestens vier zusätzliche dynamische KI-Reservepositionen je Typ anstreben, soweit die Bagram-Parking-Geometrie dies erlaubt;
10. die tatsächlichen TerminalIDs dokumentieren;
11. Parking-Blacklist nur aus bewusst durch Statics belegten Nodes ableiten;
12. die `.miz` zur direkten Auswertung von Clients, Templates, Statics, Warehouse und Parking übergeben.

## 9. Verhältnis zum Bagram-Manifest

Dieses Dokument ist für die Clientanzahl, die F-16C-KI-Templateauswahl und den Verzicht auf künstliche Bagram-Funktionszonen autoritativ. Es ersetzt im Bagram-Manifest `docs/28-bagram-air-operations-manifest.md` insbesondere:

- die Aussage von vier Spielerluftfahrzeugen je Fighter-Typ,
- die Clientgruppen `_03` und `_04`,
- die Forderung nach vier Client-Parking-Nodes je Typ,
- das Template `TPL_AIR_US_BGRM_F16C_ARMED_RECON_2SHIP`,
- die Forderung nach zwei F-16C-KI-Templates,
- die sechs pauschal geforderten Static-, AI-Reserve-, Load- und Recovery-Zonen,
- die Acceptance-Angabe von vier KI-Templates beziehungsweise acht Templateflugzeugen,
- die Acceptance-Angabe von acht Clientgruppen,
- die Acceptance-Angabe von sechs Zonen,
- die Safe-Parking-Angabe für acht Clientpositionen.

Alle übrigen historischen, ORBAT-, Warehouse-, Static- und Parking-Aussagen des Bagram-Manifests bleiben bestehen.

Die beiden Dokumente sind bei der nächsten redaktionellen Konsolidierung zusammenzuführen; bis dahin hat diese verbindliche Korrektur bei Widersprüchen Vorrang.
