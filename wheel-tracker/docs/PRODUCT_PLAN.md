# Wheel Tracker - Product Requirements Document

> **A sophisticated options trading tracker for the Wheel Strategy**

**Version:** 1.0
**Last Updated:** February 6, 2026
**Status:** Planning

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Problem Statement](#problem-statement)
3. [The Wheel Strategy](#the-wheel-strategy)
4. [Target Users](#target-users)
5. [Product Vision](#product-vision)
6. [Core Features](#core-features)
7. [User Stories](#user-stories)
8. [Data Model](#data-model)
9. [Technical Architecture](#technical-architecture)
10. [Market Data Integration](#market-data-integration)
11. [Success Metrics](#success-metrics)
12. [Development Phases](#development-phases)
13. [Future Enhancements](#future-enhancements)

---

## Executive Summary

**Wheel Tracker** is a web application designed to help options traders track the performance of the **Wheel Strategy** - a systematic options selling strategy that generates income through selling cash-secured puts and covered calls.

The application solves the problem of tracking complex, multi-leg options positions over time, calculating true profit/loss including premium collected and assignment outcomes, and comparing performance against benchmark indices like SPY.

**Key Value Propositions:**
- Accurate P&L tracking for wheel strategy positions
- Automated stock price updates for real-time position valuations
- Benchmark comparison against SPY ETF
- Trade journal with entry/exit tracking
- Performance analytics and reporting

---

## Problem Statement

Options traders using the Wheel Strategy face several challenges:

1. **Manual Tracking Complexity**: Tracking puts that expire, get assigned, convert to stock positions, then have calls sold against them requires complex spreadsheet management
2. **Inaccurate P&L Calculation**: Many traders fail to account for:
   - Premium collected from expired puts
   - Premium collected from calls
   - Unrealized gains/losses on current positions
   - Assignment costs and basis adjustments
3. **Lack of Benchmark Comparison**: No easy way to compare wheel strategy returns vs "just buying SPY"
4. **Time-Consuming Updates**: Manually updating stock prices daily to see current position values
5. **No Historical Analysis**: Difficulty analyzing which trades worked, which didn't, and why

**Current Alternatives:**
- **Spreadsheets**: Manual, error-prone, no automation
- **Broker Platforms**: Show current positions but don't track strategy-specific metrics or historical performance
- **Generic Portfolio Trackers**: Don't understand options strategies or the wheel's unique flow

---

## The Wheel Strategy

The Wheel Strategy is a systematic options income strategy with three phases:

### Phase 1: Sell Cash-Secured Puts
- Sell put options on stocks you'd be willing to own
- Collect premium upfront
- **Outcome A**: Put expires worthless → Keep premium, repeat
- **Outcome B**: Put assigned → You now own 100 shares per contract

### Phase 2: Stock Assignment
- If put is assigned, you own stock at the strike price
- Your cost basis = strike price - premium collected
- Now holding shares, move to Phase 3

### Phase 3: Sell Covered Calls
- Sell call options against owned shares
- Collect premium
- **Outcome A**: Call expires worthless → Keep premium, repeat
- **Outcome B**: Call assigned → Sell shares at strike, realize gain/loss

### The "Wheel" Complete
Once shares are called away, you "complete the wheel" and can start over with Phase 1 on the same or different stock.

### Example Trade Sequence

```
Day 1: Sell AAPL $150 put, collect $200 premium
Day 30: Put expires worthless
        Result: +$200 profit, no stock

Day 31: Sell AAPL $145 put, collect $250 premium
Day 60: Put assigned, buy 100 shares @ $145
        Cost basis: $145 - $2.50 premium = $142.50/share

Day 61: Sell AAPL $150 call against shares, collect $180 premium
Day 90: Call expires worthless
        Result: +$180 profit, still own shares at $142.50 basis

Day 91: Sell AAPL $155 call, collect $200 premium
Day 120: Call assigned, sell 100 shares @ $155
         Result: ($155 - $142.50) * 100 + $200 = $1,450 profit

Total profit: $200 + $250 + $180 + $1,450 = $2,080
```

**Wheel Tracker must track all phases and calculate true returns.**

---

## Target Users

### Primary User Persona: "The Income Trader"

**Demographics:**
- Age: 30-60
- Experience: Intermediate to advanced options trader
- Portfolio: $25,000 - $500,000+ in trading capital
- Strategy: Wheel strategy as primary or supplementary income source

**Goals:**
- Generate consistent income from options premium
- Track performance vs benchmark (SPY)
- Understand which tickers/strikes work best
- Maintain detailed trade records for taxes
- Optimize strategy based on historical data

**Pain Points:**
- Spending hours updating spreadsheets
- Uncertainty about true returns
- Can't easily answer "Am I beating SPY?"
- Difficulty tracking positions across multiple brokers
- No clear view of which trades are profitable

**Technical Proficiency:**
- Comfortable with web applications
- Uses broker platforms daily
- Familiar with financial concepts (P&L, cost basis, etc.)

---

## Product Vision

**Vision Statement:**
"Empower options traders to confidently execute and optimize the Wheel Strategy through automated tracking, real-time analytics, and benchmark-beating insights."

**What Success Looks Like:**
- Traders spend 90% less time on manual tracking
- Accurate P&L calculation including all premium and assignments
- Clear visibility into strategy performance vs SPY
- Data-driven insights that improve trade selection
- Complete trade history for tax reporting

**Not In Scope (v1.0):**
- Automated trade execution
- Broker integration (import trades)
- Multi-strategy tracking (focusing on Wheel only)
- Social/community features
- Mobile app (web-responsive only)

---

## Core Features

### Feature 1: Trade Entry & Management

**Description:**
Users can manually enter trades with full details about the options contract.

**Capabilities:**
- Enter sold put trades (ticker, strike, expiration, premium, quantity)
- Enter sold call trades (same fields)
- Mark puts as "expired worthless" or "assigned"
- Mark calls as "expired worthless" or "assigned"
- Edit trade details (before assignment/expiration)
- Delete trades (with confirmation)

**Trade Fields:**
```typescript
Trade {
  ticker: string              // Stock symbol (e.g., "AAPL")
  tradeType: "PUT" | "CALL"  // Option type
  action: "SELL"             // (Always SELL for wheel strategy)
  strikePrice: number        // Strike price
  premium: number            // Premium collected per share
  quantity: number           // Number of contracts (100 shares each)
  entryDate: Date            // Date trade was opened
  expirationDate: Date       // Option expiration date
  status: "OPEN" | "EXPIRED" | "ASSIGNED"
  closeDate?: Date           // When position closed
}
```

---

### Feature 2: Position Tracking

**Description:**
Track stock positions that result from put assignments and their associated covered calls.

**Capabilities:**
- Automatically create stock position when put is assigned
- Calculate cost basis (strike price - premium collected)
- Track covered calls sold against position
- Show current stock price (auto-updated)
- Calculate unrealized P&L on stock position
- Mark position as "closed" when called away

**Position Fields:**
```typescript
Position {
  ticker: string
  shares: number             // Usually 100 per contract
  costBasis: number          // Per share, adjusted for premium
  acquiredDate: Date         // When assigned
  assignmentTrade: Trade     // Reference to put that was assigned
  coveredCalls: Trade[]      // Calls sold against this position
  status: "ACTIVE" | "CLOSED"
  closedDate?: Date          // When called away
  closedPrice?: number       // Price shares sold at
}
```

---

### Feature 3: Automated Stock Price Updates

**Description:**
Integrate with market data API to automatically fetch current stock prices for accurate position valuations.

**Capabilities:**
- Fetch real-time or delayed stock prices
- Update position values automatically
- Calculate unrealized P&L based on current prices
- Show last update timestamp
- Manual refresh option
- Batch update all positions

**Technical Requirements:**
- Market data API integration (Alpha Vantage recommended)
- Background job to fetch prices (every 15 minutes during market hours)
- Cached prices to minimize API calls
- Error handling for failed API calls or delisted stocks

---

### Feature 4: P&L Calculation & Reporting

**Description:**
Calculate comprehensive profit/loss across all trades and positions, with detailed breakdowns.

**Capabilities:**
- **Realized P&L**: From closed trades
  - Expired puts/calls (100% premium profit)
  - Assigned calls (capital gains + premium)
- **Unrealized P&L**: From open positions
  - Current stock value vs cost basis
  - Premium from open calls (time value decay)
- **Total P&L**: Realized + Unrealized
- **Time-based reporting**: Daily, weekly, monthly, YTD, all-time
- **Ticker-based reporting**: P&L breakdown by stock

---

### Feature 5: Benchmark Comparison (SPY)

**Description:**
Compare wheel strategy performance against buying and holding SPY ETF.

**Capabilities:**
- Track SPY price from initial deposit date
- Calculate hypothetical SPY returns with same capital
- Show comparative P&L (Wheel vs SPY)
- Visualize performance difference over time
- Calculate outperformance/underperformance percentage

**Calculation Example:**
```typescript
// User deposits $10,000 on Jan 1, 2024
// SPY price on Jan 1: $450

hypotheticalSPYShares = 10000 / 450 = 22.22 shares

// Today SPY is $480
hypotheticalSPYValue = 22.22 * 480 = $10,666
SPYReturn = $666 (6.66%)

// User's wheel strategy P&L: $1,200
WheelReturn = $1,200 (12%)

Outperformance = $1,200 - $666 = $534 (5.34%)
```

---

### Feature 6: Trade Journal & History

**Description:**
Complete historical record of all trades with notes, outcomes, and learnings.

**Capabilities:**
- View all trades (chronological or by ticker)
- Filter by status (open, expired, assigned)
- Filter by type (puts, calls)
- Filter by date range
- Search by ticker
- Add notes to trades (strategy rationale, lessons learned)
- Tag trades (e.g., "high IV", "earnings play", "mistake")

---

### Feature 7: Dashboard & Analytics

**Description:**
High-level overview and analytics to understand strategy performance.

**Dashboard Components:**

1. **Headline Metrics (Cards)**
   - Total P&L ($ and %)
   - Realized P&L
   - Unrealized P&L
   - vs SPY ($ and %)
   - Active Positions count
   - Open Contracts count

2. **Charts**
   - P&L over time (line chart)
   - Wheel vs SPY comparison (dual line chart)
   - P&L by ticker (bar chart)
   - Win rate (pie chart: expired worthless vs assigned)

3. **Recent Activity**
   - Last 10 trades
   - Upcoming expirations (next 30 days)
   - Positions requiring action (calls to sell, etc.)

4. **Performance Statistics**
   - Total premium collected
   - Average premium per trade
   - Win rate (% expired worthless)
   - Assignment rate (% assigned)
   - Average days to expiration
   - Average return per trade

---

## User Stories

### Epic 1: Trade Management

**US-1.1: Enter a Sold Put Trade**
```
As a trader,
I want to enter details of a put I sold,
So that I can track its performance and outcome.

Acceptance Criteria:
- Can enter ticker, strike, expiration, premium, quantity
- Form validates all required fields
- Ticker is auto-suggested from valid symbols
- Trade is saved and appears in trade list
- Trade status defaults to "OPEN"
```

**US-1.2: Mark Put as Expired Worthless**
```
As a trader,
I want to mark an expired put as worthless,
So that I can record the profit and close the trade.

Acceptance Criteria:
- Can select "Expire Worthless" from trade actions
- Trade status changes to "EXPIRED"
- Premium is recorded as realized profit
- Trade no longer appears in "Open Trades"
```

**US-1.3: Mark Put as Assigned**
```
As a trader,
I want to mark a put as assigned,
So that a stock position is created and I can start selling calls.

Acceptance Criteria:
- Can select "Assigned" from trade actions
- Trade status changes to "ASSIGNED"
- Stock position is automatically created
  - Shares = quantity * 100
  - Cost basis = strike - premium
  - Assignment date = today
- Trade moves to "Closed Trades"
- New position appears in "Active Positions"
```

---

### Epic 2: Position Tracking

**US-2.1: View Active Positions**
```
As a trader,
I want to see all my active stock positions,
So that I know what I currently own and its value.

Acceptance Criteria:
- Dashboard shows all active positions
- Each position displays:
  - Ticker
  - Shares owned
  - Cost basis (per share and total)
  - Current price (live updated)
  - Current value
  - Unrealized P&L ($ and %)
- Positions sorted by unrealized P&L (best to worst)
```

---

## Data Model

### Database Schema (Prisma)

```prisma
model User {
  id            String      @id @default(cuid())
  email         String      @unique
  name          String?
  createdAt     DateTime    @default(now())
  updatedAt     DateTime    @updatedAt

  trades        Trade[]
  positions     Position[]
  benchmarks    Benchmark[]

  @@map("users")
}

model Trade {
  id              String      @id @default(cuid())
  userId          String
  user            User        @relation(fields: [userId], references: [id], onDelete: Cascade)

  ticker          String      // Stock symbol
  tradeType       TradeType   // PUT or CALL
  action          TradeAction // SELL (always for wheel)
  strikePrice     Decimal     @db.Decimal(10, 2)
  premium         Decimal     @db.Decimal(10, 2)  // Per share
  quantity        Int         // Number of contracts

  entryDate       DateTime
  expirationDate  DateTime
  status          TradeStatus // OPEN, EXPIRED, ASSIGNED
  closeDate       DateTime?

  // Notes and metadata
  notes           String?     @db.Text
  tags            String[]    // Array of tags
  outcome         String?     // User assessment

  // Relationships
  positionId      String?     // If this is a call sold against a position
  position        Position?   @relation(fields: [positionId], references: [id])

  assignedPosition Position?  @relation("AssignmentTrade")

  createdAt       DateTime    @default(now())
  updatedAt       DateTime    @updatedAt

  @@index([userId, ticker])
  @@index([userId, status])
  @@index([expirationDate])
  @@map("trades")
}

enum TradeType {
  PUT
  CALL
}

enum TradeAction {
  SELL
}

enum TradeStatus {
  OPEN
  EXPIRED
  ASSIGNED
}

model Position {
  id              String        @id @default(cuid())
  userId          String
  user            User          @relation(fields: [userId], references: [id], onDelete: Cascade)

  ticker          String
  shares          Int
  costBasis       Decimal       @db.Decimal(10, 2)

  acquiredDate    DateTime
  status          PositionStatus
  closedDate      DateTime?
  closedPrice     Decimal?      @db.Decimal(10, 2)

  assignmentTradeId String      @unique
  assignmentTrade   Trade       @relation("AssignmentTrade", fields: [assignmentTradeId], references: [id])

  coveredCalls    Trade[]

  createdAt       DateTime      @default(now())
  updatedAt       DateTime      @updatedAt

  @@index([userId, ticker])
  @@index([userId, status])
  @@map("positions")
}

enum PositionStatus {
  ACTIVE
  CLOSED
}

model StockPrice {
  id            String    @id @default(cuid())
  ticker        String    @unique
  price         Decimal   @db.Decimal(10, 2)
  lastUpdated   DateTime
  source        String

  previousClose Decimal?  @db.Decimal(10, 2)
  changePercent Decimal?  @db.Decimal(5, 2)

  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  @@index([ticker])
  @@map("stock_prices")
}

model Benchmark {
  id              String    @id @default(cuid())
  userId          String
  user            User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  symbol          String
  initialDate     DateTime
  initialPrice    Decimal   @db.Decimal(10, 2)
  initialCapital  Decimal   @db.Decimal(10, 2)
  shares          Decimal   @db.Decimal(10, 4)

  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  @@unique([userId, symbol])
  @@map("benchmarks")
}
```

---

## Technical Architecture

### Stack

**Frontend:**
- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript (strict mode)
- **Styling**: Tailwind CSS
- **Charts**: Recharts
- **Forms**: React Hook Form + Zod validation
- **Date Handling**: date-fns

**Backend:**
- **API**: Next.js API Routes / Server Actions
- **Database**: PostgreSQL 16
- **ORM**: Prisma
- **Validation**: Zod schemas

**Infrastructure:**
- **Hosting**: Vercel (recommended)
- **Database**: Vercel Postgres or Railway
- **Cron Jobs**: Vercel Cron
- **Environment**: Docker Compose for local development

---

## Market Data Integration

### Recommended Provider: Alpha Vantage

**Why Alpha Vantage:**
- Free tier: 25 requests/day
- Generous rate limits: 5 requests/minute
- Real-time and historical data
- Simple REST API
- No credit card required for free tier

**Pricing:**
- Free: 25 requests/day (sufficient for ~20 tickers)
- Premium: $49.99/month (75 requests/minute, unlimited)

**API Example:**
```bash
GET https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=AAPL&apikey=YOUR_KEY
```

### Alternative Providers

| Provider | Free Tier | Pricing | Notes |
|----------|-----------|---------|-------|
| **Alpha Vantage** | 25 req/day | $49.99/mo | Best for low volume |
| **Finnhub** | 60 req/min | $99/mo | Good real-time data |
| **IEX Cloud** | 50k msgs/mo | $9/mo+ | Pay per message |
| **Polygon.io** | None | $99/mo | Professional grade |

**Recommendation:** Start with Alpha Vantage free tier, upgrade if needed.

---

## Success Metrics

### User Metrics

**Engagement:**
- Daily Active Users (DAU)
- Weekly Active Users (WAU)
- Number of trades entered per user
- Number of positions tracked per user

**Retention:**
- Week 1 retention rate
- Month 1 retention rate

**Feature Adoption:**
- % of users who compare to SPY
- % of users who add notes/tags
- % of users who export reports

### Product Metrics

**Accuracy:**
- P&L calculation accuracy (manual audit sample)
- Stock price update success rate

**Performance:**
- Page load time (< 2 seconds)
- Database query performance (< 100ms)

---

## Development Phases

### Phase 0: Foundation (Week 1-2)
- Initialize Next.js project with TypeScript
- Set up Prisma with PostgreSQL
- Create database schema and migrations
- Set up Docker Compose for local development
- Configure authentication

### Phase 1: Trade Entry (Week 3-4)
- Trade entry form (puts and calls)
- Trade list view
- Edit/delete trades
- Filter trades

### Phase 2: Position Management (Week 5-6)
- Mark put as assigned → creates position
- View active positions
- Position detail view
- Mark call as assigned → closes position

### Phase 3: Market Data Integration (Week 7-8)
- Alpha Vantage API integration
- Background job to fetch prices
- Price display on positions
- Manual refresh option

### Phase 4: P&L Calculations (Week 9-10)
- Realized/unrealized P&L calculation
- P&L dashboard
- P&L by ticker breakdown
- P&L over time chart

### Phase 5: Benchmark Comparison (Week 11-12)
- Benchmark setup (SPY)
- SPY price tracking
- Comparison calculation
- Comparison chart

### Phase 6: Analytics & Polish (Week 13-14)
- Complete dashboard with metrics
- Performance statistics
- Trade journal with notes/tags
- Responsive design polish

### Phase 7: Testing & Launch (Week 15-16)
- Integration tests
- Component tests
- Performance optimization
- Production deployment

---

## Future Enhancements (Post-v1.0)

### Phase 8: Broker Integration
- Import trades from broker CSV
- OAuth integration with broker APIs

### Phase 9: Advanced Analytics
- Trade performance heat map
- IV rank tracking
- Probability of profit calculator
- Risk metrics (max drawdown, Sharpe ratio)

### Phase 10: Multi-Strategy Support
- Iron Condor, Credit Spreads tracking
- Strategy comparison

### Phase 11: Mobile App
- Native iOS/Android apps
- Push notifications for expirations

### Phase 12: Tax Optimization
- Wash sale detection
- Tax lot tracking
- IRS Form 8949 generation

---

## Open Questions

1. **Multi-Account Support:** Should users track multiple brokerage accounts?
2. **Capital Tracking:** How to handle deposits/withdrawals?
3. **Dividends:** Should we track dividend income from held positions?
4. **Time Zones:** All times in ET (market time) or user's timezone?
5. **Currency:** USD only for v1.0?

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 6, 2026 | Brian Griffey | Initial draft |

---

**End of PRD**
