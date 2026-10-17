---
document_id: OMW-GAMEPLAY-CONCEPT
status: BINDING
document_class: GAMEPLAY_CONCEPT
owning_policy: OMW-GOV-001
authoritative_for:
  - high-level BLUE and RED gameplay loops
  - project mission-type and scaling principles
  - persistent-server playability and AI-autonomy principles
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/campaign-autonomy-influence-balancing
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 02 – Gameplay-Konzept

## 1. Grundmodell

BLUE betreibt strategische Hauptbasen, regionale Luft- und Logistikknoten sowie vorgeschobene FOBs. Strategische Reserven werden nicht automatisch zu lokal verfügbaren Ressourcen.

RED besteht aus regionalen Zellen und Netzwerken mit begrenztem Personal, Material und Verbindungen. Camps, Hide Sites, Caches, Sammelpunkte, Hinterhaltstellungen und Rückzugsräume besitzen nachvollziehbare Herkunft und Funktion.

Operation Mountain Watch ist als dauerhaft laufende persistente COIN-Kampagne ausgelegt. Spielerpräsenz ist nicht vorausgesetzt. Die Kampagne muss auch über längere Zeiträume ohne menschliche Spieler strategisch weiterlaufen, darf dabei aber weder durch autonome RED-Aktivität in einen unbeaufsichtigten BLUE-Zusammenbruch noch durch BLUE-KI in einen faktisch gewonnenen Endzustand kippen.

Der ursprüngliche Gameplay-Text bleibt unverändert erhalten:

- [`Legacy-Gameplay-Konzept`](evidence/source-records/legacy-02-gameplay-concept.md)

## 2. BLUE-Kernschleife

1. Lage, Ressourcen und offene `MissionDemand`-Objekte bewerten.
2. Aufklärung, Versorgung, Schutz oder Angriff planen.
3. gegnerische Operation verhindern, abwehren oder deren Infrastruktur bekämpfen.
4. Verluste, Versorgung und Einsatzbereitschaft bearbeiten.
5. Erkenntnisse über Netzwerke, Routen, Kuriere und Führung gewinnen.
6. strategische Folgen in den CampaignState übernehmen.

BLUE-KI dient primär dem Halten, Reagieren und Versorgen. Sie darf notwendige Verteidigung, QRF, CAS, ISR, CSAR, Route Security, Patrouillen und bedarfsgetriebene Logistik durchführen. Sie darf RED jedoch nicht allein deshalb systematisch abarbeiten, weil CampaignState RED-Standorte oder Ressourcen intern kennt. Für offensive Maßnahmen gilt derselbe Intelligence- und MissionDemand-Vertrag wie für Spieler.

## 3. RED-Kernschleife

1. Ziel anhand eigener Informationen und Ressourcen auswählen.
2. Personal, Waffen, Fahrzeuge und Transportkapazität reservieren.
3. Operation vorbereiten und Kräfte real oder kontrolliert virtualisiert verlegen.
4. Hinterhalt, Mörserangriff, Raid, Logistik oder größeren Angriff durchführen.
5. bei Verlusten zurückziehen, zerstreuen oder evakuieren.
6. nur über vorhandene Netzwerke, lokale oder externe Zuführung und verfügbare Ressourcen regenerieren.

RED-Angriffe entstehen nicht als spielerabhängige Zufallsspawns. Vor einer Operation müssen die erforderlichen strategischen Voraussetzungen bestehen, beispielsweise Information, Personal, Material, Cache-/Versorgungszugang, Sammeln und Verlegung. Diese Vorbereitung erzeugt selbst beobachtbare oder aufklärbare Aktivität und damit potenzielles Gameplay vor dem eigentlichen Angriff.

## 4. Missionsarten

- Straßen-, Hubschrauber- und Fixed-Wing-Logistik;
- Konvoieskorte und Route Clearance;
- QRF und CASEVAC/MEDEVAC;
- Reconnaissance, ISR, HUMINT und Armed Reconnaissance;
- CAS, Strike, Raid und Seize/Destroy;
- CSAR und konkurrierende Capture-/Recovery-Vorgänge;
- FOB-Verstärkung, Reparatur und Wiederaufbau;
- Target Development und HVT-/Netzwerkoperationen;
- Show of Force und Präsenzmissionen bei plausibler lokaler Lage;
- bedarfsgetriebene Humanitarian-/Civil-Support-Lieferungen an dafür vorgesehene Ortschaften.

Missionen werden nicht erzeugt, nur um Spieler künstlich zu beschäftigen. Versorgung entsteht aus tatsächlichem Bedarf, Aufklärung aus tatsächlicher Unsicherheit oder gegnerischer Aktivität, CAS aus realem Unterstützungsbedarf und RED-Aktivität aus dessen eigener strategischer Planung.

## 5. Skalierung

Die Spielerzahl beeinflusst vor allem:

- Zahl paralleler physisch dargestellter Operationen;
- verfügbare Rollen und Tasking;
- Auswahl und Sichtbarkeit bereits plausibler MissionDemand-Objekte;
- Einsatz schwerer Mittel;
- Materialisierungs- und Performancebudgets.

Die Spielerzahl ist kein direkter Generator für RED-Personal, RED-Angriffe oder strategische Ressourcen. RED darf nicht nur deshalb zusätzliche Kräfte erhalten, weil Spieler online sind.

Skalierung erfolgt nicht lediglich durch mehr gleichzeitig gespawnte Einheiten.

## 6. Persistenter Serverbetrieb und Spielbarkeit

### 6.1 Kampagne läuft ohne Spieler weiter

Die Hintergrundsimulation, Ressourcenverbräuche, strategischen Zustände, MissionDemand-Entstehung, RED-Netzwerkaktivität und notwendige BLUE-Reaktionen laufen auch ohne Spieler weiter. Spieleranwesenheit ist keine Voraussetzung für strategischen Fortschritt.

Gleichzeitig gilt:

```text
NO_PLAYERS != FREE_RED_ADVANCE
NO_PLAYERS != BLUE_AI_VICTORY
```

Autonome KI soll den Konflikt weiterführen und lokale Ergebnisse erzeugen, aber keinen künstlichen dauerhaften Endzustand erzwingen.

### 6.2 Begrenzte BLUE-Autonomie

BLUE-CHIEF/COMMANDER darf ohne Spieler insbesondere:

- kritische Versorgung sicherstellen;
- Verteidigung und QRF auslösen;
- CAS/ISR bei tatsächlich entstandenem Bedarf zuweisen;
- Route Security und Patrouillen ausführen;
- CSAR/AICSAR-Fallbacks durchführen, soweit separat genehmigt;
- strategisch notwendige Konvois oder Lufttransporte starten.

BLUE-KI soll den Betrieb aufrechterhalten, nicht das Schlachtfeld autonom dominieren. Besonders interessante, nicht zeitkritische Target-Development-, HUMINT-, Recon-, Interdiction- oder Raid-Gelegenheiten dürfen bewusst für Spieler offen bleiben, solange dadurch kein unplausibler Systemstillstand entsteht.

### 6.3 Begrenzte RED-Autonomie

RED darf ohne Spieler weiter beobachten, versorgen, verlegen, Caches aufbauen, reinfiltrieren und Operationen vorbereiten. Jede Operation muss jedoch aus vorhandenen Ressourcen, Zugängen und Netzwerken entstehen. Kein RED-Angriff darf ausschließlich durch einen Timer oder Spieler-Login begründet sein.

### 6.4 MissionDemand-Fallback

MissionDemand ist der gemeinsame Bedarf für Spieler und KI. Für die spätere Umsetzung sind mindestens drei Autonomieklassen vorzusehen:

```text
ESSENTIAL
OPERATIONAL
PLAYER_OPPORTUNITY
```

Bedeutung:

- `ESSENTIAL`: bei ausbleibender Spielerübernahme muss nach passender Frist eine KI-Lösung möglich sein;
- `OPERATIONAL`: KI darf übernehmen, wenn Priorität, Lage und Ressourcen dies rechtfertigen;
- `PLAYER_OPPORTUNITY`: bevorzugter Spielerinhalt; KI übernimmt nur bei ausdrücklich definierter Notwendigkeit oder lässt den Bedarf verfallen/neu bewerten.

Die genaue Klassifizierung einzelner Missionstypen und die Fristen bleiben eine separate Fachentscheidung.

### 6.5 Bedarf statt Beschäftigungsgenerator

Nicht-DCS-Ressourcen wie allgemeine Versorgung, Lebensmittel, Wasser, medizinische Güter oder andere abstrahierte Verbrauchsgüter dürfen CampaignState-seitig verbraucht werden, wenn sie eine echte strategische Funktion besitzen. Daraus können reale Resupply-Demands entstehen.

Beispiel:

```text
stock decreases by strategic consumption
-> reorder threshold reached
-> MissionDemand RESUPPLY
-> player opportunity window
-> AI fallback if required
-> successful delivery updates CampaignState
```

Damit bleiben Supply-Missionen kausal und nachvollziehbar, auch wenn gerade kein Kampfauftrag existiert.

## 7. Strategisches Balancing

Balancing wird in drei getrennten Ebenen betrachtet:

```text
STRATEGIC BALANCE
resources, regeneration, logistics, influence, security

AUTONOMY BALANCE
what BLUE and RED AI may achieve without players

GAMEPLAY PACING
which plausible activities are exposed or materialized when players are present
```

Diese Ebenen dürfen nicht vermischt werden. Insbesondere ist Gameplay-Pacing kein Freibrief für unkausale Spawns oder künstliche RED-Ressourcenerzeugung.

Langfristiger Spielerfolg soll reale strategische Wirkung besitzen: ein über längere Zeit gut gesicherter Raum darf ruhiger werden. Die Kampagne erhält ihre Dauerhaftigkeit durch Regeneration, Reinfiltration, Ressourcenflüsse, wechselnde Schwerpunkte und Einflussdynamik, nicht durch sofortiges Zurücksetzen erfolgreicher Spieleraktionen.
