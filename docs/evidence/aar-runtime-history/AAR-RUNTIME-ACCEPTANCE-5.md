---
document_id: OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-5
status: HISTORICAL_TEST_FIXTURE
document_class: TECHNICAL_ACCEPTANCE_REPORT
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-run Acceptance-5 AAR runtime evidence
  - Nelson northern ingress/egress gate candidate based on EGPAN approach
  - post-refuel dwell correction before accelerated FuelLow
  - repeat proof of owner-run AI Boom path after Acceptance-4
not_authoritative_for:
  - final production AAR gate set outside the tested Nelson/Clancy scope
  - complete FAST/SLOW dual-tanker production matrix
  - production MissionDemand/CampaignState activation logic
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-4
superseded_by:
  - OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-6
source_branch: agent/aar-rc-east-runtime-scope
source_commit: 6d4d326ab7b05f63fe8ac458e108d2dc6aea089a
validated_in_dcs: partial
---

# AAR Runtime Acceptance-5 – EGPAN Gate + Post-Refuel-Dwell

## 1. Anlass

Acceptance-4 bestätigte den MOOSE-/DCS-AAR-Kernpfad einschließlich Y-Band-TACAN, Bagram-F-16-AIRWING-Recruiting, visueller Boom-Nutzung beider F-16 und plausibler Fuel-Zunahme. Zwei Acceptance-Punkte blieben zu korrigieren:

1. Der Nelson-Gate-Kandidat lag noch deutlich innerhalb des nordöstlichen Afghanistan-Zipfels.
2. Der künstliche 99-%-FuelLow-Trigger wurde unmittelbar nach dem ersten `OnAfterRefueled`-Event aktiviert und konnte dadurch den zweiten Receiver unnötig unter Zeitdruck setzen.

Acceptance-5 korrigierte beide Punkte und wurde am 14.08.2026 in DCS praktisch geprüft.

## 2. Testprovenienz

```text
Branch: agent/aar-rc-east-runtime-scope
Source commit: 6d4d326ab7b05f63fe8ac458e108d2dc6aea089a
BuilderVersion: AAR-KC135-RUNTIME-ACCEPTANCE-5
Source SHA-256: 408adb70179c66c42cea03b1839a8f5a14a02abf83a15f338d8319f56b3b4da8
Builder SHA-256: 917f71a181fb904038e8644b98d2704ba758b249e019e1820b8235919fda0f57
Bundle SHA-256: 5daeae8c0ae04a1c6165a603f4e0124d9003e6b2ef757f447fffbb5353f37a95
MIZ: OMW_Template_v8_AirOps_rdy(20260814-172100).miz
MIZ SHA-256: ac94909ffe85b1711aa82f38f7c78bdad491e6d6fc7508727c29567d5adc48af
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Embedded Acceptance bundle SHA-256: 5daeae8c0ae04a1c6165a603f4e0124d9003e6b2ef757f447fffbb5353f37a95
```

Die `.miz` enthielt damit exakt den lokal gebauten Acceptance-5-Bundle-Stand und den gepinnten MOOSE-Stand.

## 3. Nelson-EGPAN-Ingress

Historisch/geografisch dokumentierter Bezugsrahmen:

```text
Northern KC-135 origin model: MANAS / Kyrgyzstan
Transit region: Tajikistan
Kabul FIR entry reference: EGPAN
EGPAN: N38°25'00" E070°44'00"
High airway reference: M881
Low airway reference: V876
```

Acceptance-5 verwendete als Materialisierungs-/Handoff-Punkt ungefähr 50 km NNE von EGPAN:

```text
NELSON gate:
N38.83163
E70.95271

Approximate relation:
~50 km NNE of EGPAN
```

Runtime-Log:

```text
TANKER_START_PASS area=NELSON
 gateDomain=NORTH_EGPAN
 gateLat=38.83163000
 gateLon=70.95271000
 spawnHeadingDeg=173.889
 speedKt=300
 radioMHz=384.400
 tacan=47Y
 ident=NEL
```

Owner-Beobachtung:

```text
PASS
Der Tanker materialisierte außerhalb des sichtbaren Bereichs.
Der Screenshot zeigt Texaco 1-1 erst nach dem Einflug in den sichtbaren Kartenbereich.
Der neue nördliche Gate-Punkt wurde visuell als geeignet bewertet.
```

Damit ist der Acceptance-5-Nelson-Gatepunkt für den exakt getesteten Missions-/DCS-/MOOSE-Stand praktisch bestätigt. Eine pauschale Aussage über andere nördliche AAR-Areas wird daraus nicht abgeleitet.

## 4. Runtime-Konfiguration

```text
CLANCY / Shell 1
Gate: N28.90264890 E64.61166667
Track: N31.75441342 E66.82695501
Orbit: FL225 / 220 KIAS
Radio: 241.600 AM
TACAN: 60Y / CLA

NELSON / Texaco 1
Gate: N38.83163 E70.95271
Track: N36.37666667 E71.01833333
Orbit: FL275 / 300 KIAS
Radio: 384.400 AM
TACAN: 47Y / NEL
```

Der Spawn-Heading wurde weiterhin mit `COORDINATE:HeadingTo()` berechnet und mit `SPAWN:InitHeading()` gesetzt.

Die Y-Band-TACAN-Konfiguration wurde bereits unmittelbar vor Acceptance-5 in Acceptance-4 praktisch im F-16-Cockpit bestätigt:

```text
60Y / CLA: PASS
47Y / NEL: PASS
```

Acceptance-5 änderte diesen Beacon-Pfad nicht; ein erneuter Cockpit-TACAN-Test war in diesem Lauf nicht erforderlich und wird nicht als neue separate Messung behauptet.

## 5. AI-Boom und Post-Refuel-Dwell

Der bestehende Bagram-Pfad blieb unverändert:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Der test-only Missionsreichweiten-Override blieb:

```lua
mission:SetMissionRange(250)
```

Runtime-Befund:

```text
AI_BOOM_REFUELED_PASS
 group=SQ_US_BGRM_F16C_121_EFS_AID-7
 fuelBeforePct=82.93
 fuelAfterPct=99.96
 postRefuelDwellSec=60
```

Owner-Beobachtung bestätigte erneut die physische Boom-Nutzung der F-16. Der Fuel-Readback zeigt zusätzlich eine plausible positive Fuel-Zunahme.

Acceptance-5 trennte den ersten dokumentierten Refuel-Abschluss vom künstlichen FuelLow-Test:

```text
AI_BOOM_REFUELED_PASS
-> post-refuel dwell
-> POST_REFUEL_DWELL_PASS
-> accelerated FuelLow threshold = 99%
-> FuelLow -> Cancel -> Egress
```

Gemessener Runtime-Befund:

```text
POST_REFUEL_DWELL_PASS elapsedSec=74.9 requiredSec=60
ACCELERATED_FUEL_LOW_ARMED thresholdPct=99 afterAiBoomRefueled=true postRefuelDwellSec=60
```

Die 74,9 Sekunden liegen über der geforderten Mindestdauer. Die Abweichung oberhalb 60 Sekunden entsteht durch die diskrete Scheduler-Auswertung und ist für dieses Acceptance-Kriterium unkritisch. Die 60 Sekunden bleiben ausschließlich ein Acceptance-Testwert und sind keine produktive Tanker-Abbruchregel.

## 6. FuelLow, Egress und Off-map-Handoff

Nach dem Dwell wurde der beschleunigte FuelLow-Pfad ausgelöst:

```text
FUEL_LOW_PASS area=CLANCY fuelPct=75.86 thresholdPct=99 action=CANCEL_TO_EGRESS
FUEL_LOW_PASS area=NELSON fuelPct=81.89 thresholdPct=99 action=CANCEL_TO_EGRESS
```

Beide Tanker erreichten anschließend ihre Handoff-Gates innerhalb des 10-NM-Kriteriums:

```text
NELSON:
EGRESS_GATE_PASS distanceGateNm=9.53 fuelPct=78.45 action=DESPAWN_OFFMAP_HANDOFF

CLANCY:
EGRESS_GATE_PASS distanceGateNm=8.97 fuelPct=70.66 action=DESPAWN_OFFMAP_HANDOFF
```

Die zugehörigen MOOSE-AUFTRAG-Missionen wurden danach als erfolgreich abgeschlossen geführt.

## 7. Acceptance-Ergebnis

```text
Nelson spawn at N38.83163 E70.95271:
PASS

Nelson spawn outside normal visible area:
VISUAL PASS

Nelson gate-to-track initial heading:
PASS

No observed map-edge/terrain/routing blocker:
PASS

Clancy 60Y / CLA:
PASS from immediately preceding Acceptance-4 cockpit test; unchanged in Acceptance-5

Nelson 47Y / NEL:
PASS from immediately preceding Acceptance-4 cockpit test; unchanged in Acceptance-5

Bagram F-16 AIRWING recruiting:
PASS

AI Boom refuel:
PASS

Fuel increase:
82.93 % -> 99.96 %
PASS

Post-refuel minimum dwell >= 60 s:
74.9 s
PASS

Clancy FuelLow -> Cancel -> Egress:
PASS

Nelson FuelLow -> Cancel -> Egress:
PASS

Clancy off-map handoff gate <= 10 NM:
8.97 NM
PASS

Nelson off-map handoff gate <= 10 NM:
9.53 NM
PASS
```

Acceptance-5 bleibt als `HISTORICAL_TEST_FIXTURE` mit dokumentiertem PASS-with-limitations-Ergebnis erhalten. Seine Runtime-Evidenz gilt nur für den exakt dokumentierten Branch-/Commit-/Missions-/DCS-/MOOSE-Stand und wird durch spätere produktive AAR-Entscheidungen nicht automatisch verallgemeinert.

## 8. Grenzen und offene Folgearbeit

Acceptance-5 validiert weiterhin **nicht**:

```text
- A-10 als tatsächlichen SLOW-Receiver
- zwei Tanker gleichzeitig in derselben AAR-Area mit >=3000 ft Staffelung
- automatische A-10 -> SLOW / F-16 -> FAST Auswahl
- vollständige receiverbezogene Produktions-Speed-/Altitude-Matrix
- produktive MissionDemand-/CampaignState-Aktivierungslogik
```

Diese Punkte waren zum Zeitpunkt von Acceptance-5 die nächste AAR-Folgearbeit. Spätere Acceptance- und Produktionsdokumente sind für den aktuellen Stand maßgeblich.
