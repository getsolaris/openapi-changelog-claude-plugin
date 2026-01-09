# OpenAPI Changelog Plugin

A Claude Code plugin that detects changes in OpenAPI/Swagger spec files using Git diff and generates a changelog in Markdown format.

## Installation

### From Marketplace (Recommended)

```bash
# Add the marketplace
/plugin marketplace add getsolaris/openapi-changelog-claude-plugin

# Install the plugin
/plugin install openapi-changelog@openapi-changelog
```

### From GitHub URL

```bash
/plugin marketplace add https://github.com/getsolaris/openapi-changelog-claude-plugin.git
/plugin install openapi-changelog@openapi-changelog
```

### Manual Installation

Clone the repository to your Claude Code plugins directory:

```bash
git clone https://github.com/getsolaris/openapi-changelog-claude-plugin.git ~/.claude/plugins/openapi-changelog
```

Then restart Claude Code or run `/plugin refresh`.

## Features

- Git diff-based OpenAPI spec change detection
- Date-based versioning (YYYY-MM-DD)
- Latest changes displayed at the top
- Change categorization (Added/Modified/Deprecated/Removed)
- Breaking Changes section
- Language detection from spec for summary generation

## Quick Start

```bash
# Generate/update changelog
/openapi-changelog

# Specify spec file
/openapi-changelog swagger.json

# Specify output path
/openapi-changelog --output docs/CHANGELOG.md

# Compare with specific commit
/openapi-changelog --from HEAD~5
```

## Output Format

`api-changelog.md` file is created in the project root:

```markdown
# API Changelog

Records changes to the OpenAPI spec.

---

## [2026-01-09]

> Added user authentication API and modified order response schema.

### Added
- `POST /auth/login` - Added login endpoint
- `POST /auth/refresh` - Added token refresh endpoint

### Modified
- `OrderResponse.status` - Added enum values

### Deprecated
- `DELETE /users/{id}` - Please migrate to v2 API

### Removed
- `GET /legacy/users` - Removed legacy users API

### Breaking Changes
- `GET /legacy/users` endpoint removed

---
```

## Swagger UI Integration

To display the changelog in Swagger UI, add the following code to your framework's Swagger configuration.

### NestJS

```typescript
import * as fs from 'fs';

const config = new DocumentBuilder()
  .setTitle('API')
  .setDescription('API description')
  .setVersion('1.0')
  .addTag('Changelog', fs.readFileSync('./api-changelog.md', 'utf8'))
  .build();
```

### Spring Boot (Java)

```java
import io.swagger.v3.oas.models.tags.Tag;
import java.nio.file.Files;
import java.nio.file.Path;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI customOpenAPI() throws Exception {
        String changelog = Files.readString(Path.of("api-changelog.md"));
        return new OpenAPI()
            .info(new Info()
                .title("API")
                .description("API description")
                .version("1.0"))
            .addTagsItem(new Tag().name("Changelog").description(changelog));
    }
}
```

### Spring Boot (Kotlin)

```kotlin
import io.swagger.v3.oas.models.tags.Tag
import java.nio.file.Files
import java.nio.file.Path

@Configuration
class OpenApiConfig {
    @Bean
    fun customOpenAPI(): OpenAPI {
        val changelog = Files.readString(Path.of("api-changelog.md"))
        return OpenAPI()
            .info(Info()
                .title("API")
                .description("API description")
                .version("1.0"))
            .addTagsItem(Tag().name("Changelog").description(changelog))
    }
}
```

### FastAPI

```python
from fastapi import FastAPI
from pathlib import Path

changelog_content = Path("api-changelog.md").read_text(encoding="utf-8")

app = FastAPI(
    title="API",
    description="API description",
    version="1.0.0",
    openapi_tags=[
        {"name": "Changelog", "description": changelog_content}
    ]
)
```

### Express + swagger-jsdoc

```javascript
const fs = require('fs');
const path = require('path');

const changelogContent = fs.readFileSync(path.join(__dirname, 'api-changelog.md'), 'utf8');

const swaggerSpec = {
  openapi: '3.0.0',
  info: {
    title: 'API',
    description: 'API description',
    version: '1.0.0'
  },
  tags: [
    { name: 'Changelog', description: changelogContent }
  ]
};
```

## Change Types

| Section | Description |
|---------|-------------|
| Added | Newly added endpoints, schemas, parameters |
| Modified | Changes to existing items |
| Deprecated | Items marked as deprecated |
| Removed | Deleted items |
| Breaking Changes | Changes that break backward compatibility |

## Breaking Change Detection

The following changes are automatically marked as Breaking Changes:
- Endpoint removal
- Required parameter addition
- Response field removal
- Parameter/field type change
- Required field addition

## Workflow

```
1. Develop and modify APIs
2. /openapi-changelog          # Generate/update changelog
3. git commit                  # Commit changes
4. View changelog in Swagger UI (as "Changelog" tag)
```

## Requirements

- Run within a Git repository
- OpenAPI 3.x or Swagger 2.x spec file
