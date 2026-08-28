---
document_id: OMW-GOV-001
status: BINDING_PROJECT_DECISION
authoritative_for:
  - project governance
  - document authority
  - MOOSE-first exceptions
  - branch and acceptance status
  - campaign research period
  - active ORBAT selection model
  - project development phase
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - less restrictive non-MOOSE approval rules
  - automatic interpretation of draft-branch PASS results as repository-wide truth
  - Kandahar 107th EFS active governance baseline
source_branch: agent/reconcile-documentation-authority
validated_in_dcs: false
document_class: PROJECT_GOVERNANCE
owning_policy: OMW-GOV-001
source_commit: GIT_HISTORY
superseded_by:
---

# Operation Mountain Watch – Projekt-Governance

## 1. Geltungsbereich

Dieses Dokument ist die höchste projektinterne Governance-Instanz für **Operation Mountain Watch**. Es gilt für:

- das Hauptprojekt und sämtliche Unterprojekte;
- Dokumentation, Missionseditor-Arbeit, Lua-Entwicklung und Datenaufbereitung;
- Testmissionen, Diagnosezweige, Feature-Branches und gestapelte Pull Requests;
- MOOSE-, DCS-, CampaignState-, Warehouse-, AIRWING-, SQUADRON-, AUFTRAG-, OPSTRANSPORT- und sonstige Projektlogik.

Bei einem Widerspruch zwischen diesem Dokument und einer älteren Projektdatei gilt dieses Dokument, bis eine neuere ausdrückliche Entscheidung des Projektinhabers es ersetzt.

## 2. Quellen- und Entscheidungshierarchie

Bei widersprüchlichen Angaben gilt folgende Reihenfolge:

1. ausdrückliche Entscheidung des Projektinhabers in einem Governance-Dokument oder ADR auf `main`;
2. aktuelles, als `BINDING_PROJECT_DECISION` oder `BINDING` gekennzeichnetes Fach- oder Baseline-Dokument auf `main`;
3. DCS-Acceptance-Bericht für das tatsächlich getestete Laufzeitverhalten des exakt dokumentierten Branches, Commits, Bundles und MOOSE-Stands;
4. Fachmanifest oder Missionseditor-Arbeitsliste, soweit sie nicht ersetzt wurde;
5. Test-README, Übergabe, älterer Pull Request oder historischer Ergebnisbericht;
6. externe historische Quelle für die von ihr tatsächlich belegte Zeit, Aussage und Evidenzklasse.

Eine ältere Datei wird nicht dadurch erneut verbindlich, dass sie detaillierter ist. Maßgeblich sind Status, Geltungsbereich, Aktualität und dokumentierte Autorität.

## 3. Verbindliche Dokumentstatus

Zulässige Statuswerte:

- `DRAFT` – Entwurf ohne verbindliche Projektwirkung;
- `PLANNED` – genehmigte Planung, noch nicht technisch oder fachlich abgenommen;
- `ACCEPTED_TECHNICAL_BASELINE` – exakt dokumentierter Branch-/Commit-/Missionsstand wurde technisch akzeptiert;
- `BINDING_PROJECT_DECISION` – verbindliche Entscheidung des Projektinhabers;
- `BINDING` – verbindliche Fach- oder Arbeitsbaseline innerhalb des angegebenen Geltungsbereichs;
- `SUPERSEDED` – vollständig oder teilweise durch ein neueres Dokument ersetzt;
- `HISTORICAL_TEST_FIXTURE` – Entwicklungs- oder Testnachweis ohne produktive Architekturwirkung;
- `REJECTED` – verworfen und nicht weiterzuverwenden.

Jedes neue maßgebliche Dokument muss mindestens folgende Metadaten enthalten:

```yaml
---
document_id:
status:
authoritative_for:
scenario_period:
project_phase:
supersedes:
superseded_by:
source_branch:
source_commit:
validated_in_dcs:
---
```

Nicht anwendbare Felder dürfen leer bleiben, müssen aber bewusst bewertet werden.

## 4. Draft-Branches, technische Akzeptanz und Repository-Wahrheit

Ein bestandener DCS-Test auf einem Draft-Branch ist verbindlich für exakt den dokumentierten technischen Stand:

- Branch;
- Commit;
- Missionsdatei und Hash;
- generiertes Bundle und Hash;
- DCS-Version;
- tatsächlich geladene MOOSE-Datei und deren Version beziehungsweise Hash;
- dokumentierte Testbedingungen.

Ein solcher Stand darf als `ACCEPTED_TECHNICAL_BASELINE` bezeichnet werden. Er beweist das beobachtete Laufzeitverhalten, ersetzt aber nicht automatisch die auf `main` geltende Projekt-Governance oder Fachbaseline.

Projektweit verbindliche normative Wirkung entsteht erst durch:

1. Merge nach `main`, oder
2. eine ausdrückliche Entscheidung des Projektinhabers in einem auf `main` geführten Governance-Dokument oder ADR.

Ein Folgebranch darf auf einem akzeptierten, ungemergten Branch aufbauen. Er muss dann mindestens dokumentieren:

```yaml
base_branch:
base_commit:
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch may still be revised
```

Wird der Elternbranch geändert, verworfen oder neu aufgebaut, ist der Folgebranch neu zu bewerten.

## 5. MOOSE-First und Ausnahmen

Operation Mountain Watch ist verbindlich **MOOSE-first**.

Vor eigener Lua-Logik sind passende MOOSE-Klassen, Methoden, Ereignisse, FSM-Mechanismen, Scheduler, Sets, Wrapper, OPS-Klassen, Routing-, Spawn-, Detection-, Zone-, Coordinate-, Warehouse-, AIRWING-, SQUADRON-, AUFTRAG- und Transportfunktionen zu prüfen.

Eine technische Begründung allein genehmigt keine Abweichung. Für jede produktive Nicht-MOOSE-, Native-DCS- oder projektspezifische Parallelimplementierung gilt:

1. die MOOSE-Prüfung ist zu dokumentieren;
2. die technische Lücke oder Einschränkung ist nachzuweisen;
3. die kleinstmögliche Ergänzung ist zu entwerfen;
4. der Projektinhaber muss die Ausnahme ausdrücklich genehmigen;
5. die Ausnahme ist als ADR oder im zuständigen Acceptance-Dokument zu erfassen;
6. die Lösung muss reproduzierbar getestet werden.

Ohne ausdrückliche Eigentümerfreigabe bleibt eine Nicht-MOOSE-Lösung `DRAFT`, `EXPLORATORY` oder `HISTORICAL_TEST_FIXTURE` und darf nicht als Produktionsarchitektur übernommen werden.

## 5.1 CampaignState–MOOSE-Autorität und Ressourcenabgleich

Für Ressourcen, die sowohl strategisch persistiert als auch als physische DCS-Einheit ausgeführt werden, gilt projektweit die folgende verbindliche Trennung.

### Eine Ressource, zwei Repräsentationen

CampaignState und MOOSE dürfen nicht unabhängig denselben Bestand besitzen. Sie bilden jedoch notwendigerweise zwei Ebenen derselben Ressource ab:

| Ebene | Verbindliche Zuständigkeit |
|---|---|
| CampaignState | Persistente strategische Identität, Zugehörigkeit, Verlegung, Verfügbarkeit, Wartungs-/Schadens- und Verlustzustand |
| MOOSE | Physische DCS-Ausführung und zur Laufzeit beobachtbarer Lifecycle: Bereitstellung, Start, Auftrag, Rückkehr, Landung, Verlust und Bereinigung der DCS-Repräsentation |

Jede Ressource ist über eine stabile, von DCS-Gruppennamen unabhängige Ressourcen-ID zuzuordnen. Ein bloßer Vergleich aggregierter Zähler genügt nicht.

MOOSE wird nicht durch CampaignState ersetzt. Während einer laufenden Mission ist ein bestätigtes MOOSE-Lifecycle-Ereignis für den physischen Zustand maßgeblich. CampaignState übernimmt dieses Ereignis idempotent in den strategischen Zustand.

### Verbindliche Zustandsregeln

- Ein regulär eingesetztes, zurückkehrendes Luft-, Boden- oder See-Asset wird **nicht verbraucht**. Es wechselt zwischen mindestens `available`, `reserved`, `deployed`, `returning`, `maintenance` und `lost`.
- Ein dauerhafter Bestandsabgang ist nur nach einem bestätigten Verlust- oder ausdrücklich dokumentierten strategischen Abgangsvorgang zulässig.
- `AUFTRAG:Done`, eine Auftragsstornierung oder ein Rückkehrbefehl sind keine physische Rückkehr. Die Freigabe in CampaignState darf erst nach dem passenden bestätigten MOOSE-Ereignis für physische Rückkehr beziehungsweise Verlust erfolgen.
- CampaignState wählt vor der Disposition den konkreten Herkunftspool und die strategische Ressource. Der MOOSE-Auftrag wird anschließend explizit an den dazugehörigen AIRWING beziehungsweise die SQUADRON gebunden.
- MOOSE darf keinen ungebundenen gemeinsamen Pool mehrerer strategischer Herkunftsbestände wählen.

### Abgleich und Konfliktbehandlung

Ein Abgleich ist verpflichtend:

1. beim Missions-/Serverstart;
2. nach jeder bestätigten physischen Bereitstellung, Rückkehr und jedem Verlust;
3. nach einer Wiederherstellung oder einem kontrollierten Neustart;
4. bei einer Dispatch- oder Bestandsabweichung.

Ein erwarteter Lifecycle-Übergang darf den CampaignState nur genau einmal verändern; dafür sind stabile Ereignis- oder Settlement-IDs zu verwenden.

Bei einer ungeklärten Abweichung darf kein System stillschweigend als richtig angenommen und der Bestand nicht automatisch erhöht oder vermindert werden. Das betroffene Asset wird für neue Dispositionen gesperrt, die Abweichung mit Ressourcen-ID, CampaignState-Zustand, MOOSE-Zustand und Lifecycle-Ereignis protokolliert und anschließend gezielt entschieden beziehungsweise bereinigt.

Eine ereignisgebundene, idempotente Übernahme eines bestätigten MOOSE-Ereignisses in CampaignState ist kein zweiter Ressourcenbesitzer, sondern der vorgeschriebene Abgleich der strategischen Persistenz mit der physischen Ausführung.

### Mindestnachweise für neue Ressourcenintegrationen

Jede neue Integration von CampaignState und MOOSE muss mindestens nachweisen:

- Zuordnung über stabile Ressourcen- und Herkunfts-IDs;
- reservieren, physisch starten, zurückkehren, verlieren und erneut disponieren;
- idempotente Behandlung mehrfach zugestellter Ereignisse;
- Verhalten nach Server-/Missionsneustart;
- Diagnose und Sperrverhalten bei einer absichtlich erzeugten Abweichung.

Ohne diesen Nachweis darf eine Integration nicht als produktive Ressourcenbuchhaltung gelten.

## 6. Historischer Recherche- und Missionszeitraum

Verbindlicher Recherche- und Kampagnenzeitraum:

```text
01.08.2010 bis 31.12.2011
```

Die Kampagne wird nicht in automatisch wechselnde historische Teilphasen aufgeteilt. Innerhalb dieses Zeitraums gab es reale Staffel-, Verbands- und Bestandswechsel. Operation Mountain Watch verwendet deshalb eine **zusammengesetzte, spielbare aktive ORBAT-Baseline**.

Grundsätze:

- historische Rotationen bleiben als Recherchekontext dokumentiert;
- die aktive Missions-ORBAT wählt einen belastbaren und spielbaren Bestand innerhalb des Zeitraums;
- Satellitenbilder von Ende 2011 bilden für sichtbare Basen- und Rampstrukturen eine besonders wichtige belegte Vorlage;
- eine Satellitenaufnahme ist eine Momentaufnahme und beweist nicht automatisch vollständige administrative Stärke oder Einheitsidentität;
- Abweichungen von einem einzelnen historischen Stichtag sind als bewusste Missionsdesign-Entscheidung zu kennzeichnen.

## 7. Verbindliche aktive Luft-ORBAT-Kernentscheidungen

### Bagram

```text
335th Expeditionary Fighter Squadron
13 F-15E

121st Expeditionary Fighter Squadron
13 F-16C Block 30
DCS-Abbildung: F-16C Block 50 als gekennzeichneter technischer Ersatz
```

### Kandahar

Für die organisatorische Kandahar-Struktur ist die Juli-2011-ORBAT die entscheidende Referenz. Die aktive OMW-Abbildung besteht aus zwei getrennten Air-Ops-Domänen:

```text
451st Air Expeditionary Wing
├── 74th Expeditionary Fighter Squadron
│   16 A-10C
├── 26th Expeditionary Rescue Squadron
├── 361st Expeditionary Reconnaissance Squadron
└── 772nd Expeditionary Airlift Squadron

Task Force Thunder / 159th Combat Aviation Brigade
├── Task Force Guns / 4-227 Attack Aviation
├── Task Force Palehorse / 7-17 Air Cavalry
└── Task Force Lift / 7-101 General Support Aviation
```

Die 46th Expeditionary Rescue Squadron wird als Guardian-Angel-Personal geführt und erzeugt keinen eigenen Aircraft-Pool. Task Force Attack / 3-101 bleibt Tarin Kowt zugeordnet; Task Force Wings / 4-101 bleibt FOB Wolverine zugeordnet. Frühere aktive Kandahar-Auswahlen der 75th beziehungsweise 107th EFS sind `SUPERSEDED` und bleiben nur historischer Rotationskontext.

Die vollständigen Kandahar-Bestände und technischen SQUADRON-Pools stehen in `OMW-AIR-ACTIVE-ORBAT` sowie im Kandahar-Foundation-Bestandsvertrag.

### Jalalabad / FOB Fenty

```text
24 OH-58D
 8 AH-64D
 8 UH-60
 8 CH-47
```

Der Jalalabad-Bestand gilt für die Kampagnenbaseline als historisch ausreichend bestätigt. Die vier Inventare bleiben dennoch logisch von sichtbaren Statics, Client-Reservierungen, aktiven KI-Gruppen und virtueller Reserve getrennt.

### Spielerobergrenze

Projektweit gilt:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Basis
maximal 2 Client-Gruppen je Muster und Basis
1 Luftfahrzeug je Client-Gruppe
```

Ältere Werte von vier oder mehr Clients je Muster und Basis sind `SUPERSEDED`.

## 8. RED-Netzwerkarchitektur

TM02A bis TM02V bleiben technische Entwicklungs- und Testnachweise. Soweit sie ein starres Relais-, Baum-, Mindestbesatzungs- oder festes Sechserpaketmodell als Produktionsarchitektur beschreiben, besitzen sie den Status:

```yaml
status: HISTORICAL_TEST_FIXTURE
production_architecture: false
```

TM02W und Nachfolger bilden die verbindliche Produktionsrichtung:

- gewichtetes Bewegungsnetz;
- mehrere mögliche Quellen und alternative Wege;
- getrennte Kommando-, Bewegungs- und Personalnetze;
- Guard Floor, Readiness Target und Hard Capacity statt starrer Dauerbesatzungen;
- bounded command cycles und begrenzte Transportausführung;
- MOOSE-first für physische Ausführung, Routing, Lifecycle und Überwachung.

## 9. Projektphase

Der frühere vertikale Prototyp Jalalabad–Connolly ist als erste Projektphase ersetzt.

Aktuelle Projektphase:

```text
COMPLETE_FOUNDATION_BUILD_PHASE
```

Ziel ist zunächst der vollständige Missionsgrundbau:

- relevante Flugplätze und Luftoperationsknoten;
- FOBs, COPs, OPs, Warehouses und Infrastruktur;
- Spielergruppen, KI-Templates und Statics;
- aktive ORBAT-Arbeitsbestände;
- Naming, Dokumentregister und Missionseditor-Baselines;
- grundlegende MOOSE-AIRWING-, SQUADRON- und Logistikstrukturen.

Darauf bauen anschließend gezielte Funktions-, Integrations- und Acceptance-Tests auf. Der frühere Prototyp bleibt als Entwicklungsnachweis erhalten, ist aber nicht mehr die aktuelle Ablaufstrategie.

## 10. Quellen- und Dateinutzung

Für frei zugängliche oder vom Projektinhaber rechtmäßig bereitgestellte Projektquellen gilt bis auf Weiteres:

- vollständige fachliche Auswertung ist zulässig und erwünscht;
- Originaldateien, normalisierte Daten und abgeleitete Projektdateien dürfen nach Entscheidung des Projektmanagers beziehungsweise Autors in das Repository und in Missionspakete aufgenommen werden;
- Attribution, Quellenlink und Trennung zwischen Quellinhalt und OMW-Entscheidung bleiben verpflichtend;
- Inhalte hinter einer nicht rechtmäßig zugänglichen Paywall werden nicht beschafft, umgangen oder rekonstruiert;
- konkrete weitergehende Nutzungsbedingungen eines Materials bleiben zu beachten.

Diese Regel ist eine interne Projekt- und Veröffentlichungsentscheidung. Sie erklärt Materialien nicht allgemein zu gemeinfreien oder lizenzfreien Werken.

## 11. Dokumentnummern und stabile IDs

Dokumentnummern werden zentral in [`DOCUMENT-REGISTRY.md`](DOCUMENT-REGISTRY.md) reserviert.

Verbindliche Regeln:

- keine neue Nummer ohne Eintrag im Register;
- jedes maßgebliche Dokument erhält eine stabile `document_id`;
- die `document_id` bleibt bei Umbenennung oder Umnummerierung unverändert;
- Verweise sollen primär die stabile ID und den Pfad, nicht nur „Dokument 28“, nennen;
- Nummern auf ungemergten Branches gelten als vorläufig, sofern sie nicht zentral reserviert wurden;
- bei einer Kollision wird vor dem Merge umnummeriert.

## 12. Änderungsregel

Dieses Dokument darf nur durch eine neue ausdrückliche Entscheidung des Projektinhabers geändert oder ersetzt werden. Fachliche Detaildokumente dürfen die hier festgelegten Governance-, Status-, Zeitraum-, ORBAT-, MOOSE- oder Autoritätsregeln nicht stillschweigend überschreiben.
