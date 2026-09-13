---
document_id: OMW-ISR-BASE-SOURCE-RESOURCE-QUEUE-CONTRACT
status: DRAFT
document_class: TECHNICAL_ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - none until owner approval and main integration
not_authoritative_for:
  - production ISR dispatch
  - CampaignState resource booking
  - F10 menu behavior
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/isr-base-main-reconciliation
source_commit: PENDING_COMMIT
base_branch: main
base_commit: 980340c9225a81921aed8995aa8f50cad7d1c215
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
---

# ISR-Reconciliation – Source-, Ressourcen- und MOOSE-Queue-Vertrag

## 1. Ziel und Abgrenzung

Dieser Entwurf baut ISR neu von aktuellem `main` auf. Der historische Branch
`agent/uav-isr-request-orchestration` ist keine Quellbasis: Er ist zeitlich und
architektonisch überholt und enthält nicht zulässige parallele Dispatch-/Bestandslogik.

Zielbild:

```text
Anforderer (später Spieler-F10, JTAC/AFAC oder Installation)
-> fachlicher ISR-Bedarf
-> FireSupStratResupply_Base / MissionDemand
-> MOOSE COMMANDER oder AIRWING/LEGION Queue
-> MOOSE selektiert, materialisiert und führt aus
-> bestätigtes MOOSE-Lifecycle-Ereignis
-> idempotente CampaignState-Übernahme
```

`OMW_ISR_Base.lua` wird dabei **kein** zweiter Dispatcher und keine
spielerexklusive Basis. Er ist der schmale ISR-Fachadapter: validiert ISR-spezifische
Parameter, erzeugt einen fachlichen Bedarf und verarbeitet bestätigte Lifecycle-Ereignisse.
Die generische Support-Queue bleibt MOOSE; der generische Support-Kern bleibt
`OMW_FireSupStratResupply_Base.lua`, sobald dessen offene Production-Base-Acceptance
abgeschlossen und der Stand nach `main` integriert ist.

Nicht Teil dieses Schritts:

- bodengebundene JTAC-Materialisierung;
- AFAC-/Laser- oder Waffenlogik;
- F10-Menü, Marker-Auswertung oder Spieler-Ownership;
- eigene Retry-Schleife, Kandidatenliste oder Asset-Reservation;
- Zugriff auf MOOSE-Interna wie `squadron.assets` oder `asset.Treturned`;
- produktiver DCS-Dispatch vor der definierten Acceptance.

## 2. Verbindlicher Source-/Ressourcenvertrag

Eine ISR-Anforderung muss diese stabilen Identitäten führen:

| Feld | Besitzer | Zweck |
|---|---|---|
| `supportRequestId` | OMW | idempotente fachliche Anforderung |
| `originId` | CampaignState | strategische Herkunft, z. B. Kandahar oder später Bagram |
| `resourceId` | CampaignState | strategische Identität des tatsächlich gebundenen Assets |
| `mooseMissionId` | MOOSE/Adapter | Zuordnung zum AUFTRAG bzw. MOOSE-Auftrag |
| `settlementId` | OMW | einmalige Übernahme eines bestätigten Ereignisses |

Regeln:

1. CampaignState führt strategische Identität, Verfügbarkeit, Schaden, Verlust und
   Rückkehrzustand; MOOSE führt Auswahl, Queue und physischen Lifecycle.
2. OMW wählt weder einzelne DCS-Gruppen noch MOOSE-Assets vor.
3. Der Herkunftskontext ist fachlich bindend. Ein Auftrag wird an den passenden
   MOOSE-AIRWING beziehungsweise dessen zulässige SQUADRONs gebunden; ein
   ungebundener gemeinsamer Pool mehrerer strategischer Herkünfte ist unzulässig.
4. Eine Buchung von `available` nach `reserved` erfolgt nicht allein wegen einer
   F10-Auswahl oder einer UI-Bestätigung. Sie folgt dem dokumentierten, bestätigten
   MOOSE-Bindungsereignis.
5. `Cancel()`, `Done`, Rückkehrbefehl oder Despawn sind keine Rückkehrbuchung.
   Erst ein passendes bestätigtes MOOSE-Rückkehr- oder Verlustereignis darf
   CampaignState idempotent fortschreiben.
6. Abweichungen zwischen strategischem Zustand und MOOSE-Lifecycle sperren das
   betroffene `resourceId` für neue Dispositionen und erzeugen Diagnose; sie werden
   nicht durch stilles Hoch-/Herunterzählen bereinigt.

Damit konkretisiert dieser Entwurf die projektweite Regel aus
`OMW-GOV-001 §5.1`, ohne eine zweite Bestandswahrheit zu schaffen.

## 3. Verbindlicher MOOSE-Queue-Vertrag

Die operative Queue ist MOOSE. ISR benötigt keinen OMW-Retry-Dispatcher.

| Situation | Zulässiger Pfad | Verboten |
|---|---|---|
| Asset aktuell gebunden, später verfügbar | Auftrag einmal an MOOSE übergeben; MOOSE wartet/rekrutiert | OMW pollt oder sendet erneut |
| ISR-Bedarf endet vor Zuweisung | `AUFTRAG:Cancel()` über Lifecycle-Adapter | private Queue-Manipulation |
| ISR-Bedarf läuft ab | fachliche Gültigkeit + nativer Cancel-Pfad | eigene Timeout-/Retry-Queue |
| Auftrag läuft | MOOSE führt Auftrag/Rückkehr aus | OMW wechselt Asset oder Zielgruppe |
| bestätigte Rückkehr/Verlust | idempotente CampaignState-Übernahme | Freigabe bei UI-Aktion/Despawn-Vermutung |

Die geprüfte MOOSE-Queue-Regel ist verbindlich:

- direkter `LEGION:AddMission(...)`-, `AIRWING:AddMission(...)`- oder
  `BRIGADE:AddMission(...)`-Pfad: MOOSE-Queue mit `AUFTRAG:SetTime(...)` und
  nativen Conditions;
- `COMMANDER`-/`CHIEF`-Planungsqueue: fachliches Ende oder Ablauf wird genau
  einmal durch den Lifecycle-Adapter als öffentlicher `AUFTRAG:Cancel()`-Aufruf
  weitergereicht;
- kein Zugriff auf private MOOSE-Queues oder Tabellen.

Die vollständige Source-Prüfung und ihre nachgewiesene Grenze stehen in
[`MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md`](MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md).

## 4. Vorgesehene Modulgrenze

```text
OMW_ISR_Base.lua
  owns: ISR-Profil, Request-Validierung, originId, fachliche Validität,
        Lifecycle-Übersetzung und Diagnose
  does not own: Assetwahl, Queue, Spawn, Rückkehr, Turnover, Bestand, F10 UI

OMW_FireSupStratResupply_Base.lua
  owns: generische Support-Anforderung und deren Bridge zu MOOSE
  does not own: ISR-Taktik oder Spieler-Menü

MOOSE
  owns: Assetrekrutierung, Warteschlange, physische Mission und Recovery-Lifecycle

CampaignState
  owns: persistente strategische Projektion bestätigter Ereignisse
```

Die künftige ISR-Unterstützungsart wird als `ISR_RECON` modelliert. Eine bewaffnete
UAV-, CAS- oder JTAC/FAC-Wirkung ist eine spätere, separat akzeptierte Fähigkeit und
nicht implizit Teil von `ISR_RECON`.

## 5. Standorte und Konfiguration

### Kandahar – erster Vertical Slice

Kandahar wird der erste Konfigurationsstandort, weil `main` bereits eine
Kandahar-AIRWING-/SQUADRON-Foundation enthält. Vor einem Dispatch sind dessen
Objektvertrag, ISR-Payload, strategische `originId` und MOOSE-Bindung in einer
dedizierten Acceptance zu belegen.

### Bagram – spätere Konfiguration, keine Kopie

Bagram erhält keinen kopierten Kandahar-Dispatcher. Es wird eine zweite Konfiguration
gegen die bestehende duale Bagram-AIRWING-Foundation. Bagram wird erst nach dem
Kandahar-Vertical-Slice begonnen und muss eigene Herkunfts-, Parking-, Payload- und
Acceptance-Nachweise führen.

## 6. Neue Acceptance-Reihenfolge

1. **Contract Acceptance:** Quell-/Ressourcenbindung, MOOSE-Queue und keine
   Parallelqueue statisch nachweisen.
2. **Kandahar ISR Acceptance 1:** ein `ISR_RECON`-Bedarf erreicht einmal MOOSE,
   MOOSE übernimmt Auswahl/Queue; kein physischer Runtime-Claim.
3. **Kandahar ISR Acceptance 2:** eine UAV wird physisch gestartet, führt eine reine
   ISR-Mission aus und erreicht den dokumentierten Rückkehr-/Verlustpfad.
4. **Kandahar ISR Acceptance 3:** Wiederverwendbarkeit nach regulärer Rückkehr,
   idempotente CampaignState-Übernahme und absichtlich erzeugte Abweichungsdiagnose.
5. **Bagram ISR Acceptance:** dieselben Verträge mit eigener Konfiguration;
   keine Übernahme von Kandahar-Ergebnissen ohne neuen Nachweis.

Jeder Runtime-Test dokumentiert mindestens Branch, Commit, Builder, Bundle-Hash,
MIZ-Hash, DCS-Version und MOOSE-Artefakt-Hash.

## 7. Offene Voraussetzung

Der Fire-Support-Strategic-Resupply-Production-Base-Branch ist gegenüber aktuellem
`main` noch nicht integriert und seine reale Production-Base-Acceptance 3 ist offen.
Dieser ISR-Entwurf baut daher keine lauffähige Kopie dieses Kerns. Die Implementierung
von `OMW_ISR_Base.lua` beginnt erst nach dem aktuellen Main-Abgleich dieses
Basismoduls und der expliziten Festlegung, ob `ISR_RECON` über MissionDemand oder
direkt über den generischen Supportvertrag eingebracht wird.
