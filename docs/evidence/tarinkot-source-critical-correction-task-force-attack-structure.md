---
document_id: OMW-EVIDENCE-TARINKOT-TF-ATTACK-STRUCTURE-CORRECTION
status: BINDING
document_class: SOURCE_CRITICAL_CORRECTION
owning_policy: OMW-GOV-001
authoritative_for:
  - correction of unsupported claims about Task Force Attack organic battalion structure
  - distinction between organic battalion companies and task-organized attached aircraft
  - correction of the 2011 brigade parent for 3-101 Aviation
not_authoritative_for:
  - exact full task organization of Task Force Attack on every date
  - exact local UH-60 company identity
  - exact local aircraft inventory
  - DCS or MOOSE runtime acceptance
scenario_period: 2010-08-01/2011-12-31
source_branch: agent/tarinkot-object-contract-reconciliation
validated_in_dcs: false
evidence_state: REVIEWED
project_phase: TARINKOT_OBJECT_CONTRACT_RECONCILIATION
source_commit: PENDING_MERGE
supersedes: []
superseded_by: []
---

# Tarinkot – Quellenkritische Korrektur zur Struktur von Task Force Attack

## 1. Anlass

Geprüft wurde eine Zusammenfassung mit folgenden Kernaussagen:

- Task Force Attack / 3-101 Aviation sei Ende 2011 Teil der 101st Combat Aviation Brigade gewesen;
- 3-101 habe organisch über AH-64-, UH-60- und CH-47-Kompanien verfügt;
- Company A sei AH-64, Companies B und C seien UH-60M-Assault-Kompanien gewesen;
- am wahrscheinlichsten habe B Company, 3-101 die UH-60 in Tarin Kowt gestellt;
- Task Force Lift habe in Tarin Kowt CH-47F betrieben und Afghan-Air-Force-Ausbildung durchgeführt.

Die erste, dritte und vierte Aussage sind in dieser Form falsch beziehungsweise nicht quellenfest. Die übrigen Aussagen benötigen organisatorische Präzisierung.

## 2. Korrekter Brigade-Parent 2011

Zeitgenössische offizielle U.S.-Army-Quellen nennen:

```text
3rd Battalion, 101st Aviation Regiment
159th Combat Aviation Brigade
```

Nicht:

```text
101st Combat Aviation Brigade
```

Die 159th CAB gehörte zur 101st Airborne Division, war aber eine eigenständige Combat Aviation Brigade. Die Divisionzugehörigkeit darf nicht mit dem Brigadenamen verwechselt werden.

Für Tarin Kowt 2011 gilt daher:

```text
Task Force Thunder / 159th Combat Aviation Brigade
└── Task Force Attack / 3rd Battalion, 101st Aviation Regiment
```

## 3. Organische Struktur versus Task Organization

3-101 war ein Attack Helicopter Battalion. Offizielle Quellen belegen AH-64D-Apache-Kompanien innerhalb des Bataillons:

```text
Company A: AH-64D belegt
Company B: AH-64D belegt
Company C: AH-64D belegt
```

Insbesondere nennt eine offizielle Quelle vom April 2011:

```text
Capt. Donna Buono
Commander, Company B, 3-101 Aviation Regiment
AH-64 Apache pilot
```

Weitere offizielle Quellen nennen Companies B und C bei AH-64D-Gunnery sowie Company A mit AH-64D-Crew-Chiefs beziehungsweise Attack-/Reconnaissance-Auftrag.

Damit ist folgende behauptete Gliederung nicht zulässig:

```text
Company A = AH-64
Company B = UH-60M
Company C = UH-60M
```

Sie verwechselt ein Attack Battalion mit der Gliederung eines Assault- oder General-Support-Bataillons.

## 4. Bedeutung der September-2011-Fly-over-Quelle

Die offizielle Bildunterschrift vom 11.09.2011 nennt:

```text
2 × AH-64 Apache
1 × UH-60 Black Hawk
1 × CH-47 Chinook
from Task Force Attack / 3-101 Aviation Regiment
```

Diese Formulierung belegt sicher:

- operative Zuordnung des Formationsfluges zu Task Force Attack;
- lokale Präsenz der drei Musterfamilien;
- einen task-organized gemischten Aviation-Verband.

Sie belegt nicht automatisch:

- organischen Besitz aller drei Muster durch das Stamm-Bataillon 3-101;
- dass UH-60 und CH-47 aus organischen Companies von 3-101 stammten;
- die administrative Company des UH-60;
- den vollständigen lokalen Bestand.

Task Forces konnten angegliederte Luftfahrzeuge anderer Bataillone und Companies unter einem lokalen Task-Force-Hauptquartier führen.

## 5. UH-60-Company bleibt offen

Die derzeit geprüften Quellen belegen für März bis Dezember 2011:

```text
UH-60 am FOB Tarin Kowt
operative Zuordnung zu Task Force Attack
lokale FARP-/Hot-Refuel-Unterstützung durch 3-101
```

Sie belegen nicht:

```text
B Company, 3-101 als UH-60-Betreiber
C Company, 3-101 als UH-60-Betreiber
UH-60M statt UH-60L oder anderer Untervariante
organische statt attached Zugehörigkeit
```

Da Company B von 3-101 zeitgenössisch als AH-64-Apache-Company belegt ist, ist die Vermutung `B Company, 3-101 = Tarinkot-UH-60` sogar durch die bessere Quelle widerlegt.

Der aktive Name bleibt daher:

```text
SQ_US_TKOT_UH60_TF_ATTACK
```

Company:

```text
UNRESOLVED
```

## 6. CH-47: Task Force Lift und B/1-52 sauber trennen

Die Army-Quelle `Afghan Air Force Increases Crew Coordination` belegt am 14.09.2011 einen CH-47F von:

```text
Task Force Lift
7th Battalion, 101st Aviation Regiment
```

am FOB Tarin Kowt im Rahmen einer Ausbildungs-/Transportmission mit Angehörigen der Afghan Air Force.

Das belegt:

- CH-47F von Task Force Lift war an diesem Tag in Tarin Kowt;
- Task Force Lift führte Transport- und Crew-Coordination-Ausbildung durch;
- Tarin Kowt war Ziel und Arbeitsort der Mission.

Es beweist allein nicht:

- dauerhafte Stationierung eines organischen 7-101-CH-47F-Pools in Tarin Kowt;
- dass alle lokalen CH-47 zu 7-101 gehörten;
- dass B/1-52 nicht ebenfalls lokal stationiert war.

Für eine dauerhafte lokale Einheitsbenennung ist die spezifischere Quelle maßgeblich:

```text
B Company, 1-52 Aviation Regiment
CH-47D
Detachment at FOB Tarin Kowt
attached regionally to Task Force Lift / 7-101
```

Daher bleibt:

```text
SQ_US_TKOT_CH47_B_1_52_AVN
```

Die September-2011-Task-Force-Lift-Quelle wird als zusätzliche transient/mission-specific CH-47F-Präsenz geführt, nicht als Ersatz für den belegten B/1-52-Detachment-Vertrag.

## 7. Korrigierte Kurzfassung

Zulässige Zusammenfassung:

```text
Ende 2011 war Task Force Attack / 3-101 Aviation Regiment
unter der 159th Combat Aviation Brigade am FOB Tarin Kowt eingesetzt.

3-101 war das lokale Attack-/Task-Force-Hauptquartier mit organischen
AH-64D-Apache-Kompanien und task-organized angegliederten Fähigkeiten.

UH-60 und CH-47 waren operativ Task Force Attack zugeordnet,
ohne dass daraus ein organischer Besitz durch 3-101 folgt.

Die administrative UH-60-Company ist weiterhin nicht sicher aufgelöst.

Für die lokal stationierte CH-47-Komponente ist B Company, 1-52 AVN
mit CH-47D die spezifischste belegte Einheit.

Task Force Lift / 7-101 führte zusätzlich CH-47F-Missionen und
Afghan-Air-Force-Ausbildung über Tarin Kowt durch.
```

## 8. Objektvertragsauswirkung

Keine Änderung:

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

Nicht anzulegen:

```text
SQ_US_TKOT_UH60_B_3_101_AVN
SQ_US_TKOT_UH60_C_3_101_AVN
```

Diese Korrektur autorisiert keine Lua-Implementierung.
