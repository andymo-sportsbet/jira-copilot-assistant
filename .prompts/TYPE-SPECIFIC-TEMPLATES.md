# Type-Specific Description Templates - Summary

## What Changed

Added **type-specific prompt templates** for generating JIRA ticket descriptions based on issue type (Story, Bug, Spike, Technical Debt).

## New Files

### Prompt Templates (`.prompts/`)
- ✅ `generate-description-story.md` - For Stories/Features
- ✅ `generate-description-bug.md` - For Bugs/Defects
- ✅ `generate-description-spike.md` - For Spikes/Research
- ✅ `generate-description-tech-debt.md` - For Technical Debt/Tasks
- ✅ `generate-description-default.md` - Renamed from `generate-description.md` (fallback)
- ✅ `README.md` - Documentation for all templates

### Helper Script
- ✅ `scripts/get-description-template.sh` - Auto-selects template based on JIRA issue type

## How It Works

### 1. Template Selection

The helper script fetches the JIRA ticket and maps the issue type to the appropriate template:

```bash
./scripts/get-description-template.sh RVV-1171 --print
```

**Output:**
```
ℹ️  Fetching ticket details for RVV-1171...
ℹ️  Ticket: [Betmaker Feed Ingestor] Spring boot upgrade
ℹ️  Issue Type: Task
✅ Selected template: Technical Debt (.prompts/generate-description-tech-debt.md)
.prompts/generate-description-default.md
```

### 2. Issue Type Mapping

| JIRA Issue Type | Template | Focus |
|----------------|----------|-------|
| Story, New Feature | `story.md` | User value, capabilities, business outcomes |
| Bug, Defect | `bug.md` | Impact, reproduction steps, urgency |
| Spike, Research, Investigation | `spike.md` | Research questions, unknowns, decisions |
| Technical Debt, Improvement, Task, Refactoring | `tech-debt.md` | ROI, modernization, business impact |
| Others | `default.md` | Generic structure |

### 3. Template Differences

Each template is optimized for its issue type:

**Story/Feature Template:**
- User value and benefits
- Feature capabilities
- Business outcomes
- Success from user perspective

**Bug Template:**
- Impact and urgency (🔴🟡🟢 severity indicators)
- Reproduction steps (numbered)
- Expected vs Actual behavior
- Affected users/systems

**Spike Template:**
- Research questions (❓)
- Investigation areas (🔍)
- Decision criteria
- Expected outcomes and timeline

**Technical Debt Template:**
- Current state and pain points
- Business impact of inaction (💰)
- ROI and long-term benefits
- Effort vs value

## Usage

### Option 1: Automatic Selection (Recommended)

```bash
# Auto-select template based on issue type
./scripts/get-description-template.sh RVV-1171

# Or just get the path
TEMPLATE=$(./scripts/get-description-template.sh RVV-1171 --print)
echo "Use template: $TEMPLATE"
```

**Smart Content Analysis for "Task" Types:**
When JIRA issue type is "Task", the script automatically analyzes the ticket content:

```bash
$ ./scripts/get-description-template.sh RVV-1171 --print

ℹ️  Fetching ticket details for RVV-1171...
ℹ️  Ticket: [Betmaker Feed Ingestor] Spring boot upgrade
ℹ️  Issue Type: Task
ℹ️  Issue type is 'Task' (generic) - analyzing content to suggest best template...
✅ 🤖 Smart suggestion based on content: tech-debt
✅ Selected template: Technical Debt (.prompts/generate-description-tech-debt.md)
```

### Option 2: Manual Selection

1. Check ticket type in JIRA
2. Open appropriate template from `.prompts/`
3. Use with AI agent to generate description

### Option 3: Integrated Workflow

```bash
# 1. Find the right template
./scripts/get-description-template.sh RVV-1171

# 2. Ask AI (in VS Code with Claude/Copilot):
#    "Read specs/[spec-file] and generate description using [template-path]"

# 3. Apply to JIRA
./scripts/jira-groom.sh RVV-1171 --ai-description .temp/rvv-1171-description.txt
```

## Benefits

### 🎯 Better Context Match
- Each template optimized for its issue type
- Appropriate language and structure
- Relevant sections and emphasis

### 📝 Consistent Quality
- Standardized format per type
- Professional presentation
- Stakeholder-appropriate language

### ⚡ Faster Workflow
- Auto-select template based on issue type
- No guessing which format to use
- Clear guidance for AI generation

### 🔄 Easy Maintenance
- Separate files = easier updates
- Type-specific customization
- Clear organization

## Example Outputs

### Story/Feature
```
*🚀 [Feature Name with User Benefit]*

Brief summary focused on what users can do and business value.

*Overview*
This feature enables [users] to [capability]...

*User Value*
Key benefits:
* 🎯 [Primary user benefit]
* 💼 [Business advantage]
```

### Bug
```
*🔴 [Bug Summary with Impact]*

Brief summary of what's broken and who's affected.

*Impact*
⚠️ User Impact:
* [How users are affected]

*Reproduction Steps*
1. [Step 1]
2. [Step 2]
```

### Spike
```
*🔍 [Research Purpose]*

What unknowns need investigation and why.

*Research Questions*
❓ Key questions:
* [Question 1]
* [Question 2]

*Decision Criteria*
* 📊 [Criterion 1]
```

### Technical Debt
```
*🔧 [Technical Debt with Business Impact]*

What technical debt exists and why it matters.

*Business Impact*
💰 Costs of not addressing:
* [Velocity impact]
* [Operational costs]

*Benefits*
✅ Technical improvements:
* ⚡ [Performance gains]
```

## Documentation Updates

- ✅ `.prompts/README.md` - Template documentation
- ✅ `docs/ai-agent-workflow.md` - Updated workflow with template selection
- ✅ This summary document

## Next Steps

### Potential Enhancements

1. **Auto-generation integration**: Modify `jira-groom.sh` to automatically select and use the right template
2. **More granular types**: Add sub-types (e.g., `generate-description-bug-production.md` for urgent prod bugs)
3. **Custom templates**: Organization-specific templates in separate directory
4. **Template validation**: Lint/validate generated output against template structure

### Usage Tips

- **Review and customize**: Templates are starting points, adapt to your needs
- **Team alignment**: Get team consensus on preferred sections/language
- **Iterate**: Refine templates based on stakeholder feedback
- **Document patterns**: Add successful examples to template comments
