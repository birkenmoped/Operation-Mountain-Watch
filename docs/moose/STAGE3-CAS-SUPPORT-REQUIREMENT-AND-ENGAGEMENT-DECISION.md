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

Diese Regel war ausdrücklich nur eine Acceptance-Vereinfachung. Sie ist ab Build 1-20 aus dem Full-Response-Pfad entfernt.

## 4. Normaler CAS-Lifecycle

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

```text
HONAKER_NO_KNOWN_ATTACKERS
```

Das ist ein lokaler Statusreport, nicht automatisch `CAS_COMPLETE`.

### 5.2 CAS meldet keinen Kontakt

```text
CAS_NO_CONTACT_REPORTED
```

Auch das beendet den Auftrag nicht allein. Erst in Verbindung mit Honakers lokalem Status kann das unterstützte Element im Acceptance-Modell ausdrücklich freigeben.

### 5.3 CAS meldet relevanten verbleibenden Kontakt

Der Auftrag bleibt aktiv. Die CAS-Mission darf weiter wirken, soweit der Kontakt vom aktuellen Tasking erfasst ist.

Ein neuer/unabhängiger Kontakt darf nicht allein deshalb automatisch bekämpft werden, weil er RED ist. Ein solcher Kontakt ist Report-/Retask-Gegenstand.

### 5.4 CAS kann nicht weiterarbeiten

Bingo, Winchester, Battle Damage, Emergency oder vergleichbare `unable to continue`-Zustände sind ein eigener Abbruchpfad.

## 6. Gepinnter MOOSE-Nachweis für PATROLZONE + SetEngageDetected

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Source-verifiziert:

```text
AUFTRAG:NewPATROLZONE(...)
AUFTRAG:SetEngageDetected(...)
OPSGROUP:SetEngageDetectedOn(...)
OPSGROUP:SetDetection(true)
OPSGROUP:GetDetectedGroups()
ZONE_BASE:IsCoordinateInZone(...)
```

`SetEngageDetected` wird beim MissionExecute auf den OPSGROUP/FLIGHTGROUP übertragen. MOOSE aktiviert dabei die Detection. Der automatische Angriffspfad prüft anschließend das **eigene detectedgroups-Bild des Carriers**.

Damit gilt:

```text
F10-map RED visibility
!=
AH-64D MOOSE/DCS detectedgroups
```

## 7. Korrigierter Acceptance-Vertrag

```text
CAS_REQUIRED
-> CAS_ACTIVE
-> CAS_ON_STATION
-> CAS_CONTACT_REPORTED | CAS_NO_CONTACT_REPORTED
-> CAS_RELEASED_BY_SUPPORTED_ELEMENT
-> CAS_RECOVERING
-> CAS_COMPLETE
```

Der Acceptance-Code benutzt für den CAS-Report ausschließlich das eigene MOOSE-Detektionsbild des AH-64D-Flights. Ground-`TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC` bleibt davon unabhängig.

Der AH-64D gilt erst als on-station, wenn seine FLIGHTGROUP-Koordinate in der CAS-Tactical-Zone liegt. Vorher darf ein leerer Detection-Set nicht als `NO CONTACT` interpretiert werden.

Sobald Honaker `HONAKER_NO_KNOWN_ATTACKERS` meldet:

```text
if CAS is on station AND CAS reports no engagement-eligible detected ground group:
    supported element explicitly releases CAS

if CAS is on station AND CAS reports an engagement-eligible detected ground group:
    CAS remains active
```

Die zweite Information stammt ausschließlich aus dem eigenen MOOSE/DCS-Detektionsbild des CAS-Flights.

## 8. Ziel-/Informationsgrenze

Die PATROLZONE-Mission darf nur die konfigurierte MOOSE-Zielpolicy ausführen:

```text
engageDetectedRangeNm = 5
engageDetectedTargetTypes = Ground Units
engage zone = Honaker CAS tactical zone
```

Der Acceptance-Code injiziert keine allwissende RED-Liste und verwendet kein `KnowTarget()` zur Zielzuführung.

## 9. Reale Build-1-19-Evidenz vom 08.09.2026

Der Full-Response-Lauf zeigte:

```text
AH-64D CAS allocated: YES
PATROLZONE + SetEngageDetected assigned: YES
configured corridor: YES
CAS weapon shot evidence: NO
Honaker attack incident closed: YES
5-NM RED groups at closure: 4 (diagnostics only)
old code closed CAS immediately from attackIncidentClosed: YES
```

Damit ist Build 1-19 für den CAS-Lifecycle nicht validiert. Guard, QRF, ARTY und CH-47 bleiben getrennte positive Evidenz.

## 10. Reale fokussierte CAS-Evidenz vom 08.09.2026

Nach der Lifecycle-Korrektur wurde der fokussierte Test `STAGE3-HONAKER-CAS-SUPPORT-ACCEPTANCE-1-1` mit dem gepinnten MOOSE-Stand ausgeführt.

Reale Beobachtung/Logs:

```text
both AH-64D attacked: YES
MOOSE PATROLZONE + SetEngageDetected produced weapon employment: YES
both AH-64D were subsequently lost: YES
Guard/QRF/ARTY interaction: NOT IN SCOPE
later remaining-group behavior after local incident changes: NOT IN SCOPE
```

Dieser Lauf bestätigt damit **Engagement-Funktion**, aber weder Survivability noch das Zusammenspiel mit der vollständigen Stage-3-Reaktionskette.

Der nächste notwendige Test ist deshalb der korrigierte Full-Response-Build 1-20.

## 11. Full-Response Build 1-20

Build 1-20 übernimmt die im fokussierten Test bewährte CAS-Supportzustandslogik in den Gesamtintegrationslauf:

```text
Honaker local incident completion
-> QRF recovery may proceed
-> CAS does NOT automatically close
-> AH-64 own GetDetectedGroups picture remains active
-> eligible CAS contact present: CAS stays active
-> no eligible CAS contact + Honaker no-known-attackers: supported-element release
```

Zusätzliche Runtime-Marker:

```text
HONAKER_LOCAL_PICTURE
CAS_SENSOR_REPORT
CAS_ENGAGE_EVENT
EVENTS.Shot
SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
```

Damit ist der nächste Lauf ausdrücklich dafür ausgelegt zu beantworten, ob die AH-64 nach Wirkung von Guard/QRF/ARTY noch vorhandene, selbst erkannte relevante Gruppen weiter angreifen.

## 12. Static Gate vor dem nächsten DCS-Lauf

```text
closeAttackIncidentIfClear() does not directly close CAS
no closeCasIfReady() legacy function
no tactical RED count controls CAS closure
CAS closure requires explicit supported-element release state
CAS no-contact evaluated only after CAS on station
CAS contact report uses FLIGHTGROUP:GetDetectedGroups()
PATROLZONE + SetEngageDetected remains MOOSE-owned
configured recovery corridor remains intact
Lua syntax PASS
Documentation validation PASS
builder hash == independent local hash
```

`VALIDATED` bleibt bis zu einem neuen realen Full-Response-DCS-Lauf false.
