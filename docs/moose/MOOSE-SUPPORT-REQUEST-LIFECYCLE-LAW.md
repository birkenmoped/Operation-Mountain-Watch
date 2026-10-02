---
document_id: OMW-MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW
status: BINDING
document_class: TECHNICAL_ARCHITECTURE_LAW
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE-first lifecycle of support requests
  - distinction between incident lifecycle and support-mission lifecycle
  - MOOSE queue, cancellation and expiry requirements
  - independent availability of Guard, QRF, ARTY, CAS and resupply
  - verified limitations of the pinned MOOSE request queues
not_authoritative_for:
  - site-specific tactical response deadlines
  - DCS runtime acceptance of an unimplemented generic lifecycle adapter
  - use of MOOSE private queue APIs
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - implicit assumption that an active incident requires every requested support mission to remain queued indefinitely
  - project-specific pre-filtering of MOOSE asset selection
superseded_by:
source_branch: agent/moose-support-request-lifecycle-law
source_commit: 985c142f19b42c5048e46698fc275b61063dc730
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# MOOSE-first-Gesetz für Unterstützungsanforderungen und deren Ablauf

## 1. Zweck und Geltung

Dieses Gesetz regelt projektweit den Lifecycle aller aus einem Angriff oder einer anderen Lage abgeleiteten Unterstützungsanforderungen. Es gilt insbesondere für Guard, QRF, ARTY, CAS sowie Boden-, Luft- und sonstigen Resupply einschließlich Personal, Treibstoff, Artilleriemunition, sonstiger Munition und logistischer META-Bestände wie Verpflegung.

Es gilt für Luft-, Boden- und Transport-Assets gleichermaßen. Es ist nicht auf Jalalabad, Honaker, Wright oder einen einzelnen Acceptance-Test beschränkt.

Die im Stage-3-Honaker-Test dokumentierten CAS-Freigabe- und Recovery-Kriterien bleiben test- und missionsspezifisch. Dieses Gesetz ersetzt sie nicht, sondern definiert die allgemeine MOOSE-first-Behandlung von Bedarf, Warten, Abbruch und Ressourcenverfügbarkeit.

## 2. Verbindliche Verantwortungsgrenzen

| Ebene | Zuständigkeit |
|---|---|
| Installation / lokale Lage | Angriff erkennen, Incident führen und Unterstützungsbedarf fachlich melden |
| CampaignState | persistente strategische Ressourcenidentität, Reservierung, Transit, bestätigte Lieferung, Rückkehr, Verlust und idempotente Buchung |
| MOOSE COMMANDER, CHIEF, LEGION, AIRWING, BRIGADE, COHORT, AUFTRAG, OPSTRANSPORT, WAREHOUSE, ARTY | operative Auswahl, Queue, Materialisierung, Auftrag, Transport, Abbruch und beobachtbarer physischer Lifecycle |
| OMW-Adapter | MOOSE-Aufträge aus einem fachlichen Bedarf erzeugen, Incident-Ende und fachliche Gültigkeitsfrist an den vorhandenen MOOSE-Abbruchpfad weiterreichen sowie MOOSE-Lifecycle-Ereignisse in CampaignState übernehmen |

Der OMW-Adapter darf keine zweite Asset-Auswahl, keine eigene Verfügbarkeitswarteschlange und keinen parallelen Dispatcher bauen.

~~~text
MissionDemand / Incident
-> MOOSE Auftrag oder MOOSE Warehouse-/Transportvorgang
-> MOOSE selektiert und rekrutiert selbst
-> MOOSE führt physisch aus
-> bestätigtes MOOSE-Ereignis
-> idempotente CampaignState-Buchung
~~~

## 3. Unterstützungen sind unabhängige Optionen

Eine Fähigkeit ist niemals Vorbedingung für eine andere.

~~~text
ARTY nicht möglich
!= CAS, Guard, QRF oder Resupply blockieren

CAS nicht verfügbar
!= ARTY, Guard, QRF oder Resupply blockieren

lokales Personal nicht verfügbar
!= externe ARTY, CAS oder bereits laufenden Resupply blockieren
~~~

MOOSE und CampaignState bewerten jede Unterstützungsart eigenständig. Eine bestehende Deconfliction-Regel darf nur den dokumentierten Konflikt begrenzen. Beispiel: Physisch on-station befindliches CAS hält neue ARTY-Feueraufträge im selben taktischen Raum zurück; fehlendes CAS sperrt ARTY nicht.

## 4. MOOSE-first-Auftragserzeugung

### 4.1 Keine projektspezifische Vorselektion von Assets

OMW übergibt den fachlich zulässigen Bedarf an MOOSE. Die Auswahl geeigneter Kohorten, Legionen, Squadrons, Luftfahrzeuge, Bodenfahrzeuge, Carrier und verfügbarer MOOSE-Assets erfolgt durch MOOSE.

Insbesondere ist verboten:

- Kandidatenlisten als Ersatz für COMMANDER-, CHIEF-, LEGION-, AIRWING-, BRIGADE- oder WAREHOUSE-Selektion selbst abzuarbeiten;
- MOOSE-Aufträge nur deshalb nicht zu erzeugen, weil OMW glaubt, aktuell kein Asset zu finden;
- einen zweiten Retry-Dispatcher oder eine zweite Queue neben MOOSE aufzubauen;
- private MOOSE-Queue-Methoden zu verwenden oder deren Tabellen direkt zu verändern.

MOOSE darf einen Auftrag warten lassen, wenn die benötigte Fähigkeit grundsätzlich vorhanden, aber aktuell gebunden ist. Das umfasst etwa ein zurückkehrendes CAS-Asset, eine noch nicht wieder verfügbare Ground Cohort oder einen gerade belegten Transportcarrier.

### 4.2 Fachliche Gültigkeit ist kein Ersatz für Asset-Selektion

Jeder Auftrag erhält bei Erzeugung eine fachliche Gültigkeitsgrenze:

- Incident-Ende beziehungsweise Rücknahme des Bedarfs;
- auftragsbezogene Reaktions- oder Verfallsfrist;
- gegebenenfalls weitere fachliche Failure-Conditions.

Diese Werte beantworten nicht, welches Asset eingesetzt wird. Sie begrenzen nur, ob es nach einer Wartezeit noch sinnvoll ist, den Bedarf auszuführen.

Es werden keine projektweit festen Zeiten vorgegeben. Die Frist ist je Fähigkeit, Bedrohung, Distanz, Route, Auftrag und taktischer Lage zu bestimmen und mit dem jeweiligen Einsatzprofil zu dokumentieren.

## 5. Source-verifiziertes MOOSE-Verhalten

Die folgenden Aussagen sind gegen den im Frontmatter festgelegten MOOSE-Commit und dessen Moose.lua geprüft. Sie sind SOURCE_REVIEWED, nicht DCS-validiert.

### 5.1 AUFTRAG: native Beendigung

Verifizierte öffentliche MOOSE-Methoden:

~~~lua
mission:SetTime(ClockStart, ClockStop)
mission:AddConditionStart(ConditionFunction, ...)
mission:AddConditionSuccess(ConditionFunction, ...)
mission:AddConditionFailure(ConditionFunction, ...)
mission:Cancel()
~~~

AUFTRAG:IsReadyToCancel() liefert wahr, wenn die Endzeit erreicht ist oder mindestens eine Success- oder Failure-Condition wahr wird. In LEGION:CheckMissionQueue() prüft MOOSE diesen Zustand und ruft dann selbst mission:Cancel() auf.

AUFTRAG:Cancel() ist kein bloßer Statuswechsel. Der FSM-Pfad propagiert die Stornierung an CHIEF, COMMANDER, LEGION und zugewiesene OPSGROUP-Instanzen. Noch nicht gestartete Warehouse-Anforderungen einer Legion werden dabei über den vorhandenen Lifecycle entfernt.

### 5.2 COMMANDER und CHIEF: bestätigte Planungsgrenze

COMMANDER:CheckMissionQueue() sortiert geplante Aufträge, prüft Startfähigkeit und versucht, geeignete Assets über RecruitAssetsForMission(...) zu finden. Bei fehlender Rekrutierung bleibt der Auftrag geplant; der geprüfte Pfad klassifiziert ihn nicht selbst als dauerhaft unmöglich.

Im gepinnten Source ruft COMMANDER:CheckMissionQueue() für einen weiterhin PLANNED Auftrag nicht AUFTRAG:IsReadyToCancel() auf. Gleiches gilt für den hier geprüften CHIEF-Planungsweg. SetTime(..., Tstop) oder AddConditionFailure(...) allein garantiert daher nicht, dass ein noch nicht zugewiesener Auftrag aus dieser Planungsqueue verschwindet.

Der native Abbruchpfad existiert dennoch:

~~~text
AUFTRAG:Cancel()
-> CHIEF:MissionCancel(...) oder COMMANDER:MissionCancel(...)
-> geplante Mission: COMMANDER/CHIEF RemoveMission(...)
-> zugewiesene Mission: Legion-Cancel- und Gruppen-Lifecycle
~~~

Daraus folgt die verbindliche kleinste Ergänzung:

> Für beim COMMANDER oder CHIEF noch geplante Support-Aufträge muss ein ereignisgebundener OMW-Lifecycle-Adapter bei Incident-Ende oder Ablauf der fachlichen Frist nur AUFTRAG:Cancel() auslösen. Er darf keine Asset-Selektion, Rekrutierung oder Parallelqueue übernehmen.

Ein einmaliges Ablaufereignis oder ein Incident-Endereignis ist zulässig. Hochfrequentes Polling, globale Welt-Scans und blinde Retry-Schleifen sind verboten.

### 5.3 Direkte LEGION-, AIRWING- und BRIGADE-Queues

LEGION:AddMission(...) stellt den Auftrag auf QUEUED. LEGION:CheckMissionQueue() versucht die Rekrutierung wiederholt und wertet zugleich IsReadyToCancel() aus.

Für direkt an AIRWING, BRIGADE oder eine andere LEGION übergebene Aufträge sind SetTime(...) und die nativen Conditions deshalb der vorrangige MOOSE-Mechanismus für eine begrenzte Wartezeit und deren Abbruch.

### 5.4 OPSTRANSPORT

Verifizierte öffentliche MOOSE-Methoden:

~~~lua
transport:SetTime(ClockStart, ClockStop)
transport:AddConditionStart(ConditionFunction, ...)
transport:Cancel()
~~~

OPSTRANSPORT besitzt die Zustände PLANNED, QUEUED, REQUESTED, SCHEDULED, EXECUTING, DELIVERED, CANCELLED, SUCCESS und FAILED. Cancel() propagiert die Stornierung an CHIEF, COMMANDER, LEGION oder die Carrier. Ein noch geplanter Transport wird vom COMMANDER oder CHIEF aus dessen Queue entfernt.

Die im aktuellen Source sichtbare OPSTRANSPORT-API enthält AddConditionStart; eine gleichartige öffentliche Failure-Condition wie bei AUFTRAG wurde für diesen Commit nicht verifiziert. Daher ist für Ablauf oder Incident-Ende der explizite native Aufruf transport:Cancel() zu verwenden.

### 5.5 WAREHOUSE

MOOSE WAREHOUSE besitzt selbst zwei relevante Kategorien:

| Kategorie | Source-verifiziertes Verhalten |
|---|---|
| Dauerhaft ungültige Anfrage | MOOSE entfernt sie aus der Warehouse-Queue, etwa bei fehlender Straßen-, Off-road- oder See-Verbindung, ungeeigneten Airbase-Typen, fehlendem Terminaltyp, zerstörtem oder gestopptem Ziel oder nicht implementiertem Transporttyp. |
| Temporär nicht verarbeitbare Anfrage | MOOSE hält sie in der Queue, etwa bei aktuell fehlenden Parkpositionen, momentan nicht laufendem Ziel-Warehouse, fehlenden momentan freien Cargo- oder Transportassets. |

Diese Prüfung ist MOOSE-first zu verwenden und darf nicht durch OMW-Listen ersetzt werden.

Es besteht jedoch eine verifizierte Grenze: WAREHOUSE:_CheckRequestValid(...) akzeptiert eine Anfrage ohne aktuell passenden Bestand zunächst weiter, weil die vollständige Gültigkeitsprüfung ohne repräsentatives Stock-Asset nicht durchgeführt wird. Der Request kann damit in der Queue bleiben, obwohl strategisch nie wieder ein passender Bestand entstehen wird.

Eine öffentliche, einzelne Warehouse-Request-Expiry- oder Cancel-Methode wurde in diesem gepinnten Source nicht verifiziert. Die gefundenen _DeleteQueueItem...-Methoden sind intern und dürfen produktiv nicht aufgerufen werden.

Folge:

> Für rohe WAREHOUSE:AddRequest(...)-Anforderungen darf kein privater Queue-Eingriff implementiert werden. Vor einer generischen produktiven Ablaufgarantie ist entweder eine öffentliche MOOSE-API in einer geprüften Version nachzuweisen oder die Anforderung über einen bereits kontrollierten öffentlichen MOOSE-OPSTRANSPORT-/Auftragslifecycle zu modellieren. Diese Lücke bleibt offen und benötigt vor einer Ausnahme eine separate MOOSE-First-Gap-Analyse und Projektinhaberfreigabe.

### 5.6 ARTY

ARTY:AssignTargetCoord(...) und ARTY:AssignAttackGroup(...) führen eine eigene Zielqueue. ARTY:RemoveTarget(name) entfernt ein Ziel; ist es aktuell in Bekämpfung, wird die Bekämpfung abgebrochen. ARTY:SetTimeToShot(...) bricht nach einer konfigurierten Wartezeit ohne ersten Schuss den Feuerauftrag ab und entfernt das Ziel.

ARTY-Ziele werden nur über den MOOSE-ARTY-Pfad erzeugt und beendet. Eine fehlende Batterie, Reichweiten-, Munitions- oder Waffenfähigkeit darf keine anderen Unterstützungen sperren.

## 6. Verbindlicher Ablauf je Unterstützungsbedarf

~~~text
Incident bleibt fachlich aktiv
-> für jede zulässige Support-Fähigkeit separaten MOOSE-Bedarf erzeugen
-> MOOSE selektiert, rekrutiert, wartet oder führt aus
-> MOOSE-Lifecycle meldet Dispatch, Erfolg, Stornierung, Rückkehr, Verlust oder Lieferung
-> CampaignState übernimmt ausschließlich bestätigte strategische Folgen

Incident-Ende oder fachliche Verfallsfrist
-> nativer MOOSE Cancel-Pfad der noch relevanten Support-Anforderung
-> keine neue Ausführung nach Ende des Bedarfs
~~~

Ein Incident und ein Support-Auftrag sind nicht derselbe Lifecycle:

~~~text
Incident aktiv
!= jede Support-Anforderung muss unendlich offen bleiben

Support-Auftrag abgebrochen oder nicht startbar
!= Incident ist automatisch beendet
~~~

Ein abgebrochener Auftrag wird mit Ursache protokolliert. Zulässige Ursachen sind beispielsweise:

~~~text
INCIDENT_RESOLVED
TACTICAL_VALIDITY_EXPIRED
MOOSE_MISSION_CANCELLED
MOOSE_TRANSPORT_CANCELLED
MOOSE_WAREHOUSE_INVALID_REQUEST
MOOSE_ARTY_TARGET_ABORTED
~~~

Die Ursache ist ein Nachweis- und Diagnosewert, keine zweite MOOSE-Entscheidungslogik.

## 7. Personal- und Resupply-Realität

Resupply ist nicht auf ARTY-Shells begrenzt. Die strategische Buchhaltung unterscheidet mindestens:

~~~text
GROUND_PERSONNEL
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
SUPPLY / META_SUPPLY
~~~

Strategischer Bestand am Ziel wird erst nach bestätigter physischer Lieferung erhöht. Ein in Transit befindlicher Personal- oder Munitionskonvoi ist keine bereits am FOB verfügbare Ressource.

Beispiel:

~~~text
Erster Angriff
-> FOB verliert Personal
-> Personal-Resupply wird durch MOOSE gestartet

Zweiter Angriff während des Transits
-> MOOSE kann keine lokale Guard-/QRF-Kohorte rekrutieren
-> der Ground-Auftrag wartet nur innerhalb seiner fachlichen Gültigkeit
-> externe ARTY und/oder CAS bleiben unabhängig möglich
-> bestätigte Ankunft des Konvois erhöht erst dann CampaignState-Bestand
-> ein weiterhin aktiver MOOSE-Auftrag kann danach rekrutiert werden
~~~

Es erfolgt weder magische Personalverfügbarkeit noch ein Blockieren der übrigen Fähigkeiten.

## 8. Verbotene Umgehungen

Folgendes ist projektweit verboten:

- Asset- und Kandidatenwahl vor MOOSE als parallele OMW-Logik;
- eigene Support-Queues oder Retry-Dispatcher neben MOOSE;
- direkter Zugriff auf private MOOSE-Queues, _DeleteQueueItem... oder vergleichbare Interna;
- künstliche Erfolgsmeldung bei Cancel(), Done, Rückkehrbefehl oder nicht bestätigter Lieferung;
- Übernahme eines noch in Transit befindlichen Resupply als Zielbestand;
- Ableitung einer allgemeinen DCS-Validierung aus dieser Source-Prüfung;
- Blockieren unabhängiger Support-Arten wegen einer nicht leistbaren anderen Support-Art.

## 9. Verpflichtende Akzeptanz vor generischem Einsatz

Vor einem produktiven standortunabhängigen FireSupStratResupply_base.lua- oder vergleichbaren Einsatz sind mindestens zu testen:

1. kein passendes, aber später zurückkehrendes CAS- oder Ground-Asset: MOOSE wartet und startet nur bei weiterhin gültigem Bedarf;
2. Incident endet vor Rekrutierung: geplanter COMMANDER- oder CHIEF-Auftrag wird über AUFTRAG:Cancel() aus MOOSE entfernt;
3. Ablauf der fachlichen Frist vor Rekrutierung: gleicher MOOSE-Cancel- und Queue-Entfernungsnachweis;
4. direkte LEGION-, AIRWING- oder BRIGADE-Queue: Tstop und Failure-Condition führen zum nativen Cancel;
5. fehlende ARTY-Reichweite: keine Blockade von CAS, Guard, QRF oder Resupply;
6. fehlendes lokales Personal während Personal-Resupply-Transit: keine Guard-/QRF-Materialisierung vor bestätigter Lieferung, externe Unterstützung bleibt möglich;
7. jeder relevante Cancel-, Delivery-, Return- und Loss-Pfad aktualisiert CampaignState genau einmal;
8. WAREHOUSE: dauerhaft ungültige Anfrage wird durch MOOSE entfernt; temporär nicht verarbeitbare Anfrage wird bei späterer MOOSE-Verfügbarkeit verarbeitet;
9. die offene Warehouse-Nullbestand-/Einzelrequest-Expiry-Grenze wird nicht mit privaten APIs umgangen.

Bis zu diesen DCS-Nachweisen bleibt dieses Gesetz eine verbindliche Source- und Architekturregel, aber keine Runtime-Acceptance.