from pathlib import Path
import subprocess

repo_commit = "dac19985de5ecae89b6948854e4a4bd5906f765b"
old = "source_commit: PENDING_MERGE"
new = f"source_commit: {repo_commit}"

changed = subprocess.check_output(
    ["git", "diff", "--name-only", "main...HEAD", "--", "*.md"],
    text=True,
).splitlines()
replaced = []
for raw in changed:
    path = Path(raw)
    if not path.exists():
        continue
    text = path.read_text(encoding="utf-8")
    if old in text:
        count = text.count(old)
        if count != 1:
            raise SystemExit(f"{raw}: expected one source_commit placeholder, found {count}")
        path.write_text(text.replace(old, new, 1), encoding="utf-8")
        replaced.append(raw)

expected = {
    "docs/handoffs/2026-08-22-automatic-response-orchestration-development-order.md",
    "docs/handoffs/2026-08-23-automatic-response-orchestration-current-state-and-next-chat-handoff.md",
    "docs/handoffs/2026-08-29-automatic-response-orchestration-main-reconciliation-handoff.md",
    "docs/moose/GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW.md",
    "docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md",
    "mission/tests/ground-resupply-execution/ACCEPTANCE-1.md",
    "mission/tests/ground-resupply-execution/ACCEPTANCE-2.md",
    "mission/tests/ground-resupply-execution/ACCEPTANCE-3.md",
    "mission/tests/ground-resupply-execution/ACCEPTANCE-4.md",
    "mission/tests/ground-resupply-execution/README.md",
}
missing = sorted(expected - set(replaced))
if missing:
    raise SystemExit("expected source_commit migrations missing: " + ", ".join(missing))


def append_once(path_name, marker, block):
    path = Path(path_name)
    text = path.read_text(encoding="utf-8")
    if marker not in text:
        if not text.endswith("\n"):
            text += "\n"
        path.write_text(text + "\n" + block.strip() + "\n", encoding="utf-8")


append_once(
    "docs/moose/PROJECT-CLASS-INDEX.md",
    "## Ground RESUPPLY accepted execution addendum - 29.08.2026",
    r"""
## Ground RESUPPLY accepted execution addendum - 29.08.2026

Fuer den exakt dokumentierten Ground-RESUPPLY-Scope gelten mit MOOSE 2.9.18 / Commit
`73d3ed119cd9e7e3f2cfcabbaa34513d30529b54` / `Moose.lua`
SHA-256 `e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915`
zusaetzlich folgende Klassenstaende:

| Klasse | Projektstatus | Geltungsgrenze |
|---|---|---|
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Stage 1A bestaetigt `NewAMMOSUPPLY(...)`; Stage 1C bestaetigt den neutralen physischen Meta-RESUPPLY-Pfad ueber `NewNOTHING(...)`; Stage 1B2 bestaetigt `NewFUELSUPPLY(...)` als One-Shot-Fuel-Executor. Die Nachweise gelten nur fuer die jeweiligen Acceptance-Provenienzen. |
| `BRIGADE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `SOURCE_REVIEWED` | `AddMission(...)` ist im dokumentierten Ground-RESUPPLY-Lifecycle praktisch bestaetigt. `AddRefuellingZone(...)` ist source-seitig als persistente Refuelling-Service-Registrierung eingeordnet und wird nicht als One-Shot-CampaignState-Transferdispatcher verwendet. |
| `ARMYGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Die akzeptierten RESUPPLY-Laeufe bestaetigen physischen Hinweg, Return-to-Legion/RTZ, `Returned` und den anschliessenden Warehouse-Handoff im jeweils dokumentierten Scope. |
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` + `INTERNAL_RESTRICTED` | Materialisierung und `Returned -> AddAsset` sind in den Ground-RESUPPLY-Acceptances beobachtet; die bereits genehmigte road-aligned Ground-Spawn-Ausnahme bleibt auf ihren dokumentierten Scope begrenzt. |

Technische Details und Grenzen:

- [`Ground RESUPPLY Execution Source Review`](GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md)
- [`Ground FUELSUPPLY Source Review`](GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW.md)
- [`Ground AMMO RESUPPLY Acceptance 1`](../../mission/tests/ground-resupply-execution/ACCEPTANCE-1.md)
- [`Ground Meta RESUPPLY NOTHING Acceptance`](../../mission/tests/ground-resupply-execution/ACCEPTANCE-3.md)
- [`Ground FUELSUPPLY Acceptance 2`](../../mission/tests/ground-resupply-execution/ACCEPTANCE-4.md)

Dieser Addendum-Eintrag validiert keinen generischen Produktions-Executor fuer weitere Ressourcentypen und keine CAS-/CSAR-Ausfuehrung.
""",
)

append_once(
    "docs/moose/VERIFIED-METHODS.md",
    "## Ground RESUPPLY - method-level evidence 29.08.2026",
    r"""
## Ground RESUPPLY - method-level evidence 29.08.2026

Gepinnter Framework-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

| Methode / Pfad | Status | Exakt bestaetigter OMW-Umfang |
|---|---|---|
| `AUFTRAG:NewAMMOSUPPLY(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Stage 1A: MissionDemand-getriebener physischer AMMO-Transfer bis Zielbeobachtung, exactly-once CampaignState-Settlement, Rueckkehr und Warehouse-Handoff. |
| `AUFTRAG:NewNOTHING(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Stage 1C: neutraler physischer Meta-RESUPPLY-Transport; technische Evidenz/Fallback, nicht bevorzugter Fuel-Executor nach Stage 1B2. |
| `AUFTRAG:NewFUELSUPPLY(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Stage 1B2: One-Shot Fuel-Dispatch ueber Zielzone, genau eine Materialisierung/Mission, Zielbeobachtung, CampaignState-Settlement und normale Rueckkehr. |
| `BRIGADE:AddMission(...)` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Direkter One-Shot-Dispatch der dokumentierten Ground-RESUPPLY-Missionen. |
| `BRIGADE:AddRefuellingZone(...)` | `SOURCE_REVIEWED` | Registriert im gepinnten Source einen persistenten Refuelling-Service; der BRIGADE-Statuspfad kann Folge-FUELSUPPLY-Missionen erzeugen. Daher nicht als One-Shot-Transferdispatcher verwendet. |
| `AUFTRAG:SetReturnToLegion(...)` / normaler Legion-Return | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Rueckkehrverhalten in den dokumentierten Ground-Lifecycles; Stage 1B2 nutzt den normalen MOOSE-Return ohne OMW-eigenen RTZ-Override. |
| `ARMYGROUP:RTZ(...)` / `Returned` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Physische Rueckkehr und `Returned`-Handoff fuer die dokumentierten mobilen Ground-Gruppen. |
| `WAREHOUSE AddAsset` nach `Returned` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Rueckgabe der temporaeren physischen Repraesentation in den MOOSE-Warehouse-Lifecycle; keine strategische Ressourcenautoritaet. |

Acceptance-Provenienz:

```text
Stage 1A AMMO:
  acceptance_commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
  mission: OMW_Template_v18.miz
  mission_sha256: 2fdf31a2e07409cf392d45bff5fc69750958c670ae3e12ff28d0b4fd8aecc90d

Stage 1C NOTHING:
  acceptance_commit: 8803505edf07120bc6d1673b41f69067e8db0211
  mission: OMW_Template_v19.miz
  mission_sha256: d788af36535d3acd1866d15ffb5d354b2c44b5f8ee40d4baf6fd1d97b7c0f8a5

Stage 1B2 FUELSUPPLY:
  acceptance_commit: 2bd930729ed12a073f5364dc139281b60151acf0
  bundle_sha256: 8cbdfa12b1a052517d82cb20a460ca665415353fe38ed2f1c50928be6c7966a0
  mission: OMW_Template_v19.miz
  mission_sha256: 603422efaffa860041089d0f1ad41d35642a7863bc1c7b658e0b8f15a6eb63f2
  dcs: 2.9.28.26385 MT
```

Grenze: Diese Eintraege bestaetigen weder eine DCS-Fuelmengen-Synchronisation noch einen generischen Executor fuer weitere CampaignState-Ressourcen.
""",
)

append_once(
    "docs/DOCUMENT-REGISTRY.md",
    "## Ground RESUPPLY technical package - merge addition",
    r"""
## Ground RESUPPLY technical package - merge addition

Die folgenden stabilen IDs werden mit dem Ground-RESUPPLY-Mergepaket in den Main-Dokumentbestand aufgenommen:

| Stabile ID | Pfad | Status | Klasse/Funktion |
|---|---|---|---|
| `OMW-MOOSE-GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW` | `docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md` | `BINDING` | MOOSE Ground-RESUPPLY Source-/Runtime-Grenze |
| `OMW-MOOSE-GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW` | `docs/moose/GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW.md` | `BINDING` | One-Shot FUELSUPPLY vs. persistenter Refuelling-Service |
| `OMW-TEST-GROUND-RESUPPLY-EXECUTION` | `mission/tests/ground-resupply-execution/README.md` | `PLANNED` | Ground-RESUPPLY Testprojektindex |
| `OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1` | `mission/tests/ground-resupply-execution/ACCEPTANCE-1.md` | `ACCEPTED_TECHNICAL_BASELINE` | Stage 1A AMMO RESUPPLY |
| `OMW-GROUND-FUEL-RESUPPLY-ACCEPTANCE-1` | `mission/tests/ground-resupply-execution/ACCEPTANCE-2.md` | `HISTORICAL_TEST_FIXTURE` | historischer/inconclusive FUELSUPPLY-Versuch |
| `OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1` | `mission/tests/ground-resupply-execution/ACCEPTANCE-3.md` | `ACCEPTED_TECHNICAL_BASELINE` | Stage 1C neutraler NOTHING-Transport |
| `OMW-GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2` | `mission/tests/ground-resupply-execution/ACCEPTANCE-4.md` | `ACCEPTED_TECHNICAL_BASELINE` | Stage 1B2 One-Shot FUELSUPPLY |
""",
)

append_once(
    "docs/SUBPROJECT-REGISTRY.md",
    "## Automatic Response Orchestration - Ground RESUPPLY branch cut",
    r"""
## Automatic Response Orchestration - Ground RESUPPLY branch cut

Aktueller Merge-Scope:

```text
PR: 131
branch: agent/automatic-response-orchestration
base: main
scope: completed Ground RESUPPLY acceptance package
Stage 1A: ACCEPTED_TECHNICAL_BASELINE
Stage 1B: HISTORICAL_TEST_FIXTURE / INCONCLUSIVE
Stage 1C: ACCEPTED_TECHNICAL_BASELINE
Stage 1B2: ACCEPTED_TECHNICAL_BASELINE
```

Die verbleibende Automatic-Response-Arbeit ist bewusst vom Merge-Scope getrennt und liegt auf:

```text
agent/automatic-response-orchestration-continuation
```

Restscope des Nachfolgers: Stage 1D sowie Stages 2-9 (weitere RESUPPLY-Reconciliation, FOB-/Convoy-Angriffsreaktionen, Fires/CAS, CSAR, End-to-End, Restart/Idempotence und Multiplayer/Performance/Failure Acceptance).

Reconciliation-Historie fuer PR 131:

```text
PR 130: earlier main reconciliation into feature branch
PR 133: documentation metadata cleanup merged to main
PR 134: cleaned main reconciled into feature branch
```

Keiner dieser Eintraege erweitert die branchgebundenen DCS-Acceptance-Grenzen.
""",
)

handoff = Path("docs/handoffs/2026-08-29-automatic-response-orchestration-main-reconciliation-handoff.md")
htext = handoff.read_text(encoding="utf-8")
marker = "## Merge-readiness addendum 29.08.2026"
if marker not in htext:
    htext += r"""

## Merge-readiness addendum 29.08.2026

Nach Abschluss der separaten Dokumentationsbereinigung wurde `main` erneut in diesen Branch reconciliert:

```text
documentation cleanup PR: 133
cleanup main merge: fa1cde7d284d1c00ef073669a3d2ba483260254f
reconciliation PR: 134
feature reconciliation merge: d439724858b10c986e5ce7e6a39d845d715b9d11
```

Damit basiert der finale Ground-RESUPPLY-Merge-Review auf dem bereinigten Main-Dokumentationsstand. Die Restarbeit Stage 1D-9 verbleibt im Nachfolgebranch und blockiert diesen bewusst geschnittenen Merge-Scope nicht.
"""
    handoff.write_text(htext, encoding="utf-8")

print(f"migrated source_commit placeholders: {len(replaced)}")
