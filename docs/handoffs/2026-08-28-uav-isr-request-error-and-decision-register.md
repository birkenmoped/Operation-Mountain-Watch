---
document_id: OMW-UAV-ISR-REQUEST-ERROR-REGISTER-2026-08-28
status: HISTORICAL_TEST_FIXTURE
document_class: ERROR_AND_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - observed errors in the UAV ISR request acceptance branch
  - rejected implementation paths
  - required evidence before a replacement architecture is accepted
not_authoritative_for:
  - production UAV ISR architecture
  - DCS behavior not demonstrated by the cited evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/uav-isr-request-orchestration
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# UAV-ISR-Request – Fehler-, Irrtums- und Entscheidungsprotokoll

## Zweck und ehrliche Einordnung

Dieses Dokument erfasst die im bisherigen Acceptance-3-Verlauf erkannten Fehler,
Fehlannahmen, unzureichenden Prüfungen und daraus entstandenen falschen
Korrekturen. Es ersetzt keine technische Abnahme und beschönigt keinen
getesteten Fehler als „Feature“.

Der Branch enthält bis zu einer MOOSE-first-Neuplanung **keine freigegebene
Produktionsarchitektur** für mehrere gleichzeitig oder nachgelagert angeforderte
UAV-ISR-Missionen. Insbesondere darf der A3-12-Ansatz mit lokaler
30-Sekunden-Dispatch-Wiederholung nicht weiter als Lösung getestet oder
übernommen werden.

## Verbindliche Zustandsregel ab diesem Protokoll

| Bereich | Zulässige Verantwortung |
|---|---|
| physische Luftfahrzeuge, verfügbare Luftfahrzeug-/Payload-Ressourcen, Start, Rückkehr, Turnover und Missionswarteschlange | MOOSE AIRWING / SQUADRON / AUFTRAG |
| strategische Kampagnenbuchung, Persistenz, Spielerauftrag und fachliche Ergebnisanzeige | CampaignState und OMW-Adapter |
| Abgleich | MOOSE-Lifecycle als physische Beobachtung; CampaignState gleicht ab und protokolliert Differenzen |
| unzulässig | eigene Ressourcenwarteschlange oder Scheduler-Retry als Ersatz für MOOSE AIRWING-Queue |

CampaignState darf nicht durch eine vorgezogene Reservierung verhindern, dass ein
gültiger AUFTRAG überhaupt in MOOSEs Warteschlange gelangt. Umgekehrt darf eine
strategische Differenz nicht stillschweigend zu einer unkontrollierten physischen
Ausführung führen. Der konkrete öffentliche MOOSE-Lifecycle-Einstieg für diesen
Abgleich ist **noch zu verifizieren**, bevor neuer Laufzeitcode entsteht.

## Fehlerregister

### E-01 – F10-/Marker-Interaktion war nicht vollständig erreichbar

**Fehler:** Das erwartete Untermenü beziehungsweise die Anfrageführung war im
praktischen F10-Ablauf zunächst nicht verfügbar bzw. nicht eindeutig genug.

**Folge:** Der zentrale Acceptance-Einstieg war nicht zuverlässig testbar.

**Korrekturstand:** In späteren Bundles wurde das Menü unter
`F10 -> Command -> ISR Cell` und der exakte Marker `UAV RECON` bereitgestellt.
Das ist nur für den jeweiligen Bundle-Stand beobachtet, nicht als allgemeine
Produktionsabnahme bestätigt.

**Lehre:** Spielerinteraktion, Menüpfad, Marker-Text, Coalition und
Löschen/Ändern des Markers gehören als eigene Acceptance-Fälle vor jeden
Lifecycle-Test.

### E-02 – Falsches On-Station-Flugprofil

**Fehler:** Der erste On-Station-Auftrag verwendete
`AUFTRAG:NewORBIT_RACETRACK`. Für den gewünschten ISR-Overhead über einem
Marker war das fachlich falsch; der sichtbare Kurs wirkte veränderlich.

**Folge:** Der Test stellte nicht den geforderten Kreis-Track dar.

**Korrekturstand:** Umstellung auf `AUFTRAG:NewORBIT_CIRCLE`. Die
Anzeigewerte des MQ-9 (unter anderem IAS/AOA) wurden dabei nicht als eigener
Fehler belegt; aus einem Einzelbild folgt keine belastbare Flugleistungsdiagnose.

**Lehre:** Bei einer fachlich sichtbaren Flugfigur müssen MOOSE-Auftragstyp,
Radius, Höhe, Geschwindigkeit und erwartetes Bild vor dem ersten DCS-Test
dokumentiert sein.

### E-03 – Abbruch war in mehreren Lifecycle-Phasen nicht bedienbar

**Fehler:** Die F10-Abbruchmöglichkeit fehlte zunächst für Queued,
Bodenstart, Transit und On-Station bzw. war nicht konsistent zugänglich.

**Folge:** Aufträge konnten nicht wie gefordert vor und nach dem physischen
Spawn abgebrochen werden.

**Korrekturstand:** Ein Abbruchpfad wurde ergänzt. Seine DCS-Abnahme muss
weiter alle vier Phasen separat nachweisen; ein sichtbares Menü allein belegt
nicht die korrekte MOOSE-/CampaignState-Bereinigung.

**Lehre:** Jede zustandsbehaftete F10-Aktion braucht eine explizite
Zustandsmatrix einschließlich unerlaubter oder bereits abgeschlossener Fälle.

### E-04 – `RETURNING` blieb nach physischem Despawn stehen

**Fehler:** Nach beobachteter MOOSE-Rückkehr/Despawn blieb der OMW-Auftrag im
Status `RETURNING`.

**Folge:** CampaignState und sichtbarer Auftragsstatus liefen der physischen
MOOSE-Welt hinterher; nachfolgende Anfragen konnten falsch blockiert sein.

**Korrekturstand:** Es wurde ein Rückgabe-/Recovery-Callback ergänzt. Dieser
war eine notwendige Reaktion auf die DCS-Beobachtung, aber die zugrunde liegende
Abgleicharchitektur ist wegen E-07/E-08 noch nicht final akzeptiert.

**Lehre:** `Recall`, `Return`, DCS-Despawn und strategische
Ressourcengutschrift sind vier verschiedene Ereignisse. Der Abschluss darf erst
nach nachweisbarer physischer MOOSE-Rückgabe erfolgen.

### E-05 – Nicht gestartete, aber gespawnte UAV erhielten Turnover

**Fehler:** ISR-0003 wurde laut Screenshot gespawnt, vor dem Start abgebrochen
und am Spawnplatz entfernt. MOOSE registrierte bei der Rückgabe dennoch seine
normale Turnover-Grundlage. Das widersprach der geforderten sofortigen
Wiederverfügbarkeit eines nicht geflogenen Assets.

**Beleg:** DCS-Screenshots zeigen den gestartet wirkenden MQ-9 auf dem
Parkplatz, die Recall-Meldung und anschließend den leeren Platz. Die Logfolge
der damaligen Testreihe enthält keinen zuordenbaren Takeoff/Landing-Nachweis
für ISR-0003. Der genaue Übergang in MOOSE ist damit nicht vollständig
nachgewiesen, der beobachtete Bodenabbruch aber dokumentiert.

**Fehler in der Korrektur:** Der Adapter griff auf
`Asset.Treturned` zu und entfernte dieses interne MOOSE-Feld nach der
Rückgabe. Das ist keine öffentliche Einzelasset-API und wurde zunächst
eingeführt, bevor die verpflichtende vollständige Recherche dokumentiert war.

**Heutiger Nachweis:** Die lokale `Moose.lua` mit SHA-256
`e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915`,
offizielle MOOSE-Quellen, Online-Dokumentation und offizielle Beispielmissionen
wurden nachträglich geprüft. Es existieren öffentliche
Cohort-Methoden `SetTurnoverTime`, `GetRepairTime` und `IsRepaired`,
aber keine öffentliche per-Asset-Methode zum Entfernen/Überschreiben von
`Treturned`. Das Feld wird im LEGION-Rückgabepfad intern gesetzt.

**Status:** Der Zugriff bleibt ausschließlich eine eng begrenzte
Acceptance-Ausnahme, nicht validierte Produktionspolitik. Er braucht vor einer
Weiterverwendung die in der MOOSE-first-Richtlinie verlangte Lückenakte,
ausdrückliche Projektinhaberfreigabe und einen reproduzierbaren DCS-Test.

### E-06 – CampaignState und MOOSE wurden als parallele Disposition benutzt

**Fehler:** Der Dispatcher reservierte zuerst strategisch in CampaignState.
Nur bei Erfolg wurde `AIRWING:AddMission(mission)` aufgerufen.

**Folge:** Wenn CampaignState `RESOURCE_UNAVAILABLE` meldete, wurde der
AUFTRAG nie an MOOSE übergeben. MOOSE konnte daher weder seine
AIRWING-Missionswarteschlange noch seine Ressourcen-/Turnoverlogik anwenden.

**Beleg:** Im A3-11-Log:
```text
16:09:51 ISR-0007 SUBMIT_ACCEPTED
16:09:51 DISPATCH_DEFERRED reason=NO_AVAILABLE_ISR_ASSET
16:15:57 / 16:16:05 vorherige MQ-9 physisch recovered
danach kein MISSION_STARTED/Retry für ISR-0007
```

**Lehre:** „CampaignState strategisch, MOOSE physisch“ bedeutet nicht zwei
unabhängige Admission-Controller. Die physische MOOSE-Queue muss für eine
physische Mission tatsächlich verwendet werden; CampaignState darf nur an einem
dokumentierten Lifecycle-Punkt spiegeln und Differenzen behandeln.

### E-07 – Eine lokale Wiederholungsqueue wurde fälschlich als Korrektur eingeführt

**Fehler:** Nach E-06 wurde im A3-12-Pfad ein lokaler Pending-Request-Speicher
plus MOOSE-`SCHEDULER` im 30-Sekunden-Intervall ergänzt. Der Scheduler
versuchte wiederholt, erst CampaignState zu reservieren und danach erst den
AUFTRAG an MOOSE zu geben.

**Warum dies gegen MOOSE-first verstößt:** MOOSE bietet mit
`AIRWING:AddMission` eine eigene Missionswarteschlange. Der lokale Scheduler
bildet die fehlende Admission-Queue parallel nach, anstatt sie zu verwenden.
Er löst die Ursache aus E-06 nicht.

**Betroffene Commits:**

- `7a40ea8fca25669fc8c5af0eef3d35e8dd462b93` – lokaler Dispatch-Retry;
- `80f32f1ff6e569b23888c460f2b9ec4ae94e1f87` – Test für diesen falschen Pfad;
- `7e157f5141176bcfa39f279cdfa400646787fba1` – Akzeptanztext dazu;
- `1e6148f5c15531e43f01b6d7b0d57e3774e6d9fa` – Übergabe dazu;
- `99d6d52c5be7be9e41080d67dcbb35c57011031a` – Build-Bump A3-12.

**Status:** Verworfen. A3-12 darf nicht als Zielarchitektur oder
„Problemlösung“ getestet werden.

### E-08 – MOOSE-first-Recherche und Ausnahmedokumentation kamen zu spät

**Fehler:** Vor Eigenlogik für Ressourcenannahme, Wiederholung und
Einzelasset-Turnover wurden nicht in der geforderten Reihenfolge passende
MOOSE-Dokumentation, die tatsächlich geladene Quelle und offizielle
Beispielmissionen ausgewertet und mit Version/Hash festgehalten.

**Folge:** Es entstanden zuerst eigene Logik und anschließend reaktive
Patches. Die Behauptung, es gebe keine öffentliche Einzelasset-Option, war
zunächst nicht umfassend belegt.

**Korrekturstand:** Die Recherche für die Einzelasset-Turnover-Frage wurde
nachgeholt. Sie bestätigt die Einschränkung, legitimiert aber nicht rückwirkend
den direkten internen Feldzugriff oder die lokale Dispatch-Queue.

**Lehre:** Die Schritte aus `docs/26-moose-first-development-policy.md`
sind ein Gate vor Code, nicht nach einem fehlgeschlagenen DCS-Test.

### E-09 – Laufende Dokumentation war widersprüchlich

**Fehler:** Acceptance- und Übergabedokumentation beschrieben A3-12 als
Korrektur, obwohl die Architektur gegen die verbindliche MOOSE-first-Regel
verstößt. Zugleich fehlte ein vollständiger Fehlerverlauf mit Belegen,
Unsicherheiten und klaren Verwerfungsentscheidungen.

**Folge:** Ein Nutzer konnte ein Bundle bauen und irrtümlich annehmen, es
behebe die zuvor beobachteten Probleme vollständig.

**Korrekturstand:** Dieses Register sowie die aktualisierten Acceptance- und
Übergabedokumente kennzeichnen den Zustand ausdrücklich als nicht
produktionsfähig und A3-12 als verworfen.

**Lehre:** Eine laufende Dokumentation muss auch negative Ergebnisse,
zurückgenommene Annahmen und nicht testbare Behauptungen fortschreiben.

## Fehler, die nicht als gelöst gelten

| Thema | Status | Erforderlicher Nachweis |
|---|---|---|
| vollständiger MOOSE-first-Queue-Pfad | offen | öffentliche AIRWING/AUFTRAG-Lifecycle-Recherche, Source/Beispiele, Designentscheidung, DCS-Test |
| CampaignState-Reservierungszeitpunkt | offen | dokumentierter MOOSE-Callback und Differenzbehandlung vor physischem Spawn |
| Ground-recall-Turnover | acceptance-only Ausnahme | Genehmigungsakte und erneuter DCS-Nachweis mit korreliertem Takeoff-Signal |
| Menü/Abbruch in allen Phasen | teilgetestet | vier reproduzierbare DCS-Fälle mit gleicher Request-ID |
| Recovery und Folgemission | offen | physische Rückkehr, strategische Gutschrift, nachfolgende durch MOOSE gestartete Warteschlangenmission |

## Pflicht für die nächste Implementierung

1. **Kein weiterer Code** für Queue, Retry oder Reservierungsreihenfolge ohne
   abgeschlossene MOOSE-first-Lückenakte.
2. AIRWING-Queue, AUFTRAG-FSM und relevante öffentliche Callbacks passend zur
   tatsächlich geladenen MOOSE-Version vollständig untersuchen.
3. Nachweisen, an welchem öffentlichen MOOSE-Ereignis CampaignState
   beobachtet/abgeglichen wird und wie eine Differenz ohne parallele Queue
   behandelt wird.
4. Den A3-12-Scheduler und seine begleitende Dokumentation in einem
   nachvollziehbaren Korrekturcommit entfernen oder ersetzen; keine
   Geschichtsumschreibung.
5. Vor erneutem Spieler-Test eine Testmatrix veröffentlichen: mehrere
   Requests, MOOSE-Queue, Abbruch vor Start, Abbruch nach Start, echter
   Return/Turnover, Differenzfall CampaignState/MOOSE.

## Abgrenzung

Dieses Register behauptet nicht, jede denkbare Fehlerursache des gesamten
Projekts zu kennen. Es erfasst die in dieser ISR-Request-Arbeit bis
2026-08-28 konkret beobachteten und/oder durch die implementierte Architektur
verursachten Fehler. Unklare Punkte sind ausdrücklich als offen markiert.
