#!/usr/bin/env bash
# PostToolUse-Hook: läuft nach Write/Edit auf einer Ruby-Datei und korrigiert
# sie mit RuboCop (-a, sicherer Autocorrect) im Projekt-Stil (rubocop-rails-omakase).
# Nicht-Ruby-Dateien und nicht existierende Pfade werden übersprungen.
set -euo pipefail

input=$(cat)

# Pfad robust ermitteln: PostToolUse liefert ihn je nach Tool in file_path bzw. tool_response.filePath.
f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -n "$f" ] && [ -f "$f" ] || exit 0

# Nur Ruby-Dateien anfassen.
case "${f##*/}" in
  *.rb|*.rake|*.ru|Gemfile|Rakefile|*.gemspec) ;;
  *) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-.}"

# -a = sicherer Autocorrect. Ausgabe als systemMessage zurückmelden; nie den Turn blockieren.
out=$(bin/rubocop -a "$f" 2>&1) || true
jq -nc --arg msg "RuboCop -a auf ${f##*/}:"$'\n'"$out" \
  '{systemMessage: $msg, suppressOutput: true}'
exit 0
