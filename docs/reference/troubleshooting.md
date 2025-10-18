# Troubleshooting Guide - JIRA Copilot Assistant

Solutions to common issues and debugging tips.

---

## Table of Contents
- [Common Errors](#common-errors)
- [Authentication Issues](#authentication-issues)
- [Script Errors](#script-errors)
- [GitHub Integration Issues](#github-integration-issues)
- [API Errors](#api-errors)
- [Debugging Tips](#debugging-tips)
- [FAQ](#faq)

---

## Common Errors

### "jq: command not found"

**Error**:
```
./scripts/jira-create.sh: line 45: jq: command not found
```

**Cause**: The `jq` JSON parsing tool is not installed.

**Solution**:
```bash
# macOS
brew install jq

# Linux (Ubuntu/Debian)
sudo apt-get install jq

# Linux (RHEL/CentOS)
sudo yum install jq

# Verify installation
jq --version
```

---

### "Permission denied" Error

**Error**:
```
bash: ./scripts/jira-create.sh: Permission denied
```

**Cause**: Scripts don't have execute permissions.

**Solution**:
```bash
# Make all scripts executable
chmod +x scripts/*.sh
chmod +x scripts/lib/*.sh

# Verify permissions
ls -l scripts/*.sh
# Should show: -rwxr-xr-x
```

---

### "No such file or directory: .env"

**Error**:
```
source: .env: No such file or directory
```

**Cause**: Environment file doesn't exist.

**Solution**:
```bash
# Copy the example file
cp .env.example .env

# Edit with your credentials
nano .env

# Verify it exists
ls -la .env
```

---

### Environment Variables Not Loading

**Error**:
```
❌ JIRA_BASE_URL not set
```

**Cause**: Environment file not sourced before running script.

**Solution**:
```bash
# ALWAYS source .env before running scripts
source .env
./scripts/jira-create.sh --summary "Test"

# Or combine in one line
(source .env; ./scripts/jira-create.sh --summary "Test")

# Or export variables to current session
export $(cat .env | xargs)
```

---

## Authentication Issues

### "401 Unauthorized" Error

**Error**:
```json
{
  "errorMessages": ["You do not have the permission to see the specified issue."],
  "errors": {}
}
```

**Possible Causes**:
1. Invalid API token
2. Incorrect email address
3. Token expired
4. Wrong authentication format

**Solutions**:

**1. Verify API Token**:
```bash
# Check token is set
echo $JIRA_API_TOKEN
# Should show your token (not empty)

# Regenerate token at:
# https://id.atlassian.com/manage-profile/security/api-tokens
```

**2. Verify Email**:
```bash
# Check email is correct
echo $JIRA_EMAIL
# Should match your JIRA account email exactly
```

**3. Test Authentication Manually**:
```bash
source .env
curl -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  "${JIRA_BASE_URL}/rest/api/3/myself"

# Should return your user info (not 401 error)
```

**4. Check Authentication Format**:
- Must use Basic Auth (email:token)
- NOT Bearer token
- Email and token must be separated by colon

---

### "403 Forbidden" Error

**Error**:
```json
{
  "errorMessages": ["Forbidden"],
  "errors": {}
}
```

**Cause**: Your JIRA account doesn't have permission for the operation.

**Solutions**:

**1. Check Project Permissions**:
- Log into JIRA web interface
- Try creating a ticket manually
- If you can't, you need permission from admin

**2. Verify Project Key**:
```bash
# Check your project key
echo $JIRA_PROJECT

# Should be uppercase (e.g., "MSPOC", not "mspoc")
```

**3. Request Permissions**:
- Contact JIRA admin
- Request "Create Issues" permission
- Request "Edit Issues" permission
- Request "Transition Issues" permission

---

### "400 Bad Request - Priority Field"

**Error**:
```json
{
  "errors": {
    "priority": "Field 'priority' cannot be set. It is not on the appropriate screen, or unknown."
  }
}
```

**Cause**: Priority field not available in your JIRA project.

**Solution**: The scripts handle this automatically by making priority optional. If you see this error:

```bash
# Edit scripts/lib/jira-api.sh
# Ensure priority is in the "if [ -n ... ]" block:

if [ -n "$priority_id" ]; then
    payload=$(echo "$payload" | jq --arg pid "$priority_id" \
        '.fields.priority = {id: $pid}')
fi
```

---

## Script Errors

### "bad substitution" Error (Bash 3.2)

**Error**:
```
./scripts/jira-create.sh: line 42: ${var,,}: bad substitution
```

**Cause**: Using Bash 4.0+ syntax on macOS default Bash 3.2.

**Solution**: Scripts should already be Bash 3.2 compatible. If you see this:

```bash
# Check Bash version
bash --version

# Should work with Bash 3.2+
# If using custom scripts, replace ${var,,} with:
echo "$var" | tr '[:upper:]' '[:lower:]'
```

---

### "readarray: command not found"

**Error**:
```
./scripts/jira-sync.sh: line 67: readarray: command not found
```

**Cause**: `readarray` not available in Bash 3.2.

**Solution**: Scripts should use Bash 3.2 compatible loops. If you see this:

```bash
# Replace readarray with while loop:
# OLD (Bash 4.0+):
readarray -t repos <<< "$repo_list"

# NEW (Bash 3.2 compatible):
repos=()
while IFS= read -r repo; do
    [[ -n "$repo" ]] && repos+=("$repo")
done <<< "$repo_list"
```

---

### Syntax Error: Unexpected Token

**Error**:
```
./scripts/jira-create.sh: line 70: syntax error near unexpected token `fi'
```

**Cause**: Duplicate or mismatched `if`/`fi` statements.

**Solution**:
```bash
# Check syntax without running
bash -n ./scripts/jira-create.sh

# Look for:
# - Duplicate `fi` statements
# - Missing `then` after `if`
# - # - Unclosed if blocks
```

---

## Confluence Integration Issues

### "CONFLUENCE_BASE_URL not set"

**Error**:
```
❌ CONFLUENCE_BASE_URL not set in environment
```

**Cause**: Missing Confluence configuration in `.env`.

**Solution**:
```bash
# Add to .env
echo 'CONFLUENCE_BASE_URL=https://yourcompany.atlassian.net/wiki' >> .env

# Reload environment
source .env

# Verify
echo $CONFLUENCE_BASE_URL
```

---

### "403 Forbidden" from Confluence

**Error**:
```
❌ Confluence authentication failed (HTTP 403)
```

**Cause**: Authentication failed or insufficient permissions.

**Solutions**:

1. **Check API Token**:
   ```bash
   # Test authentication manually
   curl -u "your.email@company.com:your_api_token" 
     "https://yourcompany.atlassian.net/wiki/rest/api/user/current"
   ```

2. **Verify Confluence Access**:
   - Log into Confluence in your browser
   - Can you view the specific page?
   - Do you have a Confluence license?

3. **Check Token Scopes**:
   - Regenerate token at: https://id.atlassian.com/manage-profile/security/api-tokens
   - Ensure token has both JIRA and Confluence access

4. **Page Restrictions**:
   - Is the page public or restricted?
   - Check page permissions in Confluence

---

### "404 Not Found" - Confluence Page

**Error**:
```
❌ Confluence page not found: 12345
```

**Cause**: Invalid page ID or URL.

**Solutions**:

1. **Verify Page ID**:
   ```bash
   # Check the URL in your browser
   # Should be: .../pages/12345/... or ?pageId=12345
   ```

2. **Try Different URL Format**:
   ```bash
   # If URL doesn't work, try page ID directly
   ./scripts/confluence-to-jira.sh --page-id "12345" --project PROJ
   ```

3. **Check Page Exists**:
   - Visit the page in your browser
   - Verify the page hasn't been deleted

---

### "Could not extract page ID from URL"

**Error**:
```
❌ Could not extract page ID from URL: https://...
```

**Cause**: Unsupported URL format.

**Solution**:
```bash
# Manually extract page ID from browser URL
# Look for numbers like: /pages/12907938514/

# Use page ID directly
./scripts/confluence-to-jira.sh --page-id "12907938514" --project PROJ
```

---

### Confluence Content Not Extracted

**Error**:
```
ℹ️  Description: 0 characters
ℹ️  Requirements: 0 items
```

**Cause**: Page structure not recognized.

**Solutions**:

1. **Add Standard Sections**:
   ```markdown
   ## Overview
   Your main description here
   
   ## Requirements
   - Requirement 1
   - Requirement 2
   ```

2. **Check Page Format**:
   - View page in edit mode
   - Ensure using headings (h1, h2, h3)
   - Ensure using bullet points or numbered lists

3. **Override Priority**:
   ```bash
   # If priority not detected, specify manually
   ./scripts/confluence-to-jira.sh 
     --url "..." 
     --project PROJ 
     --priority High
   ```

---

### "readarray: command not found"
```

---

## GitHub Integration Issues

### "gh: command not found"

**Error**:
```
./scripts/jira-sync.sh: line 23: gh: command not found
```

**Cause**: GitHub CLI not installed.

**Solution**:
```bash
# macOS
brew install gh

# Linux
# See: https://github.com/cli/cli#installation

# Verify installation
gh --version

# Authenticate
gh auth login
```

---

### "gh authentication required"

**Error**:
```
error: authentication required
```

**Cause**: GitHub CLI not authenticated.

**Solution**:
```bash
# Authenticate GitHub CLI
gh auth login

# Follow prompts:
# 1. Select: GitHub.com
# 2. Select: HTTPS
# 3. Authenticate via browser
# 4. Complete authentication

# Verify authentication
gh auth status
```

---

### Sync Not Finding JIRA Keys

**Issue**: `jira-sync.sh` scans repos but finds 0 tickets to update.

**Cause**: PR titles don't include JIRA keys in the expected format.

**Solution**:

**1. Check PR Title Format**:
```bash
# ✅ Good formats:
PROJ-123: Add feature
[PROJ-123] Fix bug
PROJ-123 - Update docs

# ❌ Won't be detected:
proj-123: lowercase key
Add feature (no key)
123: missing project
```

**2. Check JIRA Key Pattern**:
```bash
# Valid pattern: [A-Z][A-Z0-9]+-[0-9]+
# Examples:
PROJ-123   ✅
ABC-456    ✅
A1B2-789   ✅
proj-123   ❌ (lowercase)
123-PROJ   ❌ (reversed)
```

**3. Manual Test**:
```bash
# Test regex pattern
echo "PROJ-123: Add feature" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+'
# Should output: PROJ-123
```

---

### Sync Updates Wrong Tickets

**Issue**: Sync updates tickets that shouldn't be updated.

**Cause**: Multiple JIRA keys in PR title/body.

**Solution**:

```bash
# Put primary JIRA key at the start of PR title
# ✅ Good:
PROJ-123: Fix related to PROJ-122

# ❌ May cause issues:
Related to PROJ-122, fixes PROJ-123
```

---

## API Errors

### "Issue does not exist"

**Error**:
```json
{
  "errorMessages": ["Issue does not exist or you do not have permission to see it."],
  "errors": {}
}
```

**Cause**:
1. Ticket key doesn't exist
2. Wrong project key
3. Ticket deleted
4. No permission

**Solution**:
```bash
# 1. Verify ticket exists in JIRA web interface
# 2. Check ticket key format
echo "MSPOC-123" | grep -E '^[A-Z]+-[0-9]+$'
# Should match

# 3. List recent tickets
# Use JIRA web interface or API to verify
```

---

### "Field required but not provided"

**Error**:
```json
{
  "errors": {
    "summary": "Summary is required."
  }
}
```

**Cause**: Missing required field.

**Solution**:
```bash
# Ensure summary is provided
./scripts/jira-create.sh --summary "Your ticket title here"

# Check for empty values
./scripts/jira-create.sh --summary ""  # ❌ Empty
./scripts/jira-create.sh --summary "Title"  # ✅ Valid
```

---

### Rate Limit Exceeded

**Error**:
```json
{
  "errorMessages": ["You have exceeded the rate limit."]
}
```

**Cause**: Too many API requests in short time.

**Solution**:
```bash
# 1. Wait 60 seconds and retry
sleep 60
./scripts/jira-create.sh --summary "Test"

# 2. Reduce sync frequency
# Don't run sync multiple times per minute

# 3. Add delays between batch operations
for ticket in PROJ-{100..200}; do
    ./scripts/jira-groom.sh "$ticket"
    sleep 2  # Wait 2 seconds between requests
done
```

---

## Debugging Tips

### Enable Debug Mode

```bash
# Set DEBUG environment variable
DEBUG=true ./scripts/jira-create.sh --summary "Test"

# Or add to .env
echo "DEBUG=true" >> .env
```

**Debug output includes**:
- API request URLs
- Request payloads
- Response bodies
- Variable values
- Execution flow

### Test API Calls Manually

```bash
# Test JIRA authentication
source .env
curl -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  -H "Content-Type: application/json" \
  "${JIRA_BASE_URL}/rest/api/3/myself"

# Test create issue
curl -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "MSPOC"},
      "summary": "Test ticket",
      "issuetype": {"name": "Task"}
    }
  }' \
  "${JIRA_BASE_URL}/rest/api/3/issue"
```

### Check Script Syntax

```bash
# Validate syntax without executing
bash -n ./scripts/jira-create.sh

# Check for common issues
shellcheck ./scripts/jira-create.sh
```

### Verify Environment Variables

```bash
# List all environment variables
source .env
env | grep JIRA
env | grep GITHUB

# Should show:
# JIRA_BASE_URL=https://...
# JIRA_EMAIL=...
# JIRA_API_TOKEN=...
# JIRA_PROJECT=...
```

### Test Individual Functions

```bash
# Source the library
source scripts/lib/utils.sh

# Test functions
validate_ticket_key "PROJ-123"
echo $?  # Should be 0 (success)

validate_ticket_key "invalid"
echo $?  # Should be 1 (failure)
```

---

## FAQ

### Q: Can I use this with JIRA Server (not Cloud)?

**A**: Yes, but you may need to adjust API endpoints. JIRA Server uses different authentication (username/password or PAT).

```bash
# For JIRA Server, update API calls to use v2:
JIRA_BASE_URL="https://jira.company.com/rest/api/2"
```

### Q: Why isn't my priority being set?

**A**: Some JIRA projects don't have the priority field on the create screen. The scripts handle this gracefully by making priority optional.

### Q: Can I create different issue types (Bug, Story, Epic)?

**A**: Currently scripts create "Task" type. To change:

```bash
# Edit scripts/lib/jira-api.sh
# Change issuetype in jira_create_issue function:
"issuetype": {"name": "Bug"}  # or "Story", "Epic"
```

### Q: How do I sync only specific repositories?

**A**: Use the `--repo` flag:

```bash
./scripts/jira-sync.sh --repo "my-specific-repo"
```

### Q: Can I run sync automatically?

**A**: Yes, use cron:

```bash
# Edit crontab
crontab -e

# Add line (runs daily at 9 AM):
0 9 * * * cd /path/to/jira-copilot-assistant && source .env && ./scripts/jira-sync.sh
```

### Q: What if my .env has special characters?

**A**: Quote values in .env:

```bash
# ✅ Good:
JIRA_API_TOKEN="abc123!@#$%^&*()"

# ❌ May cause issues:
JIRA_API_TOKEN=abc123!@#$%^&*()
```

### Q: Can I use this in CI/CD pipelines?

**A**: Yes, set environment variables in CI:

```yaml
# GitHub Actions example
env:
  JIRA_BASE_URL: ${{ secrets.JIRA_BASE_URL }}
  JIRA_EMAIL: ${{ secrets.JIRA_EMAIL }}
  JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
  JIRA_PROJECT: ${{ secrets.JIRA_PROJECT }}
```

### Q: Why is Copilot not suggesting commands?

**A**: Ensure:
1. `.github/copilot-instructions.md` exists
2. GitHub Copilot is enabled
3. You're using trigger phrases ("create jira ticket", etc.)
4. Repository is open in VS Code

### Q: How do I update ticket descriptions or other fields?

**A**: Use `jira-api.sh` library:

```bash
source scripts/lib/jira-api.sh
jira_update_issue "PROJ-123" '{"fields": {"description": "New description"}}'
```

### Q: Can I customize the acceptance criteria?

**A**: Yes, edit `scripts/jira-groom.sh`:

```bash
# Modify generate_acceptance_criteria function
# Add your own logic for criteria generation
```

### Q: How do I create tickets from Confluence pages?

**A**: Use the `confluence-to-jira.sh` script:

```bash
./scripts/confluence-to-jira.sh \
  --url "https://yourcompany.atlassian.net/wiki/spaces/SPACE/pages/123456/" \
  --project PROJ
```

Ensure:
- `CONFLUENCE_BASE_URL` is set in `.env`
- Your API token has Confluence read access
- You have permission to view the page

### Q: Why do I get 403 Forbidden from Confluence?

**A**: This means authentication failed. Check:

1. **API Token Permissions**:
   ```bash
   # Your token needs both JIRA and Confluence scopes
   # Regenerate token at: https://id.atlassian.com/manage-profile/security/api-tokens
   ```

2. **Page Access**:
   - Can you view the page in your browser?
   - Is the page public or restricted?
   - Do you have Confluence license/access?

3. **Correct Credentials**:
   ```bash
   # Verify in .env:
   JIRA_EMAIL="correct.email@company.com"  # Must match Atlassian account
   CONFLUENCE_BASE_URL="https://company.atlassian.net/wiki"  # Correct URL
   ```

### Q: Confluence page content not extracting correctly?

**A**: The script looks for specific sections in order:
1. "Overview" section
2. "Description" section  
3. "Summary" section
4. First paragraph (fallback)

**Solution**: Add an "Overview" or "Description" heading to your Confluence page:

```markdown
## Overview
Your description here...

## Requirements
- Requirement 1
- Requirement 2
```

---

## Still Having Issues?

1. **Enable debug mode**: `DEBUG=true`
2. **Check all prerequisites**: Run through [Setup Guide](setup-guide.md)
3. **Test manually**: Use curl to test API calls
4. **Check JIRA logs**: Look for errors in JIRA audit log
5. **Review permissions**: Ensure you have proper JIRA permissions
6. **Create an issue**: Submit detailed bug report with:
   - Error message
   - Debug output
   - Environment (OS, Bash version, JIRA type)
   - Steps to reproduce

---

## Additional Resources

- **JIRA REST API Docs**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
- **GitHub CLI Docs**: https://cli.github.com/manual/
- **Bash Scripting Guide**: https://www.gnu.org/software/bash/manual/
- **jq Documentation**: https://stedolan.github.io/jq/manual/

---

**Need more help?** Check the [User Guide](onboarding/user-guide.md) or create an issue on GitHub.
