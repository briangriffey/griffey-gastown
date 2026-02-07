# Mayor Prompting Quick Reference

> **TL;DR: How to get the Mayor to create parallelized work effectively**

## Basic Template

```markdown
Create [WORK TYPE] for [FEATURE NAME]:

**Phase 1 (Parallel):**
- [Task 1] - [Formula if applicable]
- [Task 2] - [Formula if applicable]

**Phase 2 (Depends on Phase 1, Parallel):**
- [Task 3] - [Formula if applicable]
- [Task 4] - [Formula if applicable]

Create convoy: "[Convoy Name]"
Assign to: [rig-name]
```

## Available Formulas

| Formula | Usage | Creates |
|---------|-------|---------|
| `web-feature` | `feature_name="auth"` | Full-stack feature checklist |
| `web-component` | `component_name="UserCard"` | React component checklist |
| `web-api` | `endpoint_name="users"` | API endpoint checklist |
| `web-app-setup` | (no params) | New web app setup |
| `feature-branch` | `feature_name="dark-mode"` | Feature development workflow |

## Key Phrases

| Say This | Mayor Does This |
|----------|----------------|
| "Create in parallel" | Creates beads with no dependencies |
| "Phase X depends on Phase Y" | Uses `bd dep add` to link phases |
| "Use web-feature formula" | Uses `bd cook web-feature ...` |
| "Create convoy" | Groups beads with `gt convoy create` |
| "Assign to meal-agent" | Uses `gt sling <bead> meal-agent` |

## Dependency Syntax

**In Your Prompt:**
```
Phase 2 depends on Phase 1
Task C needs Task A
Build API after schema is done
```

**Mayor Executes:**
```bash
bd dep add phase2-task phase1-task
bd dep add taskC taskA
bd dep add api-task schema-task
```

**Remember:** `bd dep add <NEEDS> <BLOCKING>` - First arg needs second arg

## Common Patterns

### Independent Features (Parallel)
```markdown
Create these features in parallel:
- Feature A (web-feature formula: feature_name="recipes")
- Feature B (web-feature formula: feature_name="shopping")
- Feature C (web-feature formula: feature_name="meal-plans")

Assign all to meal-agent, create convoy "Sprint 1"
```

### Sequential Phases
```markdown
Database updates (Sequential):
1. Add user_preferences table
2. Add indexes on user_id
3. Migrate existing data

Then API endpoints (Parallel, depends on database):
- GET /api/preferences
- POST /api/preferences
- PUT /api/preferences
```

### Multi-Rig Work
```markdown
Update dependencies across rigs (parallel per rig):

For each rig (meal-agent, other-app):
- Update Next.js to v15
- Update Prisma to v6
- Update TypeScript to v5.4
```

## Checklist

Before sending a prompt, verify:
- [ ] Tasks are clearly defined
- [ ] Dependencies are explicit ("Phase X depends on Y")
- [ ] Formulas are specified where applicable
- [ ] Convoy name provided for grouping
- [ ] Rig assignment included
- [ ] Parallelization is real (tasks don't block each other)

## Anti-Patterns

❌ **Vague:** "Make the app better in parallel"
✅ **Specific:** "Create these 3 API endpoints in parallel: users, posts, comments"

❌ **False parallel:** "Schema, API, UI in parallel" (these depend on each other!)
✅ **True parallel:** "Users API, Posts API, Comments API in parallel"

❌ **Missing deps:** "Create all these tasks" (no structure)
✅ **Clear deps:** "Phase 1: X, Y. Phase 2 (depends on Phase 1): Z"

## Quick Examples

### Feature Implementation
```markdown
Implement user settings feature:

**Database (Priority 1):**
- Add settings table with migration

**Backend (Priority 2, depends on Database):**
- API: GET /api/settings (web-api: endpoint_name="settings")
- API: PUT /api/settings

**Frontend (Priority 2, depends on Database):**
- Component: SettingsForm (web-component: component_name="SettingsForm")
- Component: SettingToggle (web-component: component_name="SettingToggle")

**Integration (Priority 3, depends on Backend + Frontend):**
- Page: /settings
- Tests: E2E settings flow

Convoy: "User Settings"
Assign to: meal-agent
```

### Bug Fixes (Parallel)
```markdown
Fix these bugs in parallel:

- Bug #123: Login redirect loop
- Bug #456: Image upload timeout
- Bug #789: Search results pagination

All independent, assign to meal-agent polecats
```

### Sprint Planning
```markdown
Sprint Feb 10-16 - Performance improvements:

**Independent tracks (run in parallel):**
1. Image optimization (4 tasks)
2. API caching (3 tasks)
3. Database indexing (2 tasks)
4. Frontend bundle size (3 tasks)

Create convoy "Sprint: Performance"
Distribute across available polecats
```

## Commands the Mayor Uses

```bash
# Create beads with formula
bd cook web-feature feature_name="..."

# Add dependencies
bd dep add <needs-this> <blocking-bead>

# Create convoy
gt convoy create "Name" <bead-id-1> <bead-id-2>

# Assign to polecat
gt sling <bead-id> <rig-name>

# Check ready work
bd ready

# Check what's blocking
bd blocked <bead-id>
```

## Full Guide

For comprehensive patterns, examples, and anti-patterns:
**[Mayor Prompting Guide](MAYOR_PROMPTING_GUIDE.md)**
