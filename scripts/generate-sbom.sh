#!/usr/bin/env bash
set -euo pipefail

# Generates a lightweight SBOM artifact from dependency-report.json when present.
# If the report is absent, emits an empty dependency list while preserving schema.

mkdir -p artifacts

python3 - <<'PY'
from datetime import datetime, timezone
import json
import os

report_path = 'dependency-report.json'
out_path = 'artifacts/sbom.json'

deps = []
if os.path.exists(report_path):
    report = json.load(open(report_path))
    deps = report.get('dependencies', [])

sbom = {
    'project': 'Spline',
    'generatedAt': datetime.now(timezone.utc).isoformat(),
    'dependencies': deps
}

json.dump(sbom, open(out_path, 'w'), indent=2)
print('Wrote', out_path)
PY
