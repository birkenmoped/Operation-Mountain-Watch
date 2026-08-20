---
document_id: OMW-PLAN-ARMY-GROUND-RETURN-SETTLEMENT
status: PLANNED
document_class: DECISION_PREPARATION
owning_policy: OMW-GOV-001
authoritative_for:
  - recorded owner decisions and mandatory gates for the ARMY Ground CampaignState settlement adapter
not_authoritative_for:
  - production resource identifiers, quantities, or source-node mappings beyond the cited baselines
  - production activation or runtime acceptance outside cited result documents
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

Acceptance 7 hat anschließend den kleinen Ground-CampaignState-Settlement-Adapter gegen diesen bereits bestätigten operativen Lifecycle technisch und visuell validiert. Die strategische Buchung bleibt dabei strikt von der MOOSE-/DCS-Lifecycle-Führung getrennt.

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

CampaignState bleibt allein verantwortlich für strategische Verfügbarkeit, Commitments und deren einmalige Abrechnung. Die notwendige Korrelation zwischen MOOSE-Runtime und CampaignState ist daher ein kleiner projektspezifischer Adapter und keine zweite Warehouse- oder DCS-Bestandsführung.

Acceptance 7 hat diese Grenze für den gepinnten MOOSE-Stand bestätigt. Der Ground-Settlement-Adapter selbst enthält keine DCS- oder MOOSE-Aufrufe; die bereits genehmigte road-aligned Warehouse-Materialisierungs-Ausnahme aus Acceptance 3-2 blieb unverändert.

## 5. Bereits vorhandene Produktionsbaseline und Unit-zu-Ressourcen-Korrelation

Die Ground-Quantities, Root Nodes und stabilen Resource IDs sind bereits im Branch festgelegt:

~~~text
GROUND_NODE_JALALABAD / Fenty: PERSONNEL 480, VEHICLE 48
GROUND_NODE_JOYCE:             PERSONNEL 180, VEHICLE 20
GROUND_NODE_WRIGHT:            PERSONNEL 120, VEHICLE 22
GROUND_NODE_BOSTICK:           PERSONNEL 220, VEHICLE 26
Resource ID: GROUND:<groundNodeId>:<resourceClass>
~~~

Fortress besitzt keinen eigenen strategischen Root-Pool. Honaker-Miracle bindet seinen lokalen Personnel-Vertrag aus Joyce. Das sind keine fehlenden Bestandsdaten.

Die Unit-zu-Ressourcen-Korrelation für den getesteten motorisierten Verband ist festgelegt und durch Acceptance 7 bestätigt:

~~~text
1 physical M-ATV = 1 VEHICLE + 3 PERSONNEL
4 M-ATV          = 4 VEHICLE + 12 PERSONNEL
~~~

Diese Zuordnung wird explizit über den Adaptervertrag geführt und nicht aus einem bloßen DCS-Gruppenzähler geraten.

Unverändert gilt:

~~~text
strategic parent / resource obligation != physical dispatch origin
MOOSE Warehouse AddAsset != CampaignState credit without adapter settlement
~~~

## 6. Acceptance 7 – Produktionsnahes Settlement-Gate abgeschlossen

Der gebündelte Acceptance-7-Lauf prüfte:

~~~text
1. normaler Vier-Unit-Return:        exact consumed units -> exact returned credit
2. Teilverlust:                      exact survivor credit -> confirmed units remain loss
3. beschädigter Rückkehrer:          same immediate credit as an undamaged survivor
4. Restart-Reconciliation:           consumed active commitment -> startup recredit once
5. Idempotenz:                       duplicate return/restart callback -> no second credit
~~~

Validierter Stand:

~~~text
Source commit: e049e34fe8e6de878fd390486888f3912bb179d8
Bundle SHA-256: b591ccd746896c90064fa93d9b3d42626384f55e605efc748bf304ffccb86ec7
MIZ: OMW_Template_v14_ground_test.miz
MIZ SHA-256: 88184ec180837044ff4dcef7cca264fe7ee5fcf5d55a8af19b11125c41eab94d
DCS: 2.9.28.26385 MT
Result: PASS / owner visual acceptance
~~~

Vollständige Evidenz:

- [`2026-08-20-acceptance-7-runtime.md`](../../mission/tests/army-ground-foundation/results/2026-08-20-acceptance-7-runtime.md)

Damit ist das technische Settlement-Gate geschlossen.

## 7. Nächster technischer Schritt

Als nächstes darf die Produktionsintegration des bereits getesteten Adapters gegen den autoritativen CampaignState-Initialbestand vorbereitet werden.

Dabei unverändert:

~~~text
CampaignState = einzige strategische Ressourcenautorität
MOOSE = operativer Ground-Lifecycle
GroundCampaignStateAdapter = kleine Korrelation/Settlement-Brücke
keine parallele Ressourcenhoheit im MOOSE Warehouse
keine physische Restart-Fortsetzung oder Respawns
~~~

Die Produktionsintegration muss die bereits baselierten Resource IDs und Source Nodes verwenden und darf keine neuen Mengen für Fortress oder Honaker erfinden.

## 8. Ausgeschlossen

~~~text
DCS group continuation across a restart
automatic group respawn at former map position
maintenance timers or workshop queues
parallel strategic inventories in DCS or MOOSE WAREHOUSE
ATO / Ground-order structure and cross-domain persistence architecture
~~~
