# JIRA Description Prompt Templates

This directory contains AI prompt templates for generating JIRA ticket descriptions tailored to different issue types.

## Available Templates

### By Issue Type

| Template File | JIRA Issue Type | Focus | When to Use |
|--------------|-----------------|-------|-------------|
| `generate-description-story.md` | Story, New Feature | User value, business benefits, feature capabilities | User-facing features, new functionality |
| `generate-description-bug.md` | Bug, Defect | Impact, reproduction, urgency | Issues, defects, broken functionality |
| `generate-description-spike.md` | Spike, Research, Investigation | Research questions, unknowns, decisions | Technical research, proof of concepts, investigations |
| `generate-description-tech-debt.md` | Technical Debt, Improvement | Business impact, ROI, long-term benefits | Refactoring, modernization, code quality |
| `generate-description-default.md` | Any (fallback) | General structure | When specific type template doesn't exist |

### Technical Guide

| Template File | Purpose | Format |
|--------------|---------|--------|
| `generate-technical-guide.md` | Detailed implementation guide | JIRA ADF JSON |

## Usage

### Option 1: Automatic Selection (Recommended)

The script automatically selects the appropriate template, with **smart content analysis** for generic "Task" types:

```bash
# Auto-select template - analyzes content for "Task" types
./scripts/get-description-template.sh RVV-1171
# Opens the right template in VS Code

# Or just get the path
./scripts/get-description-template.sh RVV-1171 --print
# Returns: .prompts/generate-description-tech-debt.md
```

**Smart Detection for "Task" Issue Types:**
When the JIRA issue type is "Task" (generic), the script automatically analyzes the ticket summary and description to suggest the best template:

- "Spring Boot upgrade" → Tech Debt template ✅
- "Investigate Kafka performance" → Spike/Research template
- "User cannot login" → Bug template  
- "Add CSV export feature" → Story/Feature template

**Detection Keywords (Priority Order):**
1. **Tech Debt** (specific): upgrade, migration, spring boot, java, update version
2. **Spike**: spike, research, investigate, POC, evaluate
3. **Bug**: bug, defect, broken, error, crash, not working
4. **Story**: feature, enhancement, user story, new functionality
5. **Tech Debt** (broad): refactor, improve, cleanup, technical debt

### Option 2: Manual Selection

1. Identify the JIRA issue type (Story, Bug, Spike, Technical Debt)
2. Open the corresponding prompt template
3. Use with AI agent (Claude/Copilot) to generate description
4. Save output to `.temp/[ticket-id]-description.txt`
5. Apply with: `./scripts/jira-groom.sh [TICKET] --ai-description .temp/[ticket-id]-description.txt`

### Option 2: Automatic Selection (Future Enhancement)

The script could automatically select the appropriate template based on issue type:

```bash
# Script extracts issue type from JIRA
issue_type=$(echo "$ticket_data" | jq -r '.fields.issuetype.name')

# Maps to template file
case "${issue_type,,}" in
    "story"|"new feature")
        prompt_template=".prompts/generate-description-story.md"
        ;;
    "bug"|"defect")
        prompt_template=".prompts/generate-description-bug.md"
        ;;
    "spike"|"research"|"investigation")
        prompt_template=".prompts/generate-description-spike.md"
        ;;
    "technical debt"|"improvement"|"tech debt")
        prompt_template=".prompts/generate-description-tech-debt.md"
        ;;
    *)
        prompt_template=".prompts/generate-description-default.md"
        ;;
esac
```

## Template Structure

Each template follows a consistent structure but tailored to the issue type:

### Common Elements
- **Overview/Purpose** - What and why (2-3 sentences)
- **Context/Background** - Relevant background information
- **Main Content** - Type-specific sections
- **Outcomes** - Expected results or success criteria

### Type-Specific Differences

**Story/Feature:**
- User value and benefits
- Feature capabilities
- Business outcomes

**Bug:**
- Impact and urgency
- Reproduction steps
- Expected vs actual behavior

**Spike:**
- Research questions
- Investigation areas
- Decision criteria

**Technical Debt:**
- Current pain points
- Business impact of inaction
- ROI and long-term benefits

## Formatting Guidelines

All templates use simple JIRA text formatting:

- Section headers: `*Bold*`
- Bullet points: `*` prefix
- Horizontal rules: `---`
- Emojis: Visual indicators (🎯 ⚠️ ✅ 🔍 etc.)

**Note:** Complex JIRA wiki markup (`h3.`, panels, colored boxes) was removed for better readability.

## Customization

To customize for your organization:

1. **Adjust tone**: Modify the language style to match your team's culture
2. **Add sections**: Include organization-specific sections (e.g., compliance, security)
3. **Change structure**: Reorder sections based on priorities
4. **Update emojis**: Use emojis that resonate with your team

## Best Practices

1. **Read the spec file first** - Ensure AI has context before generating
2. **Review and edit** - AI-generated content is a starting point, not final
3. **Keep it concise** - Stakeholders prefer scannable over comprehensive
4. **Focus on value** - Lead with business impact, save technical details for guide
5. **Use appropriate template** - Match template to issue type for best results

## Integration with AI Agent Workflow

See `docs/ai-agent-workflow.md` for complete workflow:

1. **Select template** based on issue type
2. **Generate description** using AI agent + spec file
3. **Generate technical guide** (optional) for implementation details
4. **Apply to JIRA** using `--ai-description` and `--ai-guide` flags

## Future Enhancements

- [ ] Automatic template selection based on JIRA issue type
- [ ] Interactive template chooser
- [ ] Organization-specific templates
- [ ] Template validation and linting
- [ ] Multi-language support
