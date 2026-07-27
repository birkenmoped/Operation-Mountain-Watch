#!/usr/bin/env python3
from pathlib import Path
import sys

UPDATES={
'docs/00-project-governance.md':{'document_class':'PROJECT_GOVERNANCE','owning_policy':'OMW-GOV-001','source_commit':'GIT_HISTORY','superseded_by':None},
'docs/03-system-architecture.md':{'document_class':'SYSTEM_ARCHITECTURE'},
'docs/09-historical-setting.md':{'document_class':'HISTORICAL_BASELINE','source_commit':'GIT_HISTORY','superseded_by':None},
'docs/14-prototype-scope.md':{'document_class':'HISTORICAL_PHASE_BASELINE','source_commit':'GIT_HISTORY','supersedes':None},
'docs/18-air-operations-implementation.md':{'document_class':'AIR_OPERATIONS_ARCHITECTURE'},
'docs/19-active-air-orbat-decisions.md':{'document_class':'PROJECT_DECISION','source_commit':'GIT_HISTORY','superseded_by':None},
'docs/20-air-orbat-mission-editor-worklist.md':{'document_class':'MISSION_EDITOR_WORKLIST'},
'docs/26-moose-first-development-policy.md':{'document_class':'GOVERNANCE_POLICY','scenario_period':None,'source_commit':'GIT_HISTORY','superseded_by':None},
'docs/evidence/jalalabad-air-operations-baseline-audit.md':{'owning_policy':'OMW-GOV-001','scenario_period':'2010-08-01/2011-12-31','project_phase':'COMPLETE_FOUNDATION_BUILD_PHASE','supersedes':None,'superseded_by':None,'source_branch':'agent/resolve-document-number-collisions','source_commit':'GIT_HISTORY'},
'docs/moose/VERSION-AND-SOURCES.md':{'document_class':'MOOSE_VERSION_POLICY','scenario_period':None,'supersedes':None,'superseded_by':None},
'docs/sources/graveyard-of-empires.md':{'document_class':'SOURCE_USE_POLICY','scenario_period':None,'source_commit':'GIT_HISTORY','superseded_by':None},
'docs/us-air-orbat-2010-2011.md':{'document_class':'HISTORICAL_RESEARCH_REFERENCE','owning_policy':'OMW-GOV-001','supersedes':None,'superseded_by':None,'source_commit':'GIT_HISTORY'},
}

def patch(root: Path) -> int:
    changed=0
    for rel,fields in UPDATES.items():
        path=root/rel
        text=path.read_text(encoding='utf-8')
        lines=text.splitlines(keepends=True)
        if not lines or lines[0].strip()!='---': raise RuntimeError(f'missing frontmatter: {rel}')
        end=next(i for i in range(1,len(lines)) if lines[i].strip()=='---')
        existing={line.split(':',1)[0].strip() for line in lines[1:end] if ':' in line and not line.startswith((' ','\t','-'))}
        additions=[]
        for key,value in fields.items():
            if key in existing: continue
            additions.append(f'{key}:\n' if value is None else f'{key}: {value}\n')
        if additions:
            lines[end:end]=additions
            path.write_text(''.join(lines),encoding='utf-8')
            print(f'updated {rel}: {len(additions)} field(s)')
            changed+=1
    print(f'metadata migration changed {changed} file(s)')
    return changed

if __name__=='__main__':
    patch(Path(sys.argv[1] if len(sys.argv)>1 else '.').resolve())
