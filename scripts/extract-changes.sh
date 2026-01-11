#!/bin/bash
# Extract API-related changes from git diff
# Usage: ./extract-changes.sh [--from <commit>] [--spec <file>]

FROM_COMMIT="HEAD~1"
SPEC_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --from) FROM_COMMIT="$2"; shift 2 ;;
    --spec) SPEC_FILE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# Auto-detect spec file if not provided
if [[ -z "$SPEC_FILE" ]]; then
  for f in swagger.json openapi.json openapi.yaml openapi.yml swagger.yaml swagger.yml; do
    [[ -f "$f" ]] && SPEC_FILE="$f" && break
  done
fi

echo "=== API CHANGE SUMMARY ==="
echo "FROM: $FROM_COMMIT"
echo "TO: HEAD"
echo ""

# Mode A: Spec file analysis
if [[ -n "$SPEC_FILE" && -f "$SPEC_FILE" ]]; then
  echo "MODE: SPEC_FILE"
  echo "FILE: $SPEC_FILE"
  echo ""

  # Check if spec file changed
  if git diff --quiet "$FROM_COMMIT" -- "$SPEC_FILE" 2>/dev/null; then
    echo "STATUS: NO_CHANGES"
    exit 0
  fi

  echo "STATUS: CHANGED"
  echo ""
  echo "=== SPEC DIFF (paths/schemas only) ==="

  # Extract only paths and schemas changes using diff
  git diff "$FROM_COMMIT" -- "$SPEC_FILE" | grep -E '^\+|^\-' | grep -E '"(/|paths|schemas|definitions|components)' | head -100

  exit 0
fi

# Mode B: Source code analysis
echo "MODE: SOURCE_CODE"
echo ""

# API-related file patterns
API_PATTERNS="controller|route|endpoint|api|handler|resolver|dto|schema|model|entity|request|response"

# Get changed files matching API patterns
echo "=== CHANGED API FILES ==="
CHANGED_FILES=$(git diff --name-only "$FROM_COMMIT" 2>/dev/null | grep -iE "$API_PATTERNS" | head -20)

if [[ -z "$CHANGED_FILES" ]]; then
  echo "STATUS: NO_API_CHANGES"
  exit 0
fi

echo "$CHANGED_FILES"
echo ""
echo "=== CHANGES BY FILE ==="

# For each API file, extract key changes (decorators, routes, fields)
for file in $CHANGED_FILES; do
  echo ""
  echo "--- $file ---"

  # Extract only added/removed lines with API indicators
  git diff "$FROM_COMMIT" -- "$file" 2>/dev/null | \
    grep -E '^\+|^\-' | \
    grep -iE '@(Get|Post|Put|Delete|Patch|Api|Schema|Field|Column|Property|Route|Controller|Injectable|Service|Mapping|Request|Response|Param|Query|Body|Header)|class |interface |type |def |func |function |router\.|app\.' | \
    head -30
done

echo ""
echo "=== END ==="
