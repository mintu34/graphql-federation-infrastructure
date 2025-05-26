#!/bin/bash
# Stage 1 Setup Verification Script - UPDATED FOR .gen

set -e

echo "🚀 Stage 1 Verification Script"
echo "=============================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check function
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
        exit 1
    fi
}

# 1. Check Node version
echo -e "\n📋 Checking prerequisites..."
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ $NODE_VERSION -ge 18 ]; then
    echo -e "${GREEN}✅ Node.js version: $(node --version)${NC}"
else
    echo -e "${RED}❌ Node.js version must be >= 18. Current: $(node --version)${NC}"
    exit 1
fi

# 2. Check pnpm
which pnpm > /dev/null 2>&1
check "pnpm is installed: $(pnpm --version)"

# 3. Check if dependencies are installed
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✅ Dependencies installed${NC}"
else
    echo -e "${RED}❌ Dependencies not installed. Run: pnpm install${NC}"
    exit 1
fi

# 4. Check generated providers - UPDATED TO CHECK .gen
echo -e "\n📋 Checking CDKTF providers..."
if [ -d ".gen" ]; then
    echo -e "${GREEN}✅ CDKTF providers generated in .gen directory${NC}"
    # Check for provider files
    if ls .gen/providers/*aws* 1> /dev/null 2>&1 && ls .gen/providers/*azure* 1> /dev/null 2>&1; then
        echo -e "${GREEN}✅ AWS and Azure providers found${NC}"
    else
        echo -e "${RED}❌ AWS or Azure providers not found in .gen/providers/${NC}"
        echo "Contents of .gen:"
        ls -la .gen/ 2>/dev/null || true
        exit 1
    fi
else
    echo -e "${RED}❌ .gen directory not found. Run: pnpm run get${NC}"
    exit 1
fi

# 5. Build the project
echo -e "\n📋 Building project..."
pnpm run build > /dev/null 2>&1
check "TypeScript compilation successful"

# 6. Run linting
echo -e "\n📋 Running linter..."
pnpm run lint > /dev/null 2>&1
check "ESLint passed"

# 7. Check formatting
echo -e "\n📋 Checking code formatting..."
pnpm run format:check > /dev/null 2>&1
check "Prettier formatting correct"

# 8. Run tests
echo -e "\n📋 Running tests..."
pnpm test --silent > /dev/null 2>&1
check "All tests passed"

# 9. Synthesize CDKTF
echo -e "\n📋 Synthesizing CDKTF..."
pnpm run synth > /dev/null 2>&1
check "CDKTF synthesis successful"

# 10. Verify synthesis output
echo -e "\n📋 Verifying synthesis output..."
if [ -f "cdktf.out/manifest.json" ]; then
    STACK_NAME=$(cat cdktf.out/manifest.json | jq -r '.stacks | keys[0]')
    if [ "$STACK_NAME" = "graphql-federaration-infrastructure" ]; then
        echo -e "${GREEN}✅ Stack name verified: $STACK_NAME${NC}"
    else
        echo -e "${RED}❌ Unexpected stack name: $STACK_NAME${NC}"
        exit 1
    fi
    
    # Check if terraform JSON exists
    if [ -f "cdktf.out/stacks/$STACK_NAME/cdk.tf.json" ]; then
        echo -e "${GREEN}✅ Terraform JSON generated${NC}"
    else
        echo -e "${RED}❌ Terraform JSON not found${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ manifest.json not found${NC}"
    exit 1
fi

# Summary
echo -e "\n✨ ${GREEN}Stage 1 Setup Verification Complete!${NC} ✨"
echo -e "\nYour CDKTF project foundation is ready. You can now proceed to Stage 2."
echo -e "\nNext steps:"
echo "1. Commit your changes: git add . && git commit -m 'Stage 1 complete'"
echo "2. Tag the stage: git tag stage-1-complete"
echo "3. Move to Stage 2: Configuratio
n Management System"