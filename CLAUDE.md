# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin that generates API changelogs from OpenAPI/Swagger spec changes using Git diff. It outputs `api-changelog.md` with categorized changes (Added/Modified/Deprecated/Removed/Breaking Changes).

## Plugin Architecture

```
openapi-changelog/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest (name, version, author)
│   └── marketplace.json     # Marketplace registration
├── commands/
│   └── openapi-changelog.md # Main command definition (/openapi-changelog)
├── skills/
│   └── openapi-diff/
│       └── SKILL.md         # OpenAPI diff analysis skill
└── README.md                # User documentation with framework integration examples
```

## Analysis Modes

**Mode A (Spec File)**: Analyzes static swagger.json/openapi.yaml files by comparing git versions.

**Mode B (Source Code Fallback)**: When no spec file exists, analyzes git diff of source code (controllers, DTOs) to extract API changes. LLM interprets decorators/annotations from any framework.

## Key Files

- `commands/openapi-changelog.md`: Defines the `/openapi-changelog` command with execution flow, argument parsing, and output format
- `skills/openapi-diff/SKILL.md`: Knowledge base for OpenAPI spec structures, breaking change rules, and diff analysis patterns

## Commit Convention

Use English conventional commits:
```
feat: Add new feature
fix: Bug fix
docs: Documentation changes
refactor: Code refactoring
```
