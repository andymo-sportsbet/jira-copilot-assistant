# Setup Guide - JIRA Copilot Assistant

Complete installation and configuration guide for the JIRA Copilot Assistant.

---

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

1. **Bash 3.2+** (macOS default)
   ```bash
   bash --version
   # Should show: GNU bash, version 3.2.x or higher
   ```

2. **curl** (for API calls)
   ```bash
   curl --version
   # Usually pre-installed on macOS/Linux
   ```

3. **jq** (for JSON parsing)
   ```bash
   # macOS
   brew install jq
   
   # Linux (Ubuntu/Debian)
   sudo apt-get install jq
   
   # Verify
   jq --version
   ```

4. **GitHub CLI** (optional, for sync features)
   ```bash
   # macOS
   brew install gh
   
   # Linux
   # See: https://github.com/cli/cli#installation
   
   # Verify
   gh --version
   ```

### Required Accounts

1. **JIRA Account**
   - Access to a JIRA instance (Cloud or Server)
   - Permission to create, update, and transition issues
   - Project key where you'll create tickets (e.g., "MSPOC")

2. **GitHub Account** (for sync features)
   - Access to organization repositories
   - Read permissions for repositories and pull requests

---

## Installation

### Step 1: Clone or Download

```bash
# Navigate to your projects directory
cd ~/projects

# Clone the repository (if applicable)
git clone <repository-url> jira-copilot-assistant

# Or download and extract the archive
cd jira-copilot-assistant
```

### Step 2: Set Permissions

Make all scripts executable:

```bash
chmod +x scripts/*.sh
chmod +x scripts/lib/*.sh
```

Verify permissions:

```bash
ls -l scripts/*.sh
# Should show: -rwxr-xr-x
```

---

## Configuration

### Step 1: Create Environment File

Copy the example environment file:

```bash
cp .env.example .env
```

### Step 2: Get JIRA API Token

1. **Log into JIRA** at your JIRA instance URL
2. **Go to Account Settings**:
   - Click your profile icon → **Account Settings**
   - Or visit: `https://id.atlassian.com/manage-profile/security/api-tokens`
3. **Create API Token**:
   - Click **Create API token**
   - Label: "JIRA Copilot Assistant"
   - Click **Create**
   - **Copy the token** (you won't see it again!)

**Note**: This same token will be used for both JIRA and Confluence access.

### Step 3: GitHub authentication (Optional, for sync features)

You can authenticate GitHub in two ways; prefer option A (safer/easier):

A) Use GitHub CLI (recommended)

1. Install GitHub CLI (`gh`) and run:

```bash
gh auth login
# follow the interactive prompts to authenticate
gh auth status  # verify authentication
```

This is the recommended approach because it avoids storing long-lived tokens in files and integrates with the user's GitHub account.

B) Personal Access Token (fallback)

Only use a PAT if you can't use `gh auth login`:

1. **Go to GitHub Settings** → https://github.com/settings/tokens
2. **Generate new token** (choose fine-grained token when possible):
   - Name: "JIRA Copilot Assistant"
   - Scopes: For private repo sync you typically need `repo` (or read-only repo access if you can restrict to that). Prefer fine-grained tokens and minimal scopes.
   - Click **Generate token** and **copy the token** (you won't see it again).

Paste the token into your `.env` as `GITHUB_TOKEN` only if required for your workflow.

### Step 4: Configure .env File

Edit the `.env` file with your details:

```bash
# Open in your preferred editor
nano .env
# or
code .env
```

Fill in these values:

```bash
# JIRA Configuration
JIRA_BASE_URL="https://your-domain.atlassian.net"
JIRA_EMAIL="your.email@company.com"
JIRA_API_TOKEN="your_jira_api_token_here"
JIRA_PROJECT="YOUR_PROJECT_KEY"  # e.g., "MSPOC", "PROJ"

# Confluence Configuration (Epic 4 - for Confluence integration)
CONFLUENCE_BASE_URL="https://your-domain.atlassian.net/wiki"
# Note: Uses same JIRA_API_TOKEN for authentication

# GitHub Configuration (Optional - for sync features)
GITHUB_TOKEN="your_github_token_here"
GITHUB_ORG="your-github-org"  # e.g., "andymo-sportsbet"

# Debug Mode (Optional)
DEBUG=false  # Set to 'true' for verbose output
```

### Step 5: Secure Your .env File

Protect your credentials:

```bash
# Set proper permissions (owner read/write only)
chmod 600 .env

# Verify .env is in .gitignore
grep "^\.env$" .gitignore
# Should show: .env
```

**⚠️ NEVER commit .env to version control!**

---

## Verification

### Test Configuration

Run the verification script:

```bash
cd jira-copilot-assistant
source .env

# Test JIRA connectivity
./scripts/jira-create.sh --help

# You should see the help message without errors
```

### Test JIRA Connection

Create a test ticket:

```bash
source .env
./scripts/jira-create.sh \
  --summary "Test Ticket - Setup Verification" \
  --description "Testing JIRA Copilot Assistant setup" \
  --priority "Low"
```

Expected output:
```
✅ Created: PROJ-123
ℹ️  Summary: Test Ticket - Setup Verification
🔗 https://your-domain.atlassian.net/browse/PROJ-123
```

If successful:
1. ✅ Configuration is correct
2. ✅ API credentials work
3. ✅ You can create tickets

### Test Confluence Connection (Optional)

If you configured Confluence integration:

```bash
source .env
./scripts/confluence-to-jira.sh --help

# Test with a Confluence page (replace with your URL)
./scripts/confluence-to-jira.sh \
  --url "https://your-domain.atlassian.net/wiki/spaces/SPACE/pages/123456/" \
  --project PROJ
```

Expected output:
```
ℹ️  Extracted page ID: 123456
ℹ️  Verifying Confluence authentication...
✅ Fetched Confluence page: Your Page Title
✅ Created: PROJ-124
🔗 Confluence: https://your-domain.atlassian.net/wiki/...
```

If you get **403 Forbidden**:
- Ensure your API token has Confluence read access
- Verify you can view the page in your browser
- Check the page isn't private/restricted

### Test GitHub Connection (Optional)

If you configured GitHub:

```bash
# Authenticate GitHub CLI
gh auth login

# Test sync
source .env
./scripts/jira-sync.sh
```

Expected output:
```
ℹ️  Fetching repositories from your-github-org...
ℹ️  Found X repositories
✅ Sync complete!
```

---

## Verification Checklist

After setup, verify:

- [ ] `jq` is installed and working
- [ ] `.env` file exists with your credentials
- [ ] `.env` has proper permissions (600)
- [ ] All scripts have execute permissions
- [ ] Test ticket created successfully in JIRA
- [ ] Confluence connection tested (if using Epic 4)
- [ ] GitHub CLI authenticated (if using sync features)
- [ ] You can see the test ticket in your JIRA project
- [ ] JIRA API token is valid
- [ ] JIRA project key is correct
- [ ] Test ticket creation works
- [ ] GitHub CLI authenticated (if using sync)
- [ ] All scripts are executable

---

## GitHub Copilot Integration (Optional)

### Enable Copilot Instructions

The project includes `.github/copilot-instructions.md` to teach GitHub Copilot about JIRA workflows.

**To use**:

1. **Open a specification file** in VS Code
2. **Ask Copilot**:
   - "create jira ticket from this file"
   - "groom PROJ-123"
   - "close PROJ-456"
   - "sync jira with github"
3. **Copilot will suggest** the appropriate command with extracted data

**Requirements**:
- GitHub Copilot subscription
- VS Code with GitHub Copilot extension
- `.github/copilot-instructions.md` in the repository

---

## Next Steps

Now that setup is complete:

1. **Read the [User Guide](onboarding/user-guide.md)** - Learn all commands and workflows
2. **Try the examples** - Create, groom, close tickets
3. **Customize as needed** - Adjust scripts for your workflow
4. **Report issues** - See [Troubleshooting Guide](troubleshooting.md)

---

## Common Setup Issues

### "jq: command not found"

**Solution**: Install jq:
```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

### "Permission denied" when running scripts

**Solution**: Make scripts executable:
```bash
chmod +x scripts/*.sh scripts/lib/*.sh
```

### "401 Unauthorized" or "403 Forbidden"

**Possible causes**:
1. Invalid API token
2. Incorrect email address
3. Token expired

**Solution**:
1. Generate a new JIRA API token
2. Update `.env` with new token
3. Verify email matches JIRA account

### "Project does not exist"

**Solution**: Check your `JIRA_PROJECT` value:
```bash
# Should be the project KEY, not name
JIRA_PROJECT="MSPOC"  # ✅ Correct (uppercase key)
JIRA_PROJECT="My Project"  # ❌ Wrong (name, not key)
```

### Environment variables not loading

**Solution**: Always source .env before running:
```bash
source .env
./scripts/jira-create.sh --summary "Test"
```

Or combine in one line:
```bash
(source .env; ./scripts/jira-create.sh --summary "Test")
```

---

## Security Best Practices

1. **Never share .env file** - Contains sensitive credentials
2. **Use read-only tokens** when possible
3. **Rotate tokens regularly** - Update every 90 days
4. **Check .gitignore** - Ensure .env is excluded
5. **Use environment-specific tokens** - Different tokens for dev/prod

---

## Need Help?

- **Troubleshooting**: See [troubleshooting.md](troubleshooting.md)
- **Usage Examples**: See [user-guide.md](onboarding/user-guide.md)
- **Project Issues**: Check GitHub Issues
- **JIRA API Docs**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/

---

**Setup Complete!** 🎉

You're ready to automate JIRA workflows with shell scripts and GitHub Copilot!
