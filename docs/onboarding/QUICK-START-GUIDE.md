# JIRA Copilot Assistant - Quick Start Guide
## Get Started in 5 Minutes

---

## 🚀 Installation

### Step 1: Clone Repository
```bash
cd ~/projects
git clone https://github.com/andymo-sportsbet/jira-copilot-assistant.git
cd jira-copilot-assistant
```

### Step 2: Configure Environment
```bash
cp .env.example .env
nano .env  # or use your favorite editor
```

### Step 3: Set Required Variables
```bash
# Minimum required configuration:
JIRA_BASE_URL=https://sportsbet.atlassian.net
JIRA_EMAIL=your.email@sportsbet.com.au
JIRA_API_TOKEN=<get from https://id.atlassian.com/manage-profile/security/api-tokens>
JIRA_PROJECT=YOUR_PROJECT

# Optional but recommended:
GITHUB_TOKEN=<get from https://github.com/settings/tokens>
GITHUB_ORG=sportsbet
JIRA_STORY_POINTS_FIELD=customfield_10102
```

### Step 4: Test Installation
```bash
./scripts/jira-groom.sh --help
```

✅ **You're ready to go!**

### Step 5 (Optional): Set Up MCP for AI Automation ✨ NEW
```bash
cd mcp-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Add to VS Code settings.json (see mcp-server/QUICK-START.md)
# Then use GitHub Copilot Chat with @jira commands
```

📚 **Full MCP setup**: [mcp-server/QUICK-START.md](../mcp-server/QUICK-START.md)

---

## 📝 Most Common Commands

### Command Line

#### 1. Groom a Ticket (Add Acceptance Criteria)
```bash
./scripts/jira-groom.sh PROJ-123
```

#### 2. Estimate a Ticket
```bash
./scripts/jira-groom.sh PROJ-123 --estimate --team-scale
```

#### 3. Groom + Estimate Together
```bash
./scripts/jira-groom.sh PROJ-123 --estimate --team-scale
```

#### 4. Search JIRA Tickets
```bash
./scripts/jira-search.sh "spring boot upgrade"
```

#### 5. Search GitHub Code
```bash
./scripts/github-search.sh "race condition"
```

### With GitHub Copilot (MCP) ✨ NEW

Once MCP is set up, use natural language in Copilot Chat:

```
@jira groom ticket PROJ-123 with AI estimation
```

```
@jira create a bug for login failure with high priority
```

```
@jira find tickets about Spring Boot upgrade
```

📚 **MCP Commands**: [mcp-server/QUICK-START.md](../mcp-server/QUICK-START.md)

---

## 🎯 Your First Ticket

Try this with one of your actual tickets:

```bash
# Replace PROJ-123 with your ticket number
./scripts/jira-groom.sh PROJ-123 --estimate --team-scale
```

**What happens:**
1. ✅ Fetches ticket from JIRA
2. ✅ Searches GitHub for related code
3. ✅ AI analyzes and generates estimate
4. ✅ Shows breakdown and confidence
5. ✅ Asks if you want to update JIRA
6. ✅ (Optional) Updates ticket with criteria

**Time taken:** ~30 seconds

---

## 💡 Pro Tips

### Tip 1: Mention Reference Work
If you've done similar work before, mention it in the ticket description:
```
"Follow the same approach as the DM adapter Spring Boot upgrade"
```
**Result:** AI reduces estimate by 50%!

### Tip 2: Use Interactive Mode
When the tool asks `[a/o/s]`:
- **a** = Accept the AI estimate
- **o** = Override with your own value
- **s** = Skip (don't update JIRA)

### Tip 3: Batch Processing
Estimate multiple tickets for sprint planning:
```bash
for ticket in PROJ-100 PROJ-101 PROJ-102; do
  ./scripts/jira-groom.sh $ticket --estimate --team-scale
done
```

### Tip 4: Save Output
```bash
./scripts/jira-groom.sh PROJ-123 --estimate --team-scale > estimation.txt
```

---

## 🆘 Troubleshooting

### "Command not found"
Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### "Authentication failed"
Check your JIRA_API_TOKEN is correct:
```bash
# Test JIRA connection
curl -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  "${JIRA_BASE_URL}/rest/api/3/myself"
```

### "Field cannot be set"
Story Points field not on edit screen - contact JIRA admin or use estimation for guidance only.

### "No such ticket"
Check:
- Ticket exists in JIRA
- You have permission to view it
- JIRA_PROJECT is set correctly

---

## 📚 Learn More

- **Full Documentation:** [README.md](../README.md)
- **User Guide:** [user-guide.md](./onboard/user-guide.md)
- **Presentation:** [INTERNAL-RELEASE-PRESENTATION.md](./INTERNAL-RELEASE-PRESENTATION.md)

## 💬 Get Help

- **Slack:** `#jira-copilot-assistant`
- **Email:** racing-team@sportsbet.com.au
- **Issues:** GitHub Issues

---

## ✅ Checklist

- [ ] Repository cloned
- [ ] `.env` file configured
- [ ] JIRA API token created
- [ ] GitHub token created (optional)
- [ ] Tested with `--help`
- [ ] Ran first ticket estimation
- [ ] Joined Slack channel
- [ ] Shared feedback

---

**Ready to transform your JIRA workflow?**  
**Start with just one ticket today!**

*JIRA Copilot Assistant v3.0.0*
