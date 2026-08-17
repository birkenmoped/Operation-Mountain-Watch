---
document_id: OMW-EVIDENCE-ARMY-GROUND-2011-07-UNIT-RECONCILIATION
status: PLANNED
document_class: EVIDENCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - source-qualified July-2011-near unit evidence for the active ARMY Ground Foundation nodes
  - explicit limits on company and platoon attribution at Jalalabad, Joyce, Bostick and Wright
not_authoritative_for:
  - final OMW ground-force ORBAT strengths
  - final MOOSE BRIGADE or PLATOON topology
  - final Mission Editor object state
  - DCS runtime acceptance
scenario_period: 2011-05-01/2011-09-30
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – July-2011 unit reconciliation

## 1. Zweck

Dieser Evidenzstand präzisiert die offenen Phase-B-Fragen der ARMY Ground Foundation mit offiziellen DoD-/DVIDS-Quellen aus dem unmittelbaren Umfeld des Juli-2011-Snapshots.

Die Arbeitsregel bleibt:

```text
historical formation evidence
!= final OMW physical strength
!= MOOSE PLATOON composition
!= DCS group template
```

Eine einzelne Bildunterschrift oder Story wird nur für die dort tatsächlich belegte Einheit, den genannten Ort und den genannten Zeitraum verwendet.

## 2. Jalalabad / FOB Fenty

### 2.1 TF Bronco als lokales Higher HQ

DVIDS dokumentiert die Transfer-of-Authority am 03.05.2011 auf FOB Fenty. `Task Force Bronco / 3rd BCT, 25th Infantry Division` übernahm Kunar, Nangarhar und Nuristan und nutzte FOB Fenty als Brigade-HQ-Knoten.

Quelle:

- DVIDS Story 69999, *TF Bronco assumes battle space from TF Bastogne*, 07.05.2011: <https://www.dvidshub.net/news/69999/tf-bronco-assumes-battle-space-tf-bastogne>

### 2.2 konkret belegtes Ground-/Security-Element

DVIDS Story 72077 belegt am 11.06.2011 in Jalalabad das `Military Police Platoon, Headquarters & Headquarters Company, 3rd Brigade Special Troops Battalion, 3rd BCT, 25th Infantry Division, Task Force Bronco`. Das Platoon arbeitete mit Afghan Customs Police an Security Assessment, Training und Ausstattung des Jalalabad Customs Depot.

Damit ist für die Juli-2011-nahe Ground-Foundation ein konkretes TF-Bronco-Security-Element im Jalalabad-Raum belegt. Die Quelle beweist jedoch **nicht**, dass dieses MP Platoon allein die gesamte FOB-Fenty-Base-Defense oder QRF stellte.

Quelle:

- DVIDS Story 72077, *Military police share tactics, deliver equipment to Jalalabad Customs Depot*, 11.06.2011: <https://www.dvidshub.net/news/72077/military-police-share-tactics-deliver-equipment-jalalabad-customs-depot>

### 2.3 QRF-Abgrenzung

Eine DVIDS-Story vom 18.07.2011 beschreibt einen QRF-Call im Tactical Operations Center von `Task Force Shooter` auf FOB Fenty zur Unterstützung von TF-Bronco-Soldaten. Diese Quelle belegt einen **Aviation-QRF-Kontext** auf Fenty, nicht automatisch einen eigenständigen Ground-QRF-Zug für die spätere OMW-Bodenstruktur.

Quelle:

- DVIDS Story 73871, *Junkyard Dogs keep Apaches in the air*, 18.07.2011: <https://www.dvidshub.net/news/73871/junkyard-dogs-keep-apaches-air>

Für die Ground Foundation bleibt deshalb zulässig:

```text
JALALABAD_SECURITY
  strong candidate basis:
    HHC / 3rd BSTB Military Police Platoon

JALALABAD_GROUND_QRF
  exact July-2011 formation:
    OPEN
```

## 3. Joyce / Honaker-Miracle

### 3.1 FOB Joyce – B Company / 2-35 Infantry

DVIDS Bildmaterial vom 13.09.2011 belegt `B Company, 2nd Battalion, 35th Infantry Regiment, Task Force Cacti` direkt auf FOB Joyce bei einer CH-47-Sling-Load-Versorgung mit Fuel Blivets.

Zusätzlich belegt eine DVIDS-Story vom 18.09.2011 `1st Platoon, Bravo Company, 2nd Battalion, 35th Infantry Regiment` bei einem Key-Leader-Engagement nahe FOB Joyce im Sarkani District.

Diese Quellen liegen wenige Wochen nach der Juli-2011-Baseline und zeigen belastbar, dass B Company / 2-35 im Joyce-Komplex operierte. Sie beweisen nicht, dass **jede** B-Company-Komponente im Juli dauerhaft auf FOB Joyce stationiert war.

Quellen:

- DVIDS Image 464973, *Resupply operation*, 13.09.2011: <https://www.dvidshub.net/image/464973/resupply-operation>
- DVIDS Story 77521, *Afghan governor hosts lunch for Tropic Lightning*, 18.09.2011: <https://www.dvidshub.net/news/77521/afghan-governor-hosts-lunch-tropic-lightning>

### 3.2 C Company / 2-35 Infantry

DVIDS Bildmaterial vom 29.07.2011 belegt `C Company, 2nd Battalion, 35th Infantry Regiment` während Operation Diamond Head im Pech River Valley. Das Material ist mit FOB Fenty als Medienstandort versehen, die Caption verortet die Soldaten jedoch im Chapah Darah District / Pech River Valley.

Daraus folgt **keine** belastbare Stationierung von C Company auf FOB Joyce. Die Quelle ist nur ein Nachweis für C-Company-Operationen im erweiterten TF-Cacti-Raum Ende Juli 2011.

Quelle:

- DVIDS Image 446394, *Operation Diamond Head*, 29.07.2011: <https://www.dvidshub.net/image/446394/operation-diamond-head>

### 3.3 Honaker-Miracle – Battery C / 3-321 Field Artillery

DVIDS Story 74586 und zugehörige Bilder belegen am 30.07.2011 zwei M777A2 am COP Honaker-Miracle sowie Soldaten von `Battery C, 3rd Battalion, 321st Field Artillery Regiment, 18th Fires Brigade`, attached to TF Bronco.

Damit ist für den Juli-2011-Snapshot eine konkrete Fire-Support-Zuordnung belastbar:

```text
COP Honaker-Miracle
└── C Battery / 3-321 Field Artillery
    └── two M777A2 documented on 2011-07-30
```

Quellen:

- DVIDS Story 74586, *Budget or No Budget, soldiers focused on the tasks at hand*, 01.08.2011: <https://www.dvidshub.net/news/74586/budget-no-budget-soldiers-focused-tasks-hand>
- DVIDS Image 436824, 30.07.2011: <https://www.dvidshub.net/image/436824/budget-no-budget-soldiers-focused-tasks-hand>

## 4. Bostick / TF Wolfhound

### 4.1 Battalion HQ presence

DVIDS Story 70185 belegt am 01.05.2011 `2nd Battalion, 27th Infantry Regiment, Task Force No Fear / TF Bronco` auf FOB Bostick. Die Story nennt Lt. Col. Daniel B. Wilson als Battalion Commander und beschreibt die Battalion-Aktivität auf Bostick.

DVIDS Story 76198 belegt im August 2011 erneut TF No Fear im Raum um FOB Bostick, Naray und Jabah.

Damit bleibt die bisherige Juli-2011-Baseline `TF Wolfhound / 2-27 Infantry -> FOB Bostick` stark gestützt.

Quellen:

- DVIDS Story 70185, *Wolfhound soldiers continue World War II tradition, help Japanese orphans*, 01.05.2011: <https://www.dvidshub.net/news/70185/wolfhound-soldiers-continue-world-war-ii-tradition-help-japanese-orphans>
- DVIDS Story 76198, *TF No Fear lends a helping hand during Ramadan*, 19.08.2011: <https://www.dvidshub.net/news/76198/tf-no-fear-lends-helping-hand-during-ramadan>

### 4.2 Company-level limits

Story 70185 nennt `Alpha Company, 2-27 Infantry` ausdrücklich am `Combat Outpost Pirtle King`, nicht auf FOB Bostick. Sie nennt außerdem Angehörige der Foxtrot Company, ohne daraus einen eigenen Bostick-Maneuver-Company-Standort abzuleiten.

Für OMW wird deshalb **keine** einzelne Company als sichere Juli-2011-Garnisonskompanie von FOB Bostick festgeschrieben. Belastbar bleibt zunächst:

```text
FOB Bostick
  Battalion / Task Force node:
    2-27 Infantry / TF No Fear

exact maneuver company permanently based at Bostick in July 2011:
  OPEN
```

Das verhindert eine falsche 1:1-Ableitung von Battalion-HQ-Standort auf lokale Company-/Platoon-Stärke.

## 5. Wright / Artillerie

Die bisherige Primärquelle DVIDS Story 52264 belegt `Bravo Battery, 3-321 Field Artillery` mit `2nd Platoon` und M777 am FOB Wright im Jahr 2010. Sie sagt zugleich, dass Bravo Battery Platoons auf Wright, Bostick und Blessing verteilt hatte und bis 2011 im Land bleiben sollte.

Diese Aussage ist **kein Nachweis**, dass dasselbe 2nd Platoon oder dieselbe B-Battery-Verteilung im Juli 2011 unverändert auf Wright stand. Im aktuellen Review wurde keine belastbare offizielle Quelle gefunden, die eine konkrete Juli-2011-Battery-/Platoon-Zuordnung auf Wright festschreibt.

Quelle:

- DVIDS Story 52264, *Top Chi reaches out, touches insurgent forces*, 01.07.2010: <https://www.dvidshub.net/news/52264/top-chi-reaches-out-touches-insurgent-forces>

Damit bleibt verbindlich:

```text
Wright historical M777 capability in OMW period:
  CONFIRMED

Wright exact July-2011 artillery battery/platoon:
  OPEN
```

Eine M777- oder Proxy-Gruppe darf für die Juli-2011-Foundation daher nicht allein aus dem 2010er Wright-Nachweis als historisch exakt attribuiert werden.

## 6. Konsequenz für die nächste OMW-Designstufe

Die Quellen reichen jetzt aus, um die historische Rollenbasis enger zu fassen, aber noch nicht für exakte DCS-Stärken:

```text
GROUND_NODE_JALALABAD
  HQ / regional command: TF Bronco
  artillery relation: TF Steel / 3-7 FA
  concrete local security evidence: HHC / 3rd BSTB MP Platoon
  exact ground QRF formation: OPEN

GROUND_NODE_JOYCE
  maneuver parent: TF Cacti / 2-35 Infantry
  B Company operating at/from Joyce: SUPPORTED
  1st Platoon B Company near Joyce in Sep 2011: CONFIRMED
  Honaker fire support: C/3-321 FA, two M777A2 on 2011-07-30
  exact July company distribution across Joyce/Honaker: PARTIAL

GROUND_NODE_BOSTICK
  maneuver parent / battalion node: TF No Fear / 2-27 Infantry
  exact Bostick maneuver company: OPEN
  Alpha Company specifically at COP Pirtle King in May 2011: CONFIRMED

GROUND_NODE_WRIGHT
  July-2011 security basis: 1-14th Illinois ADT SECFOR
  historical M777 presence: CONFIRMED for 2010
  exact July-2011 artillery element: OPEN
```

Daraus dürfen im nächsten Schritt Rollen-**Kandidaten** für PLATOON-Pools abgeleitet werden. Eine endgültige PLATOON-Struktur, Gruppengröße, DCS-Fahrzeugausstattung oder Artillerie-Proxyentscheidung bleibt eine separate OMW-Designentscheidung und benötigt anschließend MOOSE-/DCS-Tests.
