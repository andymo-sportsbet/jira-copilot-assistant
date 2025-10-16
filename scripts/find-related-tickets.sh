#!/usr/bin/env bash
#
# Find Related Tickets - Example Script
# Uses jira-search.sh library to find tickets related to an epic
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/lib/utils.sh"

# Load environment before sourcing other libs that use it
cd "$PROJECT_ROOT"
load_env .env

source "$SCRIPT_DIR/lib/jira-api.sh"
source "$SCRIPT_DIR/lib/jira-search.sh"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Find JIRA tickets related to a specific epic or search criteria.

OPTIONS:
    -e, --epic EPIC_KEY          Epic key to search under (e.g., RVV-1178)
    -t, --text SEARCH_TEXT       Text to search for
    -p, --project PROJECT_KEY    Project key (default: RVV)
    -f, --filter JQL             Additional JQL filter
    -o, --output FILE            Save ticket keys to file
    -h, --help                   Show this help message

EXAMPLES:
    # Find all tickets under an epic
    $(basename "$0") -e RVV-1178
    
    # Find Spring Boot tickets in RVV project
    $(basename "$0") -p RVV -t "spring boot upgrade"
    
    # Find Spring Boot tickets under an epic
    $(basename "$0") -e RVV-1178 -f 'AND text ~ "spring boot"'
    
    # Save results to file
    $(basename "$0") -e RVV-1178 -o .temp/tickets.txt

EOF
    exit 1
}

# Parse arguments
EPIC_KEY=""
SEARCH_TEXT=""
PROJECT_KEY="RVV"
ADDITIONAL_FILTER=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--epic)
            EPIC_KEY="$2"
            shift 2
            ;;
        -t|--text)
            SEARCH_TEXT="$2"
            shift 2
            ;;
        -p|--project)
            PROJECT_KEY="$2"
            shift 2
            ;;
        -f|--filter)
            ADDITIONAL_FILTER="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate input
if [[ -z "$EPIC_KEY" ]] && [[ -z "$SEARCH_TEXT" ]]; then
    error "Either --epic or --text must be provided"
    usage
fi

# Perform search
info "Searching for related tickets..."
echo ""

if [[ -n "$EPIC_KEY" ]]; then
    # Search by epic
    info "Epic: $EPIC_KEY"
    
    # Get epic details
    epic_data=$(jira_get_issue "$EPIC_KEY")
    epic_summary=$(echo "$epic_data" | jq -r '.fields.summary')
    info "Epic Summary: $epic_summary"
    echo ""
    
    # Search for tickets under epic
    search_results=$(jira_search_by_epic "$EPIC_KEY" "$ADDITIONAL_FILTER")
    
elif [[ -n "$SEARCH_TEXT" ]]; then
    # Search by text
    info "Project: $PROJECT_KEY"
    info "Search Text: $SEARCH_TEXT"
    echo ""
    
    search_results=$(jira_search_by_text "$PROJECT_KEY" "$SEARCH_TEXT" "$ADDITIONAL_FILTER")
fi

# Display results
total=$(jira_search_count "$search_results")
info "Found $total tickets:"
echo ""

jira_extract_summaries "$search_results"
echo ""

# Save to file if requested
if [[ -n "$OUTPUT_FILE" ]]; then
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    jira_extract_keys "$search_results" > "$OUTPUT_FILE"
    success "Ticket keys saved to: $OUTPUT_FILE"
fi

# Return the results for scripting
echo "$search_results"
