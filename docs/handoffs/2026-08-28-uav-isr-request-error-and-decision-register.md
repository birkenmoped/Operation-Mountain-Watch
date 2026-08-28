---
document_id: OMW-UAV-ISR-REQUEST-ERROR-REGISTER-2026-08-28
status: ACTIVE_REMEDIATION_RECORD
document_class: ERROR_AND_DECISION_RECORD
owning_policy: OMW-GOV-001
source_branch: agent/uav-isr-request-orchestration
validated_in_dcs: false
---

# UAV-ISR-Request – Fehler-, Irrtums- und Entscheidungsprotokoll

## Aktueller Stand

A3-12 ist verworfen. A3-13 ersetzt die lokale OMW-Dispatch-Wiederholung durch
MOOSEs eigene AIRWING-Missionswarteschlange. Das ist implementiert und
quell-/unit-testseitig abgedeckt, aber **noch nicht in DCS validiert**.

| Bereich | Autorität in A3-13 |
|---|---|
| physische Mission, Assetwahl, Queue, Start, Rückkehr, Turnover | MOOSE AIRWING / SQUADRON / AUFTRAG |
| strategischer Bestand und Persistenz | CampaignState |
| Abgleich | MOOSE-`Started` und bestätigte physische Rückkehr |
| unzulässig | lokale Ressourcenqueue oder Scheduler-Retry vor `AIRWING:AddMission` |

## Festgestellte Fehler und Korrektur

| ID | Fehler | Folge | Korrektur/Status |
|---|---|---|---|
| E-01 | F10-/Marker-Ablauf nicht vollständig erreichbar | Acceptance nicht zuverlässig auslösbar | Menü und exakter Marker `UAV RECON` ergänzt; erneut in DCS prüfen |
| E-02 | `NewORBIT_RACETRACK` statt Kreis | falsche sichtbare Flugfigur | `AUFTRAG:NewORBIT_CIRCLE`; DCS-Nachweis offen |
| E-03 | Abbruch nicht in allen Phasen | Aufträge konnten festhängen | Queue-, Boden-, Transit- und On-Station-Pfade implementiert; Matrix noch offen |
| E-04 | `RETURNING` blieb nach Despawn | sichtbarer und strategischer Zustand liefen nach | Abschluss erst nach physischer MOOSE-Rückkehr; DCS-Nachweis offen |
| E-05 | Bodenabbruch erhielt Turnover | nicht geflogenes Asset war blockiert | eng begrenzte Acceptance-Ausnahme über internes `Asset.Treturned`; keine Produktionsfreigabe |
| E-06 | CampaignState entschied vor `AIRWING:AddMission` | ISR-0007 gelangte nie in MOOSEs Queue | A3-13: sofortiges `AddMission`; CampaignState erst beim MOOSE-Start |
| E-07 | lokaler 30-Sekunden-Scheduler als Retry-Queue | parallele Disposition, MOOSE-first-Verstoß | A3-12 verworfen und aus aktivem Laufzeitpfad entfernt |
| E-08 | MOOSE-Recherche erst nach Eigenlogik | unbelegte Behauptungen und reaktive Patches | Quellen, Online-Doku und Beispiele nachgeprüft; Recherche-Gate künftig vor Code |
| E-09 | Dokumentation widersprüchlich | A3-12 konnte fälschlich als Lösung erscheinen | Acceptance und Übergabe auf A3-13 / nicht DCS-validiert korrigiert |

## Nachweis für E-06

Im A3-11-Log wurde ISR-0007 um 16:09:51 angenommen, aber mit
`DISPATCH_DEFERRED reason=NO_AVAILABLE_ISR_ASSET` lokal abgewiesen. Nach den
physischen Rückkehrereignissen um 16:15:57 und 16:16:05 folgte kein
`MISSION_STARTED` für ISR-0007. Ursache war der vorgezogene
CampaignState-Reserve-Gate vor `AIRWING:AddMission`.

Die MOOSE-Quelle bestätigt: `AIRWING:AddMission(mission)` führt den Auftrag
in die Missionswarteschlange; die AIRWING rekrutiert verfügbare Assets und
startet ihn erst dann. Deshalb muss dieser Aufruf der Admission-Punkt sein.

## A3-13-Entscheidung

- Jeder gültige Auftrag wird genau einmal über `AIRWING:AddMission` in MOOSE
  eingereiht.
- Es gibt keinen lokalen Pending-Request-Speicher und keinen Retry-Scheduler.
- `Started` ist kein Vorab-Gate: Es ist die erste bestätigte physische
  Startbeobachtung. Dort wird CampaignState reserviert und konsumiert.
- Schlägt dies fehl, wird der bereits physische MOOSE-Auftrag via MOOSE
  zurückgerufen; der Request endet sichtbar als `RECONCILIATION_REQUIRED`.
  Weitere ISR-Dispatches werden gesperrt. Es gibt keine strategische
  Rückgabegutschrift für diesen unvereinbarten Flug.
- Die konkrete physische Asset-ID bleibt in dieser Acceptance noch nicht als
  stabile CampaignState-Entität abgebildet; A3-13 gleicht den profilbasierten
  strategischen Bestand gegen die MOOSE-physische Ausführung ab. Das ist vor
  Produktionsnutzung zu erweitern.

## Offene DCS-Pflichtmatrix

1. Drei Requests nacheinander einreichen, davon mindestens einer ohne freies
   Asset; prüfen, dass er als MOOSE-queued angezeigt wird und später startet.
2. Bodenabbruch vor Takeoff, inklusive leerem Parkplatz, fehlendem
   Takeoff-Nachweis und ausgewiesenem Turnover-Ergebnis.
3. Echter Start, Orbit, Recall oder Ablauf, Rückkehr und MOOSE-Turnover-Hinweis.
4. Nach Rückkehr/Turnover muss der nächste bereits in MOOSE wartende Auftrag
   ohne F10-Neueinreichung starten.
5. Erzwungene CampaignState-Differenz: sichtbarer Reconciliation-Status,
   MOOSE-Rückkehr, Sperre weiterer Starts.

## MOOSE-First-Lehre

Die MOOSE-first-Schritte aus
`docs/26-moose-first-development-policy.md` sind vor jeder projektspezifischen
Laufzeitlogik einzuhalten: Projektvertrag, öffentliche Doku, passende
Source-Version und offizielle Beispiele prüfen; erst danach eine eng begrenzte
OMW-Ergänzung mit dokumentierter Ausnahmefreigabe. Die A3-12-Abweichung war ein
Verstoß gegen diese Reihenfolge und ist nicht wiederzuverwenden.
