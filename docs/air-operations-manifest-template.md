---
document_id: OMW-AIR-MANIFEST-TEMPLATE
status: BINDING
document_class: AUTHORING_TEMPLATE
owning_policy: OMW-GOV-001
authoritative_for:
  - minimum structure of future basis-specific air operations manifests
not_authoritative_for:
  - local ORBAT decisions
  - DCS runtime acceptance
scenario_period:
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/document-salerno-air-operations
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Vorlage für zukünftige Air-Operations-Manifeste

Diese Datei ist zusammen mit [`OMW-AIR-MANIFEST-NAMING`](52-air-operations-manifest-naming-standard.md) als Arbeitsvorlage zu verwenden. Platzhalter werden vollständig ersetzt; nicht zutreffende Abschnitte bleiben mit begründeter Kennzeichnung erhalten.

## 1. Autorität und Standort

```yaml
document_id: OMW-AIR-<LOCATION>-MANIFEST
status: PLANNED
owning_policy: OMW-GOV-001
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
validated_in_dcs: false
```

```text
Standort:
Standortkürzel:
DCS-Airbase-Name:
DCS-Airbase-ID:
Koalition/Land:
AIRWING:
Warehouse-Anker:
COMMANDER-Zuordnung:
```

## 2. Aktive Einheiten und logischer Bestand

| Verband/Element | historisches Muster | DCS-Abbildung | lokaler Bestand | Evidenzklasse |
|---|---|---|---:|---|
|  |  |  |  |  |

## 3. Player-Gruppen

```text
CLIENT_US_<BASE>_<PLAYER_TYPE>_01
  CLIENT_US_<BASE>_<PLAYER_TYPE>_01_UNIT_01
CLIENT_US_<BASE>_<PLAYER_TYPE>_02
  CLIENT_US_<BASE>_<PLAYER_TYPE>_02_UNIT_01
```

Dokumentieren:

- DCS-Modulvariante;
- Cold-/Hot-Start;
- Parking-/Helipad-ID;
- Modul- oder Modabhängigkeit;
- Ausfallverhalten ohne optionales Modul.

## 4. KI-Templates

```text
TPL_AIR_US_<BASE>_<TYPE>_<ROLE>_<FORMATION>
  TPL_AIR_US_<BASE>_<TYPE>_<ROLE>_<FORMATION>_UNIT_01
```

Je Template dokumentieren:

| Feld | Wert |
|---|---|
| Gruppengröße |  |
| DCS-Typ |  |
| DCS-Haupttask |  |
| OMW-Rollen |  |
| Skill |  |
| Late Activation | ja |
| Uncontrolled | nein |
| Payload/ROE |  |
| Start-/Recovery-Verfahren |  |

## 5. Statische Luftfahrzeuge

```text
STATIC_AIR_US_<BASE>_<TYPE_OR_ROLE>_01 ... _NN
```

| Serie | Zahl | Rampenbereich | Bestandsbezug |
|---|---:|---|---|
|  |  |  |  |

## 6. MOOSE-Struktur

```text
AW_US_<LOCATION>
└── SQ_US_<BASE>_<TYPE>_<UNIT_OR_ROLE_IDENTIFIER>

WH_AIR_US_<LOCATION>
```

| SQUADRON | logischer Bestand | Templategröße | Ngroups | Reservebehandlung |
|---|---:|---:|---:|---|
|  |  |  |  |  |

## 7. Parking und Flächen

Dokumentieren:

- Clientpositionen;
- KI-Start-/Ready-/Recovery-Positionen;
- Static-Bereiche;
- Blacklist-Kandidaten;
- Sicherheits- und Rotorabstände;
- Hot-Refueling-/Turnaround-Flächen;
- Wartungsflächen;
- Transit- und Logistikflächen;
- nicht klassifizierte oder gesperrte Flächen.

## 8. Funktionszonen

Nur tatsächlich benötigte Zonen anlegen:

```text
ZONE_AIR_US_<BASE>_<FUNCTION>
```

| Zone | Funktion | Radius/Lage | verwendende MOOSE-Funktion |
|---|---|---|---|
|  |  |  |  |

## 9. Nicht anzulegende Objekte

Explizit dokumentieren:

- ausgeschlossene zusätzliche Clientserien;
- nicht benötigte Rollen-Templates;
- verbotene Doppelbestände;
- Flächen ohne Dauerparkfreigabe;
- nicht bestätigte Verbände oder Muster;
- nicht genehmigte Modabhängigkeiten.

## 10. Mindestvalidierung

- [ ] DCS-Airbase-Name und ID bestätigt;
- [ ] Warehouse-Anker durch MOOSE gefunden;
- [ ] Gruppen-, Unit-, Static- und Zonennamen vollständig;
- [ ] Clientobergrenze eingehalten;
- [ ] alle Templates `Late Activation`;
- [ ] Gruppengröße entspricht Formationssuffix;
- [ ] Safe Parking und Blacklists geprüft;
- [ ] kollisionsfreie Spawns und Rückkehr;
- [ ] keine Doppelzählung von Clients, KI, Templates und Statics;
- [ ] AIRWING und SQUADRONs starten ohne spontane Missionen;
- [ ] Verlust- und Rückgabelogik geprüft;
- [ ] Branch, Commit, Mission, Bundle, DCS und MOOSE vollständig nachgewiesen.

## 11. Provenienz nach Acceptance

```yaml
acceptance_branch:
acceptance_commit:
acceptance_mission:
acceptance_mission_sha256:
dcs_version:
moose_commit:
moose_artifact_sha256:
validated_in_dcs: true
```