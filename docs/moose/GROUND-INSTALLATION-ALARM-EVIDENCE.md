---
document_id: OMW-MOOSE-GROUND-INSTALLATION-ALARM-EVIDENCE
status: PLANNED
document_class: MOOSE_TECHNICAL_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE mechanisms for installation attack evidence
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

Dieses Dokument beschreibt den MOOSE-first Technikpfad fuer die projektweit verbindliche Multi-Evidence-Alarmierung missionsrelevanter BLUE-Installationen. Die aktuelle Stage-3-Implementierung verwendet Honaker als Ground-Acceptance-Fall; die Alarmsemantik selbst ist nicht auf Honaker oder ARMY beschraenkt.

Verbindliche fachliche Baseline:

- `OMW-GOV-001`, Abschnitt Installation-Alarm-/Triggerzonen-Regel;
- `OMW-ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE` beziehungsweise dessen auf `main` generalisierte Installationssemantik.

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
OPSZONE:OnAfterEvaluated(...)
OPSZONE:GetScannedGroupSet()
EVENTHANDLER
EVENTS.Hit
EVENTS.Shot
EVENTS.ShootingStart
EVENTS.ShootingEnd
WEAPON
ZONE
```

## 3. `OPSZONE` – Proximity-Evidenz und Alarmbild

Der vorhandene OMW-Adapter `OMW_FobThreatOpsZoneAdapter.lua` nutzt `OPSZONE` fuer feindliche Ground-Praesenz innerhalb der Alarmzone. Der `Attacked`-FSM-Uebergang bleibt der MOOSE-first Sensor fuer:

```text
PROXIMITY_INTRUSION
```

Der gepinnte Source definiert ausserdem den FSM-Uebergang:

```text
* -> Evaluated -> *
```

und ruft `self:Evaluated()` am Ende jeder normalen `OPSZONE`-Auswertung auf. Der oeffentliche Callback-Vertrag lautet:

```lua
OPSZONE:OnAfterEvaluated(From, Event, To)
```

Der aktuelle OMW-Adapter exponiert diesen Callback ab Schema `OMW-FOB-THREAT-OPSZONE-ADAPTER-3` als `onThreatEvaluated(...)` und uebergibt dabei `OPSZONE:GetScannedGroupSet()`. Damit kann die bestehende MOOSE-Auswertung neue Angreifer in einen bereits laufenden Installation-Attack-Incident uebernehmen, ohne einen zweiten Welt- oder Frame-Scanner einzufuehren.

Verbindliche Semantik fuer Stage 3:

```text
OPSZONE current scan
-> alarm/proximity picture
-> newly observed hostile groups may be added to active attack incident

hostile group later leaves alarm zone
-> group may remain a known participant of the active incident
-> leaving the alarm zone does not itself end ARTY/CAS/QRF
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
scripts/ground/OMW_GroundInstallationAttackIncident.lua
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
```

Relevante Schemas:

```text
OMW-GROUND-INSTALLATION-ALARM-EVIDENCE-2
OMW-GROUND-INSTALLATION-ATTACK-INCIDENT-1
OMW-FOB-THREAT-OPSZONE-ADAPTER-3
```

Der Evidence-Adapter erzeugt ausschliesslich Evidenzobjekte:

```text
PROXIMITY_INTRUSION
DIRECT_FIRE_ATTACK
INDIRECT_FIRE_ATTACK
CONFIRMED_HIT_ATTACK
OTHER_CONFIRMED_ATTACK
```

Der Incident-Koordinator fasst mehrere Evidenzen eines laufenden Angriffs in genau einem aktiven Incident zusammen und kann bekannte Angreifergruppen als Teilnehmer halten. Verlassene Alarmzonen entfernen eine bekannte Gruppe nicht automatisch aus diesem Incident; `GetParticipants(true)` filtert erst nach realem `IsAlive()`-Status.

Diese Schichten besitzen ausdruecklich **nicht**:

```text
CampaignState authority
MissionDemand authority
response-dispatch authority
```

Die taktische Completion bleibt auftragsspezifisch. Insbesondere darf `OPSZONE Defeated` nicht als generische Incident-, Fire-Support- oder CAS-Completion verwendet werden.

## 8. Unit-/CI-Nachweis

Branch-lokale Contract-Tests:

```text
tests/mission-demand/test_ground_installation_alarm_evidence_adapter.lua
tests/mission-demand/test_ground_installation_attack_incident.lua
tests/mission-demand/test_fob_threat_opszone_adapter.lua
```

Abgedeckt sind unter anderem:

```text
OPSZONE-fed proximity evidence
OPSZONE OnAfterEvaluated callback exposure
current scanned-group-set handoff without second scanner
ShootingStart direct-fire evidence
Hit evidence
Shot target evidence
wrong-coalition rejection
filtered shell impact tracking
impact-inside-zone evidence
tracking-filter rejection
MOOSE event registration/unregistration
multiple evidence items -> one active incident
participant dedupe
alive-participant filtering
explicit incident closure
```

CI-Evidenz ist Syntax-/Contract-Evidenz, **kein DCS-Runtime-PASS**. Der jeweils aktuelle Branch-HEAD und die zugehoerigen Workflow-Runs sind vor DCS-Staging neu zu dokumentieren.

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

F. RED-Gruppe wird waehrend laufendem Incident durch OPSZONE-Auswertung erkannt,
   verlaesst danach die Alarmzone und bleibt lebender Incident-Teilnehmer
   -> ARTY/CAS darf nicht allein wegen OPSZONE Defeated abbrechen
```

Erst danach darf der jeweilige Runtime-Scope als `VALIDATED` dokumentiert werden.
