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

## 5. Bereits vorhandene Produktionsbaseline und tatsächliche Restlücke

Die Ground-Quantities, Root Nodes und stabilen Resource IDs sind bereits im Branch festgelegt:

~~~text
GROUND_NODE_JALALABAD / Fenty: PERSONNEL 480, VEHICLE 48
GROUND_NODE_JOYCE:             PERSONNEL 180, VEHICLE 20
GROUND_NODE_WRIGHT:            PERSONNEL 120, VEHICLE 22
GROUND_NODE_BOSTICK:           PERSONNEL 220, VEHICLE 26
Resource ID: GROUND:<groundNodeId>:<resourceClass>
~~~

Fortress besitzt keinen eigenen strategischen Root-Pool. Honaker-Miracle bindet seinen lokalen Personnel-Vertrag aus Joyce. Das sind keine fehlenden Bestandsdaten.

Die verbleibende fachliche Korrelationsregel betrifft ausschließlich gemischte physische Gruppen:

~~~text
MOTORISED PATROL contract = PERSONNEL 12 + VEHICLE 4
DCS M-ATV group           = 4 physical vehicle units
~~~

Für jeden Rückkehrer/Verlust muss der Adapter deshalb wissen, wie viele strategische PERSONNEL-Units neben der jeweiligen physischen Fahrzeug-Unit zu buchen sind. Diese Zuordnung darf nicht aus dem bloßen DCS-Gruppenzähler geraten werden.

Unverändert gilt:

~~~text
strategic parent / resource obligation != physical dispatch origin
MOOSE Warehouse AddAsset != CampaignState credit without adapter settlement
~~~

## 6. Nächster technische Schritt: ein gebündelter Produktions-Acceptance-Lauf

Nach Festlegung der Unit-zu-Ressourcen-Korrelation umfasst **ein** Acceptance-Bundle mindestens:

~~~text
1. normaler Vier-Unit-Return:        exact consumed units -> exact returned credit
2. Teilverlust:                      exact survivor credit -> confirmed units remain loss
3. beschädigter Rückkehrer:          same immediate credit as an undamaged survivor
4. Restart-Reconciliation:           consumed active commitment -> startup recredit once
5. Idempotenz:                       duplicate return/restart callback -> no second credit
~~~

Der Lauf darf isolierte Test-Stores verwenden und ändert keine .miz. Erst nach erfolgreicher technischer Abnahme werden konkrete Produktionsadapter eingeführt.

## 7. Ausgeschlossen

~~~text
DCS group continuation across a restart
automatic group respawn at former map position
maintenance timers or workshop queues
parallel strategic inventories in DCS or MOOSE WAREHOUSE
ATO / Ground-order structure and cross-domain persistence architecture
~~~
