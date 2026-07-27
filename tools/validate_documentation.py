#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path
from urllib.parse import unquote

ALLOWED_STATUSES = {
    "DRAFT",
    "PLANNED",
    "ACCEPTED_TECHNICAL_BASELINE",
    "BINDING_PROJECT_DECISION",
    "BINDING",
    "SUPERSEDED",
    "HISTORICAL_TEST_FIXTURE",
    "REJECTED",
}

CORE_KEYS = {
    "document_id",
    "status",
    "authoritative_for",
    "source_branch",
    "validated_in_dcs",
}

EXTENDED_KEYS = {
    "document_class",
    "owning_policy",
    "scenario_period",
    "project_phase",
    "supersedes",
    "superseded_by",
    "source_commit",
}

STRICT_METADATA_PATHS = {
    "docs/README.md",
    "docs/DOCUMENT-REGISTRY.md",
    "docs/DOCUMENT-METADATA-POLICY.md",
    "docs/SUBPROJECT-REGISTRY.md",
    "docs/43-dcs-rain-shower-preset-validation.md",
    "docs/adr/0003-use-mission-editor-group-templates.md",
    "docs/adr/0004-use-explicit-location-registry.md",
    "docs/csar/README.md",
    "docs/csar/source-notes-1-8.md",
    "docs/csar/afghanistan-2010-facilities-and-coverage.md",
    "docs/csar/mission-design-requirements.md",
    "docs/data/weather/README.md",
    "docs/targeting/afghanistan-nsl-data-use-policy.md",
    "docs/targeting/afghanistan-no-strike-list.md",
    "mission/tests/jalalabad-air-operations/README.md",
}

LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
HEADING_RE = re.compile(r"^#{1,6}\s+(.+?)\s*$")
NUMBERED_DOC_RE = re.compile(r"^(\d{2})-")
HEX40_RE = re.compile(r"^[0-9a-f]{40}$")
HEX64_RE = re.compile(r"^[0-9a-f]{64}$")


def parse_frontmatter(text: str) -> tuple[dict[str, object], int]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, 0
    end = None
    for index in range(1, len(lines)):
        if lines[index].strip() == "---":
            end = index
            break
    if end is None:
        return {}, 0

    data: dict[str, object] = {}
    current_key: str | None = None
    for raw in lines[1:end]:
        line = raw.rstrip()
        if not line or line.lstrip().startswith("#"):
            continue
        if re.match(r"^\s+-\s+", line) and current_key:
            value = re.sub(r"^\s+-\s+", "", line).strip().strip('"\'')
            existing = data.get(current_key)
            if not isinstance(existing, list):
                existing = []
                data[current_key] = existing
            existing.append(value)
            continue
        match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if match:
            current_key = match.group(1)
            value = match.group(2).strip().strip('"\'')
            data[current_key] = value
    return data, end + 1


def github_slug(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text)
    text = re.sub(r"[`*_~]", "", text)
    text = text.strip().lower()
    text = re.sub(r"[^\w\- ]", "", text, flags=re.UNICODE)
    text = re.sub(r"\s+", "-", text)
    return text


def collect_headings(text: str) -> set[str]:
    slugs: set[str] = set()
    counts: defaultdict[str, int] = defaultdict(int)
    for line in text.splitlines():
        match = HEADING_RE.match(line)
        if not match:
            continue
        base = github_slug(match.group(1))
        suffix = counts[base]
        counts[base] += 1
        slugs.add(base if suffix == 0 else f"{base}-{suffix}")
    return slugs


def iter_scoped_markdown(root: Path) -> list[Path]:
    docs = root / "docs"
    paths: set[Path] = set()
    if docs.exists():
        for path in docs.rglob("*.md"):
            rel = path.relative_to(root).as_posix()
            if rel.startswith("docs/evidence/source-records/"):
                continue
            if rel.startswith("docs/handoffs/"):
                continue
            paths.add(path)
    test_index = root / "mission/tests/jalalabad-air-operations/README.md"
    if test_index.exists():
        paths.add(test_index)
    return sorted(paths)


def validate(root: Path) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    files = iter_scoped_markdown(root)
    docs = root / "docs"
    metadata_by_path: dict[Path, dict[str, object]] = {}
    text_by_path: dict[Path, str] = {}
    ids: defaultdict[str, list[str]] = defaultdict(list)
    numbers: defaultdict[str, list[str]] = defaultdict(list)

    for path in files:
        rel = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8")
        text_by_path[path] = text
        metadata, _ = parse_frontmatter(text)
        metadata_by_path[path] = metadata

        if not metadata:
            is_top_level_doc = path.parent == docs
            if rel in STRICT_METADATA_PATHS or is_top_level_doc:
                errors.append(f"{rel}: missing YAML frontmatter")
            else:
                warnings.append(f"{rel}: subordinate or legacy document has no YAML frontmatter")
            continue

        missing_core = sorted(CORE_KEYS - metadata.keys())
        if missing_core:
            errors.append(f"{rel}: missing core metadata keys: {', '.join(missing_core)}")

        missing_extended = sorted(EXTENDED_KEYS - metadata.keys())
        if missing_extended:
            if rel in STRICT_METADATA_PATHS:
                errors.append(f"{rel}: missing extended metadata keys: {', '.join(missing_extended)}")
            else:
                warnings.append(f"{rel}: legacy metadata gap: {\", \".join(missing_extended)}")

        document_id = str(metadata.get("document_id", "")).strip()
        if document_id:
            ids[document_id].append(rel)

        status = str(metadata.get("status", "")).strip()
        if status and status not in ALLOWED_STATUSES:
            errors.append(f"{rel}: invalid governance status {status!r}")

        source_commit = str(metadata.get("source_commit", "")).strip()
        if source_commit and source_commit not in {"PENDING_MERGE", "GIT_HISTORY"} and not HEX40_RE.fullmatch(source_commit):
            errors.append(f"{rel}: source_commit must be a 40-hex SHA, PENDING_MERGE, GIT_HISTORY, or empty under the migration rule")

        if status == "ACCEPTED_TECHNICAL_BASELINE":
            required_acceptance = {
                "acceptance_branch",
                "acceptance_commit",
                "acceptance_mission",
                "acceptance_mission_sha256",
                "dcs_version",
            }
            missing = sorted(required_acceptance - metadata.keys())
            if missing:
                errors.append(f"{rel}: technical acceptance lacks provenance: {', '.join(missing)}")
            commit = str(metadata.get("acceptance_commit", "")).strip()
            mission_hash = str(metadata.get("acceptance_mission_sha256", "")).strip()
            if commit and not HEX40_RE.fullmatch(commit):
                errors.append(f"{rel}: acceptance_commit must be a full 40-hex SHA")
            if mission_hash and not HEX64_RE.fullmatch(mission_hash):
                errors.append(f"{rel}: acceptance_mission_sha256 must be a 64-hex SHA-256")
            if str(metadata.get("validated_in_dcs", "")).strip().lower() != "true":
                errors.append(f"{rel}: ACCEPTED_TECHNICAL_BASELINE requires validated_in_dcs: true")
            if not (metadata.get("moose_commit") or metadata.get("moose_artifact_sha256")):
                errors.append(f"{rel}: technical acceptance requires moose_commit or moose_artifact_sha256")

        number_match = NUMBERED_DOC_RE.match(path.name)
        if number_match and path.parent == docs:
            numbers[number_match.group(1)].append(rel)

    for document_id, paths in sorted(ids.items()):
        if len(paths) > 1:
            errors.append(f"duplicate document_id {document_id}: {', '.join(paths)}")

    for number, paths in sorted(numbers.items()):
        if len(paths)> 1:
            errors.append(f"duplicate document number {number}: {', '.join(paths)}")

    heading_cache: dict[Path, set[str]] = {}
    for path, text in text_by_path.items():
        rel = path.relative_to(root).as_posix()
        for raw_target in LINK_RE.findall(text):
            target = raw_target.strip().split()[0].strip("<>")
            if not target or target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            target = unquote(target)
            file_part, sep, anchor = target.partition("#")
            resolved = (path.parent / file_part).resolve() if file_part else path.resolve()
            try:
                resolved.relative_to(root.resolve())
            except ValueError:
                errors.append(f"{rel}: relative link escapes repository: {target}")
                continue
            if not resolved.exists():
                errors.append(f"{rel}: dead relative link: {target}")
                continue
            if sep and resolved.is_file() and resolved.suffix.lower() == ".md":
                headings = heading_cache.setdefault(
                    resolved,
                    collect_headings(resolved.read_text(encoding="utf-8")),
                )
                if anchor and anchor not in headings:
                    warnings.append(f"{rel}: unresolved heading anchor {target}")

    return errors, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Operation Mountain Watch documentation metadata and links.")
    parser.add_argument("root", nargs="?", default=".", help="repository root")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    errors, warnings = validate(root)

    for warning in warnings:
        print(f"WARNING: {warning}")
    for error in errors:
        print(f"ERROR: {error}")

    print(f"documentation validation: {len(errors)} error(s), {len(warnings)} warning(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
