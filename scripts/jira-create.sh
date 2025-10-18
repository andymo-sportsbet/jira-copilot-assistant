#!/usr/bin/env bash

# jira-create.sh
# Create JIRA tickets from command-line arguments
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
source "${SCRIPT_DIR}/lib/jira-format.sh"

# Load environment
load_env "${SCRIPT_DIR}/../.env"

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") --summary "Title" [OPTIONS]

Create a JIRA ticket with the specified details.

Required Arguments:
  --summary TEXT        Ticket title/summary (required)

Optional Arguments:
  --description TEXT    Detailed description of the ticket
  --features LIST       Comma-separated list of features/requirements
  --priority LEVEL      Priority: High, Medium, Low (default: Medium)
  --help, -h           Show this help message

Examples:
  # Simple ticket
  $(basename "$0") --summary "User Authentication"

  # Full ticket with all details
  $(basename "$0") \\
    --summary "User Authentication System" \\
    --description "Implement OAuth 2.0 authentication with JWT tokens" \\
    --features "Google OAuth,GitHub OAuth,JWT tokens,Token refresh,MFA support" \\
    --priority "High"

Environment Variables:
  JIRA_BASE_URL        Your JIRA instance URL (e.g., https://company.atlassian.net)
  JIRA_TOKEN          JIRA API token
  JIRA_PROJECT        JIRA project key (e.g., PROJ)

EOF
}

# Main function
main() {
    # Check dependencies
    check_dependencies || exit 1
    
    # Parse arguments
        # Load dry-run helper
        # shellcheck disable=SC1091
        source "$(dirname "${BASH_SOURCE[0]}")/lib/dryrun.sh"

        parse_dry_run_arg "$@"

        if is_dry_run; then
            echo "Dry-run: would create JIRA ticket (no network calls)." >&2
            exit 0
        fi
    if ! parse_args "$@"; then
        [[ $? -eq 2 ]] && show_help && exit 0
        show_help
        exit 1
    fi
    
    # Validate required arguments
    if [[ -z "${ARG_SUMMARY:-}" ]]; then
        error "Missing required argument: --summary"
        echo ""
        show_help
        exit 1
    fi
    
    # Extract arguments with defaults
    local summary="${ARG_SUMMARY}"
    local description="${ARG_DESCRIPTION:-}"
    local features="${ARG_FEATURES:-}"
    local priority="${ARG_PRIORITY:-Medium}"
    
    # Validate priority (convert to lowercase for comparison)
    local priority_lower=$(echo "$priority" | tr '[:upper:]' '[:lower:]')
    case "$priority_lower" in
        high|medium|low|highest|lowest|critical|blocker|urgent)
            ;;
        *)
            warning "Invalid priority '$priority', using 'Medium'"
            priority="Medium"
            ;;
    esac
    
    # Build description with features
    local full_description="$description"
    
    if [[ -n "$features" ]]; then
        local feature_bullets=$(features_to_bullets "$features")
        if [[ -n "$description" ]]; then
            full_description="${description}"
            full_description+=$'\n\n'
            full_description+="*Features:*"
            full_description+=$'\n'
            full_description+="${feature_bullets}"
        else
            full_description="*Features:*"
            full_description+=$'\n'
            full_description+="${feature_bullets}"
        fi
    fi
    
    # Truncate description if too long (JIRA has limits)
    full_description=$(truncate_text "$full_description" 5000)
    
    # Wrap description in COPILOT_GENERATED markers
    local start_marker="⚡ COPILOT_GENERATED_START ⚡"
    local end_marker="⚡ COPILOT_GENERATED_END ⚡"
    
    local marked_description=""
    marked_description+="$start_marker"
    marked_description+=$'\n\n'
    marked_description+="$full_description"
    marked_description+=$'\n\n'
    marked_description+="$end_marker"
    
    # Convert to ADF format
    local description_adf=$(markdown_to_jira_adf "$marked_description")
    
    # Get priority ID
    local priority_id=$(get_priority_id "$priority")
    
    # Build JIRA issue JSON (priority is optional)
    local issue_json
    if [[ -n "$priority" ]] && [[ "$priority" != "Medium" ]]; then
        # Include priority if explicitly set
        issue_json=$(jq -n \
            --arg project "$JIRA_PROJECT" \
            --arg summary "$summary" \
            --argjson description "$description_adf" \
            --arg priority_id "$priority_id" \
            '{
                fields: {
                    project: {
                        key: $project
                    },
                    summary: $summary,
                    description: $description,
                    issuetype: {
                        name: "Story"
                    },
                    labels: ["copilot-created"]
                }
            }')
    else
        # Exclude priority field
        issue_json=$(jq -n \
            --arg project "$JIRA_PROJECT" \
            --arg summary "$summary" \
            --argjson description "$description_adf" \
            '{
                fields: {
                    project: {
                        key: $project
                    },
                    summary: $summary,
                    description: $description,
                    issuetype: {
                        name: "Story"
                    },
                    labels: ["copilot-created"]
                }
            }')
    fi
    
    debug "Creating JIRA issue..."
    debug "JSON: $issue_json"
    
    # Create the issue
    local response
    if ! response=$(jira_create_issue "$issue_json"); then
        error "Failed to create JIRA ticket"
        exit 1
    fi
    
    # Extract ticket key from response
    local ticket_key=$(echo "$response" | jq -r '.key')
    local ticket_url=$(get_issue_url "$ticket_key")
    
    # Success output
    echo ""
    success "Created: $ticket_key"
    info "Summary: $summary"
    if [[ -n "$description" ]]; then
        info "Description: $(truncate_text "$description" 100)"
    fi
    if [[ -n "$features" ]]; then
        info "Features: $features"
    fi
    info "Priority: $priority"
    echo -e "${BLUE}🔗 $ticket_url${NC}"
    echo ""
}

# Run main function
main "$@"
