---
document_id: OMW-MOOSE-STAGE3-CAS-SUPPORT-REQUIREMENT-AND-ENGAGEMENT-DECISION
status: PLANNED
document_class: OWNER_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 3 Honaker CAS support authority and normal mission-termination semantics
  - retirement of the Build 1-17 incident-participant CAS-closure simplification
  - separation of Honaker local threat picture, CAS own detection picture, and C2 allocation/retask authority
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
  - branch-local Build 1-17 acceptance simplification that equated zero living Honaker attack-incident participants with immediate CAS mission closure
superseded_by:
---

# Stage 3 – CAS Support Requirement, Zielbild und Missionsbeendigung

## 1. Owner-Entscheidung

Für den Stage-3-Honaker-CAS-Pfad gelten drei getrennte Rollen und Informationsräume:

```text
Honaker
= lokale taktische Führung seiner eigenen Kräfte
= lokales Feind-/Kontaktbild
= erzeugt und hält den Bedarf an externer CAS-Unterstützung

C2
= koordiniert, priorisiert und allokiert externe CAS-Ressourcen
= erhält keine automatische allwissende Sicht auf Honakers interne Incident-Daten

CAS flight
= führt den zugewiesenen CAS-Auftrag aus
= besitzt ein eigenes DCS/MOOSE-Detektions-/Kontaktbild
= meldet Kontakt-/No-Contact-/Unable-Zustand
```

Guard und QRF bleiben vollständig lokale Honaker-Entscheidungen. C2 entscheidet nicht über deren Einsatz oder Rückkehr.

## 2. Explizite Trennung der Trigger

Die folgenden Größen dürfen den laufenden CAS-Auftrag **nicht automatisch beenden**:

```text
OPSZONE Defeated
1000-m alarm perimeter clear
attackIncidentClosed
number of living GroundInstallationAttackIncident participants
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC
raw RED-group count in the 5-NM tactical area
state.casFired
```

Sie dürfen Evidenz, Diagnose oder lokale Honaker-Zustände darstellen, besitzen aber keine CAS-Mission-Termination-Authority.

Insbesondere bleibt:

```text
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC
= DIAGNOSTICS ONLY
```

Der 5-NM-RED-Count ist weder Start-, Continue- noch Release-Trigger für CAS.

## 3. Retirement der Build-1-17-Vereinfachung

Für Build 1-17 war bewusst und temporär zugelassen:

```text
all known Honaker attack-incident participants dead
= Honaker releases requested CAS
```

Diese Regel war ausdrücklich nur eine Acceptance-Vereinfachung, keine endgültige CAS-Doktrin. Sie wird mit der aktuellen Reconciliation beendet und darf ab dem korrigierten Build nicht mehr als automatische CAS-Schließbedingung verwendet werden.

## 4. Normaler CAS-Lifecycle

Die normale Kette lautet:

```text
Honaker detects attack
-> Honaker uses local Guard/QRF/fire support as appropriate
-> Honaker creates/maintains CAS support requirement
-> C2 allocates CAS asset
-> CAS flight executes assigned support mission
-> Honaker status + CAS status are evaluated independently
-> supported-element/control decision releases CAS
-> planned WEST reverse / configured OMW_FlightPath reverse / Jalalabad recovery
```

Normale Missionsbeendigung wird semantisch von der Frage gesteuert:

```text
CAS requirement still active?
```

und nicht von einem Ground-Alarm- oder Ground-Incident-Zustand.

## 5. Statusfälle

### 5.1 Honaker meldet keine bekannten Angreifer mehr

Das ist zunächst ein lokaler Statusreport:

```text
HONAKER_NO_KNOWN_ATTACKERS
```

Er ist **nicht** automatisch `CAS_COMPLETE`.

CAS kann weiterhin einen relevanten Kontakt besitzen. Dann bleibt die Unterstützung aktiv, bis der unterstützte Commander/die Control-Kette die Wirkung beendet oder erweitert.

### 5.2 CAS meldet keinen Kontakt

Auch das ist zunächst ein Statusreport:

```text
CAS_NO_CONTACT_REPORTED
```

Er beendet den Auftrag nicht allein. In Kombination mit dem Honaker-Status kann das unterstützte Element den CAS-Auftrag ausdrücklich freigeben.

### 5.3 CAS meldet relevanten verbleibenden Kontakt

Der Auftrag bleibt aktiv. Die CAS-Mission darf weiter wirken, soweit der Kontakt vom aktuellen Tasking erfasst ist.

Ein neuer/unabhängiger Kontakt darf nicht allein deshalb automatisch bekämpft werden, weil er RED ist. Ein solcher Kontakt ist Report-/Retask-Gegenstand.

### 5.4 CAS kann nicht weiterarbeiten

Bingo, Winchester, Battle Damage, Emergency oder vergleichbare `unable to continue`-Zustände sind ein eigener Abbruchpfad. Sie sind nicht mit Honakers Ground-Incident-Completion zu vermischen.

```text
CAS mission target authority
!=
aircrew self-defence / unable-to-continue authority
```

## 6. Gepinnter MOOSE-Nachweis für PATROLZONE + SetEngageDetected

Maßgeblicher Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verifiziert:

```text
AUFTRAG:NewPATROLZONE(...)
AUFTRAG:SetEngageDetected(...)
OPSGROUP:SetEngageDetectedOn(...)
OPSGROUP:SetDetection(true)
OPSGROUP:GetDetectedGroups()
ZONE_BASE:IsCoordinateInZone(...)
```

`SetEngageDetected` wird beim MissionExecute auf den OPSGROUP/FLIGHTGROUP übertragen. MOOSE aktiviert dabei die Detection. Der automatische Angriffspfad prüft anschließend das **eigene detectedgroups-Bild des Carriers** und ruft `EngageTarget()` nur für einen passenden, tatsächlich erkannten Zielkontakt auf.

Damit gilt ausdrücklich:

```text
F10-map RED visibility
!=
AH-64D MOOSE/DCS detectedgroups
```

Der reale Build-1-19-Lauf mit `shotEvidence=false` beweist daher nicht, dass SetEngageDetected ausgefallen ist; er beweist nur, dass kein AH-64-Waffeneinsatz bestätigt wurde. Der vorherige Test enthielt keine ausreichende CAS-Sensor-Telemetrie, um Detection versus Engagement sauber zu unterscheiden.

## 7. Korrigierter Acceptance-Vertrag

Der korrigierte Full-Response-Test führt einen expliziten CAS-Supportzustand ein:

```text
CAS_REQUIRED
-> CAS_ACTIVE
-> CAS_ON_STATION
-> CAS_CONTACT_REPORTED | CAS_NO_CONTACT_REPORTED
-> CAS_RELEASED_BY_SUPPORTED_ELEMENT
-> CAS_RECOVERING
-> CAS_COMPLETE
```

Die Acceptance benutzt für den **Report** ausschließlich das eigene MOOSE-Detektionsbild des AH-64D-Flights. Ground-`TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC` bleibt davon unabhängig.

Der AH-64D gilt erst als on-station, wenn seine FLIGHTGROUP-Koordinate in der bestehenden CAS-Tactical-Zone liegt. Vorher darf ein leerer Detection-Set keinesfalls als `NO CONTACT` und damit als Release-Grund interpretiert werden.

Sobald Honaker `HONAKER_NO_KNOWN_ATTACKERS` meldet, gilt im Acceptance-Modell:

```text
if CAS is on station AND CAS reports no engagement-eligible detected ground group:
    supported element explicitly releases CAS

if CAS is on station AND CAS reports an engagement-eligible detected ground group:
    CAS remains active
```

Das ist keine Rückkehr zum Ground-RED-Count: Die zweite Information stammt ausschließlich aus dem eigenen MOOSE/DCS-Detektionsbild des CAS-Flights.

## 8. Ziel-/Informationsgrenze

Die aktuelle PATROLZONE-Mission darf nur die bereits konfigurierte MOOSE-Zielpolicy ausführen:

```text
engageDetectedRangeNm = 5
engageDetectedTargetTypes = Ground Units
engage zone = Honaker CAS tactical zone
```

Der Acceptance-Code erzeugt **keine** künstliche allwissende RED-Liste für den AH-64D und injiziert keine beliebigen F10-map-Gegner mit `KnowTarget()`.

Wenn später explizite Honaker/JTAC/C2 Target Reports modelliert werden, müssen sie als eigener Informationsfluss dokumentiert werden. C2 darf nicht implizit auf `GroundInstallationAttackIncident` zugreifen.

## 9. Reale Build-1-19-Evidenz vom 08.09.2026

Der reale Lauf zeigte:

```text
AH-64D CAS allocated: YES
PATROLZONE + SetEngageDetected assigned: YES
configured corridor: YES
CAS weapon shot evidence: NO
Honaker attack incident closed: YES
5-NM RED groups at closure: 4 (diagnostics only)
old code closed CAS immediately from attackIncidentClosed: YES
```

Damit ist Build 1-19 für den CAS-Lifecycle **nicht validiert**. Guard, QRF, ARTY und CH-47-Ergebnisse dieses Laufs bleiben getrennte Evidenz und werden durch diese CAS-Korrektur nicht entwertet.

## 10. Static Gate vor dem nächsten DCS-Lauf

Der nächste Build darf erst freigegeben werden, wenn statisch mindestens gilt:

```text
closeAttackIncidentIfClear() does not close CAS
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC is diagnostics only
CAS closure requires explicit supported-element release state
CAS no-contact report is evaluated only after CAS is on station
CAS contact report uses FLIGHTGROUP:GetDetectedGroups()
no raw tactical RED count controls CAS closure
PATROLZONE + SetEngageDetected remains MOOSE-owned
configured recovery corridor remains intact
Lua syntax PASS
Documentation validation PASS
builder hash == independent local hash
```

`VALIDATED` bleibt bis zu einem neuen realen DCS-Lauf false.
