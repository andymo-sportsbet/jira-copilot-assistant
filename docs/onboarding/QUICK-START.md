# Quick Start Guide - Jira MCP Bash Wrapper

## What Is This?

A **thin Python wrapper** that exposes your existing bash scripts to GitHub Copilot through MCP (Model Context Protocol).

**Architecture:** Copilot Chat → MCP → Python Wrapper → Your Bash Scripts → Jira/Confluence

## Setup (5 minutes)

### 1. Update MCP Configuration

Find your MCP config file and update:

**Location:** `~/Library/Application Support/Code - Insiders/User/globalStorage/github.copilot-mcp/mcp.json`

**Config:**
```json
{
  "servers": {
    "jira-local": {
      "type": "stdio",
      "command": "/Users/andym/projects/my-project/jira-copilot-assistant/mcp-server/venv/bin/python",
      "args": ["/Users/andym/projects/my-project/jira-copilot-assistant/mcp-server/jira_bash_wrapper.py"],
      "cwd": "/Users/andym/projects/my-project/jira-copilot-assistant"
    }
  }
}
```

### 2. Reload VS Code

Command Palette → "Developer: Reload Window"

### 3. Test

Open Copilot Chat and ask:
```
"What Jira tools do you have?"
```

Should see: groom_ticket, create_ticket, fetch_confluence_page, etc.

## Usage Examples

### Grooming

**Basic:**
```
"Groom ticket RVV-1234"
```
→ Runs: `./scripts/jira-groom.sh RVV-1234`

**With Auto Template Selection:** ✨ NEW
```
"Groom RVV-1234 with auto template"
```
→ Automatically selects the right prompt template:
- Tech Debt: For upgrades, migrations (Spring Boot, Java)
- Spike: For research, investigation, POC
- Bug: For defects, errors, broken functionality
- Story: For features, enhancements

The template is exposed as an MCP resource that Copilot can read!

**With AI Estimation:**
```
"Groom RVV-1234 with AI estimation"
```
→ Runs: `./scripts/jira-groom.sh RVV-1234 --estimate`

**With Team Scale (0.5-5):**
```
"Groom RVV-1234 with estimation using team scale"
```
→ Runs: `./scripts/jira-groom.sh RVV-1234 --estimate --team-scale`

**With Spec File:**
```
"Groom RVV-1234 using spec file /path/to/spec.md"
```
→ Runs: `./scripts/jira-groom.sh RVV-1234 --reference-file /path/to/spec.md`

**With Confluence Page:**
```
"Groom RVV-1234 with Confluence page https://confluence/pages/123"
```
→ Runs:
1. `./scripts/confluence-to-spec.sh https://... /tmp/temp.md`
2. `./scripts/jira-groom.sh RVV-1234 --reference-file /tmp/temp.md`

**Manual Story Points:**
```
"Set RVV-1234 to 3 story points"
```
→ Runs: `./scripts/jira-groom.sh RVV-1234 --points 3`

### Confluence

**Fetch Page:**
```
"Fetch Confluence page https://confluence/pages/123456"
```
→ Runs: `./scripts/confluence-to-spec.sh https://...`

**Save to File:**
```
"Fetch Confluence page https://... and save to /specs/feature.md"
```
→ Runs: `./scripts/confluence-to-spec.sh https://... /specs/feature.md`

### Ticket Management

**Create Ticket:**
```
"Create a task for upgrading Spring Boot to 3.2"
```
→ Runs: `./scripts/jira-create.sh Task "Upgrade Spring Boot to 3.2"`

**Find Related:**
```
"Find tickets related to RVV-1234"
```
→ Runs: `./scripts/find-related-tickets.sh RVV-1234`

**Close Ticket:**
```
"Close RVV-1234 with comment 'Completed successfully'"
```
→ Runs: `./scripts/jira-close.sh RVV-1234 --comment "Completed successfully"`

## Available Tools

| Tool | Bash Script | Description |
|------|------------|-------------|
| `groom_ticket` | jira-groom.sh | AI acceptance criteria + estimation |
| `create_ticket` | jira-create.sh | Create Story/Task/Bug/Epic |
| `fetch_confluence_page` | confluence-to-spec.sh | Download Confluence pages |
| `find_related_tickets` | find-related-tickets.sh | Search related work |
| `close_ticket` | jira-close.sh | Close with comment |
| `sync_to_confluence` | confluence-to-jira.sh | Bidirectional sync |

## Troubleshooting

### "Tool not found" or "MCP server not responding"

1. Check mcp.json path is correct
2. Verify Python path: `which python` in venv
3. Reload VS Code window
4. Check VS Code Developer Tools console for errors

### "Script not found" errors

Test bash scripts directly:
```bash
cd /Users/andym/projects/my-project/jira-copilot-assistant
./scripts/jira-groom.sh --help
```

If bash works but MCP doesn't, issue is in wrapper.

### "Permission denied" errors

Make scripts executable:
```bash
chmod +x /Users/andym/projects/my-project/jira-copilot-assistant/scripts/*.sh
```

### Environment variables not loaded

Bash scripts load `.env` automatically. Verify:
```bash
cat /Users/andym/projects/my-project/jira-copilot-assistant/.env
```

Should have: JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN, etc.

### Test wrapper directly

```bash
cd /Users/andym/projects/my-project/jira-copilot-assistant/mcp-server
./venv/bin/python test_bash_wrapper.py
```

Should show all scripts found and execution working.

## Benefits

✅ **No Code Duplication** - Bash scripts are source of truth  
✅ **Battle-Tested Logic** - Uses production bash with years of testing  
✅ **Easy Updates** - Update bash, wrapper automatically uses new features  
✅ **Simple** - Only 400 lines of Python vs 3000+ reimplementation  
✅ **Debuggable** - Can test bash scripts independently  
✅ **All Features** - Every bash option available through Copilot  

## File Reference

```
jira-copilot-assistant/
├── .env                         # Environment (shared)
├── scripts/                     # Source of truth
│   ├── jira-groom.sh           # ⭐ Main grooming
│   ├── jira-create.sh          # Ticket creation
│   ├── confluence-to-spec.sh   # Confluence fetch
│   ├── find-related-tickets.sh # Related search
│   ├── jira-close.sh           # Close tickets
│   └── lib/*.sh                # Libraries
└── mcp-server/
    ├── jira_bash_wrapper.py    # ⭐ MCP wrapper (USE THIS)
    ├── test_bash_wrapper.py    # Validation
    └── venv/                   # Python env
```

## Next Steps

1. ✅ Wrapper tested and working
2. ⏭️ Update mcp.json with wrapper path
3. ⏭️ Reload VS Code
4. ⏭️ Ask Copilot: "Groom ticket RVV-1234"
5. 🎉 Enjoy AI-powered Jira workflows!
