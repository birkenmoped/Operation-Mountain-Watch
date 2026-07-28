---
document_id: OMW-CAS-BUDDY-LASING
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW buddy-lasing roles, brevity and coordination sequence
  - distinction between continuous and delayed lasing
  - mission-design safety and abort requirements for remote designation
not_authoritative_for:
  - aircrew or JTAC qualification
  - weapon-specific certified delivery envelopes
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/document-ato-asr-aar-buddy-lasing
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 56 - Buddy Lasing: Phraseology und Missionsdesign

## 1. Einordnung

Buddy Lasing trennt den **Shooter** vom **Designator**. Der Designator kann eine Bodeneinheit, ein JTAC-/FO-Team, ein anderes bemanntes Luftfahrzeug oder ein UAV sein. Die technische Fähigkeit zum Lasern ersetzt weder positive Zielidentifikation noch Terminal Attack Control.

Ausgewertete Quelle:

- Graveyard of Empires, `Paveway II Delivery Profiles - Buddy-Lasing Phraseology (13/25)`, 29.07.2025;
- dort genannte Fachgrundlagen: JP 3-09.3, JFIRE 2023 und NATO ATP-3.3.2.1.

Die bereitgestellte Datei ist Teil 13 einer größeren Serie. Nicht bereitgestellte Serienteile werden nicht rekonstruiert.

**Credits für Recherche und Quellenzusammenstellung: Graveyard of Empires - <https://www.patreon.com/cw/graveyard4DCS>**

## 2. Rollen

| Rolle | Aufgabe |
|---|---|
| Requestor/Ground Commander | gewünschter Effekt und Einsatzpriorität |
| JTAC/FAC(A) beziehungsweise Controller | CAS-Kontrolle, Deconfliction und Weapons Release Authority im zugewiesenen Rahmen |
| Shooter | Waffenabwurf/-abschuss, Flugprofil, Zeitansagen und Abbruchreaktion |
| Designator | Zielaufnahme, Codeprüfung, Laseraktivierung und Track bis Impact |
| Third Party | mögliche Relais-, Sensor- oder Handover-Funktion ohne automatische Release Authority |

Die Rollen können auf einer Plattform zusammenfallen, müssen in Briefing und Funkverfahren trotzdem eindeutig sein.

## 3. Brevity

### 3.1 Buddy-Lasing-Kernbegriffe

| Call | OMW-Bedeutung |
|---|---|
| `BUDDY LASE/GUIDE` | Anforderung oder Information, dass die Waffe durch eine andere Quelle geführt wird |
| `TEN SECONDS` | Shooter kündigt ungefähr zehn Sekunden bis zum geforderten Laserbeginn an |
| `CAPTURED` | Designator hat das richtige Ziel erfasst und erwartet, den Track bis Impact halten zu können |
| `LASER ON` | Anweisung beziehungsweise Bestätigung zum Aktivieren des Lasers |
| `LASING [CODE]` | Laser ist aktiv, verfolgt das Ziel und verwendet den genannten Code |
| `CEASE LASER` | Laserbetrieb sofort beenden |
| `SHIFT [Richtung/Track]` | Designation auf ein anderes Ziel oder einen anderen Zielpunkt verlegen |

Bei `CAPTURED` soll der Code erneut bestätigt werden. Wenn der Designator das Ziel nicht aufnehmen oder nicht halten kann, wird dies eindeutig mit `NO JOY` oder einer vergleichbar unmissverständlichen Negativmeldung übermittelt.

### 3.2 Laser Handover

| Call | Bedeutung |
|---|---|
| `STARE [Ort/Code]` | Sensor auf einen Ort und Laser-Code cueen |
| `SPOT` | Laserpunkt wurde aufgenommen |
| `NEGATIVE LASER` | keine passende Laserenergie erkannt; mögliche Ursachen sind Timing, Code, Maskierung oder Technik |

Handover ist nicht automatisch Buddy Lasing. Es beschreibt zunächst nur die Aufnahme eines fremden Laserpunktes.

### 3.3 Kritische Calls

| Call | Bedeutung |
|---|---|
| `DEAD EYE` | Laserfähigkeit ist ausgefallen oder kann nicht wirksam eingesetzt werden; keine Freigabe bis erneuter positiver Bestätigung |
| `ABORT` dreimal | Angriff unverzüglich abbrechen; alle Beteiligten stoppen die Angriffshandlung unabhängig vom aktuellen Zeitpunkt |

Mögliche Abortgründe sind Zielverwechslung, Fratricide-Risiko, Trackverlust, Codeproblem, technische Störung, neue ROE-/NSL-Lage oder Verlust der notwendigen Zweiwegekommunikation.

## 4. Continuous Lasing

Continuous Lasing ist laut Quelle das einfachere und für DCS regelmäßig zu bevorzugende Verfahren. Der Designator aktiviert den Laser vor oder spätestens zur Weapon Release und hält ihn bis zum Einschlag.

### 4.1 Arbeitssequenz

1. Shooter kündigt den Buddy-Lase-Bedarf und die geplante Weapon Release an. Die Quelle empfiehlt, die Koordination spätestens ungefähr 30 Sekunden vorher zu beginnen; bei komplexer Zeitkoordination deutlich früher.
2. Designator bestätigt Zielaufnahme mit `CAPTURED` und wiederholt den Laser-Code.
3. Shooter gibt die Zeitmarke `TEN SECONDS`.
4. Shooter beziehungsweise Controller fordert `LASER ON`.
5. Designator bestätigt `LASING [CODE]`.
6. Shooter meldet Weapon Release und Time of Flight.
7. Designator hält den Zielpunkt stabil bis Impact.
8. Nach Impact folgt `CEASE LASER` oder ein ausdrücklich befohlenes `SHIFT`.

Diese Sequenz ergänzt die normalen CAS-Verfahren. Sie ersetzt weder Check-in, Situation Update, Game Plan, CAS Brief, Readbacks, Attack Clearance noch Abort Procedures.

### 4.2 Vorteile

- geringere Timingempfindlichkeit;
- frühzeitige Erkennung eines Code- oder Sichtlinienproblems;
- robustere Durchführung bei Funk- oder Datenlatenz;
- geringeres Risiko eines vollständigen Guidance-Verlusts;
- leichter in Multiplayer-Briefing und KI-Skripting abzubilden.

## 5. Delayed Lasing

Delayed Lasing beginnt erst nach Weapon Release in der terminalen Flugphase. Es benötigt genauere Zeitkoordination und bietet weniger Fehlertoleranz.

### 5.1 Arbeitssequenz

1. Shooter und Designator bestätigen Ziel, Code und Bereitschaft vor Release.
2. Shooter setzt die Waffe ein und meldet Time of Flight.
3. Ungefähr zehn Sekunden vor dem geplanten Laserbeginn folgt `TEN SECONDS`.
4. Erst zum berechneten Zeitpunkt erfolgt `LASER ON`.
5. Designator bestätigt `LASING [CODE]` und hält bis Impact.

### 5.2 Geeignete Anwendungsfälle

Die Quelle nennt als Beispiele:

- Hellfire `LOAL` mit später Seeker-Aktivierung;
- Terrainmaskierung oder fehlende direkte Sicht des Shooters;
- Bedrohungen durch Laserwarnung, Laserjamming oder gegnerische Reaktion auf Laseremissionen;
- Minimierung der Laser-On-Zeit als prozedurale Schutzmaßnahme.

Genannte LOAL-Profile:

| Profil | Charakteristik |
|---|---|
| `LOAL-DIR` | niedrigstes Profil, kurze Distanz und minimale Exposition |
| `LOAL-LO` | mittlerer Bogen mit begrenzter Terrainmaskierung |
| `LOAL-HI` | höherer Bogen zur Überwindung deutlicher Geländehindernisse, mit zusätzlichen Wetter- und Seeker-Risiken |

### 5.3 OMW-Entscheidung

Für normale OMW-Multiplayer- und KI-Abläufe gilt **Continuous Lasing als Standard**. Delayed Lasing wird nur verwendet, wenn:

- der konkrete Waffeneinsatz es verlangt oder plausibel begründet;
- Shooter und Designator dieselbe Time-of-Flight-Referenz besitzen;
- die Mission den Laserstart eindeutig vorgibt;
- ein Abort bei verspätetem oder fehlendem Laser technisch möglich ist;
- das Verfahren in DCS reproduzierbar getestet wurde.

## 6. Fehler- und Abbruchbedingungen

Eine Buddy-Lase-Mission darf nicht in den Release-Zustand wechseln bei:

- fehlendem `CAPTURED`;
- widersprüchlichem Laser-Code;
- `NEGATIVE LASER` beim erforderlichen Handover;
- `DEAD EYE`;
- unklarer Zielidentität;
- verlorenem Track;
- Zielmaskierung vor dem benötigten Laserfenster;
- nicht aufgelöster Friendly-/NSL-/ROE-Konfliktlage;
- fehlender Zweiwegekommunikation, sofern diese für die Kontrolle erforderlich ist;
- fehlender Attack Clearance.

Nach Weapon Release muss `ABORT` weiterhin alle noch beeinflussbaren Handlungen stoppen. Die DCS-Waffe selbst kann je nach Simulation nicht immer neutralisiert werden; deshalb muss die Mission Abortkriterien möglichst vor Release erkennen.

## 7. OMW-Missionsdaten

```yaml
LaserDesignationPlan:
  missionId:
  requestId:
  targetId:
  controllerId:
  shooterUnitId:
  designatorUnitId:
  designationType: GROUND | AIRBORNE | UAV
  method: CONTINUOUS | DELAYED
  laserCode:
  targetPoint:
  plannedLaserOn:
  plannedImpact:
  minimumLaserWindow:
  shiftPlan:
  abortCriteria:
  communicationsNet:
  state:
```

Empfohlene Zustände:

```text
PLANNED
-> TARGET_CAPTURED
-> CODE_CONFIRMED
-> READY
-> LASER_ON
-> WEAPON_AWAY
-> GUIDING
-> IMPACT | ABORTED | FAILED
-> CEASED
```

## 8. Funk- und Briefingvorlage

Die folgende Sequenz ist eine **OMW-Arbeitsvorlage**, keine wörtliche Wiedergabe eines vollständigen offiziellen CAS-Dialogs:

```text
SHOOTER:    BUDDY LASE, target [description], code [code], planned release [time].
DESIGNATOR: CAPTURED, code [code].
SHOOTER:    TEN SECONDS.
SHOOTER:    LASER ON.
DESIGNATOR: LASING [code].
SHOOTER:    WEAPON AWAY, time of flight [seconds].
DESIGNATOR: IMPACT.
CONTROLLER: CEASE LASER.
```

Bei Zielwechsel:

```text
CONTROLLER: SHIFT [direction or track number].
DESIGNATOR: CAPTURED, code [code].
```

Bei Fehler:

```text
DESIGNATOR: NEGATIVE LASER | DEAD EYE.
CONTROLLER: ABORT, ABORT, ABORT.
```

## 9. DCS- und MOOSE-Anforderungen

Vor eigener Implementierung sind die einschlägigen MOOSE-Funktionen gemäß [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md) zu prüfen. Besonders relevant sind die dokumentierten Klassen und Mechanismen für:

- `DESIGNATE` und Laser-Code-Verwaltung;
- FAC-/FAC(A)-Aufgaben;
- `TARGET`, `INTEL`, `DETECTION` und `PLAYERRECCE`;
- Spieleraufgaben und KI-`AUFTRAG`;
- Events, FSM und zeitgesteuerte Zustandswechsel;
- Funkmeldungen, Menüs und Marker.

Technisch zu validieren sind:

- ob Laser-Code und Laserzustand für alle verwendeten Designatorplattformen zuverlässig gesetzt und gelesen werden können;
- ob bewegte Ziele stabil verfolgt werden;
- wie DCS bei Maskierung, Zielverlust und Designatorzerstörung reagiert;
- ob ein KI-Shooter Weapon Release ohne wirksame Designation verhindert;
- Multiplayer-Latenz und Reihenfolge der Calls;
- Ground-, Airborne- und UAV-Designation getrennt;
- kontinuierliches und verzögertes Lasing;
- `SHIFT`, `DEAD EYE` und `ABORT`.

## 10. Missionsdesign-Regeln

1. Laser-Code wird vor Mission oder vor Attack eindeutig zugewiesen und bestätigt.
2. Shooter, Designator und Controller werden namentlich beziehungsweise per Callsign benannt.
3. Ein Laser-Code darf im selben Wirkungsraum nicht unkoordiniert mehrfach verwendet werden.
4. `CAPTURED` bestätigt das Ziel, nicht nur einen Kartenpunkt.
5. Continuous Lasing ist der Standard; Delayed Lasing benötigt eine dokumentierte Begründung.
6. Weapon Release ohne positive Designatorbereitschaft ist ein Missionsfehler.
7. `DEAD EYE` sperrt weitere lasergeführte Releases, bis eine neue Designation bestätigt ist.
8. `ABORT` besitzt Vorrang vor allen Timing- und Attack-Calls.
9. Die Laser-Sequenz wird im Debriefing mit Ziel, Code, Zeit und Ergebnis protokolliert.
10. Die NSL- und ROE-Prüfung bleibt auch bei rein technischer Fremdbezeichnung verbindlich.

## 11. Querverweise

- [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](45-air-c2-cas-afghanistan.md)
- [`OMW-C2-JTAR-ASR`](55-jtar-asr-air-support-request.md)
- [`OMW-C2-ATO-ACO-SPINS`](54-air-tasking-order-aco-spins.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL`](48-afghanistan-no-strike-list.md)
- [`ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur`](moose/ISR-FAC-CAS-AAR.md)
