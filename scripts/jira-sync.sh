#!/usr/bin/env bash

# jira-sync.sh
# Sync GitHub repositories with JIRA ticket statuses
# Part of: Copilot-Powered JIRA Assistant (Spec 008)

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load libraries
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/utils.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/jira-api.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/github-api.sh"

# Load environment
load_env "${SCRIPT_DIR}/../.env"

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Sync GitHub repositories with JIRA ticket statuses by:
  1. Scanning recent PRs and commits for JIRA keys
  2. Determining appropriate status based on PR state
  3. Transitioning JIRA tickets accordingly

Options:
  --repo OWNER/REPO   Sync only a specific repository
  --days N            Look back N days (default: 7)
  --help, -h         Show this help message

Examples:
  # Sync all repos in organization (last 7 days)
  $(basename "$0")

  # Sync specific repository
  $(basename "$0") --repo yourorg/backend

  # Sync last 14 days
  $(basename "$0") --days 14

Status Transitions:
  - Open PR → "In Review" or "In Progress"
  - Merged PR → "Done"
  - Closed PR (not merged) → No change

Environment Variables:
  JIRA_BASE_URL      Your JIRA instance URL
  JIRA_EMAIL         Your JIRA email
  JIRA_TOKEN         JIRA API token
  JIRA_PROJECT       JIRA project key
  GITHUB_TOKEN       GitHub API token (required)
  GITHUB_ORG         GitHub organization (required)

EOF
}

# Sync a single repository
sync_repository() {
    local repo="$1"
    local days="${2:-7}"
    
    debug "Scanning repository: $repo"
    
    # Get recent PRs
    local prs=$(github_get_recent_prs "$repo" "$days")
    local pr_count=$(echo "$prs" | jq 'length' 2>/dev/null || echo "0")
    
    if [[ "$pr_count" == "0" ]]; then
        debug "No recent PRs in $repo"
        return 0
    fi
    
    debug "Found $pr_count recent PR(s) in $repo"
    
    local updated=0
    local errors=0
    
    # Process each PR
    while IFS= read -r pr; do
        local pr_number=$(echo "$pr" | jq -r '.number')
        local pr_title=$(echo "$pr" | jq -r '.title')
        local pr_body=$(echo "$pr" | jq -r '.body // ""')
        local pr_state=$(echo "$pr" | jq -r '.state')
        local pr_merged=$(echo "$pr" | jq -r '.mergedAt // "null"')
        
        # Extract JIRA keys from title and body
        local jira_keys=$(extract_jira_keys "$pr_title $pr_body")
        
        if [[ -z "$jira_keys" ]]; then
            continue
        fi
        
        # Process each JIRA key found
        while IFS= read -r jira_key; do
            [[ -z "$jira_key" ]] && continue
            
            # Determine target status based on PR state
            local target_status=""
            
            if [[ "$pr_merged" != "null" ]]; then
                target_status="Done"
            elif [[ "$pr_state" == "OPEN" ]]; then
                target_status="In Progress"
            else
                continue  # Closed but not merged - skip
            fi
            
            # Get current ticket status
            local ticket_data
            if ! ticket_data=$(jira_get_issue "$jira_key" 2>/dev/null); then
                debug "Ticket $jira_key not found or inaccessible"
                continue
            fi
            
            local current_status=$(echo "$ticket_data" | jq -r '.fields.status.name')
            local current_status_lower=$(echo "$current_status" | tr '[:upper:]' '[:lower:]')
            local target_status_lower=$(echo "$target_status" | tr '[:upper:]' '[:lower:]')
            
            # Skip if already in target status
            if [[ "$current_status_lower" == "$target_status_lower" ]]; then
                debug "$jira_key already in $target_status"
                continue
            fi
            
            # Attempt transition
            info "Transitioning $jira_key: $current_status → $target_status (PR #$pr_number)"
            
            if jira_transition "$jira_key" "$target_status" > /dev/null 2>&1; then
                success "$jira_key → $target_status"
                ((updated++))
            else
                warning "Failed to transition $jira_key (transition may not be available)"
                ((errors++))
            fi
            
        done <<< "$jira_keys"
        
    done < <(echo "$prs" | jq -c '.[]' 2>/dev/null)
    
    echo "$updated $errors"
}

# Main function
main() {
    # Check dependencies
    check_dependencies || exit 1
    
    # Check for GitHub CLI
    if ! check_gh_cli; then
        error "GitHub CLI (gh) is required for sync functionality"
        info "Install with: brew install gh"
        exit 1
    fi
    
    # Parse arguments
    local specific_repo=""
    local days=7
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --repo)
                specific_repo="${2:-}"
                shift 2
                ;;
            --days)
                days="${2:-7}"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown argument: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Check for required GitHub config
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        error "GITHUB_TOKEN is required for sync"
        exit 1
    fi
    
    if [[ -z "${GITHUB_ORG:-}" ]] && [[ -z "$specific_repo" ]]; then
        error "GITHUB_ORG is required when not specifying --repo"
        exit 1
    fi
    
    # Get list of repositories to sync
    local repos=()
    
    if [[ -n "$specific_repo" ]]; then
        repos=("$specific_repo")
        info "Syncing repository: $specific_repo"
    else
        info "Fetching repositories from $GITHUB_ORG..."
        
        local repo_list=$(github_list_repos)
        
        if [[ -z "$repo_list" ]]; then
            error "No repositories found in $GITHUB_ORG"
            exit 1
        fi
        
        # Bash 3.2 compatible array population
        repos=()
        while IFS= read -r repo; do
            [[ -n "$repo" ]] && repos+=("$repo")
        done <<< "$repo_list"
        
        info "Found ${#repos[@]} repositories"
    fi
    
    # Sync each repository
    local total_updated=0
    local total_errors=0
    local total_scanned=0
    
    for repo in "${repos[@]}"; do
        [[ -z "$repo" ]] && continue
        
        ((total_scanned++))
        
        local result=$(sync_repository "$repo" "$days")
        local updated=$(echo "$result" | cut -d' ' -f1)
        local errors=$(echo "$result" | cut -d' ' -f2)
        
        ((total_updated += updated))
        ((total_errors += errors))
    done
    
    # Summary
    echo ""
    success "Sync complete!"
    info "Scanned: $total_scanned repositories"
    info "Updated: $total_updated tickets"
    
    if [[ $total_errors -gt 0 ]]; then
        warning "Errors: $total_errors"
    else
        info "Errors: 0"
    fi
    
    echo ""
}

# Run main function
main "$@"
