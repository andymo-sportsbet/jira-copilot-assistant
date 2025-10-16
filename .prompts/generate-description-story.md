# AI Prompt: Generate Story/Feature Description

Use this prompt with Claude/Copilot to generate a business-focused story/feature description.

## Instructions for AI Agent

Read the specification file and current ticket information to generate an enhanced, user-focused story description.

### Requirements:

1. **Analyze the spec file** to extract:
   - User needs and business goals
   - Feature capabilities and functionality
   - Value proposition and benefits
   - User impact

2. **Generate a clear, user-focused description** with:
   - **Overview** - What this feature enables users to do (2-3 sentences)
   - **Background** - Business driver and user need
   - **User Value** - How this improves user experience or business outcomes
   - **Scope** - What's included and excluded (feature perspective)
   - **Key Deliverables** - Main capabilities being delivered
   - **Success Criteria** - Measurable user/business outcomes

3. **Use business language**:
   - Focus on user benefits and business value
   - Lead with "what" users can do, not "how" it's built
   - Keep it accessible to product owners and stakeholders
   - Save technical details for the technical guide

4. **Use enhanced formatting with emojis**:
   - Main title: Start with ✨ or 🎯 emoji for features
   - Section headers: Use relevant emojis (📋 🎯 📦 💼 ✅)
   - Sub-headers: Bold with `*Sub-Header:*`
   - Horizontal rules: `---` between major sections
   - Bullet points: Use `•` for better readability
   - Visual indicators: ✅ for included, ❌ for excluded
   - Keep it professional but engaging

### Example Structure:

```
✨ *[Feature Name with User Benefit]*

Brief 2-3 sentence summary focused on what users can do and the business value. 
Explain the capability being delivered and why it matters.

---

📋 *Background*

*Current Situation:*
Users currently [limitation or gap].

*User Need:*
• [User requirement 1]
• [User requirement 2]
• [Business driver]

*Why Now:*
[Timing or urgency rationale]

---

🎯 *User Value*

*Key Benefits:*
🎯 [Primary user benefit]
💼 [Business advantage]
📈 [Measurable improvement]

*What Users Can Do:*
• [Capability 1]
• [Capability 2]
• [Capability 3]

---

🎯 *Scope*

*✅ What's Included:*
• [Core capability 1]
• [Core capability 2]
• [Core capability 3]

*❌ What's NOT Included (Future):*
• [Out of scope item 1]
• [Out of scope item 2]

---

📦 *Key Deliverables*

✅ [Main deliverable 1 - user-facing capability]
✅ [Main deliverable 2 - business outcome]
✅ [Main deliverable 3 - integration/enabler]

---

💼 *Impact*

*Who Benefits:*
👥 *[User Group 1]* - [How they benefit]
📊 *[User Group 2]* - [How they benefit]
🎯 *Business* - [Business impact]

---

✅ *Success Criteria*

🎯 [Users can successfully perform X action]
🎯 [Measurable business outcome achieved]
🎯 [Adoption/usage metric met]
🎯 [Performance/quality threshold met]
```

### Output:

Generate the description following this structure, tailored to the specific feature/story from the spec file.
Output plain text only, no markdown code blocks or explanations.
