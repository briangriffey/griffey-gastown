# Gas Town HQ

Central headquarters for managing Gas Town rigs, primarily focused on web application development.

## Overview

This is the **Gas Town HQ** - a centralized, version-controlled workspace for managing multiple Gas Town rigs. Each rig represents a separate project (typically a web application) with its own repository, agents, and workflows.

**What is Gas Town?**

Gas Town is a development workflow system that provides:
- **Rigs**: Project workspaces with isolated repositories
- **Agents**: Specialized AI assistants (Mayor, Deacon, Polecats, etc.)
- **Beads**: Issue tracking and workflow automation
- **Formulas**: Reusable workflow templates
- **Crew**: Personal development workspaces within rigs

## Quick Start

### Prerequisites

- Node.js 20+ (managed via mise)
- pnpm 8+
- Docker & Docker Compose
- Gas Town CLI (`gt` command)
- Git

### Initial Setup

1. **Navigate to HQ:**
   ```bash
   cd ~/gt  # Symlink to /Users/briangriffey/Code/griffey-gastown
   ```

2. **Verify HQ status:**
   ```bash
   gt status
   gt rig list
   ```

3. **Start working on a rig:**
   ```bash
   # Add yourself to a rig's crew if not already added
   gt crew add brian --rig meal-agent

   # Navigate to your crew workspace
   cd ~/gt/meal-agent/crew/brian
   ```

## Architecture

Gas Town uses a hierarchical structure:

```
Gas Town HQ (griffey-gastown)
├── mayor/                  # Mayor agent (coordinates town)
├── deacon/                 # Deacon watchdog (monitors health)
├── .beads/                 # Town-level issues (prefix: gm-)
├── templates/              # Reusable project templates
├── rigs/                   # Rig metadata
└── [rig-name]/             # Individual rig workspaces
    ├── mayor/rig/          # Rig-specific Mayor workspace
    ├── crew/[name]/        # Personal development clones
    ├── polecats/           # Automated worker branches
    ├── refinery/rig/       # Merge queue and CI
    ├── witness/            # Polecat health monitor
    ├── .beads/             # Rig-level issues (prefix: ma-, etc.)
    └── .repo.git/          # Shared bare repository
```

### Key Concepts

- **HQ (Town)**: This repository - manages multiple rigs
- **Rig**: A project workspace (e.g., meal-agent web app)
- **Mayor**: Coordinates work across agents, dispatches tasks
- **Crew**: Your personal development workspace within a rig
- **Polecat**: Automated worker that handles specific tasks
- **Refinery**: Manages merge queue and verification
- **Witness**: Monitors polecat health and progress
- **Beads**: Issue tracking system (town-level and rig-level)
- **Formulas**: Workflow automation templates

## Adding New Rigs

### 1. Create the Rig

```bash
# From HQ root
cd ~/gt

# Add rig with git URL
gt rig add my-app git@github.com:user/my-app.git
```

This creates:
- `my-app/` directory with full rig structure
- `.beads/` for rig-level issue tracking
- Rig-specific agents (Mayor, Refinery, Witness)
- Metadata in `rigs/` and `mayor/rigs.json`

### 2. Create Your Crew Workspace

```bash
# Add yourself to the rig's crew
gt crew add brian --rig my-app

# Navigate to your workspace
cd ~/gt/my-app/crew/brian
```

Your crew workspace is a full git clone where you do your development work.

### 3. Initialize the Project (for new rigs)

If this is a brand new project (empty repository):

```bash
# Copy web app templates
cp ~/gt/templates/web-app/.env.template .env.example
cp ~/gt/templates/web-app/docker-compose.template.yml docker-compose.yml
cp ~/gt/templates/web-app/package.template.json package.json

# Follow the Web App Template guide
cat ~/gt/templates/WEB_APP_TEMPLATE.md
```

## Web App Template

For web applications, we have a proven stack and structure:

**Stack:**
- Next.js 14+ (App Router)
- TypeScript
- Tailwind CSS
- Prisma ORM
- PostgreSQL 16
- Redis 7
- pnpm workspaces (monorepo)

**Structure:**
```
apps/
  web/              # Next.js application
  worker/           # Background jobs (optional)
packages/
  database/         # Prisma schema + client
  shared/           # Shared utilities
  config/           # Shared configs
```

See [`templates/WEB_APP_TEMPLATE.md`](./templates/WEB_APP_TEMPLATE.md) for detailed setup instructions.

## Web Development Specialized Polecats

Gas Town polecats can be specialized for web development work using our web app context templates. This gives autonomous workers deep knowledge of React, Next.js, TypeScript, and modern web development patterns.

### Why Specialized Polecats?

- **Better autonomous decisions**: Polecats understand React component patterns, Next.js conventions, and TypeScript best practices
- **Comprehensive checklists**: Web-specific formulas create detailed, framework-aware task breakdowns
- **Consistent quality**: Pre-configured context ensures all polecats follow the same patterns
- **Faster onboarding**: New polecats have immediate web development expertise

### Setting Up a Web App Rig

When adding a new web app rig, apply the specialized polecat context:

```bash
# 1. Add the rig
gt rig add my-app git@github.com:user/my-app.git

# 2. Apply web development context
./scripts/setup-web-app-rig.sh my-app

# 3. Create your crew workspace (optional)
gt crew add brian --rig my-app
```

The setup script:
- Copies comprehensive web development context to `polecats/.context/`
- Updates refinery context with web app patterns
- Creates symlinks to web app templates
- Configures .gitignore

### Web Development Formulas

Use these formulas to create web-specific work for polecats:

#### web-feature

Full-stack feature (React + API + Database):

```bash
bd cook web-feature feature_name="user-authentication"
```

Creates a comprehensive checklist covering:
- Frontend components (Server/Client Component decisions)
- Backend API routes or Server Actions
- Database schema changes and migrations
- Testing (unit, integration, E2E)
- Security validation
- Code quality checks

#### web-component

React component implementation:

```bash
bd cook web-component component_name="UserProfile"
```

Creates a checklist for:
- Server vs Client Component decision
- TypeScript props interface
- Styling with Tailwind CSS
- Accessibility (ARIA, keyboard navigation)
- Component testing
- Responsive design

#### web-api

API endpoint implementation:

```bash
bd cook web-api endpoint_name="users"
```

Creates a checklist for:
- HTTP method and route design
- Request/response validation (Zod)
- Prisma database queries
- Error handling and status codes
- Security (authentication, authorization, input validation)
- Integration testing

### Web Development Technology Stack

Polecats specialized for web development have knowledge of:

**Frontend:**
- React 18+ (Server Components, Client Components, Suspense)
- Next.js 14+ (App Router, Server Actions, Route Handlers)
- TypeScript (strict mode, type-safe patterns)
- Tailwind CSS (utility-first styling)

**Backend:**
- Next.js API Routes
- Server Actions (form handling)
- Node.js

**Database:**
- Prisma ORM (type-safe database client)
- PostgreSQL (primary database)
- Redis (caching)

**Testing:**
- Vitest (unit tests)
- React Testing Library (component tests)
- Playwright (E2E tests)

**Tooling:**
- pnpm (package management)
- ESLint (linting)
- Prettier (formatting)
- Husky (git hooks)

### Polecat Context Reference

The complete web development context is in:
**`templates/polecat-contexts/WEB_DEVELOPMENT.md`**

This ~800 line reference document covers:
- React Server vs Client Component patterns
- Next.js App Router file conventions
- TypeScript typing patterns
- Prisma database query patterns
- API endpoint design patterns
- Testing strategies
- Common troubleshooting
- Best practices and anti-patterns

### Example Workflow

```bash
# 1. Setup web app rig
./scripts/setup-web-app-rig.sh meal-agent

# 2. Create feature work
cd meal-agent/refinery/rig  # or crew/brian/rig
bd cook web-feature feature_name="recipe-import"

# 3. Assign to polecat
gt sling <bead-id> meal-agent

# 4. Polecat automatically receives web development context
# 5. Polecat implements feature following React/Next.js best practices
# 6. Polecat runs tests, linting, type checking
# 7. Polecat pushes to branch, refinery merges
```

Polecats spawned with work assignments automatically have access to:
- Comprehensive web development patterns
- Project structure awareness
- Technology stack reference
- Common troubleshooting solutions
- Quality standards and checklists

## Available Formulas

Formulas automate common workflows by creating structured issue checklists.

### web-app-setup

Creates a complete setup checklist for new web apps:

```bash
bd cook web-app-setup
```

This creates issues for:
1. Monorepo structure setup
2. Next.js app configuration
3. Database package with Prisma
4. Docker environment
5. Shared packages
6. Development tooling

### feature-branch

Creates a feature development checklist:

```bash
bd cook feature-branch feature_name="user-authentication"
```

This creates an issue with a comprehensive checklist covering:
- Development workflow
- Testing requirements
- Code quality checks
- Documentation
- Local testing
- PR submission

### Listing Formulas

```bash
bd formula list
```

## Common Commands

### Town (HQ) Level

```bash
# View HQ status
gt status

# List all rigs
gt rig list

# Add a new rig
gt rig add <name> <git-url>

# Remove a rig
gt rig remove <name>

# Start Mayor (from HQ)
cd ~/gt/mayor
gt prime
```

### Rig Level

```bash
# Navigate to a rig
cd ~/gt/<rig-name>

# List crew members
gt crew list

# Add yourself to crew
gt crew add brian --rig <rig-name>

# View rig status
gt status

# List rig agents
gt agent list
```

### Crew Workspace

```bash
# Navigate to your workspace
cd ~/gt/<rig-name>/crew/brian

# Standard git workflow
git status
git checkout -b feature/my-feature
git add .
git commit -m "Add feature"
git push origin feature/my-feature

# Run project commands
pnpm install
pnpm dev
pnpm test
```

### Beads (Issue Tracking)

```bash
# List issues
bd list

# Create an issue
bd create --title "Fix bug" --description "Details..."

# View issue details
bd show <issue-id>

# Update issue status
bd status <issue-id> done

# Cook a formula
bd cook <formula-name> [variables...]
```

### Docker Services

```bash
# Start services
docker-compose up -d postgres redis

# View status
docker-compose ps

# View logs
docker-compose logs -f postgres

# Stop services
docker-compose down

# Clean up volumes
docker-compose down -v
```

## Typical Development Workflow

### Starting Work on a Feature

1. **Navigate to crew workspace:**
   ```bash
   cd ~/gt/meal-agent/crew/brian
   ```

2. **Start services:**
   ```bash
   docker-compose up -d
   ```

3. **Create feature branch:**
   ```bash
   git checkout -b feature/add-recipe-import
   ```

4. **Create tracking issue:**
   ```bash
   bd cook feature-branch feature_name="recipe-import"
   ```

5. **Develop and test:**
   ```bash
   pnpm dev          # Start dev server
   pnpm test:watch   # Run tests in watch mode
   ```

6. **Commit and push:**
   ```bash
   git add .
   git commit -m "feat: add recipe import functionality"
   git push origin feature/add-recipe-import
   ```

7. **Create pull request:**
   ```bash
   gh pr create --title "Add recipe import" --body "..."
   ```

### Working with Mayor

The Mayor coordinates work across the rig. To start a Mayor session:

```bash
cd ~/gt/mayor
gt prime
```

The Mayor can:
- Dispatch work to Polecats
- Review Beads (issues)
- Coordinate across multiple rigs
- Monitor overall town health

See `mayor/CLAUDE.md` for detailed Mayor capabilities.

## Rig Structure Deep Dive

### .repo.git (Shared Bare Repository)

The `.repo.git` directory is a bare git repository shared by:
- Refinery (main branch worktree)
- Polecats (feature branch worktrees)
- Witness (monitoring)

This allows multiple agents to work on different branches simultaneously without conflicts.

### mayor/rig/

The Mayor's workspace for this rig. Contains:
- Rig-specific CLAUDE.md instructions
- State tracking
- Coordination files

### crew/[name]/

Personal development clones. Each crew member gets their own full git clone to work independently.

### polecats/

Automated workers that handle specific tasks:
- Each polecat works in its own git worktree
- Isolated from other polecats and crew members
- Coordinated by the Mayor

### refinery/rig/

The merge queue and verification system:
- Main branch worktree
- Runs CI checks before merging
- Manages merge conflicts

### witness/

Monitors polecat health:
- Tracks active polecats
- Detects stuck or failed workers
- Reports to Mayor

## Templates

### Available Templates

- **WEB_APP_TEMPLATE.md** - Comprehensive web app setup guide
- **.env.template** - Standard environment variables
- **docker-compose.template.yml** - Docker services configuration
- **package.template.json** - Root package.json structure

### Using Templates

```bash
# Copy all web app templates
cp ~/gt/templates/web-app/* ./

# Or copy individually
cp ~/gt/templates/web-app/.env.template .env.example
```

## Troubleshooting

### Rig Won't Initialize

**Problem:** `gt rig add` fails with git errors

**Solution:**
```bash
# Verify git URL is accessible
git ls-remote <git-url>

# Check SSH keys
ssh -T git@github.com

# Try with full path
gt rig add my-app git@github.com:user/my-app.git
```

### Database Connection Failed

**Problem:** App can't connect to PostgreSQL

**Solution:**
```bash
# Check if postgres is running
docker-compose ps

# View postgres logs
docker-compose logs postgres

# Restart postgres
docker-compose restart postgres

# Verify DATABASE_URL in .env
grep DATABASE_URL .env
```

### Beads Prefix Mismatch

**Problem:** `prefix mismatch: database uses 'gm' but you specified 'ma'`

**Solution:**
This is a known issue when creating rig agents. The rig-level beads use a different prefix than town-level. This warning can be ignored - rig functionality is not affected.

### Pnpm Install Fails

**Problem:** `pnpm install` fails with lockfile errors

**Solution:**
```bash
# Remove lockfile and try again
rm pnpm-lock.yaml
pnpm install

# Or use clean install
pnpm install --frozen-lockfile=false
```

### Port Already in Use

**Problem:** Can't start dev server, port 3000 in use

**Solution:**
```bash
# Find process using port
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use different port
PORT=3001 pnpm dev
```

### Git Push Fails

**Problem:** Can't push to remote repository

**Solution:**
```bash
# Check remote URL
git remote -v

# Update remote URL if needed
git remote set-url origin git@github.com:user/repo.git

# Verify SSH access
ssh -T git@github.com
```

## Best Practices

### Rig Management

1. **One rig per project** - Don't mix unrelated projects in a single rig
2. **Use crew workspaces** - Always work in `crew/[name]`, never in `mayor/rig` or `refinery/rig`
3. **Keep HQ clean** - Commit Gas Town configuration changes separately from project code
4. **Use formulas** - Leverage formulas for consistent workflows

### Development

1. **Start services first** - Run `docker-compose up -d` before developing
2. **Use feature branches** - Never commit directly to main
3. **Write tests** - Add tests alongside features
4. **Run checks before pushing** - Lint, type-check, and test locally
5. **Keep commits focused** - One logical change per commit

### Code Quality

1. **Follow TypeScript strict mode** - Enable all strict checks
2. **Use path aliases** - Import with `@/components` not `../../components`
3. **Handle errors** - Use try/catch and error boundaries
4. **Validate environment** - Check required env vars on startup
5. **Document complex logic** - Add comments where needed

### Git Workflow

1. **Conventional commits** - Use `feat:`, `fix:`, `docs:`, etc.
2. **Descriptive PR titles** - Clearly state what changed
3. **Keep PRs focused** - One feature/fix per PR
4. **Review before merging** - Don't merge your own PRs
5. **Clean up branches** - Delete merged branches

## Project History

This Gas Town HQ was created to:
- Consolidate Gas Town management in a version-controlled repository
- Replace the previous HQ at `~/gt` (backed up to `~/gt-backup-*`)
- Provide reusable templates for web app rigs
- Enable better organization for managing multiple projects

The first rig added was **meal-agent** - a Next.js meal planning application that serves as the reference implementation for the web app template.

## Additional Resources

- [Gas Town Documentation](https://github.com/gaslight/gas-town) (if available)
- [Next.js Documentation](https://nextjs.org/docs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [pnpm Documentation](https://pnpm.io)
- [TypeScript Handbook](https://www.typescriptlang.org/docs)

## Contributing

To improve this HQ:

1. Create a branch for your changes
2. Update relevant documentation
3. Test with existing rigs
4. Commit and push
5. Create PR for review

## License

This is a personal Gas Town HQ for managing development projects.
