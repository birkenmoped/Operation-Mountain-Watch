from pathlib import Path
import re

root = Path('.').resolve()
TKOT_MERGE = '585f3c46d4ff0a4b167c984d427bcdb356138e69'
KAF_MERGE = '66b37d31c715882e910305169906400304a826c0'

# Normalize obsolete project-phase values and replace merge placeholders with
# the exact merge commits that now contain the documented source state.
for p in list((root / 'docs').rglob('*.md')) + list((root / 'mission/tests').rglob('*.md')):
    txt = p.read_text(encoding='utf-8')
    orig = txt
    txt = re.sub(
        r'^project_phase: (?:AIR_OPERATIONS_TEST_WORKFLOW|TARINKOT_[A-Z0-9_]+)$',
        'project_phase: COMPLETE_FOUNDATION_BUILD_PHASE',
        txt,
        flags=re.M,
    )
    if 'source_commit: PENDING_MERGE' in txt:
        replacement = KAF_MERGE if p.as_posix().endswith(
            'docs/evidence/2026-08-10-kandahar-foundation-inventory-reconciliation.md'
        ) else TKOT_MERGE
        txt = txt.replace('source_commit: PENDING_MERGE', f'source_commit: {replacement}')
    if txt != orig:
        p.write_text(txt, encoding='utf-8')

# Historical snapshots used non-governance status labels. Preserve their body
# and evidence, but classify them with current allowed governance vocabulary.
status_map = {
    'mission/tests/tarinkot-air-operations/results/2026-08-04-g6b-final-free-spots-pass-and-departure-scope-correction.md': ('DCS_ACCEPTED_BRANCH', 'HISTORICAL_TEST_FIXTURE'),
    'mission/tests/tarinkot-air-operations/results/2026-08-05-complete-status-freeze-through-g8-parking-block.md': ('FROZEN_SNAPSHOT', 'HISTORICAL_TEST_FIXTURE'),
    'mission/tests/tarinkot-air-operations/results/2026-08-05-main-lifecycle-sync-and-g8-static-pass.md': ('ACCEPTED_STATIC_BASELINE', 'HISTORICAL_TEST_FIXTURE'),
}
for rel, (old, new) in status_map.items():
    p = root / rel
    txt = p.read_text(encoding='utf-8')
    txt = txt.replace(f'status: {old}', f'status: {new}', 1)
    p.write_text(txt, encoding='utf-8')

# Complete the frozen snapshot's missing provenance with the exact snapshot
# commit already recorded by the historical Tarinkot line.
p = root / 'mission/tests/tarinkot-air-operations/results/2026-08-05-complete-status-freeze-through-g8-parking-block.md'
txt = p.read_text(encoding='utf-8')
insert = (
    'scenario_period: 2010-08-01/2011-12-31\n'
    'project_phase: COMPLETE_FOUNDATION_BUILD_PHASE\n'
    'source_commit: 0a533fcd7ccec6b71f9d44db675e95cef2eda06b\n'
)
if 'scenario_period:' not in txt.split('---', 2)[1]:
    txt = txt.replace(
        'source_branch: agent/tarinkot-object-contract-reconciliation\n',
        'source_branch: agent/tarinkot-object-contract-reconciliation\n' + insert,
        1,
    )
p.write_text(txt, encoding='utf-8')


def add_acceptance(rel, fields):
    p = root / rel
    txt = p.read_text(encoding='utf-8')
    marker = 'validated_in_dcs: true\n'
    block = ''.join(f'{key}: {value}\n' for key, value in fields)
    first_line = block.strip().splitlines()[0]
    if first_line not in txt:
        txt = txt.replace(marker, marker + block, 1)
    p.write_text(txt, encoding='utf-8')


add_acceptance(
    'mission/tests/tarinkot-air-operations/results/2026-08-03-g6a-parking-candidate-analysis-pass.md',
    [
        ('acceptance_branch', 'agent/tarinkot-object-contract-reconciliation'),
        ('acceptance_commit', 'a58fdfb82082bb7e9043f314e1c483a9a6ba3775'),
        ('acceptance_mission', 'OMW_Template_v5_Salerno.miz'),
        ('acceptance_mission_sha256', '203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5'),
        ('dcs_version', '2.9.28.26385'),
        ('moose_commit', '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'),
        ('moose_artifact_sha256', 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'),
    ],
)

for rel in [
    'mission/tests/tarinkot-air-operations/expected/g7-airwing-squadron-payload-foundation-acceptance.md',
    'mission/tests/tarinkot-air-operations/results/2026-08-04-g7-airwing-squadron-payload-foundation-pass.md',
]:
    add_acceptance(
        rel,
        [
            ('acceptance_branch', 'agent/tarinkot-object-contract-reconciliation'),
            ('acceptance_commit', 'add569fb3231a5563d9c89f865cce7bd764bc0bb'),
            ('acceptance_mission', 'OMW_Template_v6_Tarinkot.miz'),
            ('acceptance_mission_sha256', '86ba08f46c78a94cdf6eb54f7abe85145bdabe2817e7a2a89f2cec34932866bb'),
            ('dcs_version', '2.9.28.26385 MT'),
            ('moose_commit', '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'),
            ('moose_artifact_sha256', 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'),
        ],
    )

# Restore complete frontmatter for the already documented exact Salerno
# foundation runtime artifact chain. No new runtime claim is introduced.
p = root / 'docs/evidence/2026-08-09-salerno-foundation-runtime-validation.md'
txt = p.read_text(encoding='utf-8')
frontmatter = '''---
document_id: OMW-EVIDENCE-SALERNO-FOUNDATION-RUNTIME-2026-08-09
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Salerno AIRWING/SQUADRON foundation runtime validation for the exact documented artifact chain
  - Salerno foundation-only no-tasking boundary for the exact documented run
not_authoritative_for:
  - parking assignment or parking compliance
  - tactical dispatch, recovery, persistence, COMMANDER or OPSTRANSPORT acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/salerno-airops-foundation-cleanup
source_commit: d7b54e310aed83c4c2e4d08be81e9f31a9b9a45e
validated_in_dcs: true
acceptance_branch: agent/salerno-airops-foundation-cleanup
acceptance_commit: d7b54e310aed83c4c2e4d08be81e9f31a9b9a45e
acceptance_mission: OMW_Template_v6_Tarinkot.miz
acceptance_mission_sha256: f0b0b5ce14643f510ef7581f2122c10777475c2d148daf2e6f2c316c80dd96aa
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

'''
if not txt.startswith('---\n'):
    p.write_text(frontmatter + txt, encoding='utf-8')
