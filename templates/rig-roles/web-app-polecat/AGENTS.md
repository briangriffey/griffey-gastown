# Web App Polecat - Practical Command Reference

Quick reference for common tasks when working on web applications.

## Git Workflow

### Starting Work
```bash
# Check what's on your hook
gt hook

# View the assignment
bd show <id>

# Check your branch
git status
git branch                       # Should be on polecat/<your-name>
```

### During Work
```bash
# Check what you've changed
git status
git diff                         # Unstaged changes
git diff --staged                # Staged changes

# Stage changes
git add <specific-files>         # Prefer this over "git add ."
git add -p                       # Interactive staging (review each change)

# Commit
git commit -m "feat: add user authentication

- Implement login form with validation
- Add JWT token handling
- Create auth middleware
- Add tests for auth flow

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

### Finishing Work
```bash
# Sync beads
bd sync

# Push to your branch
git push origin HEAD

# Close the bead
bd close <id>
```

### If Main Has Advanced
```bash
# Fetch latest
git fetch origin

# Rebase on main
git rebase origin/main

# If conflicts, resolve them:
git status                       # See conflicted files
# Edit files to resolve conflicts
git add <resolved-files>
git rebase --continue

# Push (may need force push after rebase)
git push origin HEAD --force-with-lease
```

## pnpm Commands

### Development
```bash
# Start dev server (usually http://localhost:3000)
pnpm dev

# Build for production
pnpm build

# Start production server
pnpm start

# Clean build artifacts
pnpm clean
```

### Dependencies
```bash
# Install all dependencies
pnpm install

# Add a dependency
pnpm add <package>               # Production dependency
pnpm add -D <package>            # Dev dependency

# Remove a dependency
pnpm remove <package>

# Update dependencies
pnpm update

# List outdated packages
pnpm outdated
```

### Code Quality
```bash
# Run linter
pnpm lint

# Fix linting errors
pnpm lint:fix

# Type check
pnpm type-check

# Format code
pnpm format

# Run all checks
pnpm lint && pnpm type-check && pnpm test
```

## Database Commands (Prisma)

### Migrations
```bash
# Create a new migration (development)
pnpm db:migrate dev --name add_user_profile

# Apply migrations (production)
pnpm db:migrate deploy

# Reset database (WARNING: deletes all data)
pnpm db:migrate reset

# View migration status
pnpm db:migrate status
```

### Schema Management
```bash
# Push schema changes without migration (dev only)
pnpm db:push

# Pull schema from database
pnpm db:pull

# Generate Prisma Client (after schema changes)
pnpm prisma generate

# Format schema file
pnpm prisma format
```

### Database Tools
```bash
# Open Prisma Studio (database GUI)
pnpm db:studio                   # Usually http://localhost:5555

# Seed database
pnpm db:seed

# Validate schema
pnpm prisma validate
```

### Common Migration Workflow
```bash
# 1. Update prisma/schema.prisma
# 2. Create migration
pnpm db:migrate dev --name add_posts_table

# 3. Generate Prisma Client
pnpm prisma generate

# 4. Update code to use new schema
# 5. Test with fresh database
pnpm db:migrate reset
pnpm db:seed
```

## Testing Commands

### Unit & Component Tests (Vitest)
```bash
# Run all tests
pnpm test

# Run tests in watch mode
pnpm test:watch

# Run specific test file
pnpm test path/to/file.test.ts

# Run tests matching pattern
pnpm test --grep "user authentication"

# Run with coverage
pnpm test:coverage

# Clear test cache
pnpm test --clearCache
```

### E2E Tests (Playwright)
```bash
# Run E2E tests
pnpm test:e2e

# Run E2E tests in UI mode (interactive)
pnpm test:e2e:ui

# Run specific E2E test
pnpm test:e2e path/to/file.spec.ts

# Update snapshots
pnpm test:e2e --update-snapshots
```

## Docker Commands (if using Docker)

### Development
```bash
# Start all services (database, redis, etc.)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Restart specific service
docker-compose restart postgres

# View running containers
docker-compose ps
```

### Database
```bash
# Access PostgreSQL shell
docker-compose exec postgres psql -U <username> -d <database>

# Access Redis CLI
docker-compose exec redis redis-cli

# View database logs
docker-compose logs postgres
```

### Cleanup
```bash
# Stop and remove containers, networks
docker-compose down

# Also remove volumes (WARNING: deletes data)
docker-compose down -v

# Rebuild containers
docker-compose up -d --build
```

## Beads Commands

### Viewing Work
```bash
# Check your hook
gt hook

# Show bead details
bd show <id>

# List open beads
bd list --status=open

# List your assigned beads
bd list --assignee=<your-name>

# Show ready-to-work beads (no blockers)
bd ready
```

### Working on Beads
```bash
# Add a comment/progress note
bd comment <id> -m "Completed API implementation, working on tests"

# Update bead fields
bd edit <id> --title "New title"
bd edit <id> --priority 1

# Add dependency (this bead needs other bead)
bd dep add <this-id> <needs-id>

# Close completed bead
bd close <id>
```

### Syncing Beads
```bash
# Sync beads changes to git
bd sync

# Typical workflow:
git add <files>
bd sync                          # Commit beads changes
git commit -m "..."              # Commit code changes
bd sync                          # Sync again to pick up commit ref
git push origin HEAD
```

### Creating Beads (if needed)
```bash
# Create from formula
bd cook web-feature feature_name="user-settings"
bd cook web-component component_name="SettingsPanel"
bd cook web-api endpoint_name="settings"

# Create manually
bd create --title "Fix login redirect bug" --type=bug --priority=1
```

## Next.js Commands

### Development
```bash
# Start dev server with turbo
pnpm dev --turbo

# Start on different port
PORT=3001 pnpm dev

# Clear Next.js cache
rm -rf .next

# Analyze bundle size
pnpm build && pnpm analyze
```

### Build & Deploy
```bash
# Build for production
pnpm build

# Start production server
pnpm start

# Export static site (if applicable)
pnpm export
```

## Troubleshooting Commands

### Clear All Caches
```bash
# Clear Next.js cache
rm -rf .next

# Clear node_modules and reinstall
rm -rf node_modules
pnpm install

# Clear pnpm cache
pnpm store prune

# Clear test cache
pnpm test --clearCache
```

### Debug Information
```bash
# Check Node version
node --version

# Check pnpm version
pnpm --version

# Check environment variables
env | grep DATABASE

# Check ports in use
lsof -i :3000
lsof -i :5432                    # PostgreSQL default
lsof -i :6379                    # Redis default

# Kill process on port
lsof -ti :3000 | xargs kill -9
```

### Database Debugging
```bash
# Check database connection
pnpm prisma db pull

# View current schema
cat prisma/schema.prisma

# Generate SQL for migration (without applying)
pnpm db:migrate dev --create-only --name test_migration

# Reset and reseed
pnpm db:migrate reset && pnpm db:seed
```

## Common Workflows

### Adding a New Feature
```bash
# 1. Check assignment
gt hook
bd show <id>

# 2. Start dev server
pnpm dev

# 3. Make changes
# ... edit files ...

# 4. Test changes
pnpm lint
pnpm type-check
pnpm test

# 5. Commit and push
git add <files>
bd sync
git commit -m "feat: add feature X"
bd sync
git push origin HEAD

# 6. Close bead
bd close <id>
```

### Fixing a Bug
```bash
# 1. Reproduce the bug locally
pnpm dev

# 2. Find the issue
# ... investigate code ...

# 3. Fix the bug
# ... edit files ...

# 4. Add test for the bug
# ... create test file ...
pnpm test

# 5. Verify fix
pnpm dev
# ... manually test in browser ...

# 6. Commit
git add <files>
git commit -m "fix: resolve login redirect issue"
bd sync
git push origin HEAD
```

### Adding a Database Migration
```bash
# 1. Update schema
# ... edit prisma/schema.prisma ...

# 2. Create migration
pnpm db:migrate dev --name add_user_settings

# 3. Generate client
pnpm prisma generate

# 4. Update code to use new schema
# ... edit TypeScript files ...

# 5. Test migration
pnpm db:migrate reset
pnpm db:seed
pnpm dev

# 6. Commit
git add prisma/
git add <affected-code-files>
git commit -m "feat: add user settings schema"
bd sync
git push origin HEAD
```

### Creating a New Component
```bash
# 1. Create component file
# apps/web/components/user-profile.tsx

# 2. Implement component
# ... write React code ...

# 3. Add styles (if needed)
# ... add Tailwind classes ...

# 4. Write tests
# apps/web/components/user-profile.test.tsx
pnpm test

# 5. Use component in page
# ... import and use ...

# 6. Test in browser
pnpm dev

# 7. Commit
git add components/
git commit -m "feat: add UserProfile component"
bd sync
git push origin HEAD
```

## Environment Variables

### View Environment
```bash
# Show all env vars
env

# Show specific var
echo $DATABASE_URL
echo $NEXT_PUBLIC_API_URL
```

### Local Environment Files
```bash
# .env.local (not committed, local development)
DATABASE_URL="postgresql://user:pass@localhost:5432/mydb"
NEXT_PUBLIC_API_URL="http://localhost:3000/api"
SECRET_KEY="local-dev-secret"

# .env (committed, shared defaults)
NEXT_PUBLIC_APP_NAME="My App"

# .env.production (production values)
DATABASE_URL="postgresql://user:pass@prod.example.com:5432/mydb"
```

### Check Which Env File Is Used
```bash
# Development
pnpm dev                         # Uses .env.local, .env.development.local, .env

# Production
pnpm build && pnpm start         # Uses .env.production.local, .env.production, .env
```

## Quick Diagnostics

### "Why isn't my code working?"
```bash
# 1. Check for TypeScript errors
pnpm type-check

# 2. Check for lint errors
pnpm lint

# 3. Check test failures
pnpm test

# 4. Check browser console
# Open browser DevTools (F12)

# 5. Check server logs
# Look at terminal where "pnpm dev" is running

# 6. Check database connection
pnpm db:studio
```

### "Why won't my changes show up?"
```bash
# 1. Clear Next.js cache
rm -rf .next

# 2. Restart dev server
# Ctrl+C to stop, then:
pnpm dev

# 3. Hard refresh browser
# Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)

# 4. Check if file is being imported
# Search for import statements
bd grep "import.*YourComponent"
```

### "Why are tests failing?"
```bash
# 1. Run specific test file
pnpm test path/to/failing-test.test.ts

# 2. Clear test cache
pnpm test --clearCache

# 3. Check database state
pnpm db:migrate reset
pnpm db:seed

# 4. View detailed error
pnpm test --reporter=verbose
```

## Session Checklist

### Before Starting
- [ ] `gt hook` - Check for assigned work
- [ ] `bd show <id>` - Read requirements
- [ ] `git status` - Verify clean state
- [ ] `pnpm install` - Ensure dependencies installed
- [ ] `pnpm dev` - Start dev server

### During Work
- [ ] Save files frequently
- [ ] Run `pnpm lint` periodically
- [ ] Run `pnpm type-check` after type changes
- [ ] Run `pnpm test` after logic changes
- [ ] Test manually in browser

### Before Committing
- [ ] `git status` - Review changed files
- [ ] `pnpm lint` - No linting errors
- [ ] `pnpm type-check` - No type errors
- [ ] `pnpm test` - All tests pass
- [ ] Manual testing - Feature works in browser

### Ending Session
- [ ] `git add <files>` - Stage changes
- [ ] `bd sync` - Sync beads
- [ ] `git commit -m "..."` - Commit with clear message
- [ ] `bd sync` - Sync beads again
- [ ] `git push origin HEAD` - Push to remote
- [ ] `bd close <id>` - Close completed bead (if done)
- [ ] Create handoff mail if incomplete
