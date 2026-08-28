#!/usr/bin/env python3
import argparse
import re
from collections import defaultdict
from pathlib import Path
from urllib.parse import unquote

ALLOWED = {
    "DRAFT",
    "PLANNED",
    "ACCEPTED_TECHNICAL_BASELINE",
    "BINDING_PROJECT_DECISION",
    "BINDING",
    "SUPERSEDED",
    "HISTORICAL_TEST_FIXTURE",
    "REJECTED",
}
SOURCE_RECORD_STATUSES = ALLOWED | {"ACTIVE", "BINDING_SOURCE_RECORD", "SOURCE_RECORD"}
ALLOWED_PHASES = {"COMPLETE_FOUNDATION_BUILD_PHASE", "HISTORICAL_VERTICAL_PROTOTYPE"}
CORE = {"document_id", "status", "authoritative_for", "source_branch", "validated_in_dcs"}
EXT = {
    "document_class",
    "owning_policy",
    "scenario_period",
    "project_phase",
    "supersedes",
    "superseded_by",
    "source_commit",
}
ARCHIVE_PATHS = {
    "docs/handoffs/2026-07-31-bagram-current-state-and-kandahar-chat-handoff.md",
    "docs/handoffs/2026-07-31-bagram-handoff-addendum.md",
}
SOURCE_RECORD_PREFIX = "docs/evidence/source-records/"
LEGACY_SOURCE_PREFIX = f"{SOURCE_RECORD_PREFIX}legacy-"
LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
NUM = re.compile(r"^(\d{2})-")
HEX40 = re.compile(r"^[0-9a-f]{40}$")
HEX64 = re.compile(r"^[0-9a-f]{64}$")
HEAD = re.compile(r"^#{1,6}\s+(.+?)\s*$")
CODE_SPAN = re.compile(r"`([^`]+)`")


def meta(text):
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        return {}
    out = {}
    key = None
    for line in lines[1:end]:
        if not line or line.lstrip().startswith("#"):
            continue
        if re.match(r"^\s+-\s+", line) and key:
            if not isinstance(out.get(key), list):
                out[key] = []
            out[key].append(re.sub(r"^\s+-\s+", "", line).strip(" '\""))
            continue
        match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if match:
            key = match.group(1)
            value = match.group(2).strip().strip(" '\"")
            out[key] = value if value else []
    return out


def slug(value):
    value = re.sub(r"<[^>]+>|[`*_~]", "", value).lower().strip()
    value = re.sub(r"[^\w\- ]", "", value, flags=re.UNICODE)
    return re.sub(r"\s+", "-", value)


def anchors(path):
    result = set()
    counts = defaultdict(int)
    for line in path.read_text(encoding="utf-8").splitlines():
        match = HEAD.match(line)
        if not match:
            continue
        base = slug(match.group(1))
        count = counts[base]
        counts[base] += 1
        result.add(base if count == 0 else f"{base}-{count}")
    return result


def markdown_files(root):
    result = list((root / "docs").rglob("*.md"))
    tests = root / "mission" / "tests"
    if tests.exists():
        result.extend(tests.rglob("*.md"))
    return sorted(set(result))


def is_source_record(rel):
    return rel.startswith(SOURCE_RECORD_PREFIX)


def is_archive(rel):
    return rel in ARCHIVE_PATHS or rel.startswith(LEGACY_SOURCE_PREFIX)


def metadata_required(rel):
    return not is_archive(rel) and not is_source_record(rel)


def add_link_issue(errors, warnings, rel, message):
    target = warnings if is_archive(rel) or is_source_record(rel) else errors
    target.append(f"{rel}: {message}")


def validate_registry(root, metadata, errors):
    registry = root / "docs" / "DOCUMENT-REGISTRY.md"
    if not registry.exists():
        errors.append("docs/DOCUMENT-REGISTRY.md: missing document registry")
        return

    registered_paths = set()
    registered_ids = defaultdict(list)
    for line_number, line in enumerate(registry.read_text(encoding="utf-8").splitlines(), 1):
        if not line.lstrip().startswith("|"):
            continue
        tokens = CODE_SPAN.findall(line)
        path = next(
            (
                token
                for token in tokens
                if token.endswith(".md") and token.startswith(("docs/", "mission/tests/"))
            ),
            None,
        )
        document_id = next((token for token in tokens if token.startswith("OMW-")), None)
        if not path:
            continue
        registered_paths.add(path)
        if document_id:
            registered_ids[document_id].append((path, line_number))
        target = root / path
        if not target.is_file():
            errors.append(f"docs/DOCUMENT-REGISTRY.md:{line_number}: registered path does not exist: {path}")
            continue
        actual = metadata.get(path, {}).get("document_id")
        if document_id and actual != document_id:
            errors.append(
                f"docs/DOCUMENT-REGISTRY.md:{line_number}: ID/path mismatch: "
                f"{document_id} -> {path}, file declares {actual!r}"
            )

    for document_id, rows in sorted(registered_ids.items()):
        if len(rows) > 1:
            details = ", ".join(f"{path}:{line}" for path, line in rows)
            errors.append(f"docs/DOCUMENT-REGISTRY.md: duplicate registered ID {document_id}: {details}")

    for path in sorted((root / "docs").glob("[0-9][0-9]-*.md")):
        rel = path.relative_to(root).as_posix()
        if rel not in registered_paths:
            errors.append(f"docs/DOCUMENT-REGISTRY.md: numbered document is not registered: {rel}")


def validate(root, main_branch=False):
    errors = []
    warnings = []
    ids = defaultdict(list)
    nums = defaultdict(list)
    texts = {}
    metadata = {}
    docs = root / "docs"

    for path in markdown_files(root):
        rel = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8")
        texts[path] = text
        frontmatter = meta(text)
        metadata[rel] = frontmatter

        if metadata_required(rel) and not frontmatter:
            errors.append(f"{rel}: missing YAML frontmatter")
            continue
        if not frontmatter or is_archive(rel):
            continue

        if metadata_required(rel):
            missing = sorted(CORE - set(frontmatter))
            if missing:
                errors.append(f"{rel}: missing core metadata: {', '.join(missing)}")
            missing = sorted(EXT - set(frontmatter))
            if missing:
                errors.append(f"{rel}: missing extended metadata: {', '.join(missing)}")

        document_id = str(frontmatter.get("document_id", "")).strip()
        if document_id:
            ids[document_id].append(rel)

        status = str(frontmatter.get("status", "")).strip()
        allowed_statuses = SOURCE_RECORD_STATUSES if is_source_record(rel) else ALLOWED
        if status and status not in allowed_statuses:
            errors.append(f"{rel}: invalid status {status!r}")

        raw_phase = frontmatter.get("project_phase", "")
        phase = "" if raw_phase in ("", []) else str(raw_phase).strip()
        if phase and phase not in ALLOWED_PHASES:
            errors.append(f"{rel}: invalid project_phase {phase!r}")

        raw_validated = frontmatter.get("validated_in_dcs", "")
        validated = "" if raw_validated in ("", []) else str(raw_validated).lower().strip()
        if validated and validated not in {"true", "false", "partial"}:
            errors.append(f"{rel}: invalid validated_in_dcs value {validated!r}")

        raw_commit = frontmatter.get("source_commit", "")
        commit = "" if raw_commit in ("", []) else str(raw_commit).strip()
        if commit and commit not in {"PENDING_MERGE", "GIT_HISTORY"} and not HEX40.fullmatch(commit):
            errors.append(f"{rel}: invalid source_commit {commit!r}")
        if main_branch and metadata_required(rel) and not commit:
            errors.append(f"{rel}: empty source_commit is not allowed on main")
        if main_branch and commit == "PENDING_MERGE":
            errors.append(f"{rel}: source_commit PENDING_MERGE is not allowed on main")

        if status == "ACCEPTED_TECHNICAL_BASELINE" and not is_source_record(rel):
            required = {
                "acceptance_branch",
                "acceptance_commit",
                "acceptance_mission",
                "acceptance_mission_sha256",
                "dcs_version",
            }
            missing = sorted(required - set(frontmatter))
            if missing:
                errors.append(f"{rel}: incomplete acceptance provenance: {', '.join(missing)}")
            if frontmatter.get("acceptance_commit") and not HEX40.fullmatch(str(frontmatter["acceptance_commit"])):
                errors.append(f"{rel}: invalid acceptance_commit")
            if frontmatter.get("acceptance_mission_sha256") and not HEX64.fullmatch(
                str(frontmatter["acceptance_mission_sha256"])
            ):
                errors.append(f"{rel}: invalid acceptance_mission_sha256")
            if validated != "true":
                errors.append(f"{rel}: accepted baseline requires validated_in_dcs: true")
            if not (frontmatter.get("moose_commit") or frontmatter.get("moose_artifact_sha256")):
                errors.append(f"{rel}: accepted baseline requires MOOSE provenance")

        match = NUM.match(path.name)
        if match and path.parent == docs:
            nums[match.group(1)].append(rel)

    for document_id, paths in sorted(ids.items()):
        if len(paths) > 1:
            errors.append(f"duplicate document_id {document_id}: {', '.join(paths)}")
    for number, paths in sorted(nums.items()):
        if len(paths) > 1:
            errors.append(f"duplicate document number {number}: {', '.join(paths)}")

    validate_registry(root, metadata, errors)

    cache = {}
    for path, text in texts.items():
        rel = path.relative_to(root).as_posix()
        if is_archive(rel):
            continue
        for raw in LINK.findall(text):
            target = raw.strip().split()[0].strip("<>")
            if not target or target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            filepart, separator, anchor = unquote(target).partition("#")
            resolved = (path.parent / filepart).resolve() if filepart else path.resolve()
            try:
                resolved.relative_to(root.resolve())
            except ValueError:
                add_link_issue(errors, warnings, rel, f"link escapes repository: {target}")
                continue
            if not resolved.exists():
                add_link_issue(errors, warnings, rel, f"dead relative link: {target}")
                continue
            if separator and resolved.is_file() and resolved.suffix.lower() == ".md":
                known = cache.setdefault(resolved, anchors(resolved))
                if anchor and anchor not in known:
                    warnings.append(f"{rel}: unresolved heading anchor: {target}")

    return errors, warnings


def main():
    parser = argparse.ArgumentParser(description="Validate OMW documentation governance and links")
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--main", action="store_true", help="reject branch-only provenance values")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    errors, warnings = validate(root, main_branch=args.main)
    for warning in warnings:
        print("WARNING:", warning)
    for error in errors:
        print("ERROR:", error)
    print(f"documentation validation: {len(errors)} error(s), {len(warnings)} warning(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
