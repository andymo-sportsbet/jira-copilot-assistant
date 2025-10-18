#!/usr/bin/env bash
# Save Confluence page as local spec file
# Fetches Confluence page content and saves as markdown spec file for later JIRA ticket creation

set -euo pipefail

# Get script directory for relative imports
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/confluence-api.sh"

# Show help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Save Confluence page as local spec file (markdown format).
Enables version control of Confluence content and later JIRA ticket creation.

OPTIONS:
    --url URL           Confluence page URL
    --page-id ID        Confluence page ID (alternative to --url)
    --output PATH       Output file path (optional)
                        Default: specs/confluence-[PAGE_ID]/spec.md
    --help              Show this help message

EXAMPLES:
    # Save to default location (specs/confluence-[PAGE_ID]/spec.md)
    $(basename "$0") \\
      --url "https://company.atlassian.net/wiki/spaces/TECH/pages/123456/Feature"

    # Save to custom location
    $(basename "$0") \\
      --page-id "123456" \\
      --output "specs/001-my-feature/spec.md"

    # With Copilot (paste URL and say):
    "save this confluence page as a spec"

ENVIRONMENT:
    CONFLUENCE_BASE_URL    Confluence base URL (e.g., https://company.atlassian.net/wiki)
    JIRA_EMAIL             Atlassian account email
    JIRA_API_TOKEN         Atlassian API token (same for Confluence and JIRA)

OUTPUT:
    Generated spec file includes:
    - Front matter with Confluence metadata (URL, page ID, author, date, labels)
    - Title (# heading)
    - Overview/Description section
    - Requirements (if lists present)
    - Technical Details (if present)

NEXT STEPS:
    1. Review the generated spec file
    2. Edit locally as needed
    3. Create JIRA tickets: ./scripts/jira-create.sh --file [spec-file]

EOF
}

# Parse command-line arguments
URL=""
PAGE_ID=""
OUTPUT_PATH=""
SPACE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --url)
            URL="$2"
            shift 2
            ;;
            --space)
                SPACE="$2"
                shift 2
                ;;
        --page-id)
            PAGE_ID="$2"
            shift 2
            ;;
        --output)
            OUTPUT_PATH="$2"
            shift 2
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
    info "Add to .env: CONFLUENCE_BASE_URL=https://yourcompany.atlassian.net/wiki"
    exit 1
fi

if [ -z "${JIRA_EMAIL:-}" ] || [ -z "${JIRA_API_TOKEN:-}" ]; then
    error "JIRA_EMAIL and JIRA_API_TOKEN required for Confluence authentication"
    exit 1
fi

# Extract page ID from URL if provided
if [ -n "$URL" ] && [ -z "$PAGE_ID" ]; then
    PAGE_ID=$(confluence_extract_page_id "$URL")
    if [ $? -ne 0 ] || [ -z "$PAGE_ID" ]; then
        error "Could not extract page ID from URL: $URL"
        info "Supported formats:"
        info "  - https://[domain].atlassian.net/wiki/spaces/[SPACE]/pages/[PAGE_ID]/[TITLE]"
        info "  - https://[domain].atlassian.net/wiki/pages/[PAGE_ID]/"
        info "Or use --page-id parameter directly"
        exit 1
    fi
fi

# Validate we have a page ID
if [ -z "$PAGE_ID" ] && [ -z "$SPACE" ]; then
    error "Either --url, --page-id or --space is required"
    echo ""
    show_help
    exit 1
fi

# Set default output path if not provided
if [ -z "$OUTPUT_PATH" ]; then
    if [ -n "$PAGE_ID" ]; then
        OUTPUT_PATH="specs/confluence-${PAGE_ID}/spec.md"
    else
        OUTPUT_PATH="$OUTPUT"
    fi
fi

# Check Confluence authentication
info "Checking Confluence authentication..."
if ! confluence_check_auth; then
    error "Confluence authentication failed"
    info "Verify JIRA_EMAIL and JIRA_API_TOKEN in .env"
    info "Token must have Confluence read permissions"
    exit 1
fi

# Fetch Confluence page
info "Fetching Confluence page: $PAGE_ID..."
if [ -n "$PAGE_ID" ]; then
    page_data=$(confluence_get_page "$PAGE_ID")
    if [ $? -ne 0 ]; then
        error "Failed to fetch Confluence page $PAGE_ID"
        exit 1
    fi
fi

# If SPACE was provided, iterate pages in the space and generate spec files
if [ -n "$SPACE" ]; then
    info "Listing pages in space: $SPACE"
    ids=$(confluence_list_pages_in_space "$SPACE")
    if [ -z "$ids" ]; then
        info "No pages found in space $SPACE"
        exit 0
    fi
    for pid in $ids; do
        OUT_DIR="${OUTPUT}/${pid}"
        mkdir -p "$OUT_DIR"
        ./scripts/confluence-to-spec.sh --page-id "$pid" --output "$OUT_DIR/spec.md"
    done
    exit 0
fi

# Extract metadata
title=$(confluence_extract_metadata "$page_data" "title")
author=$(confluence_extract_metadata "$page_data" "author")
created=$(confluence_extract_metadata "$page_data" "created")
labels=$(confluence_extract_metadata "$page_data" "labels")
space=$(confluence_extract_metadata "$page_data" "space")
space_key=$(confluence_extract_metadata "$page_data" "space_key")
version=$(confluence_extract_metadata "$page_data" "version")

# Get page content
content_html=$(confluence_get_content "$PAGE_ID" "storage")
if [ $? -ne 0 ]; then
    error "Failed to get page content"
    exit 1
fi

# Convert to markdown
content_markdown=$(confluence_to_markdown "$content_html")

# Build Confluence URL
confluence_url="${CONFLUENCE_BASE_URL}/spaces/${space_key}/pages/${PAGE_ID}"

# Count sections (approximate by counting headings)
section_count=$(echo "$content_markdown" | grep -c "^#" || echo "0")

# Character count
char_count=$(echo "$content_markdown" | wc -c | tr -d ' ')

success "Fetched Confluence page: $title"
info "📝 Converted to markdown (${char_count} characters)"

# Extract sections for spec file structure
overview=$(confluence_extract_section "$content_html" "Overview" || \
           confluence_extract_section "$content_html" "Description" || \
           confluence_get_first_paragraph "$content_html" || \
           echo "")
overview_markdown=$(confluence_to_markdown "$overview")

requirements=$(confluence_extract_lists "$content_html" || echo "")
requirements_markdown=$(confluence_to_markdown "$requirements")

technical=$(confluence_extract_section "$content_html" "Technical" || \
            confluence_extract_section "$content_html" "Implementation" || \
            confluence_extract_section "$content_html" "Details" || \
            echo "")
technical_markdown=$(confluence_to_markdown "$technical")

# Create output directory
output_dir=$(dirname "$OUTPUT_PATH")
mkdir -p "$output_dir"

# Generate current date
current_date=$(date +%Y-%m-%d)

# Generate spec file with front matter and structure
cat > "$OUTPUT_PATH" << EOF
---
confluence_url: ${confluence_url}
confluence_page_id: ${PAGE_ID}
confluence_space: ${space}
author: ${author}
created_date: ${created:0:10}
generated_date: ${current_date}
labels: ${labels}
version: ${version}
---

# ${title}

## Overview
${overview_markdown:-*No overview section found in Confluence page.*}

EOF

# Add Requirements section if we found any lists
if [ -n "$requirements_markdown" ]; then
    cat >> "$OUTPUT_PATH" << EOF
## Requirements
${requirements_markdown}

EOF
fi

# Add Technical Details section if found
if [ -n "$technical_markdown" ]; then
    cat >> "$OUTPUT_PATH" << EOF
## Technical Details
${technical_markdown}

EOF
fi

# Add full content section
cat >> "$OUTPUT_PATH" << EOF
## Full Content
${content_markdown}

---
*Generated from Confluence on ${current_date}*
*Source: [${title}](${confluence_url})*
EOF

# Success output
success "📁 Created: $OUTPUT_PATH"
info "📊 Extracted:"
info "   - Title: $title"
[ -n "$author" ] && info "   - Author: $author"
[ -n "$labels" ] && info "   - Labels: $labels"
info "   - Sections: $section_count"
info "🔗 Confluence: ${confluence_url}"
echo ""
info "💡 Next steps:"
info "   - Review the spec file: $OUTPUT_PATH"
info "   - Create JIRA tickets: ./scripts/jira-create.sh --file $OUTPUT_PATH"
echo ""
