# AI Prompt: Generate Technical Debt Description

Use this prompt with Claude/Copilot to generate a compelling technical debt ticket description.

## Instructions for AI Agent

Read the specification file and current ticket information to generate a clear technical debt description that communicates technical context while emphasizing business value.

### Requirements:

1. **Analyze the spec file** to extract:
   - What technical debt exists and why
   - Current pain points and risks
   - Business impact of not addressing it
   - Long-term benefits of resolving it

2. **Generate a balanced, value-focused description** with:
   - **Overview** - What debt exists and why it matters (2-3 sentences)
   - **Current State** - The technical problem and its symptoms
   - **Business Impact** - Risks, costs, and inefficiencies
   - **Proposed Improvement** - What will be done (high-level)
   - **Benefits** - Technical and business value of fixing this
   - **Success Criteria** - How we measure improvement

3. **Use balanced language**:
   - Start with business impact, then technical context
   - Explain risks and costs of inaction
   - Quantify impact when possible (velocity, incidents, maintenance time)
   - Show ROI: effort vs. long-term benefits
   - Technical accuracy but accessible to non-technical stakeholders

4. **Use enhanced formatting with emojis**:
   - Main title: Start with 🚀 emoji
   - Section headers: Use relevant emojis (📋 📦 🎯 💼 ⚠️ 🔗 ✅)
   - Sub-headers: Bold with `*Sub-Header:*`
   - Horizontal rules: `---` between major sections
   - Bullet points: Use `•` for better readability
   - Visual indicators: ✅ for included, ❌ for excluded, 🔴 for critical risks
   - Keep it professional but engaging

### Example Structure:

```
� *[Technical Debt Title with Business Impact]*

Brief 2-3 sentence summary of the technical debt and why addressing it matters. 
Lead with business impact, then technical context.

---

📋 *Background*

*Current Situation:*
The [system/component] currently runs on [outdated technology/approach].

*Why This Matters:*
• [Business-critical function 1]
• [Business-critical function 2]
• [Impact on operations]

*Business Risks of Inaction:*
⚠️ [Risk 1 - vendor support, security]
⚠️ [Risk 2 - service stability]
⚠️ [Risk 3 - blocking future work]
⚠️ [Risk 4 - maintenance burden]

This upgrade ensures [service remains supported, secure, ready for future needs].

---

🎯 *Scope*

*✅ What's Included:*
• [Main change 1]
• [Main change 2]
• [Testing/validation approach]
• [Documentation updates]
• [Operational changes]

*❌ What's NOT Included:*
• [Out of scope item 1]
• [Out of scope item 2]
• [Future work or enhancements]
• [Other system changes]

---

📦 *Key Deliverables*

✅ [Main deliverable 1 - modernized system]
✅ [Deliverable 2 - validated functionality]
✅ [Deliverable 3 - confirmed compatibility]
✅ [Deliverable 4 - updated documentation]
✅ [Deliverable 5 - performance validated]

---

💼 *Impact & Value*

*Who Benefits:*
🏢 *[Team 1]* - [Specific benefit]
📊 *[Team 2]* - [Specific benefit]
⚙️ *[Team 3]* - [Specific benefit]
🎯 *Business* - [Overall business benefit]

*Business Value:*
• *[Value 1]* - [Description]
• *[Value 2]* - [Description]
• *[Value 3]* - [Description]
• *[Value 4]* - [Description]

---

⚠️ *Risks if Not Done*

🔴 *[Critical Risk 1]* - [Description and timeline]
🔴 *[Critical Risk 2]* - [Description and impact]
🔴 *[Critical Risk 3]* - [Description and consequences]
🔴 *[Critical Risk 4]* - [Description and costs]
🔴 *[Critical Risk 5]* - [Description and implications]

---

🔗 *Dependencies*

*Requires:*
• [Prerequisite 1]
• [Prerequisite 2]
• [Coordination needed]

*Impacts:*
• [Downstream system 1]
• [Downstream system 2]
• [Related components]

---

✅ *Success Criteria*

🎯 [Criterion 1 - functionality working correctly]
🎯 [Criterion 2 - data/integration validated]
🎯 [Criterion 3 - performance metrics met]
🎯 [Criterion 4 - zero customer impact]
🎯 [Criterion 5 - operational readiness]
🎯 [Criterion 6 - deployment success]

*Success Criteria*

This work is successful when:
* ✅ [Measurable technical improvement - e.g., reduced build time]
* 📉 [Reduction in incidents/issues]
* 🚀 [Developer velocity improvement]
* 💡 [New capabilities enabled]

*Effort vs. ROI*

Estimated effort: [Time/complexity]
Expected ROI: [Long-term savings and benefits]
Why now: [Timing rationale - window of opportunity, risk threshold, etc.]
```

### Output:

Generate the description following this structure, tailored to the specific technical debt from the spec file.
Balance technical accuracy with business accessibility - stakeholders should understand the value.
Output plain text only, no markdown code blocks or explanations.
