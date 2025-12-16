#!/bin/bash

# GIDYO Edge Functions Deployment Script

set -e

echo "🚀 Starting deployment of GIDYO Edge Functions..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}❌ Supabase CLI is not installed${NC}"
    echo "Install it with: npm install -g supabase"
    exit 1
fi

echo -e "${GREEN}✓ Supabase CLI found${NC}"

# List of functions to deploy
FUNCTIONS=(
    "create-booking"
    "accept-booking"
    "complete-booking"
    "process-payout"
    "send-notification"
    "verify-guide"
)

# Deploy each function
for func in "${FUNCTIONS[@]}"; do
    echo -e "${BLUE}📦 Deploying ${func}...${NC}"

    if supabase functions deploy "$func" --no-verify-jwt; then
        echo -e "${GREEN}✓ ${func} deployed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to deploy ${func}${NC}"
        exit 1
    fi
done

echo ""
echo -e "${GREEN}✅ All functions deployed successfully!${NC}"
echo ""
echo "📋 Next steps:"
echo "1. Set environment secrets with: supabase secrets set KEY=value"
echo "2. Test functions with: curl or Postman"
echo "3. Monitor logs with: supabase functions logs <function-name>"
echo ""
echo "Required secrets to set:"
echo "  - STRIPE_SECRET_KEY"
echo "  - FCM_SERVER_KEY"
echo "  - SUPABASE_SERVICE_ROLE_KEY"
echo "  - MONCASH_CLIENT_ID (optional)"
echo "  - MONCASH_SECRET_KEY (optional)"
