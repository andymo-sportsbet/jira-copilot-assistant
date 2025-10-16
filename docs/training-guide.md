# Team Training - JIRA Copilot Assistant

**Session Duration**: 45 minutes  
**Format**: Interactive hands-on workshop  
**Prerequisites**: VS Code, GitHub Copilot subscription, terminal access

---

## 📋 Training Agenda

| Time | Topic | Format |
|------|-------|--------|
| 0-5 min | Introduction & Setup Check | Presentation |
| 5-15 min | Demo: All 4 Commands | Live Demo |
| 15-30 min | Hands-on Exercise | Interactive |
| 30-40 min | Advanced Tips & Q&A | Discussion |
| 40-45 min | Next Steps & Resources | Wrap-up |

---

## 🎯 Learning Objectives

By the end of this session, participants will be able to:

1. ✅ Create JIRA tickets from specification files using Copilot
2. ✅ Enhance tickets with acceptance criteria using `jira-groom.sh`
3. ✅ Close tickets with auto-generated summaries
4. ✅ Sync GitHub PR status to JIRA automatically
5. ✅ Troubleshoot common issues independently

---

## 📊 Pre-Training Setup (Send 24 Hours Before)

### Email to Participants:

**Subject**: JIRA Copilot Assistant Training - Setup Required

**Body**:
```
Hi Team,

You're registered for the JIRA Copilot Assistant training session on [DATE] at [TIME].

To make the session productive, please complete these setup steps BEFORE the session:

1. **Install jq** (JSON parser):
   - macOS: brew install jq
   - Linux: sudo apt-get install jq
   - Verify: jq --version

2. **Clone the repository**:
   git clone <repo-url> ~/jira-copilot-assistant
   cd ~/jira-copilot-assistant

3. **Get your JIRA API token**:
   - Go to: https://id.atlassian.com/manage-profile/security/api-tokens
   - Create token named "JIRA Copilot Assistant"
   - Save it somewhere safe (you'll need it during training)

4. **Optional - GitHub CLI** (for sync features):
   brew install gh
   gh auth login

5. **Verify GitHub Copilot** is active in VS Code

⚠️ If you encounter issues during setup, reply to this email ASAP.

See you at the session!
```

---

## 🎓 Session 1: Introduction (0-5 min)

### Slide 1: Welcome

**Title**: JIRA Copilot Assistant Training

**Agenda**:
- Quick polls: Who's done the setup?
- Overview of what we'll build
- Learning objectives

### Slide 2: The Problem

**Before**:
- ❌ Context-switch to JIRA web interface
- ❌ Manually copy spec details to ticket
- ❌ Forget to update ticket status
- ❌ Inconsistent ticket quality

**After**:
- ✅ Stay in VS Code/terminal
- ✅ Copilot extracts details automatically
- ✅ Auto-sync from GitHub PRs
- ✅ Standardized ticket format

### Slide 3: The Solution

**4 Simple Scripts**:
1. `jira-create.sh` - Create tickets
2. `jira-groom.sh` - Add acceptance criteria
3. `jira-close.sh` - Close with summary
4. `jira-sync.sh` - Sync with GitHub

**+ GitHub Copilot** for natural language commands

---

## 🎬 Session 2: Live Demo (5-15 min)

### Demo Flow

**Setup** (1 min):
```bash
cd ~/jira-copilot-assistant
cp .env.example .env
nano .env  # Show filling in credentials (use dummy values on screen)
source .env
```

**Demo 1: Create Ticket** (3 min):
```bash
# Open test-spec.md in VS Code
code test-spec.md

# Ask Copilot in chat: "create jira ticket from this file"
# Show Copilot's suggestion
# Copy command to terminal

source .env
./scripts/jira-create.sh \
  --summary "Mobile App Payment Feature" \
  --description "Add in-app payment functionality..." \
  --features "Stripe SDK,Apple Pay,Google Pay,..." \
  --priority "High"

# Show ticket in JIRA web interface
```

**Demo 2: Groom Ticket** (3 min):
```bash
# Groom the just-created ticket
./scripts/jira-groom.sh MSPOC-87

# Show acceptance criteria added in JIRA
```

**Demo 3: Close Ticket** (2 min):
```bash
# Close the ticket
./scripts/jira-close.sh MSPOC-87

# Show completion comment in JIRA
```

**Demo 4: Sync Repos** (3 min):
```bash
# Show existing PR with JIRA key in title
# Run sync
./scripts/jira-sync.sh

# Show ticket status updated
```

---

## 🔨 Session 3: Hands-On Exercise (15-30 min)

### Exercise Structure

**Individual Work** (15 minutes total)

#### Exercise 1: Create Your First Ticket (5 min)

**Task**: Create a JIRA ticket for a "User Profile Page" feature

**Specification**:
```markdown
# User Profile Page

## Description
Create a user profile page where users can view and edit their information.

## Requirements
- Display user avatar
- Show user name and email
- Edit bio text field
- Change password button
- Privacy settings toggle

## Priority
This is important for Q1 release.
```

**Steps**:
1. Create file `user-profile-spec.md` with above content
2. Open in VS Code
3. Ask Copilot: "create jira ticket from this file"
4. Review Copilot's suggestion
5. Run the command
6. Verify ticket created in JIRA

**Expected Result**:
```
✅ Created: PROJ-XXX
ℹ️  Summary: User Profile Page
ℹ️  Priority: Medium
```

**Bonus**: What priority did Copilot detect? Why?

---

#### Exercise 2: Groom the Ticket (5 min)

**Task**: Add acceptance criteria to your ticket

**Steps**:
1. Use your ticket key from Exercise 1
2. Run: `./scripts/jira-groom.sh PROJ-XXX`
3. Open ticket in JIRA
4. Review the acceptance criteria added

**Expected Result**:
- 5-6 acceptance criteria added
- Each criteria is testable
- Related to the requirements

**Discussion**: How would you improve these criteria?

---

#### Exercise 3: Close the Ticket (3 min)

**Task**: Practice closing a ticket

**Steps**:
1. Run: `./scripts/jira-close.sh PROJ-XXX`
2. Check ticket status in JIRA
3. Read the completion comment

**Expected Result**:
- Ticket moved to "Done"
- Completion summary added as comment
- All features listed

---

#### Exercise 4: GitHub Sync (2 min)

**Task**: Test sync command (even if no PRs exist)

**Steps**:
1. Run: `./scripts/jira-sync.sh`
2. Review the output
3. Note how many repos scanned

**Expected Result**:
```
✅ Sync complete!
ℹ️  Scanned: X repositories
ℹ️  Updated: 0 tickets
```

**Discussion**: Why were 0 tickets updated?

---

### Group Review (5 min)

**Facilitator asks**:
- Who successfully created a ticket? 🎉
- What priority did Copilot detect?
- Did anyone encounter errors?
- How long did it take vs. manual JIRA?

**Common Issues to Address**:
- Permission denied → Need `chmod +x scripts/*.sh`
- 401 error → Check JIRA_API_TOKEN
- jq not found → Install: `brew install jq`

---

## 💡 Session 4: Advanced Tips (30-40 min)

### Tip 1: Create Aliases for Speed

```bash
# Add to ~/.zshrc or ~/.bashrc
alias jc='cd ~/jira-copilot-assistant && source .env && ./scripts/jira-create.sh'
alias jg='cd ~/jira-copilot-assistant && source .env && ./scripts/jira-groom.sh'
alias jclose='cd ~/jira-copilot-assistant && source .env && ./scripts/jira-close.sh'
alias jsync='cd ~/jira-copilot-assistant && source .env && ./scripts/jira-sync.sh'

# Usage:
jc --summary "Quick ticket" --priority "Low"
jg PROJ-123
```

### Tip 2: Batch Operations

```bash
# Create multiple tickets from a list
cat sprint-items.txt | while read summary; do
    ./scripts/jira-create.sh --summary "$summary"
done

# Groom all tickets in a sprint
for ticket in PROJ-{100..110}; do
    ./scripts/jira-groom.sh "$ticket"
    sleep 2  # Avoid rate limits
done
```

### Tip 3: Debug Mode

```bash
# Enable verbose output
DEBUG=true ./scripts/jira-create.sh --summary "Test"

# Shows:
# - API request URLs
# - Request payloads
# - Response bodies
# - Variable values
```

### Tip 4: GitHub PR Best Practices

**For auto-sync to work**:

✅ **Good PR Titles**:
- `PROJ-123: Add payment endpoint`
- `[PROJ-123] Fix login validation`
- `PROJ-123 - Refactor user service`

❌ **Won't Be Detected**:
- `Add payment endpoint` (no JIRA key)
- `proj-123: Fix bug` (lowercase)

### Tip 5: Automate Daily Sync

```bash
# Add to crontab
crontab -e

# Run sync every day at 9 AM
0 9 * * * cd ~/jira-copilot-assistant && source .env && ./scripts/jira-sync.sh >> ~/jira-sync.log 2>&1
```

### Tip 6: Custom Priority Detection

Edit `scripts/lib/utils.sh` to add your own keywords:

```bash
detect_priority() {
    local text="$1"
    
    # Add your company's keywords
    if echo "$text" | grep -qi "P0\|sev1\|emergency"; then
        echo "High"
    elif echo "$text" | grep -qi "P2\|sev3\|backlog"; then
        echo "Low"
    else
        echo "Medium"
    fi
}
```

---

## ❓ Q&A Session (10 min)

### Common Questions

**Q: Can I use this with JIRA Server (not Cloud)?**  
A: Yes, but you may need to adjust API endpoints to v2 and authentication method.

**Q: What if my project doesn't have priority field?**  
A: Scripts handle this automatically by making priority optional.

**Q: Can I create Bugs or Stories instead of Tasks?**  
A: Yes! Edit `scripts/lib/jira-api.sh` and change the issue type.

**Q: How do I integrate with CI/CD?**  
A: Set environment variables as secrets in GitHub Actions, then call scripts.

**Q: Is my JIRA token secure?**  
A: Yes—it stays local in `.env` file which is `.gitignore`d.

**Q: Can I customize acceptance criteria generation?**  
A: Yes! Edit the `generate_acceptance_criteria` function in `jira-groom.sh`.

---

## 🎯 Session 5: Wrap-Up (40-45 min)

### Next Steps

**This Week**:
1. ✅ Create at least 3 real tickets using scripts
2. ✅ Try using Copilot for all ticket creation
3. ✅ Set up aliases in your shell config
4. ✅ Add JIRA keys to your PR titles

**This Sprint**:
1. ✅ Groom all sprint tickets
2. ✅ Set up daily sync (manual or cron)
3. ✅ Share feedback on what works/doesn't

### Resources

**Documentation**:
- 📖 [Setup Guide](setup-guide.md) - Installation & config
- 📖 [User Guide](user-guide.md) - All commands & examples
- 📖 [Troubleshooting](troubleshooting.md) - Common issues
- 🎬 [Demo Video](demo-script.md) - 5-minute walkthrough

**Support**:
- 💬 Slack channel: #jira-automation
- 🐛 GitHub Issues: <repo-url>/issues
- 📧 Email: <maintainer-email>

### Feedback Survey

**Please complete**: <survey-link>

Questions:
1. How confident are you using the tools? (1-5)
2. What worked well?
3. What was confusing?
4. What features would you like added?
5. Would you recommend to other teams?

---

## 📚 Training Materials Checklist

### Before Training
- [ ] Send setup email 24 hours before
- [ ] Verify all participants have JIRA access
- [ ] Create test project in JIRA
- [ ] Prepare demo environment
- [ ] Test all scripts beforehand
- [ ] Create Slack channel for questions
- [ ] Prepare feedback survey

### During Training
- [ ] Record session for later viewing
- [ ] Share screen with good font size
- [ ] Paste all commands in shared doc
- [ ] Save time for Q&A
- [ ] Note common issues

### After Training
- [ ] Send recording link
- [ ] Share command cheat sheet
- [ ] Post feedback survey
- [ ] Follow up on reported issues
- [ ] Schedule office hours

---

## 📊 Success Metrics

Track after training:
- [ ] % of participants who completed setup
- [ ] # of tickets created via scripts (first week)
- [ ] # of support questions received
- [ ] Average satisfaction rating
- [ ] % who would recommend to colleagues

**Target Goals**:
- 80%+ setup completion
- 50+ tickets created first week
- 4.0+ satisfaction rating
- 80%+ would recommend

---

## 🎓 Certification (Optional)

**JIRA Copilot Assistant - Certified User**

To earn certification, complete:
- [ ] Attend training session (or watch recording)
- [ ] Complete all 4 hands-on exercises
- [ ] Create 10 real tickets using scripts
- [ ] Successfully sync at least 1 PR
- [ ] Pass quiz (8/10 correct)

**Benefits**:
- Listed as resource person for team
- Can contribute to script improvements
- Early access to new features

---

## 📝 Quick Reference Card

**Create Ticket**:
```bash
jc --summary "Title" --features "F1,F2,F3" --priority "High"
```

**Groom Ticket**:
```bash
jg PROJ-123
```

**Close Ticket**:
```bash
jclose PROJ-123
```

**Sync GitHub**:
```bash
jsync
```

**Debug**:
```bash
DEBUG=true <any-command>
```

**Help**:
```bash
./scripts/jira-create.sh --help
```

---

**Training Complete!** 🎉

Welcome to automated JIRA workflows! 🚀
