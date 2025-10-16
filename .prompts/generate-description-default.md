# AI Prompt: Generate Enhanced JIRA Ticket Description

Use this prompt with Claude/Copilot to generate a well-formatted, comprehensive ticket description.

## Instructions for AI Agent

Read the specification file and current ticket information to generate an enhanced, well-structured ticket description.

### Requirements:

1. **Analyze the spec file** to extract:
   - Business goals and objectives
   - Why this work matters to the organization
   - High-level scope of work
   - Impact and benefits

2. **Generate a clear, business-focused description** with:
   - **Overview** - Brief summary in business terms (2-3 sentences)
   - **Background** - Business context and rationale
   - **Scope** - What's included and excluded (business perspective)
   - **Key Deliverables** - Main outcomes (what, not how)
   - **Impact** - Who benefits and how
   - **Success Criteria** - Business outcomes, not technical metrics

3. **Use business language**:
   - Focus on "what" and "why", not "how"
   - Minimize technical jargon (save for technical guide comment)
   - Speak to business value and outcomes
   - Keep it accessible to non-technical stakeholders

4. **Use enhanced formatting with emojis**:
   - Main title: Start with relevant emoji (🚀 ✨ 📋 🎯)
   - Section headers: Use relevant emojis for each section
   - Sub-headers: Bold with `*Sub-Header:*`
   - Horizontal rules: `---` between major sections
   - Bullet points: Use `•` for better readability
   - Visual indicators: ✅ for included/completed, ❌ for excluded
   - Keep it professional, scannable, and visually appealing

### Example Structure:

```
🎯 *[Title with Business Context]*

Brief 2-3 sentence summary focused on business value and purpose. Explain what this 
work accomplishes and why it matters to the organization.

---

📋 *Background*

*Current Situation:*
[Description of current state]

*Why This Matters:*
• [Business reason 1]
• [Business reason 2]
• [Impact or urgency]

---

🎯 *Scope*

*✅ What's Included:*
• [Item 1]
• [Item 2]
• [Item 3]

*❌ What's NOT Included:*
• [Out of scope 1]
• [Out of scope 2]

---

📦 *Key Deliverables*

✅ [Deliverable 1]
✅ [Deliverable 2]
✅ [Deliverable 3]

---

💼 *Impact & Value*

*Who Benefits:*
👥 *[Group 1]* - [Benefit]
📊 *[Group 2]* - [Benefit]

*Business Value:*
• [Value proposition 1]
• [Value proposition 2]

---

✅ *Success Criteria*

🎯 [Criterion 1]
🎯 [Criterion 2]
🎯 [Criterion 3]

h4. 📋 Background

Current situation and why this work is needed now. Focus on business drivers.

{panel:title=Business Risks|borderStyle=solid|borderColor=#ffab00|titleBGColor=#fff4e5|bgColor=#fffef7}
* Risk 1 - Why this matters
* Risk 2 - Business impact
* Risk 3 - Consequences
{panel}

----

h4. 🎯 Scope

{panel:title=What's Included ✅|borderStyle=solid|borderColor=#00875a|titleBGColor=#e3fcef|bgColor=#f6fff9}
* Deliverable 1 (business outcome)
* Deliverable 2 (business outcome)
* Deliverable 3 (business outcome)
{panel}

{panel:title=What's NOT Included ⛔|borderStyle=solid|borderColor=#6554c0|titleBGColor=#eae6ff|bgColor=#f4f5f7}
* Out of scope item 1
* Out of scope item 2
{panel}

----

h4. 🚀 Key Deliverables

* ✅ Deliverable 1 - What and why
* ✅ Deliverable 2 - What and why
* ✅ Deliverable 3 - What and why

----

h4. 💡 Impact & Value

*Who Benefits:*

{info:title=Team/Department 1}
How they benefit
{info}

{info:title=Team/Department 2}
How they benefit
{info}

*Business Value:*
* 🔒 *Value 1* - Description
* 🛡️ *Value 2* - Description
* ⚡ *Value 3* - Description

----

h4. ⚠️ Risks if Not Done

{warning:title=Critical Risks}
* *Risk 1* - Business impact description
* *Risk 2* - Business impact description
* *Risk 3* - Business impact description
{warning}

----

h4. 🔗 Dependencies

*Requires:*
* Prerequisite 1
* Prerequisite 2

*Impacts:*
* System/team affected
* Coordination needed

----

h4. ✅ Success Criteria

{success:title=Definition of Done}
✓ Success criterion 1 (business outcome)
✓ Success criterion 2 (business outcome)
✓ Success criterion 3 (business outcome)
{success}

----

h4. 📚 References

[Confluence: Spec Title|URL]

*Component:* Service/System name
*Technical Lead:* Name
*Note:* ⚙️ Technical implementation details provided in separate comment below
```

### Example Usage:

**You say to Claude/Copilot:**
> "Read `specs/dm-adapater-springboot3/spec.md` and generate an enhanced JIRA description for ticket [TICKET-NAME] using the template in `.prompts/generate-description.md`. Focus on business language, use JIRA wiki markup with panels and emojis for visual appeal. Save the output to `.temp/description.txt`"

**Claude will:**
1. Read the spec file
2. Understand the ticket context and business goals
3. Generate a well-structured, visually appealing description with JIRA formatting
4. Use panels, info boxes, warnings, and emojis for better readability
5. Focus on business value and outcomes (not technical implementation)
6. Save to `.temp/description.txt` as plain text with JIRA wiki markup

**You then run:**
```bash
./scripts/jira-groom.sh RVV-1171 \
  --ai-description .temp/description.txt \
  --ai-guide .temp/technical-guide.json
```

## Tips:

1. **Business first** - Focus on outcomes and value, not implementation details
2. **Keep it scannable** - Use headers and bullets liberally
3. **Avoid jargon** - Write for product owners and stakeholders, not just developers
4. **Explain impact** - Who benefits and how?
5. **Think like a stakeholder** - Why should we prioritize this work?
6. **Highlight risks** - What happens if we don't do this?
7. **Be concise** - Save technical details for the technical guide comment

## Output Format:

- Must be plain text (not JSON)
- Use JIRA wiki markup formatting:
  - `h3.` for main title, `h4.` for section headers
  - `----` for horizontal rules (4 dashes)
  - `*text*` for bold
  - `_text_` for italic
  - `* ` for bullet points
  - `{panel:title=...}content{panel}` for highlighted boxes
  - `{info:title=...}content{info}` for info boxes (blue)
  - `{warning:title=...}content{warning}` for warning boxes (yellow/red)
  - `{success:title=...}content{success}` for success boxes (green)
  - `[Link Text|URL]` for hyperlinks
  - Emojis: 📋 🎯 🚀 💡 ⚠️ 🔗 ✅ 🔒 🛡️ ⚡ 🔮
- Panel colors for visual hierarchy:
  - Green panels for "What's Included" (positive)
  - Purple/Gray panels for "What's NOT Included" (neutral)
  - Yellow panels for "Business Risks" (caution)
  - Blue info boxes for benefits
  - Red warning boxes for risks
  - Green success boxes for criteria
- Save to `.temp/description.txt`
- File will be read by `jira-groom.sh --ai-description`

## What to Avoid:

- ❌ Technical implementation details (save for technical guide comment)
- ❌ Code examples, library versions, technical stack details
- ❌ Low-level architecture or design decisions
- ❌ Detailed module/component breakdowns
- ❌ Build tool or configuration specifics
- ❌ Testing strategy details
- ❌ Time estimates or sprint planning info
- ❌ Duplicating acceptance criteria content

## What to Focus On:

- ✅ Business value and outcomes
- ✅ Why this work is important now
- ✅ Who benefits and how
- ✅ High-level scope and deliverables
- ✅ Dependencies and impacts on other work
- ✅ Risks of not doing this work
- ✅ Clear, accessible language
