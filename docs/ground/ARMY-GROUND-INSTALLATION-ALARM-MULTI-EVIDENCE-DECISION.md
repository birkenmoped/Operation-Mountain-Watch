---
document_id: OMW-ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE
status: BINDING_PROJECT_DECISION
document_class: INSTALLATION_ALARM_AND_RESPONSE_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - project-wide BLUE installation alarm evidence semantics
  - project-wide alarm-zone semantics for mission-relevant BLUE installations
  - OR-combination of valid attack indicators
  - separation of alarm evidence from tactical battlespace and response completion
  - local-first and external-support response model
  - installation Guard patrol behavior
  - QRF composition and vehicle augmentation policy
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - any interpretation that this decision applies only to ARMY FOBs/COPs/OPs
  - any interpretation that hostile entry into an installation alarm zone is the sole attack trigger
  - any interpretation that multiple confirmed hits are required before an installation alarm may activate
  - any interpretation that an installation alarm zone is the tactical battlespace or mission-end boundary
  - static Guard behavior as the intended project-wide baseline
  - infantry-only QRF as the intended project-wide baseline
superseded_by:
source_branch: agent/installation-guard-qrf-governance
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# OMW BLUE Installations – verbindliche Alarm-, Guard- und QRF-Regel

## 1. Projektweiter Geltungsbereich

Diese Entscheidung gilt fuer **alle missionsrelevanten BLUE-Einrichtungen** von Operation Mountain Watch, nicht nur fuer ARMY-Einrichtungen und nicht nur fuer Honaker-Miracle.

Dazu gehoeren insbesondere, soweit sie in OMW als operative Einrichtung modelliert werden:

```text
airfields / air bases
FOBs
COPs
OPs
camps
firebases
FARPs / heliports
logistics nodes
HQ / command sites
radar / sensor sites
other mission-relevant BLUE installations
```

Jede solche Einrichtung besitzt einen stabilen Installation-Kontext mit mindestens:

```text
installationId
installation type
anchor / location
installation-specific alarm / security zone
available local capabilities and assets
support relationships
resource state
active installation attack incident, if any
```

Die Alarmzone gehoert semantisch zur **Installation**, nicht zu einer einzelnen dort stationierten MOOSE-Organisation. Eine Installation kann mehrere operative Organisationen und Provider beherbergen, zum Beispiel BRIGADE, AIRWING, SQUADRON, PLATOON oder andere MOOSE-/OMW-Strukturen.

## 2. Verbindliches Multi-Evidence-Alarmmodell

Das Eindringen feindlicher Kraefte in eine standortbezogene Alarm-/Security-/Threat-Zone ist **ein** gueltiger Ausloeser, aber niemals der einzige moegliche Ausloeser.

```text
INSTALLATION ALARM =
    credible hostile proximity / penetration evidence
 OR credible hostile direct-fire evidence
 OR credible hostile indirect-fire / stand-off-fire evidence
 OR confirmed hostile hit / damage evidence
 OR other positively correlated hostile attack evidence
```

Sobald **eine** hinreichend belastbare Evidenzquelle einen laufenden Angriff auf die Installation oder ihre zugeordneten Verteidiger belegt, darf der Installationsalarm aktiviert werden. Es ist weder ein zweiter Ausloeser noch eine Mindestanzahl von Treffern erforderlich.

## 3. Verbindliche Evidenzklassen

Die OMW-Domain verwendet mindestens folgende semantische Evidenzklassen:

```text
PROXIMITY_INTRUSION
DIRECT_FIRE_ATTACK
INDIRECT_FIRE_ATTACK
CONFIRMED_HIT_ATTACK
OTHER_CONFIRMED_ATTACK
```

Diese Namen sind OMW-Domainbegriffe. Sie sind nicht zwingend 1:1 an genau ein einzelnes MOOSE-Event gebunden. Mehrere MOOSE-Signale duerfen dieselbe Domain-Evidenzklasse speisen.

Beispiele:

```text
RED enters installation alarm zone
-> PROXIMITY_INTRUSION
-> alarm

RED fires from outside the alarm zone at installation defenders
-> DIRECT_FIRE_ATTACK
-> alarm

RED mortar/artillery/rocket fires from outside the alarm zone
and the projectile impacts in the installation alarm area
-> INDIRECT_FIRE_ATTACK
-> alarm

RED hits an installation defender
-> CONFIRMED_HIT_ATTACK
-> alarm
```

## 4. Alarmzone ist kein Kampfgebiet

Projektweit gilt fuer jede missionsrelevante BLUE-Installation:

```text
installation alarm / security zone
= threat-detection and response-trigger boundary
!= tactical battlespace
!= weapons engagement zone
!= fire-support target area
!= CAS engagement area
!= mission-end condition
```

Ein Gegner kann den Alarm daher auch von ausserhalb der Zone ausloesen. Ebenso beendet das Verlassen oder Freikaempfen der Alarmzone einen bereits ausgeloesten Guard-, QRF-, Fire-Support-, CAS-, RECON-, MEDEVAC-, Supply- oder sonstigen Response-Auftrag nicht automatisch.

Ein MOOSE-`OPSZONE`-Zustand wie `Defeated` innerhalb der Alarmzone bedeutet nur, dass die unmittelbare Bedrohung dieser Triggergrenze beendet ist. Er beweist nicht, dass der umliegende taktische Gefechtsraum frei von relevanten Feindkraeften ist.

## 5. Ein Angriff, mehrere Evidenzen, ein Incident

Mehrere Evidenzquellen desselben Angriffs duerfen keine parallelen Alarmvorfaelle oder mehrfachen identischen Response-Demands erzeugen.

Verbindliches Modell:

```text
multiple valid evidence sources
-> one installation attack incident
-> refresh / strengthen same incident
-> deduplicated response orchestration
```

Beispiel:

```text
RED enters alarm zone
+ starts direct fire
+ scores a hit
+ mortar round impacts nearby

= one attack incident
!= four independent attack incidents
```

Die konkrete Incident-ID-, Timeout- und Refresh-Implementierung bleibt technische Ausgestaltung und muss gegen die aktuellen CampaignState-/MissionDemand-Vertraege erfolgen.

Bekannte Angreifer duerfen nach Ausloesung des Incidents weiter Teil des taktischen Zielbilds bleiben, auch wenn sie die Alarmzone spaeter verlassen. Das Verlassen der Triggerzone allein entfernt einen Angreifer nicht aus einem laufenden Incident.

## 6. Local-first Response und externe Unterstuetzung

Jede Installation reagiert zuerst mit den **eigenen tatsaechlich verfuegbaren und geeigneten Faehigkeiten und Assets**. Reichen diese nicht aus, sind sie nicht vorhanden, nicht geeignet, gebunden, beschaedigt oder erschoepft, erzeugt die Installation einen Bedarf fuer externe Unterstuetzung.

Verbindliches Zielbild:

```text
Installation Attack Incident
-> evaluate local capabilities / assets
-> use suitable local response where available
-> create MissionDemand for unmet capability
-> select eligible external provider
-> reserve / assign available asset
-> MOOSE AUFTRAG / operational execution
-> lifecycle evidence / settlement
```

Moegliche Response-Bedarfe sind insbesondere:

```text
Guard / local defence
QRF / reinforcement
Fire Support
CAS
RECON / ISR
MEDEVAC / CASEVAC where applicable
Supply / Resupply
other explicitly modelled OMW support capabilities
```

Die Installation fordert grundsaetzlich eine **Faehigkeit**, nicht ein fest verdrahtetes Einzelasset an. Beispiel:

```text
request FIRE_SUPPORT
request CAS
request RECON
request MEDEVAC
request AMMO
```

Nicht als generelles Architekturprinzip:

```text
send Wright L118 #2
send Jalalabad Apache #1
```

Die konkrete Provider-/Assetauswahl erfolgt ueber die vorhandene OMW-/MOOSE-Architektur unter Beachtung von CampaignState-Autoritaet, Verfuegbarkeit, Reichweite, Eignung und operativem MOOSE-Lifecycle.

## 7. Installation versus MOOSE-Organisation

Installation und operative Organisation sind getrennte Begriffe.

```text
INSTALLATION
= geographic / operational site

ORGANIZATION / PROVIDER
= capability provider located at or assigned to a site
```

Eine Installation kann mehrere Provider enthalten, zum Beispiel:

```text
Jalalabad installation
├── AIRWING
│   ├── AH-64 squadron
│   ├── CH-47 squadron
│   └── other air squadrons
├── Ground BRIGADE
│   ├── Guard platoon
│   ├── QRF platoon
│   └── logistics assets
└── CampaignState / Warehouse node
```

Der Installationsalarm darf daher nicht an eine einzelne SQUADRON, BRIGADE oder LEGION gebunden werden. Diese sind Reaktions-/Ausfuehrungsprovider innerhalb oder ausserhalb des Standorts.

## 8. Verbindliches Guard-Verhalten

Guard-Kraefte sind die dauerhaft lokale erste Sicherung einer Installation. Das projektweite Sollverhalten ist **aktive Patrouille**, nicht dauerhaft statisches Herumstehen mit rein reaktivem Zurueckschiessen.

Bevorzugte Umsetzung:

```text
owner-authored Mission Editor Guard route
-> validated route through / around installation
-> MOOSE route patrol / repeated circuit
-> local first-line defence remains installation-bound
```

Eine freie Patrol-Zone ist nur ein Fallback fuer Standorte, deren Terrain und Bebauung nachweislich robust funktionieren. Fuer Afghanistan wird wegen Ground-AI-Pathfinding grundsaetzlich eine vom Projektinhaber im Mission Editor gesetzte, validierte Route bevorzugt.

Die Guard darf durch normale externe Support-Requests nicht vollstaendig aus der lokalen Sicherungsaufgabe abgezogen werden.

MOOSE-first-Kandidat fuer die Route ist der vorhandene Patrol-Route-Pfad (`CONTROLLABLE:PatrolRoute()` beziehungsweise der entsprechende GROUP-Wrapper-Pfad im verwendeten MOOSE-Stand). Vor produktiver Aktivierung ist die konkrete Route je Installation in DCS zu pruefen.

## 9. Verbindliches QRF-Modell

Eine QRF ist eine lokale Bereitschaftsreserve und **nicht auf Infanterie beschraenkt**.

Sie darf entsprechend dem tatsaechlich verfuegbaren lokalen Bestand dynamisch aus geeigneten Assets zusammengestellt werden, zum Beispiel:

```text
infantry squad
+ optional MRAP / M-ATV / armed HMMWV / other suitable protected or armed vehicle
```

Fuer die erste produktive Ausbaustufe ist kein kombiniertes DCS-Template fuer jede moegliche Infanterie-/Fahrzeugkombination erforderlich.

Bevorzugtes Phase-1-Modell:

```text
one infantry GROUP asset
+ optional independent vehicle GROUP asset
-> one logical QRF response package
-> same installation attack incident
-> coordinated tasking / target picture
```

Die physisch getrennten DCS-/MOOSE-Gruppen bleiben getrennte Assets, werden aber logisch als ein Response-Paket disponiert. Fahrzeugbeistellung erfolgt nur, wenn ein geeignetes Fahrzeug am Standort tatsaechlich verfuegbar ist.

Beispiel:

```text
local stock:
2 rifle squads
1 M-ATV
0 armed HMMWV

QRF request:
1 rifle squad
+ up to 1 suitable vehicle if available

result:
1 rifle squad + 1 M-ATV
```

Ist das M-ATV bereits deployed, lost, damaged oder anderweitig gebunden, darf die naechste QRF entsprechend nur mit den verbleibenden verfuegbaren Assets ausruecken.

## 10. Mounted Infantry / OPSTRANSPORT – spaetere Ausbaustufe

Ein gemischtes DCS-Template aus Infanteristen und Fahrzeugen ist **kein** Ersatz fuer echtes Auf-/Absitzen. Infanterie in derselben DCS-Gruppe laeuft nicht automatisch als transportierte Besatzung im Fahrzeug mit.

Fuer echtes mounted-QRF-Verhalten ist der MOOSE-first Kandidat `OPSTRANSPORT`:

```text
Infantry GROUP = cargo
vehicle / carrier GROUP = carrier
-> embark
-> transport
-> deploy / disembark
-> ground engagement
```

`OPSTRANSPORT` bleibt fuer diesen OMW-QRF-Scope bis zu einem isolierten DCS-Acceptance-Test `SOURCE_REVIEWED`. Insbesondere Materialisierung, Embark/Disembark, sichtbares Verhalten, Pathfinding und Lifecycle duerfen nicht aus Source-Review allein als validiert gelten.

Bis dahin gilt Phase 1 mit koordinierten, aber getrennten Infantry-/Vehicle-Gruppen als bevorzugter QRF-Pfad.

## 11. MOOSE-first Source Review fuer Alarmdetektion

Gepruefter MOOSE-Stand fuer diese Entscheidung:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im gepinnten Source sind fuer die Alarmdetektion insbesondere vorhanden:

```text
OPSZONE
EVENTHANDLER
EVENTS.Hit
EVENTS.Shot
EVENTS.ShootingStart
EVENTS.ShootingEnd
WEAPON
WEAPON:StartTrack(...)
WEAPON:SetTimeStepTrack(...)
WEAPON:SetFuncImpact(...)
WEAPON:GetImpactCoordinate()
WEAPON:GetTarget()
WEAPON:IsShell()
WEAPON:IsRocket()
WEAPON:IsMissile()
ZONE:IsCoordinateInZone(...)
```

Source-seitig belegt ist ausserdem, dass `OPSZONE:OnEventHit(...)` bei aktivem Hit-Monitoring einen Treffer auf einen Verteidiger innerhalb der Zone in den Zustand `Attacked` ueberfuehren kann.

`WEAPON` kann aus dem MOOSE-`Shot`-Event erzeugt werden, die Flugbahn bis zum Verlust des DCS-Waffenobjekts verfolgen und anschliessend eine Impact-Koordinate sowie einen Impact-Callback bereitstellen. Die Klasse weist selbst darauf hin, dass ein Weapon-Target fehlen, verloren gehen oder wechseln kann. `GetTarget()` darf daher nicht die alleinige Korrelation fuer einen Installationsangriff bilden.

Der Standard-Tracking-Zeitschritt von `WEAPON` betraegt 0,01 Sekunden und kann ueber `SetTimeStepTrack(...)` geaendert werden. Daher ist projektweit ausgeschlossen, blind jedes Geschoss der Mission hochfrequent zu verfolgen. Vor einem Weapon-Tracking muessen billige Filter fuer feindliche Coalition, relevante Waffenkategorie und potenziell betroffene Installation angewendet werden.

## 12. Offizielle MOOSE-Demo-Evidenz

Die offizielle MOOSE-Demo `Wrapper/Weapon/040-Track-Shell` demonstriert den vorgesehenen Framework-Pfad fuer Artilleriegranaten:

```text
EVENTHANDLER
-> EVENTS.Shot
-> WEAPON:New(eventdata.weapon)
-> WEAPON:SetFuncImpact(...)
-> WEAPON:StartTrack()
-> WEAPON:GetImpactCoordinate()
-> ZONE:IsCoordinateInZone(...)
```

Damit ist fuer OMW ein MOOSE-first Weg fuer indirektes Feuer vorhanden: Ein feindliches Shell-/Rocket-/relevantes Missile-Projektil kann nach geeigneter Vorfilterung bis zum Einschlag verfolgt und ein Impact in einer Installations-Alarmzone als `INDIRECT_FIRE_ATTACK`-Evidenz gewertet werden, ohne einen BLUE-Treffer vorauszusetzen.

## 13. Noch nicht DCS-validierte Punkte

Diese Entscheidung ist eine verbindliche Architektur-/Semantikentscheidung, aber **kein DCS-Runtime-PASS**.

Vor produktiver Aktivierung sind mindestens isoliert zu pruefen:

```text
A. hostile ground unit enters alarm zone without firing
   -> PROXIMITY_INTRUSION

B. hostile small-arms / machine-gun fire from outside alarm zone
   -> useful ShootingStart / Hit correlation

C. hostile RPG / rocket fire from outside alarm zone
   -> Shot target correlation where available
   OR tracked impact in alarm zone

D. hostile mortar / artillery fire from well outside alarm zone
   -> Shot -> WEAPON -> impact in alarm zone
   -> alarm without BLUE hit

E. several evidence channels for same attack
   -> exactly one deduplicated installation attack incident

F. owner-authored Guard patrol route
   -> repeated patrol without unacceptable pathfinding behavior

G. QRF Phase 1
   -> infantry GROUP + optional vehicle GROUP
   -> one logical response package
   -> no duplicate resource reservation or materialization

H. mounted QRF candidate
   -> OPSTRANSPORT embark / movement / disembark / engagement
   -> separate acceptance before production use
```

Die konkrete Qualitaet von `ShootingStart`-Targetdaten fuer die in OMW verwendeten DCS-Ground-AI-Waffen ist vor einem produktiven Vertrag in DCS nachzuweisen.

## 14. Implementierungsgrenze

Die technische Reihenfolge bleibt:

```text
MOOSE event / OPSZONE / WEAPON evidence
-> small OMW evidence adapter
-> one installation attack incident
-> local capability evaluation
-> existing MissionDemand / response orchestration for unmet need
-> MOOSE provider / AUFTRAG execution
```

Nicht zulaessig ohne separate MOOSE-Gap-Analyse und ausdrueckliche Projektinhaberfreigabe sind:

```text
parallel native world-object scanner
per-frame projectile scanner
second independent threat authority
hit-count gate before alarm activation
alarm-zone exit as automatic response completion
hard-coded provider asset where capability-based selection is required
unvalidated free-roaming Ground AI where an owner-authored route is available
```

`CampaignState` bleibt strategische Autoritaet. Der Installationsalarm ist operative Bedrohungs-/Response-Evidenz und keine neue Ressourcen- oder Bestandsautoritaet.

## 15. Architekturgrenze zur Base

`OMW_Ground_Base` bleibt Ground-Foundation und soll nicht zu einer monolithischen Alarm-/Response-Implementierung werden.

Verbindliche Trennung:

```text
OMW_Ground_Base
= Ground structure / registration / resources / physical foundation

Installation alarm / incident layer
= threat evidence / incident lifecycle

MissionDemand
= need / request / assignment

MOOSE operational layer
= BRIGADE / AIRWING / SQUADRON / PLATOON / LEGION / AUFTRAG / OPSGROUP execution

CampaignState
= strategic resource authority
```

Die Base darf Installation-/Ground-Kontexte, Registry-Daten und Adapterzugriffe bereitstellen oder initialisieren. Spezifische Alarm-, Incident-, Guard-, QRF-, CAS-, Fire-Support-, RECON-, MEDEVAC- oder Supply-Orchestrierung bleibt in getrennten Modulen beziehungsweise zuständigen Fachschichten.
