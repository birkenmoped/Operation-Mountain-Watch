# Gate 5 Acceptance 1 – reale DCS-Laufzeiterkenntnisse

Status: DCS_EVIDENCE / ACCEPTANCE_1_FAILED / ACCEPTANCE_2_REQUIRED

## Evidenzbasis

Vom Projektinhaber bereitgestellter DCS-Lauf am 12.09.2026 mit `OMW_Template_v24_GroundWorks_base.miz` und Gate-5 Six-Site Guard Runtime Acceptance 1.

Die Logs bestaetigen, dass alle sechs Guards materialisiert und ihren bereits vorhandenen Guard-PATHLINEs zugeordnet wurden. Damit sind Six-Site-Registry, Guard-Template, ACCESS-Aufloesung und PATHLINE-Aufloesung fuer diesen Lauf grundsaetzlich funktionsfaehig.

## Reproduzierbare Problemklasse

Die Bewegung einzelner Guards war jedoch nicht deterministisch robust. Beispiele aus der realen Telemetrie:

```text
Lauf A:
JALALABAD_FENTY routeStarted=true alive=true movementM=0.0
COP_FORTRESS     routeStarted=true alive=true movementM=177.3
FOB_JOYCE        routeStarted=true alive=true movementM=85.3
FOB_WRIGHT       routeStarted=true alive=true movementM=181.1
COP_HONAKER      routeStarted=true alive=true movementM=160.8
FOB_BOSTICK      routeStarted=true alive=true movementM=138.0

Acceptance result:
FAIL JALALABAD_FENTY:MOVEMENT_0.0_LT_25
```

Ein weiterer Lauf zeigte die umgekehrte standortbezogene Erscheinung:

```text
JALALABAD_FENTY routeStarted=true alive=true movementM=90.0
COP_FORTRESS     routeStarted=true alive=true movementM=0.3
FOB_JOYCE        routeStarted=true alive=true movementM=132.7
FOB_WRIGHT       routeStarted=true alive=true movementM=110.8
COP_HONAKER      routeStarted=true alive=true movementM=48.3
FOB_BOSTICK      routeStarted=true alive=true movementM=105.1
```

Damit ist die Fehlerklasse nicht auf eine fehlende PATHLINE oder eine generell defekte Six-Site-Orchestrierung zu reduzieren. Sie ist mit der zufaelligen WAREHOUSE-Materialisierung und DCS-Ground-AI innerhalb dichter FOB/COP-Static-Geometrie vereinbar und muss mit einem kontrollierten Spawn-Test isoliert werden.

## Owner-Korrektur / neue Vorgabe

Der Projektinhaber legte fest, dass Guard-Gruppen in enger Formation und auf der Route ausgerichtet materialisiert werden sollen, analog zum bereits erprobten Strassenkonvoi-Prinzip. Ziel ist, dass Infanteristen nicht bereits beim Materialisieren in Gebaeuden, HESCOs oder anderen Statics festhaengen.

Diese Vorgabe wird in Gate 5 Acceptance 2 umgesetzt als:

```text
- Materialisierung entlang des ersten Segments der bestehenden Guard-PATHLINE;
- kompakter Abstand, Ziel 2 m;
- gemeinsame Ausrichtung Punkt 1 -> Punkt 2;
- MOOSE Off Road Route;
- MOOSE OptionFormationInterval(2);
- kein neues Mission-Editor-Objekt;
- keine MIZ-Mutation.
```

## MOOSE-first / vorhandene Evidenz

Der gepinnte MOOSE-Source zeigt, dass `WAREHOUSE:_SpawnAssetGroundNaval(...)` Ground-Assets standardmaessig auf einen Zufallspunkt der Spawn-Zone verschiebt und dabei die relative Template-Geometrie beibehaelt. Eine oeffentliche Option zur exakten PATHLINE-ausgerichteten Unit-Geometrie ist in diesem Materialisierungspfad nicht vorhanden.

Die bereits owner-genehmigte ARMY Ground Acceptance 3-2 hat fuer den dokumentierten Scope einen Adapter um genau diesen MOOSE-Warehouse-Spawn-Schritt verwendet und absolute Positionen/Headings vor `_DATABASE:Spawn(...)` gesetzt, ohne BRIGADE/WAREHOUSE-Lifecycle oder Assetreservation zu ersetzen. Gate 5 Acceptance 2 verwendet dieses bereits genehmigte Adaptermuster nur fuer seinen eigenen Test-Scope erneut.

## Acceptance-Grenze

Acceptance 1 ist fuer den Six-Site-Movement-Nachweis **FAILED**, liefert aber positive Teil-Evidenz fuer Materialisierung und PATHLINE-Aufloesung. Keine generische Guard-Produktion ist damit validiert.

Naechster funktionaler Schritt: Gate 5 Acceptance 2 – compact/aligned Guard materialization.
