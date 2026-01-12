# Instructions Directory

This directory contains instruction files for GitHub Copilot and other automation tools.

## File Naming Convention

- **`.instructions.md`** - Files with this extension are automatically discovered and loaded by GitHub Copilot's coding agent
- **`.excluded.md`** - Files with this extension are excluded from automatic discovery by the coding agent

## Currently Active Instructions

- `armapi-review.instructions.md` - ARM OpenAPI (Swagger) review instructions for Azure Resource Manager specifications

## Excluded Instructions

The following instruction files have been renamed to `.excluded.md` to prevent the coding agent from automatically loading them:

- `dp-migration.excluded.md` - Data plane migration instructions
- `github-codingagent.excluded.md` - GitHub coding agent instructions
- `language-emitter.excluded.md` - Language emitter instructions
- `mgmt-migration.excluded.md` - Management plane migration instructions
- `openapi-review.excluded.md` - OpenAPI review instructions
- `sdk-generation.excluded.md` - SDK generation instructions
- `typespec-project.excluded.md` - TypeSpec project instructions

## Purpose

This configuration ensures that the GitHub Copilot coding agent only loads and applies the ARM API review instructions, preventing conflicts and confusion from multiple instruction sets being active simultaneously.

To re-enable any excluded instruction file, simply rename it back to use the `.instructions.md` extension.
