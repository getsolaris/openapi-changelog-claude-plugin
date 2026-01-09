---
description: "Generate changelog Markdown from OpenAPI spec changes using Git diff"
argument-hint: "[spec-file] [--output <path>] [--from <commit>]"
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]
---

# /openapi-changelog - OpenAPI Changelog Generator

Analyzes OpenAPI/Swagger spec file changes using Git diff and records them in `api-changelog.md`.

## Arguments

User provided arguments: $ARGUMENTS

## Usage

```bash
# Basic usage (auto-detect spec file)
/openapi-changelog

# Specify file
/openapi-changelog swagger.json

# Specify output path
/openapi-changelog --output docs/CHANGELOG.md

# Compare with specific commit
/openapi-changelog --from HEAD~5
/openapi-changelog --from abc1234
```

---

## Execution Flow

### Step 1: Detect OpenAPI Spec File

If no file is provided as argument, auto-detect in this priority order:

```
1. swagger.json
2. openapi.json
3. openapi.yaml
4. openapi.yml
5. swagger.yaml
6. swagger.yml
7. **/swagger.json (subdirectories)
8. **/openapi.json (subdirectories)
```

Use Glob tool to check file existence and use the first found file.

### Step 2: Check Git Status

```bash
git status --porcelain -- <spec-file>
git diff --name-only HEAD~1 -- <spec-file>
```

If no changes, output "No changes detected" and exit.

### Step 3: Compare Previous/Current Versions

**If there are staged or unstaged changes:**
```bash
# Read current file
cat <spec-file>

# Get previous version (HEAD)
git show HEAD:<spec-file>
```

**If --from option is provided:**
```bash
git show <from-commit>:<spec-file>
```

### Step 4: Analyze and Compare OpenAPI Spec

Compare the two versions and extract:

#### Endpoint Changes (paths)
- New paths/methods added → Added
- Paths/methods deleted → Removed
- Modified paths (parameters, responses, etc.) → Modified
- deprecated added → Deprecated

#### Schema Changes (components/schemas or definitions)
- New schema added → Added
- Schema deleted → Removed
- Field added/deleted/type changed → Modified

#### Parameter Changes
- Query/header/path parameters added/deleted/modified

#### Security Changes
- securitySchemes changes

#### Metadata Changes
- info, tags, servers, etc.

### Step 5: Generate Change Summary

Detect the language of the spec's description field and write summary in the same language.
If Korean is detected, write in Korean; if English, write in English.

Summary should be concise, 1-2 sentences:
- Example: "Added user authentication API and modified order response schema."

### Step 6: Create/Update Changelog Markdown

**Determine output file path:**
- Use path from `--output` option if provided
- Otherwise use `api-changelog.md` in project root

**If file exists:**
1. Parse existing Markdown
2. If a version section for today's date exists, update that section
3. If new date, add new version section right after the title (latest on top)

**If new file:**
Create new changelog structure

### Step 7: Markdown Output Format

```markdown
# API Changelog

Records changes to the OpenAPI spec.

---

## [2026-01-09]

> Added user authentication API and modified order response schema.

### Added
- `POST /auth/login` - Added login endpoint
- `POST /auth/refresh` - Added token refresh endpoint
- `UserResponse` schema added

### Modified
- `OrderResponse.status` - Added enum values: `pending`, `processing`, `completed`
- `GET /products` - Added `category` query parameter

### Deprecated
- `DELETE /users/{id}` - Please migrate to v2 API

### Removed
- `GET /legacy/users` - Removed legacy users API

### Breaking Changes
- `GET /legacy/users` endpoint removed
- `OrderRequest.legacyField` field removed

---

## [2026-01-08]

> Improved product search functionality.

### Modified
- `GET /products` - Added search filter options

---
```

### Step 8: Output Results

```
📋 OpenAPI Changelog Generated

🔍 Spec file: <spec-file>
📊 Comparing: <from-commit> → <to-commit>

## Change Summary
<summary>

### ➕ Added (<count>)
- `<METHOD> <path>` - <description>

### ✏️ Modified (<count>)
- `<name>.<field>` - <description>

### ⚠️ Deprecated (<count>)
- `<METHOD> <path>` - <description>

### 🗑️ Removed (<count>)
- `<METHOD> <path>` - <description>

✅ api-changelog.md updated
```

---

## Breaking Change Detection

The following changes are marked separately in the Breaking Changes section:
- Endpoint removal
- Required parameter addition
- Response field removal
- Parameter/field type change
- Required field addition

## Markdown Parsing Rules

When updating existing file:
1. Keep `# API Changelog` title
2. Separate version sections with `---`
3. Version heading format: `## [YYYY-MM-DD]`
4. If same date version exists, replace that section content
5. If new date, insert new section after first `---`

## Error Handling

- Not a Git repository: "Please run in a Git repository"
- Spec file not found: "Could not find OpenAPI spec file"
- No changes: "No changes detected"
- JSON/YAML parsing error: Abort with error message
