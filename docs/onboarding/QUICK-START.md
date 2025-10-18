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
````markdown
# Quick Start — JIRA Copilot Assistant

This repository exposes your existing bash-based JIRA/Confluence helpers to GitHub Copilot via an MCP (Model Context Protocol) wrapper.

Audience: engineers who want AI-assisted Jira grooming, ticket creation, Confluence export, and story-point estimation using the existing bash tooling.

Architecture: Copilot Chat → MCP → Python wrapper → Bash scripts → Jira / Confluence

--

## Quick 5-minute setup

Follow these quick steps from the repository root (`jira-copilot-assistant`).

1) Clone (if needed)

```bash
cd ~/projects
git clone https://github.com/andymo-sportsbet/jira-copilot-assistant.git
cd jira-copilot-assistant
```

2) Configure environment

```bash
cp .env.example .env
# Edit .env and add required variables (see below)
```

Minimum required in `.env`:

```
JIRA_BASE_URL=https://sportsbet.atlassian.net
JIRA_EMAIL=your.email@sportsbet.com.au
JIRA_API_TOKEN=<your_api_token>
JIRA_PROJECT=YOUR_PROJECT
```

Optional but recommended:

```
GITHUB_TOKEN=<your_github_token>
GITHUB_ORG=sportsbet
JIRA_STORY_POINTS_FIELD=customfield_10102
```

3) Make scripts executable (if not already):

```bash
chmod +x scripts/*.sh scripts/lib/*.sh
```

4) (Optional) Set up MCP wrapper for Copilot automation

```bash
cd mcp-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Add/update your MCP config (example below) and point VS Code Copilot to the wrapper
```

Example MCP server config (update paths to your checkout):

```json
{
  "servers": {
    "jira-local": {
      "type": "stdio",
      "command": "/path/to/jira-copilot-assistant/mcp-server/venv/bin/python",
      "args": ["/path/to/jira-copilot-assistant/mcp-server/jira_bash_wrapper.py"],
      "cwd": "/path/to/jira-copilot-assistant"
    }
  }
}
```

Reload VS Code (Developer: Reload Window) after updating MCP settings.

--

## Most common commands (CLI)

Use the original bash scripts directly for quick checks. Examples:

Groom a ticket (adds acceptance criteria):

```bash
./scripts/jira-groom.sh PROJ-123
```

Estimate a ticket (AI-assisted):

```bash
./scripts/jira-groom.sh PROJ-123 --estimate --team-scale
```

Create a ticket:

```bash
./scripts/jira-create.sh Task "Upgrade Spring Boot to 3.2"
```

Fetch a Confluence page and save as spec:

```bash
./scripts/confluence-to-spec.sh "https://.../pages/12345" --output specs/feature/spec.md
```

Find related tickets:

```bash
./scripts/find-related-tickets.sh PROJ-123
```

Close a ticket with a comment:

```bash
./scripts/jira-close.sh PROJ-123 --comment "Completed successfully"
```

--

## Using Copilot (MCP) — natural language examples

After the MCP server is running and Copilot is configured, try these prompts in Copilot Chat:

Grooming examples

```
"Groom ticket RVV-1234"
```
→ runs `./scripts/jira-groom.sh RVV-1234`

```
"Groom RVV-1234 with AI estimation"
```
→ runs `./scripts/jira-groom.sh RVV-1234 --estimate`

```
"Groom RVV-1234 with estimation using team scale"
```
→ runs `./scripts/jira-groom.sh RVV-1234 --estimate --team-scale`

Template selection: the wrapper exposes templates (Tech Debt, Spike, Bug, Story) and Copilot can choose the right one based on the ticket text.

Confluence & Spec workflows

```
"Fetch Confluence page https://... and save to specs/feature.md"
```
→ runs `./scripts/confluence-to-spec.sh` and stores a local spec file that can be used as a reference for grooming.

--

## Internals / Available tools

The MCP wrapper exposes a set of tools that map to the bash scripts. Example mapping:

| Tool | Script |
|------|--------|
| groom_ticket | `scripts/jira-groom.sh` |
| create_ticket | `scripts/jira-create.sh` |
| fetch_confluence_page | `scripts/confluence-to-spec.sh` |
| find_related_tickets | `scripts/find-related-tickets.sh` |
| close_ticket | `scripts/jira-close.sh` |
| sync_to_confluence | `scripts/confluence-to-jira.sh` |

--

## Troubleshooting

Tool not found / MCP server not responding

1. Verify MCP `mcp.json` path and settings
2. Ensure the MCP venv python is correct (`which python` inside `mcp-server/venv`)
3. Reload VS Code and check Developer Tools console for errors

Script not found or permission denied

```bash
./scripts/jira-groom.sh --help
chmod +x scripts/*.sh
```

Authentication failed

Check your `JIRA_API_TOKEN` and test with curl:

```bash
curl -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" "${JIRA_BASE_URL}/rest/api/3/myself"
```

Field cannot be set (Story Points)

The Story Points field may not be on the edit screen for your project. Either ask your JIRA admin to add it to the relevant screen, or use estimates for planning without writing to JIRA.

--

## Pro tips

- Mention a reference ticket or spec to reduce AI estimation uncertainty (e.g., "Follow same approach as DM adapter Spring Boot upgrade").
- Use interactive mode when prompted: `a` = accept estimate, `o` = override, `s` = skip updating JIRA.
- Batch estimate tickets via a shell loop for sprint planning.

--

## Files & structure

```
jira-copilot-assistant/
├── .env               # Environment (copy from .env.example)
├── scripts/           # Bash scripts (source of truth)
├── tests/             # Unit and integration tests
└── mcp-server/        # MCP wrapper and validation
```

--

## Next steps

1. Configure `.env` with your Jira credentials
2. (Optional) Set up MCP in `mcp-server/` and point VS Code Copilot to it
3. Try: `./scripts/jira-groom.sh PROJ-123 --estimate --team-scale`

---

*JIRA Copilot Assistant — Quick Start*

````
