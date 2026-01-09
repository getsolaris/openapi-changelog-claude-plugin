---
name: openapi-diff
description: >
  This skill should be used when analyzing differences between two OpenAPI/Swagger spec versions,
  comparing API specifications, detecting breaking changes in APIs, or generating API changelogs.
  Triggers: "compare OpenAPI", "API diff", "spec changes", "breaking changes", "API changelog"
version: 1.0.0
---

# OpenAPI Diff Analysis Skill

Compares two versions of OpenAPI/Swagger specs and extracts changes in a structured format.

## When This Skill Applies

- Analyzing differences between OpenAPI spec files
- Tracking API changes
- Detecting breaking changes
- Diff analysis for changelog generation

## OpenAPI Spec Structure Reference

### OpenAPI 3.x Structure
```yaml
openapi: "3.0.0"
info:
  title: API Title
  version: "1.0.0"
  description: API description
servers:
  - url: https://api.example.com
paths:
  /resource:
    get:
      summary: Get resource
      parameters: []
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
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
```

### Swagger 2.x Structure
```yaml
swagger: "2.0"
info:
  title: API Title
  version: "1.0.0"
basePath: /api
paths:
  /resource:
    get:
      summary: Get resource
      parameters: []
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
securityDefinitions:
  bearerAuth:
    type: apiKey
```

## Diff Analysis Categories

### 1. Endpoint Changes (paths)

**Addition detection:**
```
oldSpec.paths['/new-endpoint'] = undefined
newSpec.paths['/new-endpoint'] = { get: {...} }
→ { type: "added", category: "endpoint", path: "/new-endpoint", method: "GET" }
```

**Removal detection (Breaking):**
```
oldSpec.paths['/old-endpoint'] = { get: {...} }
newSpec.paths['/old-endpoint'] = undefined
→ { type: "removed", category: "endpoint", path: "/old-endpoint", method: "GET", breaking: true }
```

**Method addition/removal:**
```
oldSpec.paths['/resource'].get = {...}
newSpec.paths['/resource'].get = {...}
newSpec.paths['/resource'].post = {...}  // newly added
→ { type: "added", category: "endpoint", path: "/resource", method: "POST" }
```

**Deprecated change:**
```
oldSpec.paths['/resource'].get.deprecated = undefined
newSpec.paths['/resource'].get.deprecated = true
→ { type: "deprecated", category: "endpoint", path: "/resource", method: "GET" }
```

### 2. Schema Changes (components/schemas or definitions)

**Schema addition:**
```
newSpec.components.schemas['NewSchema'] = {...}
→ { type: "added", category: "schema", name: "NewSchema" }
```

**Field addition:**
```
newSpec.components.schemas.User.properties.email = { type: "string" }
→ { type: "modified", category: "schema", name: "User", field: "email",
   description: "Field added: email (string)" }
```

**Field removal (Breaking):**
```
oldSpec.components.schemas.User.properties.legacyField = {...}
not in newSpec
→ { type: "modified", category: "schema", name: "User", field: "legacyField",
   description: "Field removed: legacyField", breaking: true }
```

**Type change (Breaking):**
```
oldSpec: { type: "string" }
newSpec: { type: "integer" }
→ { type: "modified", category: "schema", name: "User", field: "age",
   description: "Type changed: string → integer", breaking: true }
```

**Required change (Breaking if added):**
```
oldSpec.components.schemas.User.required = ["id"]
newSpec.components.schemas.User.required = ["id", "email"]
→ { type: "modified", category: "schema", name: "User", field: "email",
   description: "Changed to required field", breaking: true }
```

### 3. Parameter Changes

**Parameter addition:**
```
newSpec.paths['/users'].get.parameters has new parameter added
→ { type: "added", category: "parameter", path: "/users", method: "GET",
   name: "filter", description: "Query parameter added: filter" }
```

**Required parameter addition (Breaking):**
```
newSpec has parameter added with required: true
→ { type: "added", category: "parameter", ..., breaking: true }
```

**Parameter removal:**
```
Parameter in oldSpec not in newSpec
→ { type: "removed", category: "parameter", ... }
```

### 4. Security Changes

**Security scheme addition:**
```
newSpec.components.securitySchemes.oauth2 = {...}
→ { type: "added", category: "security", name: "oauth2" }
```

**Security requirement change:**
```
security array changed for endpoint
→ { type: "modified", category: "security", path: "/resource", method: "GET" }
```

### 5. Metadata Changes

**API version change:**
```
oldSpec.info.version = "1.0.0"
newSpec.info.version = "2.0.0"
→ { type: "modified", category: "metadata", field: "version",
   description: "API version: 1.0.0 → 2.0.0" }
```

**Server URL change:**
```
servers array changed
→ { type: "modified", category: "metadata", field: "servers" }
```

## Breaking Change Detection Rules

The following changes are automatically marked as `breaking: true`:

1. **Endpoint removal**: Existing API removed
2. **Required parameter addition**: Causes client call failures
3. **Response field removal**: Causes client parsing failures
4. **Type change**: Incompatible data format
5. **Required field addition**: Causes existing request failures
6. **Enum value removal**: Existing values become invalid
7. **URL path change**: Causes existing call failures

## Language Detection for Summary

Analyze info.description or the first endpoint's summary from spec:

```javascript
// Check for Korean characters
const hasKorean = /[\uac00-\ud7af]/.test(text);
const language = hasKorean ? 'ko' : 'en';
```

## Output Format (Markdown)

Analysis results are output in Markdown format:

```markdown
## [2026-01-09]

> Added user authentication API and modified order response schema.

### Added
- `POST /auth/login` - Added login endpoint
- `UserResponse` schema added

### Modified
- `UserResponse.status` - Added enum values: `active`, `inactive`, `pending`

### Deprecated
- `DELETE /users/{id}` - Please migrate to v2 API

### Removed
- `GET /legacy/users` - Removed legacy users API

### Breaking Changes
- `GET /legacy/users` endpoint removed
- `OrderRequest.legacyField` field removed
```

### Internal Analysis Structure

```
{
  changes: [
    { type: "added", category: "endpoint", path: "/auth/login", method: "POST", description: "...", breaking: false },
    { type: "removed", category: "endpoint", path: "/legacy/users", method: "GET", description: "...", breaking: true }
  ],
  summary: { added: 5, modified: 3, deprecated: 1, removed: 2, breaking: 2 }
}
```

## Comparison Algorithm

1. **Parse both specs** (JSON/YAML)
2. **Compare paths** object keys and values
3. **Compare components/schemas** or definitions
4. **Compare parameters** for each operation
5. **Compare security** schemes and requirements
6. **Compare info** and server metadata
7. **Classify each difference** by type and category
8. **Detect breaking changes** using rules
9. **Generate descriptions** in detected language
10. **Return structured diff** result
