---
description: "Generate changelog Markdown from OpenAPI spec changes using Git diff"
argument-hint: "[spec-file] [--output <path>] [--from <commit>]"
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]
---

# /openapi-changelog - OpenAPI Changelog Generator

Analyzes OpenAPI/Swagger spec file or source code changes using Git diff and records them in `api-changelog.md`.

## Arguments

User provided arguments: $ARGUMENTS

## Usage

```bash
# Basic usage (auto-detect spec file or source code)
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

### Step 1: Detect Analysis Mode

**Mode A - Spec File Analysis:**
If spec file is provided as argument or auto-detected, use spec file analysis.

Auto-detect spec files in this priority order:
```
1. swagger.json
2. openapi.json
3. openapi.yaml / openapi.yml
4. swagger.yaml / swagger.yml
5. **/swagger.json (subdirectories)
6. **/openapi.json (subdirectories)
7. docs/swagger.json
8. docs/openapi.json
```

**Mode B - Source Code Analysis (Fallback):**
If no spec file found, analyze git diff of changed source code files to extract API changes.

---

## Mode A: Spec File Analysis

### Step A1: Check Git Status

```bash
git status --porcelain -- <spec-file>
git diff --name-only HEAD~1 -- <spec-file>
```

If no changes, output "No changes detected" and exit.

### Step A2: Compare Previous/Current Versions

```bash
# Current version
cat <spec-file>

# Previous version (HEAD or --from commit)
git show HEAD:<spec-file>
# or
git show <from-commit>:<spec-file>
```

### Step A3: Analyze Spec Diff

Compare the two JSON/YAML versions and extract:
- Endpoint changes (paths)
- Schema changes (components/schemas or definitions)
- Parameter changes
- Security changes
- Metadata changes

---

## Mode B: Source Code Analysis

### Step B1: Get Changed Files

```bash
# Get all changed files
git diff --name-only HEAD~1

# Or if --from is provided
git diff --name-only <from-commit>
```

### Step B2: Get Diff Content

For each changed file that might contain API definitions (controllers, routes, DTOs, models, schemas):

```bash
git diff HEAD~1 -- <file>
# or
git diff <from-commit> -- <file>
```

### Step B3: Analyze Diff with LLM

Read the diff output and intelligently analyze:

1. **Endpoint Changes**: Look for added/removed/modified route definitions
   - HTTP method decorators/annotations (@Get, @Post, @GetMapping, @app.get, etc.)
   - Route paths
   - Request/response types

2. **Schema/DTO Changes**: Look for added/removed/modified fields
   - Property decorators (@ApiProperty, @Schema, Field(), etc.)
   - Type changes
   - Required/optional changes
   - Validation changes

3. **Deprecation**: Look for deprecated flags or annotations

4. **Breaking Changes**: Identify changes that break backward compatibility
   - Removed endpoints
   - Removed required fields
   - Type changes
   - Added required parameters

The LLM should understand various frameworks and languages:
- TypeScript/JavaScript (NestJS, Express, Fastify)
- Java/Kotlin (Spring Boot)
- Python (FastAPI, Flask, Django)
- Go (Gin, Echo)
- Ruby (Rails)
- PHP (Laravel)
- And others

---

## Change Categories

### Added
- New endpoints
- New schemas/DTOs
- New fields
- New parameters

### Modified
- Changed parameters
- Changed field types
- Changed validation rules
- Changed response types

### Deprecated
- Endpoints marked as deprecated
- Fields marked as deprecated

### Removed
- Deleted endpoints
- Deleted schemas
- Deleted fields

### Breaking Changes
- Endpoint removal
- Required parameter addition
- Required field addition
- Field type change
- Response field removal

---

## Step 4: Generate Change Summary

Detect the language from source code comments or descriptions.
Write summary in the same language (Korean or English).

Summary should be concise, 1-2 sentences:
- Example: "Added user authentication API and modified order response schema."
- Example (Korean): "사용자 인증 API 추가 및 주문 응답 스키마 수정"

---

## Step 5: Create/Update Changelog Markdown

**Determine output file path:**
- Use path from `--output` option if provided
- Otherwise use `api-changelog.md` in project root

**If file exists:**
1. Parse existing Markdown
2. If a version section for today's date exists, update that section
3. If new date, add new version section right after the title (latest on top)

**If new file:**
Create new changelog structure

---

## Step 6: Markdown Output Format

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
```

---

## Step 7: Output Results

**For Spec File Analysis:**
```
📋 OpenAPI Changelog Generated

🔍 Spec file: <spec-file>
📊 Comparing: <from-commit> → <to-commit>

## Change Summary
<summary>

### ➕ Added (<count>)
### ✏️ Modified (<count>)
### ⚠️ Deprecated (<count>)
### 🗑️ Removed (<count>)

✅ api-changelog.md updated
```

**For Source Code Analysis:**
```
📋 OpenAPI Changelog Generated (Source Code Analysis)

📁 Analyzed files: <count> files
📊 Comparing: <from-commit> → <to-commit>

## Change Summary
<summary>

### ➕ Added (<count>)
### ✏️ Modified (<count>)
### ⚠️ Deprecated (<count>)
### 🗑️ Removed (<count>)

✅ api-changelog.md updated
```

---

## Markdown Parsing Rules

When updating existing file:
1. Keep `# API Changelog` title
2. Separate version sections with `---`
3. Version heading format: `## [YYYY-MM-DD]`
4. If same date version exists, replace that section content
5. If new date, insert new section after first `---`

## Error Handling

- Not a Git repository: "Please run in a Git repository"
- No spec file and no code changes: "No API changes detected"
- No changes: "No changes detected"
- JSON/YAML parsing error: Abort with error message
