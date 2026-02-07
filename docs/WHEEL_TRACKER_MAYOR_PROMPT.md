# Mayor Prompt: Wheel Tracker Implementation

> **Copy this prompt and send to the Mayor to execute the Wheel Tracker product plan**

---

## Implementation Request

Create parallelized work for implementing the Wheel Tracker application following the PRD at `wheel-tracker/docs/PRODUCT_PLAN.md`.

**Constraints:**
- Maximum 2 polecats working simultaneously
- Assign all work to: `wheel-tracker` rig
- Create convoy: "Wheel Tracker v1.0"
- Use web development formulas where applicable

**Strategy:**
- Structure work in sequential phases (dependencies between phases)
- Within each phase, create parallel tracks when possible (2 polecats max)
- Each phase blocks on previous phase completion

---

## Phase 0: Foundation (SEQUENTIAL - Must Complete First)

**Priority: CRITICAL**
**Dependencies:** None
**Parallelization:** Limited (infrastructure setup must be sequential)

Create these beads in order:

### Bead 1: Project Initialization
```
Title: Initialize Wheel Tracker Next.js Project

Description:
Set up the foundational Next.js project with TypeScript and all tooling.

Tasks:
- [ ] Create Next.js 14+ project with App Router
- [ ] Configure TypeScript (strict mode)
- [ ] Set up pnpm workspace if needed
- [ ] Configure Tailwind CSS
- [ ] Set up ESLint, Prettier
- [ ] Configure Husky (git hooks)
- [ ] Create basic app structure (app/, components/, lib/)
- [ ] Set up .env.example with all required variables
- [ ] Create README with setup instructions
- [ ] Verify dev server runs: pnpm dev

Acceptance Criteria:
- pnpm dev starts without errors
- TypeScript compiles with no errors
- Linter passes with no warnings
- Git hooks work on commit

Tags: [foundation, setup, infrastructure]
```

### Bead 2: Database Setup
```
Title: Set up PostgreSQL and Prisma ORM

Description:
Configure database infrastructure and create complete Prisma schema for Wheel Tracker.

Tasks:
- [ ] Set up Docker Compose with PostgreSQL 16
- [ ] Install and configure Prisma
- [ ] Create complete Prisma schema from PRD:
  - User model
  - Trade model (with enums: TradeType, TradeAction, TradeStatus)
  - Position model (with enum: PositionStatus)
  - StockPrice model
  - Benchmark model
  - All relations and indexes
- [ ] Generate Prisma Client
- [ ] Create initial migration: pnpm db:migrate dev --name init
- [ ] Verify migration applies cleanly
- [ ] Set up db:studio script
- [ ] Test database connection

Dependencies: Bead 1 (needs project structure)

Acceptance Criteria:
- Docker Compose starts PostgreSQL
- Prisma schema matches PRD data model
- Migration creates all tables
- Prisma Studio opens and shows schema
- Can query database successfully

Tags: [foundation, database, prisma]
```

### Bead 3: Authentication Setup
```
Title: Implement User Authentication

Description:
Set up NextAuth.js for user authentication with email/password.

Tasks:
- [ ] Install NextAuth.js
- [ ] Configure NextAuth with Prisma adapter
- [ ] Set up email/password authentication
- [ ] Create auth API routes
- [ ] Add session management
- [ ] Create login page UI
- [ ] Create register page UI
- [ ] Add protected route middleware
- [ ] Test login/logout flow
- [ ] Add user session display in layout

Dependencies: Bead 2 (needs database)

Acceptance Criteria:
- Users can register with email/password
- Users can login and logout
- Session persists across page reloads
- Protected routes redirect to login
- User info displays when logged in

Tags: [foundation, auth, security]
```

**Phase 0 Assignment:**
Assign all 3 beads sequentially to one polecat (they must complete in order).

---

## Phase 1: Trade Entry (PARALLEL - 2 Tracks)

**Priority: HIGH**
**Dependencies:** Phase 0 complete
**Parallelization:** Split into Backend + Frontend tracks

### Track 1: Trade Backend (Polecat 1)

#### Bead 4: Trade Data Model & API
```
Title: Implement Trade CRUD API

Description:
Build Server Actions and API routes for trade management.

Tasks:
- [ ] Create Zod validation schemas for Trade
  - CreateTradeSchema (all required fields)
  - UpdateTradeSchema (partial fields)
- [ ] Implement Server Actions:
  - createTrade(formData) - create new trade
  - updateTrade(id, data) - update existing trade
  - deleteTrade(id) - soft delete trade
  - updateTradeStatus(id, status) - mark expired/assigned
- [ ] Add trade queries:
  - getTrades(userId, filters) - list with filtering
  - getTrade(id) - single trade details
  - getOpenTrades(userId) - trades with status OPEN
- [ ] Handle trade status transitions:
  - OPEN → EXPIRED (mark expired worthless)
  - OPEN → ASSIGNED (for puts: create position, for calls: close position)
- [ ] Write integration tests for trade CRUD
- [ ] Add error handling and validation

Use web-api formula concepts for structure.

Dependencies: Phase 0 complete

Acceptance Criteria:
- Can create PUT and CALL trades
- Can update trade details
- Can mark trades as EXPIRED
- Can mark trades as ASSIGNED (position creation tested separately)
- All validations work correctly
- Tests pass

Tags: [phase1, backend, trade, api]
```

### Track 2: Trade Frontend (Polecat 2)

#### Bead 5: Trade Entry Form Component
```
Title: Create Trade Entry Form UI

Description:
Build the form component for entering new put/call trades.

Component: TradeEntryForm
Use web-component formula concepts.

Tasks:
- [ ] Create TradeEntryForm component
- [ ] Use React Hook Form + Zod validation
- [ ] Form fields:
  - Ticker (text input with validation)
  - Trade Type (radio: PUT or CALL)
  - Strike Price (number input)
  - Premium (number input, per share)
  - Quantity (number input, default 1)
  - Entry Date (date picker)
  - Expiration Date (date picker)
- [ ] Add field validation:
  - Ticker: uppercase, max 5 chars
  - Strike/Premium: positive numbers
  - Quantity: positive integer
  - Expiration must be after entry date
- [ ] Add form submission with loading state
- [ ] Show success/error messages
- [ ] Style with Tailwind CSS
- [ ] Make responsive (mobile-friendly)
- [ ] Add keyboard navigation support
- [ ] Write component tests

Dependencies: Phase 0 complete

Acceptance Criteria:
- Form renders correctly
- Validation works for all fields
- Can submit valid trade
- Loading states show during submission
- Error messages display clearly
- Works on mobile screens
- Keyboard accessible

Tags: [phase1, frontend, trade, component, form]
```

#### Bead 6: Trade List Component
```
Title: Create Trade List Display Component

Description:
Build the component for displaying list of trades with filtering.

Component: TradeList
Use web-component formula concepts.

Tasks:
- [ ] Create TradeList component
- [ ] Display trades in table/card layout
- [ ] Show columns:
  - Ticker
  - Type (PUT/CALL badge)
  - Strike
  - Premium
  - Expiration
  - Status (badge with color)
  - Actions (edit/delete/status buttons)
- [ ] Add filters:
  - By ticker (search)
  - By status (OPEN/EXPIRED/ASSIGNED)
  - By type (PUT/CALL)
  - By date range
- [ ] Add sorting:
  - By expiration date
  - By ticker
  - By premium
- [ ] Add trade actions:
  - Edit button → opens edit form
  - Delete button → confirmation dialog
  - "Mark Expired" button (for OPEN trades)
  - "Mark Assigned" button (for OPEN trades)
- [ ] Handle empty state (no trades yet)
- [ ] Make responsive (table → cards on mobile)
- [ ] Write component tests

Dependencies: Phase 0 complete

Acceptance Criteria:
- Trades display in organized layout
- Filters work correctly
- Sorting works on all columns
- Actions trigger correct behavior
- Responsive on mobile
- Empty state shows helpful message
- Tests pass

Tags: [phase1, frontend, trade, component, list]
```

**Phase 1 Assignment Strategy:**
- Assign Bead 4 (Trade Backend) to Polecat 1
- Assign Beads 5-6 (Trade Frontend) to Polecat 2
- Both tracks can run in parallel
- Beads 5 and 6 can be worked sequentially by same polecat (form first, then list)

**Phase 1 Dependencies:**
```
Phase 2 depends on Phase 1 (all beads 4-6 must complete)
```

---

## Phase 2: Position Management (PARALLEL - 2 Tracks)

**Priority: HIGH**
**Dependencies:** Phase 1 complete (trade system must exist)
**Parallelization:** Split into Backend + Frontend tracks

### Track 1: Position Backend (Polecat 1)

#### Bead 7: Position Creation & Management API
```
Title: Implement Position CRUD and Assignment Logic

Description:
Build Server Actions for position management and put→position assignment flow.

Tasks:
- [ ] Create Zod schemas for Position
- [ ] Implement position assignment logic:
  - When PUT trade marked ASSIGNED:
    - Create Position record
    - Calculate cost basis: strikePrice - premium
    - Set shares: quantity * 100
    - Link to assignment trade
    - Update trade status
- [ ] Implement position closing logic:
  - When CALL trade marked ASSIGNED:
    - Find related position
    - Update position status to CLOSED
    - Set closedDate and closedPrice
    - Calculate final P&L
- [ ] Add position queries:
  - getPositions(userId, filters) - list positions
  - getActivePositions(userId) - only ACTIVE
  - getPosition(id) - single position with all trades
- [ ] Calculate unrealized P&L:
  - Fetch current stock price
  - Calculate (currentPrice - costBasis) * shares
- [ ] Write integration tests for assignment flows
- [ ] Handle edge cases (position not found, etc.)

Use web-api formula concepts.

Dependencies: Phase 1 complete (needs trade system)

Acceptance Criteria:
- Marking PUT as assigned creates position correctly
- Cost basis calculated correctly
- Marking CALL as assigned closes position
- Can query active and closed positions
- Unrealized P&L calculated correctly
- All tests pass

Tags: [phase2, backend, position, assignment]
```

### Track 2: Position Frontend (Polecat 2)

#### Bead 8: Position Card Component
```
Title: Create Position Display Card Component

Description:
Build component for displaying stock position with current value and P&L.

Component: PositionCard
Use web-component formula concepts.

Tasks:
- [ ] Create PositionCard component
- [ ] Display position details:
  - Ticker (large, prominent)
  - Shares owned
  - Cost basis (per share and total)
  - Current price (from API, auto-updated)
  - Current value
  - Unrealized P&L ($ and %)
  - Days held
- [ ] Add color coding:
  - Green for profit
  - Red for loss
  - Gray for break-even
- [ ] Show premium from covered calls
- [ ] Add action buttons:
  - "Sell Call" (quick entry)
  - "View Details" (expand/navigate)
- [ ] Handle loading state (price fetching)
- [ ] Handle error state (price unavailable)
- [ ] Make responsive
- [ ] Write component tests

Dependencies: Phase 1 complete (needs trade display patterns)

Acceptance Criteria:
- Position displays all key info
- P&L shows correct colors
- Current price updates
- Action buttons work
- Responsive on mobile
- Loading/error states handled
- Tests pass

Tags: [phase2, frontend, position, component]
```

#### Bead 9: Active Positions Dashboard
```
Title: Create Active Positions List View

Description:
Build dashboard view showing all active stock positions.

Page: /positions (or dashboard section)

Tasks:
- [ ] Create ActivePositions page/component
- [ ] Display all active positions using PositionCard
- [ ] Add sorting:
  - By ticker (alphabetical)
  - By P&L (best to worst)
  - By days held
- [ ] Add filters:
  - By ticker (search)
  - Profit/Loss/All
- [ ] Show summary stats:
  - Total positions count
  - Total unrealized P&L
  - Total capital deployed
- [ ] Handle empty state (no positions)
- [ ] Add "Sell Call" quick action from card
- [ ] Make responsive (grid → list on mobile)
- [ ] Write component tests

Dependencies: Bead 8 complete (needs PositionCard)

Acceptance Criteria:
- All active positions display
- Sorting works correctly
- Filters work
- Summary stats accurate
- Quick actions work
- Responsive on mobile
- Empty state helpful
- Tests pass

Tags: [phase2, frontend, position, dashboard]
```

**Phase 2 Assignment Strategy:**
- Assign Bead 7 (Position Backend) to Polecat 1
- Assign Beads 8-9 (Position Frontend) to Polecat 2
- Both tracks can run in parallel
- Bead 9 depends on Bead 8 (sequential within frontend track)

**Phase 2 Dependencies:**
```
Phase 3 depends on Phase 2 (position system must exist for price updates)
```

---

## Phase 3: Market Data Integration (SEQUENTIAL - Complex Integration)

**Priority: HIGH**
**Dependencies:** Phase 2 complete (needs positions to update prices for)
**Parallelization:** Limited (API integration requires sequential setup)

#### Bead 10: Alpha Vantage API Client
```
Title: Build Market Data API Integration

Description:
Implement Alpha Vantage API client for fetching stock prices.

Tasks:
- [ ] Install/configure API client
- [ ] Set up ALPHA_VANTAGE_API_KEY in .env
- [ ] Create market-data service:
  - lib/market-data/alpha-vantage.ts
  - fetchStockPrice(ticker) - get single quote
  - batchFetchPrices(tickers[]) - get multiple quotes
  - Rate limiting: 5 req/min (12 second delay)
- [ ] Create helper functions:
  - isMarketOpen() - check if trading hours (9:30am-4pm ET)
  - getActiveTickers() - get unique tickers from trades/positions
- [ ] Implement StockPrice model updates:
  - Upsert price data
  - Track lastUpdated timestamp
  - Store previousClose and changePercent
- [ ] Add error handling:
  - API rate limit exceeded
  - Invalid ticker
  - Network failures
  - Graceful degradation
- [ ] Write integration tests
- [ ] Create manual refresh endpoint

Dependencies: Phase 2 complete

Acceptance Criteria:
- Can fetch price for single ticker
- Can batch fetch multiple tickers
- Rate limiting works (doesn't exceed 5/min)
- Prices stored in database correctly
- Error handling works
- Tests pass

Tags: [phase3, backend, market-data, api]
```

#### Bead 11: Background Price Update Job
```
Title: Implement Automated Price Update Cron Job

Description:
Create background job to automatically update stock prices during market hours.

Tasks:
- [ ] Create cron API route: app/api/cron/update-prices/route.ts
- [ ] Implement update logic:
  - Check if market is open
  - Get all active tickers
  - Fetch prices for each ticker (with rate limiting)
  - Update StockPrice records
  - Log results (success/failed counts)
- [ ] Add authentication:
  - Verify CRON_SECRET from header
  - Return 401 if unauthorized
- [ ] Configure Vercel Cron:
  - Create vercel.json
  - Schedule: */15 9-16 * * 1-5 (every 15 min, Mon-Fri, 9am-4pm)
- [ ] Add monitoring:
  - Log successful updates
  - Alert on failures
- [ ] Test locally with manual trigger
- [ ] Deploy and verify cron runs

Dependencies: Bead 10 complete (needs API client)

Acceptance Criteria:
- Cron job runs every 15 minutes during market hours
- Updates all active ticker prices
- Rate limiting respected
- Authentication works
- Logging provides useful info
- Can manually trigger for testing

Tags: [phase3, backend, cron, automation]
```

#### Bead 12: Live Price Display in UI
```
Title: Add Real-Time Price Display to Positions

Description:
Update position components to show live prices with auto-refresh.

Tasks:
- [ ] Update PositionCard to fetch current prices:
  - Query StockPrice table for ticker
  - Display current price
  - Show lastUpdated timestamp
  - Show price change indicator (+/- from previous close)
- [ ] Add manual refresh button:
  - Trigger price fetch for all positions
  - Show loading state
  - Show success/error message
- [ ] Add auto-refresh (optional):
  - Refresh prices every 5 minutes while page open
  - Use polling or Server-Sent Events
- [ ] Show price staleness warning:
  - If lastUpdated > 1 hour, show warning
  - "Prices may be outdated"
- [ ] Update P&L calculations to use current prices
- [ ] Add loading skeleton while fetching prices
- [ ] Write component tests

Dependencies: Beads 10-11 complete (needs price data available)

Acceptance Criteria:
- Current prices display on positions
- Manual refresh works
- Staleness warning shows when appropriate
- Price change indicators work
- P&L updates with current prices
- Loading states handled
- Tests pass

Tags: [phase3, frontend, prices, real-time]
```

**Phase 3 Assignment Strategy:**
- Assign Beads 10-11-12 sequentially to one polecat (complex integration)
- OR split: Polecat 1 does 10-11 (backend), Polecat 2 does 12 (frontend) after 11 completes

**Phase 3 Dependencies:**
```
Phase 4 depends on Phase 3 (P&L needs current prices)
```

---

## Phase 4: P&L Calculations (PARALLEL - 2 Tracks)

**Priority: HIGH**
**Dependencies:** Phase 3 complete (needs price data for unrealized P&L)
**Parallelization:** Split into Calculation Logic + UI tracks

### Track 1: P&L Backend (Polecat 1)

#### Bead 13: P&L Calculation Service
```
Title: Implement Comprehensive P&L Calculations

Description:
Build service layer for calculating realized and unrealized profit/loss.

Tasks:
- [ ] Create P&L calculation service:
  - lib/calculations/profit-loss.ts
- [ ] Implement realized P&L:
  - Calculate from EXPIRED trades (premium * quantity * 100)
  - Calculate from ASSIGNED calls (capital gains + premium)
  - Calculate from ASSIGNED puts (track in position cost basis)
  - Total realized P&L
- [ ] Implement unrealized P&L:
  - For ACTIVE positions: (currentPrice - costBasis) * shares
  - For OPEN calls: estimate value if closed now
  - Total unrealized P&L
- [ ] Implement per-ticker P&L:
  - Aggregate all trades for ticker
  - Sum realized and unrealized
  - Return breakdown
- [ ] Implement time-based P&L:
  - Calculate for date range
  - Daily, weekly, monthly aggregations
  - YTD and all-time
- [ ] Add portfolio-level calculations:
  - Total capital deployed
  - Total return percentage
  - Premium collected (total)
  - Win rate (% expired worthless)
  - Assignment rate (% assigned)
- [ ] Write unit tests for all calculations
- [ ] Optimize for performance (caching where appropriate)

Dependencies: Phase 3 complete (needs current prices)

Acceptance Criteria:
- Realized P&L matches manual calculation
- Unrealized P&L accurate with current prices
- Per-ticker breakdown correct
- Time-based aggregations work
- Portfolio stats accurate
- All tests pass
- Performance acceptable (< 100ms queries)

Tags: [phase4, backend, pl, calculations]
```

### Track 2: P&L Frontend (Polecat 2)

#### Bead 14: P&L Dashboard Component
```
Title: Create P&L Dashboard with Charts

Description:
Build comprehensive dashboard showing all P&L metrics and charts.

Page: /dashboard or home page

Tasks:
- [ ] Create PLDashboard component
- [ ] Add headline metric cards:
  - Total P&L ($ and %)
  - Realized P&L
  - Unrealized P&L
  - vs SPY (placeholder for now)
- [ ] Add performance stat cards:
  - Total premium collected
  - Win rate
  - Assignment rate
  - Active positions count
  - Open contracts count
- [ ] Install and configure Recharts
- [ ] Create P&L over time chart:
  - Line chart
  - X-axis: date
  - Y-axis: cumulative P&L
  - Show realized and total lines
- [ ] Create P&L by ticker chart:
  - Bar chart
  - X-axis: ticker
  - Y-axis: P&L
  - Color code: green (profit), red (loss)
- [ ] Create win rate pie chart:
  - Expired worthless vs Assigned
  - Show percentages
- [ ] Add time range selector:
  - 1M, 3M, 6M, 1Y, All
  - Update all charts
- [ ] Make responsive (stack on mobile)
- [ ] Add loading states
- [ ] Write component tests

Dependencies: Phase 3 complete (can build UI with mock data)

Acceptance Criteria:
- All metric cards display correctly
- Charts render with real data
- Time range selector updates charts
- Responsive on mobile
- Loading states show
- Tests pass

Tags: [phase4, frontend, pl, dashboard, charts]
```

#### Bead 15: P&L Export Feature
```
Title: Add CSV Export for Tax Reporting

Description:
Implement export functionality for downloading P&L reports.

Tasks:
- [ ] Create export API route:
  - app/api/export/pl/route.ts
  - Generate CSV with all trades
- [ ] CSV columns:
  - Date Opened
  - Date Closed
  - Ticker
  - Type (PUT/CALL)
  - Strike
  - Premium
  - Quantity
  - Status
  - Realized P&L
  - Notes
- [ ] Add CSV summary section:
  - Total realized P&L
  - Total unrealized P&L
  - Total premium collected
  - Number of trades
- [ ] Add export button to dashboard:
  - Trigger download
  - Filename: wheel-tracker-pl-YYYY-MM-DD.csv
  - Show success message
- [ ] Add date range filter for export:
  - Export only trades in selected range
  - Useful for tax year (e.g., 2024 only)
- [ ] Handle large exports (many trades)
- [ ] Write integration tests

Dependencies: Bead 13 complete (needs P&L data)

Acceptance Criteria:
- CSV exports with all trade data
- Summary section included
- Date range filtering works
- Filename includes date
- Large exports work
- Tests pass

Tags: [phase4, backend, export, csv, taxes]
```

**Phase 4 Assignment Strategy:**
- Assign Bead 13 (P&L Calculations) to Polecat 1
- Assign Beads 14-15 (P&L Frontend) to Polecat 2
- Both tracks can run in parallel
- Bead 15 depends on Bead 13 (needs calculation service)

**Phase 4 Dependencies:**
```
Phase 5 depends on Phase 4 (benchmark comparison needs P&L system)
```

---

## Phase 5: Benchmark Comparison (SEQUENTIAL)

**Priority: MEDIUM**
**Dependencies:** Phase 4 complete (needs P&L for comparison)
**Parallelization:** Limited (benchmark logic is cohesive)

#### Bead 16: Benchmark Tracking Backend
```
Title: Implement SPY Benchmark Comparison

Description:
Build system for tracking hypothetical SPY performance and comparing to wheel strategy.

Tasks:
- [ ] Create benchmark setup:
  - When user first uses app, record:
    - Initial capital amount
    - Initial date
    - SPY price on that date
  - Calculate hypothetical SPY shares: capital / spyPrice
- [ ] Fetch SPY price via Alpha Vantage:
  - Reuse market data service
  - Add SPY to price update job
- [ ] Calculate benchmark P&L:
  - Current SPY value: shares * currentPrice
  - SPY P&L: currentValue - initialCapital
  - SPY return %: (P&L / initialCapital) * 100
- [ ] Calculate comparison metrics:
  - Wheel P&L vs SPY P&L (dollar difference)
  - Wheel return % vs SPY return % (percentage point difference)
  - Outperformance/underperformance
- [ ] Add benchmark queries:
  - getBenchmark(userId, symbol) - get benchmark data
  - updateBenchmark(userId) - refresh calculation
- [ ] Support multiple benchmarks:
  - SPY (S&P 500)
  - QQQ (Nasdaq)
  - VTI (Total Market)
- [ ] Write tests for calculations

Dependencies: Phase 4 complete

Acceptance Criteria:
- Initial benchmark setup works
- SPY prices fetched and updated
- Benchmark P&L calculated correctly
- Comparison metrics accurate
- Multiple benchmarks supported
- Tests pass

Tags: [phase5, backend, benchmark, spy]
```

#### Bead 17: Benchmark Comparison UI
```
Title: Create Benchmark Comparison Dashboard

Description:
Build UI for displaying wheel strategy vs benchmark performance.

Tasks:
- [ ] Add comparison section to dashboard:
  - Show side-by-side comparison:
    - Wheel Strategy: P&L and return %
    - SPY: P&L and return %
    - Difference: $ and % outperformance
- [ ] Create comparison chart:
  - Dual-line chart (Recharts)
  - Line 1: Wheel strategy value over time
  - Line 2: SPY value over time
  - Both start at same initial capital
  - X-axis: date
  - Y-axis: portfolio value
- [ ] Add color coding:
  - Green if beating SPY
  - Red if losing to SPY
- [ ] Add benchmark selector:
  - Dropdown: SPY, QQQ, VTI
  - Updates comparison
- [ ] Add time range selector:
  - Works with existing time range filter
  - Updates comparison chart
- [ ] Show calculation details:
  - Info tooltip explaining how calculated
  - Show initial capital, shares, prices
- [ ] Make responsive
- [ ] Write component tests

Dependencies: Bead 16 complete (needs backend data)

Acceptance Criteria:
- Comparison shows correct metrics
- Dual-line chart renders
- Benchmark selector works
- Time range updates chart
- Color coding accurate
- Responsive on mobile
- Tests pass

Tags: [phase5, frontend, benchmark, comparison, charts]
```

**Phase 5 Assignment Strategy:**
- Assign Beads 16-17 sequentially to one polecat (cohesive feature)
- OR split: Polecat 1 does 16 (backend), Polecat 2 does 17 (frontend) after 16 completes

**Phase 5 Dependencies:**
```
Phase 6 depends on Phase 5 (analytics builds on all previous features)
```

---

## Phase 6: Analytics & Polish (PARALLEL - 2 Tracks)

**Priority: MEDIUM**
**Dependencies:** Phase 5 complete (all core features must exist)
**Parallelization:** Split into Features + Polish tracks

### Track 1: Advanced Features (Polecat 1)

#### Bead 18: Trade Journal with Notes & Tags
```
Title: Add Notes and Tags to Trade Journal

Description:
Enhance trade tracking with journaling capabilities.

Tasks:
- [ ] Update Trade model to support:
  - notes field (text)
  - tags field (array)
  - outcome field (dropdown)
- [ ] Create trade journal page:
  - List all trades (table view)
  - Filter by tags
  - Search in notes
  - Sort by date, P&L, outcome
- [ ] Add note editing:
  - Edit button on each trade
  - Modal/inline editor
  - Markdown support (optional)
  - Save notes
- [ ] Add tag system:
  - Predefined tags: "high-iv", "earnings", "mistake", "great-trade"
  - Custom tags (user-defined)
  - Tag autocomplete
  - Filter by tags
- [ ] Add outcome tracking:
  - Dropdown: "Great trade", "Okay", "Mistake", "Learning"
  - Show outcome in trade list
  - Filter by outcome
- [ ] Add bulk operations:
  - Select multiple trades
  - Bulk tag
  - Bulk export
- [ ] Write tests

Dependencies: Phase 5 complete

Acceptance Criteria:
- Can add notes to trades
- Can tag trades
- Tags filter works
- Search in notes works
- Outcome tracking works
- Bulk operations work
- Tests pass

Tags: [phase6, features, journal, notes, tags]
```

#### Bead 19: Upcoming Expirations & Reminders
```
Title: Create Expiration Calendar and Reminders

Description:
Build calendar view showing upcoming option expirations.

Tasks:
- [ ] Create expirations page:
  - Calendar view (next 30 days)
  - List view (upcoming expirations)
  - Group by date
- [ ] Show expiration details:
  - Trades expiring on each date
  - Type (PUT/CALL)
  - Ticker
  - Strike
  - Days until expiration
  - Current status
- [ ] Add color coding:
  - Red: < 7 days to expiration
  - Yellow: 7-14 days
  - Green: 14+ days
- [ ] Add quick actions:
  - "Mark Expired" button
  - "Mark Assigned" button
  - "Roll Option" button (placeholder)
- [ ] Add to dashboard:
  - Widget showing next 5 expirations
  - Count of expirations this week
- [ ] Add filtering:
  - Show only OPEN trades
  - Filter by ticker
  - Filter by type
- [ ] Write tests

Dependencies: Phase 5 complete

Acceptance Criteria:
- Calendar shows all expirations
- Color coding works
- Quick actions functional
- Dashboard widget displays
- Filters work
- Tests pass

Tags: [phase6, features, expirations, calendar]
```

### Track 2: Polish & UX (Polecat 2)

#### Bead 20: Responsive Design & Mobile UX
```
Title: Polish Responsive Design Across All Pages

Description:
Ensure excellent mobile experience across entire application.

Tasks:
- [ ] Audit all pages on mobile (iPhone, Android)
- [ ] Fix responsive issues:
  - Tables → cards on mobile
  - Charts → scrollable or stacked
  - Forms → full-width inputs
  - Buttons → touch-friendly size
- [ ] Optimize navigation:
  - Mobile menu (hamburger)
  - Bottom nav bar (alternative)
  - Easy access to key features
- [ ] Test on real devices:
  - iPhone (various sizes)
  - Android (various sizes)
  - iPad (tablet view)
- [ ] Add touch gestures where appropriate:
  - Swipe to delete trades
  - Pull to refresh positions
- [ ] Optimize performance:
  - Lazy load images
  - Code split routes
  - Optimize bundle size
- [ ] Fix any accessibility issues:
  - Color contrast
  - Touch targets
  - Screen reader support
- [ ] Test with real users (friends/family)

Dependencies: Phase 5 complete (all pages exist)

Acceptance Criteria:
- All pages work well on mobile
- No horizontal scroll
- All interactions touch-friendly
- Navigation intuitive on mobile
- Performance good on mobile network
- Accessibility issues resolved

Tags: [phase6, polish, responsive, mobile, ux]
```

#### Bead 21: Error Handling & Loading States
```
Title: Add Comprehensive Error Handling and Loading UX

Description:
Improve error handling and loading states throughout application.

Tasks:
- [ ] Add error boundaries:
  - Root error boundary (app/error.tsx)
  - Page-level error boundaries
  - Component-level error boundaries
- [ ] Improve loading states:
  - Skeleton loaders for cards/tables
  - Spinner for buttons
  - Progress bars for long operations
  - Loading.tsx for pages
- [ ] Add error messages:
  - User-friendly error text
  - Actionable suggestions
  - Retry buttons
  - Contact support link
- [ ] Handle edge cases:
  - Empty states (no trades, no positions)
  - Network errors (offline)
  - API errors (rate limit, invalid data)
  - Database errors
- [ ] Add toast notifications:
  - Success messages
  - Error messages
  - Info messages
  - Install react-hot-toast or similar
- [ ] Add form validation feedback:
  - Inline errors
  - Field-level validation
  - Clear error messages
- [ ] Test error scenarios
- [ ] Write error handling tests

Dependencies: Phase 5 complete (all features exist)

Acceptance Criteria:
- All pages have error boundaries
- Loading states show for async operations
- Error messages are helpful
- Empty states provide guidance
- Toast notifications work
- Form validation clear
- Tests pass

Tags: [phase6, polish, errors, loading, ux]
```

**Phase 6 Assignment Strategy:**
- Assign Beads 18-19 (Advanced Features) to Polecat 1
- Assign Beads 20-21 (Polish) to Polecat 2
- Both tracks can run in parallel

**Phase 6 Dependencies:**
```
Phase 7 depends on Phase 6 (testing needs complete application)
```

---

## Phase 7: Testing & Launch (PARALLEL THEN SEQUENTIAL)

**Priority: CRITICAL**
**Dependencies:** Phase 6 complete (all features must be built)
**Parallelization:** Testing parallel, then deploy sequential

### Track 1: Testing (Polecat 1)

#### Bead 22: Integration & E2E Testing
```
Title: Write Comprehensive Integration and E2E Tests

Description:
Add integration tests and E2E tests for critical user flows.

Tasks:
- [ ] Set up Playwright for E2E testing:
  - Install Playwright
  - Configure test environment
  - Set up test database
- [ ] Write E2E tests for critical flows:
  - User registration and login
  - Create put trade → mark assigned → create position
  - Sell covered call → mark assigned → close position
  - View P&L dashboard
  - Export P&L report
  - Compare to SPY benchmark
- [ ] Write integration tests:
  - Trade CRUD operations
  - Position creation from assignment
  - P&L calculations
  - Price updates
  - CSV export
- [ ] Add API tests:
  - Test all Server Actions
  - Test all API routes
  - Test authentication
  - Test authorization
- [ ] Achieve test coverage goals:
  - > 70% code coverage
  - 100% of critical paths
- [ ] Set up CI/CD testing:
  - Run tests on every PR
  - Block merge if tests fail
- [ ] Document testing approach

Dependencies: Phase 6 complete

Acceptance Criteria:
- All E2E flows tested
- Integration tests cover critical features
- API tests comprehensive
- Code coverage > 70%
- CI/CD runs tests automatically
- Documentation complete

Tags: [phase7, testing, e2e, integration, quality]
```

### Track 2: Documentation (Polecat 2)

#### Bead 23: User Documentation & Help
```
Title: Create User Guide and Help Documentation

Description:
Write comprehensive user documentation and in-app help.

Tasks:
- [ ] Create user guide documentation:
  - Getting started guide
  - How to enter trades
  - Understanding the wheel strategy
  - Reading the dashboard
  - Interpreting P&L
  - Using benchmarks
  - Exporting for taxes
- [ ] Add in-app help:
  - Tooltips on complex features
  - Help icons with explanations
  - FAQ page
  - Glossary of terms
- [ ] Create video tutorials (optional):
  - Quick start (2 min)
  - Full walkthrough (10 min)
- [ ] Write README.md:
  - Project overview
  - Setup instructions
  - Development guide
  - Deployment guide
  - Contributing guidelines
- [ ] Create CHANGELOG.md:
  - Document v1.0 features
  - Set up for future releases
- [ ] Add inline code comments:
  - JSDoc for complex functions
  - Explain business logic
  - Document edge cases

Dependencies: Phase 6 complete (all features exist to document)

Acceptance Criteria:
- User guide comprehensive
- In-app help useful
- README complete
- CHANGELOG started
- Code comments added
- Documentation clear and accurate

Tags: [phase7, documentation, help, guide]
```

### SEQUENTIAL: Final Steps (One Polecat)

#### Bead 24: Performance Optimization
```
Title: Optimize Application Performance

Description:
Profile and optimize application performance before launch.

Tasks:
- [ ] Run Lighthouse audits:
  - Performance score > 90
  - Accessibility score > 95
  - Best Practices score > 90
  - SEO score > 90
- [ ] Optimize database queries:
  - Add indexes where needed
  - Optimize N+1 queries
  - Use select to limit fields
  - Add query caching
- [ ] Optimize bundle size:
  - Analyze bundle (next bundle-analyzer)
  - Remove unused dependencies
  - Code split large pages
  - Lazy load heavy components
- [ ] Optimize images:
  - Use Next.js Image component
  - Compress images
  - Use appropriate formats (WebP)
- [ ] Add caching:
  - HTTP caching headers
  - ISR for static pages
  - Redis for expensive queries (optional)
- [ ] Test on slow networks:
  - Throttle to 3G
  - Verify loading states work
  - Ensure app remains usable
- [ ] Fix any performance issues found

Dependencies: Beads 22-23 complete

Acceptance Criteria:
- Lighthouse scores meet targets
- Page load time < 2 seconds
- Database queries optimized
- Bundle size reasonable
- Works well on slow networks
- No performance regressions

Tags: [phase7, performance, optimization, lighthouse]
```

#### Bead 25: Production Deployment
```
Title: Deploy to Production and Launch

Description:
Deploy application to production and verify everything works.

Tasks:
- [ ] Set up production environment:
  - Create Vercel project
  - Configure environment variables
  - Set up production database (Vercel Postgres)
  - Configure domain (optional)
- [ ] Deploy application:
  - Deploy to Vercel
  - Verify deployment successful
  - Check build logs for errors
- [ ] Configure production settings:
  - Enable Vercel Cron
  - Set up error monitoring (Sentry - optional)
  - Configure analytics (Vercel Analytics)
  - Set up uptime monitoring
- [ ] Smoke test production:
  - Register new user
  - Create test trades
  - Verify prices update
  - Check all pages load
  - Test on mobile
- [ ] Set up backups:
  - Database backup strategy
  - Automated daily backups
- [ ] Create launch checklist:
  - All tests passing
  - Documentation complete
  - No critical bugs
  - Performance acceptable
- [ ] Launch! 🚀
- [ ] Monitor for issues first 48 hours

Dependencies: Bead 24 complete

Acceptance Criteria:
- Application deployed to production
- All environment variables configured
- Smoke tests pass
- Monitoring set up
- Backups configured
- No critical issues in first 48 hours

Tags: [phase7, deployment, production, launch]
```

**Phase 7 Assignment Strategy:**
- Assign Beads 22-23 (Testing + Docs) to 2 polecats in parallel
- Assign Beads 24-25 sequentially to one polecat (final optimization and deploy)

---

## Summary & Assignment Instructions

**Total Beads:** 25
**Total Phases:** 7 (0-6 = development, 7 = testing/launch)
**Timeline:** ~16 weeks
**Constraint:** Maximum 2 polecats working simultaneously

### Convoy Structure

Create convoy: **"Wheel Tracker v1.0"**

Include all 25 beads in convoy.

### Dependency Chain

```
Phase 0 (sequential) → Phase 1 (parallel) → Phase 2 (parallel) →
Phase 3 (sequential) → Phase 4 (parallel) → Phase 5 (sequential) →
Phase 6 (parallel) → Phase 7 (parallel then sequential)
```

### Parallelization Summary

**Can Run in Parallel:**
- Phase 1: Backend + Frontend tracks (Beads 4, 5-6)
- Phase 2: Backend + Frontend tracks (Bead 7, Beads 8-9)
- Phase 4: Backend + Frontend tracks (Bead 13, Beads 14-15)
- Phase 6: Features + Polish tracks (Beads 18-19, Beads 20-21)
- Phase 7 (partial): Testing + Docs (Beads 22, 23)

**Must Run Sequential:**
- Phase 0: All beads (1, 2, 3) - foundational setup
- Phase 3: All beads (10, 11, 12) - API integration
- Phase 5: All beads (16, 17) - benchmark feature
- Phase 7 (final): Beads 24, 25 - optimization and deploy

### Assignment Commands

After creating all beads with dependencies, assign to polecats:

```bash
# Phase 0 (sequential - one polecat)
gt sling <bead-1> wheel-tracker
# Wait for completion
gt sling <bead-2> wheel-tracker
# Wait for completion
gt sling <bead-3> wheel-tracker

# Phase 1 (parallel - two polecats)
gt sling <bead-4> wheel-tracker   # Backend polecat
gt sling <bead-5> wheel-tracker   # Frontend polecat

# Continue pattern for remaining phases...
```

### Formulas Used

Throughout this implementation:
- **web-api formula concepts**: Server Actions, API routes (Beads 4, 7, 10, 13, 16)
- **web-component formula concepts**: React components (Beads 5, 6, 8, 9, 12, 14, 17, 18, 19)
- **web-feature formula concepts**: Full-stack features (could be applied to entire phases)

### Success Criteria

**For Mayor to Mark Complete:**
- [ ] All 25 beads created
- [ ] Dependencies set correctly between phases
- [ ] Convoy "Wheel Tracker v1.0" created with all beads
- [ ] Work assigned respecting 2-polecat constraint
- [ ] Application deployed to production
- [ ] All tests passing
- [ ] Documentation complete

---

## Reference Documents

- **PRD**: `wheel-tracker/docs/PRODUCT_PLAN.md`
- **Mayor Prompting Guide**: `docs/MAYOR_PROMPTING_GUIDE.md`
- **Web Development Context**: `templates/polecat-contexts/WEB_DEVELOPMENT.md`

---

**Ready to Execute!**

Copy this prompt and send to the Mayor to begin Wheel Tracker implementation.
