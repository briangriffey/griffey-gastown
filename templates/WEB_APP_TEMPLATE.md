# Web App Template for Gas Town Rigs

This template provides a proven structure for web application rigs based on the meal-agent pattern.

## Technology Stack

- **Runtime**: Node.js (via mise)
- **Package Manager**: pnpm (workspaces for monorepo)
- **Framework**: Next.js 14+ (App Router)
- **Database**: PostgreSQL 16 + Prisma ORM
- **Cache/Queue**: Redis 7
- **Language**: TypeScript
- **Styling**: Tailwind CSS

## Monorepo Architecture

Use pnpm workspaces to organize code:

```
my-app/
├── apps/
│   ├── web/              # Next.js application
│   └── worker/           # Background job processor (optional)
├── packages/
│   ├── database/         # Prisma schema + client
│   ├── shared/           # Shared utilities, types
│   └── config/           # Shared configs (tsconfig, eslint)
├── docker-compose.yml
├── .env.example
├── package.json
├── pnpm-workspace.yaml
└── .mise.toml
```

## Standard Package Structure

### Root `package.json`

```json
{
  "name": "my-app",
  "private": true,
  "scripts": {
    "build": "turbo build",
    "build:clean": "turbo build --force",
    "build:docker": "docker-compose build",
    "dev": "turbo dev",
    "dev:worker": "turbo dev --filter=worker",
    "worker": "turbo start --filter=worker",
    "db:migrate": "turbo db:migrate --filter=database",
    "db:generate": "turbo db:generate --filter=database",
    "db:studio": "turbo db:studio --filter=database",
    "db:push": "turbo db:push --filter=database",
    "db:seed": "turbo db:seed --filter=database",
    "test": "turbo test",
    "test:watch": "turbo test:watch",
    "lint": "turbo lint",
    "docker:up": "docker-compose up -d postgres redis",
    "docker:down": "docker-compose down",
    "docker:logs": "docker-compose logs -f"
  },
  "devDependencies": {
    "turbo": "^2.0.0",
    "typescript": "^5.3.0"
  }
}
```

### `pnpm-workspace.yaml`

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

### `.mise.toml`

```toml
[tools]
node = "20.11.0"
pnpm = "8.15.0"
```

## Apps Structure

### `apps/web/` - Next.js Application

```
apps/web/
├── app/
│   ├── api/
│   │   └── health/route.ts    # Health check endpoint
│   ├── layout.tsx
│   └── page.tsx
├── components/
├── lib/
├── public/
├── next.config.mjs
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

**Key configurations:**

- **TypeScript path aliases**: `@/components/*`, `@/lib/*`
- **API health check**: `/api/health` returns status and dependencies
- **Environment validation**: Validate required env vars on startup

### `apps/worker/` - Background Jobs (Optional)

```
apps/worker/
├── src/
│   ├── jobs/              # Job handlers
│   ├── queues/            # Queue definitions
│   └── index.ts           # Worker process
├── tsconfig.json
└── package.json
```

Uses BullMQ for Redis-backed job queues.

## Packages Structure

### `packages/database/` - Prisma + Database Client

```
packages/database/
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── src/
│   └── index.ts           # PrismaClient singleton export
├── tsconfig.json
└── package.json
```

**`src/index.ts` pattern:**

```typescript
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

**Common scripts:**

```json
{
  "scripts": {
    "db:generate": "prisma generate",
    "db:migrate": "prisma migrate dev",
    "db:push": "prisma db push",
    "db:studio": "prisma studio",
    "db:seed": "tsx prisma/seed.ts"
  }
}
```

### `packages/shared/` - Shared Utilities

```
packages/shared/
├── src/
│   ├── types/             # Shared TypeScript types
│   ├── utils/             # Utility functions
│   └── index.ts
├── tsconfig.json
└── package.json
```

## Docker Setup

See `templates/web-app/docker-compose.template.yml` for the standard Docker Compose configuration.

**Key services:**

1. **PostgreSQL** - Primary database with health checks
2. **Redis** - Cache and job queue with persistence
3. **Web** (optional) - Containerized Next.js app
4. **Worker** (optional) - Background job processor

## Environment Configuration

See `templates/web-app/.env.template` for standard environment variables.

**Critical variables:**

- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `ANTHROPIC_API_KEY` - Claude API key (if using AI features)
- `NEXTAUTH_SECRET` - Auth secret (if using NextAuth.js)
- `NODE_ENV` - development/production

## TypeScript Configuration

**Root `tsconfig.json`:**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  }
}
```

**App-specific configs extend the root:**

```json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

## Getting Started with a New Web App Rig

1. **Add the rig to Gas Town:**
   ```bash
   gt rig add my-app git@github.com:user/my-app.git
   ```

2. **Create crew workspace:**
   ```bash
   gt crew add brian --rig my-app
   cd ~/gt/my-app/crew/brian
   ```

3. **Initialize the monorepo:**
   ```bash
   # Copy template files
   cp ~/gt/templates/web-app/.env.template .env.example
   cp ~/gt/templates/web-app/docker-compose.template.yml docker-compose.yml
   cp ~/gt/templates/web-app/package.template.json package.json

   # Initialize pnpm workspace
   echo "packages:\n  - 'apps/*'\n  - 'packages/*'" > pnpm-workspace.yaml

   # Create directory structure
   mkdir -p apps/web apps/worker packages/database packages/shared
   ```

4. **Setup Next.js app:**
   ```bash
   cd apps/web
   pnpm create next-app@latest . --typescript --tailwind --app --no-src-dir
   ```

5. **Setup Prisma:**
   ```bash
   cd ../../packages/database
   pnpm init
   pnpm add -D prisma
   pnpm add @prisma/client
   pnpm prisma init
   ```

6. **Start services:**
   ```bash
   cd ../..
   docker-compose up -d postgres redis
   pnpm install
   pnpm db:migrate
   pnpm dev
   ```

7. **Use formulas for common setups:**
   ```bash
   bd cook web-app-setup  # Creates issues for standard setup tasks
   ```

## Best Practices

1. **Database Migrations**: Always use Prisma migrations, never `db push` in production
2. **Environment Variables**: Never commit `.env` files, always provide `.env.example`
3. **Type Safety**: Export types from `packages/shared` for reuse
4. **API Routes**: Add health checks to all services
5. **Error Handling**: Use proper error boundaries in Next.js
6. **Testing**: Write tests alongside features, use Vitest or Jest
7. **Docker**: Use health checks for all services
8. **Git**: Commit often, use conventional commits

## Common Issues

**Prisma client not found:**
```bash
pnpm db:generate
```

**Port already in use:**
```bash
lsof -i :3000  # Find process using port
kill -9 <PID>  # Kill the process
```

**Database connection failed:**
```bash
docker-compose ps          # Check if postgres is running
docker-compose logs postgres  # Check logs
```

**Redis connection failed:**
```bash
docker-compose ps          # Check if redis is running
docker-compose logs redis  # Check logs
```

## Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [pnpm Workspaces](https://pnpm.io/workspaces)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [TypeScript](https://www.typescriptlang.org/docs)
