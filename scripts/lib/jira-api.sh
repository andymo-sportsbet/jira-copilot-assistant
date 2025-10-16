#!/usr/bin/env bash

# JIRA API Library
# Provides reusable functions for JIRA REST API operations
#
# Note: This is a library file meant to be sourced.
# Do not use 'set -euo pipefail' here as it affects the calling script.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check required environment variables
check_jira_config() {
    local missing=()
    
    [[ -z "${JIRA_BASE_URL:-}" ]] && missing+=("JIRA_BASE_URL")
    [[ -z "${JIRA_EMAIL:-}" ]] && missing+=("JIRA_EMAIL")
    
    # Support both JIRA_TOKEN and JIRA_API_TOKEN
    if [[ -z "${JIRA_TOKEN:-}" ]] && [[ -z "${JIRA_API_TOKEN:-}" ]]; then
        missing+=("JIRA_TOKEN or JIRA_API_TOKEN")
    else
        # Use JIRA_API_TOKEN if JIRA_TOKEN is not set
        JIRA_TOKEN="${JIRA_TOKEN:-${JIRA_API_TOKEN}}"
    fi
    
    [[ -z "${JIRA_PROJECT:-}" ]] && missing+=("JIRA_PROJECT")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required environment variables:${NC}" >&2
        printf '%s\n' "${missing[@]}" | sed 's/^/  - /' >&2
        echo "" >&2
        echo "Please set these variables in your .env file or environment." >&2
        return 1
    fi
}

# Generic JIRA API call
# Usage: jira_api_call <method> <endpoint> [data]
jira_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"
    
    check_jira_config || return 1
    
    local url="${JIRA_BASE_URL}/rest/api/3${endpoint}"
    local response
    local http_code
    
    # Create a temporary netrc-style auth to avoid shell escaping issues
    # Use curl's built-in Basic Auth with proper quoting
    if [[ -n "$data" ]]; then
        response=$(curl -s -w "\n%{http_code}" -X "${method}" \
            --user "${JIRA_EMAIL}:${JIRA_TOKEN}" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            --data "${data}" \
            "${url}")
    else
        response=$(curl -s -w "\n%{http_code}" -X "${method}" \
            --user "${JIRA_EMAIL}:${JIRA_TOKEN}" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            "${url}")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    # Handle HTTP errors
    case "$http_code" in
        200|201|204)
            echo "$body"
            return 0
            ;;
        401)
            echo -e "${RED}❌ Authentication failed. Check your JIRA_EMAIL and JIRA_TOKEN.${NC}" >&2
            return 1
            ;;
        403)
            echo -e "${RED}❌ Permission denied. Check your JIRA permissions.${NC}" >&2
            return 1
            ;;
        404)
            echo -e "${RED}❌ Resource not found.${NC}" >&2
            return 1
            ;;
        *)
            echo -e "${RED}❌ API error (HTTP $http_code):${NC}" >&2
            echo "$body" | jq -r '.errorMessages[]? // .errors? // .' >&2 2>/dev/null || echo "$body" >&2
            return 1
            ;;
    esac
}

# Create a JIRA issue
# Usage: jira_create_issue <issue_json>
jira_create_issue() {
    local issue_data="$1"
    jira_api_call "POST" "/issue" "$issue_data"
}

# Get a JIRA issue
# Usage: jira_get_issue <issue_key>
jira_get_issue() {
    local issue_key="$1"
    jira_api_call "GET" "/issue/${issue_key}"
}

# Update a JIRA issue
# Usage: jira_update_issue <issue_key> <update_json>
jira_update_issue() {
    local issue_key="$1"
    local update_data="$2"
    jira_api_call "PUT" "/issue/${issue_key}" "$update_data"
}

# Get available transitions for an issue
# Usage: jira_get_transitions <issue_key>
jira_get_transitions() {
    local issue_key="$1"
    jira_api_call "GET" "/issue/${issue_key}/transitions"
}

# Transition a JIRA issue to a new status
# Usage: jira_transition <issue_key> <transition_name>
jira_transition() {
    local issue_key="$1"
    local transition_name="$2"
    
    # Get available transitions
    local transitions=$(jira_get_transitions "$issue_key")
    
    # Find transition ID by name (case-insensitive)
    local transition_name_lower=$(echo "$transition_name" | tr '[:upper:]' '[:lower:]')
    local transition_id=$(echo "$transitions" | jq -r \
        ".transitions[] | select(.name | ascii_downcase == \"${transition_name_lower}\") | .id" | head -1)
    
    if [[ -z "$transition_id" ]]; then
        echo -e "${RED}❌ Transition '${transition_name}' not found.${NC}" >&2
        echo -e "${YELLOW}Available transitions:${NC}" >&2
        echo "$transitions" | jq -r '.transitions[].name' | sed 's/^/  - /' >&2
        return 1
    fi
    
    local transition_data=$(jq -n --arg id "$transition_id" '{transition: {id: $id}}')
    jira_api_call "POST" "/issue/${issue_key}/transitions" "$transition_data"
}

# Add a comment to a JIRA issue
# Usage: jira_add_comment <issue_key> <comment_text>
jira_add_comment() {
    local issue_key="$1"
    local comment_text="$2"
    
    local comment_data=$(jq -n --arg text "$comment_text" '{
        body: {
            type: "doc",
            version: 1,
            content: [{
                type: "paragraph",
                content: [{
                    type: "text",
                    text: $text
                }]
            }]
        }
    }')
    
    jira_api_call "POST" "/issue/${issue_key}/comment" "$comment_data"
}

# Get JIRA priority ID by name
# Usage: get_priority_id <priority_name>
get_priority_id() {
    local priority_name="${1:-Medium}"
    local priority_lower=$(echo "$priority_name" | tr '[:upper:]' '[:lower:]')
    
    case "$priority_lower" in
        highest|critical|blocker)
            echo "1"  # Highest
            ;;
        high|urgent)
            echo "2"  # High
            ;;
        medium|normal)
            echo "3"  # Medium
            ;;
        low)
            echo "4"  # Low
            ;;
        lowest)
            echo "5"  # Lowest
            ;;
        *)
            echo "3"  # Default to Medium
            ;;
    esac
}

# Build issue URL
# Usage: get_issue_url <issue_key>
get_issue_url() {
    local issue_key="$1"
    echo "${JIRA_BASE_URL}/browse/${issue_key}"
}
