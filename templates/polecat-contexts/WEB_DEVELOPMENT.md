# Web Development Context for Polecats

> **Comprehensive reference for modern web application development**

This document provides specialized knowledge for polecats working on web applications using React, Next.js, TypeScript, and related modern web technologies.

## Technology Stack Overview

### Core Technologies

**React 18+**
- Server Components (default in Next.js App Router)
- Client Components (opt-in with 'use client')
- Suspense boundaries for async rendering
- Concurrent rendering features
- Hooks API for state and effects

**Next.js 14+**
- App Router (file-system based routing)
- Server Actions (RPC-style server functions)
- Route Handlers (API endpoints)
- Server Components by default
- Built-in optimizations (images, fonts, scripts)

**TypeScript**
- Strict mode enabled
- Type-safe database access via Prisma
- Component props typing
- API request/response typing
- Type inference and utilities

**Styling**
- Tailwind CSS (utility-first framework)
- CSS Modules (scoped styles)
- clsx/cn utilities for conditional classes

**Database**
- Prisma ORM (type-safe database client)
- PostgreSQL (primary database)
- Redis (caching layer)

**Package Management**
- pnpm (fast, disk-efficient)
- Workspaces for monorepos

**Testing**
- Vitest (unit testing)
- React Testing Library (component testing)
- Playwright (E2E testing)

---

## Project Structure Patterns

### Next.js App Router Structure

```
apps/web/
├── app/                    # App Router directory
│   ├── layout.tsx         # Root layout (wraps all pages)
│   ├── page.tsx           # Home page (/)
│   ├── globals.css        # Global styles
│   ├── api/               # API routes
│   │   └── users/
│   │       └── route.ts   # /api/users endpoint
│   ├── (auth)/            # Route group (doesn't affect URL)
│   │   ├── login/
│   │   │   └── page.tsx   # /login
│   │   └── register/
│   │       └── page.tsx   # /register
│   └── dashboard/
│       ├── layout.tsx     # Dashboard layout
│       ├── page.tsx       # /dashboard
│       └── [id]/          # Dynamic route
│           └── page.tsx   # /dashboard/:id
├── components/            # React components
│   ├── ui/               # Reusable UI components
│   │   ├── button.tsx
│   │   └── card.tsx
│   └── features/         # Feature-specific components
│       └── user-profile.tsx
├── lib/                  # Shared utilities
│   ├── utils.ts
│   └── api-client.ts
└── public/               # Static assets
    └── images/

packages/database/
├── prisma/
│   ├── schema.prisma     # Database schema
│   └── migrations/       # Migration history
└── src/
    └── index.ts          # Prisma client export
```

### Monorepo Layout

```
workspace-root/
├── apps/                 # Applications
│   ├── web/             # Next.js web app
│   └── api/             # Standalone API (if separate)
├── packages/            # Shared packages
│   ├── database/        # Prisma + DB client
│   ├── ui/              # Shared UI components
│   ├── config/          # Shared configs (eslint, ts)
│   └── types/           # Shared TypeScript types
├── pnpm-workspace.yaml  # Workspace configuration
├── package.json         # Root package.json
└── turbo.json          # Turborepo config (if using)
```

---

## React Patterns

### Server Components vs Client Components

**Server Components (Default)**
- Rendered on the server
- Can directly access databases/APIs
- Cannot use hooks (useState, useEffect)
- Cannot use browser APIs
- No interactivity
- Smaller client bundle

```typescript
// app/users/page.tsx - Server Component
import { prisma } from '@/lib/db'

export default async function UsersPage() {
  // Fetch data directly in component
  const users = await prisma.user.findMany()

  return (
    <div>
      <h1>Users</h1>
      <ul>
        {users.map(user => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  )
}
```

**Client Components (Opt-in)**
- Use 'use client' directive at top of file
- Rendered on client (hydrated from server)
- Can use hooks and browser APIs
- Can handle interactivity
- Adds to client bundle

```typescript
// components/counter.tsx - Client Component
'use client'

import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  )
}
```

**When to Use Each:**

Use Server Components for:
- Static content
- Data fetching
- Direct database/API access
- SEO-critical content
- Large dependencies (syntax highlighters, markdown parsers)

Use Client Components for:
- Interactivity (onClick, onChange)
- State management (useState, useReducer)
- Effects (useEffect, useLayoutEffect)
- Browser APIs (localStorage, geolocation)
- Event listeners
- Custom hooks

### Composition Pattern

Mix Server and Client Components strategically:

```typescript
// app/dashboard/page.tsx - Server Component
import { UserProfile } from './user-profile' // Client
import { prisma } from '@/lib/db'

export default async function DashboardPage() {
  const user = await prisma.user.findUnique({ where: { id: 1 } })

  return (
    <div>
      <h1>Dashboard</h1>
      {/* Pass server data to client component as props */}
      <UserProfile user={user} />
    </div>
  )
}

// app/dashboard/user-profile.tsx - Client Component
'use client'

import { useState } from 'react'
import type { User } from '@prisma/client'

interface UserProfileProps {
  user: User
}

export function UserProfile({ user }: UserProfileProps) {
  const [isEditing, setIsEditing] = useState(false)

  return (
    <div>
      <h2>{user.name}</h2>
      <button onClick={() => setIsEditing(!isEditing)}>
        Edit
      </button>
    </div>
  )
}
```

### Data Fetching Patterns

**Parallel Data Fetching**

```typescript
// Fetch multiple resources in parallel
export default async function Page() {
  const [users, posts] = await Promise.all([
    prisma.user.findMany(),
    prisma.post.findMany()
  ])

  return (
    <div>
      <Users data={users} />
      <Posts data={posts} />
    </div>
  )
}
```

**Sequential Data Fetching (Waterfall)**

```typescript
// Fetch dependent data sequentially
export default async function Page({ params }: { params: { id: string } }) {
  const user = await prisma.user.findUnique({
    where: { id: params.id }
  })

  // This waits for user to load first
  const posts = await prisma.post.findMany({
    where: { authorId: user.id }
  })

  return <UserPosts user={user} posts={posts} />
}
```

**Streaming with Suspense**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { UserList } from './user-list'
import { PostList } from './post-list'

export default function Page() {
  return (
    <div>
      <h1>Dashboard</h1>

      {/* Show loading state while UserList fetches */}
      <Suspense fallback={<p>Loading users...</p>}>
        <UserList />
      </Suspense>

      {/* Show loading state while PostList fetches */}
      <Suspense fallback={<p>Loading posts...</p>}>
        <PostList />
      </Suspense>
    </div>
  )
}

// app/dashboard/user-list.tsx - Server Component
export async function UserList() {
  const users = await prisma.user.findMany()
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}
```

### Form Handling with Server Actions

Server Actions provide a modern way to handle forms without client-side JavaScript:

```typescript
// app/users/actions.ts
'use server'

import { revalidatePath } from 'next/cache'
import { prisma } from '@/lib/db'
import { z } from 'zod'

const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email()
})

export async function createUser(formData: FormData) {
  // Parse and validate form data
  const data = createUserSchema.parse({
    name: formData.get('name'),
    email: formData.get('email')
  })

  // Create user in database
  const user = await prisma.user.create({
    data
  })

  // Revalidate the users page to show new data
  revalidatePath('/users')

  return { success: true, user }
}

// app/users/create-form.tsx
import { createUser } from './actions'

export function CreateUserForm() {
  return (
    <form action={createUser}>
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit">Create User</button>
    </form>
  )
}
```

**With Client-Side Enhancement**

```typescript
// app/users/create-form.tsx
'use client'

import { createUser } from './actions'
import { useFormState, useFormStatus } from 'react-dom'

function SubmitButton() {
  const { pending } = useFormStatus()
  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Creating...' : 'Create User'}
    </button>
  )
}

export function CreateUserForm() {
  const [state, formAction] = useFormState(createUser, null)

  return (
    <form action={formAction}>
      <input name="name" required />
      <input name="email" type="email" required />
      <SubmitButton />
      {state?.error && <p className="error">{state.error}</p>}
    </form>
  )
}
```

### State Management

**Local State (useState)**

```typescript
'use client'

import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  )
}
```

**Complex State (useReducer)**

```typescript
'use client'

import { useReducer } from 'react'

type State = { count: number; step: number }
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setStep'; step: number }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + state.step }
    case 'decrement':
      return { ...state, count: state.count - state.step }
    case 'setStep':
      return { ...state, step: action.step }
    default:
      return state
  }
}

export function Counter() {
  const [state, dispatch] = useReducer(reducer, { count: 0, step: 1 })

  return (
    <div>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
      <input
        type="number"
        value={state.step}
        onChange={(e) => dispatch({ type: 'setStep', step: +e.target.value })}
      />
    </div>
  )
}
```

**Shared State (Context)**

```typescript
// lib/auth-context.tsx
'use client'

import { createContext, useContext, useState, ReactNode } from 'react'

type User = { id: string; name: string } | null

const AuthContext = createContext<{
  user: User
  login: (user: User) => void
  logout: () => void
} | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User>(null)

  return (
    <AuthContext.Provider
      value={{
        user,
        login: setUser,
        logout: () => setUser(null)
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used within AuthProvider')
  return context
}

// app/layout.tsx
import { AuthProvider } from '@/lib/auth-context'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  )
}
```

### Error Handling

**Error Boundaries**

```typescript
// app/error.tsx - Error boundary for app routes
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  )
}

// app/dashboard/error.tsx - Specific to dashboard routes
'use client'

export default function DashboardError({ error, reset }) {
  return (
    <div className="dashboard-error">
      <h2>Dashboard Error</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Retry</button>
    </div>
  )
}
```

**Loading States**

```typescript
// app/dashboard/loading.tsx - Automatic loading UI
export default function Loading() {
  return (
    <div className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
      <div className="h-64 bg-gray-200 rounded"></div>
    </div>
  )
}
```

---

## Next.js Patterns

### File Conventions

```
app/
├── layout.tsx          # Layout wrapper
├── page.tsx            # Page component
├── loading.tsx         # Loading UI (Suspense fallback)
├── error.tsx           # Error boundary
├── not-found.tsx       # 404 handler
├── route.ts            # API route handler
└── template.tsx        # Re-rendered layout (unlike layout.tsx)
```

### Dynamic Routes

```typescript
// app/posts/[id]/page.tsx
interface PageProps {
  params: { id: string }
  searchParams: { [key: string]: string | string[] | undefined }
}

export default async function PostPage({ params, searchParams }: PageProps) {
  const post = await prisma.post.findUnique({
    where: { id: params.id }
  })

  return <article>{post.title}</article>
}

// Generate static params at build time
export async function generateStaticParams() {
  const posts = await prisma.post.findMany()
  return posts.map(post => ({ id: post.id }))
}
```

**Catch-all Routes**

```typescript
// app/docs/[...slug]/page.tsx
interface PageProps {
  params: { slug: string[] }
}

export default function DocsPage({ params }: PageProps) {
  // /docs/getting-started → slug = ['getting-started']
  // /docs/api/users → slug = ['api', 'users']
  const path = params.slug.join('/')
  return <div>Docs: {path}</div>
}
```

### Route Groups

```typescript
// (auth) group - doesn't affect URL structure
app/
├── (auth)/
│   ├── layout.tsx      # Auth-specific layout
│   ├── login/
│   │   └── page.tsx    # /login (not /auth/login)
│   └── register/
│       └── page.tsx    # /register (not /auth/register)
└── (marketing)/
    ├── layout.tsx      # Marketing-specific layout
    ├── about/
    │   └── page.tsx    # /about
    └── pricing/
        └── page.tsx    # /pricing
```

### Parallel Routes

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  analytics,  // @analytics/page.tsx
  team,       // @team/page.tsx
}: {
  children: React.ReactNode
  analytics: React.ReactNode
  team: React.ReactNode
}) {
  return (
    <div>
      {children}
      <div className="grid grid-cols-2 gap-4">
        {analytics}
        {team}
      </div>
    </div>
  )
}

// app/dashboard/@analytics/page.tsx
export default function Analytics() {
  return <div>Analytics Panel</div>
}

// app/dashboard/@team/page.tsx
export default function Team() {
  return <div>Team Panel</div>
}
```

### Intercepting Routes

```typescript
// Show modal when navigating from feed, full page on direct visit
app/
├── feed/
│   └── page.tsx
├── photo/
│   └── [id]/
│       └── page.tsx       # Full page: /photo/123
└── (.)/photo/
    └── [id]/
        └── page.tsx       # Modal: intercepts when navigating from feed

// app/(.)/photo/[id]/page.tsx
export default function PhotoModal({ params }: { params: { id: string } }) {
  return (
    <dialog open>
      <img src={`/photos/${params.id}.jpg`} />
    </dialog>
  )
}
```

### Middleware

```typescript
// middleware.ts (at root or in app/)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Check authentication
  const token = request.cookies.get('auth-token')

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Add custom header
  const response = NextResponse.next()
  response.headers.set('x-custom-header', 'value')
  return response
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*']
}
```

### Environment Variables

```typescript
// .env.local
DATABASE_URL="postgresql://..."
NEXT_PUBLIC_API_URL="https://api.example.com"  # Public (exposed to browser)
SECRET_KEY="secret123"                          # Private (server only)

// Usage
// Server Components and API Routes (can access all vars)
const dbUrl = process.env.DATABASE_URL
const secret = process.env.SECRET_KEY

// Client Components (only NEXT_PUBLIC_ vars)
const apiUrl = process.env.NEXT_PUBLIC_API_URL
// ❌ process.env.SECRET_KEY is undefined on client
```

---

## TypeScript Patterns

### Component Props Typing

```typescript
// Basic props
interface ButtonProps {
  label: string
  onClick: () => void
  variant?: 'primary' | 'secondary'
}

export function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return <button onClick={onClick}>{label}</button>
}

// Extending HTML attributes
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string
  error?: string
}

export function Input({ label, error, ...props }: InputProps) {
  return (
    <div>
      <label>{label}</label>
      <input {...props} />
      {error && <span className="error">{error}</span>}
    </div>
  )
}

// Children typing
interface CardProps {
  title: string
  children: React.ReactNode
}

export function Card({ title, children }: CardProps) {
  return (
    <div>
      <h3>{title}</h3>
      {children}
    </div>
  )
}

// Generic components
interface ListProps<T> {
  items: T[]
  renderItem: (item: T) => React.ReactNode
}

export function List<T>({ items, renderItem }: ListProps<T>) {
  return <ul>{items.map(renderItem)}</ul>
}

// Usage
<List items={users} renderItem={(user) => <li key={user.id}>{user.name}</li>} />
```

### API Response Typing

```typescript
// types/api.ts
export interface ApiResponse<T> {
  data: T
  error?: string
  meta?: {
    page: number
    total: number
  }
}

export interface User {
  id: string
  name: string
  email: string
}

// app/api/users/route.ts
import type { ApiResponse, User } from '@/types/api'

export async function GET(): Promise<Response> {
  const users = await prisma.user.findMany()

  const response: ApiResponse<User[]> = {
    data: users,
    meta: { page: 1, total: users.length }
  }

  return Response.json(response)
}

// Client-side usage
async function fetchUsers(): Promise<User[]> {
  const res = await fetch('/api/users')
  const json: ApiResponse<User[]> = await res.json()
  return json.data
}
```

### Prisma Types Integration

```typescript
import { Prisma, User } from '@prisma/client'

// Use generated types
const user: User = {
  id: '1',
  name: 'Alice',
  email: 'alice@example.com',
  createdAt: new Date()
}

// Include relations
type UserWithPosts = Prisma.UserGetPayload<{
  include: { posts: true }
}>

async function getUserWithPosts(id: string): Promise<UserWithPosts> {
  return prisma.user.findUnique({
    where: { id },
    include: { posts: true }
  })
}

// Select specific fields
type UserNameAndEmail = Prisma.UserGetPayload<{
  select: { name: true; email: true }
}>
```

### Type Guards

```typescript
// Narrow union types
type Shape =
  | { kind: 'circle'; radius: number }
  | { kind: 'rectangle'; width: number; height: number }

function isCircle(shape: Shape): shape is { kind: 'circle'; radius: number } {
  return shape.kind === 'circle'
}

function getArea(shape: Shape): number {
  if (isCircle(shape)) {
    return Math.PI * shape.radius ** 2  // TypeScript knows shape.radius exists
  } else {
    return shape.width * shape.height   // TypeScript knows shape.width exists
  }
}
```

### Utility Types

```typescript
interface User {
  id: string
  name: string
  email: string
  password: string
}

// Partial - all properties optional
type PartialUser = Partial<User>

// Pick - select specific properties
type UserCredentials = Pick<User, 'email' | 'password'>

// Omit - exclude specific properties
type PublicUser = Omit<User, 'password'>

// Required - all properties required
type RequiredUser = Required<Partial<User>>

// Record - create object type with specific keys
type UserRoles = Record<string, 'admin' | 'user' | 'guest'>
```

---

## Database Patterns

### Prisma Schema Design

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  posts     Post[]
  profile   Profile?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@map("users")  // Custom table name
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId  String
  tags      Tag[]    @relation("PostTags")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@index([published])
  @@map("posts")
}

model Profile {
  id     String @id @default(cuid())
  bio    String?
  user   User   @relation(fields: [userId], references: [id])
  userId String @unique

  @@map("profiles")
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[] @relation("PostTags")

  @@map("tags")
}
```

### Migrations Workflow

```bash
# Create migration from schema changes
pnpm db:migrate dev --name add_user_profile

# Apply migrations in production
pnpm db:migrate deploy

# Generate Prisma Client after schema changes
pnpm prisma generate

# Reset database (drop all data and reapply migrations)
pnpm db:migrate reset

# View database in browser
pnpm db:studio
```

### Query Patterns

```typescript
import { prisma } from '@/lib/db'

// Find unique
const user = await prisma.user.findUnique({
  where: { id: '123' }
})

// Find many with filters
const posts = await prisma.post.findMany({
  where: {
    published: true,
    author: {
      email: {
        contains: '@example.com'
      }
    }
  },
  orderBy: { createdAt: 'desc' },
  take: 10,
  skip: 0
})

// Include relations
const userWithPosts = await prisma.user.findUnique({
  where: { id: '123' },
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' }
    },
    profile: true
  }
})

// Create with relations
const post = await prisma.post.create({
  data: {
    title: 'Hello World',
    content: 'This is my first post',
    author: {
      connect: { id: userId }  // Connect existing user
    },
    tags: {
      connectOrCreate: [
        {
          where: { name: 'typescript' },
          create: { name: 'typescript' }
        }
      ]
    }
  }
})

// Update
await prisma.user.update({
  where: { id: '123' },
  data: { name: 'New Name' }
})

// Upsert (update or create)
await prisma.user.upsert({
  where: { email: 'alice@example.com' },
  update: { name: 'Alice Updated' },
  create: {
    email: 'alice@example.com',
    name: 'Alice'
  }
})

// Delete
await prisma.post.delete({
  where: { id: '123' }
})

// Count
const count = await prisma.post.count({
  where: { published: true }
})

// Aggregate
const stats = await prisma.post.aggregate({
  _count: true,
  _avg: { views: true },
  _max: { createdAt: true }
})
```

### Transaction Handling

```typescript
// Sequential operations in transaction
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({
    data: { email: 'alice@example.com', name: 'Alice' }
  })

  await tx.post.create({
    data: {
      title: 'First post',
      authorId: user.id
    }
  })
})

// Batch operations
await prisma.$transaction([
  prisma.user.create({ data: { email: 'user1@example.com', name: 'User 1' } }),
  prisma.user.create({ data: { email: 'user2@example.com', name: 'User 2' } }),
  prisma.user.create({ data: { email: 'user3@example.com', name: 'User 3' } })
])
```

---

## API Patterns

### Route Handlers

```typescript
// app/api/users/route.ts
import { NextRequest } from 'next/server'
import { z } from 'zod'
import { prisma } from '@/lib/db'

// GET /api/users
export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '10')

    const users = await prisma.user.findMany({
      take: limit,
      skip: (page - 1) * limit,
      orderBy: { createdAt: 'desc' }
    })

    return Response.json({ data: users })
  } catch (error) {
    return Response.json({ error: 'Failed to fetch users' }, { status: 500 })
  }
}

// POST /api/users
const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email()
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const data = createUserSchema.parse(body)

    const user = await prisma.user.create({ data })

    return Response.json({ data: user }, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return Response.json({ error: error.errors }, { status: 400 })
    }
    return Response.json({ error: 'Failed to create user' }, { status: 500 })
  }
}

// app/api/users/[id]/route.ts
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const user = await prisma.user.findUnique({
    where: { id: params.id }
  })

  if (!user) {
    return Response.json({ error: 'User not found' }, { status: 404 })
  }

  return Response.json({ data: user })
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const body = await request.json()

  const user = await prisma.user.update({
    where: { id: params.id },
    data: body
  })

  return Response.json({ data: user })
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  await prisma.user.delete({
    where: { id: params.id }
  })

  return Response.json({ success: true }, { status: 204 })
}
```

### Request Validation

```typescript
import { z } from 'zod'

const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().optional(),
  published: z.boolean().default(false),
  tags: z.array(z.string()).optional()
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    // Validate and parse
    const data = createPostSchema.parse(body)

    // data is now type-safe and validated
    const post = await prisma.post.create({ data })

    return Response.json({ data: post })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return Response.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      )
    }
    return Response.json({ error: 'Internal error' }, { status: 500 })
  }
}
```

### Error Handling

```typescript
class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message)
  }
}

function handleApiError(error: unknown): Response {
  console.error('API Error:', error)

  if (error instanceof ApiError) {
    return Response.json(
      { error: error.message, code: error.code },
      { status: error.statusCode }
    )
  }

  if (error instanceof z.ZodError) {
    return Response.json(
      { error: 'Validation failed', details: error.errors },
      { status: 400 }
    )
  }

  return Response.json(
    { error: 'Internal server error' },
    { status: 500 }
  )
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    if (!body.email) {
      throw new ApiError('Email is required', 400, 'MISSING_EMAIL')
    }

    const user = await prisma.user.create({ data: body })
    return Response.json({ data: user })
  } catch (error) {
    return handleApiError(error)
  }
}
```

---

## Testing Patterns

### Unit Testing with Vitest

```typescript
// lib/utils.test.ts
import { describe, it, expect } from 'vitest'
import { cn, formatDate } from './utils'

describe('utils', () => {
  describe('cn', () => {
    it('merges class names', () => {
      expect(cn('foo', 'bar')).toBe('foo bar')
    })

    it('handles conditional classes', () => {
      expect(cn('foo', false && 'bar', 'baz')).toBe('foo baz')
    })
  })

  describe('formatDate', () => {
    it('formats date correctly', () => {
      const date = new Date('2024-01-15')
      expect(formatDate(date)).toBe('January 15, 2024')
    })
  })
})
```

### Component Testing

```typescript
// components/button.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'
import { Button } from './button'

describe('Button', () => {
  it('renders with label', () => {
    render(<Button label="Click me" onClick={() => {}} />)
    expect(screen.getByRole('button')).toHaveTextContent('Click me')
  })

  it('calls onClick when clicked', async () => {
    const onClick = vi.fn()
    render(<Button label="Click me" onClick={onClick} />)

    await userEvent.click(screen.getByRole('button'))
    expect(onClick).toHaveBeenCalledOnce()
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button label="Click me" onClick={() => {}} disabled />)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
```

### Integration Testing

```typescript
// app/api/users/route.test.ts
import { describe, it, expect, beforeEach } from 'vitest'
import { POST } from './route'

describe('POST /api/users', () => {
  beforeEach(async () => {
    // Clear database
    await prisma.user.deleteMany()
  })

  it('creates a user', async () => {
    const request = new Request('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({
        name: 'Alice',
        email: 'alice@example.com'
      })
    })

    const response = await POST(request)
    const data = await response.json()

    expect(response.status).toBe(201)
    expect(data.data).toMatchObject({
      name: 'Alice',
      email: 'alice@example.com'
    })
  })

  it('returns 400 for invalid data', async () => {
    const request = new Request('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({ name: '' })  // Missing email
    })

    const response = await POST(request)
    expect(response.status).toBe(400)
  })
})
```

---

## Common Commands

```bash
# Development
pnpm dev                 # Start dev server
pnpm build              # Build for production
pnpm start              # Start production server
pnpm lint               # Run ESLint
pnpm type-check         # Run TypeScript compiler check
pnpm format             # Format code with Prettier

# Database
pnpm db:migrate dev     # Create and apply migration
pnpm db:migrate deploy  # Apply migrations (production)
pnpm db:migrate reset   # Reset database
pnpm db:studio          # Open Prisma Studio
pnpm db:seed            # Run seed script
pnpm db:push            # Push schema without migration (dev only)

# Testing
pnpm test               # Run tests
pnpm test:watch         # Run tests in watch mode
pnpm test:coverage      # Run tests with coverage
pnpm test:e2e           # Run E2E tests

# Package management
pnpm install            # Install dependencies
pnpm add <pkg>          # Add dependency
pnpm add -D <pkg>       # Add dev dependency
pnpm remove <pkg>       # Remove dependency
pnpm update             # Update dependencies

# Prisma
pnpm prisma generate    # Generate Prisma Client
pnpm prisma studio      # Open Prisma Studio
pnpm prisma db push     # Push schema to database
pnpm prisma db pull     # Pull schema from database
```

---

## Troubleshooting

### Hydration Mismatch

**Error:** "Text content does not match server-rendered HTML"

**Causes:**
- Using browser-only APIs (window, localStorage) during render
- Rendering different content on server vs client
- Date formatting differences (timezones)

**Solutions:**
```typescript
// ❌ Wrong - runs on server and client
function Component() {
  const data = localStorage.getItem('key')  // undefined on server
  return <div>{data}</div>
}

// ✅ Right - only run on client
'use client'
import { useEffect, useState } from 'react'

function Component() {
  const [data, setData] = useState<string | null>(null)

  useEffect(() => {
    setData(localStorage.getItem('key'))
  }, [])

  return <div>{data}</div>
}

// ✅ Alternative - suppressHydrationWarning for expected differences
function Component() {
  return (
    <time suppressHydrationWarning>
      {new Date().toLocaleString()}
    </time>
  )
}
```

### Cannot Read Property of Undefined

**Error:** "Cannot read property 'x' of undefined"

**Causes:**
- Accessing properties before data loads
- Not handling null/undefined in types

**Solutions:**
```typescript
// ❌ Wrong
function UserProfile({ user }) {
  return <div>{user.name}</div>  // Crashes if user is undefined
}

// ✅ Right - optional chaining
function UserProfile({ user }) {
  return <div>{user?.name ?? 'Unknown'}</div>
}

// ✅ Right - early return
function UserProfile({ user }) {
  if (!user) return <div>Loading...</div>
  return <div>{user.name}</div>
}

// ✅ Right - proper TypeScript typing
interface UserProfileProps {
  user: User | null  // Explicit that user can be null
}

function UserProfile({ user }: UserProfileProps) {
  if (!user) return null
  return <div>{user.name}</div>
}
```

### Database Connection Issues

**Error:** "Can't reach database server"

**Solutions:**
```bash
# Check DATABASE_URL is correct
echo $DATABASE_URL

# Test connection with Prisma
pnpm prisma db pull

# Check if database is running (PostgreSQL)
pg_isready

# Start database (if using Docker)
docker-compose up -d postgres

# Check connection pooling settings
# Update DATABASE_URL with connection_limit
# postgresql://user:pass@localhost:5432/db?connection_limit=10
```

### Port Already in Use

**Error:** "Port 3000 is already in use"

**Solutions:**
```bash
# Find process using port
lsof -i :3000

# Kill process
kill -9 <PID>

# Or use different port
PORT=3001 pnpm dev
```

---

## Best Practices

### Code Organization

- **Collocate related code**: Keep components, tests, and styles together
- **Use barrel exports**: Create index.ts files to simplify imports
- **Separate concerns**: UI components, business logic, API clients
- **Shared utilities**: Extract common functions to lib/

### Performance Optimization

- **Use Server Components by default**: Smaller client bundles
- **Code split with dynamic imports**: Load code only when needed
  ```typescript
  const HeavyComponent = dynamic(() => import('./heavy-component'))
  ```
- **Optimize images**: Use Next.js Image component
  ```typescript
  import Image from 'next/image'
  <Image src="/photo.jpg" width={500} height={300} alt="Photo" />
  ```
- **Implement pagination**: Don't load all data at once
- **Use Suspense for data fetching**: Parallel loading of independent data

### Security

- **Validate all inputs**: Use Zod for runtime validation
- **Sanitize user content**: Prevent XSS attacks
- **Use environment variables**: Never commit secrets
- **Implement rate limiting**: Prevent abuse
- **Use HTTPS in production**: Secure data in transit
- **Implement CSRF protection**: Use Next.js built-in protection

### Accessibility

- **Semantic HTML**: Use proper elements (button, not div with onClick)
- **ARIA labels**: Add labels for screen readers
- **Keyboard navigation**: Ensure all interactive elements are accessible
- **Color contrast**: Meet WCAG standards
- **Focus management**: Show focus indicators

---

## Anti-Patterns to Avoid

❌ **Using useState in Server Components**
```typescript
// ❌ Wrong
export default function Page() {
  const [data, setData] = useState([])  // Error!
  return <div>{data}</div>
}
```

❌ **Fetching data in useEffect**
```typescript
// ❌ Wrong (in Next.js App Router)
'use client'
export default function Page() {
  const [data, setData] = useState(null)
  useEffect(() => {
    fetch('/api/data').then(r => r.json()).then(setData)
  }, [])
  return <div>{data}</div>
}

// ✅ Right - fetch in Server Component
export default async function Page() {
  const data = await fetch('/api/data').then(r => r.json())
  return <div>{data}</div>
}
```

❌ **Not handling loading states**
```typescript
// ❌ Wrong
function UserList() {
  const users = await fetchUsers()  // What if this is slow?
  return <ul>{users.map(u => <li>{u.name}</li>)}</ul>
}

// ✅ Right
function UserListPage() {
  return (
    <Suspense fallback={<div>Loading users...</div>}>
      <UserList />
    </Suspense>
  )
}
```

❌ **Over-using Client Components**
```typescript
// ❌ Wrong - entire page is client-side
'use client'
export default function Page() {
  const data = await fetchData()  // Can't use async in client component!
  return <div>{data}</div>
}

// ✅ Right - Server Component wrapper, Client Component for interactivity
export default async function Page() {
  const data = await fetchData()
  return <InteractiveUI data={data} />  // Only UI is client-side
}
```

❌ **Missing error boundaries**
```typescript
// ❌ Wrong - no error handling
export default async function Page() {
  const data = await fetchData()  // What if this throws?
  return <div>{data}</div>
}

// ✅ Right - add error.tsx in same directory
// app/dashboard/error.tsx
'use client'
export default function Error({ error, reset }) {
  return (
    <div>
      <h2>Error: {error.message}</h2>
      <button onClick={reset}>Retry</button>
    </div>
  )
}
```

---

## Quick Reference Checklist

When implementing a web feature, ensure:

- [ ] **Server vs Client**: Used Server Components where possible
- [ ] **TypeScript**: All props and return types defined
- [ ] **Data fetching**: Fetched in Server Components or Server Actions
- [ ] **Loading states**: Added loading.tsx or Suspense boundaries
- [ ] **Error handling**: Added error.tsx boundaries
- [ ] **Validation**: Validated inputs with Zod
- [ ] **Database**: Used Prisma for type-safe queries
- [ ] **Testing**: Wrote tests for critical paths
- [ ] **Accessibility**: Added ARIA labels, keyboard support
- [ ] **Performance**: Optimized images, implemented code splitting
- [ ] **Security**: Validated inputs, sanitized outputs, checked auth

---

**End of Web Development Context**
