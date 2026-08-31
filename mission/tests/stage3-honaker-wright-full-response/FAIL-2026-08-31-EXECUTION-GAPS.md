---
document_id: OMW-STAGE3-HONAKER-WRIGHT-FAIL-2026-08-31-EXECUTION-GAPS
status: TEST_EVIDENCE
test_id: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: 05dbd538801f298a3eef084dd5d439e11e721ec3
builder_version: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-8
bundle_sha256: 101339C8A8C1EF0DCB806D8A0B4280C09A2C1EEB919A0F4D1E62F73A1B8BBD88
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs_version: 2.9.29.27278
validated_in_dcs: false
result: FAIL
---

# Stage 3 DCS FAIL – CAS allocation, QRF execution and rearm/resupply closure

## Teststand

Der dokumentierte Lauf vom 31.08.2026 verwendete den real lokal gebauten Stand:

```text
GitCommit: 05dbd538801f298a3eef084dd5d439e11e721ec3
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-8
Bundle SHA256: 101339C8A8C1EF0DCB806D8A0B4280C09A2C1EEB919A0F4D1E62F73A1B8BBD88
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.29.27278
```

Primäre Runtime-Evidenz:

```text
dcs(20260831-204642).log
debrief(20260831-204642).log
```

## Ergebnisübersicht

```text
Alarm / OPSZONE Attacked                         PASS
Attack-Incident-Erzeugung                        PASS
ARTY wiederholtes Live-Retargeting               PASS
OPSZONE Defeated beendet Response nicht mehr     PASS

QRF-Anforderung                                  PASS
QRF physische Materialisierung                   vom Besitzer visuell beobachtet
QRF nachgewiesener taktischer Kontakt            FAIL / nicht nachgewiesen
QRF Lifecycle nach Materialisierung              UNRESOLVED

CAS MissionDemand                                PASS
CASENHANCED AUFTRAG-Erzeugung / Queue            PASS
AH-64 physische Zuteilung / Start                FAIL

lokaler M1083-Rearm-Request                      PASS
M1083 physische Materialisierung                 FAIL / nicht nachgewiesen
ARTY-Rearm                                       FAIL / nicht nachgewiesen
CampaignState Wright 16 -> 15                    FAIL / nicht nachgewiesen
strategischer RESUPPLY-Demand                    FAIL / nicht nachgewiesen
CH-47 / Slingload                                FAIL / nicht ausgelöst
```

## 1. CAS – bestätigte Capability-Lücke

Der Stage-3-Harness erzeugte erfolgreich einen `AUFTRAG:NewCASENHANCED` für Honaker. Die Jalalabad-AH-64-SQUADRON und ihr Payload waren im zu diesem DCS-Lauf geladenen Bootstrap jedoch ausschließlich für `AUFTRAG.Type.CAS` registriert.

Damit bestand eine gültige CASENHANCED-Mission, aber kein passender AH-64-Cohort/Payload für die AIRWING-Auswahl.

Korrektur nach dem FAIL:

```lua
missionTypes = {
  AUFTRAG.Type.CAS,
  AUFTRAG.Type.CASENHANCED,
}
```

Dies gilt sowohl für die SQUADRON-MissionCapability als auch für den zugehörigen AIRWING-Payload. Der physische Mission-Editor-Seed bleibt unverändert.

Wichtig für den nächsten DCS-Test: Diese Änderung liegt im Jalalabad-AirOps-Bootstrap und ist nicht Bestandteil des Stage-3-Einzelbundles. Deshalb müssen vor dem Test sowohl das Jalalabad-AirOps-Bundle als auch das Stage-3-Bundle neu gebaut und im Mission Editor neu geladen werden.

## 2. Lokaler M1083-Rearm – fehlender gestarteter BRIGADE-Lifecycle

Der Log erreichte nach drei physisch bestätigten Feueraufträgen:

```text
Wright live fire cycle ended after 3 coordinate missions; total physical ammo 300 -> 288; local M1083 rearm requested
[OMW][Ground.SupportMaterializer] requested template=TPL_BLUE_GND_SUP_M1083 assignment=OMW:WRIGHT:AMMO-SUPPORT:STAGE3-E2E
```

Danach fehlte jede Materialisierungs-, Rearm- oder CampaignState-Evidenz.

Die Codeprüfung ergab, dass Stage 3 einen dedizierten MOOSE-`BRIGADE` für den Wright-Rearm erzeugte und darin PLATOON/Materializer registrierte, diesen dedizierten BRIGADE-Lifecycle aber nicht startete. Die Self-Request-Grenze konnte damit erreicht werden, ohne dass ein laufender MOOSE-Warehouse/BRIGADE-Lifecycle den M1083 materialisierte.

Korrektur nach dem FAIL:

```text
FixedFireSupportAmmoSupport.New()
-> SetSpawnZone
-> Materializer/PLATOON vollständig registrieren
-> BRIGADE:Start()
-> erst später Self-Request zulassen
```

Die strategische Kette bleibt unverändert und darf erst nach realem Rearm fortschreiten:

```text
M1083 materialisiert
-> reale ARTY-Rearm-Evidenz
-> CampaignState Wright 16 -> 15
-> Reorder
-> genau ein RESUPPLY-Demand
-> Jalalabad CH-47 CARGOTRANSPORT / Slingload
```

## 3. QRF – noch keine belastbare Root Cause

Der Log bestätigt die QRF-Anforderung und der Projektinhaber beobachtete ein physisches QRF-Team. Ein tatsächliches `EngageTarget`-Ereignis beziehungsweise taktischer Kontakt ist für den Lauf jedoch nicht belegt. Der beobachtete spätere Despawn darf deshalb nicht ohne weitere Evidenz einem bestimmten MOOSE-Callback oder Missionsabschluss zugeschrieben werden.

Der aktuell verwendete Auftrag ist `AUFTRAG:NewGROUNDATTACK(Target, ...)`. Der gepinnte MOOSE-Quellcode beschreibt diesen Auftrag ausdrücklich als Workaround: Die Ground Group wird in die Nähe des konkreten Zielobjekts geführt und greift erst nach eigener DCS-Erkennung an. Der Auftrag ist damit an ein einzelnes Zielobjekt gekoppelt. Parallel laufende ARTY kann dieses Ziel vor dem QRF-Kontakt neutralisieren.

Vor einer produktiven Änderung wird der QRF-Pfad deshalb separat gegen die gepinnte MOOSE-Implementierung weiter geprüft. Eine nicht nachgewiesene Despawn-Ursache wird nicht als behoben dokumentiert.

## 4. Acceptance-Folge

Build `1-8` ist `FAIL` und nicht `VALIDATED`.

Der nächste DCS-Lauf muss mindestens nachweisen:

```text
AH-64D wird für CASENHANCED wirklich aus Jalalabad zugeteilt und startet
M1083 wird über den gestarteten dedizierten BRIGADE/Warehouse-Lifecycle materialisiert
ARTY wird real rearmladen
CampaignState Wright sinkt exakt 16 -> 15
strategischer RESUPPLY wird exakt einmal erzeugt
CH-47 + physischer Slingload werden ausgelöst
QRF bleibt bis zu einer nachvollziehbaren taktischen/Lifecycle-Entscheidung beobachtbar
```

Keine dieser nach dem FAIL vorgenommenen Änderungen ist vor einem neuen dokumentierten DCS-Lauf als `VALIDATED` zu bezeichnen.
