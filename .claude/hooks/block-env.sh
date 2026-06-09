#!/usr/bin/env bash
# PreToolUse-Hook: blockiert jeden Zugriff auf .env-Dateien.
# Greift für Read/Edit/Write (per file_path) und für Bash (per Kommando-Text).
# Gibt bei Treffer eine PreToolUse-"deny"-Entscheidung als JSON aus.
set -euo pipefail

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

deny() {
  jq -nc \
    --arg reason "Zugriff auf .env ist per Hook gesperrt – die Datei enthält Secrets. Nutze Rails Credentials/ENV statt .env auszulesen." \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  exit 0
}

case "$tool" in
  Read|Edit|Write|NotebookEdit)
    f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
    base=${f##*/}
    case "$base" in
      .env|.env.*) deny ;;
    esac
    ;;
  Bash)
    c=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
    # Treffer, wenn ".env" als eigenständiger Pfad-Token vorkommt (nicht z. B. ".envrc" oder "foo.environment")
    if printf '%s' "$c" | grep -qE '(^|[^[:alnum:]_./])\.env($|\.[[:alnum:]]+)?($|[^[:alnum:]])'; then
      deny
    fi
    ;;
esac

# Kein Treffer -> nichts ausgeben, Tool darf normal weiterlaufen.
exit 0
