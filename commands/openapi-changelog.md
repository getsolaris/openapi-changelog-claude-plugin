---
description: "Generate API changelog from OpenAPI spec or source code changes via Git diff"
argument-hint: "[spec-file] [--output <path>] [--from <commit>]"
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]
---

# /openapi-changelog

Args: $ARGUMENTS

## Flow

### 1. Run Extraction Script

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/extract-changes.sh [--from <commit>] [--spec <file>]
```

Script outputs:
- `MODE`: SPEC_FILE or SOURCE_CODE
- `STATUS`: CHANGED, NO_CHANGES, or NO_API_CHANGES
- `CHANGED API FILES`: List of relevant files
- `CHANGES BY FILE`: Filtered diff (decorators, routes, schemas only)

### 2. Analyze Script Output

If `STATUS: NO_CHANGES` or `NO_API_CHANGES` → Report "No API changes detected" and exit

### 3. Classify Changes

| Category | Criteria |
|----------|----------|
| Added | New endpoints, schemas, fields, params |
| Modified | Changed types, validations, responses |
| Deprecated | Deprecated flags/annotations |
| Removed | Deleted endpoints, schemas, fields |
| Breaking | Endpoint removal, required param/field added, type change, response field removal |

### 4. Generate Output

- **File**: `--output` path or `api-changelog.md`
- **Format**: `## [YYYY-MM-DD]` → `> Summary` → `### Added/Modified/Deprecated/Removed/Breaking Changes` sections
- **Update**: Same date → replace | New date → prepend
- **Report**: Show counts per category, confirm file updated

### Errors
- Not git repo → "Run in Git repository"
- No changes → "No API changes detected"
