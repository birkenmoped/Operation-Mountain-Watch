---
document_id: OMW-ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE
status: BINDING_PROJECT_DECISION
document_class: GROUND_ALARM_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - project-wide FOB/COP/OP installation alarm evidence semantics
  - OR-combination of valid attack indicators
  - separation of alarm evidence from tactical battlespace and response completion
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - any interpretation that hostile entry into an installation alarm zone is the sole attack trigger
  - any interpretation that multiple confirmed hits are required before an installation alarm may activate
superseded_by:
source_branch: agent/ground-installation-alarm-multi-evidence
source_commit: 81bbb6744192661bf6d7b7b6bc4760f377e124c8
validated_in_dcs: false
---

# ARMY Ground – Verbindliche Multi-Evidence-Alarmregel fuer FOBs, COPs und OPs

## 1. Projektentscheidung

Fuer die gesamte BLUE-Ground-Organisation von Operation Mountain Watch gilt fuer **alle FOBs, COPs und OPs** ein OR-basiertes Alarmmodell.

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

## 2. Verbindliche Evidenzklassen

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

## 3. Alarmzone ist kein Kampfgebiet

Die bereits auf `main` in `OMW-GOV-001` festgelegte Trennung bleibt unveraendert verbindlich:

```text
FOB / COP / OP alarm zone
= threat-detection and response-trigger boundary
!= tactical battlespace
!= weapons engagement zone
!= fire-support target area
!= CAS engagement area
!= mission-end condition
```

Ein Gegner kann den Alarm daher auch von ausserhalb der Zone ausloesen. Ebenso beendet das Verlassen oder Freikaempfen der Alarmzone einen bereits ausgeloesten QRF-, Fire-Support-, CAS- oder sonstigen Response-Auftrag nicht automatisch.

## 4. Ein Angriff, mehrere Evidenzen, ein Incident

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

## 5. MOOSE-first Source Review

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

## 6. Offizielle MOOSE-Demo-Evidenz

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

## 7. Noch nicht DCS-validierte Punkte

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
```

Die konkrete Qualitaet von `ShootingStart`-Targetdaten fuer die in OMW verwendeten DCS-Ground-AI-Waffen ist vor einem produktiven Vertrag in DCS nachzuweisen.

## 8. Implementierungsgrenze

Die technische Reihenfolge bleibt:

```text
MOOSE event / OPSZONE / WEAPON evidence
-> small OMW evidence adapter
-> one installation attack incident
-> existing MissionDemand / response orchestration
```

Nicht zulaessig ohne separate MOOSE-Gap-Analyse und ausdrueckliche Projektinhaberfreigabe sind:

```text
parallel native world-object scanner
per-frame projectile scanner
second independent threat authority
hit-count gate before alarm activation
alarm-zone exit as automatic response completion
```

`CampaignState` bleibt strategische Autoritaet. Der Installationsalarm ist operative Bedrohungs-/Response-Evidenz und keine neue Ressourcen- oder Bestandsautoritaet.
