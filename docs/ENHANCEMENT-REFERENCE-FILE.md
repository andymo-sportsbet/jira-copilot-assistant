# Enhancement: Reference File Support for jira-groom.sh

**Date**: 2025-10-14  
**Feature**: Added `--reference-file` parameter to `jira-groom.sh`  
**Status**: ✅ Complete

---

## Overview

The `jira-groom.sh` script now accepts a `--reference-file` parameter to include technical implementation details from a spec file when grooming JIRA tickets.

This enhancement enables a powerful workflow:
1. Save Confluence page as local spec file
2. Groom existing JIRA ticket with technical details from the spec
3. Automatically extract and format relevant sections as a comment

---

## What Changed

### Before
```bash
# Only basic grooming with acceptance criteria
./scripts/jira-groom.sh PROJ-123
```

**Result**: 
- 5 generic acceptance criteria
- GitHub PR/commit references (if found)
- Basic grooming comment

### After
```bash
# Groom with technical reference
./scripts/jira-groom.sh PROJ-123 --reference-file specs/feature/spec.md
```

**Result**:
- 5 generic acceptance criteria
- GitHub PR/commit references (if found)
- **Technical implementation guide extracted from spec file**
- **Structured comment with Overview, Requirements, Technical Details**

---

## New Parameter

### `--reference-file FILE`

**Purpose**: Path to a markdown spec file containing technical implementation details

**Supported Formats**:
- Markdown files (`.md`)
- YAML front matter (optional, from Confluence metadata)
- Structured sections: Overview, Requirements, Technical Details

**Best Used With**:
- Specs created by `confluence-to-spec.sh`
- Any structured markdown documentation
- Technical design documents

---

## How It Works

### 1. Extraction Process

The script extracts these sections from the reference file:

```markdown
## Overview
[Extracted content]

## Requirements  
[Extracted content]

## Technical Details
[Extracted content]

- [ ] Checklist items
[Extracted if present]
```

### 2. Comment Format

Creates a structured technical guide comment:

```markdown
## Technical Implementation Guide

### Reference Documentation
Based on: [Confluence URL from YAML front matter]

---

### Overview
[Extracted overview section]

### Key Requirements
[Extracted requirements section]

### Technical Details
[Extracted technical details section]

### Implementation Checklist
[Extracted checklist items]

---
_Technical reference extracted from: spec.md_
```

### 3. Grooming Summary

Updates the main grooming comment to include:
```
🤖 Ticket Groomed by JIRA Copilot Assistant

Added:
* 5 acceptance criteria
* 2 related PR reference(s)
* Technical implementation guide from reference spec

The ticket has been enhanced with additional context and requirements.
```

---

## Usage Examples

### Example 1: Confluence → Spec → Groom Workflow

**Scenario**: You have a Confluence page with upgrade instructions and an existing JIRA ticket

```bash
# Step 1: Save Confluence page as spec
./scripts/confluence-to-spec.sh \
  --url "https://company.atlassian.net/wiki/spaces/TECH/pages/123456/" \
  --output "specs/springboot-upgrade/spec.md"

# Step 2: Groom ticket with technical details
./scripts/jira-groom.sh RVV-1171 \
  --reference-file "specs/springboot-upgrade/spec.md"
```

**Result**:
- ✅ Spec file saved locally (version controlled)
- ✅ Ticket groomed with acceptance criteria
- ✅ Technical implementation guide added as comment
- ✅ Confluence URL preserved in reference

### Example 2: Existing Spec File

**Scenario**: You already have a technical spec and want to groom a ticket

```bash
./scripts/jira-groom.sh PROJ-456 \
  --reference-file "specs/001-payment-feature/spec.md"
```

**Result**:
- Extracts technical details from existing spec
- Adds structured guide to ticket
- No need to manually copy-paste content

### Example 3: Basic Grooming (No Reference)

**Scenario**: Quick grooming without technical details

```bash
./scripts/jira-groom.sh PROJ-789
```

**Result**:
- Standard grooming with acceptance criteria
- GitHub references (if found)
- No additional technical guide

---

## Real-World Example: Betmaker Ingestor Spring Boot 3 Upgrade

### Problem
- Confluence page with detailed upgrade instructions
- Existing JIRA ticket (RVV-1171) needs technical guidance
- Manual copy-paste is error-prone and time-consuming

### Solution

```bash
# 1. Save Confluence reference
./scripts/confluence-to-spec.sh \
  --url "https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/DM+Adapters+Springboot+Upgrade" \
  --output "specs/betmaker-ingestor-springboot3/spec.md"

# 2. Groom ticket with reference
./scripts/jira-groom.sh RVV-1171 \
  --reference-file "specs/betmaker-ingestor-springboot3/spec.md"
```

### Result
- ✅ Spec file created with full Confluence content (5,550 characters)
- ✅ Ticket groomed with acceptance criteria
- ✅ Technical guide added with:
  - Gradle 8.13, Java 17, Spring Boot 3.x requirements
  - Jakarta migration steps
  - Library upgrade instructions
  - Event contract updates
  - Configuration changes
  - Testing checklist
- ✅ Confluence URL preserved for traceability

---

## Benefits

### 1. Consistency
- Standardized way to add technical details to tickets
- Same extraction logic for all spec files
- Predictable comment format

### 2. Traceability
- Preserves link to source documentation
- Version-controlled spec files
- Easy to update and track changes

### 3. Efficiency
- No manual copy-paste
- Automatic section extraction
- One command to groom + add technical guide

### 4. Integration
- Works seamlessly with `confluence-to-spec.sh`
- Compatible with existing grooming workflow
- Optional parameter (backward compatible)

---

## Technical Implementation

### Code Changes

**File**: `scripts/jira-groom.sh`

**Added**:
1. **Parameter Parsing**: 
   - `--reference-file FILE` option
   - Validation of file existence

2. **`extract_technical_details()` Function**:
   - Reads markdown file
   - Extracts YAML front matter (Confluence URL)
   - Parses sections: Overview, Requirements, Technical Details
   - Finds checklist items
   - Formats as structured guide

3. **Enhanced Main Function**:
   - Calls extraction if reference file provided
   - Adds technical guide as separate comment
   - Updates success output

**Lines Added**: ~70 lines
**Backward Compatible**: Yes (optional parameter)

---

## Updated Help Message

```
Usage: jira-groom.sh <TICKET-KEY> [OPTIONS]

Groom a JIRA ticket by:
  1. Fetching ticket details from JIRA
  2. Searching GitHub for related PRs and commits
  3. Generating additional acceptance criteria
  4. Optionally including technical details from a reference spec file
  5. Updating the ticket with enhancements

Arguments:
  TICKET-KEY                JIRA ticket key (e.g., PROJ-123)

Options:
  --reference-file FILE     Path to spec file with technical implementation details
  --help, -h               Show this help message

Examples:
  # Basic grooming
  jira-groom.sh PROJ-123
  
  # Groom with technical reference from spec file
  jira-groom.sh RVV-1171 --reference-file specs/betmaker-ingestor-springboot3/spec.md
  
  # After saving Confluence as spec
  ./scripts/confluence-to-spec.sh --url "..." --output specs/feature/spec.md
  jira-groom.sh PROJ-456 --reference-file specs/feature/spec.md
```

---

## Workflow Diagrams

### Standard Grooming Flow
```
┌─────────────────┐
│  JIRA Ticket    │
│   PROJ-123      │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│  ./scripts/jira-groom.sh    │
│  PROJ-123                   │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  Ticket Enhanced            │
│  ✓ Acceptance Criteria      │
│  ✓ GitHub References        │
└─────────────────────────────┘
```

### Enhanced Flow with Reference File
```
┌─────────────────┐     ┌──────────────────────┐
│ Confluence Page │────▶│ confluence-to-spec   │
│   Technical     │     │ --output spec.md     │
└─────────────────┘     └──────┬───────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │  spec.md     │
                        │  (version    │
                        │   control)   │
                        └──────┬───────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
┌─────────────────┐     ┌─────────────────┐  ┌─────────────────┐
│  Review & Edit  │     │  JIRA Ticket    │  │  Share via PR   │
│  Locally        │     │  RVV-1171       │  │  with Team      │
└─────────────────┘     └────────┬────────┘  └─────────────────┘
                                 │
                                 ▼
                        ┌─────────────────────────────┐
                        │  jira-groom.sh RVV-1171     │
                        │  --reference-file spec.md   │
                        └────────┬────────────────────┘
                                 │
                                 ▼
                        ┌─────────────────────────────┐
                        │  Ticket Groomed             │
                        │  ✓ Acceptance Criteria      │
                        │  ✓ GitHub References        │
                        │  ✓ Technical Guide (from    │
                        │    spec: Overview, Reqs,    │
                        │    Technical Details)       │
                        │  ✓ Confluence Link          │
                        └─────────────────────────────┘
```

---

## Next Steps

### Potential Enhancements
1. **AI-Powered Extraction**: Use LLM to summarize technical details
2. **Custom Section Mapping**: Allow users to specify which sections to extract
3. **Template Support**: Define templates for different spec types
4. **Multi-File Support**: Accept multiple reference files
5. **Update Description**: Optionally update ticket description (not just comments)

### Documentation Updates Needed
- [x] Update `jira-groom.sh` help message
- [ ] Update `docs/onboard/user-guide.md` with --reference-file examples
- [ ] Update `README.md` features table
- [ ] Add to Copilot instructions for natural language triggering

---

## Testing

### Manual Test Cases

✅ **Test 1: Basic grooming (no reference)**
```bash
./scripts/jira-groom.sh PROJ-123
# Expected: Standard grooming, no tech guide
```

✅ **Test 2: With reference file**
```bash
./scripts/jira-groom.sh PROJ-123 --reference-file specs/test/spec.md
# Expected: Grooming + technical guide comment
```

✅ **Test 3: Invalid reference file**
```bash
./scripts/jira-groom.sh PROJ-123 --reference-file nonexistent.md
# Expected: Error message, exit 1
```

✅ **Test 4: Help message**
```bash
./scripts/jira-groom.sh --help
# Expected: Shows new --reference-file option
```

✅ **Test 5: Real-world Confluence spec**
```bash
./scripts/confluence-to-spec.sh --url "..." --output specs/feature/spec.md
./scripts/jira-groom.sh PROJ-456 --reference-file specs/feature/spec.md
# Expected: Confluence URL in guide, structured sections
```

---

## Summary

✅ **Enhancement Complete**

**What was added**:
- `--reference-file` parameter to `jira-groom.sh`
- Technical details extraction from spec files
- Structured implementation guide as JIRA comment
- Preservation of Confluence URL for traceability

**Benefits**:
- Eliminates manual copy-paste
- Standardized technical guidance in tickets
- Seamless integration with `confluence-to-spec.sh`
- Version-controlled spec files linked to tickets

**Usage**:
```bash
./scripts/jira-groom.sh <TICKET-KEY> --reference-file <SPEC-FILE>
```

**Perfect for**:
- Adding upgrade/migration guides to tickets
- Linking Confluence technical docs to JIRA
- Grooming tickets with implementation details
- Building knowledge base from Confluence in version control

🎉 **The JIRA Copilot Assistant just got smarter!**
