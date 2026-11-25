---
name: sync-project-skills
description: >-
  Synchronize Impal-02-07 workspace skills, rules, living memory, feature logs,
  and roadmap whenever backend routes, controllers, database schemas, or project
  conventions change. Use after any meaningful backend or architecture edit.
---

# Sync Project Skills & Agent Memory Protocol

Run this 5-step synchronization loop whenever backend code, database schema, API contracts, or engineering conventions change in `Impal-02-07`.

## 5-Step Update Loop

1. **Detect Drift:**
   - Run the live DB schema inspector from `Impal-02-07/backend/`:
     ```powershell
     dart run --packages=.dart_tool/package_config.json ../.agents/skills/impal-backend-engineer/scripts/introspect_schema.dart
     ```
   - Compare active routes in `backend/bin/server.dart` and `backend/lib/routes/` against documentation.

2. **Update Project Skills & References:**
   - If live PostgreSQL columns, types, constraints, or indexes changed, regenerate the snapshot:
     ```powershell
     dart run --packages=.dart_tool/package_config.json ../.agents/skills/impal-backend-engineer/scripts/introspect_schema.dart --write
     ```
   - Update `../impal-backend-engineer/SKILL.md` if workflow steps, patterns, or verification commands changed.
   - Keep `SKILL.md` concise (progressive disclosure): move bulky tables/schemas into `references/`.

3. **Update Rules & Living Memory:**
   - Update `.agents/rules/backend_dart_frog_rules.md` when new backend standards are introduced (and ensure any new `.agents/rules/*.md` is registered in `.agents/rules/README.md`).
   - Record new API contracts, schema conventions, or status mappings in `.agents/memory/project_conventions.md`.
   - Record newly discovered bugs or forbidden practices in `.agents/memory/anti_patterns.md`.
   - Keep `AGENTS.md` strictly under **24,000 bytes** and free of hardcoded personal machine paths.

4. **Update Feature Logs & Roadmap:**
   - Create or update `.agents/features/<feature_name>.md` with changed files, technical summary, schema alignment, and `.agents/cybersecurity.md` compliance.
   - Update `ROADMAP_AUDIT_DAN_PENINGKATAN.md` with completed items and next priority backlog.

5. **Validate Sync:**
   - Run the automated sync validator from `Impal-02-07/backend/`:
     ```powershell
     dart run ../.agents/skills/sync-project-skills/scripts/validate_agent_sync.dart
     ```
   - Ensure exit code is `0` before reporting completion.
