#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Upstream (source) repository this fork was created from
UPSTREAM_URL="https://github.com/terminal-42s/42_examshell.git"
UPSTREAM_REMOTE="upstream"

clear

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                   🔄 UPDATING 42 EXAM SHELL               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Error: Git is not installed${NC}"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Show current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${BLUE}📍 Current branch: ${YELLOW}$CURRENT_BRANCH${NC}"
echo ""

# Fetch latest changes
echo -e "${BLUE}📥 Fetching latest changes from repository...${NC}"
if ! git fetch origin; then
    echo -e "${RED}❌ Failed to fetch${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Fetch successful${NC}"
echo ""

# Check if there are updates available
BEHIND=$(git rev-list --count HEAD..origin/$CURRENT_BRANCH 2>/dev/null)

if [ "$BEHIND" -eq 0 ]; then
    echo -e "${GREEN}✅ You are up to date!${NC}"
    echo ""
else
    echo -e "${YELLOW}📦 $BEHIND update(s) available${NC}"
    echo ""
    
    # Show what will be updated
    echo -e "${BLUE}📋 Changes to be pulled:${NC}"
    git log HEAD..origin/$CURRENT_BRANCH --oneline | sed 's/^/   /'
    echo ""
    
    # Pull latest changes
    echo -e "${BLUE}⬇️  Pulling latest changes...${NC}"
    if ! git pull origin $CURRENT_BRANCH; then
        echo -e "${RED}❌ Failed to pull${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Pull successful${NC}"
    echo ""
fi

# ─── Sync fork with its upstream source ───
echo -e "${BLUE}🔗 Checking upstream source...${NC}"

# Add the upstream remote if it isn't configured yet
if ! git remote get-url "$UPSTREAM_REMOTE" > /dev/null 2>&1; then
    echo -e "${YELLOW}➕ Adding upstream remote -> $UPSTREAM_URL${NC}"
    git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
fi

echo -e "${BLUE}📥 Fetching latest changes from source...${NC}"
if ! git fetch "$UPSTREAM_REMOTE"; then
    echo -e "${RED}❌ Failed to fetch from upstream${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Upstream fetch successful${NC}"
echo ""

if ! git rev-parse --verify "$UPSTREAM_REMOTE/$CURRENT_BRANCH" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Branch '$CURRENT_BRANCH' not found on the source — skipping sync${NC}"
    echo ""
else
    BEHIND_UPSTREAM=$(git rev-list --count "HEAD..$UPSTREAM_REMOTE/$CURRENT_BRANCH" 2>/dev/null)
    BEHIND_UPSTREAM=${BEHIND_UPSTREAM:-0}

    if [ "$BEHIND_UPSTREAM" -eq 0 ]; then
        echo -e "${GREEN}✅ Your fork is in sync with the source!${NC}"
        echo ""
    else
        echo -e "${YELLOW}📦 $BEHIND_UPSTREAM new change(s) from the source${NC}"
        echo ""
        echo -e "${BLUE}📋 Changes from the source:${NC}"
        git log "HEAD..$UPSTREAM_REMOTE/$CURRENT_BRANCH" --oneline | sed 's/^/   /'
        echo ""

        echo -e "${BLUE}🔀 Merging changes from the source...${NC}"
        if ! git merge "$UPSTREAM_REMOTE/$CURRENT_BRANCH" --no-edit; then
            echo -e "${RED}❌ Merge conflict with the source.${NC}"
            echo -e "${YELLOW}   Resolve the conflicts manually, or run 'git merge --abort' to cancel.${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ Fork synced with the source${NC}"
        echo ""

        # Offer to push the synced state back up to the fork on GitHub
        echo -e "${CYAN}Push the synced changes to your fork (origin)? [y/N]${NC}"
        read -r PUSH_ANSWER
        if [[ "$PUSH_ANSWER" =~ ^[Yy]$ ]]; then
            if git push origin "$CURRENT_BRANCH"; then
                echo -e "${GREEN}✅ Fork updated on GitHub${NC}"
            else
                echo -e "${RED}❌ Failed to push to fork${NC}"
            fi
            echo ""
        fi
    fi
fi

# Update file permissions for tester scripts
echo -e "${BLUE}🔐 Updating file permissions...${NC}"
find .resources -name "tester.sh" -exec chmod +x {} \; 2>/dev/null
echo -e "${GREEN}✅ Permissions updated${NC}"
echo ""

# Show final status
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}${BOLD}✨ Update Complete!${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${CYAN}Ready to continue? Press enter to return to menu.${NC}"
read -r

cd .resources/main
bash menu.sh
