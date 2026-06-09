#!/usr/bin/env bash
# Demo-Script für den kr-Skill: zeigt, dass ein Skill Scripts bündeln und
# deterministisch ausführen kann, ohne sie erst in den Kontext zu laden.
set -euo pipefail

echo "Hello, World aus dem kr-Skill! 👋"
echo "Arbeitsverzeichnis: $(pwd)"
echo "Geänderte Dateien gegenüber HEAD:"
git diff --name-only HEAD 2>/dev/null || echo "  (kein Git-Repo erreichbar)"
