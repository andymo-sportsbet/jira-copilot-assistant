# AI Prompt: Generate Spike/Research Description

Use this prompt with Claude/Copilot to generate a focused spike/research ticket description.

## Instructions for AI Agent

Read the specification file and current ticket information to generate a clear spike description focused on research questions, unknowns, and decision criteria.

### Requirements:

1. **Analyze the spec file** to extract:
   - What unknowns need investigation
   - Key questions to answer
   - Decision points or options to evaluate
   - Success criteria for the research

2. **Generate a clear, research-focused description** with:
   - **Purpose** - What we need to learn and why (2-3 sentences)
   - **Research Questions** - Specific questions to answer
   - **Investigation Areas** - What to explore and analyze
   - **Decision Criteria** - How findings will be evaluated
   - **Expected Outcomes** - What deliverables/decisions result from this
   - **Success Criteria** - How we know the spike is complete

3. **Use exploratory language**:
   - Frame as questions and investigations, not solutions
   - Focus on reducing uncertainty
   - Identify trade-offs and options to evaluate
   - Be clear about what decisions this enables

4. **Use enhanced formatting with emojis**:
   - Main title: Start with 🔍 emoji for research
   - Section headers: Use relevant emojis (❓ 🔍 📊 💡 ✅)
   - Sub-headers: Bold with `*Sub-Header:*`
   - Horizontal rules: `---` between major sections
   - Bullet points: Use `•` for better readability
   - Questions: Use ❓ prefix for key questions
   - Keep it focused on exploration and learning

### Example Structure:

```
🔍 *[Spike/Research Purpose]*

Brief 2-3 sentence summary of what unknowns need investigation and why this research 
is needed now. Explain what decision or work this enables.

---

📋 *Purpose*

*What We Need to Learn:*
We need to investigate [topic/area] to determine [decision/approach] before we can 
[next step]. This spike reduces risk by answering [key unknowns].

*Why Now:*
• [Timing driver]
• [Blocking factors]
• [Risk mitigation]

---

❓ *Research Questions*

*Key Questions to Answer:*
❓ [Primary question 1]
❓ [Primary question 2]
❓ [Primary question 3]

*Additional Considerations:*
• [Secondary question 1]
• [Secondary question 2]
• [Secondary question 3]

---

🔍 *Investigation Areas*

*What to Explore:*

*Technical Evaluation:*
• [Technology/approach option 1]
• [Technology/approach option 2]
• [Existing solution/pattern review]

*Analysis Required:*
• [Performance/scalability assessment]
• [Integration complexity review]
• [Risk and trade-off analysis]

---

📊 *Decision Criteria*

*Evaluate options based on:*
📊 [Criterion 1 - e.g., performance requirements]
💰 [Criterion 2 - e.g., cost/complexity]
⚡ [Criterion 3 - e.g., time to implement]
🔗 [Criterion 4 - e.g., integration ease]
🎯 [Criterion 5 - e.g., business fit]

---

💡 *Expected Outcomes*

*Research Deliverables:*
✅ [Document/report on findings]
✅ [Recommendation with pros/cons]
✅ [Prototype or proof of concept (if applicable)]
✅ [Decision on approach/direction]

---

✅ *Success Criteria*

🎯 All key research questions are answered
🎯 Options are evaluated against criteria
🎯 Clear recommendation is documented
🎯 Team has confidence to proceed with implementation
🎯 Risks and trade-offs are well understood

---

⏱️ *Timeline*

*Timeboxed to:* [X days/sprint]
*Reason:* [Why this timeframe - balance thoroughness with delivery needs]
```

### Output:

Generate the description following this structure, tailored to the specific spike/research from the spec file.
Frame everything as exploration and investigation, not implementation.
Output plain text only, no markdown code blocks or explanations.
