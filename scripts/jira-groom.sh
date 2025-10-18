#!/usr/bin/env bash

# jira-groom.sh
# Enhance JIRA tickets with AI-generated acceptance criteria
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
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/github-api.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/jira-estimate.sh"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/jira-estimate-team.sh"

# Load environment
load_env "${SCRIPT_DIR}/../.env"

# Global markers used by grooming to identify AI-generated sections
start_marker="⚡ COPILOT_GENERATED_START ⚡"
end_marker="⚡ COPILOT_GENERATED_END ⚡"

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") <TICKET-KEY> [OPTIONS]

Groom a JIRA ticket by:
  1. Fetching ticket details from JIRA
  2. Searching GitHub for related PRs and commits
  3. Generating additional acceptance criteria
  4. Optionally including technical details from a reference spec file
  5. Updating the ticket with enhancements

Arguments:
  TICKET-KEY                JIRA ticket key (e.g., PROJ-123)

Options:
  --reference-file FILE     Path to spec file with technical implementation details
  --ai-guide FILE          Path to AI-generated technical guide (JIRA ADF JSON format)
  --ai-description FILE    Path to AI-generated enhanced description (plain text)
  --estimate               Enable AI-powered story point estimation (interactive)
  --points N               Manually set story points to N (0.5, 1, 2, 3, 4, 5)
  --auto-estimate          Auto-accept AI estimation without confirmation
  --team-scale             Use team-specific estimation (0.5-5, default: Fibonacci)
  --help, -h               Show this help message

Examples:
  # Basic grooming
  $(basename "$0") PROJ-123
  
  # Groom with AI story point estimation (interactive)
  $(basename "$0") PROJ-123 --estimate
  
  # Auto-accept AI estimation
  $(basename "$0") PROJ-123 --estimate --auto-estimate
  
  # Use team-specific scale (0.5, 1, 2, 3, 4, 5)
  $(basename "$0") PROJ-123 --estimate --team-scale
  
  # Manually set story points
  $(basename "$0") PROJ-123 --points 3
  
  # Groom with technical reference from spec file (uses template)
  $(basename "$0") RVV-1171 --reference-file specs/betmaker-ingestor-springboot3/spec.md
  
  # Groom with AI-generated guide (created by Claude/Copilot)
  $(basename "$0") RVV-1171 --ai-guide .temp/technical-guide.json
  
  # Groom with AI-generated description + guide (full AI enhancement)
  $(basename "$0") RVV-1171 --ai-description .temp/description.txt --ai-guide .temp/guide.json
  
  # After saving Confluence as spec
  ./scripts/confluence-to-spec.sh --url "..." --output specs/feature/spec.md
  $(basename "$0") PROJ-456 --reference-file specs/feature/spec.md

What this does:
  - Searches GitHub for PRs/commits mentioning the ticket
  - Generates 3-5 additional acceptance criteria based on context
  - If --reference-file provided: Extracts technical details from spec file (template)
  - If --ai-guide provided: Uses AI-generated technical guide (JIRA ADF JSON)
  - Updates ticket description with enhancements
  - Adds a comment with technical implementation guide (if provided)

Reference File Format:
  - Markdown file (.md)
  - Can include YAML front matter (Confluence metadata)
  - Extracts: Overview, Requirements, Technical Details sections
  - Best used with specs from confluence-to-spec.sh

Environment Variables:
  JIRA_BASE_URL      Your JIRA instance URL
  JIRA_EMAIL         Your JIRA email
  JIRA_TOKEN         JIRA API token (or JIRA_API_TOKEN)
  JIRA_PROJECT       JIRA project key
  GITHUB_TOKEN       GitHub API token (optional)
  GITHUB_ORG         GitHub organization (optional)

EOF
}

# Update story points for a JIRA ticket
# Usage: update_story_points <ticket_key> <points>
update_story_points() {
    local ticket_key="$1"
    local points="$2"
    
    # Always initialize manual_content before any use
    local manual_content=""
    if echo "$current_description" | grep -q "$start_marker"; then
        manual_content=$(echo "$current_description" | awk -v marker="$start_marker" '
            $0 ~ marker { exit }
            { print }
        ' | sed 's/[[:space:]]*$//')
        manual_content=$(echo "$manual_content" | sed 's/---[[:space:]]*$//' | sed 's/[[:space:]]*$//')
    fi
    if [[ -z "$manual_content" ]]; then
        manual_content="$current_description"
    fi
    # Get story points field from environment or use default
    local story_points_field="${JIRA_STORY_POINTS_FIELD:-customfield_10016}"
    
    # Validate points are in team scale
    if [[ ! "$points" =~ ^(0\.5|1|2|3|4|5)$ ]]; then
        error "Invalid story points: $points. Must be one of: 0.5, 1, 2, 3, 4, 5"
        return 1
    fi
    
    # Create update payload
    local update_payload=$(cat << EOF
{
  "fields": {
    "${story_points_field}": $points
  }
}
EOF
)
    
    info "Updating story points to $points..."
    
    if jira_update_issue "$ticket_key" "$update_payload"; then
        success "✅ Story points updated to $points"
        return 0
    else
        echo ""
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}⚠️  Story Points field is not on the screen for this ticket type${NC}"
        echo ""
        echo -e "${BLUE}Possible solutions:${NC}"
        echo "  1. Ask your JIRA admin to add 'Story Points' field to the edit screen"
        echo "  2. Manually update the ticket in JIRA UI (if the field is visible)"
        echo "  3. Convert ticket to a type that has Story Points on its screen"
        echo ""
        echo -e "${GREEN}AI Estimation: $points points (~$(echo "$points * 7" | bc) focus hours / $points focus days / $(echo "$points * 2" | bc) working days)${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        return 1
    fi
}

# Generate acceptance criteria based on ticket and GitHub context
generate_acceptance_criteria() {
    local ticket_data="$1"
    local github_context="$2"
    
    local summary=$(echo "$ticket_data" | jq -r '.fields.summary')
    local description=$(echo "$ticket_data" | jq -r '.fields.description.content[0].content[0].text // "No description"' 2>/dev/null || echo "No description")
    
    # For now, generate simple criteria based on ticket type and context
    # In a real implementation, this would call an AI API (OpenAI, Anthropic, etc.)
    
    cat << EOF
*Generated Acceptance Criteria:*

* Functionality should be fully tested with unit tests
* Code should follow project coding standards
* Documentation should be updated to reflect changes
* Security considerations should be reviewed and addressed
* Performance impact should be measured and acceptable
EOF
    
    # Add GitHub-specific criteria if we found related work
    if [[ -n "$github_context" ]] && [[ "$github_context" != "No related GitHub activity found." ]]; then
        cat << EOF

*Based on Related GitHub Activity:*

* Changes should be consistent with patterns in related PRs
* All related commits should be included in the implementation
* Existing tests should continue to pass
EOF
    fi
}

# Extract technical details from a reference spec file and format as JIRA document JSON
# Extract technical details from a reference spec file and generate with LLM
extract_technical_details() {
    local spec_file="$1"
    
    if [[ ! -f "$spec_file" ]]; then
        error "Reference file not found: $spec_file"
        return 1
    fi
    
    # Output info message to stderr so it doesn't pollute the JSON output
    info "📄 Extracting technical details from: $(basename "$spec_file")" >&2
    
    # Read the file content
    local content=$(cat "$spec_file")
    
    # Extract Confluence URL if present (from YAML front matter)
    local confluence_url=$(echo "$content" | grep -E "^confluence_url:" | sed 's/confluence_url: //' | tr -d ' ')
    
    # Check if LLM generation is enabled (via environment variable)
    if [[ "${USE_LLM_GENERATION:-false}" == "true" ]] && [[ -n "${OPENAI_API_KEY:-}" ]]; then
        info "🤖 Generating technical guide using LLM..." >&2
        generate_with_llm "$spec_file" "$confluence_url"
    else
        # Fallback to template-based generation
        if [[ "${USE_LLM_GENERATION:-false}" == "true" ]]; then
            warning "USE_LLM_GENERATION=true but OPENAI_API_KEY not set. Using template." >&2
            info "💡 Get an OpenAI API key at: https://platform.openai.com/api-keys" >&2
        fi
        info "📋 Using template-based generation" >&2
        generate_with_template "$confluence_url" "$(basename "$spec_file")"
    fi
}

# Generate technical guide using LLM (GitHub Copilot or OpenAI)
generate_with_llm() {
    local spec_file="$1"
    local confluence_url="$2"
    
    # Read spec content (truncate if too large to avoid token limits)
    local spec_content=$(cat "$spec_file" | head -500)
    
    # Create prompt for LLM
    local prompt="Based on the following technical specification, generate a JIRA Atlassian Document Format (ADF) JSON for a technical implementation guide comment.

SPECIFICATION:
$spec_content

REQUIREMENTS:
1. Extract the main upgrade/implementation topic from the spec
2. Identify core requirements (versions, tools, frameworks)
3. List key libraries and dependencies mentioned
4. Extract code changes or refactoring needed
5. Identify common issues and solutions mentioned
6. Note any configuration updates required

OUTPUT FORMAT: Valid JIRA ADF JSON with this structure:
- H2 heading: \"Technical Implementation Guide - [Topic]\"
- H3: \"Reference Documentation\" with link to: $confluence_url
- H2: \"Core Requirements\" with bullet list
- H3: \"Key Libraries & Dependencies\" with bullet list
- H3: \"Code Changes Required\" with bullet list  
- H3: \"Common Issues & Solutions\" with bullet list (use code marks for error names)
- H3: \"Configuration Updates\" with bullet list
- Horizontal rule
- Footer paragraph: \"AI-generated from spec\" in italic

Use strong marks for emphasis, code marks for technical terms, link marks for URLs.
Return ONLY valid JSON, no explanation."

    local llm_response=""
    
    # Use OpenAI API (if configured)
    if [[ -n "${OPENAI_API_KEY:-}" ]]; then
        info "🤖 Using OpenAI for AI generation..." >&2
        
        llm_response=$(curl -s https://api.openai.com/v1/chat/completions \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer ${OPENAI_API_KEY}" \
            -d "{
                \"model\": \"gpt-4\",
                \"messages\": [{
                    \"role\": \"system\",
                    \"content\": \"You are a technical documentation expert. Generate only valid JSON, no markdown formatting.\"
                }, {
                    \"role\": \"user\",
                    \"content\": $(echo "$prompt" | jq -Rs .)
                }],
                \"temperature\": 0.3
            }" 2>/dev/null)
        
        # Extract and clean response
        local content=$(echo "$llm_response" | jq -r '.choices[0].message.content' 2>/dev/null)
        
        if [[ -n "$content" ]] && [[ "$content" != "null" ]]; then
            # Clean up response (remove markdown code blocks if present)
            llm_response=$(echo "$content" | sed -n '/^{/,/^}/p')
            
            if [[ -n "$llm_response" ]] && echo "$llm_response" | jq '.' &>/dev/null 2>&1; then
                success "✅ Generated with OpenAI" >&2
                echo "$llm_response"
                return 0
            fi
        fi
    fi
    
    # If LLM fails, fallback to template
    warning "LLM generation failed, using template" >&2
    generate_with_template "$confluence_url" "$(basename "$spec_file")"
}

# Generate technical guide using static template (fallback)
generate_with_template() {
    local confluence_url="$1"
    local filename="$2"
    
    # Build JIRA document JSON using jq to avoid bash variable expansion issues
    jq -n \
      --arg url "$confluence_url" \
      --arg filename "$filename" \
      '{
        "body": {
          "type": "doc",
          "version": 1,
          "content": [
            {
              "type": "heading",
              "attrs": { "level": 2 },
              "content": [{ "type": "text", "text": "Technical Implementation Guide - Spring Boot 3 Upgrade" }]
            },
            {
              "type": "heading",
              "attrs": { "level": 3 },
              "content": [{ "type": "text", "text": "Reference Documentation" }]
            },
            {
              "type": "paragraph",
              "content": [
                { "type": "text", "text": "Based on DM Adapters upgrade: " },
                {
                  "type": "text",
                  "text": $url,
                  "marks": [{ "type": "link", "attrs": { "href": $url } }]
                }
              ]
            },
            {
              "type": "rule"
            },
            {
              "type": "heading",
              "attrs": { "level": 2 },
              "content": [{ "type": "text", "text": "Core Upgrade Requirements" }]
            },
            {
              "type": "bulletList",
              "content": [
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Gradle", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Upgrade to 8.13" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Java", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Upgrade to Java 17" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Spring Boot", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Upgrade to version 3.x" }] }] }
              ]
            },
            {
              "type": "heading",
              "attrs": { "level": 3 },
              "content": [{ "type": "text", "text": "Key Libraries & Dependencies" }]
            },
            {
              "type": "bulletList",
              "content": [
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Jakarta Migration", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Replace javax.* with jakarta.*" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "ByteBuddy", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Replace cglib (no longer supported)" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Spock/Objenesis", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Upgrade test libraries" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Spring Kafka", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Upgrade version" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Racing BOM", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Use for third-party libraries" }] }] }
              ]
            },
            {
              "type": "heading",
              "attrs": { "level": 3 },
              "content": [{ "type": "text", "text": "Code Changes Required" }]
            },
            {
              "type": "bulletList",
              "content": [
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Kafka retry logic", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Listener container factory no longer supports Spring retry template" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Event contracts", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Update with originTimestamp field (racing core)" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Bean qualifiers", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Use Spring bean qualifier annotation" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Test logging", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Remove logger verification (Java 17 incompatible)" }] }] }
              ]
            },
            {
              "type": "heading",
              "attrs": { "level": 3 },
              "content": [{ "type": "text", "text": "Common Issues & Solutions" }]
            },
            {
              "type": "bulletList",
              "content": [
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "NoClassDefFoundError: AsyncCache", "marks": [{ "type": "code" }] }, { "type": "text", "text": " → Upgrade caffeine to 3.2.0" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "NoSuchFieldError: JCTree$JCImport", "marks": [{ "type": "code" }] }, { "type": "text", "text": " → Upgrade lombok to latest" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Unable to resolve nested path", "marks": [{ "type": "code" }] }, { "type": "text", "text": " → Upgrade springdoc-openapi-ui" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Gradle plugin awsecr", "marks": [{ "type": "code" }] }, { "type": "text", "text": " → MUST upgrade to 0.7.0 for Gradle 8" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Integration tests fail", "marks": [{ "type": "code" }] }, { "type": "text", "text": " → Upgrade spock-spring library" }] }] }
              ]
            },
            {
              "type": "heading",
              "attrs": { "level": 3 },
              "content": [{ "type": "text", "text": "Configuration Updates" }]
            },
            {
              "type": "bulletList",
              "content": [
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "AWS log format", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Update datetime format for parser compatibility" }] }] },
                { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Racing BOM strategy", "marks": [{ "type": "strong" }] }, { "type": "text", "text": ": Add missing libs to BOM first, then use" }] }] }
              ]
            },
            {
              "type": "rule"
            },
            {
              "type": "paragraph",
              "content": [
                { "type": "text", "text": "Technical reference extracted from: \($filename)", "marks": [{ "type": "em" }] }
              ]
            }
          ]
        }
      }'
}

# Format GitHub context for display
format_github_context() {
    local prs="$1"
    local commits="$2"
    
    local pr_count=$(echo "$prs" | jq 'length' 2>/dev/null || echo "0")
    local commit_count=$(echo "$commits" | jq 'length' 2>/dev/null || echo "0")
    
    if [[ "$pr_count" == "0" ]] && [[ "$commit_count" == "0" ]]; then
        echo "No related GitHub activity found."
        return
    fi
    
    local context=""
    
    if [[ "$pr_count" -gt 0 ]]; then
        context+="*Related Pull Requests:*\n"
        context+=$(echo "$prs" | jq -r '.[] | "* PR #\(.number): \(.title) (\(.state)) - \(.url)"' 2>/dev/null || echo "")
        context+="\n\n"
    fi
    
    if [[ "$commit_count" -gt 0 ]]; then
        context+="*Related Commits:*\n"
        context+=$(echo "$commits" | jq -r '.[] | "* \(.sha): \(.message) (by \(.author))"' 2>/dev/null || echo "")
    fi
    
    echo -e "$context"
}

# Main function
main() {
    # Check dependencies
    check_dependencies || exit 1
    
    # Parse arguments
    local ticket_key=""
    local reference_file=""
    local ai_guide_file=""
    local ai_description_file=""
    local enable_estimation=false
    local manual_points=""
    local auto_estimate=false
    local use_team_scale=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --reference-file)
                reference_file="$2"
                shift 2
                ;;
            --ai-guide)
                ai_guide_file="$2"
                shift 2
                ;;
            --ai-description)
                ai_description_file="$2"
                shift 2
                ;;
            --estimate)
                enable_estimation=true
                shift
                ;;
            --points)
                manual_points="$2"
                shift 2
                ;;
            --auto-estimate)
                auto_estimate=true
                shift
                ;;
            --team-scale)
                use_team_scale=true
                shift
                ;;
            *)
                if [[ -z "$ticket_key" ]]; then
                    ticket_key="$1"
                    shift
                else
                    error "Unknown argument: $1"
                    echo ""
                    show_help
                    exit 1
                fi
                ;;
        esac
    done
    
    # Validate required argument
    if [[ -z "$ticket_key" ]]; then
        error "Missing required argument: TICKET-KEY"
        echo ""
        show_help
        exit 1
    fi
    
    # Validate reference file if provided
    if [[ -n "$reference_file" ]] && [[ ! -f "$reference_file" ]]; then
        error "Reference file not found: $reference_file"
        exit 1
    fi
    
    # Validate ticket key format
    validate_ticket_key "$ticket_key" || exit 1
    
    info "Fetching ticket details for $ticket_key..."
    
    # Fetch ticket details
    local ticket_data
    if ! ticket_data=$(jira_get_issue "$ticket_key"); then
        error "Failed to fetch ticket $ticket_key"
        exit 1
    fi
    
    # Save a raw current_description globally so helper functions can access it
    current_description=$(echo "$ticket_data" | jq -r '.fields.description // ""' 2>/dev/null || echo "")

    local summary=$(echo "$ticket_data" | jq -r '.fields.summary')
    info "Ticket: $summary"

    # Determine description type early: null / string / object
    desc_type=$(echo "$ticket_data" | jq -r 'if .fields.description == null then "null" elif (.fields.description|type) == "string" then "string" else "object" end')
    
    # Handle manual story points
    if [[ -n "$manual_points" ]]; then
        echo ""
        if update_story_points "$ticket_key" "$manual_points"; then
            echo ""
        else
            exit 1
        fi
    fi
    
    # AI Story Point Estimation (if enabled)
    local story_points=""
    local estimation_explanation=""
    if [[ "$enable_estimation" == "true" ]]; then
        local current_description=$(echo "$ticket_data" | jq -r '.fields.description // empty')
        
        # Extract plain text from ADF if present
        local description_text=""
        if [[ -n "$current_description" ]]; then
            # Try to extract text from ADF content
            description_text=$(echo "$current_description" | jq -r '
                if type == "object" then
                    [.. | .text? // empty] | join(" ")
                else
                    .
                end
            ' 2>/dev/null || echo "$current_description")
        fi
        
        echo ""
        echo "📊 AI Story Point Estimation"
        echo ""
        
        # Choose estimation method based on flag
        local estimation_result
        if [[ "$use_team_scale" == "true" ]]; then
            info "Using team-specific estimation (0.5, 1, 2, 3, 4, 5)..."
            estimation_result=$(estimate_story_points_team "$ticket_data")
            
            # Extract from JSON
            story_points=$(echo "$estimation_result" | jq -r '.estimated_points')
            local reasoning=$(echo "$estimation_result" | jq -r '.reasoning')
            local should_split=$(echo "$estimation_result" | jq -r '.should_split')
            local confidence=$(echo "$estimation_result" | jq -r '.confidence')
            
            # Display reasoning
            echo "🔍 Analysis:"
            echo "$reasoning" | sed 's/\\n/\n/g'
            echo ""
            echo "Confidence: $confidence"
            echo ""
            
            # Generate explanation
            estimation_explanation=$(generate_team_estimation_explanation "$story_points" "$summary")
            echo "$estimation_explanation"
            echo ""
            
            # Warn if should split
            if [[ "$should_split" == "true" ]]; then
                warning "⚠️  This story is large (${story_points} points). Consider breaking it down into smaller tasks."
                echo ""
            fi
        else
            info "Using default Fibonacci estimation (1, 2, 3, 5, 8, 13...)..."
            local estimation_output
            # Capture stdout (the number) and stderr (the analysis) separately
            story_points=$(estimate_story_points "$description_text" "$summary" 2>/dev/null)
            
            # Re-run to get the analysis from stderr
            local analysis
            analysis=$(estimate_story_points "$description_text" "$summary" 2>&1 >/dev/null)
            
            if [[ -n "$analysis" ]]; then
                echo "$analysis"
            fi
            
            # Generate explanation
            estimation_explanation=$(generate_estimation_explanation "$story_points")
            
            echo ""
            echo "🎯 Estimated: $story_points Story Points"
            echo ""
            echo "$estimation_explanation"
            echo ""
        fi
        
        # Interactive prompt (unless auto-estimate is enabled)
        if [[ "$auto_estimate" == "true" ]]; then
            info "Auto-accepting AI estimation: $story_points points"
            if update_story_points "$ticket_key" "$story_points"; then
                echo ""
            fi
        else
            echo "─────────────────────────────────────"
            echo "Would you like to update the ticket with $story_points story points?"
            echo ""
            echo "  [a] Accept AI estimation ($story_points points)"
            echo "  [o] Override with custom value"
            echo "  [s] Skip (don't update story points)"
            echo ""
            read -p "Your choice [a/o/s]: " -n 1 -r choice
            echo ""
            echo "─────────────────────────────────────"
            echo ""
            
            case "$choice" in
                a|A)
                    if update_story_points "$ticket_key" "$story_points"; then
                        echo ""
                    fi
                    ;;
                o|O)
                    read -p "Enter story points (0.5, 1, 2, 3, 4, 5): " custom_points
                    if update_story_points "$ticket_key" "$custom_points"; then
                        echo ""
                    fi
                    ;;
                s|S|*)
                    info "Skipped story point update"
                    story_points=""  # Clear story_points to prevent update
                    echo ""
                    ;;
            esac
        fi
    fi
    
    # Search GitHub for related work
    info "Searching GitHub for related PRs and commits..."
    local prs=$(github_search_prs "$ticket_key")
    local commits=$(github_search_commits "$ticket_key")
    
    local pr_count=$(echo "$prs" | jq 'length' 2>/dev/null || echo "0")
    local commit_count=$(echo "$commits" | jq 'length' 2>/dev/null || echo "0")
    
    if [[ "$pr_count" -gt 0 ]]; then
        success "Found $pr_count related PR(s)"
    fi
    
    if [[ "$commit_count" -gt 0 ]]; then
        success "Found $commit_count related commit(s)"
    fi
    
    if [[ "$pr_count" == "0" ]] && [[ "$commit_count" == "0" ]]; then
        warning "No related GitHub activity found"
    fi
    
    # Format GitHub context
    local github_context=$(format_github_context "$prs" "$commits")
    
    # Generate acceptance criteria
    info "Generating acceptance criteria..."
    local acceptance_criteria=$(generate_acceptance_criteria "$ticket_data" "$github_context")
    
    # Extract technical details from reference file if provided
    local technical_guide=""
    if [[ -n "$reference_file" ]]; then
        technical_guide=$(extract_technical_details "$reference_file")
    fi
    
    # Get current description from JIRA (handle ADF object or plain string)
        # Markers to identify generated content
        local start_marker="⚡ COPILOT_GENERATED_START ⚡"
        local end_marker="⚡ COPILOT_GENERATED_END ⚡"

        # Derive manual_content from current_description (preserve original description if it's a plain string)
        local manual_content=""
        if [[ -n "$current_description" && "$desc_type" != "object" ]]; then
            if echo "$current_description" | grep -q "$start_marker"; then
                manual_content=$(echo "$current_description" | awk -v marker="$start_marker" '
                    $0 ~ marker { exit }
                    { print }
                ' | sed 's/[[:space:]]*$//' )
                manual_content=$(echo "$manual_content" | sed 's/---[[:space:]]*$//' | sed 's/[[:space:]]*$//')
            else
                manual_content="$current_description"
            fi
        fi

        local enhanced_description=""
        # Only include the original ticket description in the markdown when it is plain text
        if [[ -n "$manual_content" ]]; then
            enhanced_description+="$manual_content"
            enhanced_description+=$'\n\n---\n\n'
        elif [[ -n "${original_summary:-}" ]]; then
            # Include a short original summary and a link to the backup .temp ADF file on the grooming host
            enhanced_description+="Original summary: ${original_summary}\n\n"
            enhanced_description+="(Full original ADF saved to: .temp/${ticket_key}-original-adf.json on the grooming host)"
            enhanced_description+=$'\n\n---\n\n'
        fi

    # Add markers around ALL generated content
    enhanced_description+="$start_marker\n\n"

    # Initialize ai_description (may be set later if --ai-description provided)
    local ai_description=""

    # Add AI-generated description (if provided)
    if [[ -n "$ai_description" ]]; then
        enhanced_description+="$ai_description\n\n---\n\n"
    fi

    # Add acceptance criteria
    enhanced_description+="$acceptance_criteria"

    # Add GitHub context if present
    if [[ -n "$github_context" ]] && [[ "$github_context" != "No related GitHub activity found." ]]; then
        enhanced_description+=$'\n\n---\n\n'
        enhanced_description+="$github_context"
    fi

    # Story point estimation will be added as a grooming comment (not in the description)

    enhanced_description+=$'\n\n'
    enhanced_description+="$end_marker"
    
    # If AI description provided, read and sanitize it (preserve blank lines, strip YAML front matter, remove markers)
    local ai_description=""
    if [[ -n "$ai_description_file" ]]; then
        if [[ ! -f "$ai_description_file" ]]; then
            error "AI description file not found: $ai_description_file"
            return 1
        fi
        info "Reading AI-generated description..."

        # Read whole file, strip YAML front matter if present, trim per-line whitespace but preserve blank lines
        ai_description=$(awk '
            BEGIN{in_front=0}
            NR==1 && $0 ~ /^---\s*$/ {in_front=1; next}
            in_front==1 && $0 ~ /^---\s*$/ {in_front=0; next}
            in_front==1 {next}
            {gsub(/^[ \t]+|[ \t]+$/,"",$0); print}
        ' "$ai_description_file")

        # Remove markers if the AI text already includes them to prevent duplication
        ai_description=$(printf "%s" "$ai_description" | sed 's/⚡ COPILOT_GENERATED_START ⚡//g' | sed 's/⚡ COPILOT_GENERATED_END ⚡//g')

        # If after sanitization the description is empty, abort
        if [[ -z "${ai_description//[[:space:]]/}" ]]; then
            error "AI description is empty after sanitization: $ai_description_file"
            return 1
        fi
    fi
    
    # Build enhanced description with smart marker deduplication
    local enhanced_description=""
    
    # 1. Start with manual content (if any)
    if [[ -n "$manual_content" ]]; then
        enhanced_description="$manual_content"
        enhanced_description+=$'\n\n---\n\n'
    elif [[ -n "${original_summary:-}" ]]; then
        # Include a short original summary and a link to the backup .temp ADF file on the grooming host
        enhanced_description+="Original summary: ${original_summary}"
        enhanced_description+=$'\n\n'
        enhanced_description+="(Full original ADF saved to: .temp/${ticket_key}-original-adf.json on the grooming host)"
        enhanced_description+=$'\n\n---\n\n'
    fi
    
    # 2. Add markers around ALL generated content
    enhanced_description+="$start_marker"
    enhanced_description+=$'\n\n'
    
    # 3. Add AI-generated description (if provided)
    if [[ -n "$ai_description" ]]; then
        enhanced_description+="$ai_description"
        enhanced_description+=$'\n\n---\n\n'
    fi
    
    # 4. Add acceptance criteria
    enhanced_description+="$acceptance_criteria"
    
    # 5. Add GitHub context (if available)
    if [[ -n "$github_context" ]] && [[ "$github_context" != "No related GitHub activity found." ]]; then
        enhanced_description+=$'\n\n---\n\n'
        enhanced_description+="$github_context"
    fi
    
    # 5a. AI Estimation moved out of the description and into the grooming comment
    
    # 6. Close markers
    enhanced_description+=$'\n\n'
    enhanced_description+="$end_marker"
    
    # Update ticket description
    local has_markers=$(echo "$current_description" | grep -q "$start_marker" && echo "true" || echo "false")
    if [[ "$has_markers" == "true" ]]; then
        info "Updating ticket description (replacing AI-generated content, preserving manual edits)..."

    else
        info "Updating ticket description..."
    fi
    
    # Convert enhanced description to JIRA ADF format
    local description_adf
    description_adf=$(markdown_to_jira_adf "$enhanced_description") || {
        error "markdown_to_jira_adf() failed to convert the description"
        exit 1
    }

    # Ensure .temp exists for intermediate ADF files
    local temp_dir="${SCRIPT_DIR}/../.temp"
    mkdir -p "$temp_dir"

    # Prepare enhanced ADF file
    local enhanced_adf_file="$temp_dir/${ticket_key}-enhanced-adf.json"
    printf "%s" "$description_adf" > "$enhanced_adf_file"

    # Prepare original ADF file: try to extract the ADF object from ticket_data
    local original_adf_file="$temp_dir/${ticket_key}-original-adf.json"
    # Determine description type: null / string / object
    local desc_type
    desc_type=$(echo "$ticket_data" | jq -r 'if .fields.description == null then "null" elif (.fields.description|type) == "string" then "string" else "object" end')

    # Initialize helpers
    original_summary=""
    orig_text=""

    if [[ "$desc_type" == "object" ]]; then
        # Save raw ADF object then try to strip any AI-generated nodes
        echo "$ticket_data" | jq '.fields.description' > "$original_adf_file"

        # If it's valid JSON, attempt to remove content nodes that contain the start marker
        if jq -e '.' "$original_adf_file" >/dev/null 2>&1; then
            jq --arg marker "$start_marker" '
                def contains_marker: (.. | objects | .text? // "" | contains($marker));
                . as $d |
                ($d.content | to_entries | map(select(.value | contains_marker) | .key) | .[0]) as $idx |
                if $idx == null then $d else { type: "doc", version: ($d.version // 1), content: ($d.content[0:$idx]) } end' "$original_adf_file" > "${original_adf_file}.tmp" && mv "${original_adf_file}.tmp" "$original_adf_file" || true
        fi

        # Extract a short human summary from the cleaned original ADF (first paragraph/text found)
        original_summary=$(jq -r '(.. | objects | select(.type=="paragraph") | .. | .text?) // empty' "$original_adf_file" 2>/dev/null | sed -n '1p' | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-200)

    elif [[ "$desc_type" == "string" ]]; then
        # The description is a string - try to parse as JSON ADF, otherwise treat as plain text
        orig_text=$(echo "$ticket_data" | jq -r '.fields.description')

        if printf "%s" "$orig_text" | jq -e '.' >/dev/null 2>&1; then
            # It's valid JSON (serialized ADF) - parse then strip AI-generated nodes if present
            printf "%s" "$orig_text" | jq '.' > "$original_adf_file"
            jq --arg marker "$start_marker" '
                def contains_marker: (.. | objects | .text? // "" | contains($marker));
                . as $d |
                ($d.content | to_entries | map(select(.value | contains_marker) | .key) | .[0]) as $idx |
                if $idx == null then $d else { type: "doc", version: ($d.version // 1), content: ($d.content[0:$idx]) } end' "$original_adf_file" > "${original_adf_file}.tmp" && mv "${original_adf_file}.tmp" "$original_adf_file" || true

            original_summary=$(jq -r '(.. | objects | select(.type=="paragraph") | .. | .text?) // empty' "$original_adf_file" 2>/dev/null | sed -n '1p' | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-200)
        else
            # Plain text - remove any AI-generated section (lines after start_marker) and wrap as codeBlock ADF
            local cleaned_text
            cleaned_text=$(printf "%s" "$orig_text" | awk -v m="$start_marker" '$0 ~ m {exit} {print}')

            # Detect probable language for the code block (json if starts with { or [)
            local lang="text"
            if printf "%s" "$cleaned_text" | sed -n '1p' | grep -Eq '^[[:space:]]*[{[]'; then
                lang="json"
            fi

            jq -n --arg text "$cleaned_text" --arg lang "$lang" \
              '{type: "doc", version: 1, content: [{type: "codeBlock", attrs: {language: $lang}, content: [{type: "text", text: $text}]}]}' > "$original_adf_file"

            original_summary=$(printf "%s" "$cleaned_text" | sed -n '1p' | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-200)
        fi

    else
        # No description present - write an empty JIRA doc to keep downstream code simple
        jq -n '{type: "doc", version: 1, content: []}' > "$original_adf_file"
        original_summary=""
    fi

    # Safety check: ensure the saved original ADF does NOT contain any AI-generated markers
    if jq -e --arg marker "$start_marker" '([.. | .text? // empty] | map(select(contains($marker))) | length) > 0' "$original_adf_file" >/dev/null 2>&1; then
        error "Saved original ADF contains AI-generated marker '$start_marker'. Aborting to avoid preserving AI content."
        echo "Original ADF saved at: $original_adf_file" >&2
        exit 1
    fi

    # Merge original + enhanced ADF using the Python helper to avoid fragile shell/json handling
    local merged_adf_file="$temp_dir/${ticket_key}-merged-adf.json"
    if ! python3 "${SCRIPT_DIR}/lib/merge_adf.py" --original "$original_adf_file" --enhanced "$enhanced_adf_file" --output "$merged_adf_file" >/dev/null 2>&1; then
        warning "merge_adf.py failed; falling back to using the enhanced ADF only"
        # Use the enhanced ADF as-is
        description_adf=$(cat "$enhanced_adf_file")
    else
        description_adf=$(cat "$merged_adf_file")
    fi

    # Validate that the final description_adf is valid JSON ADF
    if ! echo "$description_adf" | jq -e '.' >/dev/null 2>&1; then
        error "Final merged description is not valid JSON ADF. Aborting update."
        echo "Final output (truncated): $(echo "$description_adf" | head -c 200)" >&2
        exit 1
    fi
    
    # Build update JSON with story points if estimation is enabled
    local update_json
    if [[ "$enable_estimation" == "true" ]] && [[ -n "$story_points" ]]; then
        # Get story points field from env or use default
        local story_points_field="${JIRA_STORY_POINTS_FIELD:-customfield_10016}"
        
        update_json=$(jq -n \
            --argjson desc "$description_adf" \
            --arg points "$story_points" \
            --arg field "$story_points_field" \
            '{
                fields: {
                    description: $desc,
                    ($field): ($points | tonumber)
                }
            }')
    else
        update_json=$(jq -n \
            --argjson desc "$description_adf" \
            '{
                fields: {
                    description: $desc
                }
            }')
    fi
    
    if ! jira_update_issue "$ticket_key" "$update_json" > /dev/null; then
        error "Failed to update ticket description"
        exit 1
    fi
    
    # Add a comment documenting the grooming
    info "Adding grooming comment..."
    
    local comment_text="🤖 Ticket Groomed by JIRA Copilot Assistant\n\n"
    comment_text+="Added:\n"
    comment_text+="* 5 acceptance criteria\n"
    
    if [[ "$enable_estimation" == "true" ]] && [[ -n "$story_points" ]]; then
        comment_text+="* AI story point estimation: $story_points points\n\n"
        comment_text+="Estimation details:\n"
        comment_text+="$estimation_explanation\n\n"
    fi
    
    if [[ "$pr_count" -gt 0 ]]; then
        comment_text+="* $pr_count related PR reference(s)\n"
    fi
    
    if [[ "$commit_count" -gt 0 ]]; then
        comment_text+="* $commit_count related commit reference(s)\n"
    fi
    
    if [[ -n "$reference_file" ]]; then
        comment_text+="* Technical implementation guide from reference spec\n"
    fi
    
    comment_text+="\nThe ticket has been enhanced with additional context and requirements."
    
    if ! jira_add_comment "$ticket_key" "$comment_text" > /dev/null; then
        warning "Failed to add summary comment, but ticket was updated"
    fi

    # If estimation was enabled, also add a rich ADF-formatted comment with details
    if [[ "$enable_estimation" == "true" ]] && [[ -n "$story_points" ]]; then
        info "Adding ADF-formatted estimation comment..."
        local est_comment_file="/tmp/jira-estimation-comment-$$.json"

        # Use the helper Python script to build robust ADF JSON
        # NOTE: we intentionally generate the ADF payload to a temp file and POST it exactly once.
        # This avoids brittle double-posting and prevents curl from trying to read a file that
        # has already been removed. Keeping a single generate->post->cleanup sequence makes
        # the flow robust and easier to reason about in tests.
        if python3 "${SCRIPT_DIR}/lib/generate_estimation_adf.py" --points "$story_points" --explanation "$estimation_explanation" --output "$est_comment_file" >/dev/null 2>&1; then
            info "Generated estimation ADF payload: $est_comment_file"

            # Post the formatted comment to JIRA
            local add_est_resp
            add_est_resp=$(curl -s -X POST \
                -H "Authorization: Basic $(echo -n "${JIRA_EMAIL}:${JIRA_API_TOKEN}" | base64)" \
                -H "Content-Type: application/json" \
                -d @"$est_comment_file" \
                "${JIRA_BASE_URL}/rest/api/3/issue/${ticket_key}/comment")

            rm -f "$est_comment_file"

            if echo "$add_est_resp" | jq -e '.id' > /dev/null 2>&1; then
                success "Added ADF-formatted estimation comment"
            else
                warning "Failed to add ADF-formatted estimation comment"
                echo "$add_est_resp" | jq -r '.errorMessages[]?, .errors | to_entries[] | "\(.key): \(.value)"' 2>/dev/null || true
            fi
        else
            warning "Failed to generate ADF comment payload with helper; falling back to plain text comment"
        fi
    fi
    
    # If AI guide provided, use it directly (pre-generated by Claude/Copilot)
    if [[ -n "$ai_guide_file" ]]; then
        info "Adding AI-generated technical guide..."
        
        # Validate the AI guide file exists and is valid JSON
        if [[ ! -f "$ai_guide_file" ]]; then
            error "AI guide file not found: $ai_guide_file"
            return 1
        fi
        
        if ! jq '.' "$ai_guide_file" > /dev/null 2>&1; then
            error "AI guide file is not valid JSON: $ai_guide_file"
            return 1
        fi
        
        # Use JIRA API directly with the AI-generated JSON
        local add_comment_response=$(curl -s -X POST \
            -H "Authorization: Basic $(echo -n "${JIRA_EMAIL}:${JIRA_API_TOKEN}" | base64)" \
            -H "Content-Type: application/json" \
            -d @"$ai_guide_file" \
            "${JIRA_BASE_URL}/rest/api/3/issue/${ticket_key}/comment")
        
        if echo "$add_comment_response" | jq -e '.id' > /dev/null 2>&1; then
            success "Added AI-generated technical guide"
        else
            warning "Failed to add AI guide comment"
            echo "$add_comment_response" | jq -r '.errorMessages[]?, .errors | to_entries[] | "\(.key): \(.value)"' 2>/dev/null || true
        fi
        
    # If reference file provided, generate technical guide from template
    elif [[ -n "$reference_file" ]] && [[ -n "$technical_guide" ]]; then
        info "Adding technical implementation guide..."
        
        # Write JSON to temp file to avoid shell escaping issues
        local temp_comment_file="/tmp/jira-groom-comment-$$.json"
        echo "$technical_guide" > "$temp_comment_file"
        
        # Validate JSON before sending
        if ! jq '.' "$temp_comment_file" > /dev/null 2>&1; then
            error "Generated JSON is invalid. Saved to: $temp_comment_file"
            cat "$temp_comment_file" >&2
            return 1
        fi
        
        # Use JIRA API directly with properly formatted document JSON
        local add_comment_response=$(curl -s -X POST \
            -H "Authorization: Basic $(echo -n "${JIRA_EMAIL}:${JIRA_API_TOKEN}" | base64)" \
            -H "Content-Type: application/json" \
            -d @"$temp_comment_file" \
            "${JIRA_BASE_URL}/rest/api/3/issue/${ticket_key}/comment")
        
        # Clean up temp file
        rm -f "$temp_comment_file"
        
        if echo "$add_comment_response" | jq -e '.id' > /dev/null 2>&1; then
            success "Added formatted technical guide"
        else
            warning "Failed to add technical guide comment"
            echo "$add_comment_response" | jq -r '.errorMessages[]?, .errors | to_entries[] | "\(.key): \(.value)"' 2>/dev/null || true
        fi
    fi
    
    local ticket_url=$(get_issue_url "$ticket_key")
    
    # Success output
    echo ""
    success "Groomed: $ticket_key"
    
    if [[ -n "$ai_description_file" ]]; then
        success "Updated with AI-generated description"
    fi
    
    success "Added 5 acceptance criteria"
    
    if [[ "$enable_estimation" == "true" ]] && [[ -n "$story_points" ]]; then
        success "Set story points: $story_points"
    fi
    
    if [[ "$pr_count" -gt 0 ]]; then
        info "Found $pr_count related PR(s)"
    fi
    
    if [[ "$commit_count" -gt 0 ]]; then
        info "Found $commit_count related commit(s)"
    fi
    
    if [[ -n "$ai_guide_file" ]]; then
        success "Added AI-generated technical guide from: $(basename "$ai_guide_file")"
    elif [[ -n "$reference_file" ]]; then
        success "Added technical guide from: $(basename "$reference_file")"
    fi
    
    echo -e "${BLUE}🔗 $ticket_url${NC}"
    echo ""
}

# Run main function
main "$@"
