#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="${SCRIPT_DIR}/prompts"
CLAUDE="$(/usr/bin/which claude) --dangerously-skip-permissions"

ISSUE_URL="${1:-}"
BASE_BRANCH="${2:-develop}"
MAX_LOOPS=10
PASS_COUNT=0
REQUIRED_PASSES=3

DESIGN_FILE="/tmp/impl_design_$$.txt"

if [[ -z "$ISSUE_URL" ]]; then
  echo "usage: impl <issue_url> [base_branch]" >&2
  exit 1
fi

# Helper to extract result from claude JSON output
extract_result() {
  jq -r '.result // .' "$1"
}

# Run command in background with spinner
run_with_spinner() {
  local output_file="$1"
  shift
  "$@" > "$output_file" &
  local pid=$!

  while kill -0 $pid 2>/dev/null; do
    echo -n "."
    sleep 5
  done
  echo ""

  wait $pid
  return $?
}

echo "=== Auto Implementation Workflow ==="
echo "Issue: $ISSUE_URL"
echo "Base branch: $BASE_BRANCH"
echo ""

# 1. Clarify (interactive)
echo "[1/3] Design clarification..."
$CLAUDE "$(cat "${PROMPTS_DIR}/clarify.md")

ISSUE_URL: $ISSUE_URL
OUTPUT_FILE: $DESIGN_FILE"

if [[ ! -f "$DESIGN_FILE" ]]; then
  echo "Design file not created. Aborting." >&2
  exit 1
fi

# 2. Implement (non-interactive)
echo ""
echo -n "[2/3] Implementing"
run_with_spinner /tmp/impl_result.json $CLAUDE -p "$(cat "${PROMPTS_DIR}/impl.md")

ISSUE_URL: $ISSUE_URL
DESIGN:
$(cat "$DESIGN_FILE")" --output-format json

IMPL_RESULT=$(extract_result /tmp/impl_result.json)
if ! echo "$IMPL_RESULT" | jq -e '.success' > /dev/null 2>&1; then
  echo "Implementation failed. Check /tmp/impl_result.json" >&2
  exit 1
fi

echo "Implementation complete."

# 3. Review loop (non-interactive, separate sessions)
echo ""
echo "[3/3] Review loop..."

for i in $(seq 1 $MAX_LOOPS); do
  echo ""
  echo -n "--- Review iteration $i (pass count: $PASS_COUNT/$REQUIRED_PASSES)"

  # Review in separate session (reviews local commits against base branch)
  run_with_spinner /tmp/review_result.json $CLAUDE -p "$(cat "${PROMPTS_DIR}/review.md")

BASE_BRANCH: $BASE_BRANCH" --output-format json

  REVIEW_RESULT=$(extract_result /tmp/review_result.json)
  HAS_ISSUES=$(echo "$REVIEW_RESULT" | jq -r '.has_issues // "true"')

  if [[ "$HAS_ISSUES" == "false" ]]; then
    PASS_COUNT=$((PASS_COUNT + 1))
    echo "No issues found. Pass count: $PASS_COUNT/$REQUIRED_PASSES"

    if [[ $PASS_COUNT -ge $REQUIRED_PASSES ]]; then
      echo ""
      echo "=== Workflow Complete ==="
      echo ""
      echo "All reviews passed. Please:"
      echo "1. Verify the changes locally"
      echo "2. Run tests"
      echo "3. Push and create PR manually"
      rm -f "$DESIGN_FILE"
      exit 0
    fi
  else
    PASS_COUNT=0
    echo -n "Issues found. Fixing"

    # Fix in separate session
    run_with_spinner /tmp/fix_result.json $CLAUDE -p "$(cat "${PROMPTS_DIR}/fix.md")

REVIEW_RESULT: $REVIEW_RESULT" --output-format json
  fi
done

echo ""
echo "=== Max iterations reached ===" >&2
echo "Please review manually." >&2
rm -f "$DESIGN_FILE"
exit 1
