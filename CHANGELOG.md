# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-16

### Added

#### Core Features
- 🔌 **Model Context Protocol (MCP) Integration** - AI-powered workflow automation
  - Local MCP server wrapping all bash scripts
  - Direct integration with GitHub Copilot in VS Code
  - 6 MCP tools: groom_ticket, create_ticket, fetch_confluence_page, find_related_tickets, close_ticket, sync_to_confluence
  - 100% feature coverage (23/23 bash script features)
  - Smart template selection (auto-detects ticket type)

- 📊 **AI Story Point Estimation** - Smart estimation with team-specific scales
  - Dual estimation modes: Fibonacci (1, 2, 3, 5, 8...) or Team scale (0.5, 1, 2, 3, 4, 5)
  - Interactive prompts: Accept / Override / Skip
  - Detailed reasoning breakdown (base + complexity + uncertainty + testing)
  - Auto-warnings on large stories (4-5 points)
  - Formula: 1 Story Point = 7 Focus Hours (team scale)

- 🔍 **JIRA Search Library** - Reusable functions for finding related tickets
  - CLI tool: `find-related-tickets.sh` for easy ticket searches
  - Library: `scripts/lib/jira-search.sh` for custom scripts
  - Supports epic-based search, text search, and custom JQL filters
  - JIRA API v3 compatibility

- 🎨 **Rich JIRA ADF Formatting** - Professional ticket formatting
  - Visual hierarchy with H2/H3 headings and emojis
  - Bullet lists, bold text, horizontal rules
  - Smart content markers (⚡ COPILOT_GENERATED markers)
  - Library: `scripts/lib/jira-format.sh` with `markdown_to_jira_adf()` function

- 📝 **AI-Generated Descriptions** - Comprehensive ticket descriptions
  - `--ai-description` flag for enhanced grooming
  - Type-specific templates (tech-debt, story, bug, spike)
  - Business-focused language with technical context
  - Preserves manual edits while replacing AI content

#### Scripts
- `jira-create.sh` - Create tickets from spec files with AI enhancement
- `jira-groom.sh` - Add acceptance criteria + GitHub context + AI descriptions
- `jira-close.sh` - Auto-generate completion summaries
- `jira-sync.sh` - Keep JIRA updated with PR status
- `confluence-to-jira.sh` - Create tickets from Confluence pages
- `confluence-to-spec.sh` - Save Confluence as spec files
- `find-related-tickets.sh` - Search for related tickets
- `get-description-template.sh` - Get appropriate prompt template

#### Documentation
- Comprehensive README with quick start guide
- MCP server setup guide (mcp-server/README.md)
- JIRA search library reference (docs/jira-search-library.md)
- ADF formatting guide (docs/jira-adf-formatting.md)
- Auto-description workflow guide (docs/auto-description-guide.md)
- Story point estimation guide (docs/estimation-guide.md)
- FAQ and troubleshooting guide
- Release and contribution guidelines

### Fixed
- Fixed literal `\n\n` appearing in JIRA descriptions (changed to `$'\n\n'`)
- Removed problematic `set -euo pipefail` from library files
- Fixed JIRA API v3 endpoint compatibility
- Fixed `generate_estimation_explanation()` unbound variable error

### Changed
- Updated all scripts to use JIRA API v3
- Support for both `JIRA_TOKEN` and `JIRA_API_TOKEN` environment variables
- Improved error handling across all scripts
- Better user feedback with emoji indicators

---

## Release Notes

### v1.0.0 - Initial Public Release

This is the first public release of JIRA Copilot Assistant, a comprehensive toolkit for automating JIRA workflows using GitHub Copilot, shell scripts, and the Model Context Protocol.

**Highlights:**
- Complete automation suite for JIRA ticket management
- Seamless GitHub Copilot integration via MCP
- AI-powered enhancements (descriptions, estimation, search)
- Production-tested with 100+ tickets groomed
- Extensive documentation and examples

**Installation:**
```bash
git clone https://github.com/YOUR_USERNAME/jira-copilot-assistant.git
cd jira-copilot-assistant
cp .env.example .env
# Edit .env with your credentials
chmod +x scripts/*.sh
```

**Quick Start:**
```bash
# Groom a ticket with AI
./scripts/jira-groom.sh PROJ-123 --estimate

# Create ticket from Confluence
./scripts/confluence-to-jira.sh --url "https://..."

# Find related tickets
./scripts/find-related-tickets.sh --epic PROJ-100
```

See [README.md](README.md) for full documentation.

[1.0.0]: https://github.com/YOUR_USERNAME/jira-copilot-assistant/releases/tag/v1.0.0
