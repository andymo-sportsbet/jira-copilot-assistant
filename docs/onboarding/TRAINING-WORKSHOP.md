# JIRA Copilot Assistant - Training Workshop Outline
## Hands-On Session Plan (2 Hours)

---

## 🎯 Workshop Overview

**Duration:** 2 hours  
**Format:** Hands-on, interactive  
**Audience:** Developers, BAs, Engineering Managers  
**Prerequisites:** Laptop with terminal access  
**Group Size:** 5-15 participants

---

## 📋 Pre-Workshop Setup (Send 1 Week Before)

### Email to Participants

**Subject:** JIRA Copilot Assistant Workshop - Pre-Work Required

**Body:**
```
Hi Team!

You're registered for the JIRA Copilot Assistant workshop on [DATE].

Please complete these setup steps BEFORE the workshop (takes ~10 minutes):

1. Clone the repository:
   git clone https://github.com/andymo-sportsbet/jira-copilot-assistant.git
   cd jira-copilot-assistant

2. Create your .env file:
   cp .env.example .env

3. Get your JIRA API token:
   - Visit: https://id.atlassian.com/manage-profile/security/api-tokens
   - Click "Create API token"
   - Name it "JIRA Copilot Assistant"
   - Copy to your .env file

4. (Optional) Get your GitHub token:
   - Visit: https://github.com/settings/tokens
   - Generate new token with 'repo' scope
   - Copy to your .env file

5. Test your setup:
   ./scripts/jira-groom.sh --help

If you have issues, join #jira-copilot-assistant on Slack.

See you at the workshop!
- Racing Team
```

---

## 🕐 Workshop Schedule

### Part 1: Introduction (20 minutes)

**10:00-10:05 - Welcome & Icebreaker**
- Quick introductions
- Poll: "How much time do you spend on JIRA admin per week?"
- Set expectations

**10:05-10:15 - The Problem & Solution**
- Show [BEFORE-AFTER-COMPARISON.md](./BEFORE-AFTER-COMPARISON.md)
- Real metrics from Racing team
- Quick demo: Before (manual) vs After (AI-assisted)

**10:15-10:20 - Architecture Overview**
- How it works (high-level)
- JIRA API + GitHub API + AI
- Security & privacy

---

### Part 2: Basic Features (30 minutes)

**10:20-10:35 - Exercise 1: Your First Ticket Grooming**

**Instructor Demo (5 min):**
```bash
# Show live on screen
./scripts/jira-groom.sh [DEMO-TICKET]
```

**Hands-On Activity (10 min):**
```
Task: Groom one of your own tickets
1. Pick a ticket from your backlog
2. Run: ./scripts/jira-groom.sh [YOUR-TICKET]
3. Review the AI-generated criteria
4. Choose [s] to skip JIRA update (for now)
5. Share what you found in chat
```

**Group Discussion (5 min):**
- What worked well?
- What surprised you?
- Questions?

**10:35-10:50 - Exercise 2: Story Point Estimation**

**Instructor Demo (5 min):**
```bash
# Show the estimation breakdown
./scripts/jira-groom.sh [DEMO-TICKET] --estimate --team-scale

# Show reference detection
./scripts/jira-groom.sh [TICKET-WITH-REFERENCE] --estimate --team-scale
```

**Hands-On Activity (10 min):**
```
Task: Estimate 3 tickets from your backlog
1. Pick 3 unestimated tickets
2. For each, run: ./scripts/jira-groom.sh [TICKET] --estimate --team-scale
3. Review the AI analysis
4. Compare with your gut feeling
5. Note: Did any have reference implementations detected?
```

**Group Discussion (5 min):**
- How accurate were the estimates?
- Did reference detection work?
- Would this help your sprint planning?

---

### ☕ BREAK (10 minutes)

---

### Part 3: Advanced Features (40 minutes)

**11:00-11:15 - Exercise 3: GitHub Integration**

**Instructor Demo (5 min):**
```bash
# Search GitHub by keywords
./scripts/github-search.sh "spring boot upgrade"

# Search for specific ticket
./scripts/github-search.sh "RVV-1171"
```

**Hands-On Activity (10 min):**
```
Task: Find related PRs for your work
1. Think of a feature you worked on
2. Search GitHub: ./scripts/github-search.sh "[KEYWORD]"
3. Find a PR you recognize
4. Search by ticket: ./scripts/github-search.sh "[TICKET]"
5. Did you find useful context?
```

**11:15-11:30 - Exercise 4: Batch Processing**

**Instructor Demo (5 min):**
```bash
# Estimate multiple tickets
for ticket in PROJ-100 PROJ-101 PROJ-102; do
  ./scripts/jira-groom.sh $ticket --estimate --team-scale
done

# Save results
./scripts/jira-groom.sh PROJ-100 --estimate --team-scale > sprint-plan.txt
```

**Hands-On Activity (10 min):**
```
Task: Plan a mini-sprint
1. Pick 5 tickets from your backlog
2. Create a script to estimate all 5
3. Run the batch estimation
4. Add up total story points
5. Would this fit in one sprint for your team?
```

**11:30-11:40 - Exercise 5: Real-World Scenario**

**Scenario:**
```
You're planning next sprint. You have 8 tickets:
- 3 new features
- 2 bug fixes
- 2 enhancements
- 1 framework upgrade (with reference to previous work)

Your team capacity: 6 points/sprint (50% philosophy)

Task:
1. Estimate all 8 tickets
2. Identify which fit in the sprint
3. Flag large stories for breakdown
4. Update 2-3 tickets in JIRA with criteria
5. Share your sprint plan
```

**Time:** 10 minutes + Group sharing

---

### Part 4: Team Integration (20 minutes)

**11:40-11:50 - Customization Workshop**

**Instructor Demo (5 min):**
- Show how to customize keywords
- Edit `scripts/lib/jira-estimate-team.sh`
- Add team-specific complexity factors

**Group Activity (5 min):**
```
Brainstorm:
1. What keywords are specific to your team's work?
2. What reference implementations exist?
3. What would improve estimate accuracy?
4. Share in breakout rooms (2-3 people)
```

**11:50-12:00 - Best Practices & Tips**

**Discussion Topics:**
1. When to use the tool
   - Sprint planning
   - Daily standup prep
   - Before starting work
   - Backlog grooming

2. How to improve accuracy
   - Mention reference work
   - Clear ticket descriptions
   - Track estimated vs actual
   - Team feedback loop

3. Common pitfalls to avoid
   - Don't blindly accept AI estimates
   - Review generated criteria
   - Keep .env secure
   - Update tokens when they expire

4. Workflow integration
   - Make it part of "Definition of Ready"
   - Use in sprint planning meetings
   - Groom tickets before standups
   - Track team metrics

---

### Part 5: Wrap-Up (20 minutes)

**12:00-12:10 - Q&A Session**

**Common Questions:**
- How do I customize for my team?
- What if estimates are wrong?
- Can I use with [other tool]?
- How do I get my team to adopt it?
- What's the roadmap?

**12:10-12:15 - Success Metrics**

**What to Track:**
```
Week 1:
- # tickets groomed
- # tickets estimated
- Time saved (rough estimate)

Month 1:
- Estimation accuracy (estimated vs actual)
- Sprint commitment success rate
- Developer satisfaction

Quarter 1:
- Total time saved
- Quality improvements
- Team velocity changes
```

**12:15-12:20 - Next Steps & Resources**

**Action Items:**
1. ✅ Join #jira-copilot-assistant on Slack
2. ✅ Bookmark documentation links
3. ✅ Estimate next 5 tickets with the tool
4. ✅ Share feedback in retros
5. ✅ Help teammates get set up

**Resources:**
**Resources:**
- [Quick Start Guide](./QUICK-START-GUIDE.md)
- [FAQ](./FAQ.md)
- [User Guide](./onboard/user-guide.md)
- [Presentation](./INTERNAL-RELEASE-PRESENTATION.md)

**Support:**
- Slack: #jira-copilot-assistant
- Email: racing-team@sportsbet.com.au
- Office Hours: Wednesdays 2-3pm

---

## 📝 Instructor Notes

### Required Materials

**Technical Setup:**
- Projector/screen sharing
- Demo JIRA project with sample tickets
- GitHub repository access
- Slack channel for Q&A during workshop

**Handouts:**
- Quick reference card (commands)
- Troubleshooting checklist
- Feedback form

### Demo Tickets to Prepare

Create these sample tickets in a demo project:

1. **DEMO-100**: Simple bug fix (Expected: 0.5-1 point)
2. **DEMO-101**: Standard API endpoint (Expected: 2 points)
3. **DEMO-102**: Framework upgrade WITHOUT reference (Expected: 4 points)
4. **DEMO-103**: Framework upgrade WITH reference (Expected: 2 points)
5. **DEMO-104**: Complex integration (Expected: 4-5 points)

### Timing Tips

- **If running ahead:** Deep dive into customization
- **If running behind:** Skip Exercise 5, do as homework
- **If technical issues:** Have backup slides with screenshots

### Common Issues & Solutions

**Issue:** Participant can't connect to JIRA
- **Solution:** Check .env formatting, token validity

**Issue:** GitHub search returns no results
- **Solution:** Check GitHub token scope, try different keywords

**Issue:** AI estimation seems way off
- **Solution:** Show how to override, explain formula, discuss ticket quality

**Issue:** Participant lost/overwhelmed
- **Solution:** Pair with another participant, walk through step-by-step

---

## 📊 Workshop Success Metrics

### Immediate (End of Workshop)
- [ ] 80%+ participants successfully ran first command
- [ ] 70%+ participants estimated at least 3 tickets
- [ ] 60%+ participants feel confident to use independently
- [ ] 90%+ would recommend to colleagues

### Week 1 Follow-Up
- [ ] 50%+ participants used tool in real work
- [ ] 5+ questions/feedback in Slack channel
- [ ] 0 unresolved setup issues

### Month 1 Follow-Up
- [ ] 40%+ participants using daily
- [ ] 3+ teams requesting workshops
- [ ] Measurable time savings reported

---

## 🎓 Post-Workshop Follow-Up

### Day 1 - Send Thank You Email

```
Subject: Thanks for attending! Next steps + resources

Hi everyone!

Thanks for attending the JIRA Copilot Assistant workshop today!

Quick recap:
✅ You can now groom tickets with AI
✅ You can estimate with data-driven insights
✅ You know how to find related GitHub work

Next steps:
1. Estimate your next 5 tickets with the tool
2. Track time saved vs manual process
3. Share feedback in #jira-copilot-assistant

Resources:
- Quick Start: [link]
- FAQ: [link]
- Office Hours: Wednesdays 2-3pm

Questions? Reply to this email or ping us on Slack!

- Racing Team
```

### Week 1 - Check-In Survey

```
1. Have you used the tool since the workshop? [Yes/No]
2. How many tickets have you processed? [#]
3. Estimated time saved: [hours]
4. What's working well? [text]
5. What challenges have you faced? [text]
6. Would you recommend the tool to others? [1-10]
7. Additional feedback: [text]
```

### Month 1 - Success Stories

- Collect testimonials
- Share metrics in team updates
- Feature top users
- Plan next workshop

---

## 🏆 Certification (Optional)

### Workshop Completion Badge

Participants who complete all exercises receive:
- ✅ "JIRA Copilot Assistant Certified" badge
- ✅ Listed as champion in their team
- ✅ Priority support access
- ✅ Invitation to contribute to roadmap

---

**Ready to run an amazing workshop?**  
**You've got this!** 🚀

*JIRA Copilot Assistant Training Workshop v1.0*
