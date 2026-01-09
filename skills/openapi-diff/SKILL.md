---
name: openapi-diff
description: >
  This skill should be used when analyzing differences between two OpenAPI/Swagger spec versions,
  comparing API specifications, detecting breaking changes in APIs, generating API changelogs,
  or analyzing source code changes for API definitions.
  Triggers: "compare OpenAPI", "API diff", "spec changes", "breaking changes", "API changelog",
  "controller changes", "DTO changes", "API changes"
version: 1.0.0
---

# OpenAPI Diff Analysis Skill

Compares two versions of OpenAPI/Swagger specs or source code and extracts API changes.

## When This Skill Applies

- Analyzing differences between OpenAPI spec files
- Analyzing source code changes for API definitions
- Tracking API changes
- Detecting breaking changes
- Diff analysis for changelog generation

## Analysis Modes

### Mode A: Spec File Analysis
For projects with static OpenAPI/Swagger spec files (swagger.json, openapi.yaml).

### Mode B: Source Code Analysis
For projects where specs are generated at runtime. LLM analyzes git diff to extract API changes from any framework or language.

## OpenAPI Spec Structure Reference

### OpenAPI 3.x
```yaml
openapi: "3.0.0"
info:
  title: API Title
  version: "1.0.0"
paths:
  /resource:
    get:
      summary: Get resource
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Resource'
components:
  schemas:
    Resource:
      type: object
      properties:
        id:
          type: string
```

### Swagger 2.x
```yaml
swagger: "2.0"
info:
  title: API Title
  version: "1.0.0"
paths:
  /resource:
    get:
      responses:
        '200':
          schema:
            $ref: '#/definitions/Resource'
definitions:
  Resource:
    type: object
    properties:
      id:
        type: string
```

## Change Detection

### What to Look For in Diffs

**Endpoint Changes:**
- Added/removed route definitions
- Changed HTTP methods
- Modified route paths
- Changed request/response types

**Schema/DTO Changes:**
- Added/removed fields
- Type changes
- Required/optional changes
- Validation rule changes

**Parameter Changes:**
- Query parameters
- Path parameters
- Header parameters
- Body parameters

**Deprecation:**
- Deprecated flags or annotations
- Deprecated comments

## Breaking Change Rules

The following are automatically marked as breaking changes:

1. **Endpoint removal** - Existing API removed
2. **Required parameter addition** - Causes client call failures
3. **Response field removal** - Causes client parsing failures
4. **Type change** - Incompatible data format
5. **Required field addition** - Causes existing request failures
6. **Enum value removal** - Existing values become invalid
7. **URL path change** - Causes existing call failures

## Output Format

```markdown
## [2026-01-09]

> Brief summary of changes

### Added
- `POST /auth/login` - Added login endpoint
- `UserResponse` schema added

### Modified
- `UserResponse.status` - Added enum values

### Deprecated
- `DELETE /users/{id}` - Please migrate to v2 API

### Removed
- `GET /legacy/users` - Removed legacy users API

### Breaking Changes
- `GET /legacy/users` endpoint removed
- `OrderRequest.legacyField` field removed
```

## Language Detection

Detect language from spec description or code comments:
- If Korean characters detected → write in Korean
- Otherwise → write in English

## Comparison Algorithm

### For Spec Files:
1. Parse both specs (JSON/YAML)
2. Compare paths, schemas, parameters
3. Classify differences by type
4. Detect breaking changes
5. Generate descriptions

### For Source Code:
1. Get changed files from git diff
2. Read diff content
3. Analyze for API-related changes
4. Classify differences by type
5. Detect breaking changes
6. Generate descriptions
