#!/bin/bash

# Get the appropriate description prompt template based on JIRA issue type
# Usage: ./scripts/get-description-template.sh TICKET-ID

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/jira-api.sh"

# Load environment
if [[ -f "${SCRIPT_DIR}/../.env" ]]; then
    # shellcheck disable=SC1091
    source "${SCRIPT_DIR}/../.env"
fi

# Validate JIRA configuration
check_jira_config

# Function to show usage
show_usage() {
    cat << EOF
Usage: $(basename "$0") TICKET-ID [OPTIONS]

Get the appropriate AI description prompt template based on JIRA issue type.

Arguments:
    TICKET-ID       JIRA ticket ID (e.g., RVV-1234)

Examples:
    $(basename "$0") RVV-1234
    $(basename "$0") RVV-1234 --print
    $(basename "$0") RVV-1234 --ai-suggest

Options:
    --print         Print the template path instead of opening in editor
    --ai-suggest    Use AI to suggest template based on ticket content (overrides issue type)

Output:
    Opens the appropriate prompt template in VS Code, or prints the path if --print is used.

Issue Type Mapping:
    Story, New Feature          -> generate-description-story.md
    Bug, Defect                 -> generate-description-bug.md
    Spike, Research             -> generate-description-spike.md
    Technical Debt, Improvement -> generate-description-tech-debt.md
    Task (with --ai-suggest)    -> AI analyzes summary to suggest best template
    Other/Unknown               -> generate-description-default.md

AI Suggestion:
    When using --ai-suggest, the script analyzes the ticket summary and description
    to intelligently suggest the most appropriate template. This is especially useful
    for generic issue types like "Task" which can represent different work types.
EOF
    exit 1
}

# Function to create AI suggestion prompt
create_ai_suggestion_prompt() {
    local summary="$1"
    local description="$2"
    local issue_type="$3"
    
    cat << EOF
Analyze this JIRA ticket and determine the most appropriate description template type.

TICKET INFORMATION:
Issue Type: ${issue_type}
Summary: ${summary}
Description: ${description}

AVAILABLE TEMPLATES:
1. story - For user-facing features, new capabilities, enhancements
   Keywords: feature, enhancement, user, capability, enable, allow
   
2. bug - For defects, issues, broken functionality
   Keywords: bug, defect, broken, error, fail, not working, issue
   
3. spike - For research, investigation, proof of concept, technical exploration
   Keywords: spike, research, investigate, explore, POC, evaluate, assess
   
4. tech-debt - For refactoring, upgrades, modernization, technical improvements
   Keywords: upgrade, refactor, modernize, improve, technical debt, migration

Based on the ticket summary and description, which template type is most appropriate?

Respond with ONLY ONE of these exact words: story, bug, spike, tech-debt

Your response:
EOF
}

# Function to suggest template using simple AI-like heuristics
suggest_template_smart() {
    local summary="$1"
    local description="$2"
    
    # Convert to lowercase for matching
    local text="${summary} ${description}"
    local text_lower=$(echo "$text" | tr '[:upper:]' '[:lower:]')
    
    # Tech debt indicators (check first - upgrade/migration are very specific)
    if echo "$text_lower" | grep -E -q "(upgrade|migration|migrate|modernize|spring boot [0-9]|java [0-9]+|update.*version|dependency.*update)"; then
        echo "tech-debt"
        return 0
    fi
    
    # Spike/Research indicators (check before bug - "investigate issue" might contain "issue")
    if echo "$text_lower" | grep -E -q "(spike|research|investigate|exploration|evaluate|assess|poc|proof of concept|feasibility|study|compare|analysis)"; then
        echo "spike"
        return 0
    fi
    
    # Bug indicators (be specific - avoid false positives from words like "spring")
    if echo "$text_lower" | grep -E -q "(\\bbug\\b|defect|broken|\\berror\\b|\\bfail|not working|\\bcrash|exception|incorrect|\\bfix\\b.*\\bissue)"; then
        echo "bug"
        return 0
    fi
    
    # Story/Feature indicators
    if echo "$text_lower" | grep -E -q "(\\bfeature\\b|enhancement|user story|capability|enable|allow|add support|new functionality|implement.*feature)"; then
        echo "story"
        return 0
    fi
    
    # Tech debt indicators (broader - refactor, improve, etc.)
    if echo "$text_lower" | grep -E -q "(refactor|technical debt|\\bimprove|optimization|\\bupdate\\b|\\bcleanup\\b|\\bdebt\\b)"; then
        echo "tech-debt"
        return 0
    fi
    
    # Default to tech-debt for generic tasks
    echo "tech-debt"
    return 0
}

# Main function
main() {
    local ticket_id="${1:-}"
    local print_only=false
    local use_ai_suggest=false
    
    if [[ "$ticket_id" == "--help" ]] || [[ "$ticket_id" == "-h" ]] || [[ -z "$ticket_id" ]]; then
        show_usage
    fi
    
    # Parse options
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --print)
                print_only=true
                shift
                ;;
            --ai-suggest)
                use_ai_suggest=true
                shift
                ;;
            *)
                warning "Unknown option: $1"
                shift
                ;;
        esac
    done
    
    info "Fetching ticket details for ${ticket_id}..."
    
    # Fetch ticket data
    local ticket_data=$(jira_get_issue "$ticket_id")
    
    if [[ -z "$ticket_data" ]] || [[ "$ticket_data" == "null" ]]; then
        error "Failed to fetch ticket ${ticket_id}"
        exit 1
    fi
    
    # Extract issue type and summary
    local issue_type=$(echo "$ticket_data" | jq -r '.fields.issuetype.name // "Unknown"')
    local summary=$(echo "$ticket_data" | jq -r '.fields.summary')
    local description=$(echo "$ticket_data" | jq -r '.fields.description.content[0].content[0].text // ""' 2>/dev/null || echo "")
    
    info "Ticket: ${summary}"
    info "Issue Type: ${issue_type}"
    
    # Determine template based on issue type or AI suggestion
    local template_file=""
    local template_name=""
    local suggested_type=""
    
    # Convert to lowercase for comparison
    local issue_type_lower=$(echo "${issue_type}" | tr '[:upper:]' '[:lower:]')
    
    # Use AI suggestion if requested OR if issue type is generic "Task"
    if [[ "$use_ai_suggest" == true ]] || [[ "$issue_type_lower" == "task" ]]; then
        if [[ "$issue_type_lower" == "task" ]]; then
            info "ℹ️  Issue type is 'Task' (generic) - analyzing content to suggest best template..."
        fi
        
        suggested_type=$(suggest_template_smart "$summary" "$description")
        
        if [[ $? -eq 0 ]] && [[ -n "$suggested_type" ]]; then
            success "🤖 Smart suggestion based on content: ${suggested_type}"
            issue_type_lower="$suggested_type"
        fi
    fi
    
    # Map to template file
    case "${issue_type_lower}" in
        "story"|"new feature"|"feature")
            template_file=".prompts/generate-description-story.md"
            template_name="Story/Feature"
            ;;
        "bug"|"defect")
            template_file=".prompts/generate-description-bug.md"
            template_name="Bug"
            ;;
        "spike"|"research"|"investigation"|"technical investigation")
            template_file=".prompts/generate-description-spike.md"
            template_name="Spike/Research"
            ;;
        "technical debt"|"improvement"|"tech debt"|"refactor"|"refactoring"|"tech-debt"|"techdebt")
            template_file=".prompts/generate-description-tech-debt.md"
            template_name="Technical Debt"
            ;;
        "task")
            # If we reach here, AI suggestion failed or wasn't used
            template_file=".prompts/generate-description-tech-debt.md"
            template_name="Technical Debt"
            info "ℹ️  Generic 'Task' issue type - defaulting to Technical Debt template"
            ;;
        *)
            template_file=".prompts/generate-description-default.md"
            template_name="Default"
            info "⚠️  Unknown issue type '${issue_type}', using default template"
            ;;
    esac
    
    success "Selected template: ${template_name} (${template_file})"
    
    if [[ "$print_only" == true ]]; then
        echo "$template_file"
    else
        # Open in VS Code
        if command -v code &> /dev/null; then
            info "Opening template in VS Code..."
            code "$template_file"
            
            # Helpful next steps
            echo ""
            echo "📋 Next steps:"
            echo "   1. Review the prompt template in VS Code"
            echo "   2. Use AI agent (Claude/Copilot) to generate description"
            echo "   3. Save output to: .temp/${ticket_id,,}-description.txt"
            echo "   4. Apply with: ./scripts/jira-groom.sh ${ticket_id} --ai-description .temp/${ticket_id,,}-description.txt"
        else
            warning "VS Code not found in PATH. Template path:"
            echo "$template_file"
        fi
    fi
}

# Run main function
main "$@"
