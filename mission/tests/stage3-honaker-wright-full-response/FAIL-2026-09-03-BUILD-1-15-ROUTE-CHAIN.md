---
document_id: OMW-STAGE3-BUILD-1-15-ROUTE-CHAIN-FAIL
status: FAILED_DCS_ACCEPTANCE
document_class: ACCEPTANCE_FAILURE_EVIDENCE
owning_policy: OMW-GOV-001
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: 739daed6e22ea7bb02b677fe6b06b716c624fd7c
validated_in_dcs: false
---

# Stage 3 Build 1-15 – Routing-/Lifecycle-Fail vom 03.09.2026

## 1. Exakte Testprovenienz

```text
GitCommit:
739daed6e22ea7bb02b677fe6b06b716c624fd7c

BuilderVersion:
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-15

MOOSECommit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

MooseLuaSHA256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

BundleSHA256:
696E4021C36676DF3DAF14CFD909322015E3A3A166B3F1BDA860430573130992

DCS:
2.9.29.27468

Mission:
OMW_Template_v21_GroundWorks.miz
```

Der Build wurde lokal reproduzierbar erzeugt; Builder-Hash und unabhängiger `Get-FileHash` waren identisch. Das nachfolgende DCS-Verhalten ist dennoch ein Acceptance-Fail.

## 2. CAS – beobachteter Fail

Positiv:

```text
Jalalabad
-> gemeinsamer Korridor
-> WEST
-> Honaker AO
-> reale Waffenwirkung
```

Der initiale Transfer zum Einsatzraum war damit gegenüber Build 1-13 korrigiert.

Negativ:

- Nach Vernichtung der für den Angriff relevanten RED-Gruppen blieb der PATROLZONE-CAS-Auftrag aktiv.
- Die AH-64 flogen weiter große Schleifen über dem AO.
- Die vorgesehene Recovery-Kette `WEST reverse -> R500 reverse -> Jalalabad` wurde nicht freigegeben.
- Erst Low-/Bingo-Fuel führte zu einem separaten RTB-Verhalten.
- Dieses RTB führte direkt Richtung Jalalabad und nicht über den freigehaltenen Talkorridor.
- Beide AH-64 verloren vor Jalalabad den Treibstoff und gingen verloren.

Der Fehler ist source-seitig nachvollziehbar: Build 1-15 verlangte zusätzlich zur Vernichtung aller bekannten Incident-Participants noch `0` aktive RED Ground Groups in einer künstlichen 5-NM-Taktikzone. Diese zweite Bedingung hielt CAS und QRF unnötig offen.

### Korrekturentscheidung

Für Stage 3 ist künftig allein der konkrete Angriffs-Incident maßgeblich:

```text
response complete when:
zero living known attack-incident participants
```

Die breitere 5-NM-RED-Zählung darf weiter als Diagnose dienen, ist aber keine Abschlussbedingung.

## 3. CH-47 / Air-AMMO – beobachteter Fail

Positiv:

- CH-47 wurde durch den MOOSE AIRWING/AUFTRAG-Lifecycle disponiert.
- Der physische Slingload wurde aufgenommen.
- Der Slingload wurde physisch bei Wright abgeliefert.
- Die strategische Lieferung wurde erfolgreich abgeschlossen.

Negativ:

- Hinflug erfolgte nicht über den vorgesehenen R500-Korridor.
- Rückflug erfolgte nicht über den vorgesehenen R500-Korridor.
- Die Außenlast wurde außerhalb des gewünschten Jalalabad-Slingload-Bereichs materialisiert.

### Ursache der falschen Pickup-Position

Build 1-15 verwendete:

```lua
local PICKUP_ZONE = "OMW_LOG_NODE_JALALABAD"
```

und zusätzlich:

```lua
:InitValidateAndRepositionStatic(true,120)
```

`OMW_LOG_NODE_JALALABAD` ist ein allgemeiner Logistikanker und keine dedizierte Slingload-Staging-Fläche. Außerdem durfte die Static-Repositionierung die resultierende Lage zusätzlich verschieben.

Der Mission Owner hat deshalb eine getrennte physische Logistikzonierung eingeführt:

```text
ZON_BLUE_LOG_SLG_<LOCATION>_01   Slingload
ZON_BLUE_LOG_ACG_<LOCATION>_01   normale Air Cargo
```

Für Jalalabad lautet der neue Stage-3-Pickup-Anker:

```text
ZON_BLUE_LOG_SLG_JALALABAD_01
```

## 4. Guard / QRF – beobachteter Fail

### Guard

Die Guard-Infanterie wurde innerhalb des COP Honaker materialisiert und hatte sichtbar Schwierigkeiten, das umbaute Lager zu verlassen.

Der Mission Owner hat als korrekten physischen Materialisierungsbereich festgelegt:

```text
ZON_BLUE_GND_HONAKER_ACCESS
```

Die Guard soll dort straßennah entstehen und anschließend auf `OMW_RTE_BLUE_GUARD_HONAKER_01` übergehen.

### QRF

Der Mission Owner sah die QRF im DCS-Lauf nicht. Der Runtime-Log belegt jedoch die MOOSE-Materialisierung der gemischten QRF-Gruppe. Deshalb wird der Befund nicht als „QRF nicht erzeugt“, sondern als physischer Spawn-/Access-/Sichtbarkeitsfehler behandelt.

Die gleiche Access-Zone wird deshalb auch für die QRF-Materialisierung verwendet.

## 5. Konsequenz für Build 1-16

Build 1-15 wird nicht weiter gepatcht. Die Routingarchitektur wird auf eine einfache, einmalig erzeugte MOOSE-Wegpunkt-/Task-Sequenz reduziert:

```text
CAS:
Start
-> R500
-> WEST
-> PATROLZONE/CAS task
-> WEST reverse
-> R500 reverse
-> Jalalabad

CH-47:
MOOSE physical pickup
-> one-shot R500 outbound chain
-> CargoTransportation delivery task at Wright exit
-> one-shot R500 reverse chain
-> Jalalabad
```

Insbesondere entfällt beim CAS die dauerhafte `OnAfterUpdateRoute`-Überwachung und wiederholte Korridor-Reinstallation.

## 6. Acceptance-Matrix Build 1-15

| Bereich | Ergebnis |
|---|---|
| CAS Initialroute Jalalabad -> R500/WEST -> AO | PASS beobachtet |
| CAS reale Waffenwirkung | PASS beobachtet |
| CAS Abschluss nach relevanten Angreifern | FAIL |
| CAS WEST/R500 Recovery | FAIL |
| CAS sichere Jalalabad-Rückkehr | FAIL |
| CH-47 physischer Slingload-Pickup | PASS beobachtet |
| CH-47 physische Wright-Lieferung | PASS beobachtet |
| CH-47 R500 outbound | FAIL |
| CH-47 R500 return | FAIL |
| Slingload Pickup-Position Jalalabad | FAIL |
| Guard physischer Spawn | FAIL |
| QRF MOOSE-Materialisierung | PASS laut Runtime-Log |
| QRF sinnvoller physischer Access | NICHT bestätigt |
| Stage-3 Gesamtacceptance | FAIL |

Build 1-15 bleibt damit `FAILED_DCS_ACCEPTANCE` und darf nicht als produktiv validierter Lifecycle referenziert werden.
