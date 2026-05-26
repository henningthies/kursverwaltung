#!/usr/bin/env bash
# PreToolUse-Hook: blockt Lese-/Schreibzugriff auf Secret-Dateien.
# Liest das Tool-Event als JSON von stdin, prüft den Ziel-Pfad (bzw. den
# Bash-Befehl) gegen bekannte Secret-Muster und verweigert bei Treffer.
#
# Demo-Material für den Kurs: bewusst klein und lesbar gehalten.
set -euo pipefail

input="$(cat)"

# Pfad aus den üblichen Datei-Tools; bei Bash der ganze Befehl.
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
haystack="$file_path $command"

# Verbotene Secret-Pfade (als Regex, case-sensitiv genug für Demo-Zwecke).
secret_regex='(^|/|[[:space:]])(\.env(\.[A-Za-z0-9_]+)?|config/master\.key|config/credentials([^[:space:]]*)?|\.kamal/secrets)([[:space:]]|$)'

if printf '%s' "$haystack" | grep -Eq "$secret_regex"; then
  reason="Zugriff auf Secret-Dateien (.env, config/master.key, config/credentials*, .kamal/secrets) ist durch den Secrets-Hook blockiert. Diese Dateien gehören nicht in den Tool-Zugriff des Agenten."
  jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
fi

# Kein Treffer → nichts ausgeben, normaler Tool-Ablauf.
exit 0
