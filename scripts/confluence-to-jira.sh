#!/usr/bin/env bash
# Create JIRA ticket from Confluence page
# Fetches Confluence page content and creates JIRA ticket with extracted data

set -euo pipefail

# Get script directory for relative imports
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/confluence-api.sh"
source "${SCRIPT_DIR}/lib/jira-api.sh"

# Show help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Create JIRA ticket from Confluence page content.

OPTIONS:
    --url URL           Confluence page URL
    --page-id ID        Confluence page ID (alternative to --url)
    --project KEY       JIRA project key (required)
    --priority LEVEL    Priority: High, Medium, Low (optional, auto-detected)
    --help              Show this help message

EXAMPLES:
    # Create ticket from Confluence URL
    $(basename "$0") \\
      --url "https://sportsbet.atlassian.net/wiki/spaces/DATAFEEDS/pages/12907938514/" \\
      --project MSPOC

    # Create ticket from page ID
    $(basename "$0") \\
      --page-id "12907938514" \\
      --project MSPOC \\
      --priority High

ENVIRONMENT:
    CONFLUENCE_BASE_URL    Confluence base URL (e.g., https://company.atlassian.net/wiki)
    JIRA_EMAIL             Atlassian account email
    JIRA_API_TOKEN         Atlassian API token (same for Confluence and JIRA)
    JIRA_PROJECT           Default JIRA project key

EOF
}

# Parse command-line arguments
URL=""
PAGE_ID=""
PROJECT="${JIRA_PROJECT:-}"
PRIORITY=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            URL="$2"
            shift 2
            ;;
        --page-id)
            PAGE_ID="$2"
            shift 2
            ;;
        --project)
            PROJECT="$2"
            shift 2
            ;;
        --priority)
            PRIORITY="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

# Validate environment
load_env

if [ -z "${CONFLUENCE_BASE_URL:-}" ]; then
    error "CONFLUENCE_BASE_URL not set in environment"
    exit 1
fi

if [ -z "${JIRA_EMAIL:-}" ] || [ -z "${JIRA_API_TOKEN:-}" ]; then
    error "JIRA_EMAIL and JIRA_API_TOKEN required for Confluence authentication"
    exit 1
fi

# Extract page ID from URL if provided
if [ -n "$URL" ] && [ -z "$PAGE_ID" ]; then
    PAGE_ID=$(confluence_extract_page_id "$URL")
    if [ $? -ne 0 ]; then
        error "Failed to extract page ID from URL"
        exit 1
    fi
    info "Extracted page ID: $PAGE_ID"
fi

# Validate inputs
if [ -z "$PAGE_ID" ]; then
    error "Missing required argument: --url or --page-id"
    echo ""
    show_help
    exit 1
fi

if [ -z "$PROJECT" ]; then
    error "Missing required argument: --project"
    echo ""
    show_help
    exit 1
fi

# If dry-run, skip network authentication and show intended actions
if [ "$DRY_RUN" -eq 1 ]; then
    info "Dry-run: skipping Confluence and JIRA network calls. Showing what would be created..."

    # Ensure .temp exists and write a small artifact that tests/CI can inspect
    TEMP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.temp"
    mkdir -p "$TEMP_DIR"

    # Build minimal placeholders (we haven't fetched the Confluence page)
    local_title="Confluence page ${PAGE_ID:-<unknown>}"
    local_description="Content would be fetched from Confluence page: ${PAGE_ID:-<unknown>} (${URL:-<no-url>})"
    local_features=""

    echo "Project: $PROJECT"
    echo "Title: $local_title"
    echo "Description preview: ${local_description:0:200}"
    echo "Features: ${local_features:-<none>}"
    echo "Priority: ${PRIORITY:-Medium}"

    # Write a small JSON artifact for tests to assert on
    cat > "$TEMP_DIR/${PAGE_ID:-dryrun}-confluence-to-jira.json" <<EOF
{
  "project": "$PROJECT",
  "title": "$local_title",
  "description": "${local_description}",
  "features": "${local_features}",
  "priority": "${PRIORITY:-Medium}",
  "url": "${URL:-}"
}
EOF

    echo "Dry-run artifact written: $TEMP_DIR/${PAGE_ID:-dryrun}-confluence-to-jira.json"
    exit 0
fi

# Check authentication
info "Verifying Confluence authentication..."
if ! confluence_check_auth; then
    error "Confluence authentication failed. Check your credentials."
    exit 1
fi

# Fetch Confluence page
info "Fetching Confluence page: $PAGE_ID"
page_data=$(confluence_get_page "$PAGE_ID")
if [ $? -ne 0 ]; then
    error "Failed to fetch Confluence page"
    exit 1
fi

# Extract metadata
title=$(confluence_extract_metadata "$page_data" "title")
space=$(confluence_extract_metadata "$page_data" "space")
labels=$(confluence_extract_metadata "$page_data" "labels")

if [ -z "$title" ]; then
    error "Failed to extract page title"
    exit 1
fi

success "Fetched Confluence page: $title"
info "  Space: $space"
if [ -n "$labels" ]; then
    info "  Labels: $labels"
fi

# Get page content
content=$(confluence_get_content "$PAGE_ID" "storage")
if [ -z "$content" ]; then
    error "Failed to extract page content"
    exit 1
fi

# Extract description - try multiple strategies
description=""

# Strategy 1: Look for "Overview" section
overview_section=$(confluence_extract_section "$content" "Overview")
if [ -n "$overview_section" ]; then
    description=$(echo "$overview_section" | confluence_to_markdown | head -c 500)
fi

# Strategy 2: Look for "Description" section
if [ -z "$description" ]; then
    desc_section=$(confluence_extract_section "$content" "Description")
    if [ -n "$desc_section" ]; then
        description=$(echo "$desc_section" | confluence_to_markdown | head -c 500)
    fi
fi

# Strategy 3: Look for "Summary" section
if [ -z "$description" ]; then
    summary_section=$(confluence_extract_section "$content" "Summary")
    if [ -n "$summary_section" ]; then
        description=$(echo "$summary_section" | confluence_to_markdown | head -c 500)
    fi
fi

# Strategy 4: Use first paragraph
if [ -z "$description" ]; then
    description=$(confluence_get_first_paragraph "$content" | head -c 500)
fi

# Fallback description
if [ -z "$description" ]; then
    description="Content imported from Confluence page: $title"
fi

# Extract features/requirements from lists
features=$(confluence_extract_lists "$content")

# Detect priority from labels and content if not specified
if [ -z "$PRIORITY" ]; then
    PRIORITY="Medium"  # Default
    
    # Check labels for priority keywords
    labels_lower=$(echo "$labels" | tr '[:upper:]' '[:lower:]')
    if [[ "$labels_lower" =~ (urgent|critical|blocker|high-priority) ]]; then
        PRIORITY="High"
    elif [[ "$labels_lower" =~ (low-priority|nice-to-have) ]]; then
        PRIORITY="Low"
    fi
    
    # Check content for priority keywords
    content_lower=$(echo "$content" | tr '[:upper:]' '[:lower:]')
    if [[ "$content_lower" =~ (urgent|critical|blocker) ]]; then
        PRIORITY="High"
    elif [[ "$content_lower" =~ (low priority|nice to have) ]]; then
        PRIORITY="Low"
    fi
fi

# Build Confluence URL if not provided
if [ -z "$URL" ]; then
    space_key=$(confluence_extract_metadata "$page_data" "space_key")
    # Construct URL from page ID
    URL="${CONFLUENCE_BASE_URL}/spaces/${space_key}/pages/${PAGE_ID}"
fi

# Add Confluence link to description
full_description="${description}

---
**Source**: [Confluence: ${title}](${URL})
**Space**: ${space}
**Page ID**: ${PAGE_ID}"

# Show extracted data
info "📝 Extracted data:"
info "  Title: $title"
info "  Description: ${#description} characters"
if [ -n "$features" ]; then
    feature_count=$(echo "$features" | tr ',' '\n' | wc -l | tr -d ' ')
    info "  Requirements: $feature_count items"
fi
info "  Priority: $PRIORITY"

# Create JIRA ticket
info ""
info "Creating JIRA ticket in project $PROJECT..."

ticket_key=$(jira_create_issue "$PROJECT" "$title" "$full_description" "$features" "$PRIORITY")

if [ $? -eq 0 ] && [ -n "$ticket_key" ]; then
    echo ""
    success "✅ Created: $ticket_key"
    info "🔗 JIRA: ${JIRA_BASE_URL}/browse/${ticket_key}"
    info "🔗 Confluence: $URL"
    echo ""
    success "Ticket created successfully!"
    exit 0
else
    error "Failed to create JIRA ticket"
    exit 1
fi
