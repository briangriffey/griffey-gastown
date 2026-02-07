# Mayor Prompting Guide: Parallelized Work

> **How to effectively prompt the Gas Town Mayor for maximum throughput**

## Overview

The Gas Town Mayor excels at coordinating parallelized work across multiple rigs, polecats, and crew members. However, the quality of work parallelization depends heavily on how you structure your prompts.

This guide provides patterns, examples, and best practices for prompting the Mayor to create and coordinate parallelized work.

## Core Principles

### 1. Parallelization is About Independence

Work can be parallelized when tasks are **independent** - they don't need each other's results to proceed.

**Parallelizable:**
```
✅ "Implement user authentication" + "Implement recipe search" + "Add email notifications"
   → Three independent features, can run simultaneously
```

**Not Parallelizable:**
```
❌ "Design user schema" + "Implement user API" + "Add user UI"
   → Sequential dependency: schema → API → UI
```

### 2. Be Explicit About Structure

The Mayor will parallelize work more effectively when you explicitly structure your request.

**Good Prompt Structure:**
```markdown
Create parallelized work for the meal-agent redesign:

**Phase 1 (Parallel):**
- Update database schema for new recipe model
- Refactor component library to use new design system
- Set up Redis caching infrastructure

**Phase 2 (Parallel, depends on Phase 1):**
- Build recipe CRUD API using new schema
- Create recipe card component with new design
- Implement cache layer for API responses

**Phase 3 (Parallel, depends on Phase 2):**
- Build recipe list page
- Add recipe detail page
- Implement recipe search
```

### 3. Use Convoys for Batch Work

Convoys group related work that should be tracked together. Use them for features that span multiple tasks.

**When to Use Convoys:**
- Large features broken into subtasks
- Releases with multiple independent work items
- Coordinated work across multiple rigs
- Sprint/milestone planning

## Effective Prompting Patterns

### Pattern 1: Feature Decomposition

Break a large feature into independent, parallelizable subtasks.

**Prompt:**
```markdown
Create a convoy for the "User Profile Feature":

Break into these parallel tracks:
1. **Backend Track**: User profile API endpoints (CRUD)
2. **Frontend Track**: Profile UI components (ProfileCard, ProfileEditor)
3. **Database Track**: Profile schema and migrations
4. **Testing Track**: Integration tests for profile flows

Use web-component formula for UI tasks, web-api formula for backend tasks.
Assign to meal-agent rig.
```

**What the Mayor Should Do:**
- Create convoy: "User Profile Feature"
- Use `bd cook web-api endpoint_name="profile"` for backend
- Use `bd cook web-component component_name="ProfileCard"` for UI
- Create database migration bead
- Create testing bead
- Mark dependencies (DB must complete before API, API before UI tests)
- Assign to polecats via `gt sling`

### Pattern 2: Multi-Rig Coordination

Coordinate work across multiple rigs that can proceed in parallel.

**Prompt:**
```markdown
Parallelize infrastructure updates across all rigs:

For each rig (meal-agent, other-rig):
1. Update to Next.js 15
2. Migrate to new Prisma version
3. Add OpenTelemetry instrumentation
4. Update CI/CD pipeline

These are independent per-rig - run all rigs in parallel.
```

**What the Mayor Should Do:**
- Create separate convoys per rig (or one convoy with rig-tagged beads)
- For each rig, create 4 beads (can be parallel within rig)
- Dispatch work to each rig's polecats
- Track progress across all rigs

### Pattern 3: Phase-Based Execution

Structure work in phases where each phase can be parallelized, but phases are sequential.

**Prompt:**
```markdown
Implement the recipe sharing feature in phases:

**Phase 1: Foundation (Parallel)**
- Add sharing table to database schema
- Create share token generation service
- Add social media meta tags component

**Phase 2: Core Feature (Parallel, needs Phase 1)**
- Build share API endpoints
- Create share button component
- Implement share analytics tracking

**Phase 3: Polish (Parallel, needs Phase 2)**
- Add share preview page
- Implement share link QR codes
- Add share email notifications

Create dependencies so Phase 2 blocks on Phase 1, Phase 3 blocks on Phase 2.
Within each phase, work is parallel.
```

**What the Mayor Should Do:**
- Create 9 beads total (3 per phase)
- Use `bd dep add <phase2-bead> <phase1-bead>` to create dependencies
- Use `bd dep add <phase3-bead> <phase2-bead>` for next level
- Polecats can work on all Phase 1 beads simultaneously
- Once Phase 1 completes, all Phase 2 beads become ready

### Pattern 4: Formula-Driven Parallelization

Use formulas to generate consistent, parallelizable work.

**Prompt:**
```markdown
Create API endpoints for these resources in parallel:

- Users (web-api formula: endpoint_name="users")
- Recipes (web-api formula: endpoint_name="recipes")
- Comments (web-api formula: endpoint_name="comments")
- Tags (web-api formula: endpoint_name="tags")

Each endpoint is independent. Assign all to meal-agent polecats.
```

**What the Mayor Should Do:**
```bash
# Create 4 beads using formula
bd cook web-api endpoint_name="users"
bd cook web-api endpoint_name="recipes"
bd cook web-api endpoint_name="comments"
bd cook web-api endpoint_name="tags"

# Create convoy to group them
gt convoy create "API Endpoints" <user-id> <recipe-id> <comment-id> <tag-id>

# Assign to polecats (can all run in parallel)
gt sling <user-id> meal-agent
gt sling <recipe-id> meal-agent
gt sling <comment-id> meal-agent
gt sling <tag-id> meal-agent
```

### Pattern 5: Incremental Parallelization

Start with core work, then parallelize enhancements.

**Prompt:**
```markdown
Implement dark mode support incrementally:

**Immediate (Sequential):**
1. Add theme toggle component
2. Set up theme context and provider

**Then Parallelize (assign to multiple polecats):**
- Update all components in apps/web/components/ui/
- Update all pages in apps/web/app/
- Update marketing site components
- Update admin dashboard components

Each component update is independent once theme system exists.
```

**What the Mayor Should Do:**
- Create beads 1-2, mark as sequential dependencies
- Create beads for each component group
- Mark all component beads as dependent on bead #2
- Once #2 completes, dispatch all component beads in parallel

## Example Prompts

### Example 1: Web App Feature (Good)

```markdown
Create parallelized work for implementing the "Meal Planning" feature:

**Database (Priority 1):**
- Add meal plan schema (tables: meal_plans, meal_plan_items)
- Create migration: pnpm db:migrate dev --name add_meal_plans

**Backend (Priority 2, depends on Database):**
- API: POST /api/meal-plans (create plan)
- API: GET /api/meal-plans (list plans)
- API: GET /api/meal-plans/[id] (get plan)
- API: PUT /api/meal-plans/[id] (update plan)
- API: DELETE /api/meal-plans/[id] (delete plan)
Use web-api formula for each endpoint.

**Frontend (Priority 2, depends on Database):**
- Component: MealPlanCard (display plan)
- Component: MealPlanEditor (create/edit)
- Component: MealPlanCalendar (weekly view)
Use web-component formula for each.

**Integration (Priority 3, depends on Backend + Frontend):**
- Page: /meal-plans (list page)
- Page: /meal-plans/[id] (detail page)
- Page: /meal-plans/new (create page)

**Testing (Priority 4, depends on Integration):**
- E2E test: Create meal plan flow
- E2E test: Edit meal plan flow
- E2E test: Delete meal plan flow

Create a convoy called "Meal Planning Feature" with all these beads.
Set up dependencies as described.
Assign to meal-agent polecats.
```

**Why This Is Good:**
- ✅ Clear phase structure with priorities
- ✅ Explicit dependencies between phases
- ✅ Parallelization within phases (5 APIs, 3 components can run simultaneously)
- ✅ Uses formulas for consistency
- ✅ Specifies convoy for tracking
- ✅ Clear assignment target

### Example 2: Multi-Feature Sprint (Good)

```markdown
Create sprint convoy for week of Feb 10-16:

**Theme: Performance & Polish**

These features are independent - run in parallel:

1. **Image Optimization**
   - Audit all images for size/format
   - Migrate to Next.js Image component
   - Set up Cloudinary integration
   - Add image lazy loading

2. **Search Performance**
   - Add Redis caching to search API
   - Implement search result pagination
   - Add search debouncing in UI
   - Index recipe titles in database

3. **Mobile Experience**
   - Fix mobile nav menu bug
   - Improve recipe card responsive design
   - Add pull-to-refresh on recipe list
   - Optimize font sizes for mobile

4. **Error Handling**
   - Add error boundaries to all pages
   - Improve API error messages
   - Add retry logic for failed requests
   - Create error logging service

Assign each theme to a different polecat if possible.
Use appropriate formulas where applicable.
```

**Why This Is Good:**
- ✅ Clear that features are independent
- ✅ Grouped by theme for context
- ✅ Each theme can be assigned to different workers
- ✅ Balanced scope across features
- ✅ Suggests polecat distribution

### Example 3: Infrastructure Work (Good)

```markdown
Parallelize infrastructure improvements across both rigs:

**For Each Rig (meal-agent, other-app):**

Run these in parallel per rig:
1. Update dependencies (Next.js, React, Prisma)
2. Add Sentry error tracking
3. Set up Vercel deployment
4. Configure GitHub Actions CI

Run these sequentially after above:
5. Deploy to staging
6. Run integration tests on staging
7. Deploy to production

Structure:
- Create one convoy per rig
- Within each convoy, beads 1-4 are parallel
- Beads 5-7 are sequential, depend on 1-4
- Rigs can proceed independently
```

**Why This Is Good:**
- ✅ Cross-rig parallelization
- ✅ Per-rig parallelization of independent tasks
- ✅ Clear sequential dependencies for deployment
- ✅ Structured organization (convoy per rig)

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Vague Parallelization

**Bad Prompt:**
```
Make the app better. Add features in parallel.
```

**Problems:**
- No specific work items
- No clear parallelization boundaries
- No dependency information
- No assignment guidance

**Fix:**
Specify exactly what work items to create, which can be parallel, and what dependencies exist.

### ❌ Anti-Pattern 2: False Parallelization

**Bad Prompt:**
```
Run these in parallel:
1. Design the database schema
2. Build the API using the schema
3. Create UI components that call the API
```

**Problems:**
- These have hard dependencies (1→2→3)
- Claiming they're parallel causes blocking
- Polecats would start work they can't complete

**Fix:**
Identify the real dependencies and structure as sequential phases.

### ❌ Anti-Pattern 3: Over-Granular Tasks

**Bad Prompt:**
```
Create separate beads for:
- Import React
- Create function component
- Add useState hook
- Add useEffect hook
- Export component
- Create test file
- Import test library
- Write first test
...
```

**Problems:**
- Tasks too small to parallelize effectively
- Overhead exceeds value
- Should be one "create component" bead

**Fix:**
Group related micro-tasks into meaningful work units.

### ❌ Anti-Pattern 4: Missing Dependencies

**Bad Prompt:**
```
Create these beads in parallel:
- Build user authentication
- Add user profile page
- Implement user settings
```

**Problems:**
- Profile and settings likely depend on auth
- No dependency information provided
- May cause rework or blocking

**Fix:**
Either clarify they're truly independent, or specify dependencies.

### ❌ Anti-Pattern 5: No Assignment Strategy

**Bad Prompt:**
```
Create 20 beads for various features.
```

**Problems:**
- No guidance on how to distribute work
- No priority information
- No rig assignment
- No convoy organization

**Fix:**
Specify assignment strategy, priorities, and grouping.

## Advanced Patterns

### Pattern: Convoy Chains

Create multiple convoys with dependencies between them.

**Prompt:**
```markdown
Create a convoy chain for the v2.0 release:

**Convoy 1: "Foundation" (Parallel)**
- Update Next.js to v15
- Migrate to Prisma v6
- Refactor component library

**Convoy 2: "Core Features" (Parallel, depends on Convoy 1)**
- Implement meal planning
- Add recipe sharing
- Build shopping list

**Convoy 3: "Polish" (Parallel, depends on Convoy 2)**
- Add analytics
- Implement SEO optimizations
- Create admin dashboard

Use convoy dependencies: Convoy 2 blocks on Convoy 1, Convoy 3 blocks on Convoy 2.
```

### Pattern: Dynamic Work Distribution

Let the Mayor decide optimal work distribution.

**Prompt:**
```markdown
Create work for implementing these 15 UI components:

[List of 15 components]

These are all independent. Optimize the distribution:
- Group related components into beads
- Balance complexity across beads
- Assign to available polecats
- Use web-component formula for each
```

### Pattern: Cross-Rig Dependencies

Coordinate work that spans multiple rigs.

**Prompt:**
```markdown
Implement shared authentication across rigs:

**Rig: auth-service**
- Build centralized auth API
- Implement JWT issuing
- Add user management endpoints

**Rig: meal-agent (depends on auth-service API)**
- Integrate auth API client
- Add login UI
- Protect authenticated routes

**Rig: other-app (depends on auth-service API)**
- Integrate auth API client
- Add login UI
- Protect authenticated routes

meal-agent and other-app can proceed in parallel once auth-service completes.
```

## Convoy Management Commands

The Mayor uses these commands to manage convoys:

```bash
# Create a convoy
gt convoy create "Feature Name" <bead-id-1> <bead-id-2> ...

# List all convoys
gt convoy list

# Show convoy status
gt convoy status <convoy-id>

# Add beads to existing convoy
gt convoy add <convoy-id> <bead-id>

# Remove beads from convoy
gt convoy remove <convoy-id> <bead-id>
```

## Dependency Management Commands

The Mayor uses these commands to manage dependencies:

```bash
# Add dependency (bead-A needs bead-B)
bd dep add <bead-A> <bead-B>

# Remove dependency
bd dep remove <bead-A> <bead-B>

# Show what's blocking a bead
bd blocked <bead-id>

# Show what a bead is blocking
bd blocks <bead-id>

# List all ready-to-work beads (no blockers)
bd ready
```

## Formula Usage Commands

The Mayor uses formulas to create structured work:

```bash
# Web app setup
bd cook web-app-setup

# Full-stack feature
bd cook web-feature feature_name="user-auth"

# React component
bd cook web-component component_name="ProfileCard"

# API endpoint
bd cook web-api endpoint_name="users"

# Feature branch work
bd cook feature-branch feature_name="dark-mode"

# List available formulas
bd formula list
```

## Checklist for Good Parallelized Prompts

Before sending a prompt to the Mayor, verify:

- [ ] **Work items are clearly specified** - No vague "improve the app"
- [ ] **Dependencies are explicit** - Clear what depends on what
- [ ] **Parallelization is real** - Items truly don't block each other
- [ ] **Appropriate granularity** - Not too small, not too large
- [ ] **Assignment strategy included** - Which rig, which workers
- [ ] **Formulas referenced** - Use formulas where applicable
- [ ] **Convoy structure defined** - How to group related work
- [ ] **Priority/phases indicated** - What should happen first
- [ ] **Success criteria included** - What does "done" look like

## Template: Feature Implementation

```markdown
Create parallelized work for [FEATURE NAME]:

**Context:**
[Brief description of the feature and its goals]

**Phase 1: [PHASE NAME] (Parallel/Sequential)**
- [Work item 1] - [Formula to use if applicable]
- [Work item 2] - [Formula to use if applicable]
- [Work item 3] - [Formula to use if applicable]

**Phase 2: [PHASE NAME] (Depends on Phase 1)**
- [Work item 4] - [Formula to use if applicable]
- [Work item 5] - [Formula to use if applicable]

**Phase 3: [PHASE NAME] (Depends on Phase 2)**
- [Work item 6] - [Formula to use if applicable]

**Assignment:**
- Rig: [rig-name]
- Convoy: "[Convoy Name]"
- Distribution: [How to distribute work across polecats]

**Dependencies:**
- Phase 2 blocks on all Phase 1 items
- Phase 3 blocks on all Phase 2 items
- [Any other specific dependencies]

**Success Criteria:**
- [What defines completion]
- [What tests must pass]
- [What quality bars must be met]
```

## Template: Multi-Rig Coordination

```markdown
Coordinate [WORK TYPE] across rigs:

**Rigs Involved:**
- [rig-1]
- [rig-2]
- [rig-3]

**Per-Rig Work (Parallel across rigs):**
For each rig above:
1. [Work item 1]
2. [Work item 2]
3. [Work item 3]

**Cross-Rig Dependencies:**
- [Rig-1 item X] must complete before [Rig-2 item Y]
- [Describe any cross-rig dependencies]

**Coordination:**
- Create one convoy per rig named "[Rig Name] - [Work Type]"
- [How to track cross-rig progress]

**Timeline:**
- [Expected duration or milestones]
```

## Template: Sprint Planning

```markdown
Create sprint convoy for [DATE RANGE]:

**Sprint Goal:**
[High-level goal for this sprint]

**Features (Independent, run in parallel):**

1. **[Feature 1 Name]**
   - [Work item 1]
   - [Work item 2]
   - Formula: [if applicable]

2. **[Feature 2 Name]**
   - [Work item 1]
   - [Work item 2]
   - Formula: [if applicable]

3. **[Feature 3 Name]**
   - [Work item 1]
   - [Work item 2]
   - Formula: [if applicable]

**Assignment Strategy:**
- [How to distribute features across polecats]
- [Priority order if needed]

**Convoy Structure:**
- Create convoy: "[Sprint Name]"
- Include all beads above
- Target completion: [date]
```

## Quick Reference

### Good Indicators for Parallelization

✅ Different components/pages
✅ Different API endpoints
✅ Different database tables
✅ Different features with no shared code
✅ Infrastructure work on different rigs
✅ Independent bug fixes
✅ Documentation tasks

### Bad Indicators (Sequential Work)

❌ Schema → API → UI (pipeline)
❌ Design → Implementation → Testing (waterfall)
❌ One component depends on another
❌ API client depends on API server
❌ Tests depend on implementation
❌ Deployment depends on all features

### When in Doubt

If you're unsure whether work can be parallelized:
1. Ask: "Can these start at the same time?"
2. Ask: "Do they share code/resources?"
3. Ask: "Does one need the other's output?"
4. If all answers are yes, yes, no → likely parallelizable
5. Otherwise, structure as sequential or phased

## Summary

**The key to effective Mayor prompting for parallelized work:**

1. **Be explicit** about what can run in parallel
2. **Be clear** about dependencies between work items
3. **Use structure** (phases, convoys, formulas)
4. **Specify assignment** (which rig, which workers)
5. **Provide context** (why the work matters)
6. **Define success** (what done looks like)

The Mayor is capable of sophisticated work coordination, but the quality of output depends on the quality of input. Use these patterns to maximize parallelization and throughput.
