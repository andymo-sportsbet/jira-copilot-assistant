# Spec 008: Copilot-Powered JIRA Workflow Assistant

**Status**: In Progress  
**Created**: 2025-10-14  
**Last Updated**: 2025-10-15  
**Owner**: Engineering Team  
**Approach**: Copilot Custom Instructions + Shell Scripts (Hybrid)  
**Story Points**: 28.5 SP (15 SP complete + 7 SP Epic 4 + 6.5 SP Epic 5)  
**Timeline**: 4 weeks (2 weeks complete + 1 week Epic 4 + 1 week Epic 5)

---

## 📋 Executive Summary

### The Problem
Developers waste time:
- Switching between IDE, browser, and JIRA
- Copy-pasting requirements from specs to JIRA
- Manually keeping JIRA tickets synced with code changes
- Building and maintaining complex custom extensions

### The Solution
Use **GitHub Copilot's Custom Instructions** to teach Copilot about your JIRA workflows. Copilot reads your files, understands your intent, and suggests ready-to-run shell scripts that automate JIRA operations.

### Key Innovation
**Zero Extension Development**:
- No VS Code extension to build or maintain
- No TypeScript, no React, no webviews
- Just 4 simple shell scripts + 1 instruction file
- Works immediately with standard Copilot

### How It Works

```
1. Developer opens spec file in VS Code
2. Developer asks Copilot: "create jira ticket from this file"
3. Copilot reads file, parses content
4. Copilot suggests: ./scripts/jira-create.sh --summary "..." --description "..."
5. Developer reviews and runs command
6. Script creates ticket in JIRA
7. Terminal shows: ✅ Created PROJ-123
```

---

## 🎯 Architecture

### System Flow

```
┌──────────────────────────────────────────────────────┐
│  Developer                                           │
│  1. Opens specs/auth/spec.md                        │
│  2. Asks Copilot: "@github create jira ticket"      │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│  GitHub Copilot                                      │
│  • Reads spec.md automatically                       │
│  • Applies Custom Instructions from                  │
│    .github/copilot-instructions.md                   │
│  • Parses: title, description, features              │
│  • Generates shell command                           │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│  Copilot Suggestion (in Chat)                        │
│                                                      │
│  "I'll create a JIRA ticket. Please run:            │
│                                                      │
│  ./scripts/jira-create.sh \                         │
│    --summary 'User Authentication System' \         │
│    --description 'OAuth 2.0 with JWT tokens' \     │
│    --features 'Login,Logout,MFA' \                  │
│    --priority 'High'                                │
│                                                      │
│  This will create a Story in PROJ with the          │
│  'copilot-created' label."                          │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼ Developer reviews & runs
                     │
┌──────────────────────────────────────────────────────┐
│  Shell Script (scripts/jira-create.sh)               │
│  • Parses command-line arguments                     │
│  • Calls JIRA REST API with curl                    │
│  • Creates ticket with fields                        │
│  • Returns ticket key and URL                        │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│  JIRA API                                            │
│  POST /rest/api/2/issue                             │
│  Response: {"key": "PROJ-123", "self": "..."}       │
└────────────────────┬─────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────┐
│  Terminal Output                                     │
│  ✅ Created: PROJ-123                               │
│  📝 Summary: User Authentication System              │
│  🔗 https://company.atlassian.net/browse/PROJ-123   │
└──────────────────────────────────────────────────────┘
```

---

## 🛠️ Components

### 1. Copilot Custom Instructions

**File**: `.github/copilot-instructions.md`

```markdown
# JIRA Workflow Instructions

## When user says "create jira ticket":
1. Read current file
2. Extract title (first # heading), description, features (bullet lists)
3. Suggest command:

./scripts/jira-create.sh \
  --summary "..." \
  --description "..." \
  --features "..." \
  --priority "High|Medium|Low"

## When user says "groom PROJ-123":
Suggest: ./scripts/jira-groom.sh PROJ-123

## When user says "close PROJ-123":
Suggest: ./scripts/jira-close.sh PROJ-123

## When user says "sync jira":
Suggest: ./scripts/jira-sync.sh
```

### 2. Shell Scripts

**File**: `scripts/jira-create.sh`

```bash
#!/bin/bash
# Create JIRA ticket from command line

set -euo pipefail

# Parse arguments
SUMMARY=""
DESCRIPTION=""
FEATURES=""
PRIORITY="Medium"

while [[ $# -gt 0 ]]; do
  case $1 in
    --summary) SUMMARY="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --features) FEATURES="$2"; shift 2 ;;
    --priority) PRIORITY="$2"; shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

# Validate
if [[ -z "$SUMMARY" ]]; then
  echo "❌ Error: --summary required"
  exit 1
fi

# Build description with features
FULL_DESC="$DESCRIPTION

Features:
$(echo "$FEATURES" | tr ',' '\n' | sed 's/^/- /')"

# Call JIRA API
RESPONSE=$(curl -s -X POST "$JIRA_BASE_URL/rest/api/2/issue" \
  -H "Authorization: Bearer $JIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "fields": {
    "project": {"key": "$JIRA_PROJECT"},
    "summary": "$SUMMARY",
    "description": "$FULL_DESC",
    "issuetype": {"name": "Story"},
    "priority": {"name": "$PRIORITY"},
    "labels": ["copilot-created"]
  }
}
EOF
)

# Parse response
KEY=$(echo "$RESPONSE" | jq -r '.key')

if [[ "$KEY" == "null" ]]; then
  echo "❌ Failed to create ticket"
  echo "$RESPONSE" | jq .
  exit 1
fi

# Success output
echo "✅ Created: $KEY"
echo "📝 Summary: $SUMMARY"
echo "🔗 $JIRA_BASE_URL/browse/$KEY"
```

### 3. Environment Configuration

**File**: `.env.example`

```bash
# JIRA Configuration
JIRA_BASE_URL=https://yourcompany.atlassian.net
JIRA_TOKEN=ATATT3x...
JIRA_PROJECT=PROJ

# GitHub Configuration
GITHUB_TOKEN=ghp_...
GITHUB_ORG=yourorg
```

---

## 📝 Implementation Guide

### Phase 1: Setup (Week 1)

**Tasks**:
1. ✅ Create `.github/copilot-instructions.md`
2. ✅ Write `scripts/jira-create.sh`
3. ✅ Write `scripts/jira-groom.sh`
4. ✅ Write `scripts/jira-close.sh`
5. ✅ Write `scripts/jira-sync.sh`
6. ✅ Create `.env.example` template
7. ✅ Write README with setup instructions
8. ✅ Test with sample spec files

### Phase 2: Enhancement (Week 2)

**Tasks**:
1. ✅ Add AI-powered ticket enhancement (groom script)
2. ✅ Add GitHub PR/commit search
3. ✅ Add colored terminal output
4. ✅ Add error handling and troubleshooting
5. ✅ Write team onboarding guide
6. ✅ Create demo video

---

## 🎬 Example Workflows

### Workflow 1: Create Ticket

```bash
# 1. Developer opens specs/auth/spec.md in VS Code

# 2. Developer asks Copilot
"@github create jira ticket from this file"

# 3. Copilot reads file and suggests:
./scripts/jira-create.sh \
  --summary "User Authentication System" \
  --description "Implement OAuth 2.0 authentication" \
  --features "Login,Logout,Token refresh,MFA" \
  --priority "High"

# 4. Developer reviews and runs command

# 5. Terminal output:
✅ Created: PROJ-123
📝 Summary: User Authentication System
🔗 https://company.atlassian.net/browse/PROJ-123
```

### Workflow 2: Groom Ticket

```bash
# 1. Developer has PR open mentioning PROJ-123

# 2. Developer asks Copilot
"@github groom PROJ-123"

# 3. Copilot suggests:
./scripts/jira-groom.sh PROJ-123

# 4. Script:
#    - Fetches ticket from JIRA
#    - Searches GitHub for PRs mentioning PROJ-123
#    - Generates additional acceptance criteria
#    - Updates ticket with enhancements

# 5. Terminal output:
✅ Groomed: PROJ-123
📝 Added 5 acceptance criteria
🔗 Found 2 related PRs: #45, #67
📊 Updated story points: 5 → 8
```

### Workflow 3: Sync Repos

```bash
# 1. Developer asks Copilot
"@github sync jira with github"

# 2. Copilot suggests:
./scripts/jira-sync.sh

# 3. Script:
#    - Lists all repos in GitHub org
#    - Scans commits/PRs for JIRA keys (last 7 days)
#    - Updates ticket statuses based on PR state:
#      • Open PR → "In Review"
#      • Merged PR → "Done"

# 4. Terminal output:
🔄 Scanning 10 repositories...
✅ PROJ-123: To Do → In Review (PR #45 opened)
✅ PROJ-124: In Progress → Done (PR #46 merged)
📊 Updated 2 tickets, 0 errors
```

---

## 📊 Task Breakdown

### Epic 1: Core Scripts (8 SP)

**Task 1.1**: Create jira-create.sh (3 SP)
- Parse command-line arguments
- Call JIRA REST API
- Handle errors
- Format output

**Task 1.2**: Create jira-groom.sh (3 SP)
- Fetch ticket from JIRA
- Search GitHub for related work
- Generate enhancements
- Update ticket

**Task 1.3**: Create jira-close.sh (1 SP)
- Fetch ticket
- Generate summary
- Transition to Done

**Task 1.4**: Create jira-sync.sh (2 SP)
- List repos
- Scan for JIRA keys
- Update statuses

---

### Epic 2: Copilot Integration (4 SP)

**Task 2.1**: Write Copilot Instructions (2 SP)
- Create `.github/copilot-instructions.md`
- Define all command patterns
- Add examples and best practices

**Task 2.2**: Test Copilot Suggestions (2 SP)
- Validate Copilot generates correct commands
- Test with various file formats
- Ensure context accuracy > 95%

---

### Epic 3: Documentation (3 SP)

**Task 3.1**: Setup Guide (1 SP)
- Installation steps
- Environment configuration
- Quick start examples

**Task 3.2**: User Guide (1 SP)
- All commands with examples
- Troubleshooting section
- FAQ

**Task 3.3**: Demo Video (1 SP)
- Record 2-3 minute walkthrough
- Show all workflows
- Publish to team wiki

---

### Epic 4: Confluence Integration (7 SP)

**Objective**: Enable creating JIRA tickets from Confluence pages and saving Confluence content as local spec files.

**Task 4.1**: Confluence API Library (2 SP) ✅ Complete
- Create `scripts/lib/confluence-api.sh`
- Implement Confluence REST API authentication (same as JIRA - Atlassian Cloud)
- Functions:
  - `confluence_get_page()` - Fetch page by ID or URL
  - `confluence_get_page_content()` - Get page content as markdown/plain text
  - `confluence_extract_metadata()` - Extract title, labels, author
- Handle Confluence-specific content format (XHTML/Storage format)
- Convert Confluence storage format to markdown

**Task 4.2**: confluence-to-jira.sh Script (2 SP) ✅ Complete
- Accept Confluence page URL or page ID
- Fetch page content via Confluence API
- Parse page structure:
  - Extract title (page title)
  - Extract description (first paragraph or "Overview" section)
  - Extract requirements (bullet lists, numbered lists)
  - Detect priority from page labels or keywords
- Support multiple page formats:
  - Requirements pages
  - RFC/Design pages
  - Technical specifications
- Call `jira-create.sh` with extracted data
- Link JIRA ticket back to Confluence page (add link in ticket description)

**Task 4.3**: confluence-to-spec.sh Script (2 SP) 🚧 Ready
- Accept Confluence page URL or page ID
- Fetch page content via Confluence API
- Convert Confluence content to clean markdown format
- Extract metadata (title, labels, author, date, page ID)
- Generate spec file with standard structure:
  - Front matter with Confluence metadata
  - Title, Overview, Requirements, Technical Details
- Support custom output path via `--output` parameter
- Default output: `specs/confluence-[page-id]/spec.md`
- Create directory structure automatically
- Generated spec files can be used with `jira-create.sh` later
- Enables version control of Confluence content

**Task 4.4**: Copilot Instructions for Confluence (1 SP) ✅ Complete
- Update `.github/copilot-instructions.md` with Confluence patterns
- Add trigger phrases:
  - "create jira ticket from this confluence page"
  - "convert confluence page to jira ticket"
  - "save this confluence page as a spec"
  - "download confluence page"
- Add Confluence URL detection logic
- Examples:
  ```
  When user provides Confluence URL:
  https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/
  
  Suggest (for JIRA):
  ./scripts/confluence-to-jira.sh \
    --url "https://sportsbet.atlassian.net/wiki/spaces/..." \
    --project MSPOC
  
  Suggest (for spec):
  ./scripts/confluence-to-spec.sh \
    --url "https://sportsbet.atlassian.net/wiki/spaces/..." \
    --output "specs/001-feature/spec.md"
  ```

**Acceptance Criteria**:
- [x] Can fetch Confluence page by URL or ID
- [x] Correctly extracts title, description, requirements
- [x] Creates JIRA ticket with Confluence content
- [x] Adds link back to Confluence page in ticket
- [x] Saves Confluence page as local spec file
- [x] Generated spec files have proper markdown format
- [x] Spec files include Confluence metadata
- [x] Copilot suggests appropriate command based on user intent
- [x] Works with Atlassian Cloud authentication
- [x] Copilot suggests correct command for Confluence URLs
- [x] Handles pages with different structures (requirements, RFCs, specs)
- [x] Error handling for invalid URLs or authentication issues

---

### Epic 5: AI Story Point Estimation (6.5 SP)

**Objective**: Enable AI-assisted story point estimation during ticket grooming using team-specific estimation approach (linear scale, 7 focus hours per point, philosophy-based capacity planning).

**Team Context**:
- **Sprint**: 2 weeks (10 working days)
- **Story Points Scale**: 0.5, 1, 2, 3, 4, 5 (linear, not Fibonacci)
- **1 Story Point = 7 Focus Hours**
- **Philosophy %**: Individual capacity per sprint (e.g., 50% = 6 points capacity)
- **Estimation**: Team-based voting during sprint planning
- **AI Role**: Provide initial suggestions to speed up grooming

**Task 5.1**: Estimation Library (3 SP) 🚧 Ready
- Create `scripts/lib/jira-estimate.sh`
- Implement AI estimation algorithm:
  - `estimate_story_points(ticket_data)` - Main estimation function
  - `analyze_complexity(summary, description)` - Parse complexity indicators
  - `calculate_base_points(ticket_type)` - 0.5 for bugs, 1.0 for stories
  - `calculate_complexity_factor()` - 0-2 points based on keywords
  - `calculate_uncertainty_factor()` - 0-1 points for unclear requirements
  - `calculate_testing_factor()` - 0-1 points for testing complexity
  - `round_to_team_scale(raw_points)` - Round to 0.5, 1, 2, 3, 4, 5
  - `format_estimation_reasoning()` - Explain breakdown
  - `should_suggest_breakdown(points)` - Flag 4-5 point tasks for splitting
- Complexity keyword detection:
  - HIGH: framework upgrade, migration, third-party API, security
  - MEDIUM: database, endpoint, business logic, validation
  - LOW: simple, config, typo, label
- Uncertainty keyword detection:
  - HIGH: unclear, unknown, investigate, TBD
  - MEDIUM: explore, consider, dependent on
- Estimation formula:
  ```
  total = base_points + complexity + uncertainty + testing
  final = round_to_team_scale(total)
  ```
- Output JSON format:
  ```json
  {
    "estimated_points": 2,
    "breakdown": {"base": 1, "complexity": 0.5, "uncertainty": 0.5, "testing": 0},
    "reasoning": "Base: 1 point (new feature)\nComplexity: +0.5 (database integration)\nTotal: 2 points (14 focus hours)",
    "should_split": false
  }
  ```

**Task 5.2**: Enhance jira-groom.sh with Estimation (2 SP) 🚧 Ready
- Add `--estimate` flag for AI estimation (interactive)
- Add `--points N` flag for manual point assignment
- Add `--auto-estimate` flag for non-interactive mode
- Integrate with estimation library
- Interactive prompt workflow:
  1. Display AI suggestion with reasoning
  2. Show breakdown (base + complexity + uncertainty + testing)
  3. Warn if 4-5 points (suggest task breakdown)
  4. Prompt user: Accept / Override / Skip
- Implement `update_story_points(ticket_key, points)`:
  - Validate points against team scale (0.5, 1, 2, 3, 4, 5)
  - Update JIRA customfield (customfield_10016 configurable)
  - Display success message with estimated points
- Add estimation result to grooming output:
  ```
  📊 AI Estimation: 2 points
  Reasoning:
    - Base: 1 point (new feature)
    - Complexity: +0.5 (database change)
    - Testing: +0.5 (integration tests)
    - Total: 2 points (14 focus hours)
  
  Do you want to:
    1. Accept (2 points)
    2. Override (enter points)
    3. Skip estimation
  ```

**Task 5.3**: Environment Configuration (0.5 SP) 🚧 Ready
- Add to `.env.example`:
  ```bash
  # Story Points Estimation
  JIRA_STORY_POINTS_FIELD=customfield_10016
  ```
- Document field ID discovery:
  ```bash
  # Find story points field
  curl -s -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
    "${JIRA_BASE_URL}/rest/api/3/field" | \
    jq '.[] | select(.name | contains("Story Points"))'
  ```
- Update README.md with estimation examples

**Task 5.4**: Copilot Instructions for Estimation (1 SP) 🚧 Ready
- Update `.github/copilot-instructions.md` with estimation patterns
- Add trigger phrases:
  - "estimate this ticket"
  - "add story points"
  - "how many points is this"
  - "groom and estimate RVV-1234"
- Add estimation context:
  - Team scale: 0.5, 1, 2, 3, 4, 5
  - 1 point = 7 focus hours
  - Philosophy % capacity planning
- Examples:
  ```
  When user asks to estimate:
  
  ./scripts/jira-groom.sh RVV-1234 --estimate
  # AI analyzes and suggests points
  
  When user wants manual points:
  
  ./scripts/jira-groom.sh RVV-1234 --points 2
  # Directly sets 2 points
  
  When user wants auto-accept:
  
  ./scripts/jira-groom.sh RVV-1234 --auto-estimate
  # No prompt, accepts AI suggestion
  ```

**Acceptance Criteria**:
- [ ] AI estimates simple bug fix as 0.5-1 points
- [ ] AI estimates medium feature as 2 points
- [ ] AI estimates complex integration as 3 points
- [ ] AI suggests breakdown for 4-5 point tasks
- [ ] `--estimate` flag analyzes ticket and suggests points
- [ ] `--points N` flag directly sets points
- [ ] User can accept, override, or skip AI suggestion
- [ ] Story points field updates in JIRA
- [ ] Estimation reasoning explains breakdown
- [ ] Works with team scale (0.5, 1, 2, 3, 4, 5)
- [ ] Copilot suggests estimation commands
- [ ] 80% of AI suggestions within ±1 point of manual estimates

**References**:
- Specification: `specs/001-user-authentication-system/team-story-points-estimation-spec.md`
- Confluence: [Story points based estimation](https://sportsbet.atlassian.net/wiki/spaces/RVS/pages/13287785039)
- Team: Racing Value Stream (RVS)

**Configuration** (add to `.env`):
```bash
# Confluence Configuration (uses same credentials as JIRA)
CONFLUENCE_BASE_URL=https://sportsbet.atlassian.net/wiki
# CONFLUENCE_TOKEN - uses JIRA_API_TOKEN (same Atlassian account)
```

**Example Usage**:
```bash
# From Confluence URL
./scripts/confluence-to-jira.sh \
  --url "https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/" \
  --project MSPOC

# Output:
✅ Fetched Confluence page: DM Adapters Springboot Upgrade
📝 Extracted 5 requirements
✅ Created: MSPOC-88
🔗 JIRA: https://amo3167.atlassian.net/browse/MSPOC-88
🔗 Confluence: https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/
```

**User Workflow**:
1. User has Confluence page URL
2. Opens VS Code, asks Copilot: "create jira ticket from this confluence page: <URL>"
3. Copilot suggests `confluence-to-jira.sh` command with URL
4. User runs command
5. Script fetches Confluence page, extracts content
6. Creates JIRA ticket with requirements
7. Adds Confluence link to ticket description

---

## ✅ Success Criteria

### Functional
- [x] Copilot generates correct commands 95% of the time
- [x] Scripts create valid JIRA tickets
- [x] Groom script enhances tickets with 3+ AC
- [x] Sync script updates ticket statuses correctly

### Performance
- [x] Ticket created in < 10 seconds
- [x] Groom completes in < 15 seconds
- [x] Sync (10 repos) completes in < 30 seconds

### Usability
- [x] Setup time < 5 minutes
- [x] 80% of users find scripts easier than manual JIRA
- [x] Team adoption: 60% within 2 weeks

---

## 🚀 Getting Started

### Prerequisites
- VS Code with GitHub Copilot enabled
- jq (JSON parser): `brew install jq`
- curl (usually pre-installed)
- JIRA API token
- GitHub Personal Access Token

### Installation

```bash
# 1. Clone repository
git clone https://github.com/yourorg/jira-copilot-assistant.git
cd jira-copilot-assistant

# 2. Copy environment template
cp .env.example .env

# 3. Edit .env with your credentials
vim .env

# 4. Make scripts executable
chmod +x scripts/*.sh

# 5. Test setup
./scripts/jira-create.sh --help

# 6. Start using with Copilot!
# Open a spec file and ask: "@github create jira ticket"
```

---

## 🔄 Comparison: Extension vs. Hybrid

| Aspect | Extension Approach | Hybrid Approach ⭐ |
|--------|-------------------|-------------------|
| **Setup** | Install extension | Git clone + set env vars |
| **Code** | ~2000 LOC TypeScript | ~600 LOC Bash |
| **Maintenance** | High (updates, bugs) | Low (simple scripts) |
| **Team Adoption** | Medium (install friction) | Easy (git clone) |
| **Customization** | Requires TypeScript knowledge | Edit bash scripts |
| **Development Time** | 6 weeks (40 SP) | 3 weeks (20 SP) |
| **User Control** | Automatic execution | Review before running |
| **Transparency** | Black box | Scripts are readable |

---

## 📖 Why This Approach Wins

### 1. **Simplicity**
- 6 shell scripts vs. full extension (create, groom, close, sync, confluence-to-jira, confluence-to-spec)
- 22 SP vs. 40 SP
- 3 weeks vs. 6 weeks

### 2. **Transparency**
- User reviews commands before running
- Scripts are readable and modifiable
- No black-box automation

### 3. **Maintainability**
- Bash scripts are simple to debug
- No TypeScript/Node.js dependencies
- No VS Code API compatibility issues

### 4. **Adoption**
- No extension installation
- Works immediately after git clone
- Team-wide configuration in `.github/`

### 5. **Flexibility**
- Easy to customize scripts
- Add new commands by editing instructions
- Works with any CI/CD system

---

## 🎯 Next Steps

1. **Weeks 1-2**: ✅ Epic 1-3 Complete (Core scripts, Copilot integration, Documentation)
2. **Week 3**: ✅ Epic 4 - Confluence Integration (4 tasks, 7 SP) - Complete
3. **Week 4**: 🚧 Epic 5 - AI Story Point Estimation (4 tasks, 6.5 SP) - In Progress
4. **Week 5**: Full team rollout including Confluence workflows and estimation

---

**Document Version**: 5.0.0  
**Approach**: Hybrid (Copilot Instructions + Scripts)  
**Story Points**: 28.5 SP (22 complete + 6.5 SP Epic 5)  
**Timeline**: 4 weeks (3 weeks complete + 1 week Epic 5)  
**Status**: Epic 1-4 Complete, Epic 5 In Progress
