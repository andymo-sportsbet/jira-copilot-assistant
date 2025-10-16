# Release Guide - JIRA Copilot Assistant

This guide walks through releasing jira-copilot-assistant for public use.

---

## 📋 Pre-Release Checklist

### ✅ Security & Privacy

- [ ] Verify `.env` is in `.gitignore` ✅ (already done)
- [ ] Remove all hardcoded credentials from code ✅ (clean)
- [ ] Check for company-specific URLs or domains (replace with placeholders)
- [ ] Review all scripts for sensitive information
- [ ] Ensure `.temp/` directory is ignored ✅ (already done)

### ✅ Documentation

- [ ] Update README.md with clear setup instructions ✅ (done)
- [ ] Add LICENSE file (MIT recommended)
- [ ] Update `.env.example` with all required variables ✅ (done)
- [ ] Add CONTRIBUTING.md for contributors
- [ ] Add CHANGELOG.md for version history
- [ ] Document MCP server setup in mcp-server/README.md ✅ (done)

### ✅ Code Quality

- [ ] All scripts have executable permissions (`chmod +x`)
- [ ] Remove debug/test files from repository
- [ ] Test all major workflows (create, groom, close)
- [ ] Verify MCP server works with test client ✅ (done)
- [ ] Check bash script compatibility (macOS and Linux)

### ✅ Repository Structure

```
jira-copilot-assistant/
├── .github/              # GitHub Actions, issue templates
├── .prompts/             # AI prompt templates ✅
├── docs/                 # Comprehensive documentation ✅
├── mcp-server/           # MCP integration ✅
├── scripts/              # Bash automation scripts ✅
│   └── lib/              # Reusable libraries ✅
├── specs/                # Example spec files
├── .env.example          # Environment template ✅
├── .gitignore            # Ignore sensitive files ✅
├── CHANGELOG.md          # Version history (TODO)
├── CONTRIBUTING.md       # Contribution guide (TODO)
├── LICENSE               # Open source license (TODO)
└── README.md             # Main documentation ✅
```

---

## 🚀 Release Steps

### 1. Clean Up Repository

```bash
# Remove temporary and test files
rm -rf .temp/*
git rm --cached .temp/* 2>/dev/null || true

# Check for untracked files
git status

# Remove any local test data
find . -name "*.tmp" -delete
find . -name "*.bak" -delete
```

### 2. Add License

```bash
# Create MIT License (recommended)
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 [Your Name/Organization]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

git add LICENSE
```

### 3. Add Contributing Guide

```bash
cat > CONTRIBUTING.md << 'EOF'
# Contributing to JIRA Copilot Assistant

Thank you for your interest in contributing! 🎉

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/jira-copilot-assistant.git`
3. Create a branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Test your changes thoroughly
6. Commit: `git commit -m "feat: your feature description"`
7. Push: `git push origin feature/your-feature`
8. Open a Pull Request

## Development Guidelines

### Bash Scripts
- Use `set -euo pipefail` for main scripts (but NOT in library files)
- Add proper error handling and user feedback
- Include help text with `--help` flag
- Test on both macOS and Linux if possible

### MCP Server
- Follow Python 3.13+ best practices
- Test with `mcp-server/test_mcp_client.py`
- Update schema documentation for new tools

### Documentation
- Update README.md for new features
- Add examples to relevant docs/ files
- Keep .env.example up to date

## Code Style

### Bash
- Use 2-space indentation
- Function names: `snake_case`
- Constants: `UPPER_CASE`
- Local variables: `lowercase`

### Python
- Follow PEP 8
- Use type hints
- Add docstrings for functions

## Testing

- Test all new features end-to-end
- Verify MCP integration with test scripts
- Check for sensitive data leaks

## Commit Messages

Follow conventional commits:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation updates
- `refactor:` - Code refactoring
- `test:` - Test additions/updates

EOF

git add CONTRIBUTING.md
```

### 4. Add Changelog

```bash
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-10-16

### Added
- 🔌 Model Context Protocol (MCP) integration for GitHub Copilot
- 📊 AI-powered story point estimation (Fibonacci and team scales)
- 🔍 JIRA search library with reusable JQL functions
- 🎨 Rich JIRA ADF formatting with emojis and visual hierarchy
- 📝 AI-generated ticket descriptions with templates
- ✅ Smart acceptance criteria generation
- 🔗 GitHub integration for PR/commit tracking
- 📄 Confluence to JIRA/spec conversion
- 💾 Complete documentation suite

### Features
- 6 MCP tools: groom_ticket, create_ticket, fetch_confluence_page, find_related_tickets, close_ticket, sync_to_confluence
- 23 bash script features with 100% MCP coverage
- Smart template selection (tech-debt, spike, bug, story)
- Interactive and auto-accept estimation modes
- Team-specific estimation scales

### Documentation
- Comprehensive README with quick start
- MCP server setup guide
- JIRA search library reference
- ADF formatting guide
- Auto-description workflow guide
- FAQ and troubleshooting

EOF

git add CHANGELOG.md
```

### 5. Create GitHub Repository

#### Option A: GitHub CLI (Recommended)
```bash
# Install GitHub CLI if needed
brew install gh

# Authenticate
gh auth login

# Create repository
gh repo create jira-copilot-assistant \
  --public \
  --description "🤖 Automate JIRA workflows with GitHub Copilot and shell scripts" \
  --homepage "https://github.com/YOUR_USERNAME/jira-copilot-assistant"

# Push code
git remote add origin https://github.com/YOUR_USERNAME/jira-copilot-assistant.git
git branch -M main
git push -u origin main
```

#### Option B: GitHub Web UI
1. Go to https://github.com/new
2. Repository name: `jira-copilot-assistant`
3. Description: "🤖 Automate JIRA workflows with GitHub Copilot and shell scripts"
4. Public repository
5. Don't initialize (you already have files)
6. Create repository
7. Follow push instructions shown

### 6. Add GitHub Metadata

```bash
# Add topics to repository (via GitHub UI or gh CLI)
gh repo edit --add-topic jira,copilot,automation,mcp,bash,python

# Or via GitHub UI: Settings > Topics
# Suggested topics: jira, copilot, automation, mcp, bash, python, cli, workflow
```

### 7. Configure Repository Settings

Via GitHub UI:
1. **Settings > General**
   - Enable Issues
   - Enable Discussions (optional)
   - Disable Wiki (docs/ folder is better)

2. **Settings > Actions**
   - Allow actions (if you add CI/CD later)

3. **Settings > Pages** (optional)
   - Enable GitHub Pages from `docs/` folder
   - Custom domain (optional)

### 8. Create Initial Release

```bash
# Tag version
git tag -a v1.0.0 -m "Release v1.0.0 - Initial public release"
git push origin v1.0.0

# Create release via GitHub CLI
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "🎉 First public release of JIRA Copilot Assistant

**Features:**
- 🔌 MCP integration for GitHub Copilot
- 📊 AI-powered story point estimation
- 🔍 JIRA search library
- 🎨 Rich ADF formatting
- 📝 AI-generated descriptions
- Complete documentation

See [CHANGELOG.md](CHANGELOG.md) for full details."
```

---

## 📢 Post-Release

### 1. Update README Badges

Add at the top of README.md:
```markdown
[![GitHub release](https://img.shields.io/github/v/release/YOUR_USERNAME/jira-copilot-assistant)](https://github.com/YOUR_USERNAME/jira-copilot-assistant/releases)
[![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/jira-copilot-assistant)](https://github.com/YOUR_USERNAME/jira-copilot-assistant/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
```

### 2. Share Your Project

- Post on Twitter/X with #GitHubCopilot #JIRA
- Share in relevant Reddit communities (r/programming, r/devops)
- Post on Dev.to or Hashnode
- LinkedIn post for professional network
- Hacker News (Show HN: ...)

### 3. Set Up CI/CD (Optional)

Create `.github/workflows/test.yml`:
```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Test bash scripts
        run: |
          chmod +x scripts/*.sh
          # Add your test commands
```

### 4. Monitor & Maintain

- Enable GitHub notifications
- Respond to issues promptly
- Review and merge pull requests
- Update documentation based on feedback
- Release patches for bugs
- Add new features based on user requests

---

## 🔒 Security Notes

### Before Making Public

1. **Audit all files** for sensitive data:
   ```bash
   grep -r "token\|password\|secret\|key" --include="*.sh" --include="*.py" .
   ```

2. **Review commit history** for leaked credentials:
   ```bash
   git log -p | grep -i "token\|password"
   ```

3. **If credentials were committed**, use BFG Repo-Cleaner:
   ```bash
   # Install BFG
   brew install bfg
   
   # Remove sensitive data
   bfg --replace-text passwords.txt
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   ```

### Environment Variables

Ensure users know to set these in `.env`:
- `JIRA_BASE_URL`
- `JIRA_EMAIL`
- `JIRA_TOKEN` (or `JIRA_API_TOKEN`)
- `CONFLUENCE_BASE_URL` (optional)
- `CONFLUENCE_TOKEN` (optional)
- `GITHUB_TOKEN` (optional)
- `GITHUB_ORG` (optional)
- `OPENAI_API_KEY` (optional)

---

## 📝 Checklist Summary

- [ ] Remove sensitive data
- [ ] Add LICENSE file
- [ ] Add CONTRIBUTING.md
- [ ] Add CHANGELOG.md
- [ ] Create GitHub repository
- [ ] Push code to GitHub
- [ ] Create v1.0.0 release tag
- [ ] Update README badges
- [ ] Configure repository settings
- [ ] Share on social media
- [ ] Monitor issues and PRs

---

**Ready to release?** Follow the steps above and make your project public! 🚀
