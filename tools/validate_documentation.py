#!/usr/bin/env python3
import re, sys
from collections import defaultdict
from pathlib import Path
from urllib.parse import unquote

ALLOWED={"DRAFT","PLANNED","ACCEPTED_TECHNICAL_BASELINE","BINDING_PROJECT_DECISION","BINDING","SUPERSEDED","HISTORICAL_TEST_FIXTURE","REJECTED"}
CORE={"document_id","status","authoritative_for","source_branch","validated_in_dcs"}
EXT={"document_class","owning_policy","scenario_period","project_phase","supersedes","superseded_by","source_commit"}
STRICT={
"docs/README.md","docs/DOCUMENT-REGISTRY.md","docs/DOCUMENT-METADATA-POLICY.md","docs/SUBPROJECT-REGISTRY.md",
"docs/43-dcs-rain-shower-preset-validation.md","docs/adr/0003-use-mission-editor-group-templates.md",
"docs/adr/0004-use-explicit-location-registry.md","docs/csar/README.md","docs/csar/source-notes-1-8.md",
"docs/csar/afghanistan-2010-facilities-and-coverage.md","docs/csar/mission-design-requirements.md",
"docs/data/weather/README.md","docs/targeting/afghanistan-nsl-data-use-policy.md",
"docs/targeting/afghanistan-no-strike-list.md","mission/tests/jalalabad-air-operations/README.md"}
LINK=re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
NUM=re.compile(r"^(\d{2})-")
HEX40=re.compile(r"^[0-9a-f]{40}$")
HEX64=re.compile(r"^[0-9a-f]{64}$")
HEAD=re.compile(r"^#{1,6}\s+(.+?)\s*$")

def meta(text):
    lines=text.splitlines()
    if not lines or lines[0].strip()!="---": return {}
    try: end=next(i for i in range(1,len(lines)) if lines[i].strip()=="---")
    except StopIteration: return {}
    out={}; key=None
    for line in lines[1:end]:
        if not line or line.lstrip().startswith("#"): continue
        if re.match(r"^\s+-\s+",line) and key:
            if not isinstance(out.get(key),list): out[key]=[]
            out[key].append(re.sub(r"^\s+-\s+","",line).strip(" '\"")); continue
        m=re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$",line)
        if m:
            key=m.group(1); value=m.group(2).strip().strip(" '\"")
            out[key]=value if value else []
    return out

def slug(s):
    s=re.sub(r"<[^>]+>|[`*_~]","",s).lower().strip()
    s=re.sub(r"[^\w\- ]","",s,flags=re.UNICODE)
    return re.sub(r"\s+","-",s)

def anchors(path):
    result=set(); counts=defaultdict(int)
    for line in path.read_text(encoding="utf-8").splitlines():
        m=HEAD.match(line)
        if not m: continue
        base=slug(m.group(1)); n=counts[base]; counts[base]+=1
        result.add(base if n==0 else f"{base}-{n}")
    return result

def scoped(root):
    result=[]
    for p in (root/"docs").rglob("*.md"):
        rel=p.relative_to(root).as_posix()
        if rel.startswith(("docs/evidence/source-records/","docs/handoffs/")): continue
        result.append(p)
    test=root/"mission/tests/jalalabad-air-operations/README.md"
    if test.exists(): result.append(test)
    return sorted(result)

def validate(root):
    errors=[]; warnings=[]; ids=defaultdict(list); nums=defaultdict(list); texts={}
    docs=root/"docs"
    for path in scoped(root):
        rel=path.relative_to(root).as_posix(); text=path.read_text(encoding="utf-8"); texts[path]=text; fm=meta(text)
        if not fm:
            (errors if rel in STRICT or path.parent==docs else warnings).append(f"{rel}: missing YAML frontmatter"); continue
        missing=sorted(CORE-set(fm))
        if missing: errors.append(f"{rel}: missing core metadata: {', '.join(missing)}")
        missing=sorted(EXT-set(fm))
        if missing: (errors if rel in STRICT else warnings).append(f"{rel}: missing extended metadata: {', '.join(missing)}")
        did=str(fm.get("document_id","")).strip()
        if did: ids[did].append(rel)
        status=str(fm.get("status","")).strip()
        if status and status not in ALLOWED: errors.append(f"{rel}: invalid status {status!r}")
        commit=str(fm.get("source_commit","")).strip()
        if commit and commit not in {"PENDING_MERGE","GIT_HISTORY"} and not HEX40.fullmatch(commit): errors.append(f"{rel}: invalid source_commit {commit!r}")
        if status=="ACCEPTED_TECHNICAL_BASELINE":
            req={"acceptance_branch","acceptance_commit","acceptance_mission","acceptance_mission_sha256","dcs_version"}
            miss=sorted(req-set(fm))
            if miss: errors.append(f"{rel}: incomplete acceptance provenance: {', '.join(miss)}")
            if fm.get("acceptance_commit") and not HEX40.fullmatch(str(fm["acceptance_commit"])): errors.append(f"{rel}: invalid acceptance_commit")
            if fm.get("acceptance_mission_sha256") and not HEX64.fullmatch(str(fm["acceptance_mission_sha256"])): errors.append(f"{rel}: invalid acceptance_mission_sha256")
            if str(fm.get("validated_in_dcs","")).lower()!="true": errors.append(f"{rel}: accepted baseline requires validated_in_dcs: true")
            if not (fm.get("moose_commit") or fm.get("moose_artifact_sha256")): errors.append(f"{rel}: accepted baseline requires MOOSE provenance")
        m=NUM.match(path.name)
        if m and path.parent==docs: nums[m.group(1)].append(rel)
    for key,paths in sorted(ids.items()):
        if len(paths)>1: errors.append(f"duplicate document_id {key}: {', '.join(paths)}")
    for key,paths in sorted(nums.items()):
        if len(paths)>1: errors.append(f"duplicate document number {key}: {', '.join(paths)}")
    cache={}
    for path,text in texts.items():
        rel=path.relative_to(root).as_posix()
        for raw in LINK.findall(text):
            target=raw.strip().split()[0].strip("<>")
            if not target or target.startswith(("http://","https://","mailto:","#")): continue
            filepart,sep,anchor=unquote(target).partition("#")
            resolved=(path.parent/filepart).resolve() if filepart else path.resolve()
            try: resolved.relative_to(root.resolve())
            except ValueError: errors.append(f"{rel}: link escapes repository: {target}"); continue
            if not resolved.exists(): errors.append(f"{rel}: dead relative link: {target}"); continue
            if sep and resolved.is_file() and resolved.suffix.lower()==".md":
                known=cache.setdefault(resolved,anchors(resolved))
                if anchor and anchor not in known: warnings.append(f"{rel}: unresolved heading anchor: {target}")
    return errors,warnings

def main():
    root=Path(sys.argv[1] if len(sys.argv)>1 else ".").resolve(); errors,warnings=validate(root)
    for x in warnings: print("WARNING:",x)
    for x in errors: print("ERROR:",x)
    print(f"documentation validation: {len(errors)} error(s), {len(warnings)} warning(s)")
    return 1 if errors else 0

if __name__=="__main__": raise SystemExit(main())
