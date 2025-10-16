#!/usr/bin/env bash
#
# JIRA Search Library
# Reusable functions for searching JIRA tickets using JQL queries
#

# Function: jira_search
# Searches JIRA using a JQL query
#
# Arguments:
#   $1 - JQL query string
#   $2 - (optional) Fields to retrieve (comma-separated, default: "summary,issuetype,status,description")
#   $3 - (optional) Max results (default: 50)
#
# Returns:
#   JSON response from JIRA search API
#
# Example:
#   results=$(jira_search "project = RVV AND text ~ \"spring boot\"")
#   echo "$results" | jq -r '.issues[] | "\(.key): \(.fields.summary)"'
#
jira_search() {
    local jql="$1"
    local fields="${2:-summary,issuetype,status,description}"
    local max_results="${3:-50}"
    
    if [[ -z "$jql" ]]; then
        error "JQL query is required"
        return 1
    fi
    
    # Support both JIRA_TOKEN and JIRA_API_TOKEN
    local jira_token="${JIRA_TOKEN:-${JIRA_API_TOKEN}}"
    
    # Build search request body
    local search_body
    search_body=$(jq -n \
        --arg jql "$jql" \
        --arg fields "$fields" \
        --argjson maxResults "$max_results" \
        '{
            jql: $jql,
            maxResults: $maxResults,
            fields: ($fields | split(","))
        }')
    
    # Use JIRA search API v3 with POST (/search/jql endpoint, not /search)
    local response
    response=$(curl -s -X POST \
        --user "${JIRA_EMAIL}:${jira_token}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$search_body" \
        "${JIRA_BASE_URL}/rest/api/3/search/jql")
    
    # Check for errors
    local error_messages
    error_messages=$(echo "$response" | jq -r '.errorMessages[]? // empty' 2>/dev/null)
    if [[ -n "$error_messages" ]]; then
        error "JIRA search failed: $error_messages"
        return 1
    fi
    
    echo "$response"
}

# Function: jira_search_by_epic
# Searches for all tickets linked to a specific epic
#
# Arguments:
#   $1 - Epic key (e.g., "RVV-1178")
#   $2 - (optional) Additional JQL filters
#   $3 - (optional) Max results (default: 100)
#
# Returns:
#   JSON response with tickets linked to the epic
#
# Example:
#   results=$(jira_search_by_epic "RVV-1178" "AND text ~ \"spring boot\"")
#
jira_search_by_epic() {
    local epic_key="$1"
    local additional_filters="${2:-}"
    local max_results="${3:-100}"
    
    if [[ -z "$epic_key" ]]; then
        error "Epic key is required"
        return 1
    fi
    
    # Try both "parent" (JIRA Cloud) and "Epic Link" (old syntax) for compatibility
    local jql="(parent = $epic_key OR \"Epic Link\" = $epic_key)"
    if [[ -n "$additional_filters" ]]; then
        jql="$jql $additional_filters"
    fi
    jql="$jql ORDER BY key ASC"
    
    jira_search "$jql" "summary,issuetype,status,description,epic" "$max_results"
}

# Function: jira_search_by_text
# Searches for tickets containing specific text
#
# Arguments:
#   $1 - Project key (e.g., "RVV")
#   $2 - Search text
#   $3 - (optional) Additional JQL filters
#   $4 - (optional) Max results (default: 50)
#
# Returns:
#   JSON response with matching tickets
#
# Example:
#   results=$(jira_search_by_text "RVV" "spring boot upgrade")
#
jira_search_by_text() {
    local project="$1"
    local search_text="$2"
    local additional_filters="${3:-}"
    local max_results="${4:-50}"
    
    if [[ -z "$project" ]] || [[ -z "$search_text" ]]; then
        error "Project and search text are required"
        return 1
    fi
    
    local jql="project = $project AND text ~ \"$search_text\""
    if [[ -n "$additional_filters" ]]; then
        jql="$jql $additional_filters"
    fi
    jql="$jql ORDER BY key ASC"
    
    jira_search "$jql" "summary,issuetype,status,description" "$max_results"
}

# Function: jira_extract_keys
# Extracts ticket keys from search results
#
# Arguments:
#   $1 - JSON search results
#
# Returns:
#   List of ticket keys (one per line)
#
# Example:
#   keys=$(jira_extract_keys "$search_results")
#
jira_extract_keys() {
    local search_results="$1"
    echo "$search_results" | jq -r '.issues[].key'
}

# Function: jira_extract_summaries
# Extracts ticket keys and summaries from search results
#
# Arguments:
#   $1 - JSON search results
#
# Returns:
#   List of "KEY: Summary" (one per line)
#
# Example:
#   jira_extract_summaries "$search_results"
#
jira_extract_summaries() {
    local search_results="$1"
    echo "$search_results" | jq -r '.issues[] | "\(.key): \(.fields.summary)"'
}

# Function: jira_search_count
# Returns the total count of search results
#
# Arguments:
#   $1 - JSON search results
#
# Returns:
#   Total count of tickets found
#
# Example:
#   count=$(jira_search_count "$search_results")
#
jira_search_count() {
    local search_results="$1"
    echo "$search_results" | jq -r '.total'
}

# Function: jira_search_filter_by_summary
# Filters search results by summary pattern
#
# Arguments:
#   $1 - JSON search results
#   $2 - Grep pattern (e.g., "Spring Boot|spring boot")
#
# Returns:
#   Filtered JSON with matching tickets
#
# Example:
#   filtered=$(jira_search_filter_by_summary "$results" "Spring Boot")
#
jira_search_filter_by_summary() {
    local search_results="$1"
    local pattern="$2"
    
    echo "$search_results" | jq --arg pattern "$pattern" '
        .issues |= map(select(.fields.summary | test($pattern; "i")))
        | .total = (.issues | length)
    '
}
