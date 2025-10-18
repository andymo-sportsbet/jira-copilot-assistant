# JIRA Copilot Assistant

> 🤖 **Automate JIRA workflows with GitHub Copilot and shell scripts**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-3.2+-green.svg)](https://www.gnu.org/software/bash/)
[![JIRA API](https://img.shields.io/badge/JIRA%20API-v3-blue.svg)](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)

**Stop context-switching between VS Code and JIRA.** Create, enhance, and manage JIRA tickets directly from your editor using GitHub Copilot's natural language understanding and simple shell scripts.

---

## 🆕 What's New (October 2025)

### ✨ Major Updates

- **🔌 Model Context Protocol (MCP) Integration** - AI-powered workflow automation ✨ NEW
  - Local MCP server wrapping all bash scripts
  - Direct integration with GitHub Copilot in VS Code
  - 6 MCP tools: groom_ticket, create_ticket, fetch_confluence_page, find_related_tickets, close_ticket, sync_to_confluence
  - 100% feature coverage (23/23 bash script features)
  - No code rewrite needed - thin wrapper architecture
  - Setup guide: [mcp-server/README.md](mcp-server/README.md)

- **📊 AI Story Point Estimation** - Smart estimation with team-specific scales ✨ NEW
  - Dual estimation: Fibonacci (1, 2, 3, 5, 8...) or Team scale (0.5, 1, 2, 3, 4, 5)
  - Interactive prompts: Accept / Override / Skip
  - Detailed reasoning breakdown (base + complexity + uncertainty + testing)
  - Auto-warns on large stories (4-5 points)
  - Formula: 1 Story Point = 7 Focus Hours (team scale)
  - Library: `scripts/lib/jira-estimate-team.sh`

- **�🔍 JIRA Search Library** - Reusable functions for finding related tickets using JQL
  - CLI tool: `find-related-tickets.sh` for easy ticket searches
  - Library: `scripts/lib/jira-search.sh` for custom scripts
  - Supports epic-based search, text search, and custom filters
  - Fixed JIRA API v3 endpoint (`/search/jql`)

- **🎨 Rich Formatting with JIRA ADF** - Professional ticket formatting
  - Visual hierarchy with H2/H3 headings and emojis
  - Bullet lists, bold text, horizontal rules
  - Smart content markers (⚡ COPILOT_GENERATED_START/END ⚡)
  - Library: `scripts/lib/jira-format.sh` with `markdown_to_jira_adf()` function

- **📝 AI-Generated Descriptions** - Comprehensive ticket descriptions
  - `--ai-description` flag for enhanced grooming
  - Templates for tech-debt, features, and bugs
  - Business-focused language with technical context
  - Preserves manual edits while replacing AI content

- **📚 Complete Documentation** - All features documented
  - [JIRA Search Library Guide](docs/jira-search-library.md) - Complete search API reference
  - [JIRA ADF Formatting Guide](docs/jira-adf-formatting.md) - Formatting examples
  - [Auto-Description Guide](docs/auto-description-guide.md) - AI workflow

### 🔧 Improvements

- Fixed literal `\n\n` in JIRA descriptions (changed to `$'\n\n'`)
- Support for both `JIRA_TOKEN` and `JIRA_API_TOKEN` environment variables
- Removed problematic `set -euo pipefail` from library files
- Updated all scripts to use JIRA API v3
- Better error handling in search functions

### 📊 Recent Success Story

**Batch Grooming**: Successfully groomed 5 Spring Boot upgrade tickets (RVV-1171, 1174, 1175, 1176, 1177) with full AI-generated descriptions in minutes. Each ticket received:
- 7 formatted headings with emojis
- 35-39 paragraphs of comprehensive content
- 58-62 ADF sections with proper structure
- 5 acceptance criteria

See: [SPRING-BOOT-GROOMING-COMPLETE.md](SPRING-BOOT-GROOMING-COMPLETE.md)

---

## ✨ Features

| Feature | Description | Command |
|---------|-------------|---------|
| � **MCP Integration** | AI-powered automation with GitHub Copilot | `mcp-server/` ✨ NEW |
| �📝 **Create Tickets** | Extract from spec files with AI + rich formatting | `jira-create.sh` |
| 🔄 **Groom Tickets** | Add acceptance criteria + GitHub context + AI descriptions | `jira-groom.sh` |
| 📊 **Story Point Estimation** | AI-powered estimation (Fibonacci or team scale) ✨ NEW | `jira-groom.sh --estimate` |
| ✅ **Close Tickets** | Auto-generate completion summaries | `jira-close.sh` |
| 🔗 **Sync with GitHub** | Keep JIRA updated with PR status | `jira-sync.sh` |
| 📄 **Confluence → JIRA** | Create tickets from Confluence pages | `confluence-to-jira.sh` |
| 💾 **Confluence → Spec** | Save Confluence as spec file | `confluence-to-spec.sh` |
| 🔍 **Search Tickets** | Find related tickets using JQL queries | `find-related-tickets.sh` ✨ NEW |
| 🎨 **Rich Formatting** | JIRA ADF with headings, lists, emojis | `jira-format.sh` ✨ NEW |

---

## 🚀 Quick Start

### Prerequisites

```bash
# Install dependencies (macOS)
brew install jq

# Optional: GitHub CLI for sync features
brew install gh && gh auth login
```

### Installation

```bash
# 1. Clone repository
git clone https://github.com/yourorg/jira-copilot-assistant.git
cd jira-copilot-assistant

# 2. Set up environment
cp .env.example .env
nano .env  # Add your JIRA credentials

# 3. Make scripts executable
chmod +x scripts/*.sh scripts/lib/*.sh

# 4. (Optional) Set up MCP server for GitHub Copilot integration
cd mcp-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# Add to VS Code settings.json (see mcp-server/README.md)

# 5. Test setup
cd ..
source .env
./scripts/jira-create.sh --summary "Test Setup" --priority "Low"
```

### Configuration

Edit `.env` with your credentials:

```bash
# JIRA Configuration
JIRA_BASE_URL="https://yourcompany.atlassian.net"
JIRA_EMAIL="your.email@company.com"
JIRA_API_TOKEN="your_jira_api_token_here"
JIRA_PROJECT="PROJ"

# GitHub Configuration (Optional - for sync)
GITHUB_TOKEN="your_github_token_here"
GITHUB_ORG="your-github-org"
```

📚 **Full setup instructions**: [docs/setup-guide.md](docs/setup-guide.md)

---

## 📖 Usage Examples

### 1. Create JIRA Ticket

```bash
source .env
./scripts/jira-create.sh \
  --summary "Mobile App Payment Feature" \
  --description "Add in-app payment functionality using Stripe" \
  --features "Stripe SDK,Apple Pay,Google Pay,Receipt generation" \
  --priority "High"
```

**Output:**
```
✅ Created: PROJ-123
ℹ️  Summary: Mobile App Payment Feature
ℹ️  Priority: High
🔗 https://yourcompany.atlassian.net/browse/PROJ-123
```

### 2. Groom Ticket with AI

```bash
# Basic grooming (acceptance criteria + GitHub context)
./scripts/jira-groom.sh PROJ-123

# With AI-generated description
./scripts/jira-groom.sh PROJ-123 --ai-description

# Interactive AI story point estimation (Fibonacci)
./scripts/jira-groom.sh PROJ-123 --estimate

# Team-specific estimation (0.5, 1, 2, 3, 4, 5)
./scripts/jira-groom.sh PROJ-123 --estimate --team-scale

# Auto-accept AI estimation (for CI/CD)
./scripts/jira-groom.sh PROJ-123 --estimate --auto-estimate

# Manually set story points
./scripts/jira-groom.sh PROJ-123 --points 3
```

**What it does:**
- ✅ Searches GitHub for related PRs/commits
- ✅ Generates acceptance criteria
- ✅ AI story point estimation with reasoning ✨ NEW
- ✅ Updates ticket with story points ✨ NEW
- ✅ Warns on large stories (4-5 points) ✨ NEW

**Estimation Output Example:**
```
📊 AI Story Point Estimation

🔍 Analysis:
Base: 1 point (new feature/story)
Complexity: +1 (moderate - database/API)
Testing: +0.5 (unit tests)
Total: 2 points (~14 focus hours)

Confidence: high

**Team Estimate: 2 Story Points** (~14 focus hours / ~2 days)

Would you like to update the ticket with 2 story points?
  [a] Accept AI estimation (2 points)
  [o] Override with custom value
  [s] Skip (don't update story points)
```

### 3. Use MCP with GitHub Copilot (AI-Powered) ✨ NEW

Once MCP server is set up, use natural language with GitHub Copilot Chat:

```
@jira groom ticket RVV-1171 with AI description and estimation
```

```
@jira create a ticket for Spring Boot 3 upgrade with high priority
```

```
@jira find all tickets related to authentication
```

**Available MCP Tools:**
- `groom_ticket` - Enhance tickets with AI (all 23 grooming features)
- `create_ticket` - Create new tickets
- `fetch_confluence_page` - Convert Confluence to spec files
- `find_related_tickets` - Search using JQL
- `close_ticket` - Close with summary
- `sync_to_confluence` - Sync ticket to Confluence

See: [mcp-server/QUICK-START.md](mcp-server/QUICK-START.md)

### 4. Close Ticket

```bash
./scripts/jira-close.sh PROJ-123

```bash
# Sync all repositories
./scripts/jira-sync.sh

# Sync specific repository
./scripts/jira-sync.sh --repo "backend-api"
```

**What it does:**
- ✅ Scans recent PRs for JIRA keys
- ✅ Updates ticket status based on PR state:
  - Open PR → "In Progress"
  - Merged PR → "Done"

**Output:**
```
✅ Sync complete!
ℹ️  Scanned: 4 repositories
ℹ️  Updated: 2 tickets
ℹ️  Errors: 0
```

### 5. Create from Confluence Page

```bash
# From Confluence URL
./scripts/confluence-to-jira.sh \
  --url "https://yourcompany.atlassian.net/wiki/spaces/TECH/pages/123456789/" \
  --project PROJ

# With page ID directly
./scripts/confluence-to-jira.sh \
  --page-id "123456789" \
  --project PROJ \
  --priority High
```

**What it does:**
- ✅ Fetches Confluence page content via REST API
- ✅ Extracts title → JIRA summary
- ✅ Extracts "Overview" or first paragraph → JIRA description
- ✅ Extracts lists → Requirements/features
- ✅ Creates JIRA ticket with link back to Confluence

**Output:**
```
✅ Fetched Confluence page: DM Adapters Springboot Upgrade
📝 Extracted:
   - Title: DM Adapters Springboot Upgrade
   - Description: 250 characters
   - Requirements: 5 items
   - Priority: High
✅ Created: PROJ-88
🔗 JIRA: https://yourcompany.atlassian.net/browse/PROJ-88
🔗 Confluence: https://yourcompany.atlassian.net/wiki/...
```

### 6. Save Confluence as Spec File

```bash
# Save Confluence page for version control
./scripts/confluence-to-spec.sh \
  --url "https://yourcompany.atlassian.net/wiki/spaces/TECH/pages/123456/" \
  --output "specs/001-my-feature/spec.md"

# Or use page ID
./scripts/confluence-to-spec.sh \
  --page-id "123456" \
  --output "specs/feature/spec.md"
```

**What it does:**
- ✅ Fetches Confluence page via REST API
- ✅ Extracts full metadata (title, author, labels, date, space, version)
- ✅ Converts content to clean markdown
- ✅ Generates spec file with YAML front matter
- ✅ Auto-creates directory structure
- ✅ Provides next steps

**Output:**
```
✅ Fetched Confluence page: API Redesign Specification
📝 Converted to markdown (2,456 characters)
📁 Created: specs/001-api-redesign/spec.md
📊 Extracted:
   - Title: API Redesign Specification
   - Author: Jane Smith
   - Labels: api, backend, v2
   - Sections: 5
🔗 Confluence: https://yourcompany.atlassian.net/wiki/...

💡 Next steps:
   - Review: specs/001-api-redesign/spec.md
   - Create tickets: ./scripts/jira-create.sh --file specs/001-api-redesign/spec.md
```

**Workflow: Save → Review → Create**
```bash
# 1. Save Confluence as spec
./scripts/confluence-to-spec.sh --url "..." --output "specs/feature/spec.md"

# 2. Review and edit
vim specs/feature/spec.md

# 3. Create JIRA tickets
./scripts/jira-create.sh --file specs/feature/spec.md
```

### 7. Search for Related Tickets ✨ NEW

```bash
# Find all tickets under an epic
./scripts/find-related-tickets.sh -e RVV-1178

# Find Spring Boot tickets
./scripts/find-related-tickets.sh -p RVV -t "spring boot upgrade"

# Find and save to file
./scripts/find-related-tickets.sh -e RVV-1178 -f 'AND text ~ "spring boot"' -o .temp/tickets.txt

# Use in scripts
source scripts/lib/jira-search.sh
results=$(jira_search_by_epic "RVV-1178" 'AND text ~ "spring boot"')
jira_extract_summaries "$results"
```

**What it does:**
- ✅ Search tickets using JQL (JIRA Query Language)
- ✅ Find tickets by epic, text, or custom filters
- ✅ Export ticket keys to files for batch processing
- ✅ Reusable library functions for custom scripts
- ✅ Uses JIRA API v3 (`/search/jql` endpoint)

**Output:**
```
ℹ️  Epic: RVV-1178
ℹ️  Epic Summary: Racing Feeds - Core Framework Upgrades

ℹ️  Found 5 tickets:

RVV-1171: [Betmaker Feed Ingestor] Spring boot upgrade
RVV-1174: [Betmaker Feed Adapter] Spring boot upgrade
RVV-1175: [AAP Connector] Spring boot upgrade
RVV-1176: [R&S Connector] Spring boot upgrade
RVV-1177: [RAMP2] Spring boot upgrade

✅ Ticket keys saved to: .temp/tickets.txt
```

### 8. Enhanced Formatting with JIRA ADF ✨ NEW

All tickets now feature **rich visual formatting** using JIRA's Atlassian Document Format (ADF):

```bash
# Create ticket with rich formatting
./scripts/jira-create.sh --summary "My Feature" --description "Description with **bold** text"

# Groom ticket with AI-generated description
./scripts/jira-groom.sh PROJ-123 --ai-description .temp/description.txt
```

**What you get:**
- ✅ **Visual Hierarchy**: H2 and H3 headings with emojis (🚀 📋 🎯 💼 ⚠️ 🔗 ✅)
- ✅ **Bullet Lists**: Properly formatted lists with `•` markers
- ✅ **Emphasis**: Bold, italic, and code formatting
- ✅ **Horizontal Rules**: Section separators with `---`
- ✅ **Smart Markers**: ⚡ COPILOT_GENERATED_START/END ⚡ for content tracking
- ✅ **Professional Look**: Engaging yet professional ticket descriptions

**Before (plain text):**
```
Description

Background
The service needs upgrading.

Scope
- Item 1
- Item 2
```

**After (rich ADF formatting):**
```
🚀 Platform Modernization: Service Upgrade

Brief overview with business impact.

---

📋 Background

Current Situation:
The service currently runs on outdated versions.

✅ What's Included:
• Upgrade to latest framework
• Validate functionality
```

### 9. AI-Generated Descriptions ✨ NEW

Generate comprehensive ticket descriptions using AI templates:

```bash
# Generate and apply AI description
./scripts/jira-groom.sh PROJ-123 --ai-description .temp/my-description.txt
```

**Description template structure:**
- 🚀 **Platform Modernization Title** - Business-focused overview
- 📋 **Background** - Current situation, why it matters, risks
- 🎯 **Scope** - What's included/excluded
- 📦 **Key Deliverables** - Specific outcomes
- 💼 **Impact & Value** - Who benefits, business value
- ⚠️ **Risks** - What happens if not done
- 🔗 **Dependencies** - Requirements and impacts
- ✅ **Success Criteria** - Measurable outcomes

**See templates:**
- `.prompts/generate-description-tech-debt.md` - Technical debt tickets
- `.prompts/generate-description-feature.md` - Feature tickets
- `.prompts/generate-description-bug.md` - Bug fix tickets

### 10. AI-Generated Technical Guide

```bash
# Enable LLM generation (in .env file)
USE_LLM_GENERATION=true  # Uses AI to generate content from spec
# or
USE_LLM_GENERATION=false # Uses static template (default)

# Groom ticket with AI-generated technical implementation guide
./scripts/jira-groom.sh PROJ-123 --reference-file specs/feature/spec.md
```

**What it does:**
- ✅ Reads the spec file and analyzes content
- 🤖 **AI Mode**: Uses OpenAI GPT-4 to generate intelligent, context-aware technical guide
- 📋 **Template Mode**: Uses pre-defined template (faster, no API costs)
- ✅ Generates JIRA Atlassian Document Format (ADF) JSON
- ✅ Creates comprehensive technical guide with:
  - 📎 Clickable links to Confluence documentation
  - 📋 Core upgrade requirements (extracted from spec)
  - 🔧 Key libraries and dependencies  
  - 💻 Required code changes
  - ⚠️ Common issues and solutions
  - ⚙️ Configuration updates
- ✅ Adds as formatted JIRA comment with proper headings, bullets, and emphasis
- ✅ Updates description with AI-generated acceptance criteria

**AI-Powered Ticket Enhancement (Recommended):**

Use Claude/Copilot in VS Code to generate intelligent, professional ticket content:

1. **Find the right template for your issue type:**
   ```bash
   # Auto-select template based on JIRA issue type
   ./scripts/get-description-template.sh RVV-1171
   ```
   
   Available templates:
   - 🎯 **Story/Feature** - User value, capabilities, business outcomes
   - 🔴 **Bug** - Impact, reproduction steps, urgency  
   - 🔍 **Spike/Research** - Research questions, unknowns, decisions
   - 🔧 **Tech Debt/Task** - ROI, modernization, business benefits
   - 📋 **Default** - Generic structure for other types

2. **Ask the AI agent:**
   ```
   Read specs/dm-adapater-springboot3/spec.md and generate:
   1. Enhanced description using .prompts/generate-description-tech-debt.md → .temp/description.txt
   2. Technical guide using .prompts/generate-technical-guide.md → .temp/guide.json
   ```

3. **Review and apply:**
   ```bash
   # Full AI enhancement (description + technical guide)
   ./scripts/jira-groom.sh RVV-1171 \
     --ai-description .temp/description.txt \
     --ai-guide .temp/guide.json
   
   # Or just add technical guide
   ./scripts/jira-groom.sh RVV-1171 --ai-guide .temp/guide.json
   ```

**Benefits:**
- 🤖 **No API costs** - Uses your existing Claude/Copilot subscription
- 🎯 **Better context** - AI has full workspace context
- ✏️ **Review before sending** - You can edit content before posting
- 🚀 **Faster** - No network calls during grooming
- 📝 **Professional** - Consistent, well-structured content

**Alternative: Template-based (Simple, no AI):**

```bash
./scripts/jira-groom.sh RVV-1177 --reference-file specs/betmaker-ingestor-springboot3/spec.md
```

**Alternative: OpenAI API (Automated, costs money):**

```bash
# In .env file
USE_LLM_GENERATION=true
OPENAI_API_KEY=sk-...  # Get from https://platform.openai.com/api-keys
```

**Cost:** ~$0.01-0.05 per ticket (using GPT-4)

**Output with AI guide:**
```
ℹ️  Fetching ticket details for PROJ-123...
ℹ️  Ticket: Spring Boot 3 Upgrade
📄 Extracting technical details from: spec.md
🤖 Generating technical guide using LLM...
ℹ️  Generating acceptance criteria...
ℹ️  Updating ticket description...
ℹ️  Adding technical implementation guide...
✅ Groomed: PROJ-123
✅ Added 5 acceptance criteria
✅ Added AI-generated technical guide from: spec.md
🔗 https://yourcompany.atlassian.net/browse/PROJ-123
```

**Complete workflow: Confluence → Spec → AI-Groomed Ticket**
```bash
# 1. Save Confluence page as spec
./scripts/confluence-to-spec.sh \
  --url "https://company.atlassian.net/wiki/spaces/TEAM/pages/123456/" \
  --output "specs/upgrade/spec.md"

# 2. Review the spec
cat specs/upgrade/spec.md

# 3. Enable LLM (one-time setup)
echo "USE_LLM_GENERATION=true" >> .env

# 4. Groom ticket with AI technical guide
./scripts/jira-groom.sh PROJ-123 --reference-file specs/upgrade/spec.md
```

**Result:** 
- 🎯 **AI-powered**: Content adapts to your specific spec, extracts actual versions, libraries, and issues
- ✨ **Smart formatting**: Professional JIRA formatting with headings, links, bullet lists, and code snippets
- 🔄 **Fallback safety**: If LLM fails, automatically falls back to template mode
- 💰 **Cost-effective**: OpenAI GPT-4 costs ~$0.01-0.05 per ticket

---

## 🤖 GitHub Copilot Integration

**The magic happens here!** GitHub Copilot reads `.github/copilot-instructions.md` and suggests commands based on your current file.

### How to Use

1. **Open a specification file** (e.g., `feature-spec.md`)
2. **Ask Copilot** in VS Code:
   ```
   "create jira ticket from this file"
   ```
3. **Copilot extracts data** and suggests:
   ```bash
   cd jira-copilot-assistant
   source .env
   ./scripts/jira-create.sh \
     --summary "Feature Title from # Heading" \
     --description "Description from ## Description section" \
     --features "Feature 1,Feature 2,Feature 3" \
     --priority "High"
   ```
4. **Review and run** the suggested command

### Copilot Trigger Phrases

| What You Say | What Copilot Does |
|--------------|-------------------|
| "create jira ticket from this file" | Extracts spec data → suggests create command |
| "groom PROJ-123" | Suggests groom command for ticket |
| "close PROJ-456" | Suggests close command |
| "sync jira with github" | Suggests sync command |
| "create jira from this confluence page" | Detects Confluence URL → suggests confluence-to-jira command |

📚 **Full Copilot guide**: [.github/copilot-instructions.md](.github/copilot-instructions.md)

---

## 📁 Project Structure

```
jira-copilot-assistant/
├── .github/
│   └── copilot-instructions.md    # ✅ Copilot training (800+ lines)
├── scripts/
│   ├── jira-create.sh             # ✅ Create tickets
│   ├── jira-close.sh              # ✅ Close tickets
│   ├── jira-groom.sh              # ✅ Enhance tickets
│   ├── jira-sync.sh               # ✅ Sync with GitHub
│   ├── confluence-to-jira.sh      # ✅ Create from Confluence
│   ├── confluence-to-spec.sh      # ✅ Save Confluence as spec
│   └── lib/
│       ├── jira-api.sh            # ✅ JIRA REST API v3
│       ├── github-api.sh          # ✅ GitHub API + gh CLI
│       ├── confluence-api.sh      # ✅ Confluence REST API
│       └── utils.sh               # ✅ Utilities & output
├── docs/
│   ├── setup-guide.md             # ✅ Complete setup instructions
│   ├── onboard/user-guide.md      # ✅ Usage examples & workflows
│   └── troubleshooting.md         # ✅ Common issues & solutions
├── .env.example                   # Environment template
├── README.md                      # This file
└── PROGRESS.md                    # Development tracker
```

---

## 📚 Documentation

### Core Guides

| Document | Description |
|----------|-------------|
| **[Setup Guide](docs/setup-guide.md)** | Installation, prerequisites, configuration |
| **[User Guide](docs/onboard/user-guide.md)** | Commands, workflows, examples, best practices |
| **[Troubleshooting](docs/troubleshooting.md)** | Common errors, solutions, FAQ |
| **[Copilot Instructions](.github/copilot-instructions.md)** | How Copilot suggests commands |

### New Features ✨

| Document | Description |
|----------|-------------|
| **[JIRA Search Library](docs/jira-search-library.md)** | Complete search API reference, JQL examples, integration guides |
| **[JIRA ADF Formatting](docs/jira-adf-formatting.md)** | Formatting guide with headings, lists, emphasis |
| **[Auto-Description Guide](docs/auto-description-guide.md)** | AI description workflow and templates |
| **[Search Library Quick Reference](JIRA-SEARCH-LIBRARY.md)** | Quick start for search library |
| **[Formatting Summary](docs/formatting-improvements-summary.md)** | Technical details on ADF implementation |

### Success Stories

| Document | Description |
|----------|-------------|
| **[Spring Boot Grooming Complete](SPRING-BOOT-GROOMING-COMPLETE.md)** | Batch grooming 5 tickets with AI descriptions |
| **[Search Library Success](SEARCH-LIBRARY-SUCCESS.md)** | Creating reusable search functionality |

### Library Files

| Library | Description | Functions |
|---------|-------------|-----------|
| **[jira-api.sh](scripts/lib/jira-api.sh)** | Core JIRA REST API | `jira_get_issue()`, `jira_update_issue()`, etc. |
| **[jira-search.sh](scripts/lib/jira-search.sh)** ✨ NEW | JIRA search functions | `jira_search()`, `jira_search_by_epic()`, `jira_extract_keys()` |
| **[jira-format.sh](scripts/lib/jira-format.sh)** ✨ NEW | ADF formatting | `markdown_to_jira_adf()` |
| **[github-api.sh](scripts/lib/github-api.sh)** | GitHub REST API | `github_list_prs()`, `github_get_commits()` |
| **[utils.sh](scripts/lib/utils.sh)** | Utilities | `success()`, `error()`, `validate_ticket_key()` |

---

## 🎯 Project Status

### ✅ Epic 1: Core Shell Scripts (8 SP) - COMPLETE

- [x] Project structure and setup
- [x] JIRA API library (Basic Auth, Bash 3.2 compatible)
- [x] GitHub API library (Optional GitHub integration)
- [x] Utility library (Colored output, validation)
- [x] **jira-create.sh** - Create tickets ✅ Tested
- [x] **jira-close.sh** - Close tickets ✅ Tested
- [x] **jira-groom.sh** - Enhance tickets ✅ Tested
- [x] **jira-sync.sh** - GitHub sync ✅ Tested

### ✅ Epic 2: Copilot Instructions (4 SP) - COMPLETE

- [x] **Copilot instructions** (517 lines) ✅ Complete
- [x] **Test specifications** ✅ Validated

### 🚧 Epic 3: Documentation & Launch (3 SP) - IN PROGRESS

- [x] **docs/setup-guide.md** ✅ Complete
- [x] **docs/onboard/user-guide.md** ✅ Complete
- [x] **docs/troubleshooting.md** ✅ Complete
- [ ] Demo video script
- [ ] Team training materials
- [ ] Feedback mechanism

**Overall Progress**: 12/15 SP (80% complete)

---

## � Workflows

### Workflow 1: Feature Development

```bash
# 1. Create ticket from spec
./scripts/jira-create.sh \
  --summary "User Notifications" \
  --features "Email,Push,SMS" \
  --priority "High"
# → PROJ-200

# 2. Groom with criteria
./scripts/jira-groom.sh PROJ-200

# 3. Develop & create PR
git checkout -b feature/PROJ-200
# ... code ...
gh pr create --title "PROJ-200: Add notifications"

# 4. Auto-sync updates ticket
./scripts/jira-sync.sh
# → PROJ-200 moves to "In Progress" (PR open) or "Done" (PR merged)
```

### Workflow 2: Batch Ticket Creation

```bash
# Create multiple tickets from specs
for spec in specs/*.md; do
    # Open in VS Code, ask Copilot:
    # "create jira ticket from this file"
done
```

---

## 🛠️ Development & Testing

### Debug Mode

```bash
# Enable detailed logging
DEBUG=true ./scripts/jira-create.sh --summary "Test"
```

### Manual Testing

```bash
# Test JIRA connection
source .env
curl -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  "${JIRA_BASE_URL}/rest/api/3/myself"

# Test create
./scripts/jira-create.sh --summary "Test" --priority "Low"

# Test groom (use real ticket)
./scripts/jira-groom.sh PROJ-123

# Test close
./scripts/jira-close.sh PROJ-123

# Test sync
./scripts/jira-sync.sh
```

### Automation with Cron

```bash
# Add daily sync at 9 AM
crontab -e
# Add: 0 9 * * * cd /path/to/jira-copilot-assistant && source .env && ./scripts/jira-sync.sh
```

---

## 📊 Project Status

| Epic | Story Points | Status |
|------|--------------|--------|
| Epic 1: Core Scripts | 8 SP | ✅ Complete |
| Epic 2: Copilot Instructions | 4 SP | ✅ Complete |
| Epic 3: Documentation | 3 SP | ✅ Complete |
| Epic 4: Confluence Integration | 5 SP | 🚧 Ready to Start |
| **Total** | **20 SP** | **75% Complete** |

**See**: [EPIC4-PLAN.md](EPIC4-PLAN.md) for Confluence integration details

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

See the full specification: `/specs/008-copilot-jira-agent/`

---

## � Troubleshooting

**Common Issues:**

| Issue | Solution |
|-------|----------|
| `jq: command not found` | `brew install jq` |
| `401 Unauthorized` | Verify JIRA_API_TOKEN in `.env` |
| `Permission denied` | `chmod +x scripts/*.sh` |
| Copilot not suggesting | Ensure `.github/copilot-instructions.md` exists |

📚 **Full troubleshooting guide**: [docs/troubleshooting.md](docs/troubleshooting.md)

---

## 📝 License

MIT License - See LICENSE file for details

---

## 🎉 Acknowledgments

- Built with **GitHub Copilot** assistance
- Uses **JIRA REST API v3**
- Powered by **Bash 3.2+** (macOS compatible)
- Optional **GitHub CLI** integration

---

**Stop context-switching. Start automating.** 🚀

Built with ❤️ for developers who love the terminal
Test auto-approve run Sat Oct 18 03:07:12 UTC 2025
