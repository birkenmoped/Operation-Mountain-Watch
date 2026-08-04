---
document_id: OMW-TEST-GOVERNANCE
status: BINDING
document_class: TEST_GOVERNANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - mandatory repository rules for all mission test packages
  - AirOps lifecycle, observer-client and MIZ invalidation guards
  - static release gate before DCS execution
not_authoritative_for:
  - project-wide ORBAT
  - airfield-specific object contracts
  - merge or Ready-for-Review authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - informal references to a missing mission/tests/GOVERNANCE.md
superseded_by:
source_branch: agent/consolidate-air-ops-lifecycle-governance
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Governance für Missions- und Runtime-Tests

## 1. Verbindliche Quellen

Jeder Testarbeitsgang beginnt mit:

```text
docs/00-project-governance.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/26-moose-first-development-policy.md
docs/moose/VERSION-AND-SOURCES.md
docs/moose/AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md
mission/tests/GOVERNANCE.md
```

Zusätzlich gelten das zuständige Manifest, aktuelle Ergebnisberichte, Handoffs und der exakte MOOSE-Quellstand.

## 2. Stop-Regeln

Kein DCS-Lauf wird gestartet, wenn einer der folgenden Punkte offen ist:

- Branch, Commit oder Basisbranch unbekannt;
- Builder-Version oder Bundle-Hash unbekannt;
- MIZ-Hash oder eingebetteter Bundle-Hash unbekannt;
- MOOSE-Commit beziehungsweise `Moose.lua`-Hash nicht bestätigt;
- Objektvertrag nach dem letzten MIZ-Speichern nicht erneut geprüft;
- Acceptance-Dokument nicht auf dem aktuellen Teststand;
- bekannter früherer Fehler ist nur kommentiert, aber nicht durch Guard oder Assertion blockiert;
- Test vermischt mehrere nicht eindeutig attributierbare Dispatchpfade;
- der zentrale Lifecycle-Guard ist nicht bestanden.

## 3. MIZ-Invalidierung

Jedes Speichern, Neuverpacken, Ersetzen oder Übertragen einer `.miz` erzeugt ein neues Artefakt und invalidiert die Übertragbarkeit des früheren Struktur-PASS.

Vor dem nächsten Gate werden neu dokumentiert:

```text
MIZ-SHA-256
interner mission-SHA-256
eingebetteter Bundle-SHA-256
eingebetteter Moose.lua-SHA-256
Objektvertragssmoke
```

## 4. AIRWING-/SQUADRON-Lifecycle

Vor `AIRWING:Start()`:

```text
SQUADRON-Konfiguration prüfen
airwing.cohorts prüfen
airwing.stock prüfen
Payloads und Capabilities prüfen
squadron.assets nur als deferred/leer protokollieren
```

Nach `AIRWING:Start()` und abgeschlossener Initialisierung:

```text
AIRWING Running prüfen
squadron.assets == Ngroups prüfen
Asset.cohort, Asset.legion und Asset.squadname prüfen
asset.parkingIDs prüfen, sofern Parking im Scope liegt
Idle-Queues und OPSGROUP-Zahl prüfen
```

Verboten ist eine positive Sollbestandsprüfung von `squadron.assets` vor dem Startpfad.

## 5. Helikopter-Vertikaloption

Für AIRWING-gemanagte Helikopter:

```lua
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

Ein gesetzter Schalter ist nur Konfigurationsnachweis. Tatsächlicher vertikaler Abflug wird erst in einem nativen AIRWING-/AUFTRAG-Dispatch visuell und telemetrisch akzeptiert.

## 6. COMMANDER

Verbindliche Sequenz:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:CanMission()
COMMANDER:AddMission()
COMMANDER:Status()
```

`AddAirwing()` ersetzt `Start()` nicht.

## 7. Observer-Client

Ein Beobachter-Client darf zugelassen werden, wenn seine Position hart vom KI-Parking ausgeschlossen ist und das Gate funktional nicht beeinflusst wird.

Pflichtfelder:

```text
observerClientsDetected
observerClientsAllowed
observerClientsBlocking
observerClientUnits
```

Der Detektionswert darf nicht auf null maskiert werden. Ein zulässiger Beobachter bedeutet `detected > 0`, `allowed > 0`, `blocking = 0`.

## 8. Builder-Guard

AirOps-Builder rufen vor Bundle-Erzeugung auf:

```powershell
& "$repoRoot\tools\Test-AirOpsLifecycleGuards.ps1" `
    -SourceFile $sourceFile `
    -RequirePostStartAssetValidation `
    -RequireVerticalPolicyBeforeStart
```

Der Guard blockiert mindestens:

- vorzeitige SQUADRON-Asset-Sollbestandsfehler;
- vorzeitige Prüfung geerbter `asset.parkingIDs`;
- Vertikaloption nach `AIRWING:Start()`;
- Observer-Client-Maskierung durch Rückgabe null;
- fehlende Post-Start-Assetprüfung.

## 9. Testbündelung

Standard:

```text
ein technischer Bereich
ein Bundle
eine MIZ-Einbindung
ein DCS-Lauf
mehrere eindeutige Subsystemmarker
ein Aggregatergebnis
```

Getrennt wird nur zur Fehlerisolierung.

## 10. Ergebnisdokumentation

Jeder PASS, FAIL, PARTIAL oder INVALID-Lauf erhält einen Ergebnisbericht. README, Manifest, Acceptance-Dokument und PR-Beschreibung müssen denselben Gate-Status führen.

Kein Merge und kein Ready for Review ohne ausdrückliche Freigabe des Projektinhabers.
