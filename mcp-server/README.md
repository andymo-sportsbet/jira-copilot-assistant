# Jira MCP Server

A Model Context Protocol (MCP) server that **wraps** the existing jira-copilot-assistant bash scripts, providing AI assistants access to all battle-tested Jira/Confluence features through a simple MCP interface.

## ✨ Features

### Wrapper Architecture
This MCP server is a **thin wrapper** around the existing bash scripts in `../scripts/`. All the battle-tested logic stays in bash - the MCP server just provides an AI-friendly interface.

### Smart Template Selection ✨ NEW
Automatically selects the right AI prompt template based on ticket type:
- **Tech Debt**: Upgrades, migrations, refactoring (Spring Boot, Java, dependency updates)
- **Spike/Research**: Investigation, POC, evaluation, feasibility studies
- **Bug**: Defects, errors, broken functionality
- **Story**: Features, enhancements, new capabilities

Uses the same smart detection as the bash scripts - analyzes ticket summary and description with keyword matching.

### Available Tools (via Bash Scripts)

#### 1. **Groom Ticket** (`jira-groom.sh`)
- AI-generated acceptance criteria
- GitHub PR/commit search integration
- Reference file support (spec files)
- Confluence page integration
- AI story point estimation (Team scale or Fibonacci)
- Manual story point assignment
- All original bash script features preserved

#### 2. **Create Ticket** (`jira-create.sh`)
- Create Story, Task, Bug, or Epic
- Markdown description support
- Epic linking
- Auto-formatting

#### 3. **Fetch Confluence Page** (`confluence-to-spec.sh`)
- Download Confluence pages
- Convert to spec files
- YAML front matter generation
- Markdown conversion

#### 4. **Find Related Tickets** (`find-related-tickets.sh`)
- Search for related tickets
- GitHub integration
- Dependency analysis

#### 5. **Close Ticket** (`jira-close.sh`)
- Close tickets with optional comment
- Workflow transitions

#### 6. **Sync to Confluence** (`confluence-to-jira.sh`)
- Sync ticket content to Confluence
- Bidirectional updates

## Setup

### 1. Install Dependencies

```bash
cd mcp-server
pip install -r requirements.txt
```

### 2. Configure Environment

Your `.env` file in the parent directory should already be configured:

```bash
JIRA_BASE_URL=https://sportsbet.atlassian.net
JIRA_EMAIL=andy.mo@sportsbet.com.au
JIRA_API_TOKEN=your_token_here
JIRA_PROJECT=RVV
JIRA_VERIFY_SSL=false
CONFLUENCE_BASE_URL=https://sportsbet.atlassian.net/wiki
```

The bash scripts will automatically load these environment variables.

### 3. Update VS Code MCP Configuration

Edit your MCP configuration to use the wrapper:

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

### 4. Reload VS Code

Reload the window to pick up the new MCP server.

## Usage in Copilot Chat

### Grooming Examples
- **"Groom ticket RVV-1234"** - Basic grooming with AI acceptance criteria
- **"Groom RVV-1234 with auto template"** - Auto-select prompt template based on ticket type ✨ NEW
- **"Groom RVV-1234 with estimation"** - Include AI story point estimation
- **"Groom RVV-1234 using team scale"** - Use 0.5-5 scale instead of Fibonacci
- **"Groom RVV-1234 with spec file /path/to/spec.md"** - Use local spec as reference
- **"Groom RVV-1234 with Confluence page https://..."** - Fetch Confluence and use as reference
- **"Set RVV-1234 to 3 story points"** - Manual story point assignment

### Template Selection (NEW)
When using `auto_template=true`, the MCP server automatically:
1. Fetches ticket details from JIRA
2. Analyzes summary and description
3. Selects appropriate template (tech-debt, spike, bug, story)
4. Returns template info so Copilot can read and use it

**Example:**
```
@jira groom RVV-1171 with auto template
```
Returns: "Using tech-debt template" (detected "Spring Boot 3 upgrade")

The template is exposed as an MCP resource that Copilot can read automatically!

### Confluence Examples
- **"Fetch Confluence page https://confluence/pages/123456"** - Download as spec
- **"Fetch Confluence https://... and save to /specs/feature.md"** - Save to file

### Ticket Management
- **"Create a task for Spring Boot upgrade"** - Create new ticket
- **"Create story under epic RVV-1178"** - Create and link to epic
- **"Find tickets related to RVV-1234"** - Search related work
- **"Close ticket RVV-1234"** - Close with Done status

## Available Tools

All tools are thin wrappers around the bash scripts in `../scripts/`.

### groom_ticket
Groom a Jira ticket (wraps `jira-groom.sh`)

**Parameters:**
- `ticket_key` (required): Ticket key (e.g., "RVV-1234")
- `reference_file` (optional): Path to spec file with technical details
- `confluence_url` (optional): Confluence page URL to fetch and use as reference
- `auto_template` (optional): Auto-select prompt template based on ticket type ✨ NEW
- `estimate` (optional): Enable AI story point estimation (default: false)
- `auto_estimate` (optional): Auto-accept AI estimation (default: false)
- `team_scale` (optional): Use team scale 0.5-5 vs Fibonacci (default: true)
- `story_points` (optional): Manually set story points (0.5, 1, 2, 3, 4, 5, 8, 13)

**Features:**
- Smart template selection (tech-debt, spike, bug, story) ✨ NEW
- AI-generated acceptance criteria
- GitHub PR/commit search
- Spec file integration
- Confluence page fetching
- AI or manual estimation
- All original bash features preserved

### create_ticket
Create a new Jira ticket (wraps `jira-create.sh`)

**Parameters:**
- `summary` (required): Ticket title
- `description` (required): Ticket description (markdown supported)
- `issue_type` (optional): Story, Task, Bug, Epic (default: "Task")
- `epic` (optional): Epic ticket key to link to

### fetch_confluence_page
Fetch Confluence page and convert to spec file (wraps `confluence-to-spec.sh`)

**Parameters:**
- `page_url` (required): Confluence page URL
- `output_file` (optional): Path to save spec file

**Features:**
- HTML to markdown conversion
- YAML front matter generation
- Can be used with `groom_ticket` via `confluence_url` parameter

### find_related_tickets
Find tickets related to a specific ticket (wraps `find-related-tickets.sh`)

**Parameters:**
- `ticket_key` (required): Ticket key (e.g., "RVV-1234")

**Features:**
- GitHub integration
- Dependency analysis
- Related work discovery

### close_ticket
Close a Jira ticket (wraps `jira-close.sh`)

**Parameters:**
- `ticket_key` (required): Ticket key (e.g., "RVV-1234")
- `comment` (optional): Comment when closing

### sync_to_confluence
Sync Jira ticket to Confluence page (wraps `confluence-to-jira.sh`)

**Parameters:**
- `ticket_key` (required): Ticket key (e.g., "RVV-1234")
- `page_id` (required): Confluence page ID

## Architecture

```
Copilot Chat
    ↓
MCP Protocol (stdio)
    ↓
jira_bash_wrapper.py (Python wrapper)
    ↓
subprocess.run()
    ↓
Bash Scripts (../scripts/*.sh)
    ↓
Jira/Confluence REST APIs
```

### Benefits of Wrapper Approach

1. **Zero Rewriting** - All battle-tested bash logic preserved
2. **Single Source of Truth** - Bash scripts remain authoritative
3. **Easy Updates** - Update bash scripts, wrapper automatically uses new features
4. **Debugging** - Can still run bash scripts directly for troubleshooting
5. **Gradual Migration** - Can port individual scripts to Python over time if desired
6. **Fallback** - If MCP fails, bash scripts still work standalone

## Troubleshooting

### MCP Server Not Starting

Check the Python wrapper can find the scripts:
```bash
cd /Users/andym/projects/my-project/jira-copilot-assistant/mcp-server
python jira_bash_wrapper.py
# Should start MCP server without errors
```

### Bash Scripts Not Found

Verify script directory structure:
```bash
ls ../scripts/
# Should show: jira-groom.sh, jira-create.sh, etc.
```

### Scripts Not Executable

Make scripts executable:
```bash
chmod +x ../scripts/*.sh
```

### Environment Variables Not Loaded

The wrapper relies on bash scripts loading `.env`. Verify:
```bash
cat ../.env
# Should contain JIRA_BASE_URL, JIRA_EMAIL, etc.
```

### Test Bash Scripts Directly

Always test bash scripts work independently first:
```bash
cd ..
./scripts/jira-groom.sh RVV-1234 --estimate
```

If bash works but MCP fails, check subprocess call in wrapper.

### Debugging Wrapper

Add debug output to `jira_bash_wrapper.py`:
```python
print(f"Running: {cmd}", file=sys.stderr)
print(f"CWD: {self.project_dir}", file=sys.stderr)
```

### Import Errors

```bash
pip install --upgrade mcp python-dotenv
```

The wrapper only needs `mcp` and `python-dotenv` - no `jira` or `requests` libraries needed!

## File Structure

```
jira-copilot-assistant/
├── .env                          # Environment config (shared)
├── scripts/                      # Bash scripts (source of truth)
│   ├── jira-groom.sh            # Main grooming script
│   ├── jira-create.sh           # Ticket creation
│   ├── confluence-to-spec.sh    # Confluence integration
│   ├── find-related-tickets.sh  # Related ticket search
│   ├── jira-close.sh            # Close tickets
│   ├── confluence-to-jira.sh    # Sync to Confluence
│   └── lib/                     # Bash libraries
│       ├── jira-api.sh
│       ├── confluence-api.sh
│       ├── jira-format.sh
│       ├── jira-estimate.sh
│       └── ...
└── mcp-server/                  # MCP wrapper
    ├── jira_bash_wrapper.py     # Main wrapper (NEW - use this!)
    ├── jira_mcp_server.py       # Old Python reimplementation
    ├── requirements.txt         # Just mcp + python-dotenv
    ├── venv/                    # Python virtual environment
    └── README.md                # This file
```

## Migration from Old Approach

If you were using `jira_mcp_server.py` (the Python reimplementation):

### Old Config (reimplementation):
```json
{
  "command": "python",
  "args": [".../jira_mcp_server.py"]
}
```

### New Config (wrapper):
```json
{
  "command": ".../venv/bin/python",
  "args": [".../jira_bash_wrapper.py"]
}
```

The wrapper is simpler and doesn't require `jira` or `requests` Python libraries.

## Why Wrapper > Reimplementation

| Aspect | Bash Scripts | Python Rewrite | **Wrapper** |
|--------|-------------|----------------|-------------|
| Lines of code | ~3000 (tested) | ~3000 (new) | ~400 ✅ |
| Maintenance | Update bash | Update Python | **Update bash only** ✅ |
| Testing | Battle-tested | Need new tests | **Uses bash tests** ✅ |
| Debugging | Easy (bash -x) | Python debugger | **Can use both** ✅ |
| Features | All | Subset | **All** ✅ |
| Single source | ✅ | ❌ Duplicate | ✅ |

**Winner: Wrapper** - Less code, less maintenance, all features! 🎉
