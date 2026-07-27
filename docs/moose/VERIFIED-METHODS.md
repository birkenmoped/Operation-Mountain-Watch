---
document_id: OMW-MOOSE-VERIFIED-METHODS
status: BINDING
document_class: TECHNICAL_EVIDENCE_REGISTER
owning_policy: OMW-GOV-001
authoritative_for:
  - project method-level MOOSE evidence
  - documented validation scope and limitations
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified verified-method register
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: partial
---

# Verifizierte MOOSE-Methoden

## 1. Zweck

Dieses Register führt praktisch geprüfte MOOSE-Aufrufe und den jeweils belegten OMW-Einsatzumfang.

Der vollständige frühere Methodenindex bleibt unverändert erhalten:

- [`Legacy-Methodenregister`](../evidence/source-records/legacy-moose-verified-methods.md)

Ein Eintrag belegt ausschließlich die angegebene Methode im dokumentierten Teststand. Er validiert weder die gesamte Klasse noch andere Basen, Missionen oder MOOSE-Versionen.

## 2. Nachweisgrenze

Für den historischen Jalalabad-Complete-Node-PASS gilt:

```yaml
omw_runtime_behavior: validated_for_documented_scope
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
evidence_type: RECONSTRUCTED_FROM_IDENTICAL_ARTIFACT
original_report_contained_full_hash: false
pr: 18
merged_to_main: false
```

Diese Einordnung ersetzt keine erneute Signatur- und Verhaltenprüfung auf einem neuen MOOSE-Stand.

## 3. Belegte Methodengruppen

### AIRBASE

- `AIRBASE:FindByName()`;
- `GetName()`;
- `GetID()`;
- `SetParkingSpotBlacklist()`.

### AIRWING

- `AIRWING:New()`;
- `SetAirbase()`;
- `SetTakeoffCold()`;
- `SetSafeParkingOn()`;
- `AddSquadron()`;
- `NewPayload()`;
- `GetSquadron()`;
- `Start()` für den dokumentierten Grundstart.

### SQUADRON, COMMANDER und Wrapper

- Konstruktion und Anbindung der dokumentierten Jalalabad-Squadrons;
- COMMANDER-Erstellung und AIRWING-Anbindung;
- `GROUP`, `UNIT`, `STATIC` und `ZONE` für Template- und Missionsvalidierung;
- `SCHEDULER` für die dokumentierte Konstruktionsreihenfolge.

## 4. Nicht durch den Jalalabad-Grundtest belegt

- vollständige taktische `AUFTRAG`-Ausführung;
- `OPSTRANSPORT`;
- CampaignState-Persistenz;
- Verlust-/Rückkehr- und Ramp-Neuverteilung;
- vollständige MEDEVAC- und CSAR-Koordination;
- andere Airbases, Kartenversionen oder MOOSE-Stände.

## 5. Neue Einträge

Jeder neue Eintrag enthält Methode, Signatur, MOOSE-Version, OMW-Commit, Mission, Hashes, Testbedingung, beobachtetes Ergebnis und bekannte Einschränkungen.
