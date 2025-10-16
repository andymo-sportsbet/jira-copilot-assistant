# Enhanced Formatting in Prompt Templates

## Overview

All AI prompt templates now use **enhanced emoji-based formatting** as the default. This provides better visual hierarchy, scannability, and professional presentation while maintaining business-appropriate tone.

## Templates with Enhanced Formatting

| Template | Main Emoji | Use Case |
|----------|-----------|----------|
| `generate-description-tech-debt.md` | 🚀 | Technical debt, upgrades, refactoring |
| `generate-description-story.md` | ✨ | Features, stories, enhancements |
| `generate-description-bug.md` | 🔴🟡🟢 | Bugs, defects, issues |
| `generate-description-spike.md` | 🔍 | Research, spikes, investigations |
| `generate-description-default.md` | 🎯 | Other issue types |

## Formatting Elements

### Section Emojis

Each section uses a specific emoji for instant visual recognition:

- 🚀 **Platform/Modernization** - Main title for tech debt
- ✨ **Features** - Main title for stories
- 📋 **Background** - Context and current situation
- 🎯 **Scope/Goals** - What's included/excluded
- 📦 **Deliverables** - What will be delivered
- 💼 **Impact & Value** - Business impact and benefits
- ⚠️ **Risks** - Warnings and concerns
- 🔴 **Critical Risks** - High severity issues
- 🔗 **Dependencies** - Prerequisites and impacts
- 🔍 **Research** - Investigation and analysis
- ❓ **Questions** - Key questions to answer
- 📊 **Criteria** - Decision or success criteria
- 💡 **Outcomes** - Expected results
- ✅ **Success/Included** - Success criteria or included items
- ❌ **Excluded** - Out of scope items

### Visual Indicators

- ✅ Checkmark - Included items, success criteria, completed items
- ❌ Cross - Excluded items, not in scope
- 🔴 Red circle - Critical severity, urgent
- 🟡 Yellow circle - High priority
- 🟢 Green circle - Medium priority
- 🔵 Blue circle - Low priority
- 🎯 Target - Goals, objectives, targets
- ⚠️ Warning triangle - Risks, cautions

### Text Formatting

- **Bold headers**: `*Header*`
- **Bold sub-headers**: `*Sub-Header:*`
- **Bullet points**: Use `•` character
- **Horizontal rules**: `---`
- **Numbered lists**: For sequential steps

## Example: Tech Debt Template Output

```
🚀 *Platform Modernization: Betmaker Feed Ingestor Upgrade*

Upgrade the Betmaker Feed Ingestor service to current supported framework 
versions to ensure continued reliable ingestion of racing data.

---

📋 *Background*

*Current Situation:*
The Betmaker Feed Ingestor currently runs on framework versions 
approaching end-of-life in early 2026.

*Why This Matters:*
• Ingests real-time racing data from Betmaker
• Feeds downstream racing systems
• Maintains data accuracy for business operations

*Business Risks of Inaction:*
⚠️ Loss of vendor security patches
⚠️ Potential service instability
⚠️ Blocking future enhancements
⚠️ Increased maintenance burden

---

🎯 *Scope*

*✅ What's Included:*
• Upgrade to current framework versions
• Validate all workflows
• Update integration with shared libraries
• Test data flow to downstream systems

*❌ What's NOT Included:*
• Changes to data format or processing logic
• New features or functionality
• Infrastructure changes

---

📦 *Key Deliverables*

✅ Modernized service on vendor-supported framework
✅ Validated data ingestion with zero data loss
✅ Confirmed data flow to all downstream systems
✅ Updated operational documentation

---

💼 *Impact & Value*

*Who Benefits:*
🏁 *Racing Operations* - Continued reliable data feeds
📊 *Trading Team* - Maintained data quality
⚙️ *Platform Team* - Reduced maintenance overhead
🎯 *Business* - Reduced operational risk

*Business Value:*
• Service Continuity - Uninterrupted racing data
• Risk Reduction - Avoids security vulnerabilities
• Operational Efficiency - Improved maintainability
• Future Readiness - Platform ready for new requirements

---

⚠️ *Risks if Not Done*

🔴 *Data Feed Failure* - Risk of service failure after EOL (Q1 2026)
🔴 *Security Exposure* - No vendor patches for vulnerabilities
🔴 *Business Impact* - Potential disruption to racing operations
🔴 *Compliance Risk* - Unsupported software violates policies
🔴 *Increased Costs* - Emergency fixes become necessary

---

🔗 *Dependencies*

*Requires:*
• Shared platform libraries upgraded
• Racing BOM available
• Coordination with Betmaker for validation

*Impacts:*
• Downstream racing systems (compatibility validation needed)
• Racing platform operational procedures

---

✅ *Success Criteria*

🎯 All Betmaker racing data feeds operating normally
🎯 Data flowing correctly to all downstream systems
🎯 Service performance meets baseline metrics
🎯 Zero customer-facing impact
🎯 Operations team comfortable with procedures
🎯 Successfully deployed with rollback plan validated
```

## How to Use

### 1. Template Selection (Automatic)

```bash
./scripts/get-description-template.sh RVV-1234
```

This automatically:
- Fetches the ticket from JIRA
- Analyzes the issue type and summary
- Suggests the most appropriate template
- Opens it in VS Code

### 2. Generate Description with AI

Ask Claude/Copilot in VS Code:

```
Read specs/my-spec/spec.md and generate an enhanced description 
using .prompts/generate-description-tech-debt.md

Save the output to .temp/my-ticket-description.txt
```

The AI will follow the template and generate content with:
- ✅ Emoji section headers
- ✅ Enhanced visual hierarchy
- ✅ Sub-headers and structured content
- ✅ Professional but engaging formatting

### 3. Apply to JIRA

```bash
./scripts/jira-groom.sh RVV-1234 \
  --ai-description .temp/my-ticket-description.txt \
  --ai-guide .temp/my-ticket-technical-guide.json
```

The description is now in JIRA with enhanced formatting!

## Benefits

### 1. Scannable
- Emojis make sections instantly recognizable
- Quick to find relevant information
- Easy to skim for key points

### 2. Professional
- Clean, modern formatting
- Business-appropriate tone
- Not overwhelming or childish

### 3. Consistent
- All templates use same formatting approach
- Predictable structure across all issue types
- Easy for stakeholders to navigate

### 4. Engaging
- Visual elements increase readability
- More appealing than plain text
- Encourages thorough reading

### 5. Accessible
- Emojis are universally understood
- Clear hierarchy for screen readers
- Works across all devices and platforms

## Customization

### For Your Organization

You can customize the templates by:

1. **Changing emoji preferences**
   - Edit the template files
   - Choose emojis that match your culture

2. **Adding/removing sections**
   - Modify the example structure
   - Add organization-specific requirements

3. **Adjusting tone**
   - More formal or casual language
   - Different focus areas

4. **Creating variants**
   - Copy a template for specific use cases
   - e.g., `generate-description-bug-production.md`

### Example Customization

```bash
# Copy template
cp .prompts/generate-description-tech-debt.md \
   .prompts/generate-description-tech-debt-security.md

# Edit to add security-specific sections
# - Security Impact
# - Compliance Requirements
# - Audit Trail
```

## Best Practices

### Do's ✅

- Use emojis to enhance, not replace, clear text
- Keep formatting consistent across sections
- Focus on business value and impact
- Use visual indicators (✅❌🔴) sparingly for emphasis
- Test output in JIRA to ensure it renders correctly

### Don'ts ❌

- Don't overuse emojis (one per section header is enough)
- Don't use emojis that might be culturally inappropriate
- Don't sacrifice clarity for visual appeal
- Don't make descriptions longer just to add formatting
- Don't use complex JIRA wiki markup (panels, etc.)

## Troubleshooting

### Emojis Not Showing in JIRA

**Issue**: Emojis appear as boxes or question marks

**Solution**:
- This is rare - JIRA supports Unicode emojis
- Check your browser/system emoji support
- Emojis are in plain text, not JIRA emoticons

### AI Not Following Format

**Issue**: AI generates plain text without emojis

**Solution**:
- Ensure you specified the template file in your prompt
- Check that the template file has the enhanced examples
- Re-run with explicit instruction: "Follow the example structure exactly"

### Format Looks Different in JIRA

**Issue**: Formatting doesn't match local preview

**Solution**:
- JIRA renders plain text with limited formatting
- Bold (`*text*`) and bullets work consistently
- Emojis are plain Unicode characters
- Horizontal rules (`---`) may appear as thin lines

## Migration from Simple Format

If you have existing tickets with simple formatting:

1. **Re-groom with new template**
   ```bash
   ./scripts/jira-groom.sh RVV-1234 \
     --ai-description .temp/enhanced-description.txt
   ```

2. **Smart markers preserve manual edits**
   - Your manual notes stay above the markers
   - Only AI-generated content is replaced

3. **Gradual rollout**
   - Start with new tickets
   - Update important/visible tickets
   - Leave old tickets as-is

## Summary

Enhanced formatting is now the default for all AI-generated JIRA descriptions. This provides:

- 🎯 Better scannability
- 💼 Professional presentation
- ✅ Consistent structure
- 🚀 Engaging content
- 📊 Clear visual hierarchy

All templates have been updated, and the AI will automatically follow the enhanced format when generating descriptions!
