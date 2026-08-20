---
document_id: OMW-PLAN-ARMY-GROUND-RETURN-SETTLEMENT
status: PLANNED
document_class: DECISION_PREPARATION
owning_policy: OMW-GOV-001
authoritative_for:
  - recorded owner decisions and mandatory gates for a future ARMY Ground CampaignState settlement adapter
not_authoritative_for:
  - production resource identifiers, quantities, or source-node mappings
  - a runtime implementation or DCS acceptance result
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: OWNER_DECISIONS_2026-08-20
validated_in_dcs: false
supersedes:
superseded_by:
---

# ARMY Ground – CampaignState-Settlement: festgelegte Regeln und Produktionsgate

## 1. Geltungsbereich

Acceptance 4-2 und Acceptance 6 haben den operativen MOOSE-Lifecycle bestätigt:

~~~text
materialize from WAREHOUSE
-> mission / mobile return through the existing ACCESS marker
-> Returned
-> LEGION/Warehouse AddAsset
-> controlled removal of the temporary physical DCS group
~~~

Der MOOSE-Handoff ist noch keine strategische Buchung. Diese Vorbereitung legt deshalb nur fest, wie ein künftiger Ground-CampaignState-Adapter den bereits bestätigten operativen Lifecycle strategisch abrechnet.

## 2. Festgelegte Eigentümerentscheidungen

| Thema | Festgelegte Regel |
|---|---|
| Strategische Einheit | Jede physische Unit zählt einzeln. Vier Fahrzeuge verbrauchen vier Fahrzeugressourcen; eine achtköpfige Infanteriegruppe verbraucht acht Personalressourcen. Eine DCS-Gruppe ist keine strategische Einheit. |
| Materialisierung | Vor der MOOSE-Materialisierung reserviert und konsumiert der Adapter exakt die Anzahl der Units der tatsächlich materialisierten Gruppe. |
| Bestätigte Rückkehr | Nur der bestätigte MOOSE-Handoff `Returned -> Warehouse AddAsset` darf die tatsächlich zurückgekehrten, noch lebenden Units genau einmal strategisch gutschreiben. |
| Teilverlust | Nicht zurückgekehrte Units bleiben permanente Verluste. Ein Rückkehrer mit Schaden wird wie jeder andere Rückkehrer sofort wieder verfügbar. |
| Wartung | Kein Maintenance-Mode, keine Reparaturwartezeit, keine Schadens- oder Werkstattbuchhaltung. |
| Genau-einmal | Rückgabe, Verlustaudit und Restart-Reconciliation müssen pro Runtime-Commitment idempotent sein. Wiederholte Callbacks dürfen keinen zweiten Credit erzeugen. |
| Kontrolliertes Missionsende | Bereits bestätigte Rückgaben und Verluste behalten ihren terminalen Zustand. Nichtterminale Commitments fallen unter die Restart-Regel. |
| Servercrash / erzwungener Stopp | Jeder konsumierte, aber weder als Rückkehr noch als Verlust terminal bestätigte Commitment wird beim nächsten Start strategisch genau einmal zurückgebucht. Die physische DCS-/MOOSE-Gruppe wird nicht fortgesetzt oder nachgespawnt. |

Die letzte Regel übernimmt bewusst das bereits für AAR dokumentierte Muster aus
`docs/04-campaign-state.md`: Es ist eine strategische Reconciliation, keine Behauptung, der DCS-Laufzustand könne rekonstruiert werden.

## 3. Verbindliche Zustandswirkung

~~~text
confirmed return     -> returned unit count credited once
confirmed loss       -> no availability credit
damaged return       -> returned unit count credited once; immediately available
active at interruption
                     -> recredit the consumed unit count once at next startup
physical DCS group   -> never resumed or respawned by this rule
~~~

Damit werden weder bestätigte Verluste künstlich wiederhergestellt noch intakte Einheiten nach einem Serverabbruch dauerhaft blockiert. Die offene Einsatzgruppe verschwindet mit dem DCS-Lauf; nur ihre strategische Buchung wird bereinigt.

## 4. MOOSE-First-Abgrenzung

MOOSE bleibt verantwortlich für Materialisierung, AUFTRAG-/ARMYGROUP-Lifecycle, Routing, `Returned` und Warehouse-Handoff.

CampaignState bleibt allein verantwortlich für strategische Verfügbarkeit, Commitments und deren einmalige Abrechnung. Die notwendige Korrelation zwischen MOOSE-Runtime und CampaignState ist daher ein kleiner projektspezifischer Adapter und keine zweite Warehouse- oder DCS-Bestandsführung. Vor der Umsetzung ist die MOOSE-Lücke gemäß `OMW-GOV-MOOSE-FIRST` erneut am gepinnten Stand zu dokumentieren.

## 5. Noch offene Produktionsdaten – einziges Umsetzungsgate

Vor einem Produktionsadapter müssen ausschließlich die bereits baselinierten Ground-Bestände in konkrete CampaignState-Ressourcen und Source Nodes überführt werden:

~~~text
resource type / stable resource ID
source node / strategic parent
approved initial quantity
operational MOOSE warehouse host
~~~

Dabei gilt weiterhin:

~~~text
strategic parent / resource obligation != physical dispatch origin
MOOSE Warehouse AddAsset != CampaignState credit without adapter settlement
~~~

Es werden keine neuen Mengen erfunden. Für Standorte, deren Bestandsgrundlage bereits festgelegt ist, wird diese Grundlage verwendet; bei noch ungeklärter Zuordnung bleibt die Produktionsmaterialisierung gesperrt.

## 6. Nächster technische Schritt: ein gebündelter Produktions-Acceptance-Lauf

Sobald die Zuordnung aus Abschnitt 5 vorliegt, umfasst **ein** Acceptance-Bundle mindestens:

~~~text
1. normaler Vier-Unit-Return:        4 consume -> 4 returned credit
2. Teilverlust:                      4 consume -> 3 returned credit -> 1 permanent loss
3. beschädigter Rückkehrer:          4 consume -> 3 returned credit, davon 1 damaged
4. Restart-Reconciliation:           consumed active commitment -> startup recredit once
5. Idempotenz:                       duplicate return/restart callback -> no second credit
~~~

Der Lauf darf isolierte Test-Stores verwenden und ändert keine `.miz`. Erst nach erfolgreicher technischer Abnahme werden konkrete Produktionsressourcen und -adapter eingeführt.

## 7. Ausgeschlossen

~~~text
DCS group continuation across a restart
automatic group respawn at former map position
maintenance timers or workshop queues
parallel strategic inventories in DCS or MOOSE WAREHOUSE
ATO / Ground-order structure and cross-domain persistence architecture
~~~
