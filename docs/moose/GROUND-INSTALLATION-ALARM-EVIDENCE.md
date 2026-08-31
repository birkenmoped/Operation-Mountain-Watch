---
document_id: OMW-MOOSE-GROUND-INSTALLATION-ALARM-EVIDENCE
status: PLANNED
document_class: MOOSE_TECHNICAL_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE mechanisms for FOB/COP/OP attack evidence
  - Stage 3 Ground installation alarm sensor implementation scope
  - runtime acceptance requirements for proximity, direct-fire and indirect-fire evidence
not_authoritative_for:
  - DCS runtime validation
  - tactical battlespace geometry
  - CAS or fire-support mission completion criteria
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Ground Installation Alarm Evidence

## 1. Zweck und Governance-Grenze

Dieses Dokument beschreibt den MOOSE-first Technikpfad fuer die auf `main` verbindlich festgelegte Multi-Evidence-Alarmierung aller BLUE-FOBs, COPs und OPs.

Verbindliche fachliche Baseline:

- `OMW-GOV-001`, Abschnitt Ground-Alarm-/Triggerzonen-Regel;
- `OMW-ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE`.

Die Alarmzone bleibt ausschliesslich Sensor-/Triggergrenze:

```text
alarm zone
!= tactical battlespace
!= weapons engagement zone
!= fire-support target area
!= CAS engagement area
!= mission-end condition
```

## 2. Gepruefter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Source und offizielle Demo wurden fuer folgende Bausteine geprueft:

```text
OPSZONE
EVENTHANDLER
EVENTS.Hit
EVENTS.Shot
EVENTS.ShootingStart
EVENTS.ShootingEnd
WEAPON
ZONE
```

## 3. `OPSZONE` – Proximity-Evidenz

Der vorhandene OMW-Adapter `OMW_FobThreatOpsZoneAdapter.lua` nutzt `OPSZONE` fuer feindliche Ground-Praesenz innerhalb der Alarmzone. Der `Attacked`-FSM-Uebergang bleibt der MOOSE-first Sensor fuer:

```text
PROXIMITY_INTRUSION
```

Wichtig: `OPSZONE Defeated` beschreibt nur das Ende der feindlichen Praesenz innerhalb dieser Alarmgrenze. Der Zustand darf keinen laufenden QRF-, Fire-Support- oder CAS-Auftrag automatisch beenden.

Der gepinnte Source enthaelt zwar `OPSZONE:OnEventHit(...)` und prueft dort `self.HitsOn`. Im aktuellen Source Review wurde fuer `OPSZONE` jedoch kein belastbarer oeffentlicher Konfigurationsvertrag analog `ZONE_CAPTURE_COALITION:SetMonitorHits(...)` als Grundlage fuer OMW gefunden. Der produktive Multi-Evidence-Pfad verlaesst sich deshalb **nicht** auf ein mutmassliches OPSZONE-Hit-Monitoring.

## 4. `EVENTHANDLER` und MOOSE-Events

Der gepinnte Source stellt die benoetigten MOOSE-Ereignisse bereit:

```text
EVENTS.Hit
EVENTS.Shot
EVENTS.ShootingStart
EVENTS.ShootingEnd
```

OMW verwendet fuer neue Alarm-Evidenz `EVENTHANDLER:New()` und `HandleEvent(...)`. Ein paralleler nativer `world.addEventHandler()`-Sensor ist fuer diesen Scope nicht erforderlich und wird nicht eingefuehrt.

Geplante Domain-Korrelation:

```text
EVENTS.Hit
-> CONFIRMED_HIT_ATTACK

EVENTS.ShootingStart
-> DIRECT_FIRE_ATTACK
   wenn ein feindlicher Initiator belastbar auf einen BLUE-Verteidiger
   der Installation korreliert werden kann

EVENTS.Shot
-> direct projectile target evidence where reliable
OR
-> filtered WEAPON impact tracking
```

Die Qualitaet der DCS/MOOSE-Targetdaten bei `ShootingStart` und `Shot` fuer die konkreten OMW-Ground-AI-Waffen bleibt DCS-testpflichtig.

## 5. `WEAPON` – indirektes Feuer und Stand-off-Projektile

`WEAPON` kann aus dem DCS-Waffenobjekt eines MOOSE-`EVENTS.Shot` konstruiert werden. Source-verifiziert sind fuer OMW insbesondere:

```lua
WEAPON:New(eventdata.weapon)
WEAPON:GetTarget()
WEAPON:IsShell()
WEAPON:IsRocket()
WEAPON:IsMissile()
WEAPON:SetTimeStepTrack(seconds)
WEAPON:SetFuncImpact(callback, ...)
WEAPON:StartTrack(...)
WEAPON:GetImpactCoordinate()
```

MOOSE dokumentiert selbst, dass ein Weapon-Target fehlen, verloren gehen oder wechseln kann. `GetTarget()` ist daher nur positive Evidenz, niemals die alleinige Bedingung fuer Angriffserkennung.

Die offizielle MOOSE-Demo `Wrapper/Weapon/040-Track-Shell` demonstriert genau den fuer OMW relevanten Pfad:

```text
EVENTS.Shot
-> WEAPON
-> StartTrack
-> impact callback
-> GetImpactCoordinate
-> Zone:IsCoordinateInZone
```

Damit kann beispielsweise ein feindlicher Moerser-/Artillerieangriff einen Alarm ausloesen, obwohl weder eine RED-Einheit die Alarmzone betritt noch ein BLUE-Objekt getroffen wird.

## 6. Performance-Grenze

Der MOOSE-Default fuer `WEAPON:SetTimeStepTrack(...)` betraegt 0,01 s. Das entspricht bis zu 100 Tracking-Auswertungen je Sekunde und Geschoss.

Daher gilt fuer OMW verbindlich im Implementierungsscope:

```text
NO global track-every-shot behavior
```

Vor Impact-Tracking muessen billige Filter greifen. Die aktuelle Adapterfoundation verlangt deshalb explizit einen caller-supplied `shouldTrackWeapon(...)`-Filter. Ohne positiven Filter wird kein Impact-Tracking gestartet.

Direkte Target-Evidenz wird ohne zusaetzliches Impact-Tracking verarbeitet. Fuer gefiltertes Impact-Tracking setzt die Foundation einen groesseren, konfigurierbaren Zeitschritt; der konkrete produktive Wert bleibt DCS-/Performance-testpflichtig.

## 7. Aktuelle OMW-Adapterfoundation

Branch-local implementiert:

```text
scripts/ground/OMW_GroundInstallationAlarmEvidenceAdapter.lua
Schema: OMW-GROUND-INSTALLATION-ALARM-EVIDENCE-2
```

Der Adapter erzeugt ausschliesslich Evidenzobjekte:

```text
PROXIMITY_INTRUSION
DIRECT_FIRE_ATTACK
INDIRECT_FIRE_ATTACK
CONFIRMED_HIT_ATTACK
OTHER_CONFIRMED_ATTACK
```

Er besitzt ausdruecklich **nicht**:

```text
CampaignState authority
MissionDemand authority
response-dispatch authority
tactical-completion authority
```

Ein spaeterer Incident-/Orchestrierungsadapter muss mehrere Evidenzen desselben Angriffs auf genau einen aktiven Installation-Attack-Incident deduplizieren beziehungsweise diesen aktualisieren.

## 8. Unit-/CI-Nachweis

Branch-localer Contract-Test:

```text
tests/mission-demand/test_ground_installation_alarm_evidence_adapter.lua
```

Abgedeckt sind:

```text
OPSZONE-fed proximity evidence
ShootingStart direct-fire evidence
Hit evidence
Shot target evidence
wrong-coalition rejection
filtered shell impact tracking
impact-inside-zone evidence
tracking-filter rejection
MOOSE event registration/unregistration
```

Der MissionDemand-CI-Lauf fuer Branch-HEAD `701b20e6a4dae8e5a7dbfb4a65eabdc92df7fa92` ist erfolgreich. Das ist Syntax-/Contract-Evidenz, **kein DCS-Runtime-PASS**.

## 9. Erforderlicher DCS-Acceptance-Scope

Vor produktiver Uebernahme sind mindestens getrennt zu pruefen:

```text
A. RED betritt Alarmzone ohne zu feuern
   -> PROXIMITY_INTRUSION

B. RED Small Arms / MG feuert von ausserhalb
   -> brauchbare ShootingStart- oder Hit-Korrelation

C. RED RPG / Rocket feuert von ausserhalb
   -> Shot target evidence, wenn vorhanden
   OR gefilterter Impact-Nachweis

D. RED Moerser / Artillerie feuert von ausserhalb
   -> Shot -> WEAPON -> Impact in Alarmzone
   -> Alarm ohne BLUE-Hit

E. mehrere Evidenzquellen desselben Angriffs
   -> ein Incident, keine mehrfachen Response-Demands
```

Erst danach darf der jeweilige Runtime-Scope als `VALIDATED` dokumentiert werden.
