#!/usr/bin/env bash
# Confluence REST API helper functions
# Provides functions to interact with Confluence Cloud REST API

# Source utilities (use relative path from lib directory)
CONFLUENCE_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${CONFLUENCE_LIB_DIR}/utils.sh"

# Verify Confluence authentication
# Returns: 0 if authenticated, 1 if failed
confluence_check_auth() {
    local response=$(curl -s -w "\n%{http_code}" \
        -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
        "${CONFLUENCE_BASE_URL}/rest/api/user/current" 2>/dev/null)
    
    local http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "200" ]; then
        return 0
    else
        error "Confluence authentication failed (HTTP $http_code)"
        return 1
    fi
}

# Fetch Confluence page by ID
# Usage: confluence_get_page "12907938514"
# Returns: JSON page data
confluence_get_page() {
    local page_id="$1"
    
    if [ -z "$page_id" ]; then
        error "Page ID is required"
        return 1
    fi
    
    local response=$(curl -s -w "\n%{http_code}" \
        -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
        "${CONFLUENCE_BASE_URL}/rest/api/content/${page_id}?expand=body.storage,version,space,metadata.labels" 2>/dev/null)
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo "$body"
        return 0
    elif [ "$http_code" = "404" ]; then
        error "Confluence page not found: $page_id"
        return 1
    elif [ "$http_code" = "403" ]; then
        error "No permission to access Confluence page: $page_id"
        return 1
    else
        error "Failed to fetch Confluence page (HTTP $http_code)"
        return 1
    fi
}

# Get page content in specific format
# Usage: confluence_get_content "12907938514" "storage"
# Formats: storage (default), view, export_view
# Returns: Page content in requested format
confluence_get_content() {
    local page_id="$1"
    local format="${2:-storage}"  # storage, view, export_view
    
    local page_data=$(confluence_get_page "$page_id")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    echo "$page_data" | jq -r ".body.${format}.value // empty"
}

# Extract page metadata field
# Usage: confluence_extract_metadata "$page_data" "title"
# Fields: title, id, type, status, space, version
# Returns: Field value
confluence_extract_metadata() {
    local page_data="$1"
    local field="$2"
    
    if [ -z "$page_data" ] || [ -z "$field" ]; then
        error "Page data and field name are required"
        return 1
    fi
    
    case "$field" in
        "title"|"id"|"type"|"status")
            echo "$page_data" | jq -r ".${field} // empty"
            ;;
        "space")
            echo "$page_data" | jq -r '.space.name // empty'
            ;;
        "space_key")
            echo "$page_data" | jq -r '.space.key // empty'
            ;;
        "version")
            echo "$page_data" | jq -r '.version.number // empty'
            ;;
        "author")
            echo "$page_data" | jq -r '.version.by.displayName // empty'
            ;;
        "created")
            echo "$page_data" | jq -r '.version.when // empty'
            ;;
        "labels")
            echo "$page_data" | jq -r '.metadata.labels.results[].name // empty' | tr '\n' ',' | sed 's/,$//'
            ;;
        *)
            error "Unknown metadata field: $field"
            return 1
            ;;
    esac
}

# Convert Confluence storage format (XHTML) to markdown (basic conversion)
# Usage: confluence_to_markdown "$html_content"
# Returns: Markdown text
confluence_to_markdown() {
    local html="$1"
    
    if [ -z "$html" ]; then
        return 0
    fi
    
    # Improved HTML to markdown conversion
    # Step 1: Add newlines before/after block elements to ensure proper line breaks
    # Step 2: Convert HTML tags to markdown
    # Step 3: Clean up formatting
    
    echo "$html" | \
        # Remove XML/HTML tags we don't need
        sed 's/<ac:[^>]*>//g' | \
        sed 's/<\/ac:[^>]*>//g' | \
        # Add newlines before headings to ensure they're on their own line
        sed 's/<h1[^>]*>/\n\n# /g' | \
        sed 's/<\/h1>/\n/g' | \
        sed 's/<h2[^>]*>/\n\n## /g' | \
        sed 's/<\/h2>/\n/g' | \
        sed 's/<h3[^>]*>/\n\n### /g' | \
        sed 's/<\/h3>/\n/g' | \
        sed 's/<h4[^>]*>/\n\n#### /g' | \
        sed 's/<\/h4>/\n/g' | \
        sed 's/<h5[^>]*>/\n\n##### /g' | \
        sed 's/<\/h5>/\n/g' | \
        sed 's/<h6[^>]*>/\n\n###### /g' | \
        sed 's/<\/h6>/\n/g' | \
        # Convert lists - add newlines to ensure proper formatting
        sed 's/<ul[^>]*>/\n/g' | \
        sed 's/<\/ul>/\n/g' | \
        sed 's/<ol[^>]*>/\n/g' | \
        sed 's/<\/ol>/\n/g' | \
        sed 's/<li[^>]*>/\n- /g' | \
        sed 's/<\/li>//g' | \
        # Convert paragraphs - ensure they're separated
        sed 's/<p[^>]*>/\n/g' | \
        sed 's/<\/p>/\n\n/g' | \
        # Convert line breaks
        sed 's/<br[^>]*>/\n/g' | \
        sed 's/<br>/\n/g' | \
        # Convert code blocks
        sed 's/<code[^>]*>/`/g' | \
        sed 's/<\/code>/`/g' | \
        sed 's/<pre[^>]*>/\n```\n/g' | \
        sed 's/<\/pre>/\n```\n/g' | \
        # Convert emphasis (handle both opening and closing tags)
        sed 's/<strong[^>]*>/**/g' | \
        sed 's/<\/strong>/**/g' | \
        sed 's/<em[^>]*>/*/g' | \
        sed 's/<\/em>/*/g' | \
        sed 's/<b[^>]*>/**/g' | \
        sed 's/<\/b>/**/g' | \
        sed 's/<i[^>]*>/*/g' | \
        sed 's/<\/i>/*/g' | \
        # Remove links (keep link text, remove href)
        sed 's/<a[^>]*>//g' | \
        sed 's/<\/a>//g' | \
        # Remove remaining HTML tags (including their attributes)
        sed 's/<[^>]*>//g' | \
        # Decode common HTML entities
        sed 's/&nbsp;/ /g' | \
        sed 's/&amp;/\&/g' | \
        sed 's/&lt;/</g' | \
        sed 's/&gt;/>/g' | \
        sed 's/&quot;/"/g' | \
        sed "s/&apos;/'/g" | \
        sed 's/&ldquo;/"/g' | \
        sed 's/&rdquo;/"/g' | \
        sed "s/&lsquo;/'/g" | \
        sed "s/&rsquo;/'/g" | \
        sed 's/&mdash;/—/g' | \
        sed 's/&ndash;/–/g' | \
        # Clean up excessive whitespace but preserve paragraph breaks
        sed 's/^[[:space:]]*//g' | \
        sed 's/[[:space:]]*$//g' | \
        # Remove lines that are only whitespace
        sed '/^$/d' | \
        # Add back strategic blank lines after headings and paragraphs
        sed 's/^#/\n#/g' | \
        # Final cleanup - remove leading newlines
        sed '1{/^$/d;}' | \
        # Remove more than 2 consecutive blank lines
        cat -s
}

# Extract specific section from Confluence page by heading
# Usage: confluence_extract_section "$content" "Overview"
# Returns: Section content between heading and next heading
confluence_extract_section() {
    local content="$1"
    local heading="$2"
    
    if [ -z "$content" ] || [ -z "$heading" ]; then
        return 1
    fi
    
    # Try to find section with various heading levels
    # Look for: <h1>heading</h1>, <h2>heading</h2>, etc.
    local section=$(echo "$content" | \
        sed -n "/<h[0-9][^>]*>${heading}<\/h[0-9]>/,/<h[0-9][^>]*>/p" | \
        sed '$d' | \
        tail -n +2)
    
    if [ -n "$section" ]; then
        echo "$section"
        return 0
    fi
    
    # Alternative: Try case-insensitive match
    section=$(echo "$content" | \
        sed -n "/<h[0-9][^>]*>.*${heading}.*<\/h[0-9]>/I,/<h[0-9][^>]*>/Ip" | \
        sed '$d' | \
        tail -n +2)
    
    if [ -n "$section" ]; then
        echo "$section"
        return 0
    fi
    
    return 1
}

# Extract lists from Confluence content
# Usage: confluence_extract_lists "$content"
# Returns: Comma-separated list items
confluence_extract_lists() {
    local content="$1"
    
    if [ -z "$content" ]; then
        return 0
    fi
    
    # Extract all <li> items and join with commas
    echo "$content" | \
        grep -o '<li[^>]*>.*</li>' | \
        sed 's/<li[^>]*>//g' | \
        sed 's/<\/li>//g' | \
        sed 's/<[^>]*>//g' | \
        sed 's/^[[:space:]]*//g' | \
        sed 's/[[:space:]]*$//g' | \
        paste -sd ',' -
}

# Extract first paragraph from content
# Usage: confluence_get_first_paragraph "$content"
# Returns: First paragraph text
confluence_get_first_paragraph() {
    local content="$1"
    
    if [ -z "$content" ]; then
        return 0
    fi
    
    # Get first <p> tag content
    echo "$content" | \
        sed -n 's/.*<p[^>]*>\(.*\)<\/p>.*/\1/p' | \
        head -1 | \
        sed 's/<[^>]*>//g'
}

# Extract page ID from Confluence URL
# Usage: confluence_extract_page_id "https://domain.atlassian.net/wiki/spaces/SPACE/pages/12345/Title"
# Returns: Page ID (numeric)
confluence_extract_page_id() {
    local url="$1"
    
    if [ -z "$url" ]; then
        error "URL is required"
        return 1
    fi
    
    # Extract numeric page ID from various URL formats
    local page_id=""
    
    # Format 1: /pages/12345/Title or /pages/12345
    page_id=$(echo "$url" | grep -oE '/pages/[0-9]+' | grep -oE '[0-9]+')
    
    # Format 2: ?pageId=12345
    if [ -z "$page_id" ]; then
        page_id=$(echo "$url" | grep -oE 'pageId=[0-9]+' | grep -oE '[0-9]+')
    fi
    
    if [ -z "$page_id" ]; then
        error "Could not extract page ID from URL: $url"
        return 1
    fi
    
    echo "$page_id"
    return 0
}

# Debug: Print Confluence environment configuration
confluence_debug_config() {
    if [ "${DEBUG:-false}" = "true" ]; then
        info "Confluence Configuration:"
        info "  CONFLUENCE_BASE_URL: ${CONFLUENCE_BASE_URL:-not set}"
        info "  JIRA_EMAIL: ${JIRA_EMAIL:-not set}"
        info "  JIRA_API_TOKEN: ${JIRA_API_TOKEN:+***set***}"
    fi
}
