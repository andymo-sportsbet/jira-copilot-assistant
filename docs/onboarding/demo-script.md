# Demo Video Script - JIRA Copilot Assistant

**Duration**: 5 minutes  
**Audience**: Development team  
**Objective**: Show how to automate JIRA workflows using shell scripts + GitHub Copilot

---

## 🎬 Script Structure

### Opening (30 seconds)
- Introduction
- Problem statement
- Solution overview

### Demo 1: Create Ticket (1 minute)
- Show specification file
- Use Copilot to suggest command
- Create ticket

### Demo 2: Groom Ticket (1 minute)
- Enhance ticket with criteria
- Show GitHub integration
- View results in JIRA

### Demo 3: GitHub Sync (1 minute)
- Create PR with JIRA key
- Run sync command
- Show ticket auto-update

### Demo 4: Close Ticket (1 minute)
- Close ticket with summary
- Show auto-generated comment
- Verify in JIRA

### Closing (30 seconds)
- Benefits recap
- Call to action

---

## 📝 Detailed Script

### SCENE 1: Opening (0:00 - 0:30)

**[Screen: VS Code with README.md open]**

**Narrator**:
> "How much time do you spend context-switching between your code editor and JIRA? Creating tickets, updating statuses, checking for duplicates... it adds up."
>
> "Today, I'll show you how to automate your entire JIRA workflow using GitHub Copilot and simple shell scripts. No extensions, no complex setup—just Copilot's natural language understanding and the power of the terminal."

**[Screen: Show title slide: "JIRA Copilot Assistant - Automate JIRA Workflows"]**

---

### SCENE 2: Demo 1 - Create Ticket from Spec (0:30 - 1:30)

**[Screen: Open test-spec.md]**

**Narrator**:
> "Here's a specification for a new mobile payment feature. Instead of manually creating a JIRA ticket, I'll ask Copilot to do it for me."

**[Action: Open Copilot Chat]**

**User types**: `create jira ticket from this file`

**[Screen: Show Copilot's suggested command]**

**Copilot response**:
```bash
cd jira-copilot-assistant
source .env
./scripts/jira-create.sh \
  --summary "Mobile App Payment Feature" \
  --description "Add in-app payment functionality using Stripe..." \
  --features "Stripe SDK,Apple Pay,Google Pay,Receipt generation,Transaction history,Secure storage" \
  --priority "High"
```

**Narrator**:
> "Notice how Copilot extracted the title from the heading, the description from the Description section, all six requirements as features, and even detected 'High' priority from keywords like 'urgent' and 'critical'."

**[Action: Copy command to terminal and run]**

**[Screen: Show terminal output]**

```
✅ Created: MSPOC-87
ℹ️  Summary: Mobile App Payment Feature
ℹ️  Priority: High
🔗 https://amo3167.atlassian.net/browse/MSPOC-87
```

**Narrator**:
> "In seconds, we have a fully populated JIRA ticket with all the details from our spec file."

**[Screen: Quick switch to JIRA web interface showing MSPOC-87]**

---

### SCENE 3: Demo 2 - Groom Ticket (1:30 - 2:30)

**[Screen: Back to VS Code terminal]**

**Narrator**:
> "Now let's enhance this ticket with acceptance criteria and GitHub context. This is called 'grooming' the ticket."

**[Action: Run command]**

```bash
./scripts/jira-groom.sh MSPOC-87
```

**[Screen: Show terminal output]**

```
ℹ️  Fetching ticket MSPOC-87...
✅ Found: Mobile App Payment Feature
ℹ️  Searching for related GitHub activity...
ℹ️  Generating acceptance criteria...
✅ Added 6 acceptance criteria
🔗 https://amo3167.atlassian.net/browse/MSPOC-87
```

**Narrator**:
> "The groom command does three things: First, it searches GitHub for related pull requests and commits. Second, it generates testable acceptance criteria based on the features. And third, it updates the ticket with this enhanced information."

**[Screen: Show JIRA ticket with acceptance criteria]**

**Example criteria shown**:
- [ ] Stripe SDK integration is complete and functional
- [ ] Apple Pay support is implemented for iOS  
- [ ] Google Pay support is implemented for Android
- [ ] Payment receipts are generated automatically
- [ ] Transaction history view is accessible
- [ ] All payments are stored securely

**Narrator**:
> "Now the team has clear, testable criteria for this feature."

---

### SCENE 4: Demo 3 - GitHub Sync (2:30 - 3:30)

**[Screen: VS Code with a code file]**

**Narrator**:
> "Here's where it gets really powerful. Let's say we start working on this feature. I'll create a branch and make a pull request."

**[Action: Show quick git commands]**

```bash
git checkout -b feature/MSPOC-87-payments
# ... make some code changes ...
git commit -m "Add Stripe payment integration"
gh pr create --title "MSPOC-87: Add payment feature"
```

**[Screen: Show GitHub PR created]**

**Narrator**:
> "Notice the PR title includes our JIRA key. This is crucial for automatic syncing."

**[Action: Run sync command]**

```bash
./scripts/jira-sync.sh
```

**[Screen: Show terminal output]**

```
ℹ️  Fetching repositories from andymo-sportsbet...
ℹ️  Found 4 repositories
ℹ️  Checking My-projects...
ℹ️  Found PR: MSPOC-87: Add payment feature (open)
✅ Updated MSPOC-87 → In Progress
✅ Sync complete!
```

**Narrator**:
> "The sync command scanned our repos, found the PR with MSPOC-87 in the title, and automatically moved the ticket to 'In Progress'. When the PR is merged, it will move to 'Done' automatically."

**[Screen: Show JIRA ticket status changed to "In Progress"]**

---

### SCENE 5: Demo 4 - Close Ticket (3:30 - 4:30)

**[Screen: Terminal]**

**Narrator**:
> "Let's say the work is complete and the PR is merged. Time to close the ticket."

**[Action: Run close command]**

```bash
./scripts/jira-close.sh MSPOC-87
```

**[Screen: Show terminal output]**

```
ℹ️  Fetching ticket MSPOC-87...
✅ Found: Mobile App Payment Feature
ℹ️  Generating completion summary...
ℹ️  Transitioning to Done...
✅ Ticket closed successfully!
🔗 https://amo3167.atlassian.net/browse/MSPOC-87
```

**Narrator**:
> "The close command does more than just change the status. It generates a completion summary and adds it as a comment to the ticket."

**[Screen: Show JIRA ticket with completion comment]**

**Comment shown**:
```markdown
## Ticket Completion Summary

This ticket has been marked as complete.

**Original Description:**
Add in-app payment functionality using Stripe for iOS and Android mobile applications...

**Features Completed:**
- Stripe SDK integration for iOS and Android
- Apple Pay support for iOS
- Google Pay support for Android
- Payment receipt generation
- Transaction history view
- Secure payment storage

**Status:** Done
```

**Narrator**:
> "This creates a clear record of what was accomplished, perfect for sprint reviews or retrospectives."

---

### SCENE 6: Closing (4:30 - 5:00)

**[Screen: Summary slide with key benefits]**

**Narrator**:
> "Let's recap what we just did:"

**[Show bullet points appearing one by one]**

- ✅ Created a JIRA ticket in seconds using Copilot
- ✅ Enhanced it with acceptance criteria automatically
- ✅ Synced GitHub PR status to JIRA automatically
- ✅ Closed tickets with auto-generated summaries

**Narrator**:
> "All of this without leaving your terminal or VS Code. No browser context-switching, no manual data entry."

**[Screen: Show setup command]**

```bash
# Get started in 3 steps:
git clone <repo-url> jira-copilot-assistant
cp .env.example .env  # Add your credentials
source .env && ./scripts/jira-create.sh --help
```

**Narrator**:
> "Setup takes less than 5 minutes. Check out the documentation at docs/setup-guide.md to get started. Happy automating!"

**[Screen: End title: "JIRA Copilot Assistant - Stop Context-Switching. Start Automating." with GitHub repo link]**

---

## 🎥 Production Notes

### Equipment Needed
- Screen recording software (QuickTime, OBS, or Loom)
- Microphone for clear narration
- JIRA instance with test project
- GitHub account with test repositories
- VS Code with GitHub Copilot

### Pre-Recording Checklist
- [ ] Set up clean test environment
- [ ] Create fresh test-spec.md file
- [ ] Delete old MSPOC-87 ticket if exists
- [ ] Prepare test PR (don't merge yet)
- [ ] Test all commands beforehand
- [ ] Set terminal font size to 16pt for visibility
- [ ] Hide sensitive credentials in .env
- [ ] Clear terminal history
- [ ] Close unnecessary applications
- [ ] Set "Do Not Disturb" mode

### Recording Settings
- **Resolution**: 1920x1080 (1080p)
- **Frame Rate**: 30 fps
- **Audio**: 44.1kHz, stereo
- **Format**: MP4 (H.264)
- **Terminal**: Dark theme, 16pt font
- **VS Code**: Zoom 150%, dark theme

### Timing Guidelines
- Speak slowly and clearly
- Pause 2 seconds after each command completes
- Allow 3 seconds for screen transitions
- Total: 5 minutes (±15 seconds)

### Post-Production
- [ ] Add captions/subtitles
- [ ] Add intro music (0-3 seconds)
- [ ] Add outro music (3-5 seconds)
- [ ] Add text overlays for key points
- [ ] Add terminal command highlights
- [ ] Color-correct if needed
- [ ] Normalize audio levels
- [ ] Export final version

---

## 📋 Talking Points (Optional Additions)

### If Time Permits, Mention:

1. **Bash 3.2 Compatibility**:
   > "Works on macOS out of the box—no need to install newer Bash versions."

2. **Security**:
   > "Your credentials stay local in .env file, never committed to git."

3. **Customization**:
   > "All scripts are simple Bash—easy to customize for your workflow."

4. **Team Adoption**:
   > "Once one person sets it up, the whole team benefits from the Copilot instructions."

5. **CI/CD Integration**:
   > "Can be integrated into GitHub Actions for automatic ticket updates on merges."

---

## 🎯 Call to Action

### At End of Video:

> "Ready to automate your JIRA workflow? Here's what to do next:"
> 
> 1. **Clone the repo**: `git clone <repo-url>`
> 2. **Follow setup guide**: `docs/setup-guide.md`
> 3. **Try your first ticket**: Ask Copilot to help!
> 
> Questions? Check the troubleshooting guide or open an issue.
> 
> Happy automating! 🚀

---

## 📊 Success Metrics

After releasing the video, track:
- [ ] Number of views
- [ ] Setup completion rate (team members who configure it)
- [ ] Tickets created via scripts (first week)
- [ ] Feedback survey responses
- [ ] Issues/questions raised

---

**Video Title**: "Automate JIRA Workflows with GitHub Copilot + Shell Scripts | 5-Minute Demo"

**Description**:
```
Stop context-switching between VS Code and JIRA! Learn how to automate ticket creation, 
enhancement, and status updates using GitHub Copilot's natural language understanding 
and simple shell scripts.

In this 5-minute demo, you'll see:
✅ Create tickets from spec files with one Copilot command
✅ Auto-generate acceptance criteria
✅ Sync GitHub PR status to JIRA automatically
✅ Close tickets with completion summaries

No complex extensions. No manual data entry. Just Copilot + Bash.

📚 Documentation: docs/setup-guide.md
🔗 Repository: [link]
⏱️ Setup time: < 5 minutes

Timestamps:
0:00 - Introduction
0:30 - Create ticket from spec file
1:30 - Groom ticket with criteria
2:30 - GitHub sync automation
3:30 - Close ticket with summary
4:30 - Recap & next steps

#GitHub #Copilot #JIRA #Automation #DevTools #Productivity
```

---

**Ready to record!** 🎬
