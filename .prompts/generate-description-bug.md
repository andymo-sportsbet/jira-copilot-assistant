# AI Prompt: Generate Bug Description

Use this prompt with Claude/Copilot to generate a clear, actionable bug description.

## Instructions for AI Agent

Read the specification file (if available) and current ticket information to generate an enhanced bug description focused on impact, reproduction, and urgency.

### Requirements:

1. **Analyze the available information** to extract:
   - What is broken or not working as expected
   - User/business impact of the issue
   - Affected systems, features, or users
   - Urgency and severity indicators

2. **Generate a clear, impact-focused description** with:
   - **Summary** - What's broken and who's affected (2-3 sentences)
   - **Impact** - Business and user consequences
   - **Reproduction Steps** - How to observe the issue (if known)
   - **Expected vs Actual Behavior** - What should happen vs what does happen
   - **Affected Scope** - Systems, features, users impacted
   - **Root Cause** - Initial hypothesis (if known)

3. **Use clear, urgent language**:
   - Lead with impact and urgency
   - Be specific about what's broken
   - Quantify impact when possible (% of users, $ value, etc.)
   - Use severity indicators appropriately

4. **Use enhanced formatting with emojis**:
   - Main title: Start with 🔴/🟡/🟢 based on severity
   - Section headers: Use relevant emojis (⚠️ 🔍 📋 🎯)
   - Sub-headers: Bold with `*Sub-Header:*`
   - Horizontal rules: `---` between major sections
   - Bullet points: Use `•` for better readability
   - Numbered lists: For reproduction steps
   - Severity indicators: 🔴 Critical, 🟡 High, 🟢 Medium, 🔵 Low

### Example Structure:

```
🔴 *[Bug Summary with Impact]*

Brief 2-3 sentence summary of what's broken, who's affected, and the severity. 
Be specific and lead with business impact.

---

⚠️ *Impact*

*User Impact:*
• [How users are affected]
• [Frequency or scale]
• [Workaround if available]

*Business Impact:*
💼 [Revenue/operational impact]
📊 [Affected systems or workflows]
⏱️ [Time-sensitive factors]

---

🔍 *Reproduction Steps*

*To reproduce the issue:*
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. Observe: [What happens]

*Environment:*
• [Production/Staging/etc]
• [Browser/Platform if relevant]
• [Specific conditions]

---

📋 *Expected vs Actual Behavior*

*✅ Expected:*
• [What should happen]
• [Correct behavior]

*❌ Actual:*
• [What actually happens]
• [Incorrect behavior]
• [Error messages if any]

---

🎯 *Affected Scope*

*Systems/Features:*
• [Affected system 1]
• [Affected feature 2]
• [Integration point 3]

*Users/Environment:*
• [User segment or % affected]
• [Environment (prod/stage/all)]
• [Timeframe or conditions]

---

💡 *Root Cause (Initial Assessment)*

*Current hypothesis:*
• [Suspected cause based on symptoms]
• [Related changes or events]
• [Investigation needed]

---

🎯 *Priority*

*Severity:* 🔴 Critical / 🟡 High / 🟢 Medium / 🔵 Low
*Reasoning:* [Why this priority level]
*Timeline:* [Expected fix timeframe]
```

### Output:

Generate the description following this structure, tailored to the specific bug from available information.
If reproduction steps or root cause are unknown, note "Under investigation" rather than guessing.
Output plain text only, no markdown code blocks or explanations.
