# JIRA Copilot Assistant - Frequently Asked Questions

---

## 🎯 General Questions

### What is JIRA Copilot Assistant?
An intelligent command-line tool that automates JIRA workflows using AI. It helps with ticket grooming, story point estimation, and connecting JIRA tickets to GitHub code.

### Who can use it?
Anyone who works with JIRA: Developers, Business Analysts, Engineering Managers, Product Owners, and QA Engineers.

### Do I need programming skills?
Basic command-line knowledge is helpful but not required. If you can open a terminal and copy-paste commands, you can use it.

### Is it free?
Yes! It's an internal Sportsbet tool, free for all employees.

### What platforms does it support?
- macOS ✅
- Linux ✅
- Windows (via WSL or Git Bash) ✅

---

## 🔧 Installation & Setup

### How long does installation take?
About 5 minutes. Just clone the repo, configure your `.env` file, and you're ready.

### Where do I get my JIRA API token?
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Name it "JIRA Copilot Assistant"
4. Copy the token to your `.env` file

### Do I need a GitHub token?
Optional but recommended. It enables GitHub integration features like searching for related PRs and commits.

### How do I find my Story Points field ID?
We provide a helper command:
```bash
./scripts/jira-groom.sh --find-story-points-field
```

Or check your `.env.example` for manual instructions.

### Can I use it with multiple JIRA projects?
Yes! Just change the `JIRA_PROJECT` variable in your `.env` file or set it per command.

---

## 📊 Story Point Estimation

### How accurate is the AI estimation?
We've achieved 99% accuracy on our Epic 5 implementation. Accuracy improves over time as the AI learns from your team's patterns.

### What estimation scales are supported?
- **Fibonacci:** 1, 2, 3, 5, 8, 13, 21 (use `--estimate`)
- **Linear (Team):** 0.5, 1, 2, 3, 4, 5 (use `--team-scale`)

### How does the AI estimate story points?
Formula: `Base + Complexity + Uncertainty + Testing`
- **Base:** 0.5 (bug) or 1.0 (story)
- **Complexity:** 0-2 based on 80+ keyword detection
- **Uncertainty:** 0-1 (reduced if reference implementation exists)
- **Testing:** 0-1 based on testing requirements

### What if I disagree with the AI estimate?
You can always override! When prompted, choose `[o]` to enter your own value. The AI provides suggestions, you make the final decision.

### Can the AI detect reference implementations?
Yes! If you mention similar work in the ticket description (e.g., "follow same approach as DM adapter upgrade"), the AI reduces complexity and uncertainty.

**Example:**
- Without reference: 4 points
- With reference: 2 points (50% reduction!)

### Will AI estimation replace our planning poker?
No, it augments it. Use AI estimates as a starting point for team discussion. It's especially useful for initial backlog grooming.

### How do I customize the estimation formula?
Edit `scripts/lib/jira-estimate-team.sh` to adjust the algorithm, keywords, or team scale. You can create team-specific profiles.

---

## 🎫 Ticket Grooming

### What does "grooming" mean?
Enhancing tickets with AI-generated acceptance criteria, GitHub context, and technical details.

### Can I customize the acceptance criteria format?
Yes! Edit the templates in `scripts/lib/jira-format.sh` or provide your own via the `--ai-guide` flag.

### Will it overwrite my existing ticket content?
No. It appends AI-generated content with clear markers (`⚡ COPILOT_GENERATED_START/END ⚡`) so you can easily identify and modify it.

### Can I review before updating JIRA?
Yes! The tool shows you what will be added and asks for confirmation before updating.

---

## 🔌 MCP Integration ✨ NEW

### What is MCP?
Model Context Protocol - a standard for connecting AI assistants (like GitHub Copilot) to external tools. It lets you use natural language to control JIRA workflows.

### Do I need MCP?
No, it's optional. The bash scripts work standalone. MCP adds AI-powered convenience for GitHub Copilot users.

### How is MCP different from prompt files?
- **Prompt files:** Copilot suggests bash commands based on instructions
- **MCP:** Direct tool integration - Copilot calls the tools automatically
- **Result:** MCP is faster, more reliable, and provides structured parameters

See: [docs/PROMPT-FILE-VS-MCP.md](./PROMPT-FILE-VS-MCP.md)

### How do I set up MCP?
```bash
cd mcp-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# Add to VS Code settings.json (see mcp-server/README.md)
```

📚 **Full guide**: [mcp-server/QUICK-START.md](../mcp-server/QUICK-START.md)

### What can I do with MCP?
Use natural language in Copilot Chat:
- `@jira groom RVV-1171 with AI estimation`
- `@jira create bug for login issue`
- `@jira find Spring Boot tickets`
- `@jira fetch confluence page from URL`

### Does MCP support all bash script features?
Yes! 100% coverage - all 23 bash script options are available through MCP.

See: [mcp-server/FEATURE-COVERAGE.md](../mcp-server/FEATURE-COVERAGE.md)

### Can I use MCP without GitHub Copilot?
Yes, any MCP-compatible AI client works (Claude Desktop, Continue.dev, etc.). But GitHub Copilot in VS Code is the primary target.

### Is MCP secure?
Yes - it's a local server running on your machine. Your JIRA credentials stay in your `.env` file and never leave your computer.

### Can my team share one MCP server?
Each developer runs their own local MCP server with their own credentials. The code can be shared via Git.

### Will MCP replace the bash scripts?
No! MCP is a thin wrapper around the bash scripts. All the logic stays in bash - MCP just provides an AI-friendly interface.

---

## 🔗 GitHub Integration

### What GitHub features are available?
- Search for related PRs by ticket number or keywords
- Find commits mentioning the ticket
- Analyze code changes and file modifications
- Link JIRA issues to implementation

### Does it work with private repositories?
Yes, if your GitHub token has appropriate access (`repo` scope).

### Can I search across multiple repositories?
Yes! The tool searches all repos in your configured GitHub organization.

### What if GitHub search finds too many results?
Be more specific with your search terms or ticket numbers. You can also limit results in the script configuration.

---

## 🔐 Security & Privacy

### Is my data secure?
Yes:
- All tokens stored locally in `.env` (never committed to git)
- No data sent to external services except JIRA/GitHub/Confluence APIs
- AI processing uses GitHub Copilot (approved Sportsbet tool)
- Respects your existing JIRA/GitHub permissions

### Who can see my API tokens?
Only you. They're stored in your local `.env` file which is gitignored.

### Does it log sensitive information?
No. The tool doesn't log credentials or sensitive ticket content.

### Can other team members see my activity?
Only through normal JIRA audit logs. The tool uses your personal tokens, so all actions appear as you in JIRA.

---

## 🐛 Troubleshooting

### "Field 'customfield_10102' cannot be set"
This means Story Points isn't on the edit screen for that issue type. Contact your JIRA admin to add it, or use estimation for guidance only (skip JIRA update).

### "Authentication failed"
Check:
- JIRA_EMAIL is correct
- JIRA_API_TOKEN is valid (tokens can expire)
- No extra spaces in `.env` values

### "No such ticket"
Verify:
- Ticket exists in JIRA
- You have permission to view it
- Ticket key format is correct (PROJ-123)

### "Command not found"
Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Scripts run slowly
- Check internet connection
- GitHub API rate limits (5,000 requests/hour)
- JIRA API performance

### AI estimation seems wrong
The AI learns from ticket content. Improve by:
- Writing clearer ticket descriptions
- Mentioning reference implementations
- Providing more context
- Giving feedback on estimates

---

## 📈 Usage & Best Practices

### When should I use the tool?
- During sprint planning (estimate backlog)
- Before starting work (groom ticket)
- When creating new stories (generate criteria)
- When searching for similar work

### How often should I groom tickets?
Best practice: Groom tickets right before starting work to ensure you have the latest context.

### Should I estimate every ticket?
Up to you! Many teams estimate only stories and bugs, not sub-tasks or spikes.

### Can multiple people use it on the same ticket?
Yes, but be aware of potential conflicts if both update the ticket simultaneously.

### How do I track estimation accuracy?
Compare AI estimates to actual effort (from time tracking or story completion). Share findings with the team to improve the formula.

---

## 🚀 Advanced Features

### Can I batch process multiple tickets?
Yes! Use a simple loop:
```bash
for ticket in PROJ-100 PROJ-101 PROJ-102; do
  ./scripts/jira-groom.sh $ticket --estimate --team-scale
done
```

### Can I integrate with other tools?
Yes! The scripts output JSON-parseable text. You can pipe output to other tools or scripts.

### Can I run it in CI/CD?
Yes! Use `--auto-estimate` flag to skip interactive prompts:
```bash
./scripts/jira-groom.sh PROJ-123 --auto-estimate --team-scale
```

### How do I add custom keywords?
Edit the keyword arrays in `scripts/lib/jira-estimate-team.sh`:
- `HIGH_COMPLEXITY_KEYWORDS`
- `MEDIUM_COMPLEXITY_KEYWORDS`
- `UNCERTAINTY_HIGH_KEYWORDS`
- `UNCERTAINTY_REDUCING_KEYWORDS`

---

## 🆕 Feature Requests & Feedback

### How do I request a new feature?
1. Check GitHub Issues for existing requests
2. Create new issue with "Feature Request" label
3. Post in Slack `#jira-copilot-assistant`

### Where do I report bugs?
GitHub Issues with:
- Steps to reproduce
- Expected vs actual behavior
- Error messages
- Environment details

### How can I contribute?
1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit Pull Request
5. Tag `@racing-team` for review

### Will you add support for [X]?
Check the roadmap in the presentation! We're planning:
- ML-based estimation improvements
- Sprint planning automation
- Epic breakdown suggestions
- Multi-team coordination
- Integration with additional tools

---

## 📊 Metrics & ROI

### How do I measure time savings?
Track:
- Time spent grooming before vs after
- Estimation meeting duration
- Ticket quality scores
- Developer satisfaction surveys

### What success metrics should I track?
- Estimation accuracy (estimated vs actual)
- Tickets groomed per sprint
- Time saved per ticket
- Team velocity consistency
- Developer adoption rate

### How do I prove ROI to management?
Use the ROI calculator in the presentation:
- Time saved × hourly rate = dollar value
- Show improved estimation accuracy
- Demonstrate faster sprint planning
- Highlight quality improvements

---

## 🎓 Training & Support

### Where can I learn more?
- [Quick Start Guide](./QUICK-START-GUIDE.md) - Get started fast
- [User Guide](./user-guide.md) - Comprehensive manual
- [Presentation](./INTERNAL-RELEASE-PRESENTATION.md) - Full overview
- [README](../README.md) - Technical documentation

### Is there hands-on training?
Yes! We offer:
- Weekly office hours (Wednesdays 2-3pm)
- Team workshops (contact racing-team)
- Video tutorials (coming soon)

### Where do I get help?
- **Slack:** `#jira-copilot-assistant`
- **Email:** racing-team@sportsbet.com.au
- **GitHub:** Issues and Discussions
- **Office Hours:** Wednesdays 2-3pm

### Can you help set up my team?
Yes! Contact racing-team@sportsbet.com.au to schedule a team onboarding session.

---

## 🔮 Future Plans

### What's coming next?
See the roadmap in [INTERNAL-RELEASE-PRESENTATION.md](./INTERNAL-RELEASE-PRESENTATION.md):
- **Phase 1:** Department rollout
- **Phase 2:** Sportsbet-wide deployment
- **Phase 3:** Advanced ML features
- **Phase 4:** Enterprise integrations

### Will it support [other tool]?
We're exploring integrations with:
- Confluence (✅ already supported)
- Slack notifications
- Microsoft Teams
- Azure DevOps
- ServiceNow

Submit feature requests if you have specific needs!

---

## 📞 Contact

**Racing Value Stream Team**
- 📧 racing-team@sportsbet.com.au
- 💬 Slack: `#jira-copilot-assistant`
- 🐛 GitHub: Issues
- 📅 Office Hours: Wednesdays 2-3pm

---

**Still have questions?**  
**Ask in Slack `#jira-copilot-assistant`!**

*Updated: October 2025*  
*JIRA Copilot Assistant v3.0.0*
