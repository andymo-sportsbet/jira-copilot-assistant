#!/usr/bin/env bash

# github-api.sh
# GitHub API helper functions
# Part of: Copilot-Powered JIRA Assistant (Spec 008)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  GitHub CLI (gh) not installed. Some features will be limited.${NC}" >&2
        return 1
    fi
    return 0
}

# Search for PRs mentioning a JIRA key
# Usage: github_search_prs <jira_key>
github_search_prs() {
    local jira_key="$1"
    
    if ! check_gh_cli; then
        echo "[]"
        return 0
    fi
    
    # Search PRs in the organization
    local org="${GITHUB_ORG:-}"
    
    if [[ -z "$org" ]]; then
        echo "[]"
        return 0
    fi
    
    # Search for PRs mentioning the JIRA key
    gh pr list \
        --search "$jira_key" \
        --state all \
        --json number,title,state,url,mergedAt \
        --limit 10 2>/dev/null || echo "[]"
}

# Search for commits mentioning a JIRA key
# Usage: github_search_commits <jira_key> [repo]
github_search_commits() {
    local jira_key="$1"
    local repo="${2:-}"
    
    if ! check_gh_cli; then
        echo "[]"
        return 0
    fi
    
    local org="${GITHUB_ORG:-}"
    
    if [[ -z "$org" ]]; then
        echo "[]"
        return 0
    fi
    
    # Use GitHub API to search commits
    # Note: This requires GITHUB_TOKEN to be set
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        echo "[]"
        return 0
    fi
    
    local query="$jira_key+org:$org"
    if [[ -n "$repo" ]]; then
        query="$jira_key+repo:$repo"
    fi
    
    gh api "/search/commits?q=$query" \
        --jq '.items[0:5] | map({sha: .sha[0:7], message: .commit.message | split("\n")[0], author: .commit.author.name})' \
        2>/dev/null || echo "[]"
}

# List repositories in organization
# Usage: github_list_repos
github_list_repos() {
    if ! check_gh_cli; then
        echo "[]"
        return 0
    fi
    
    local org="${GITHUB_ORG:-}"
    
    if [[ -z "$org" ]]; then
        echo "[]"
        return 0
    fi
    
    gh repo list "$org" \
        --json name,owner \
        --limit 100 \
        --jq '.[] | .owner.login + "/" + .name' \
        2>/dev/null || echo ""
}

# Get recent PRs from a repo
# Usage: github_get_recent_prs <repo> [days]
github_get_recent_prs() {
    local repo="$1"
    local days="${2:-7}"
    
    if ! check_gh_cli; then
        echo "[]"
        return 0
    fi
    
    # Calculate date threshold
    local since_date
    if date -v-${days}d >/dev/null 2>&1; then
        # macOS date
        since_date=$(date -v-${days}d +%Y-%m-%d)
    else
        # GNU date
        since_date=$(date -d "$days days ago" +%Y-%m-%d)
    fi
    
    gh pr list \
        --repo "$repo" \
        --state all \
        --search "updated:>=$since_date" \
        --json number,title,state,body,mergedAt,url \
        --limit 50 \
        2>/dev/null || echo "[]"
}

# Extract JIRA keys from text
# Usage: extract_jira_keys <text>
extract_jira_keys() {
    local text="$1"
    
    # Extract all JIRA keys (format: PROJECT-123)
    echo "$text" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | sort -u || echo ""
}
