# UAV ISR Acceptance 3 — Kandahar On-Station orbit

> **Status: keine Produktionsfreigabe.** Der bisherige A3-12-Ansatz mit einer
> lokalen 30-Sekunden-Dispatch-Wiederholung ist verworfen und darf nicht als
> Abnahmebundle verwendet werden. Der vollständige Fehler- und Entscheidungsverlauf
> steht in
> [docs/handoffs/2026-08-28-uav-isr-request-error-and-decision-register.md](../../../docs/handoffs/2026-08-28-uav-isr-request-error-and-decision-register.md).

## Scope

Diese getrennte, nichtproduktive Acceptance-Mission erweitert Acceptance 2. Ein
BLUE-Spielermarker löst einen MOOSE-AIRWING-Auftrag mit dem vorhandenen
Kandahar-MQ-9-Mission-Editor-Template aus. Am übermittelten Marker soll der
Auftrag einen MOOSE-`AUFTRAG:NewORBIT_CIRCLE` verwenden.

Die Akzeptanzkonfiguration bindet den AUFTRAG ausdrücklich an die Kandahar
MQ-9-Staffel. Das ist nötig, da MOOSE der generischen `ORBIT`-Fähigkeit
nicht allein einen bestimmten Flugzeugtyp zuordnet.

`SetDuration(2700)` begrenzt den Auftrag auf 2.700 Sekunden. In der
geprüften MOOSE-Quelle wird der Ausführungszeitstempel beim `Executing`-Event
gesetzt; beim ORBIT-Auftrag ist dies der Orbit-Wegpunkt, nicht der Start.
Der Timer ist damit ein On-Station- und kein Transitlimit.

Profil: 25.000 ft MSL, 180 kt IAS, Kreisorbit über dem Marker. Dieses
Acceptance-Profil ist keine Produktionsfreigabe für Terrain-Korridore,
RC-East-Holding, Bagram-Sourcing, Persistenz, Produktionswartung,
Fog-of-War oder Waffenverwendung.

## Bekannte verworfene Architektur

Der bisherige Ablauf reservierte zuerst in CampaignState und übergab den
AUFTRAG nur bei Erfolg an `AIRWING:AddMission`. Dadurch konnte ein
strategisch abgelehnter, aber weiterhin gültiger Spielerauftrag nie in
MOOSEs AIRWING-Missionswarteschlange stehen. Der anschließend eingeführte
lokale Retry mit MOOSE-`SCHEDULER` bildet eine parallele Admission-Queue und
verstößt gegen die verbindliche MOOSE-first-Richtlinie.

Deshalb gilt bis zur Neuplanung:

- keine Aussage, ein aktuelles Bundle behebe „alle Probleme“;
- kein weiterer DCS-Abnahmetest des A3-12-Retry-Pfads;
- keine Übernahme dieser Logik in Produktion;
- zuerst vollständige Prüfung von AIRWING-Queue, AUFTRAG-FSM und öffentlichen
  MOOSE-Lifecycle-Callbacks passend zur tatsächlich geladenen MOOSE-Version.

## Narrow no-takeoff recall exception

**Anforderung:** Ein gespawnter MQ-9, der vor dem tatsächlichen Takeoff
zurückgerufen und entfernt wird, soll nicht die reguläre Flug-Turnoverzeit
erhalten.

Die nachträgliche umfassende Recherche dokumentiert:

- öffentliche Cohort-Methoden `SetTurnoverTime`, `GetRepairTime` und
  `IsRepaired`;
- keine öffentliche per-Asset-Methode zum Aufheben eines
  Rückgabezeitstempels;
- internes LEGION-Feld `Asset.Treturned`, das beim Rückgabepfad gesetzt wird;
- lokale `Moose.lua` SHA-256:
  `e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915`;
- keine offizielle MOOSE-Beispielmission mit einer öffentlichen
  Einzelasset-Turnover-Ausnahme.

Ein direkter Zugriff auf `Asset.Treturned` bleibt daher ausschließlich eine
eng begrenzte Acceptance-Ausnahme. Er ist keine stabile MOOSE-API, keine
Produktionswartungspolitik und nicht rückwirkend durch die Recherche
freigegeben. Details, Unsicherheiten und die erforderliche Genehmigungsakte
enthält das Fehlerregister.

Ein bestätigter echter Flug behält die reguläre MOOSE-Turnoverzeit. Eine
Bodenrückruf-Ausnahme darf erst nach physischer MOOSE-Rückgabe und nur bei
fehlendem bestätigten Takeoff geprüft werden.

## Build

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-uav-isr-request-acceptance-3.ps1
```

Das Build-Resultat darf erst nach der MOOSE-first-Neuplanung als Testkandidat
bezeichnet werden. Vorher ist es lediglich ein historischer Entwicklungsstand.

## Pflicht vor erneutem DCS-Test

1. Die aktuelle MOOSE-Version/Hash in der tatsächlich geladenen Mission
   feststellen.
2. AIRWING-`AddMission`-Queue, AUFTRAG-Zustände und verfügbare öffentliche
   FSM-Callbacks in Dokumentation, Quellcode und offiziellen Missionen
   untersuchen.
3. CampaignState-Abgleich und Differenzbehandlung ohne lokale
   Ressourcenwarteschlange entwerfen und vom Projektinhaber freigeben lassen.
4. Erst dann eine neue Bundle-Version bauen.
5. Danach mindestens getrennt testen: mehrere nachgelagerte Requests,
   Bodenabbruch, Flugabbruch/Return, tatsächlichen Turnover und
   CampaignState/MOOSE-Differenz.

## Historischer Acceptance-Nachweis, nicht PASS-Kriterium

Vor der Verwerfung waren folgende Nachweise vorgesehen: exakter BLUE-F10-Marker
`UAV RECON`, korrelierte Lifecycle-Logs, Kreisorbit über Marker, Abbruch in
Queued/Boden/Transit/On-Station sowie getrennte Boden- und Flug-Return-Fälle.
Diese bleiben als Anforderungen bestehen, gelten aber nicht als bestanden,
solange die zugrunde liegende Queue-Architektur nicht MOOSE-first korrigiert
ist.
