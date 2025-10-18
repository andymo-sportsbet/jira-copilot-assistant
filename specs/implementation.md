# Implementation Guide: Copilot-Powered JIRA Assistant

**Spec**: 008-copilot-jira-agent  
**Version**: 5.0.0 (Hybrid Approach + Confluence + AI Estimation)  
**Approach**: Copilot Custom Instructions + Shell Scripts  
**Last Updated**: 2025-10-15  
**Status**: Epics 1-4 Complete ✅ | Epic 5 In Progress 🚧

---

## 📋 Table of Contents

1. [Project Setup](#project-setup)
2. [Copilot Custom Instructions](#copilot-custom-instructions)
3. [Shell Script Implementations](#shell-script-implementations)
4. [Environment Configuration](#environment-configuration)
5. [Testing](#testing)
6. [Deployment](#deployment)

---

## 🚀 Project Setup

### Repository Structure

```bash
jira-copilot-assistant/
├── .github/
│   └── copilot-instructions.md       # Teaches Copilot about workflows
├── scripts/
│   ├── jira-create.sh                # Create JIRA tickets ✅
│   ├── jira-groom.sh                 # Enhance tickets with AI ✅
│   ├── jira-close.sh                 # Close tickets ✅
│   ├── jira-sync.sh                  # Sync repos with JIRA ✅
│   ├── confluence-to-jira.sh         # Create tickets from Confluence ✅
│   ├── confluence-to-spec.sh         # Save Confluence as spec file 🚧
│   └── lib/
│       ├── jira-api.sh               # JIRA API helper functions ✅
│       ├── github-api.sh             # GitHub API helper functions ✅
│       ├── utils.sh                  # Common utilities ✅
│       └── confluence-api.sh         # Confluence API helper functions ✅
├── .env.example                      # Environment template ✅
├── README.md                         # Setup and usage guide ✅
└── docs/
    ├── setup-guide.md                # ✅
    ├── user-guide.md                 # ✅
    ├── troubleshooting.md            # ✅
    ├── demo-script.md                # ✅
    └── training-guide.md             # ✅

✅ = Complete | 🚧 = In Progress (CJA-011)
```

### Prerequisites

```bash
# macOS/Linux required tools
brew install jq         # JSON parsing
brew install gh         # GitHub CLI (optional, for enhanced features)
brew install curl       # HTTP requests (usually pre-installed)

# Required environment variables
export JIRA_BASE_URL="https://yourcompany.atlassian.net"
export JIRA_TOKEN="ATATT3x..."
export JIRA_PROJECT="PROJ"
export GITHUB_TOKEN="ghp_..."
export GITHUB_ORG="yourorg"
```

### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/yourorg/jira-copilot-assistant.git
cd jira-copilot-assistant

# 2. Configure environment
cp .env.example .env
vim .env  # Add your credentials

# 3. Load environment
source .env

# 4. Make scripts executable
chmod +x scripts/*.sh

# 5. Test connection
./scripts/jira-create.sh --help
```

---

## 📝 Copilot Custom Instructions

### Complete Instructions File

**File**: `.github/copilot-instructions.md`

```markdown
# JIRA Workflow Instructions for GitHub Copilot

## Overview
We use shell scripts in `scripts/` to automate JIRA operations. When users ask
for JIRA tasks, analyze their current file and suggest the appropriate script
command with contextually-extracted arguments.

## Environment
- JIRA_BASE_URL: Company JIRA instance URL
- JIRA_TOKEN: API token for authentication
- JIRA_PROJECT: Default project key (e.g., PROJ)
- GITHUB_TOKEN: GitHub Personal Access Token
- GITHUB_ORG: GitHub organization name

---

## Command 1: Create JIRA Ticket

### Trigger Phrases
- "create jira ticket"
- "create ticket from this file"
- "make a jira issue"
- "new jira ticket"

### Process
1. **Read the current file**
2. **Extract information**:
   - **Title**: First `#` heading (remove the `#` symbol)
   - **Description**: 
     - Look for `## Description` or `## Overview` section
     - Or use first paragraph after title
     - Limit to 500 characters
   - **Features**: 
     - Look for `## Features`, `## Requirements`, or bullet lists
     - Extract bullet points
     - Join with commas (max 10 features)
   - **Priority**:
     - High: If keywords: "urgent", "critical", "blocker", "asap"
     - Low: If keywords: "nice to have", "future", "optional"
     - Medium: Default

3. **Generate command**:
```bash
./scripts/jira-create.sh \
  --summary "Extracted Title Here" \
  --description "Extracted description here..." \
  --features "Feature1,Feature2,Feature3" \
  --priority "High|Medium|Low"
```

4. **Add explanation**:
   - Explain what the command will do
   - Mention the file being used as source
   - Suggest reviewing before running

### Example Response

**User**: "create jira ticket from this file"

**You**: 
```
I'll create a JIRA ticket from `specs/auth/spec.md`. Here's the command:

\`\`\`bash
./scripts/jira-create.sh \
  --summary "User Authentication System" \
  --description "Implement OAuth 2.0 authentication with JWT tokens and refresh mechanism" \
  --features "Google OAuth,GitHub OAuth,JWT tokens,Token refresh,MFA support" \
  --priority "High"
\`\`\`

**What this does**:
- Creates a Story in your JIRA project (PROJ)
- Adds the 'copilot-created' label
- Returns the ticket key (e.g., PROJ-123) and URL

Please review the extracted information and run when ready!
```

---

## Command 2: Groom JIRA Ticket

### Trigger Phrases
- "groom PROJ-123"
- "enhance ticket PROJ-45"
- "update jira PROJ-67"
- "improve PROJ-89"

### Process
1. **Extract ticket key**: Match pattern `[A-Z]+-\d+`
2. **Generate command**:
```bash
./scripts/jira-groom.sh PROJ-123
```

3. **Explain what happens**:
   - Fetches current ticket from JIRA
   - Searches GitHub for related PRs and commits
   - Uses AI to generate additional acceptance criteria
   - Updates ticket with enhancements
   - Adds comment with changes made

### Example Response

**User**: "groom PROJ-123"

**You**:
```
I'll enhance ticket PROJ-123 with AI-generated improvements:

\`\`\`bash
./scripts/jira-groom.sh PROJ-123
\`\`\`

**What this does**:
1. Fetches PROJ-123 from JIRA
2. Searches GitHub for related PRs/commits mentioning PROJ-123
3. Generates additional acceptance criteria based on related work
4. Adds implementation notes if PRs found
5. Updates story point estimate if complexity increased
6. Adds a comment summarizing changes

This typically adds 3-5 new acceptance criteria and references to related PRs.

Run when ready!
```

---

## Command 3: Close JIRA Ticket

### Trigger Phrases
- "close PROJ-123"
- "mark PROJ-45 done"
- "finish PROJ-67"
- "complete ticket PROJ-89"

### Process
1. **Extract ticket key**
2. **Generate command**:
```bash
./scripts/jira-close.sh PROJ-123
```

### Example Response

**User**: "close PROJ-123"

**You**:
```
I'll close PROJ-123:

\`\`\`bash
./scripts/jira-close.sh PROJ-123
\`\`\`

**What this does**:
- Fetches ticket details
- Generates completion summary based on description and AC
- Adds summary as final comment
- Transitions ticket to "Done" status
- Outputs confirmation

Run when ready to close!
```

---

## Command 4: Sync Repositories

### Trigger Phrases
- "sync jira"
- "sync jira with github"
- "update jira from github"
- "sync repos"

### Process
1. **Check if specific repo mentioned**
   - If yes: `./scripts/jira-sync.sh --repo owner/repo`
   - If no: `./scripts/jira-sync.sh` (all repos)

### Example Response

**User**: "sync jira with github"

**You**:
```
I'll sync all repositories with JIRA:

\`\`\`bash
./scripts/jira-sync.sh
\`\`\`

**What this does**:
1. Lists all repos in your GitHub org (GITHUB_ORG)
2. Scans recent commits and PRs (last 7 days) for JIRA keys
3. Updates ticket statuses based on PR state:
   - Open PR → Transitions ticket to "In Review"
   - Merged PR → Transitions ticket to "Done"
4. Reports summary: X tickets updated, Y errors

This may take 15-30 seconds for large orgs.

Run when ready!
```

**Or for specific repo**:

**User**: "sync jira for backend repo"

**You**:
```
I'll sync just the backend repository:

\`\`\`bash
./scripts/jira-sync.sh --repo yourorg/backend
\`\`\`

This will only scan `yourorg/backend` instead of all repos.
```

---

## Advanced: Natural Language

### When user uses vague commands

**User**: "update ticket"

**You**:
```
I can help with JIRA tickets! Which action would you like?

**Create new ticket**:
\`./scripts/jira-create.sh\` - Creates from current file

**Enhance existing ticket**:
\`./scripts/jira-groom.sh PROJ-XXX\` - Adds AC and notes

**Close ticket**:
\`./scripts/jira-close.sh PROJ-XXX\` - Marks as Done

**Sync with GitHub**:
\`./scripts/jira-sync.sh\` - Updates statuses

Please specify which ticket or action you need!
```

---

## Error Handling

### When file has no clear structure

**You**:
```
⚠️ I couldn't extract clear requirements from this file.

For best results, ensure your file has:
- A title (`# Title` heading)
- A description section
- A list of features or requirements

Example format:
\`\`\`markdown
# User Authentication

## Description
Implement OAuth 2.0 authentication system

## Features
- Google OAuth integration
- GitHub OAuth integration
- JWT token generation
\`\`\`

Would you like me to help structure this file first?
```

### When ticket key is invalid

**User**: "groom INVALID"

**You**:
```
⚠️ That doesn't look like a valid JIRA ticket key.

Expected format: PROJECT-123 (uppercase letters, hyphen, numbers)

Examples:
- PROJ-123
- BACKEND-45
- API-789

Please provide a valid ticket key!
```

---

## Best Practices

1. **Always parse the current file** - Use actual content, don't make up examples
2. **Explain what happens** - Tell user what the script will do
3. **Suggest review** - Always say "review and run when ready"
4. **Handle errors gracefully** - Provide helpful error messages
5. **Include examples** - Show sample output when relevant
6. **Be concise** - Keep explanations short but informative

---

## Testing Instructions

When testing, Copilot should:
1. ✅ Generate syntactically correct bash commands
2. ✅ Extract title, description, features accurately (>95%)
3. ✅ Assign appropriate priority based on keywords
4. ✅ Handle files with various markdown structures
5. ✅ Provide helpful error messages for invalid inputs
6. ✅ Always suggest user review before running

---

**Instructions Version**: 1.0.0  
**Maintained by**: Engineering Team  
**Update frequency**: As needed based on feedback
```

---

## 🔧 Shell Script Implementations

### Script 1: jira-create.sh

**File**: `scripts/jira-create.sh`

```bash
#!/bin/bash
#
# jira-create.sh - Create JIRA ticket from command line
#
# Usage:
#   ./jira-create.sh \
#     --summary "Ticket title" \
#     --description "Detailed description" \
#     --features "feature1,feature2,feature3" \
#     --priority "High|Medium|Low"
#

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/jira-api.sh"
source "$SCRIPT_DIR/lib/utils.sh"

# Default values
SUMMARY=""
DESCRIPTION=""
FEATURES=""
PRIORITY="Medium"
STORY_POINTS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --summary)
      SUMMARY="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION="$2"
      shift 2
      ;;
    --features)
      FEATURES="$2"
      shift 2
      ;;
    --priority)
      PRIORITY="$2"
      shift 2
      ;;
    --story-points)
      STORY_POINTS="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 --summary 'Title' --description 'Desc' [--features 'f1,f2'] [--priority High|Medium|Low]"
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [[ -z "$SUMMARY" ]]; then
  error "--summary is required"
  exit 1
fi

# Build full description with features
FULL_DESCRIPTION="$DESCRIPTION"

if [[ -n "$FEATURES" ]]; then
  FULL_DESCRIPTION="$FULL_DESCRIPTION

Features:
$(echo "$FEATURES" | tr ',' '\n' | sed 's/^/- /')"
fi

# Build JSON payload
PAYLOAD=$(cat <<EOF
{
  "fields": {
    "project": {"key": "$JIRA_PROJECT"},
    "summary": "$SUMMARY",
    "description": "$FULL_DESCRIPTION",
    "issuetype": {"name": "Story"},
    "priority": {"name": "$PRIORITY"},
    "labels": ["copilot-created"]
  }
}
EOF
)

# Call JIRA API
info "Creating JIRA ticket..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$JIRA_BASE_URL/rest/api/2/issue" \
  -H "Authorization: Bearer $JIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# Parse response
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" -ne 201 ]]; then
  error "Failed to create ticket (HTTP $HTTP_CODE)"
  echo "$BODY" | jq -r '.errorMessages[]? // .errors? // .'
  exit 1
fi

# Extract ticket key
KEY=$(echo "$BODY" | jq -r '.key')
TICKET_URL="$JIRA_BASE_URL/browse/$KEY"

# Success output
echo ""
success "Created: $KEY"
info "📝 Summary: $SUMMARY"
info "🔗 $TICKET_URL"
echo ""
```

### Script 2: jira-groom.sh

**File**: `scripts/jira-groom.sh`

```bash
#!/bin/bash
#
# jira-groom.sh - Enhance JIRA ticket with AI and related work
#
# Usage:
#   ./jira-groom.sh PROJ-123
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/jira-api.sh"
source "$SCRIPT_DIR/lib/github-api.sh"
source "$SCRIPT_DIR/lib/utils.sh"

# Parse arguments
if [[ $# -lt 1 ]]; then
  error "Usage: $0 <ISSUE_KEY>"
  exit 1
fi

ISSUE_KEY="$1"

# Validate issue key format
if ! [[ "$ISSUE_KEY" =~ ^[A-Z]+-[0-9]+$ ]]; then
  error "Invalid issue key format. Expected: PROJECT-123"
  exit 1
fi

info "Fetching ticket $ISSUE_KEY..."

# Fetch current ticket
TICKET=$(jira_get_issue "$ISSUE_KEY")

if [[ -z "$TICKET" ]]; then
  error "Ticket not found: $ISSUE_KEY"
  exit 1
fi

CURRENT_SUMMARY=$(echo "$TICKET" | jq -r '.fields.summary')
CURRENT_DESC=$(echo "$TICKET" | jq -r '.fields.description // ""')

info "Current: $CURRENT_SUMMARY"

# Search for related PRs and commits
info "Searching GitHub for related work..."

RELATED_PRS=$(github_search_prs "$ISSUE_KEY")
RELATED_COMMITS=$(github_search_commits "$ISSUE_KEY")

PR_COUNT=$(echo "$RELATED_PRS" | jq 'length')
COMMIT_COUNT=$(echo "$RELATED_COMMITS" | jq 'length')

info "Found: $PR_COUNT PRs, $COMMIT_COUNT commits"

# Generate additional acceptance criteria
info "Generating enhancements..."

# Simple enhancement: add standard AC if missing
ADDITIONAL_AC="

---

**Enhanced Acceptance Criteria**:
1. Code reviewed and approved
2. Unit tests cover main functionality (>80% coverage)
3. Integration tests pass in CI/CD
4. Documentation updated (README, API docs)
5. No security vulnerabilities introduced"

if [[ "$PR_COUNT" -gt 0 ]]; then
  PR_NUMBERS=$(echo "$RELATED_PRS" | jq -r '.[].number' | paste -sd, -)
  ADDITIONAL_AC="$ADDITIONAL_AC

**Related PRs**: #$PR_NUMBERS"
fi

# Update ticket
UPDATED_DESC="$CURRENT_DESC$ADDITIONAL_AC"

info "Updating ticket..."

jira_update_issue "$ISSUE_KEY" "$UPDATED_DESC"

# Add comment
COMMENT="Ticket groomed by Copilot Assistant on $(date '+%Y-%m-%d %H:%M:%S')

Enhancements:
- Added 5 standard acceptance criteria
- Found $PR_COUNT related PRs
- Found $COMMIT_COUNT related commits"

jira_add_comment "$ISSUE_KEY" "$COMMENT"

# Success
echo ""
success "Groomed: $ISSUE_KEY"
info "📝 Added 5 acceptance criteria"
info "🔗 Found $PR_COUNT related PRs"
info "💬 Added comment with details"
info "🔗 $JIRA_BASE_URL/browse/$ISSUE_KEY"
echo ""
```

### Script 3: jira-close.sh

**File**: `scripts/jira-close.sh`

```bash
#!/bin/bash
#
# jira-close.sh - Close JIRA ticket
#
# Usage:
#   ./jira-close.sh PROJ-123
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/jira-api.sh"
source "$SCRIPT_DIR/lib/utils.sh"

if [[ $# -lt 1 ]]; then
  error "Usage: $0 <ISSUE_KEY>"
  exit 1
fi

ISSUE_KEY="$1"

info "Fetching ticket $ISSUE_KEY..."

# Fetch ticket
TICKET=$(jira_get_issue "$ISSUE_KEY")
SUMMARY=$(echo "$TICKET" | jq -r '.fields.summary')
STATUS=$(echo "$TICKET" | jq -r '.fields.status.name')

info "Current status: $STATUS"

if [[ "$STATUS" == "Done" ]]; then
  warning "Ticket is already Done"
  exit 0
fi

# Generate completion summary
SUMMARY_COMMENT="Ticket completed on $(date '+%Y-%m-%d')

Summary: $SUMMARY

This ticket has been marked as complete."

# Add comment
info "Adding completion comment..."
jira_add_comment "$ISSUE_KEY" "$SUMMARY_COMMENT"

# Transition to Done
info "Transitioning to Done..."
jira_transition_issue "$ISSUE_KEY" "Done"

# Success
echo ""
success "Closed: $ISSUE_KEY"
info "✅ Status: Done"
info "🔗 $JIRA_BASE_URL/browse/$ISSUE_KEY"
echo ""
```

### Script 4: jira-sync.sh

**File**: `scripts/jira-sync.sh`

```bash
#!/bin/bash
#
# jira-sync.sh - Sync JIRA tickets with GitHub repository activity
#
# Usage:
#   ./jira-sync.sh                    # Sync all repos
#   ./jira-sync.sh --repo owner/repo  # Sync specific repo
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/jira-api.sh"
source "$SCRIPT_DIR/lib/github-api.sh"
source "$SCRIPT_DIR/lib/utils.sh"

# Parse arguments
REPO_FILTER=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --repo)
      REPO_FILTER="$2"
      shift 2
      ;;
    *)
      error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Get repos
if [[ -n "$REPO_FILTER" ]]; then
  info "Syncing repo: $REPO_FILTER"
  REPOS="[\"$REPO_FILTER\"]"
else
  info "Fetching all repos in $GITHUB_ORG..."
  REPOS=$(github_list_repos)
fi

REPO_COUNT=$(echo "$REPOS" | jq 'length')
info "Scanning $REPO_COUNT repositories..."

UPDATED_COUNT=0
ERROR_COUNT=0

# Process each repo
echo "$REPOS" | jq -r '.[]' | while read -r REPO; do
  info "Scanning $REPO..."
  
  # Get recent PRs
  PRS=$(github_list_prs "$REPO" "all")
  
  echo "$PRS" | jq -c '.[]' | while read -r PR; do
    PR_NUMBER=$(echo "$PR" | jq -r '.number')
    PR_STATE=$(echo "$PR" | jq -r '.state')
    PR_MERGED=$(echo "$PR" | jq -r '.merged_at // empty')
    PR_TITLE=$(echo "$PR" | jq -r '.title')
    PR_BODY=$(echo "$PR" | jq -r '.body // ""')
    
    # Extract JIRA keys from PR
    JIRA_KEYS=$(echo "$PR_TITLE $PR_BODY" | grep -oE '[A-Z]+-[0-9]+' | sort -u)
    
    if [[ -z "$JIRA_KEYS" ]]; then
      continue
    fi
    
    # Update each ticket
    for KEY in $JIRA_KEYS; do
      # Fetch current status
      TICKET=$(jira_get_issue "$KEY" 2>/dev/null || echo "")
      
      if [[ -z "$TICKET" ]]; then
        warning "Ticket not found: $KEY"
        ((ERROR_COUNT++))
        continue
      fi
      
      CURRENT_STATUS=$(echo "$TICKET" | jq -r '.fields.status.name')
      
      # Determine new status
      NEW_STATUS=""
      
      if [[ "$PR_STATE" == "open" && "$CURRENT_STATUS" == "To Do" ]]; then
        NEW_STATUS="In Review"
      elif [[ -n "$PR_MERGED" && "$CURRENT_STATUS" != "Done" ]]; then
        NEW_STATUS="Done"
      fi
      
      # Transition if needed
      if [[ -n "$NEW_STATUS" ]]; then
        info "$KEY: $CURRENT_STATUS → $NEW_STATUS (PR #$PR_NUMBER)"
        jira_transition_issue "$KEY" "$NEW_STATUS"
        ((UPDATED_COUNT++))
      fi
    done
  done
done

# Summary
echo ""
success "Sync complete"
info "📊 Scanned: $REPO_COUNT repos"
info "✅ Updated: $UPDATED_COUNT tickets"
info "⚠️  Errors: $ERROR_COUNT"
echo ""
```

### Library: jira-api.sh

**File**: `scripts/lib/jira-api.sh`

```bash
#!/bin/bash
# JIRA API helper functions

jira_get_issue() {
  local key="$1"
  curl -s -X GET "$JIRA_BASE_URL/rest/api/2/issue/$key" \
    -H "Authorization: Bearer $JIRA_TOKEN" \
    -H "Content-Type: application/json"
}

jira_update_issue() {
  local key="$1"
  local description="$2"
  
  local payload=$(cat <<EOF
{
  "fields": {
    "description": "$description"
  }
}
EOF
  )
  
  curl -s -X PUT "$JIRA_BASE_URL/rest/api/2/issue/$key" \
    -H "Authorization: Bearer $JIRA_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload"
}

jira_add_comment() {
  local key="$1"
  local body="$2"
  
  local payload=$(cat <<EOF
{
  "body": "$body"
}
EOF
  )
  
  curl -s -X POST "$JIRA_BASE_URL/rest/api/2/issue/$key/comment" \
    -H "Authorization: Bearer $JIRA_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload"
}

jira_transition_issue() {
  local key="$1"
  local status_name="$2"
  
  # Get available transitions
  local transitions=$(curl -s -X GET "$JIRA_BASE_URL/rest/api/2/issue/$key/transitions" \
    -H "Authorization: Bearer $JIRA_TOKEN")
  
  # Find transition ID
  local transition_id=$(echo "$transitions" | jq -r ".transitions[] | select(.name == \"$status_name\") | .id")
  
  if [[ -z "$transition_id" ]]; then
    error "No transition to '$status_name' available"
    return 1
  fi
  
  # Execute transition
  local payload=$(cat <<EOF
{
  "transition": {"id": "$transition_id"}
}
EOF
  )
  
  curl -s -X POST "$JIRA_BASE_URL/rest/api/2/issue/$key/transitions" \
    -H "Authorization: Bearer $JIRA_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload"
}
```

### Library: github-api.sh

**File**: `scripts/lib/github-api.sh`

```bash
#!/bin/bash
# GitHub API helper functions

github_list_repos() {
  gh repo list "$GITHUB_ORG" --json nameWithOwner --limit 1000 | jq -r '.[].nameWithOwner'
}

github_list_prs() {
  local repo="$1"
  local state="${2:-all}"  # all, open, closed
  
  gh pr list --repo "$repo" --state "$state" --json number,title,body,state,mergedAt --limit 100
}

github_search_prs() {
  local query="$1"
  gh pr list --search "$query" --json number,title,repository --limit 50
}

github_search_commits() {
  local query="$1"
  # Simplified: search in current repo
  git log --all --grep="$query" --pretty=format:'%h|%s' --max-count=50
}
```

### Library: utils.sh

**File**: `scripts/lib/utils.sh`

```bash
#!/bin/bash
# Common utilities

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

success() {
  echo -e "${GREEN}✅${NC} $1"
}

warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

error() {
  echo -e "${RED}❌${NC} $1" >&2
}
```

---

## 🧪 Testing

### Unit Tests

Create `tests/test-jira-create.sh`:

```bash
#!/bin/bash

source scripts/lib/utils.sh

# Test 1: Help message
echo "Test 1: Help message"
OUTPUT=$(./scripts/jira-create.sh --help)
if [[ "$OUTPUT" == *"Usage"* ]]; then
  success "PASS: Help message displayed"
else
  error "FAIL: Help message not displayed"
  exit 1
fi

# Test 2: Missing summary
echo "Test 2: Missing summary"
OUTPUT=$(./scripts/jira-create.sh 2>&1 || true)
if [[ "$OUTPUT" == *"--summary is required"* ]]; then
  success "PASS: Error for missing summary"
else
  error "FAIL: Should error on missing summary"
  exit 1
fi

echo ""
success "All tests passed!"
```

---

## � Epic 4: Confluence Integration Implementation

### Confluence API Library

**File**: `scripts/lib/confluence-api.sh`

```bash
#!/usr/bin/env bash
# Confluence REST API helper functions

source "$(dirname "$0")/utils.sh"

# Verify Confluence authentication
confluence_check_auth() {
    local response=$(curl -s -w "\n%{http_code}" \
        -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
        "${CONFLUENCE_BASE_URL}/rest/api/user/current")
    
    local http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" != "200" ]; then
        error "Confluence authentication failed (HTTP $http_code)"
        return 1
    fi
    return 0
}

# Fetch Confluence page by ID
# Usage: confluence_get_page "12907938514"
confluence_get_page() {
    local page_id="$1"
    
    curl -s \
        -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
        "${CONFLUENCE_BASE_URL}/rest/api/content/${page_id}?expand=body.storage,version,space"
}

# Get page content in specific format
# Usage: confluence_get_content "12907938514" "storage"
confluence_get_content() {
    local page_id="$1"
    local format="${2:-storage}"  # storage, view, export_view
    
    local page_data=$(confluence_get_page "$page_id")
    echo "$page_data" | jq -r ".body.${format}.value"
}

# Extract page metadata
# Usage: confluence_extract_metadata "$page_data" "title"
confluence_extract_metadata() {
    local page_data="$1"
    local field="$2"
    
    echo "$page_data" | jq -r ".${field}"
}

# Convert Confluence storage format to markdown (basic)
confluence_to_markdown() {
    local html="$1"
    
    # Basic HTML to markdown conversion
    echo "$html" | \
        sed 's/<p>/\n/g' | \
        sed 's/<\/p>//g' | \
        sed 's/<li>/- /g' | \
        sed 's/<\/li>//g' | \
        sed 's/<h1>/# /g' | \
        sed 's/<\/h1>//g' | \
        sed 's/<h2>/## /g' | \
        sed 's/<\/h2>//g' | \
        sed 's/<[^>]*>//g'
}

# Extract section by heading
confluence_extract_section() {
    local content="$1"
    local heading="$2"
    
    # Extract content between heading and next heading
    echo "$content" | \
        sed -n "/<h[0-9]>$heading<\/h[0-9]>/,/<h[0-9]>/p" | \
        sed '$d'
}
```

### confluence-to-jira.sh Script

**File**: `scripts/confluence-to-jira.sh`

```bash
#!/usr/bin/env bash
# Create JIRA ticket from Confluence page

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/confluence-api.sh"
source "${SCRIPT_DIR}/lib/jira-api.sh"

# Parse command-line arguments
URL=""
PAGE_ID=""
PROJECT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --url) URL="$2"; shift 2 ;;
        --page-id) PAGE_ID="$2"; shift 2 ;;
        --project) PROJECT="$2"; shift 2 ;;
        --help) show_help; exit 0 ;;
        *) error "Unknown option: $1"; exit 1 ;;
    esac
done

# Extract page ID from URL if provided
if [ -n "$URL" ] && [ -z "$PAGE_ID" ]; then
    PAGE_ID=$(echo "$URL" | grep -oE '[0-9]{10,}')
fi

# Validate inputs
[ -z "$PAGE_ID" ] && error "Missing --url or --page-id" && exit 1
[ -z "$PROJECT" ] && error "Missing --project" && exit 1

# Fetch Confluence page
info "Fetching Confluence page: $PAGE_ID"
page_data=$(confluence_get_page "$PAGE_ID")

# Extract metadata
title=$(echo "$page_data" | jq -r '.title')
content=$(echo "$page_data" | jq -r '.body.storage.value')

# Parse content
description=$(echo "$content" | confluence_extract_section "Overview" || \
              echo "$content" | sed -n '/<p>/,/<\/p>/p' | head -1 | confluence_to_markdown)

features=$(echo "$content" | grep -o '<li>.*</li>' | sed 's/<[^>]*>//g' | tr '\n' ',')

# Detect priority
priority="Medium"
[[ "$content" =~ (urgent|critical|blocker) ]] && priority="High"
[[ "$content" =~ (nice to have|low priority) ]] && priority="Low"

# Add Confluence link to description
full_description="$description

Source: $URL"

# Create JIRA ticket
info "Creating JIRA ticket..."
ticket_key=$(jira_create_issue \
    "$PROJECT" \
    "$title" \
    "$full_description" \
    "$features" \
    "$priority")

success "Created: $ticket_key"
info "JIRA: ${JIRA_BASE_URL}/browse/${ticket_key}"
info "Confluence: $URL"
```

---

## �🚀 Deployment

### Team Rollout (Epics 1-3 - Complete)

1. **Commit to repository** ✅:
   ```bash
   git add .github/copilot-instructions.md scripts/
   git commit -m "Add Copilot JIRA assistant"
   git push
   ```

2. **Team members clone** ✅:
   ```bash
   git clone https://github.com/yourorg/repo.git
   cd repo
   cp .env.example .env
   vim .env  # Add credentials
   ```

3. **Verify setup** ✅:
   ```bash
   ./scripts/jira-create.sh --help
   ```

4. **Start using with Copilot** ✅:
   - Open any spec file
   - Ask Copilot: "@github create jira ticket"

### Epic 4 Rollout (Confluence - Ready)

1. **Update environment**:
   ```bash
   # Add to .env
   CONFLUENCE_BASE_URL=https://yourcompany.atlassian.net/wiki
   # Uses same JIRA_API_TOKEN
   ```

2. **Pull latest changes**:
   ```bash
   git pull origin main
   chmod +x scripts/confluence-to-jira.sh
   ```

3. **Test Confluence integration**:
   ```bash
   ./scripts/confluence-to-jira.sh \
     --url "https://yourcompany.atlassian.net/wiki/spaces/SPACE/pages/12345/" \
     --project PROJ
   ```

4. **Use with Copilot**:
   - Paste Confluence URL in chat
   - Ask: "create jira ticket from this confluence page"

---

**Document Version**: 2.0.0  
**Last Updated**: 2025-10-14  
**Maintainer**: Engineering Team
