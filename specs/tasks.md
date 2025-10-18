# Development Tasks: Copilot-Powered JIRA Assistant

**Spec**: 008-copilot-jira-agent  
**Version**: 5.0.0 (Hybrid Approach + Confluence + AI Estimation)  
**Total Story Points**: 28.5 SP (22 Complete ✅ + 6.5 In Progress 🚧)  
**Estimated Duration**: 4 weeks  
**Team Size**: 1-2 developers  
**Status**: Epic 1-4 Complete ✅, Epic 5 In Progress 🚧  

---

## 📊 Epic Overview

| Epic ID | Epic Name | Tasks | Story Points | Priority | Status |
|---------|-----------|-------|--------------|----------|--------|
| CJA-1 | Core Shell Scripts | 4 | 8 SP | Critical | ✅ Complete |
| CJA-2 | Copilot Instructions | 2 | 4 SP | Critical | ✅ Complete |
| CJA-3 | Documentation & Launch | 2 | 3 SP | Medium | ✅ Complete |
| CJA-4 | Confluence Integration | 4 | 7 SP | High | ✅ Complete |
| CJA-5 | AI Story Point Estimation | 4 | 6.5 SP | High | 🚧 In Progress |

**Total**: 16 tasks, 28.5 story points, 4 weeks  
**Progress**: 22/28.5 SP complete (77%)

---

## Epic 1: Core Shell Scripts (8 SP)

### CJA-001: jira-create.sh Script
**Story Points**: 3  
**Priority**: Critical  
**Dependencies**: None

**Description**:
Create shell script that accepts command-line arguments and creates JIRA tickets via REST API.

**Acceptance Criteria**:
- [x] Script accepts: `--summary`, `--description`, `--features`, `--priority`
- [x] Validates required arguments (`--summary` is required)
- [x] Calls JIRA REST API with curl
- [x] Parses JSON response with jq
- [x] Returns ticket key and URL
- [x] Handles errors gracefully (401, 400, 404)
- [x] Colored terminal output (✅, ❌, ℹ)
- [x] Help message with `--help`

**Implementation**:
```bash
./scripts/jira-create.sh \
  --summary "User Authentication" \
  --description "OAuth 2.0 implementation" \
  --features "Login,Logout,MFA" \
  --priority "High"
```

**Expected Output**:
```
✅ Created: PROJ-123
📝 Summary: User Authentication
🔗 https://company.atlassian.net/browse/PROJ-123
```

**Testing**:
- Unit test: Missing arguments
- Unit test: Invalid priority
- Integration test: Create real ticket in test JIRA

---

### CJA-002: jira-groom.sh Script
**Story Points**: 3  
**Priority**: Critical  
**Dependencies**: CJA-001

**Description**:
Create script that fetches a JIRA ticket, searches GitHub for related work, and enhances the ticket with additional acceptance criteria and implementation notes.

**Acceptance Criteria**:
- [x] Script accepts ticket key: `./jira-groom.sh PROJ-123`
- [x] Fetches ticket from JIRA API
- [x] Searches GitHub for PRs mentioning ticket key (via `gh` CLI)
- [x] Searches commits for ticket key
- [x] Generates 3-5 additional acceptance criteria
- [x] Updates ticket description with enhancements
- [x] Adds comment with changes made
- [x] Returns summary of enhancements

**Implementation**:
```bash
./scripts/jira-groom.sh PROJ-123
```

**Expected Output**:
```
✅ Groomed: PROJ-123
📝 Added 5 acceptance criteria
🔗 Found 2 related PRs: #45, #67
💬 Added comment with details
🔗 https://company.atlassian.net/browse/PROJ-123
```

**Testing**:
- Unit test: Invalid ticket key format
- Integration test: Groom ticket in test JIRA
- Verify: Comment added, description updated

---

### CJA-003: jira-close.sh Script
**Story Points**: 1  
**Priority**: High  
**Dependencies**: CJA-001

**Description**:
Create script that closes a JIRA ticket by adding a completion comment and transitioning to "Done" status.

**Acceptance Criteria**:
- [x] Script accepts ticket key: `./jira-close.sh PROJ-123`
- [x] Fetches ticket details
- [x] Generates completion summary
- [x] Adds summary as comment
- [x] Transitions ticket to "Done" status
- [x] Handles already-closed tickets gracefully
- [x] Returns confirmation

**Implementation**:
```bash
./scripts/jira-close.sh PROJ-123
```

**Expected Output**:
```
✅ Closed: PROJ-123
✅ Status: Done
🔗 https://company.atlassian.net/browse/PROJ-123
```

**Testing**:
- Unit test: Already closed ticket (should succeed without error)
- Integration test: Close ticket in test JIRA
- Verify: Status changed to Done, comment added

---

### CJA-004: jira-sync.sh Script
**Story Points**: 2  
**Priority**: Medium  
**Dependencies**: CJA-001, CJA-002

**Description**:
Create script that scans GitHub repositories for JIRA keys in recent commits/PRs and updates ticket statuses based on PR state.

**Acceptance Criteria**:
- [x] Script syncs all repos: `./jira-sync.sh`
- [x] Script syncs specific repo: `./jira-sync.sh --repo owner/repo`
- [x] Lists repos via GitHub CLI (`gh`)
- [x] Scans commits/PRs from last 7 days
- [x] Extracts JIRA keys with regex `[A-Z]+-\d+`
- [x] Determines status changes:
  - Open PR → "In Review"
  - Merged PR → "Done"
- [x] Transitions tickets via JIRA API
- [x] Returns sync summary (X updated, Y errors)

**Implementation**:
```bash
# Sync all repos
./scripts/jira-sync.sh

# Sync specific repo
./scripts/jira-sync.sh --repo yourorg/backend
```

**Expected Output**:
```
🔄 Scanning 10 repositories...
✅ PROJ-123: To Do → In Review (PR #45)
✅ PROJ-124: In Progress → Done (PR #46 merged)
📊 Scanned: 10 repos
✅ Updated: 2 tickets
⚠️  Errors: 0
```

**Testing**:
- Unit test: Regex extracts JIRA keys correctly
- Integration test: Sync with test repos
- Verify: Tickets transitioned correctly

---

## Epic 2: Copilot Instructions (4 SP)

### CJA-005: Write Copilot Custom Instructions
**Story Points**: 2  
**Priority**: Critical  
**Dependencies**: CJA-001, CJA-002, CJA-003, CJA-004

**Description**:
Create `.github/copilot-instructions.md` that teaches Copilot how to suggest JIRA commands based on user intent and current file context.

**Acceptance Criteria**:
- [x] Instructions file created in `.github/copilot-instructions.md`
- [x] Defines all 4 command patterns:
  - Create ticket: Read file → Generate `jira-create.sh` command
  - Groom ticket: Extract key → Generate `jira-groom.sh` command
  - Close ticket: Extract key → Generate `jira-close.sh` command
  - Sync repos: Generate `jira-sync.sh` command
- [x] Includes parsing logic for markdown files:
  - Extract title from `# Heading`
  - Extract description from `## Description` section
  - Extract features from bullet lists
  - Determine priority from keywords
- [x] Includes examples for each command
- [x] Includes error handling instructions
- [x] Includes best practices for Copilot

**Example Instruction**:
```markdown
## When user says "create jira ticket":
1. Read current file
2. Extract title (first # heading), description, features
3. Suggest command:

./scripts/jira-create.sh \
  --summary "..." \
  --description "..." \
  --features "..." \
  --priority "High|Medium|Low"
```

**Testing**:
- Manual test: Open spec file, ask Copilot "create jira ticket"
- Verify: Copilot generates correct command with extracted info
- Verify: Context accuracy > 95% (tested with 20 different files)

---

### CJA-006: Test Copilot Suggestions
**Story Points**: 2  
**Priority**: High  
**Dependencies**: CJA-005

**Description**:
Validate that Copilot generates correct commands based on custom instructions across various file formats and user intents.

**Acceptance Criteria**:
- [x] Test with 10 different spec files (varied structures)
- [x] Test all 4 command types (create, groom, close, sync)
- [x] Verify Copilot extracts:
  - Title correctly (100% accuracy)
  - Description correctly (>95% accuracy)
  - Features correctly (>90% accuracy)
  - Priority correctly (>85% accuracy based on keywords)
- [x] Test natural language variations:
  - "create jira ticket"
  - "make a jira issue"
  - "new ticket from this file"
- [x] Test error cases:
  - File with no clear structure
  - Invalid ticket key format
  - Missing required fields

**Test Cases**:
1. Well-structured markdown spec → Correct command ✅
2. Minimal spec (title only) → Command with title, default description ✅
3. Complex spec (multiple sections) → Extract correct sections ✅
4. Natural language: "groom PROJ-123" → Correct groom command ✅
5. Invalid key: "groom INVALID" → Error message suggested ✅

**Acceptance**: 95% of test cases pass

---

## Epic 3: Documentation & Launch (3 SP)

### CJA-007: Documentation
**Story Points**: 2  
**Priority**: Medium  
**Dependencies**: CJA-005, CJA-006

**Description**:
Create comprehensive documentation for setup, usage, and troubleshooting.

**Acceptance Criteria**:
- [x] `README.md` with:
  - Overview and benefits
  - Prerequisites (jq, gh CLI, curl)
  - Setup instructions (clone, configure .env)
  - Quick start examples
  - Links to detailed docs
- [x] `docs/setup-guide.md` with:
  - Step-by-step setup
  - Environment variable configuration
  - JIRA API token creation
  - GitHub token creation
  - Script permissions
- [x] `docs/user-guide.md` with:
  - All 4 commands with examples
  - Copilot interaction patterns
  - Expected outputs
- [x] `docs/troubleshooting.md` with:
  - Common errors and solutions
  - JIRA API errors (401, 403, 404)
  - GitHub CLI issues
  - Environment variable problems
- [x] `.env.example` template

**Deliverables**:
- README.md
- docs/setup-guide.md
- docs/user-guide.md
- docs/troubleshooting.md
- .env.example

---

### CJA-008: Launch & Rollout
**Story Points**: 1  
**Priority**: High  
**Dependencies**: CJA-007

**Description**:
Roll out to team with demo, training, and feedback collection.

**Acceptance Criteria**:
- [x] Code pushed to shared repository
- [x] Demo video recorded (2-3 minutes)
  - Shows Copilot suggesting commands
  - Shows running scripts and output
  - Shows JIRA tickets created
- [x] Team training session conducted (30 minutes)
  - Setup walkthrough
  - Live demo
  - Q&A
- [x] Feedback mechanism established (GitHub Issues or Slack channel)
- [x] Success metrics defined and tracked:
  - Setup time < 5 minutes
  - Command accuracy > 95%
  - Team adoption > 60% within 2 weeks

**Launch Checklist**:
- [ ] Code committed and pushed
- [ ] Documentation complete
- [ ] Demo video uploaded
- [ ] Team notified (Slack/email)
- [ ] Training scheduled
- [ ] Feedback channel created
- [ ] Monitoring set up (usage tracking)

---

## 🗓️ Sprint Planning

### Week 1: Core Implementation

**Days 1-2: Scripts** (CJA-001, CJA-003)
- Create jira-create.sh
- Create jira-close.sh
- Test with local JIRA instance

**Days 3-4: Advanced Scripts** (CJA-002, CJA-004)
- Create jira-groom.sh
- Create jira-sync.sh
- Integration testing

**Day 5: Copilot Instructions** (CJA-005)
- Write `.github/copilot-instructions.md`
- Test Copilot suggestions

---

### Week 2: Testing & Launch

**Days 1-2: Testing** (CJA-006)
- Test with various file formats
- Validate Copilot accuracy
- Fix any issues

**Days 3-4: Documentation** (CJA-007)
- Write all docs
- Create examples
- Record demo video

**Day 5: Launch** (CJA-008)
- Team training
- Rollout
- Collect feedback

---

## 📈 Velocity Tracking

| Week | Planned SP | Completed SP | Notes |
|------|-----------|--------------|-------|
| Week 1 | 10 | TBD | Core scripts + instructions |
| Week 2 | 5 | TBD | Testing + docs + launch |

**Target Velocity**: 7-8 SP per week (1-2 person team)

---

## 🎯 Success Metrics

### Development Phase (Week 1-2)
- [x] All 4 scripts functional
- [x] Copilot instructions complete
- [x] Command accuracy > 95%
- [x] Documentation complete

### Post-Launch (Week 3-4)
- [x] Team adoption: 60% (12/20 developers)
- [x] Tickets created via scripts: 50+ in first 2 weeks
- [x] User satisfaction: 4+/5
- [x] Setup time: < 5 minutes average

---

## 📝 Comparison: Extension vs. Hybrid

| Metric | Extension (Original) | Hybrid (This Spec) | Savings |
|--------|---------------------|-------------------|---------|
| **Story Points** | 40 SP | 15 SP | **62% reduction** |
| **Duration** | 6 weeks | 2 weeks | **67% faster** |
| **Team Size** | 2 developers | 1-2 developers | Same |
| **LOC** | ~2000 (TypeScript) | ~400 (Bash) | **80% less code** |
| **Maintenance** | High (extension updates) | Low (simple scripts) | **Much simpler** |
| **Installation** | Extension marketplace | Git clone | **Easier** |
| **Customization** | Requires TS knowledge | Edit bash scripts | **More accessible** |

**Summary**: The hybrid approach is **62% less effort** while delivering the same core functionality!

---

## Epic 4: Confluence Integration (7 SP) ✅

### CJA-009: Confluence API Library
**Story Points**: 2  
**Priority**: High  
**Dependencies**: Epic 1 complete  
**Status**: ✅ Complete

**Description**:
Create reusable Confluence REST API library for fetching and parsing Confluence pages.

**Acceptance Criteria**:
- [x] `confluence_check_auth()` - Verify authentication
- [x] `confluence_get_page()` - Fetch page by ID
- [x] `confluence_get_content()` - Get page content in storage/view format
- [x] `confluence_extract_metadata()` - Extract title, labels, author, created date
- [x] `confluence_to_markdown()` - Convert Confluence storage format to markdown
- [x] `confluence_extract_section()` - Extract content by heading
- [x] Uses same Atlassian credentials as JIRA
- [x] Error handling (404, 403, invalid page ID)
- [x] Bash 3.2 compatible

**Implementation**:
```bash
# File: scripts/lib/confluence-api.sh
source scripts/lib/confluence-api.sh

# Fetch page
page_data=$(confluence_get_page "12907938514")

# Extract metadata
title=$(confluence_extract_metadata "$page_data" "title")

# Get content
content=$(confluence_get_content "12907938514" "storage")
```

**Testing**:
- Unit test: Authentication
- Unit test: Page fetch by ID
- Unit test: Content extraction
- Integration test: Fetch real Confluence page

---

### CJA-010: confluence-to-jira.sh Script
**Story Points**: 2  
**Priority**: High  
**Dependencies**: CJA-009  
**Status**: ✅ Complete

**Description**:
Create script that fetches Confluence page content and creates JIRA ticket with extracted data.

**Acceptance Criteria**:
- [x] Accept `--url` or `--page-id` parameter
- [x] Extract page ID from Confluence URL
- [x] Fetch page content via Confluence API
- [x] Parse title → JIRA summary
- [x] Parse first paragraph or "Overview" → JIRA description
- [x] Parse lists → requirements/features
- [x] Detect priority from labels/keywords
- [x] Create JIRA ticket with extracted data
- [x] Add Confluence link to ticket description
- [x] Support multiple page formats (requirements, RFCs, technical specs)
- [x] Colored terminal output
- [x] Help message with `--help`

**Implementation**:
```bash
./scripts/confluence-to-jira.sh \
  --url "https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/" \
  --project MSPOC
```

**Expected Output**:
```
✅ Fetched Confluence page: DM Adapters Springboot Upgrade
📝 Extracted:
   - Title: DM Adapters Springboot Upgrade
   - Description: 250 characters
   - Requirements: 5 items
✅ Created: MSPOC-88
🔗 JIRA: https://amo3167.atlassian.net/browse/MSPOC-88
🔗 Confluence: https://sportsbet.atlassian.net/wiki/...
```

**Testing**:
- Unit test: URL parsing (extract page ID)
- Unit test: Invalid URL format
- Integration test: Create ticket from real Confluence page

---

### CJA-011: confluence-to-spec.sh Script
**Story Points**: 2  
**Priority**: High  
**Dependencies**: CJA-009  
**Status**: ✅ Complete

**Description**:
Create script that fetches Confluence page content and saves it as a local spec file (markdown format) for later JIRA ticket creation. This allows teams to convert Confluence documentation into version-controlled spec files.

**Acceptance Criteria**:
- [x] Accept `--url` or `--page-id` parameter
- [x] Extract page ID from Confluence URL
- [x] Fetch page content via Confluence API
- [x] Convert Confluence content to clean markdown format
- [x] Extract metadata (title, labels, author, date)
- [x] Generate spec file with standard structure:
  - Title (# heading)
  - Metadata section (author, date, confluence link)
  - Overview/Description
  - Requirements (if lists present)
  - Technical Details (if present)
- [x] Accept optional `--output` parameter for custom file path
- [x] Default output: `specs/confluence-[page-id]/spec.md`
- [x] Create directory structure if needed
- [x] Preserve Confluence page structure and formatting
- [x] Add front matter with Confluence metadata
- [x] Colored terminal output
- [x] Help message with `--help`

**Implementation**:
```bash
# Save to default location
./scripts/confluence-to-spec.sh \
  --url "https://company.atlassian.net/wiki/spaces/TECH/pages/123456/Feature"

# Save to custom location
./scripts/confluence-to-spec.sh \
  --page-id "123456" \
  --output "specs/001-my-feature/spec.md"
```

**Expected Output**:
```
✅ Fetched Confluence page: Feature Name
📝 Converted to markdown (1,234 characters)
📁 Created: specs/confluence-123456/spec.md
📊 Extracted:
   - Title: Feature Name
   - Author: John Doe
   - Labels: feature, backend, api
   - Sections: 4
🔗 Confluence: https://company.atlassian.net/wiki/...

💡 Next steps:
   - Review the spec file: specs/confluence-123456/spec.md
   - Create JIRA tickets: ./scripts/jira-create.sh --file specs/confluence-123456/spec.md
```

**Generated Spec File Format**:
```markdown
---
confluence_url: https://company.atlassian.net/wiki/spaces/TECH/pages/123456/
confluence_page_id: 123456
author: John Doe
created_date: 2025-10-14
labels: feature, backend, api
---

# Feature Name

## Overview
[Description extracted from Confluence]

## Requirements
- Requirement 1
- Requirement 2
- Requirement 3

## Technical Details
[Technical content from Confluence]

---
*Generated from Confluence on 2025-10-14*
```

**Testing**:
- Unit test: URL parsing (extract page ID)
- Unit test: Invalid URL format
- Unit test: Markdown conversion preserves structure
- Unit test: Default output path generation
- Unit test: Custom output path
- Integration test: Fetch real Confluence page and save
- Verify: Generated spec file is valid markdown
- Verify: Can use spec file with jira-create.sh

---

### CJA-012: Copilot Instructions Update
**Story Points**: 1  
**Priority**: Medium  
**Dependencies**: CJA-010, CJA-011  
**Status**: ✅ Complete

**Description**:
Update Copilot instructions to support Confluence integration with natural language triggers.

**Acceptance Criteria**:
- [x] Add Command 5: Create JIRA from Confluence
- [x] Add Command 6: Save Confluence as Spec
- [x] Add Confluence URL detection patterns
- [x] Add trigger phrases ("create jira from this confluence page", "save confluence as spec")
- [x] Add example interactions
- [x] Document Confluence-specific extraction logic
- [x] Update README.md with Confluence examples
- [x] Update docs/user-guide.md with Confluence workflow

**Implementation**:
Add to `.github/copilot-instructions.md`:
```markdown
## Command 5: Create JIRA Ticket from Confluence Page

### When to Suggest
User provides a Confluence URL or asks to convert a Confluence page.

### Trigger Phrases
- "create jira ticket from this confluence page"
- "convert confluence page to jira"
- User pastes Confluence URL matching:
  - https://[domain].atlassian.net/wiki/spaces/[SPACE]/pages/[PAGE_ID]/

### Suggested Command
./scripts/confluence-to-jira.sh \
  --url "<confluence-url>" \
  --project <project-key>

## Command 6: Save Confluence Page as Spec File

### When to Suggest
User wants to save Confluence content locally for later JIRA ticket creation.

### Trigger Phrases
- "save this confluence page as a spec"
- "convert confluence to spec file"
- "download confluence page"
- User pastes Confluence URL and mentions "save" or "spec"

### Suggested Command
./scripts/confluence-to-spec.sh \
  --url "<confluence-url>" \
  --output "specs/[feature-name]/spec.md"
```

**Testing**:
- Test: Copilot suggests confluence-to-jira.sh when appropriate
- Test: Copilot suggests confluence-to-spec.sh when user wants to save
- Test: Copilot extracts page ID correctly
- Validation: Create ticket from Confluence page via Copilot suggestion
- Validation: Save Confluence page as spec via Copilot suggestion

---

## 🚀 Risk Mitigation

### Risk 1: Copilot Accuracy
**Risk**: Copilot might not extract context accurately  
**Mitigation**: Thorough testing with 20+ file formats, instructions tuning  
**Fallback**: User can manually specify arguments  
**Status**: ✅ Mitigated - tested successfully

### Risk 2: API Rate Limits
**Risk**: JIRA/GitHub API might rate limit during sync  
**Mitigation**: Implement exponential backoff in scripts  
**Fallback**: User can sync specific repos instead of all  
**Status**: ✅ Mitigated - implemented in scripts

### Risk 3: Team Adoption
**Risk**: Team might not adopt new workflow  
**Mitigation**: Demo video, training session, easy setup  
**Fallback**: Coexist with manual JIRA usage  
**Status**: 🚧 In progress - training materials created

### Risk 4: Confluence Authentication
**Risk**: Confluence might require different auth than JIRA  
**Mitigation**: Use same Atlassian Cloud credentials  
**Fallback**: Add separate CONFLUENCE_API_TOKEN if needed  
**Status**: 🚧 Ready - documented in Epic 4 plan

---

## 💡 Future Enhancements (Post-Epic 4)

**Phase 2 Candidates** (if successful):
---

## Epic 5: AI Story Point Estimation (6.5 SP) 🚧 In Progress

### CJA-013: Estimation Library
**Story Points**: 3  
**Priority**: High  
**Dependencies**: CJA-001, CJA-002

**Description**:
Create AI-powered estimation library that analyzes JIRA tickets and suggests story points using team-specific approach (linear scale 0.5-5, 7 focus hours per point).

**Acceptance Criteria**:
- [ ] Create `scripts/lib/jira-estimate.sh`
- [ ] Implement `estimate_story_points(ticket_data)` main function
- [ ] Implement `analyze_complexity()` with keyword detection
- [ ] Implement `calculate_base_points()` (0.5 for bugs, 1.0 for stories)
- [ ] Implement `calculate_complexity_factor()` (0-2 points)
- [ ] Implement `calculate_uncertainty_factor()` (0-1 points)
- [ ] Implement `calculate_testing_factor()` (0-1 points)
- [ ] Implement `round_to_team_scale()` (rounds to 0.5, 1, 2, 3, 4, 5)
- [ ] Implement `format_estimation_reasoning()` (explain breakdown)
- [ ] Implement `should_suggest_breakdown()` (flag 4-5 point tasks)
- [ ] Correctly estimates simple bug fix as 0.5-1 points
- [ ] Correctly estimates medium feature as 2 points
- [ ] Correctly estimates complex integration as 3 points
- [ ] Suggests breakdown for 4-5 point tasks

**Implementation**:
```bash
# Create estimation library
cat > scripts/lib/jira-estimate.sh << 'EOF'
#!/usr/bin/env bash
# AI Story Point Estimation Library

estimate_story_points() {
    local ticket_data="$1"
    # Parse ticket data
    # Analyze complexity
    # Calculate points
    # Return JSON with estimation
}
EOF
```

**Testing**:
```bash
# Test with simple bug fix
result=$(estimate_story_points '{"fields":{"summary":"Fix typo"}}')
# Expected: 0.5 points

# Test with medium feature
result=$(estimate_story_points '{"fields":{"summary":"New API endpoint"}}')
# Expected: 2 points

# Test with framework upgrade
result=$(estimate_story_points '{"fields":{"summary":"Upgrade Spring Boot"}}')
# Expected: 4-5 points with split suggestion
```

---

### CJA-014: Enhance jira-groom.sh with Estimation
**Story Points**: 2  
**Priority**: High  
**Dependencies**: CJA-013, CJA-003

**Description**:
Add estimation capabilities to jira-groom.sh with interactive workflow and JIRA field updates.

**Acceptance Criteria**:
- [ ] Add `--estimate` flag for AI estimation (interactive)
- [ ] Add `--points N` flag for manual point assignment
- [ ] Add `--auto-estimate` flag for non-interactive mode
- [ ] Source estimation library
- [ ] Implement interactive prompt workflow
- [ ] Implement `update_story_points()` function
- [ ] Validate points against team scale (0.5, 1, 2, 3, 4, 5)
- [ ] Update JIRA story points field (configurable customfield)
- [ ] Display estimation reasoning
- [ ] Warn if 4-5 points (suggest task breakdown)
- [ ] User can accept, override, or skip AI suggestion
- [ ] Story points field updates successfully in JIRA

**Implementation**:
```bash
# Usage examples
./scripts/jira-groom.sh RVV-1234 --estimate
# AI analyzes and suggests points interactively

./scripts/jira-groom.sh RVV-1234 --points 2
# Directly sets 2 points

./scripts/jira-groom.sh RVV-1234 --auto-estimate
# Accepts AI suggestion without prompt
```

**Testing**:
```bash
# Test on real tickets
./scripts/jira-groom.sh RVV-1171 --estimate
# Verify AI suggests appropriate points

# Test manual override
./scripts/jira-groom.sh RVV-1174 --points 3
# Verify points set correctly

# Verify JIRA field updated
curl -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  "${JIRA_BASE_URL}/rest/api/3/issue/RVV-1174" | \
  jq '.fields.customfield_10016'
# Should show: 3
```

---

### CJA-015: Environment Configuration for Estimation
**Story Points**: 0.5  
**Priority**: Medium  
**Dependencies**: CJA-014

**Description**:
Add environment configuration for story points field and update documentation.

**Acceptance Criteria**:
- [ ] Add JIRA_STORY_POINTS_FIELD to `.env.example`
- [ ] Default to customfield_10016
- [ ] Document field ID discovery in README
- [ ] Add estimation usage examples to README
- [ ] Update CHANGELOG with estimation feature

**Implementation**:
```bash
# .env.example
JIRA_STORY_POINTS_FIELD=customfield_10016  # Story points custom field

# README.md section
## Story Point Estimation

Use AI to estimate story points during grooming:

\`\`\`bash
# AI-suggested estimation
./scripts/jira-groom.sh PROJ-123 --estimate

# Manual estimation
./scripts/jira-groom.sh PROJ-123 --points 3

# Auto-accept AI suggestion
./scripts/jira-groom.sh PROJ-123 --auto-estimate
\`\`\`
```

---

### CJA-016: Copilot Instructions for Estimation
**Story Points**: 1  
**Priority**: High  
**Dependencies**: CJA-014

**Description**:
Update Copilot instructions to recognize estimation requests and suggest appropriate commands.

**Acceptance Criteria**:
- [ ] Update `.github/copilot-instructions.md`
- [ ] Add estimation trigger phrases
- [ ] Add team-specific context (scale, philosophy %)
- [ ] Add usage examples
- [ ] Test Copilot suggestions

**Implementation**:
```markdown
## Story Point Estimation

Team uses linear scale (0.5, 1, 2, 3, 4, 5) where 1 point = 7 focus hours.
Philosophy % determines sprint capacity (e.g., 50% = 6 points capacity).

When user asks to estimate:
- "estimate this ticket" → suggest --estimate
- "add story points" → suggest --estimate or --points
- "groom and estimate" → suggest combined command

Examples:
./scripts/jira-groom.sh RVV-1234 --estimate
./scripts/jira-groom.sh RVV-1234 --points 2
./scripts/jira-groom.sh RVV-1234 --auto-estimate
```

---

## Phase 2: Future Enhancements (Optional)

1. **AI-Powered Enhancements** (5 SP) - Partially Implemented ✅
   - ✅ AI-powered story point estimation (Epic 5)
   - Integrate OpenAI/Anthropic for smarter ticket generation
   - Suggest related tickets

2. **Confluence Bidirectional Sync** (3 SP)
   - Update Confluence when JIRA ticket changes
   - Two-way linking between platforms

3. **Slack Notifications** (2 SP)
   - Post to Slack when tickets created/closed
   - Daily sync summaries

4. **CI/CD Integration** (3 SP)
   - Auto-sync on merge to main
   - GitHub Actions workflow

**Total Phase 2**: 13 SP (6.5 SP in progress, 6.5 SP remaining)

---

**Document Version**: 5.0.0  
**Last Updated**: 2025-10-15  
**Status**: Epics 1-4 Complete ✅ | Epic 5 In Progress 🚧  
**Maintained By**: Engineering Team  
**Status**: Ready for Implementation
