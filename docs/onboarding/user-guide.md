# User Guide - JIRA Copilot Assistant

Complete guide to using the JIRA Copilot Assistant for automating JIRA workflows.

---

## Table of Contents
- [Overview](#overview)
- [Quick Start](#quick-start)
- [Command Reference](#command-reference)
- [Workflows](#workflows)
- [GitHub Copilot Integration](#github-copilot-integration)
- [Best Practices](#best-practices)
- [Examples](#examples)

---

## Overview

The JIRA Copilot Assistant provides **six powerful commands** to automate your JIRA workflow:

| Command | Purpose | Use When |
|---------|---------|----------|
| `jira-create.sh` | Create tickets | You have a specification or feature request |
| `jira-groom.sh` | Enhance tickets | You want to add acceptance criteria and context |
| `jira-close.sh` | Close tickets | Work is complete and ready to mark done |
| `jira-sync.sh` | Sync with GitHub | You want to keep JIRA updated with PR status |
| `confluence-to-jira.sh` | Create from Confluence | You have requirements in a Confluence page |
| `confluence-to-spec.sh` | Save Confluence as spec | You want to version-control Confluence content |

---

## Quick Start

### Basic Workflow

```bash
# 1. Set up environment
cd jira-copilot-assistant
source .env

# 2. Create a ticket
./scripts/jira-create.sh \
  --summary "Add user profile page" \
  --description "Create a profile page where users can view and edit their information" \
  --features "Profile photo upload,Bio text field,Email preferences"

# 3. Groom the ticket with acceptance criteria
./scripts/jira-groom.sh PROJ-123

# 4. When work is done, close it
./scripts/jira-close.sh PROJ-123

# 5. Keep tickets synced with GitHub PRs
./scripts/jira-sync.sh
```

---

## Command Reference

### 1. Create JIRA Tickets (`jira-create.sh`)

**Purpose**: Create new JIRA tickets from the command line or specification files.

#### Basic Syntax

```bash
./scripts/jira-create.sh \
  --summary "Ticket title" \
  --description "Detailed description" \
  [--features "Feature 1,Feature 2,Feature 3"] \
  [--priority "High|Medium|Low"]
```

#### Parameters

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `--summary` | Yes | Ticket title/summary | "Add payment gateway" |
| `--description` | No | Detailed description | "Integrate Stripe for payments" |
| `--features` | No | Comma-separated features | "Stripe SDK,Apple Pay,Google Pay" |
| `--priority` | No | Ticket priority | "High", "Medium", "Low" |

#### Examples

**Simple ticket**:
```bash
./scripts/jira-create.sh --summary "Fix login button styling"
```

**Detailed ticket**:
```bash
./scripts/jira-create.sh \
  --summary "Mobile App Payment Feature" \
  --description "Add in-app payment functionality using Stripe" \
  --features "Stripe integration,Apple Pay,Google Pay,Receipt generation" \
  --priority "High"
```

**From specification file** (with Copilot):
```bash
# Open spec file in VS Code, then ask Copilot:
# "create jira ticket from this file"
```

#### Output

```
✅ Created: PROJ-123
ℹ️  Summary: Mobile App Payment Feature
ℹ️  Description: Add in-app payment functionality...
ℹ️  Features: Stripe integration,Apple Pay,Google Pay...
ℹ️  Priority: High
🔗 https://your-domain.atlassian.net/browse/PROJ-123
```

---

### 2. Groom JIRA Tickets (`jira-groom.sh`)

**Purpose**: Enhance existing tickets with acceptance criteria, context, and GitHub references.

#### Basic Syntax

```bash
./scripts/jira-groom.sh TICKET-KEY
```

#### What It Does

1. **Fetches ticket details** from JIRA
2. **Searches GitHub** for related PRs and commits
3. **Generates acceptance criteria** based on:
   - Ticket description
   - Feature list
   - Related code changes
4. **Updates the ticket** with:
   - Acceptance criteria (as checklist)
   - GitHub PR links
   - Related commit references

#### Example

```bash
./scripts/jira-groom.sh MSPOC-86
```

#### Output

```
ℹ️  Fetching ticket MSPOC-86...
✅ Found: Mobile App Payment Feature
ℹ️  Searching for related GitHub activity...
ℹ️  Found 2 related PRs
ℹ️  Found 5 related commits
ℹ️  Generating acceptance criteria...
✅ Added 6 acceptance criteria
✅ Ticket groomed successfully!
🔗 https://amo3167.atlassian.net/browse/MSPOC-86
```

#### Generated Acceptance Criteria Example

The script creates testable criteria like:
- [ ] Stripe SDK integration is complete and functional
- [ ] Apple Pay support is implemented for iOS
- [ ] Google Pay support is implemented for Android
- [ ] Payment receipts are generated automatically
- [ ] Transaction history view is accessible
- [ ] All payments are stored securely

---

### 3. Close JIRA Tickets (`jira-close.sh`)

**Purpose**: Mark tickets as complete with an auto-generated summary comment.

#### Basic Syntax

```bash
./scripts/jira-close.sh TICKET-KEY
```

#### What It Does

1. **Fetches ticket details** from JIRA
2. **Generates completion summary** including:
   - Original description
   - Features completed
   - Acceptance criteria met
3. **Transitions ticket** to "Done" status
4. **Adds summary comment** to ticket

#### Example

```bash
./scripts/jira-close.sh MSPOC-85
```

#### Output

```
ℹ️  Fetching ticket MSPOC-85...
✅ Found: Test Ticket - Setup Verification
ℹ️  Generating completion summary...
ℹ️  Transitioning to Done...
✅ Ticket closed successfully!
🔗 https://amo3167.atlassian.net/browse/MSPOC-85
```

#### Generated Comment Example

```markdown
## Ticket Completion Summary

This ticket has been marked as complete.

**Original Description:**
Testing JIRA Copilot Assistant setup

**Features Completed:**
- All acceptance criteria met
- Testing validated successfully

**Status:** Done
```

---

### 4. Sync with GitHub (`jira-sync.sh`)

**Purpose**: Automatically sync JIRA ticket status based on GitHub PR states.

#### Basic Syntax

```bash
# Sync all repositories
./scripts/jira-sync.sh

# Sync specific repository
./scripts/jira-sync.sh --repo "repository-name"
```

#### Parameters

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `--repo` | No | Specific repository to sync | "my-api-service" |

#### What It Does

1. **Fetches repositories** from your GitHub organization
2. **Scans recent PRs** (last 7 days) for JIRA ticket keys
3. **Extracts JIRA keys** from PR titles and bodies (e.g., "PROJ-123")
4. **Updates ticket status** based on PR state:
   - **Open PR** → Ticket moved to "In Progress"
   - **Merged PR** → Ticket moved to "Done"

#### JIRA Key Detection

The script looks for patterns like:
- `PROJ-123` in PR title
- `[PROJ-123]` in PR title
- `Fixes PROJ-123` in PR body
- `Closes PROJ-123` in PR body

#### Example

```bash
# Sync all repositories
source .env
./scripts/jira-sync.sh
```

#### Output

```
ℹ️  Fetching repositories from andymo-sportsbet...
ℹ️  Found 4 repositories
ℹ️  Checking my-api-service...
ℹ️  Found PR: PROJ-123: Add payment endpoint (merged)
✅ Updated PROJ-123 → Done
✅ Sync complete!
ℹ️  Scanned: 4 repositories
ℹ️  Updated: 1 tickets
ℹ️  Errors: 0
```

#### GitHub PR Naming Best Practices

For automatic sync to work, include JIRA keys in PR titles:

✅ **Good PR Titles**:
- `PROJ-123: Add payment endpoint`
- `[PROJ-123] Fix login validation`
- `PROJ-123 - Refactor user service`

❌ **Won't Be Detected**:
- `Add payment endpoint` (no JIRA key)
- `proj-123: Fix bug` (lowercase key)

---

### 5. Create from Confluence (`confluence-to-jira.sh`)

**Purpose**: Create JIRA tickets from Confluence page content.

#### Basic Syntax

```bash
./scripts/confluence-to-jira.sh \
  --url "https://yourcompany.atlassian.net/wiki/spaces/SPACE/pages/123456/" \
  --project PROJ \
  [--priority "High|Medium|Low"]

# Or with page ID directly
./scripts/confluence-to-jira.sh \
  --page-id "123456789" \
  --project PROJ
```

#### Parameters

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `--url` | Yes* | Confluence page URL | Full page URL |
| `--page-id` | Yes* | Confluence page ID | "123456789" |
| `--project` | Yes | JIRA project key | "PROJ", "TEAM", etc. |
| `--priority` | No | Override priority | "High", "Medium", "Low" |

*Either `--url` or `--page-id` is required

#### How It Works

1. **Fetches Confluence page** using REST API
2. **Extracts content**:
   - Title → JIRA summary
   - "Overview"/"Description"/"Summary" section → JIRA description
   - Bullet/numbered lists → Requirements/features
   - Labels → Priority detection
3. **Creates JIRA ticket** with all extracted data
4. **Adds Confluence link** in ticket description

#### Content Extraction Strategy

The script tries multiple extraction strategies in order:

1. **Title**: Uses Confluence page title as JIRA summary
2. **Description** (tries in order):
   - "Overview" section
   - "Description" section
   - "Summary" section
   - First paragraph (fallback)
3. **Requirements**: All `<li>` items from lists
4. **Priority** (auto-detected):
   - Labels/content with "urgent", "critical", "blocker" → High
   - Labels/content with "low priority", "nice to have" → Low
   - Default → Medium

#### Examples

**From Confluence URL**:
```bash
./scripts/confluence-to-jira.sh \
  --url "https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/" \
  --project MSPOC
```

**With page ID and priority override**:
```bash
./scripts/confluence-to-jira.sh \
  --page-id "12907938514" \
  --project MSPOC \
  --priority High
```

**With Copilot**:
1. Paste Confluence URL in VS Code chat
2. Say: "create jira ticket from this confluence page"
3. Copilot detects URL and suggests command

#### Output

```
ℹ️  Extracted page ID: 12907938514
ℹ️  Verifying Confluence authentication...
ℹ️  Fetching Confluence page: 12907938514
✅ Fetched Confluence page: DM Adapters Springboot Upgrade
ℹ️    Space: Data Feeds
ℹ️    Labels: springboot, upgrade, migration
ℹ️  📝 Extracted data:
ℹ️    Title: DM Adapters Springboot Upgrade
ℹ️    Description: 250 characters
ℹ️    Requirements: 5 items
ℹ️    Priority: High

ℹ️  Creating JIRA ticket in project MSPOC...

✅ Created: MSPOC-88
🔗 JIRA: https://amo3167.atlassian.net/browse/MSPOC-88
🔗 Confluence: https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/

✅ Ticket created successfully!
```

#### Configuration

Ensure `.env` has Confluence configuration:

```bash
# Confluence Configuration
CONFLUENCE_BASE_URL=https://yourcompany.atlassian.net/wiki
# Note: Uses same JIRA_API_TOKEN for authentication
```

#### Supported URL Formats

The script recognizes various Confluence URL formats:
- `/wiki/spaces/SPACE/pages/12345/Title`
- `/wiki/pages/viewpage.action?pageId=12345`
- `/wiki/display/SPACE/Title`

#### Troubleshooting

**403 Forbidden**:
- Ensure your Atlassian API token has Confluence read access
- Verify your account can view the specific page
- Check the page isn't private/restricted

**404 Not Found**:
- Verify the page ID is correct
- Check the URL format
- Ensure the page exists

**Can't extract content**:
- Page might use non-standard format
- Try adding an "Overview" or "Description" section
- Use `--priority` to override auto-detection

---

### 6. Save Confluence Page as Spec File (`confluence-to-spec.sh`)

#### Purpose
Save Confluence pages as local markdown spec files for version control, review, and later JIRA ticket creation.

#### Basic Syntax

```bash
# Default location: specs/confluence-[PAGE_ID]/spec.md
./scripts/confluence-to-spec.sh \
  --url "https://company.atlassian.net/wiki/spaces/TECH/pages/123456/Feature"

# Custom location
./scripts/confluence-to-spec.sh \
  --page-id "123456" \
  --output "specs/001-my-feature/spec.md"
```

#### Parameters

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `--url` | Yes* | Confluence page URL | `https://domain.atlassian.net/wiki/...` |
| `--page-id` | Yes* | Confluence page ID | `123456` |
| `--output` | No | Custom output path | `specs/feature/spec.md` |

*Either `--url` or `--page-id` required

#### How It Works

1. **Fetches** Confluence page via REST API
2. **Extracts** metadata (title, author, labels, date, space, version)
3. **Converts** Confluence XHTML to clean markdown
4. **Generates** spec file with:
   - YAML front matter with Confluence metadata
   - Structured sections (Overview, Requirements, Technical Details)
   - Full content in markdown
   - Source link and generation date
5. **Creates** directory structure automatically
6. **Suggests** next steps (review, create tickets)

#### Generated Spec File Structure

```markdown
---
confluence_url: https://company.atlassian.net/wiki/spaces/TECH/pages/123456/
confluence_page_id: 123456
confluence_space: Engineering
author: John Doe
created_date: 2025-10-14
generated_date: 2025-10-14
labels: feature, backend, api
version: 3
---

# Feature Name

## Overview
[Extracted from Confluence]

## Requirements
[Extracted lists]

## Technical Details
[Extracted sections]

## Full Content
[Complete page content]

---
*Generated from Confluence on 2025-10-14*
*Source: [Feature Name](confluence-url)*
```

#### Examples

**Example 1: Default Location**
```bash
./scripts/confluence-to-spec.sh \
  --url "https://company.atlassian.net/wiki/spaces/TECH/pages/123456/Payment-Feature"

# Creates: specs/confluence-123456/spec.md
```

**Example 2: Custom Location**
```bash
./scripts/confluence-to-spec.sh \
  --page-id "123456" \
  --output "specs/001-payment-feature/spec.md"

# Creates: specs/001-payment-feature/spec.md
```

**Example 3: With Copilot**
```
You: "save this confluence page as a spec"
[Paste URL: https://company.atlassian.net/wiki/spaces/TECH/pages/123456/]

Copilot suggests:
./scripts/confluence-to-spec.sh \
  --url "https://company.atlassian.net/wiki/spaces/TECH/pages/123456/" \
  --output "specs/payment-feature/spec.md"
```

#### Output

```
✅ Fetched Confluence page: Payment Feature Implementation
📝 Converted to markdown (2,456 characters)
📁 Created: specs/001-payment-feature/spec.md
📊 Extracted:
   - Title: Payment Feature Implementation
   - Author: Jane Smith
   - Labels: payment, backend, stripe
   - Sections: 5
🔗 Confluence: https://company.atlassian.net/wiki/spaces/TECH/pages/123456/

💡 Next steps:
   - Review the spec file: specs/001-payment-feature/spec.md
   - Create JIRA tickets: ./scripts/jira-create.sh --file specs/001-payment-feature/spec.md
```

#### Use Cases

1. **Version Control**: Save Confluence docs in git for tracking changes
2. **Review & Edit**: Review content locally before creating tickets
3. **Collaboration**: Share specs via pull requests
4. **Batch Processing**: Save multiple pages, create tickets later
5. **Documentation**: Build spec library from Confluence

#### Configuration

Requires same Confluence setup as `confluence-to-jira.sh`:

```bash
# In .env
CONFLUENCE_BASE_URL=https://yourcompany.atlassian.net/wiki
JIRA_API_TOKEN=your_token  # Used for both JIRA and Confluence
```

#### Troubleshooting

| Issue | Solution |
|-------|----------|
| 403 Forbidden | Check API token has Confluence read permissions |
| 404 Not Found | Verify page ID is correct and page exists |
| Invalid URL | Use supported format with numeric page ID |
| Directory creation fails | Check write permissions for output path |

#### Workflow: Save Then Create

**Best practice for quality tickets**:

```bash
# 1. Save Confluence page as spec
./scripts/confluence-to-spec.sh \
  --url "https://company.atlassian.net/wiki/..." \
  --output "specs/feature/spec.md"

# 2. Review and edit spec file
vim specs/feature/spec.md

# 3. Commit to git for team review
git add specs/feature/spec.md
git commit -m "Add feature spec from Confluence"

# 4. Create JIRA tickets when ready
./scripts/jira-create.sh --file specs/feature/spec.md

# 5. Groom if needed
./scripts/jira-groom.sh PROJ-123
```

---

## Workflows

### Workflow 1: Feature Development

**Scenario**: You have a new feature to build

```bash
# 1. Create ticket from specification
./scripts/jira-create.sh \
  --summary "Add user notifications" \
  --description "Implement email and push notifications for user events" \
  --features "Email notifications,Push notifications,Notification preferences" \
  --priority "High"
# Output: Created PROJ-200

# 2. Start development
git checkout -b feature/PROJ-200-notifications

# 3. Groom ticket with acceptance criteria
./scripts/jira-groom.sh PROJ-200

# 4. Create PR with JIRA key in title
git commit -m "Add notification service"
gh pr create --title "PROJ-200: Add user notifications"

# 5. PR is merged → Sync updates ticket to Done
./scripts/jira-sync.sh
```

### Workflow 2: Bug Fix

**Scenario**: Quick bug fix

```bash
# 1. Create bug ticket
./scripts/jira-create.sh \
  --summary "Fix: Login button not responding on mobile" \
  --priority "High"
# Output: Created PROJ-201

# 2. Fix and create PR
git checkout -b fix/PROJ-201-login-button
# ... make changes ...
gh pr create --title "PROJ-201: Fix login button mobile responsiveness"

# 3. After merge, close ticket
./scripts/jira-close.sh PROJ-201
```

### Workflow 3: Batch Ticket Creation

**Scenario**: You have multiple specifications to convert

```bash
# Create tickets from multiple spec files
for spec in specs/*.md; do
    # Use Copilot to extract and create each ticket
    # Open in VS Code → Ask Copilot: "create jira ticket from this file"
done
```

### Workflow 4: Sprint Planning

**Scenario**: Preparing for sprint

```bash
# 1. Create all sprint tickets
./scripts/jira-create.sh --summary "Feature 1" --priority "High"
./scripts/jira-create.sh --summary "Feature 2" --priority "Medium"
./scripts/jira-create.sh --summary "Feature 3" --priority "Low"

# 2. Groom all tickets
./scripts/jira-groom.sh PROJ-210
./scripts/jira-groom.sh PROJ-211
./scripts/jira-groom.sh PROJ-212

# 3. During sprint, auto-sync daily
crontab -e
# Add: 0 9 * * * cd /path/to/jira-copilot-assistant && source .env && ./scripts/jira-sync.sh
```

### Workflow 5: Confluence to JIRA

**Scenario**: Requirements are documented in Confluence

```bash
# 1. Fetch Confluence page and create JIRA ticket
./scripts/confluence-to-jira.sh \
  --url "https://yourcompany.atlassian.net/wiki/spaces/TECH/pages/123456789/" \
  --project PROJ

# 2. Groom the created ticket
./scripts/jira-groom.sh PROJ-213

# 3. Link appears in both Confluence and JIRA
```

**With Copilot**:
1. Paste Confluence URL in VS Code chat
2. Say: "create jira ticket from this confluence page"
3. Copilot suggests the command
4. Review and run

### Workflow 6: Confluence → Spec → JIRA (Version-Controlled)

**Scenario**: You want to version-control Confluence content and review before creating tickets

```bash
# 1. Save Confluence page as spec
./scripts/confluence-to-spec.sh \
  --url "https://company.atlassian.net/wiki/spaces/TECH/pages/123456/" \
  --output "specs/api-redesign/spec.md"

# 2. Review the generated spec
cat specs/api-redesign/spec.md

# 3. Edit if needed
vim specs/api-redesign/spec.md

# 4. Commit to git (version control!)
git add specs/api-redesign/spec.md
git commit -m "Add API redesign spec from Confluence"
git push

# 5. Create JIRA ticket from reviewed spec
./scripts/jira-create.sh --file specs/api-redesign/spec.md

# 6. Groom the ticket
./scripts/jira-groom.sh PROJ-145
```

**Benefits**:
- ✅ Version control Confluence content
- ✅ Team review via pull requests
- ✅ Edit and refine before ticketing
- ✅ Build spec library from Confluence
- ✅ Decouple capture from ticket creation

**With Copilot**:
1. Paste Confluence URL in VS Code
2. Say: "save this confluence page as a spec"
3. Copilot suggests: `./scripts/confluence-to-spec.sh --url "..." --output "specs/..."`
4. Review spec file
5. Say: "create jira ticket from this file"
6. Copilot suggests: `./scripts/jira-create.sh --file specs/.../spec.md`

---

## GitHub Copilot Integration

### Two Integration Methods

**1. Prompt-Based (`.github/copilot-instructions.md`)** - Basic integration
- Copilot learns from instruction file
- Suggests bash commands
- Good for simple workflows

**2. MCP Integration (Model Context Protocol)** - Advanced automation ✨ NEW
- Direct tool integration with Copilot
- Natural language commands
- Structured tool definitions
- 100% feature coverage (23/23)
- **Recommended for production use**

📚 **MCP Setup**: [mcp-server/README.md](../mcp-server/README.md)

---

### Method 1: Prompt-Based Integration

The `.github/copilot-instructions.md` file teaches GitHub Copilot to:
1. Recognize JIRA-related requests
2. Extract information from specification files
3. Suggest appropriate commands
4. Provide helpful explanations

#### Using Copilot with Prompts

##### Create Ticket from Spec File

1. **Open specification file** (e.g., `feature-spec.md`)
2. **Ask Copilot** in VS Code:
   ```
   "create jira ticket from this file"
   ```
3. **Copilot suggests**:
   ```bash
   cd jira-copilot-assistant
   source .env
   ./scripts/jira-create.sh \
     --summary "Feature Title" \
     --description "..." \
     --features "..." \
     --priority "High"
   ```

##### Groom a Ticket

**Ask Copilot**:
```
"groom PROJ-123"
```

**Copilot suggests**:
```bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh PROJ-123
```

##### Close a Ticket

**Ask Copilot**:
```
"mark PROJ-123 as done"
```

**Copilot suggests**:
```bash
cd jira-copilot-assistant
source .env
./scripts/jira-close.sh PROJ-123
```

##### Sync Repositories

**Ask Copilot**:
```
"sync jira with github"
```

**Copilot suggests**:
```bash
cd jira-copilot-assistant
source .env
./scripts/jira-sync.sh
```

---

### Method 2: MCP Integration ✨ NEW

Model Context Protocol provides direct tool integration with GitHub Copilot.

#### Setup (One-Time)

```bash
cd mcp-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Add to VS Code `settings.json`:
```json
{
  "github.copilot.chat.tools": [
    {
      "name": "jira",
      "command": "/Users/yourname/projects/jira-copilot-assistant/mcp-server/venv/bin/python",
      "args": [
        "/Users/yourname/projects/jira-copilot-assistant/mcp-server/jira_bash_wrapper.py"
      ],
      "env": {
        "JIRA_BASE_URL": "https://yourcompany.atlassian.net",
        "JIRA_EMAIL": "your.email@company.com",
        "JIRA_API_TOKEN": "your_token"
      }
    }
  ]
}
```

📚 **Full setup guide**: [mcp-server/QUICK-START.md](../mcp-server/QUICK-START.md)

#### Using MCP with Copilot Chat

Once configured, use natural language:

##### Groom with AI Estimation
```
@jira groom ticket RVV-1171 with estimation using team scale
```

##### Create Ticket
```
@jira create a high priority bug for login failure
```

##### Search Tickets
```
@jira find all tickets related to Spring Boot upgrade
```

##### Fetch Confluence Page
```
@jira fetch confluence page https://company.atlassian.net/wiki/spaces/...
```

##### Close Ticket
```
@jira close ticket PROJ-123 with comment "Merged to production"
```

#### Available MCP Tools

| Tool | Description | Parameters |
|------|-------------|------------|
| `groom_ticket` | Enhance with AI | ticket_key, estimate, team_scale, ai_guide, reference_file, etc. (23 options) |
| `create_ticket` | Create new ticket | summary, description, type, priority, epic, features |
| `fetch_confluence_page` | Convert Confluence to spec | url, output_file |
| `find_related_tickets` | Search using JQL | query, epic, project, status |
| `close_ticket` | Close with summary | ticket_key, comment |
| `sync_to_confluence` | Sync to Confluence | ticket_key, page_id |

📚 **Full feature reference**: [mcp-server/FEATURE-COVERAGE.md](../mcp-server/FEATURE-COVERAGE.md)

---

### Copilot Trigger Phrases

#### Prompt-Based
| Command | Trigger Phrases |
|---------|----------------|
| Create | "create jira ticket", "make a jira issue", "add jira task" |
| Groom | "groom PROJ-123", "enhance ticket", "add criteria to PROJ-123" |
| Close | "close PROJ-123", "mark PROJ-123 done", "complete PROJ-123" |
| Sync | "sync jira", "sync with github", "update jira from github" |

#### MCP-Based ✨ NEW
| Command | Natural Language Examples |
|---------|--------------------------|
| Groom | "@jira groom RVV-1171 with AI estimation", "@jira enhance ticket with spec file" |
| Create | "@jira create bug for auth issue", "@jira new story for payment feature" |
| Search | "@jira find Spring Boot tickets", "@jira search epic RVV-100" |
| Fetch | "@jira get confluence page from URL", "@jira download spec" |
| Close | "@jira close PROJ-123", "@jira mark done with comment" |

---

## Best Practices

### 1. Ticket Creation

✅ **Do**:
- Use clear, action-oriented summaries
- Provide detailed descriptions
- Include all known features/requirements
- Set appropriate priority

❌ **Don't**:
- Create vague tickets ("Fix stuff")
- Skip descriptions for complex features
- Assume priority (always set it)

### 2. Ticket Grooming

✅ **Do**:
- Groom tickets before sprint planning
- Review generated criteria for accuracy
- Add additional context manually if needed
- Re-groom if requirements change

❌ **Don't**:
- Skip grooming for complex features
- Accept generated criteria without review
- Groom tickets that are already in progress

### 3. GitHub Integration

✅ **Do**:
- Always include JIRA keys in PR titles
- Use consistent format: `PROJ-123: Description`
- Run sync daily or after merging PRs
- Verify sync results periodically

❌ **Don't**:
- Forget JIRA keys in PR titles
- Use lowercase keys (use `PROJ-123`, not `proj-123`)
- Rely solely on sync (manual updates sometimes needed)

### 4. Automation

✅ **Do**:
- Set up cron jobs for daily sync
- Use Copilot for batch operations
- Create reusable templates for common tickets
- Document custom workflows

❌ **Don't**:
- Run sync too frequently (API rate limits)
- Automate without monitoring
- Skip manual verification

---

## Examples

### Example 1: Full Feature Lifecycle

```bash
# Create feature ticket
./scripts/jira-create.sh \
  --summary "User Authentication System" \
  --description "Implement secure user authentication with OAuth2" \
  --features "OAuth2 integration,Social login (Google, GitHub),2FA support,Session management" \
  --priority "High"
# Created: PROJ-300

# Add acceptance criteria
./scripts/jira-groom.sh PROJ-300
# Added 5 criteria based on features

# Develop feature
git checkout -b feature/PROJ-300-auth
# ... development work ...
git commit -m "Implement OAuth2 authentication"
gh pr create --title "PROJ-300: User Authentication System"

# Merge PR
gh pr merge 123 --squash

# Sync updates ticket automatically
./scripts/jira-sync.sh
# PROJ-300 → Done

# Or close manually with summary
./scripts/jira-close.sh PROJ-300
```

### Example 2: Bug Triage

```bash
# Create high-priority bug
./scripts/jira-create.sh \
  --summary "CRITICAL: Database connection timeout" \
  --description "Users experiencing timeouts during peak hours" \
  --priority "High"
# Created: PROJ-301

# Quick fix and close
git checkout -b hotfix/PROJ-301
# ... fix ...
git commit -m "Increase connection pool size"
gh pr create --title "PROJ-301: Fix database timeout"
gh pr merge 124 --squash

./scripts/jira-close.sh PROJ-301
```

### Example 3: Sprint Planning

```bash
# Batch create sprint tickets
cat sprint-items.txt | while read summary; do
    ./scripts/jira-create.sh --summary "$summary" --priority "Medium"
done

# Groom all tickets
jira list --sprint "Sprint 10" | while read key; do
    ./scripts/jira-groom.sh "$key"
done
```

---

## Advanced Usage

### Debug Mode

Enable detailed logging:

```bash
DEBUG=true ./scripts/jira-create.sh --summary "Test"
```

Output includes:
- API request details
- Response bodies
- Variable values
- Execution flow

### Custom Priority Mapping

Edit `scripts/lib/utils.sh` to customize priority detection:

```bash
detect_priority() {
    local text="$1"
    
    # Add custom keywords
    if echo "$text" | grep -qi "urgent\|critical\|blocker\|ASAP"; then
        echo "High"
    elif echo "$text" | grep -qi "nice to have\|future\|someday"; then
        echo "Low"
    else
        echo "Medium"
    fi
}
```

### Batch Operations

```bash
# Close multiple tickets
for ticket in PROJ-{200..210}; do
    ./scripts/jira-close.sh "$ticket"
done

# Groom all tickets in a file
cat tickets.txt | xargs -I {} ./scripts/jira-groom.sh {}
```

---

## Tips & Tricks

1. **Alias commands** for quick access:
   ```bash
   # Add to ~/.zshrc or ~/.bashrc
   alias jc='cd ~/jira-copilot-assistant && source .env && ./scripts/jira-create.sh'
   alias jg='cd ~/jira-copilot-assistant && source .env && ./scripts/jira-groom.sh'
   alias jclose='cd ~/jira-copilot-assistant && source .env && ./scripts/jira-close.sh'
   alias jsync='cd ~/jira-copilot-assistant && source .env && ./scripts/jira-sync.sh'
   ```

2. **Use with Git hooks**:
   ```bash
   # .git/hooks/post-merge
   #!/bin/bash
   cd ~/jira-copilot-assistant
   source .env
   ./scripts/jira-sync.sh
   ```

3. **Integrate with CI/CD**:
   ```yaml
   # .github/workflows/jira-sync.yml
   on:
     pull_request:
       types: [closed]
   jobs:
     sync:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v2
         - name: Sync JIRA
           run: ./scripts/jira-sync.sh
   ```

---

## Next Steps

- **Troubleshooting**: See [troubleshooting.md](troubleshooting.md)
- **Setup**: See [setup-guide.md](setup-guide.md)
- **Contribute**: Submit issues or PRs on GitHub
- **Customize**: Modify scripts for your workflow

---

**Happy automating!** 🚀
