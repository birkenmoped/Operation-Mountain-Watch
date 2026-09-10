---
document_id: OMW-MOOSE-STAGE3-CAS-LIFECYCLE-RECOVERY-LAW
status: BINDING
document_class: TECHNICAL_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local normative CAS request, allocation, execution, release and recovery lifecycle
  - separation of CampaignState, supported element/C2 and MOOSE AIRWING/WAREHOUSE authority
  - mandatory CAS route, release and physical-recovery invariants
  - Stage-3 CAS regression prevention and acceptance evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local assumptions that target destruction, ground incident closure, raw RED counts, fuel state or a MOOSE mission cancellation are a successful CAS completion
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 – Gesetz für CAS-Lifecycle und physische Recovery

## 1. Verbindlichkeit und Geltungsbereich

Dieses Dokument ist die verbindliche branch-lokale Norm für jeden Stage-3-CAS-Auftrag. Bis zu einem Merge nach `main` besitzt es keine repository-weite Wirkung; innerhalb dieses Branches darf kein CAS-Code, Bundle, Test oder Folgehand-off davon abweichen.

Es ergänzt, ohne zu ersetzen:

- [CAS Support Requirement and Engagement Decision](STAGE3-CAS-SUPPORT-REQUIREMENT-AND-ENGAGEMENT-DECISION.md);
- [CAS Tactical Corridor Decision](STAGE3-CAS-TACTICAL-CORRIDOR-DECISION.md);
- [Testmissionen bauen, übertragen und validieren](../22-test-mission-build-transfer-and-validation-workflow.md).

## 2. Unveränderliche Autoritätsgrenzen

| Ebene | Verbindliche Aufgabe | Darf nicht |
|---|---|---|
| Unterstütztes Element, z. B. Honaker | Lokales Lagebild; CAS-Bedarf erzeugen und halten; normale CAS-Freigabe aussprechen | MOOSE-DCS-Detektion der AH-64 ersetzen oder einen Luftweg erfinden |
| C2 | Bedarf priorisieren, eine passende verfügbare Herkunftsressource wählen und retasken; 5-NM-Feuerbeobachtung für QRF/ARTY führen | lokale Honaker-Incident-Daten als CAS-Ende behandeln |
| CampaignState | Strategische Ressourcen-ID, Herkunft, Reservierung, Status und idempotente Übernahme bestätigter physischer Ereignisse | paralleler physischer Flugzeugbestand oder Freigabe vor bestätigter Rückkehr |
| MOOSE | AIRWING/WAREHOUSE-/LEGION-Asset ausführen, `AUFTRAG`, `FLIGHTGROUP`, PATROLZONE, Detection, Route, Landung und Rückgabe verwalten | taktische Route, Freigabeautorität oder strategischen Ressourcenbesitz selbst erfinden |

DCS-Gruppen sind nur die temporäre physische Repräsentation der von MOOSE verwalteten Asset-Instanz.

## 3. Regulärer Ablauf

```text
CAS_REQUIRED
-> C2_ALLOCATED
-> AIRWING_ASSET_RECRUITED
-> AUFTRAG_ASSIGNED
-> LAUNCHED
-> ROUTE_TO_AO
-> CAS_ON_STATION
-> CAS_CONTACT_REPORTED | CAS_NO_CONTACT_PENDING
-> CAS_NO_CONTACT_REPORTED (stable >= 30 s)
-> SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
-> RECOVERING_ON_OWNER_REVERSE_ROUTE
-> HOME_AIRBASE_LANDED
-> LEGION_ASSET_RETURNED
-> CAS_COMPLETE
```

`CAS_COMPLETE` tritt ausschließlich nach der physischen Landung am zugewiesenen Heimatflugplatz **und** der MOOSE-`AIRWING:OnAfterLegionAssetReturned`-Rückgabe ein. Ein `AUFTRAG:Cancel()`, `Done`, ein Return-Befehl oder der Beginn eines Rückflugs ist keine Rückgabe in den Warehouse-/AIRWING-Bestand.

## 4. Bedarf, Allokation und Start

1. Honaker erzeugt einen CAS-Bedarf, wenn seine eigene lokale Lage externe Luftunterstützung verlangt.
2. C2 allokiert eine freie, ausdrücklich gebundene Herkunftsressource. Im aktuellen Full-Response-Szenario ist dies eine Jalalabad-AH-64D-Ressource.
3. MOOSE `AIRWING` rekrutiert die zugehörige Asset-/LEGION-Repräsentation aus seinem AIRWING-/Warehouse-Bestand und startet den zugewiesenen Auftrag.
4. Der Auftrag ist `AUFTRAG:NewPATROLZONE(...)` mit `SetEngageDetected(...)`. Die konkrete Allokation bestimmt das Profil; im Honaker-Full-Response-Test beträgt die AH-64-Transitgeschwindigkeit 125 kt.

Kein globaler, ungebundener AIRWING-Pool darf eine andere strategische Herkunft wählen.

## 5. Routengesetz

Die Owner-Routen sind die alleinige Quelle der Transitgeometrie:

```text
Heimatflugplatz
-> konfigurierte OMW_FlightPath-Variante
-> WEST
-> dynamischer CAS_INGRESS
-> PATROLZONE-AO
-> dynamischer CAS_EGRESS
-> WEST reverse
-> konfigurierte OMW_FlightPath-Variante reverse
-> Heimatflugplatz
```

Für **jede** Allokation gilt:

- `CAS_INGRESS` wird aus der tatsächlich gewählten Anflugroute im 3–4-NM-Band vor der AO abgeleitet.
- `CAS_EGRESS` wird aus der tatsächlichen Rückroute im 3–4-NM-Band nach der AO abgeleitet.
- Beide sind dynamische Routenpunkte, keine statischen Mission-Editor-Marker, PATHLINE-Endpunkte, Resolver-Endpunkte oder zufälligen MOOSE-Punkte.
- `CAS_MISSION_POINT` ist nur der dynamische AO-Anker von `PATROLZONE`; er ist keine erfundene Battle Position.
- MOOSE erhält diese drei Einzelknoten über `SetMissionIngressCoord`, `SetMissionWaypointCoord` und `SetMissionEgressCoord`. Die vollständigen Owner-Segmente werden ausschließlich mit öffentlichen `FLIGHTGROUP:AddWaypoint`-/`UpdateRoute`-Methoden installiert und über `OnAfterUpdateRoute` bestätigt.

Eine direkte Rückkehr zum Heimatflugplatz, ein Abkürzen durch Luftlinie oder ein UID-/Gebirgseinstieg außerhalb der abgeleiteten Owner-Route ist ein Regression-FAIL.

## 6. Auftrag in der AO

MOOSE führt `PATROLZONE + SetEngageDetected` aus. Das maßgebliche Luftlagebild kommt ausschließlich aus:

```lua
state.casFlight:GetDetectedGroups()
```

Ein gültiger Kontakt ist eine erkannte, lebende rote Bodengruppe innerhalb der konfigurierten CAS-Zone und des Engagement-Umfangs. Sichtbarkeit auf der F10-Karte, ein OPSZONE-Scan, Incident-Teilnehmer oder eine globale RED-Liste sind kein Ersatz. `KnowTarget()` und vergleichbare allwissende Zielinjektion sind verboten.

Sobald CAS physisch on station ist, sperrt C2 nur **neue** ARTY-Feuermissionen. Laufende Feueraufträge werden nicht künstlich abgebrochen.

## 7. Einzige normale Freigabe

Die reguläre Freigabe erfordert gleichzeitig:

```text
Honaker: HONAKER_NO_KNOWN_ATTACKERS
AND
AH-64: physically ON STATION
AND
AH-64 own FLIGHTGROUP:GetDetectedGroups(): no engagement-eligible contact
AND
the own no-contact picture remained stable for >= 30 seconds
```

Erst dann darf das unterstützte Element auslösen:

```text
SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
```

Danach darf MOOSE den PATROLZONE-Auftrag kontrolliert schließen und ausschließlich über die installierte Reverse-Route recovern.

Die folgenden Werte besitzen ausdrücklich **keine** CAS-Termination-Authority:

```text
OPSZONE Defeated
attackIncidentClosed
zero incident participants
raw RED count
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC
C2_FIRE_OBSERVATION
state.casFired
AUFTRAG completion/cancellation alone
```

Solange die Freigabe nicht vorliegt und kein dokumentierter Unable-to-Continue-Abbruch eingetreten ist, bleibt der CAS-Auftrag aktiv; ein Verharren bis Bingo ist jedoch kein akzeptierter Normalabschluss.

## 8. Abbruch, Verlust und Rückführung

Bingo/FuelLow, Winchester, Battle Damage, Emergency oder Verlust sind gesonderte Abbruch-/Verlustpfade. Sie erzeugen niemals künstliche `CAS_COMPLETE`-, Landungs- oder Warehouse-Rückgabe-Evidenz.

Ein Abbruch darf erst dann als kontrollierte Rückkehr gelten, wenn eine separate C2-Entscheidung, die installierte Reverse-Route, die physische Landung und die MOOSE-Asset-Rückgabe nachgewiesen sind. Andernfalls bleibt er `FAIL`, `PARTIAL` oder `NOT_RUN` gemäß Ergebnisbericht.

## 9. Pflicht-Evidenz und Regression-Gates

Vor einem DCS-Lauf müssen Source und Bundle mindestens ausgeben beziehungsweise prüfen:

```text
C2 allocation and bound origin pool
AIRWING asset recruitment
CAS_ROUTE_GATES_DERIVED
CAS_GEOMETRY_CONFIGURED
CAS_CORRIDOR_INSTALLED or explicit OnAfterUpdateRoute readiness
CAS_ON_STATION
CAS_SENSOR_REPORT from FLIGHTGROUP:GetDetectedGroups()
CAS_NO_CONTACT_REPORTED
SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
home-airbase landing
AIRWING/LEGION asset returned
```

Der reale DCS-Nachweis muss die vollständige Hashkette sowie die sichtbare Route und die physische Rückgabe belegen. Bis zu diesem Nachweis ist der Vertrag geplant/source-geprüft, nicht DCS-validiert.
