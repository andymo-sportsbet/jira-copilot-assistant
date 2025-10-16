# AI Agent Workflow for JIRA Ticket Enhancement

## Overview

Use Claude/Copilot in VS Code to generate intelligent, context-aware content for JIRA tickets:
1. **Enhanced Description** - Well-structured, comprehensive ticket description
2. **Technical Guide** - Detailed implementation guide as a comment

## Why This Approach?

✅ **No API costs** - Uses your existing Claude/Copilot subscription  
✅ **Better context** - AI has full workspace context  
✅ **Review before sending** - You can edit content before posting  
✅ **Faster** - No network calls during grooming  
✅ **Consistent quality** - Professional formatting every time

## Complete Workflow (Recommended)

### Step 0: Select the Right Prompt Template (Optional)

The system provides type-specific prompt templates for different JIRA issue types. Use the helper script to automatically select the appropriate template:

```bash
# Automatically select template based on issue type
./scripts/get-description-template.sh RVV-1171

# Or just print the template path
./scripts/get-description-template.sh RVV-1171 --print
```

**Available Templates:**
- `generate-description-story.md` - For Stories/Features (user value, capabilities)
- `generate-description-bug.md` - For Bugs (impact, reproduction, urgency)
- `generate-description-spike.md` - For Spikes/Research (questions, unknowns)
- `generate-description-tech-debt.md` - For Technical Debt/Tasks (ROI, modernization)
- `generate-description-default.md` - Fallback for other types

**Issue Type Mapping:**
- Story, New Feature → Story template
- Bug, Defect → Bug template  
- Spike, Research → Spike template
- Technical Debt, Improvement, Task → Tech Debt template
- Others → Default template

### Step 1: Ask AI to Generate Both Description and Guide

In VS Code, ask Claude/Copilot (using the appropriate template for your issue type):

```
Read specs/dm-adapater-springboot3/spec.md and generate:
1. An enhanced ticket description using .prompts/generate-description-tech-debt.md 
   → Save to .temp/rvv-1171-description.txt
2. A technical guide using .prompts/generate-technical-guide.md 
   → Save to .temp/rvv-1171-technical-guide.json
```

**Tip:** Use `./scripts/get-description-template.sh RVV-1171` to find the right template automatically.

### Step 2: Review the Generated Content

Claude will create both files:

```bash
# Review the description (plain text)
cat .temp/description.txt

# Validate and preview the technical guide (JSON)
jq '.' .temp/technical-guide.json

# Edit if needed
code .temp/description.txt
code .temp/technical-guide.json
```

### Step 3: Apply to JIRA Ticket

```bash
# Full AI enhancement (description + guide)
./scripts/jira-groom.sh RVV-1171 \
  --ai-description .temp/description.txt \
  --ai-guide .temp/technical-guide.json
```

## What the AI Generates

### Enhanced Description (Plain Text)

Well-structured ticket description with:
- 📝 **Overview** - Clear 2-3 sentence summary
- 📚 **Background** - Context and rationale
- 🎯 **Scope** - What's included and excluded
- 🔧 **Key Changes** - Main deliverables and changes
- 📦 **Affected Modules** - List of components
- 🔗 **Dependencies** - Prerequisites and impacts
- ✅ **Success Criteria** - Definition of done

### Technical Implementation Guide (JIRA ADF JSON)

Detailed technical guide as a formatted comment with:
- 🔧 **Technical Stack** - Languages, frameworks, versions
- 🎯 **Key Migration Changes** - Implementation details
- ⚙️ **Configuration Updates** - Config file changes
- 📦 **Module Upgrades** - Dependency updates
- ⚠️ **Known Issues** - Problems and solutions
- 🔗 **Reference Links** - Confluence, docs, PRs

## Example Output

The generated guide will render in JIRA as:

```
📋 Technical Implementation Guide
Technical reference extracted from: betmaker-ingestor-springboot3/spec.md

---

🔧 Technical Stack
• Build Tool: Gradle 8.13
• Java Version: Java 17
• Framework: Spring Boot 3.x
• Messaging: Kafka Streams API, Spring Kafka

🎯 Key Changes
• Migration from javax.* to jakarta.* namespace
• Replace cglib with ByteBuddy (cglib no longer supported)
• Kafka Streams retry mechanism refactored
• Event contracts updated - includes originTimestamp field

...
```

## See Also

- [Prompt Template](.prompts/generate-technical-guide.md) - Full instructions for AI
- [Example Output](.temp/technical-guide-example.json) - Sample AI-generated guide
- [jira-groom.sh](scripts/jira-groom.sh) - Script that applies the guide

## Alternative Methods

### Method 1: AI Agent - Full Enhancement (Recommended)
```bash
# Claude/Copilot generates description + guide → Apply to JIRA
./scripts/jira-groom.sh RVV-1171 \
  --ai-description .temp/description.txt \
  --ai-guide .temp/technical-guide.json
```

### Method 2: AI Agent - Guide Only
```bash
# Only add technical guide, keep existing description
./scripts/jira-groom.sh RVV-1171 --ai-guide .temp/technical-guide.json
```

### Method 3: Template-based (Simple, no AI)
```bash
# Uses static template for technical guide
./scripts/jira-groom.sh RVV-1171 --reference-file specs/feature/spec.md
```

### Method 4: OpenAI API (Automated, costs money)
```bash
# Set in .env: USE_LLM_GENERATION=true, OPENAI_API_KEY=sk-...
./scripts/jira-groom.sh RVV-1171 --reference-file specs/feature/spec.md
```

## Tips

1. **Edit before applying** - Review and customize the JSON before posting to JIRA
2. **Reuse templates** - Save good guides as templates for similar tickets
3. **Batch processing** - Generate multiple guides, review all, then apply
4. **Version control** - Commit good guides to `.temp/` for team reference
