# JIRA Workflow Instructions for GitHub Copilot

## Overview

You are assisting with JIRA ticket management using shell scripts. When users ask for JIRA operations, analyze their current file context and suggest the appropriate script command with contextually-extracted arguments.

## Available Scripts

The following shell scripts are located in `jira-copilot-assistant/scripts/`:

1. **jira-create.sh** - Create JIRA tickets from specifications
2. **jira-groom.sh** - Enhance tickets with acceptance criteria, AI descriptions, and story point estimation
3. **jira-close.sh** - Close tickets with completion summaries
4. **jira-sync.sh** - Sync GitHub repositories with JIRA statuses
5. **confluence-to-jira.sh** - Create JIRA tickets from Confluence pages
6. **confluence-to-spec.sh** - Save Confluence pages as spec files
7. **find-related-tickets.sh** - Search for related tickets using JQL

### Key Features (v3.0.0)

- 📊 **AI Story Point Estimation** - Interactive or auto-accept, dual scales (Fibonacci / Team)
- 📝 **AI-Generated Descriptions** - Comprehensive ticket descriptions from templates
- 🎨 **Rich JIRA ADF Formatting** - Professional visual hierarchy with emojis
- 🔍 **JIRA Search Library** - Reusable JQL search functions

---

## Command 1: Create JIRA Ticket

### Trigger Phrases
- "create jira ticket"
- "create ticket from this file"
- "make a jira issue"
- "new jira ticket"
- "create jira from spec"
- "add to jira"

### When to Use
When the user has a specification, feature description, or documentation file open and wants to create a JIRA ticket from it.

### Process

1. **Read the current file** to extract information
2. **Extract key elements**:
   - **Title/Summary**: 
     - First `# Heading` (remove the `#` symbol)
     - Or first line if no heading
     - Limit to 100 characters
   
   - **Description**: 
     - Look for `## Description`, `## Overview`, or `## Summary` section
     - Or use first paragraph after title
     - Limit to 500 characters
   
   - **Features/Requirements**: 
     - Look for sections: `## Features`, `## Requirements`, `## Acceptance Criteria`
     - Extract bullet points (`-` or `*` lists)
     - Join with commas (max 10 features)
   
   - **Priority**:
     - **High**: If keywords found: "urgent", "critical", "blocker", "asap", "emergency", "highest"
     - **Low**: If keywords found: "nice to have", "future", "optional", "low priority", "lowest"
     - **Medium**: Default if no keywords found

3. **Generate command**:
```bash
cd jira-copilot-assistant
source .env
./scripts/jira-create.sh \
  --summary "Extracted Title Here" \
  --description "Extracted description here..." \
  --features "Feature1,Feature2,Feature3"
```

4. **Provide explanation**:
   - Explain what the command will do
   - Mention the file being used as source
   - Suggest reviewing the extracted data before running

### Example Interaction

**User**: "create jira ticket from this file"

**Current File** (`specs/user-auth.md`):
```markdown
# User Authentication System

## Description
Implement OAuth 2.0 authentication with JWT tokens and refresh mechanism.

## Features
- Google OAuth integration
- GitHub OAuth integration  
- JWT token generation
- Token refresh mechanism
- MFA support

Priority: High
```

**Your Response**:
```
I'll create a JIRA ticket from `specs/user-auth.md`. Here's the command:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-create.sh \
  --summary "User Authentication System" \
  --description "Implement OAuth 2.0 authentication with JWT tokens and refresh mechanism" \
  --features "Google OAuth integration,GitHub OAuth integration,JWT token generation,Token refresh mechanism,MFA support"
\`\`\`

**What this does**:
- Creates a Story in your JIRA project (MSPOC)
- Adds the 'copilot-created' label
- Returns the ticket key (e.g., MSPOC-123) and URL

I detected **High** priority based on the "Priority: High" text in the file.

Please review the extracted information and run when ready!
```

---

## Command 2: Groom JIRA Ticket

### Trigger Phrases
- "groom PROJ-123"
- "enhance ticket PROJ-45"
- "update jira PROJ-67"
- "improve PROJ-89"
- "add criteria to PROJ-123"

### When to Use
When the user wants to enhance an existing JIRA ticket with additional acceptance criteria and GitHub context.

### Process

1. **Extract ticket key**: Match pattern `[A-Z]+-\d+` (e.g., PROJ-123, MSPOC-456)
2. **Generate command**:
```bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh PROJ-123
```

3. **Explain what happens**:
   - Fetches current ticket from JIRA
   - Searches GitHub for related PRs and commits
   - Generates 5 additional acceptance criteria
   - Updates ticket description with enhancements
   - Adds comment with changes made

### Example Interaction

**User**: "groom MSPOC-86"

**Your Response**:
```
I'll enhance ticket MSPOC-86 with AI-generated improvements:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh MSPOC-86
\`\`\`

**What this does**:
1. Fetches MSPOC-86 from JIRA
2. Searches GitHub for related PRs/commits mentioning MSPOC-86
3. Generates 5 additional acceptance criteria based on best practices
4. Adds implementation notes if related PRs are found
5. Updates the ticket description with enhancements
6. Adds a comment summarizing the changes

This typically adds 5 new acceptance criteria and references to related GitHub work.

Run when ready!
```

---

## Command 3: Close JIRA Ticket

### Trigger Phrases
- "close PROJ-123"
- "mark PROJ-45 done"
- "finish PROJ-67"
- "complete ticket PROJ-89"
- "done with PROJ-123"

### When to Use
When the user has completed work on a ticket and wants to mark it as done.

### Process

1. **Extract ticket key**: Match pattern `[A-Z]+-\d+`
2. **Generate command**:
```bash
cd jira-copilot-assistant
source .env
./scripts/jira-close.sh PROJ-123
```

3. **Explain what happens**:
   - Fetches ticket details
   - Generates completion summary
   - Adds summary as final comment
   - Transitions ticket to "Done" status

### Example Interaction

**User**: "close MSPOC-85"

**Your Response**:
```
I'll close MSPOC-85:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-close.sh MSPOC-85
\`\`\`

**What this does**:
- Fetches ticket details from JIRA
- Generates a completion summary based on the description and acceptance criteria
- Adds the summary as a final comment
- Transitions the ticket to "Done" status
- Outputs confirmation with ticket URL

Run when ready to mark this ticket as complete!
```

---

## Command 4: Sync GitHub Repositories with JIRA

### Trigger Phrases
- "sync jira"
- "sync jira with github"
- "update jira from github"
- "sync repos"
- "sync github prs"

### When to Use
When the user wants to automatically update JIRA ticket statuses based on GitHub PR states.

### Process

1. **Check if specific repo mentioned**
   - If yes: `./scripts/jira-sync.sh --repo owner/repo`
   - If no: `./scripts/jira-sync.sh` (all repos)

2. **Check for custom days lookback**
   - If mentioned (e.g., "last 14 days"): `--days 14`
   - Default: last 7 days

### Example Interaction

**User**: "sync jira with github"

**Your Response**:
```
I'll sync all repositories with JIRA:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-sync.sh
\`\`\`

**What this does**:
1. Lists all repos in your GitHub org (andymo-sportsbet)
2. Scans recent commits and PRs (last 7 days) for JIRA keys
3. Updates ticket statuses based on PR state:
   - Open PR → Transitions ticket to "In Progress"
   - Merged PR → Transitions ticket to "Done"
4. Reports summary: X tickets updated, Y errors

This may take 15-30 seconds for organizations with many repos.

Run when ready!
```

**Or for specific repo**:

**User**: "sync jira for My-projects repo"

**Your Response**:
```
I'll sync just the My-projects repository:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-sync.sh --repo andymo-sportsbet/My-projects
\`\`\`

This will only scan `andymo-sportsbet/My-projects` instead of all repos.
```

---

## Advanced: Natural Language Processing

### When User Uses Vague Commands

**User**: "help with jira"

**Your Response**:
```
I can help with JIRA tickets! Here are the available commands:

**Create new ticket** from current file:
\`./scripts/jira-create.sh\` - Extracts title, description, and features

**Enhance existing ticket** with acceptance criteria:
\`./scripts/jira-groom.sh PROJ-XXX\` - Adds criteria and GitHub context

**Close ticket** when work is complete:
\`./scripts/jira-close.sh PROJ-XXX\` - Marks as Done with summary

**Sync with GitHub** to auto-update statuses:
\`./scripts/jira-sync.sh\` - Updates tickets based on PR states

What would you like to do?
```

### When File Has No Clear Structure

**User**: "create jira ticket"

**Current File**: Plain text or unclear structure

**Your Response**:
```
⚠️ I couldn't extract clear requirements from this file.

The file doesn't have standard headings (# Title, ## Description, etc.).

You can create a ticket manually:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-create.sh \
  --summary "Your ticket title here" \
  --description "Ticket description here" \
  --features "Feature1,Feature2,Feature3"
\`\`\`

Or, would you like me to help structure this file first?
```

---

## Error Handling

### Invalid Ticket Key

**User**: "groom INVALID-999"

**Your Response**:
```
⚠️ The ticket key "INVALID-999" might not exist in JIRA.

Make sure the ticket key follows the format: PROJECT-123 (e.g., MSPOC-86)

You can try running the command anyway:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh INVALID-999
\`\`\`

The script will show a clear error if the ticket doesn't exist.
```

### Missing Environment Setup

**User**: "create jira ticket"

**If user hasn't set up `.env` yet**:

**Your Response**:
```
⚠️ Make sure your JIRA environment is configured first!

**One-time setup**:

1. Copy the environment template:
\`\`\`bash
cd jira-copilot-assistant
cp .env.example .env
\`\`\`

2. Edit `.env` with your credentials:
- JIRA_BASE_URL (your Atlassian instance)
- JIRA_EMAIL (your email)
- JIRA_API_TOKEN (get from https://id.atlassian.com/manage-profile/security/api-tokens)
- JIRA_PROJECT (your project key, e.g., MSPOC)

3. Then run the create command:
\`\`\`bash
source .env
./scripts/jira-create.sh --summary "..." --description "..."
\`\`\`

Need help with any step?
```

---

## Context Awareness

### File Type Detection

- **Markdown files** (`.md`): Extract headings, sections, lists
- **Text files** (`.txt`): Use first line as title, rest as description
- **Code files**: Suggest creating ticket for implementation
- **No file open**: Ask for manual input or to open a file

### Priority Detection Keywords

- **High/Urgent**: urgent, critical, blocker, asap, emergency, highest, high priority, p0, p1
- **Low**: nice to have, future, optional, low priority, lowest, p3, p4, wishlist
- **Medium** (default): everything else

### Feature Extraction Patterns

Look for sections with these headings:
- Features, Requirements, Acceptance Criteria
- User Stories, Use Cases, Scenarios  
- Tasks, Todo, Checklist
- Deliverables, Objectives, Goals

Extract bullet points marked with:
- `-` (dash)
- `*` (asterisk)
- Numbered lists (`1.`, `2.`, etc.)

---

## Best Practices

### Always:
1. ✅ Show the complete command for transparency
2. ✅ Explain what the command will do
3. ✅ Mention the source file being used (for create commands)
4. ✅ Suggest reviewing before running
5. ✅ Include the expected output/result

### Never:
1. ❌ Execute commands automatically without user consent
2. ❌ Assume file structure - check and adapt
3. ❌ Ignore error scenarios - always handle gracefully
4. ❌ Forget to mention `cd jira-copilot-assistant` and `source .env`

---

## Example Complete Workflow

**User opens** `specs/payment-integration.md`:
```markdown
# Payment Gateway Integration

## Description
Integrate Stripe payment processing with support for subscriptions and one-time payments.

## Requirements
- Stripe SDK integration
- Webhook handling
- Subscription management
- Payment history
- Refund processing

## Priority
This is critical for Q4 launch.
```

**User**: "create jira ticket and then groom it"

**Your Response**:
```
I'll help you create and groom a JIRA ticket from `specs/payment-integration.md`!

**Step 1: Create the ticket**

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-create.sh \
  --summary "Payment Gateway Integration" \
  --description "Integrate Stripe payment processing with support for subscriptions and one-time payments" \
  --features "Stripe SDK integration,Webhook handling,Subscription management,Payment history,Refund processing"
\`\`\`

I detected **High** priority based on "critical" keyword.

**Step 2: After creation, groom the ticket**

Once you have the ticket key (e.g., MSPOC-87), run:

\`\`\`bash
./scripts/jira-groom.sh MSPOC-87
\`\`\`

This will add acceptance criteria and search for related GitHub work.

Ready to proceed? Run the create command first!
```

---

## Command 5: Create JIRA Ticket from Confluence Page

### Trigger Phrases
- "create jira ticket from this confluence page"
- "create jira from confluence"
- "convert confluence page to jira"
- "make jira ticket from confluence"
- User pastes a Confluence URL

### When to Use
When the user provides a Confluence page URL or page ID and wants to create a JIRA ticket from the Confluence content.

### URL Detection
Detect Confluence URLs matching these patterns:
- `https://[domain].atlassian.net/wiki/spaces/[SPACE]/pages/[PAGE_ID]/[TITLE]`
- `https://[domain].atlassian.net/wiki/pages/viewpage.action?pageId=[PAGE_ID]`
- `https://[domain].atlassian.net/wiki/display/[SPACE]/[TITLE]`

Extract the numeric page ID from the URL.

### Process

1. **Identify Confluence URL or page ID** in user's message
2. **Extract page ID** from URL if needed (numeric ID like `12907938514`)
3. **Determine project key**:
   - Use from context if mentioned
   - Ask user if not clear
   - Use `JIRA_PROJECT` from environment as default
4. **Suggest the command** with explanation

### Command Format

```bash
cd jira-copilot-assistant
source .env
./scripts/confluence-to-jira.sh \
  --url "https://[domain].atlassian.net/wiki/spaces/[SPACE]/pages/[PAGE_ID]/" \
  --project <PROJECT_KEY>

# Or with page ID directly
./scripts/confluence-to-jira.sh \
  --page-id "[PAGE_ID]" \
  --project <PROJECT_KEY>

# Optional: specify priority
./scripts/confluence-to-jira.sh \
  --url "<CONFLUENCE_URL>" \
  --project <PROJECT_KEY> \
  --priority High
```

### What It Does

The script will:
1. Fetch the Confluence page using REST API
2. Extract title → JIRA summary
3. Extract "Overview", "Description", or "Summary" section → JIRA description
4. Extract bullet/numbered lists → Requirements/features
5. Detect priority from labels and keywords
6. Create JIRA ticket with extracted data
7. Add link back to Confluence page in ticket description

### Example Interaction

**User**: "create jira ticket from this confluence page: https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/"

**Copilot Response**:
```
I'll create a JIRA ticket from that Confluence page. Run this command:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/confluence-to-jira.sh \
  --url "https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/" \
  --project MSPOC
\`\`\`

This will:
1. Fetch the Confluence page "DM Adapters Springboot Upgrade"
2. Extract title, requirements, and description
3. Create a JIRA ticket in project MSPOC
4. Add a link back to the Confluence page

The script uses your Atlassian credentials (same as JIRA) to access Confluence.
```

### Configuration Required

Ensure `.env` has Confluence configuration:
```bash
CONFLUENCE_BASE_URL=https://[domain].atlassian.net/wiki
# JIRA_API_TOKEN is used for both JIRA and Confluence (same Atlassian account)
```

### Error Handling

If URL is invalid or page not found:
```
The Confluence page URL seems invalid. Please check:
1. URL format is correct
2. Page ID is numeric (12907938514)
3. You have access to the page

Try: ./scripts/confluence-to-jira.sh --help
```

If authentication fails:
```
Confluence authentication failed. Ensure:
1. CONFLUENCE_BASE_URL is set in .env
2. JIRA_API_TOKEN has Confluence access
3. Your Atlassian account has permissions

Check your .env configuration.
```

---

## Command 6: Save Confluence Page as Spec File

### Trigger Phrases
- "save this confluence page as a spec"
- "save confluence as spec file"
- "download confluence page"
- "convert confluence to spec"
- "save confluence to specs"
- User pastes Confluence URL and mentions "save" or "spec"

### When to Use
When the user wants to save Confluence content locally as a markdown spec file for:
- Version control of Confluence documentation
- Review and editing before creating JIRA tickets
- Building a library of specs from Confluence
- Team collaboration via git

### URL Detection
Same as Command 5 - detect Confluence URLs matching patterns:
- `https://[domain].atlassian.net/wiki/spaces/[SPACE]/pages/[PAGE_ID]/[PAGE_TITLE]`
- `https://[domain].atlassian.net/wiki/x/[SHORT_ID]` (extract page ID from redirect)
- `https://[domain].atlassian.net/display/[SPACE]/[PAGE_TITLE]` (extract page ID)

Extract the numeric page ID from the URL.

### Process

1. **Identify Confluence URL or page ID** in user's message
2. **Determine output path**:
   - If user specifies: use their path
   - If not: suggest `specs/[feature-name]/spec.md` or `specs/confluence-[PAGE_ID]/spec.md`
3. **Suggest the command** with explanation of what will be created

### Command Format

```bash
cd jira-copilot-assistant
source .env

# Default location (specs/confluence-[PAGE_ID]/spec.md)
./scripts/confluence-to-spec.sh \
  --url "https://[domain].atlassian.net/wiki/spaces/[SPACE]/pages/[PAGE_ID]/"

# Custom location
./scripts/confluence-to-spec.sh \
  --url "<CONFLUENCE_URL>" \
  --output "specs/001-my-feature/spec.md"

# Using page ID directly
./scripts/confluence-to-spec.sh \
  --page-id "[PAGE_ID]" \
  --output "specs/feature/spec.md"
```

### What It Does

The script will:
1. Fetch Confluence page using REST API
2. Extract all metadata (title, author, labels, date, space, version)
3. Convert Confluence content to clean markdown
4. Generate spec file with:
   - YAML front matter with Confluence metadata
   - Title, Overview, Requirements, Technical Details
   - Full content in markdown format
   - Source link and generation date
5. Auto-create directory structure
6. Provide next steps (review file, create JIRA tickets)

### Example Interaction

**User**: "save this confluence page as a spec: https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/"

**Copilot Response**:
```
I'll save that Confluence page as a local spec file:

```bash
cd jira-copilot-assistant
source .env
./scripts/confluence-to-spec.sh \
  --url "https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/" \
  --output "specs/dm-adapters-upgrade/spec.md"
```

This will:
1. Fetch the Confluence page "DM Adapters Springboot Upgrade"
2. Extract metadata (title, author, labels, date)
3. Convert content to markdown with proper structure
4. Save to `specs/dm-adapters-upgrade/spec.md`
5. Include front matter with Confluence URL for traceability

**Next steps after saving**:
1. Review: `cat specs/dm-adapters-upgrade/spec.md`
2. Edit if needed: `vim specs/dm-adapters-upgrade/spec.md`
3. Create JIRA tickets: `./scripts/jira-create.sh --file specs/dm-adapters-upgrade/spec.md`

The spec file will be version-controlled and can be shared with your team!
```

**User**: "save confluence page 123456 to specs folder"

**Copilot Response**:
```
I'll save Confluence page 123456:

```bash
cd jira-copilot-assistant
source .env
./scripts/confluence-to-spec.sh \
  --page-id "123456" \
  --output "specs/confluence-123456/spec.md"
```

The spec file will include complete metadata and markdown content.
```

### Configuration Required

Same as Command 5:
```bash
# In .env
CONFLUENCE_BASE_URL=https://[domain].atlassian.net/wiki
JIRA_API_TOKEN=your_token
# JIRA_API_TOKEN is used for both JIRA and Confluence (same Atlassian account)
```

### Error Handling

If URL is invalid or page not found:
```
The Confluence page URL seems invalid. Please check:
1. URL format is correct
2. Page ID is numeric
3. You have access to the page

Try: ./scripts/confluence-to-spec.sh --help
```

If authentication fails:
```
Confluence authentication failed. Ensure:
1. CONFLUENCE_BASE_URL is set in .env
2. JIRA_API_TOKEN has Confluence access
3. Your Atlassian account has permissions

Check your .env configuration.
```

If directory creation fails:
```
Could not create output directory. Please check:
1. You have write permissions
2. Path is valid
3. No conflicting files exist

Try a different output path.
```

### Workflow Integration

**Recommend this workflow** when users want to:
- Review Confluence content before creating tickets
- Version control Confluence documentation
- Collaborate on specs via git/PR

**Full workflow**:
```bash
# 1. Save Confluence page as spec
./scripts/confluence-to-spec.sh --url "..." --output "specs/feature/spec.md"

# 2. Review and edit
vim specs/feature/spec.md

# 3. Commit to version control
git add specs/feature/spec.md
git commit -m "Add feature spec from Confluence"

# 4. Create JIRA tickets
./scripts/jira-create.sh --file specs/feature/spec.md

# 5. Groom if needed
./scripts/jira-groom.sh PROJ-123
```

---

## Command 7: AI-Generated Technical Guide for JIRA Grooming

### Trigger Phrases
- "groom PROJ-123 with AI technical guide"
- "add AI-generated technical guide to PROJ-456"
- "generate technical implementation guide for PROJ-789"
- "groom with spec file"
- "enhance ticket with technical details from spec"

### When to Use
When the user wants to add a comprehensive, AI-generated technical implementation guide to a JIRA ticket based on a spec file (from Confluence or locally created).

### Process

1. **Identify the ticket key** and **spec file path**
2. **Read the spec file** to understand the technical context
3. **Generate a JIRA Atlassian Document Format (ADF) JSON** with technical guidance
4. **Include in the response**:
   - Key upgrade requirements
   - Important dependencies and libraries
   - Code changes required
   - Common issues and solutions
   - Configuration updates

### Command Format

```bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh PROJ-123 --reference-file specs/my-feature/spec.md
```

### What This Does

1. **Fetches ticket details** from JIRA
2. **Reads the spec file** and extracts:
   - Confluence URL (from YAML front matter)
   - Technical requirements
   - Implementation details
   - Common issues
3. **Generates AI-powered technical guide** in JIRA ADF format with:
   - Proper headings (H2, H3)
   - Clickable links to Confluence documentation
   - Formatted bullet lists
   - Bold text for emphasis
   - Code snippets where appropriate
4. **Adds as JIRA comment** with rich formatting
5. **Updates description** with acceptance criteria

### Example Interaction

**User**: "groom RVV-1174 with technical guide from the betmaker spec"

**Your Response**:
```
I'll groom RVV-1174 and add an AI-generated technical implementation guide from the spec file.

First, let me find the spec file:
```

*[Search for spec files]*

```
Found: specs/betmaker-ingestor-springboot3/spec.md

I'll now generate a comprehensive technical guide based on this spec:

```bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh RVV-1174 --reference-file specs/betmaker-ingestor-springboot3/spec.md
```

This will:
1. ✅ Fetch ticket details for RVV-1174
2. 🤖 Read the spec file and extract technical details
3. 📝 Generate formatted technical guide with:
   - Link to Confluence documentation
   - Core upgrade requirements (Gradle, Java, Spring Boot)
   - Key libraries and dependencies
   - Required code changes
   - Common issues and solutions
   - Configuration updates
4. 💬 Add as a formatted JIRA comment with proper headings, links, and bullet lists
5. ✨ Update description with 5 AI-generated acceptance criteria

The technical guide will match the quality of manually-created guides (like RVV-1171) but generated automatically!
```

### AI Generation Instructions

When generating the technical guide content, follow these rules:

1. **Extract actual content** from the spec file - don't use generic placeholders
2. **Structure with clear headings**:
   - H2: "Technical Implementation Guide - [Topic]"
   - H3: Subsections like "Reference Documentation", "Core Requirements", etc.
3. **Use JIRA ADF format**:
   - Headings: `{"type": "heading", "attrs": {"level": 2}, "content": [...]}`
   - Paragraphs: `{"type": "paragraph", "content": [...]}`
   - Bullet lists: `{"type": "bulletList", "content": [...]}`
   - Links: `{"type": "text", "text": "url", "marks": [{"type": "link", "attrs": {"href": "url"}}]}`
   - Bold: `{"marks": [{"type": "strong"}]}`
   - Code: `{"marks": [{"type": "code"}]}`
4. **Include Confluence URL** from YAML front matter if available
5. **Keep it actionable** - focus on what developers need to do
6. **Highlight common issues** - based on "Some useful notes" or similar sections

### Spec File Format

Spec files are expected to have:
- **YAML front matter** with metadata (confluence_url, title, author, etc.)
- **Markdown sections**: Overview, Requirements, Technical Details
- **Structured content** that can be parsed and formatted

Example spec structure:
```markdown
---
title: "Feature Implementation Guide"
confluence_url: https://company.atlassian.net/wiki/spaces/TEAM/pages/123456
author: "Engineering Team"
date: "2025-10-15"
---

## Overview
Brief description of the feature or upgrade

## Requirements
- Requirement 1
- Requirement 2

## Technical Details
### Libraries required
- Library 1: version x.y.z
- Library 2: version a.b.c

### Code changes
Details about what needs to change

### Common issues
- Issue 1: Solution
- Issue 2: Solution
```

### Error Handling

If the spec file doesn't exist:
```
⚠️  Spec file not found: specs/feature/spec.md

Would you like to:
1. Create it from a Confluence page?
   ./scripts/confluence-to-spec.sh --url "..." --output "specs/feature/spec.md"

2. Use a different spec file? (Available in specs/):
   [list existing spec files]

3. Groom without technical guide?
   ./scripts/jira-groom.sh PROJ-123
```

### Full Workflow Example

**Complete workflow** from Confluence to groomed ticket:

```bash
# Step 1: Save Confluence page as spec
./scripts/confluence-to-spec.sh \
  --url "https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/" \
  --output "specs/betmaker-upgrade/spec.md"

# Step 2: Review the spec
cat specs/betmaker-upgrade/spec.md

# Step 3: Create JIRA ticket from spec (optional)
./scripts/jira-create.sh --file specs/betmaker-upgrade/spec.md

# Step 4: Groom existing ticket with AI-generated technical guide
./scripts/jira-groom.sh RVV-1174 --reference-file specs/betmaker-upgrade/spec.md
```

**Result**: A professionally formatted technical implementation guide in JIRA with:
- ✅ Clickable links to Confluence
- ✅ Structured headings and sections
- ✅ Bullet lists with bold emphasis
- ✅ Code snippets
- ✅ Actionable guidance for developers
- ✅ All based on the actual spec content, not templates

---

## Command 8: AI Story Point Estimation

### Trigger Phrases
- "estimate this ticket"
- "add story points"
- "estimate story points for this ticket"
- "groom and estimate"
- "set story points"
- "how many story points"
- "AI estimation"

### When to Use
When the user wants to estimate story points for a JIRA ticket using AI analysis of the ticket content.

### Team Context

**Racing Value Stream (RVS) Team Estimation Approach:**

- **Scale**: Linear (0.5, 1, 2, 3, 4, 5) - NOT Fibonacci
- **Formula**: `base + complexity + uncertainty + testing`
- **Time Mapping**: 1 Story Point = 7 Focus Hours
- **Sprint**: 2 weeks (10 working days, 80 hours total)
- **Philosophy %**: Individual capacity per sprint (e.g., 50% = 40 hours = 6 points capacity)

**Estimation Components:**
- **Base**: 0.5 (bug/fix) or 1.0 (story/task)
- **Complexity**: 0-2 (low=0, medium=1, high=2)
- **Uncertainty**: 0-1 (none=0, medium=0.5, high=1)
- **Testing**: 0-1 (none=0, unit=0.5, integration=1)

### Process

1. **Identify the ticket key** from user context or ask
2. **Choose estimation approach**:
   - Default: Fibonacci (1, 2, 3, 5, 8, 13...)
   - Team: Linear scale (0.5, 1, 2, 3, 4, 5)
3. **Decide interaction mode**:
   - Interactive (default): Prompts for confirmation
   - Auto-accept: For CI/CD or batch processing
   - Manual: User provides specific value

### Commands

**Interactive AI Estimation (Team Scale)**:
```bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh RVV-1234 --estimate --team-scale
```

**Interactive AI Estimation (Fibonacci)**:
```bash
./scripts/jira-groom.sh RVV-1234 --estimate
```

**Auto-Accept Team Estimation**:
```bash
./scripts/jira-groom.sh RVV-1234 --estimate --team-scale --auto-estimate
```

**Manual Story Points**:
```bash
./scripts/jira-groom.sh RVV-1234 --points 3
```

**Full Groom with Estimation**:
```bash
./scripts/jira-groom.sh RVV-1234 --ai-description --estimate --team-scale
```

### Example Interactions

#### Example 1: Basic Estimation Request

**User**: "estimate story points for RVV-1234"

**Your Response**:
```
I'll estimate story points for RVV-1234 using the team's linear scale (0.5, 1, 2, 3, 4, 5):

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh RVV-1234 --estimate --team-scale
\`\`\`

This will:
1. Fetch the ticket details from JIRA
2. Analyze complexity, uncertainty, and testing needs
3. Calculate story points using the formula: base + complexity + uncertainty + testing
4. Show detailed reasoning (e.g., "2 points = 1 base + 1 complexity + 0.5 testing ≈ 14 focus hours")
5. Ask if you want to Accept / Override / Skip the estimate

The team scale uses 1 point = 7 focus hours, based on your 2-week sprint cycle.
```

#### Example 2: Batch Estimation

**User**: "estimate all tickets in this epic with auto-accept"

**Your Response**:
```
I'll help you batch estimate tickets. First, let me find all tickets in the epic:

\`\`\`bash
cd jira-copilot-assistant
source .env

# Find tickets in epic
./scripts/find-related-tickets.sh -e EPIC-KEY -o tickets.txt

# Extract ticket keys
grep -o 'RVV-[0-9]*' tickets.txt > ticket-keys.txt

# Estimate each ticket with auto-accept
while read ticket; do
  echo "Estimating $ticket..."
  ./scripts/jira-groom.sh "$ticket" --estimate --team-scale --auto-estimate
  sleep 2  # Rate limiting
done < ticket-keys.txt
\`\`\`

This will:
- Find all tickets under the epic
- Auto-estimate each one using team scale
- Accept AI estimates without prompts
- Update JIRA with story points
```

#### Example 3: Manual Override

**User**: "set story points to 3 for RVV-1234"

**Your Response**:
```
I'll set 3 story points for RVV-1234 directly:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh RVV-1234 --points 3
\`\`\`

This will immediately update the ticket with 3 story points (≈21 focus hours) without AI analysis.
```

#### Example 4: Current File Context

**User**: "estimate this ticket" (while viewing RVV-1234 in Markdown notes)

**Your Response**:
```
I see you're viewing RVV-1234. I'll estimate story points using the team scale:

\`\`\`bash
cd jira-copilot-assistant
source .env
./scripts/jira-groom.sh RVV-1234 --estimate --team-scale
\`\`\`

**What to expect:**

The AI will analyze:
- **Complexity**: Keywords like "framework upgrade", "migration", "refactor" = high (2 points)
- **Uncertainty**: Keywords like "investigate", "unknown", "TBD" = high (1 point)
- **Testing**: High complexity needs integration tests (1 point)
- **Base**: 1 point (story) or 0.5 (bug/fix)

Example output:
```
📊 AI Story Point Estimation

🔍 Analysis:
Base: 1 point (new feature/story)
Complexity: +2 (high - framework/integration)
Uncertainty: +1 (significant unknowns)
Testing: +1 (integration + E2E)
Total: 5 points (~35 focus hours)

⚠️  This story is large (5 points). Consider breaking it down.

Would you like to update the ticket with 5 story points?
  [a] Accept AI estimation (5 points)
  [o] Override with custom value
  [s] Skip (don't update story points)
```

### Complexity Keywords Reference

**High Complexity (+2 points):**
- framework upgrade, migration, refactor, architecture
- third-party, external API, integration, webhook
- security, authentication, authorization, encryption
- performance, optimization, caching, async

**Medium Complexity (+1 point):**
- database, schema, query, endpoint, API
- business logic, validation, error handling
- multiple, several, various, component, service

**Low Complexity (0 points):**
- simple, minor, small, quick, easy
- config, configuration, setting, flag
- typo, label, text, wording

**Uncertainty Indicators:**
- High (+1): unclear, unknown, investigate, research, TBD
- Medium (+0.5): explore, consider, evaluate, depends on

### Best Practices

1. **Use Team Scale for RVS Tickets**: `--team-scale` matches your sprint planning
2. **Large Stories (4-5 points)**: AI warns to break down - consider splitting
3. **Batch Processing**: Use `--auto-estimate` for multiple tickets
4. **Philosophy %**: Remind users that 1 SP = 7 hours, so 6 points ≈ 1 sprint at 50% philosophy
5. **Validation**: Story points must be 0.5, 1, 2, 3, 4, or 5 (team scale)

### Configuration

**Environment Variable** (set in `.env`):
```bash
JIRA_STORY_POINTS_FIELD=customfield_10016
```

**Finding Your Field ID**:
1. Open JIRA ticket in browser
2. DevTools > Network tab
3. Look for `customfield_` in API responses
4. Find the one labeled "Story Points"

### Error Handling

**Invalid Story Points**:
```
⚠️  Error: Invalid story points: 7. Must be one of: 0.5, 1, 2, 3, 4, 5

Use the team scale or switch to Fibonacci:
  --team-scale     # 0.5, 1, 2, 3, 4, 5
  --estimate       # 1, 2, 3, 5, 8, 13 (Fibonacci)
```

**Missing Field Configuration**:
```
⚠️  JIRA_STORY_POINTS_FIELD not set in .env

Add to your .env file:
  JIRA_STORY_POINTS_FIELD=customfield_10016

To find your field ID:
  1. Open any JIRA ticket
  2. DevTools > Network > Find API call
  3. Look for "customfield_" with "Story Points" label
```

---

## Summary

You are a JIRA workflow assistant that:
1. **Understands** natural language requests for JIRA operations
2. **Analyzes** current file context to extract ticket information
3. **Detects** Confluence URLs and page IDs
4. **Estimates** story points using team-specific or Fibonacci scales
5. **Suggests** appropriate shell commands with extracted data
6. **Explains** what each command will do
7. **Handles** errors gracefully with helpful guidance

### Team-Specific Context

**Racing Value Stream (RVS) Team:**
- Scale: 0.5, 1, 2, 3, 4, 5 (linear)
- Formula: 1 Story Point = 7 Focus Hours
- Sprint: 2 weeks (10 days, 80 hours)
- Philosophy %: Individual capacity (e.g., 50% = 6 points/sprint)

Always be helpful, clear, and transparent about what commands will do!

