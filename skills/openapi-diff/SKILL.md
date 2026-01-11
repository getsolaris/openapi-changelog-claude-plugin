---
name: openapi-diff
description: "Analyze OpenAPI/Swagger spec or source code changes. Triggers: API diff, spec changes, breaking changes, changelog"
version: 1.0.0
---

# OpenAPI Diff Skill

## Modes
- **Spec File**: Compare swagger.json/openapi.yaml versions
- **Source Code**: Analyze git diff for API decorators/annotations

## Spec Structure
```yaml
# OpenAPI 3.x: paths → components/schemas
# Swagger 2.x: paths → definitions
```

## Change Detection

| Type | Look For |
|------|----------|
| Endpoints | Routes, HTTP methods, paths, req/res types |
| Schemas | Fields, types, required/optional, validations |
| Parameters | Query, path, header, body params |
| Deprecation | @deprecated, deprecated flags |

## Breaking Changes (Auto-flag)
1. Endpoint removal
2. Required param/field addition
3. Response field removal
4. Type change
5. Enum value removal
6. URL path change

## Algorithm
Spec: Parse JSON/YAML → Compare paths/schemas → Classify → Detect breaking
Source: git diff → Analyze decorators → Classify → Detect breaking

## Language
Korean chars in code/spec → Korean output | Otherwise → English
