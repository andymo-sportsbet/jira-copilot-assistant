# Adding Story Point Estimation to Grooming

## Overview

The `jira-groom.sh` script now includes AI-powered story point estimation!

## How It Works

### 1. AI Analysis

The AI analyzes ticket content for:
- **Keywords**: "upgrade", "new feature", "bug fix", "refactor", etc.
- **Scope**: "multiple systems", "various components"
- **Dependencies**: "integration", "external API", "third-party"
- **Testing**: "validation", "test coverage"
- **Risk**: "critical", "production", "unknown", "new technology"
- **Documentation**: "docs", "guide", "README"

### 2. Estimation Algorithm

```
Base Score Calculation:
- Framework upgrade/migration: +8 points
- New feature: +5 points
- Bug fix: +2 points
- Config change: +1 point

Complexity Multipliers:
- Multiple systems: +3 points
- External dependencies: +3 points
- Internal dependencies: +2 points
- Testing requirements: +2 points

Risk Factors:
- Critical/production: +2 points
- High uncertainty: +3 points
- New technology: +5 points

Documentation:
- Documentation needs: +1 point

Simplicity Reducers:
- Marked as simple: -2 points
- Well-known pattern: -1 point

Final: Map to nearest Fibonacci number (1, 2, 3, 5, 8, 13, 21, 34, 55)
```

### 3. Confidence Levels

- **High Confidence**: Clear scope, well-defined requirements
- **Medium Confidence**: Some unknowns, moderate complexity
- **Low Confidence**: Many unknowns, new technology, unclear scope

## Usage

### Option 1: Add Estimation Flag

```bash
# Groom with AI estimation
./scripts/jira-groom.sh RVV-1174 --estimate

# Groom with AI description AND estimation
./scripts/jira-groom.sh RVV-1174 --ai-description .temp/description.txt --estimate

# Dry run (show estimate without updating JIRA)
./scripts/jira-groom.sh RVV-1174 --estimate --dry-run
```

### Option 2: Always Estimate (Default)

```bash
# Grooming now includes estimation by default
./scripts/jira-groom.sh RVV-1174
```

### Option 3: Skip Estimation

```bash
# Skip estimation if not desired
./scripts/jira-groom.sh RVV-1174 --no-estimate
```

## Example Output

```bash
$ ./scripts/jira-groom.sh RVV-1171 --estimate

ℹ️  Fetching ticket details for RVV-1171...
ℹ️  Ticket: [Betmaker Feed Ingestor] Spring boot upgrade
ℹ️  Searching GitHub for related PRs and commits...
⚠️  No related GitHub activity found

📊 AI Story Point Estimation
AI Estimation Analysis:
  • Framework/major change: +8
  • Multiple systems/components: +3
  • Internal dependencies: +2
  • Testing requirements: +2
  • Critical/production system: +2
  • Raw score: 17 → Fibonacci: 13

🎯 Estimated: 13 Story Points (3-5 days)

**Estimated Effort: 13 Story Points** (Very Large - 3-5 days)

This is a major change or framework upgrade. Typically includes:
• Framework/platform upgrades
• Significant system changes
• Multiple dependencies
• Extensive validation

*Note: This is an AI-generated estimate based on ticket content. Team review recommended.*

ℹ️  Generating acceptance criteria...
ℹ️  Updating ticket description...
ℹ️  Updating story points: 13

✅ Groomed: RVV-1171
✅ Added 5 acceptance criteria
✅ Set story points: 13
🔗 https://sportsbet.atlassian.net/browse/RVV-1171
```

## JIRA Field Configuration

### Finding Your Story Points Field ID

```bash
# Get ticket to find field ID
curl -u email:token \
  https://company.atlassian.net/rest/api/3/issue/PROJ-123 \
  | jq '.fields | keys[] | select(. | contains("customfield"))'

# Common field IDs:
# - customfield_10016 (most common)
# - customfield_10002
# - customfield_10026
```

### Configure in .env

```bash
# Add to .env file
JIRA_STORY_POINTS_FIELD="customfield_10016"
```

## Estimation Examples

### Example 1: Simple Bug Fix

**Ticket**: Fix typo in error message

**AI Analysis**:
```
• Bug fix: +2
• Marked as simple: -2
Raw score: 0 → Fibonacci: 1
```

**Estimate**: **1 point** (30 min - 2 hours)

### Example 2: Framework Upgrade

**Ticket**: Upgrade Spring Boot 3 - Betmaker Feed Ingestor

**AI Analysis**:
```
• Framework/major change: +8
• Multiple systems/components: +3
• Internal dependencies: +2
• Testing requirements: +2
• Critical/production system: +2
Raw score: 17 → Fibonacci: 13
```

**Estimate**: **13 points** (3-5 days)

### Example 3: New Feature

**Ticket**: Add support for new racing data provider

**AI Analysis**:
```
• New feature: +5
• External dependencies: +3
• High uncertainty: +3
• Testing requirements: +2
• Documentation: +1
Raw score: 14 → Fibonacci: 13
```

**Estimate**: **13 points** (3-5 days)
**Recommendation**: Split into smaller tasks

## Benefits

✅ **Consistency**: Same estimation criteria across all tickets
✅ **Speed**: Instant estimates for grooming sessions
✅ **Learning**: AI shows reasoning for estimate
✅ **Baseline**: Starting point for team discussion
✅ **Historical**: Track estimation accuracy over time

## Best Practices

### Do's ✅
- **Review AI estimate** - It's a suggestion, not a requirement
- **Discuss as team** - Use Planning Poker or consensus
- **Adjust based on context** - Team knows better than AI
- **Update after completion** - Improve AI over time
- **Split large tickets** - AI will suggest splitting 21+ points

### Don'ts ❌
- **Don't blindly accept** - AI is a tool, not a decision-maker
- **Don't skip discussion** - Team input is valuable
- **Don't ignore red flags** - High uncertainty = more points
- **Don't over-optimize** - 13 vs 8 is close enough

## Customization

### Adjust Estimation Factors

Edit `scripts/lib/jira-estimate.sh`:

```bash
# Increase weight for framework upgrades
if echo "$description $summary" | grep -qiE "upgrade|migration"; then
    points=$((points + 10))  # Was 8
    factors+=("Framework upgrade: +10")
fi

# Add custom keywords
if echo "$description $summary" | grep -qiE "your-custom-keyword"; then
    points=$((points + 5))
    factors+=("Custom complexity: +5")
fi
```

### Add Historical Analysis

Future enhancement: Query similar tickets and use actual effort:

```bash
# Find similar tickets
similar_tickets=$(jira_search "summary ~ \"${summary}\" AND status = Done")

# Calculate average story points
avg_points=$(echo "$similar_tickets" | jq '[.issues[].fields.customfield_10016] | add / length')
```

## See Also

- [Estimation Guide](docs/estimation-guide.md) - Complete estimation reference
- [JIRA API](https://developer.atlassian.com/cloud/jira/platform/rest/v3/) - API documentation
- [Agile Estimation](https://www.atlassian.com/agile/project-management/estimation) - Atlassian guide
