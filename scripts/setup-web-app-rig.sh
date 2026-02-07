#!/bin/bash
# Setup a rig for web app development with specialized polecat context
# Usage: ./scripts/setup-web-app-rig.sh <rig-name>

set -e

RIG_NAME=$1
TOWN_ROOT="/Users/briangriffey/Code/griffey-gastown"

if [ -z "$RIG_NAME" ]; then
  echo "Usage: $0 <rig-name>"
  echo ""
  echo "Example:"
  echo "  $0 meal-agent"
  exit 1
fi

RIG_PATH="$TOWN_ROOT/$RIG_NAME"

if [ ! -d "$RIG_PATH" ]; then
  echo "❌ Error: Rig '$RIG_NAME' not found at $RIG_PATH"
  echo ""
  echo "Available rigs:"
  cd "$TOWN_ROOT"
  gt rigs
  exit 1
fi

echo "═══════════════════════════════════════════════════════════"
echo "  🌐 Setting up web app context for rig: $RIG_NAME"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Create polecat context directories
echo "📁 Creating context directories..."
mkdir -p "$RIG_PATH/polecats/.context"
echo "   ✓ Created $RIG_PATH/polecats/.context"

# Copy web development context
echo ""
echo "📚 Copying web development context..."
if [ ! -f "$TOWN_ROOT/templates/polecat-contexts/WEB_DEVELOPMENT.md" ]; then
  echo "❌ Error: WEB_DEVELOPMENT.md not found in templates"
  exit 1
fi

cp "$TOWN_ROOT/templates/polecat-contexts/WEB_DEVELOPMENT.md" \
   "$RIG_PATH/polecats/.context/"
echo "   ✓ Copied WEB_DEVELOPMENT.md"

# Check if refinery exists and update its context
echo ""
echo "⚗️  Updating refinery context..."
if [ -d "$RIG_PATH/refinery/rig" ]; then
  REFINERY_CLAUDE="$RIG_PATH/refinery/rig/CLAUDE.md"

  # Check if web app context already added
  if grep -q "Web Development Context" "$REFINERY_CLAUDE" 2>/dev/null; then
    echo "   ⚠️  Web app context already present in refinery CLAUDE.md"
  else
    # Append web app reference to refinery context
    cat >> "$REFINERY_CLAUDE" << 'EOF'

---

## Web Development Context

This rig contains web application code. Polecats working on this rig have
specialized context for modern web development.

**Technology Stack:**
- React 18+ (Server Components, Client Components)
- Next.js 14+ (App Router, Server Actions, API Routes)
- TypeScript (strict mode)
- Prisma ORM (type-safe database access)
- pnpm (package management)
- Vitest + React Testing Library (testing)

**Context Reference:**
Polecats have access to comprehensive web development patterns in:
`polecats/.context/WEB_DEVELOPMENT.md`

This includes:
- React Server vs Client Component patterns
- Next.js App Router conventions
- TypeScript typing patterns
- Prisma database query patterns
- API endpoint design patterns
- Testing strategies
- Common troubleshooting

**Web-Specific Formulas:**
Use these to create web development work:
- `bd cook web-feature feature_name="..."` - Full-stack feature
- `bd cook web-component component_name="..."` - React component
- `bd cook web-api endpoint_name="..."` - API endpoint

EOF
    echo "   ✓ Updated $REFINERY_CLAUDE with web app context"
  fi
else
  echo "   ⚠️  No refinery directory found - skipping refinery update"
fi

# Create symlink to web app templates
echo ""
echo "🔗 Creating template symlinks..."
if [ -L "$RIG_PATH/.web-app-templates" ]; then
  echo "   ⚠️  Symlink already exists"
elif [ -d "$TOWN_ROOT/templates/web-app" ]; then
  ln -sf "$TOWN_ROOT/templates/web-app" "$RIG_PATH/.web-app-templates"
  echo "   ✓ Created symlink to web app templates"
else
  echo "   ⚠️  Web app templates not found - skipping symlink"
fi

# Create .gitignore entry for polecats/.context (it's copied, not versioned)
echo ""
echo "📝 Updating .gitignore..."
GITIGNORE="$RIG_PATH/.gitignore"
if [ -f "$GITIGNORE" ]; then
  if grep -q "polecats/.context" "$GITIGNORE" 2>/dev/null; then
    echo "   ⚠️  .gitignore already configured"
  else
    echo "polecats/.context/" >> "$GITIGNORE"
    echo "   ✓ Added polecats/.context/ to .gitignore"
  fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  ✅ Web app context installed for $RIG_NAME"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "  1. Review the refinery context:"
echo "     cat $RIG_PATH/refinery/rig/CLAUDE.md"
echo ""
echo "  2. Create web development work using formulas:"
echo "     cd $RIG_PATH/refinery/rig  # or crew/*/rig"
echo "     bd cook web-feature feature_name=\"user-profile\""
echo "     bd cook web-component component_name=\"ProfileCard\""
echo "     bd cook web-api endpoint_name=\"users\""
echo ""
echo "  3. Assign work to polecats:"
echo "     gt sling <bead-id> $RIG_NAME"
echo ""
echo "  4. Polecats will automatically receive web development context"
echo "     when they are spawned with work assignments."
echo ""
